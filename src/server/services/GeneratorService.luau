--[[
	GeneratorService
	Location: src/server/services/GeneratorService.luau

	Server-authoritative generator accumulation, claiming, unlocks, and upgrades.
	Server calculates all accumulated amounts. Never trusts client time or amount.

	Part of MVP-019: Generator Expansion.
--]]

local GeneratorRegistry = require(script.Parent.Parent.data.GeneratorRegistry)
local StageOrder = require(script.Parent.Parent.data.StageOrder)
local CurrencyService = require(script.Parent.CurrencyService)
local SaveService = require(script.Parent.SaveService)
local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local GeneratorService = {}

local CLAIM_SPAM_WINDOW_SECONDS = 0.25
local UPGRADE_SPAM_WINDOW_SECONDS = 0.25
local LEGACY_GENERATOR_ID = "bio_generator_01"

local recentClaimAtByKey: { [string]: number } = {}
local recentUpgradeAtByKey: { [string]: number } = {}
local claimLocks: { [string]: boolean } = {}
local upgradeLocks: { [string]: boolean } = {}

local function _getPlayerKey(player: any): string
	if typeof(player) == "Instance" and player:IsA("Player") then
		return tostring(player.UserId)
	end
	if type(player) == "table" and player.UserId then
		return tostring(player.UserId)
	end
	return tostring(player)
end

local function _claimKey(player: any, generatorId: string): string
	return _getPlayerKey(player) .. ":" .. generatorId
end

local function _upgradeKey(player: any, generatorId: string): string
	return _getPlayerKey(player) .. ":" .. generatorId
end

local function _now(): number
	return os.time()
end

local function _validateGeneratorId(generatorId: any)
	if type(generatorId) ~= "string" or generatorId == "" then
		return Result.fail("invalid_generator", "Generator request requires a non-empty generatorId.")
	end
	return Result.ok(generatorId)
end

local function _currencyType(config: any): string
	return config.currencyType or config.currencyId
end

local function _baseRate(config: any): number
	return config.baseRate or config.ratePerSecond or 0
end

local function _baseCapacity(config: any): number
	return config.capacity or config.maxAccumulated or 0
end

local function _effectiveRate(config: any, level: number): number
	return _baseRate(config) * math.max(1, level)
end

local function _effectiveCapacity(config: any, level: number): number
	return _baseCapacity(config) * math.max(1, level)
end

local function _upgradeCostAmount(config: any, level: number): number
	local cost = config.upgradeCost or {}
	local baseAmount = cost.amount or 1
	if config.upgradeCostExponent then
		return math.max(1, math.floor(baseAmount * (level ^ config.upgradeCostExponent)))
	elseif config.upgradeCostMultiplier then
		return math.max(1, math.floor(baseAmount * (config.upgradeCostMultiplier ^ (level - 1))))
	else
		return math.max(1, math.floor(baseAmount * math.max(1, level)))
	end
end

local function _ensureGeneratorContainer(save: any)
	if type(save.economyState) ~= "table" then
		save.economyState = { balances = {}, generators = {} }
	end
	if type(save.economyState.balances) ~= "table" then
		save.economyState.balances = {}
	end
	if type(save.economyState.generators) ~= "table" then
		save.economyState.generators = {}
	end
end

local function _migrateLegacyGeneratorState(save: any)
	_ensureGeneratorContainer(save)
	if
		save.economyState.generators.bio_generator == nil
		and save.economyState.generators[LEGACY_GENERATOR_ID] ~= nil
	then
		save.economyState.generators.bio_generator = save.economyState.generators[LEGACY_GENERATOR_ID]
	end
end

local function _getRawGeneratorState(save: any, generatorId: string): any
	_migrateLegacyGeneratorState(save)
	return save.economyState.generators[generatorId]
end

local function _evaluateUnlock(player: any, save: any, config: any): boolean
	local requirement = config.unlockRequirement or { type = "always" }
	local requirementType = requirement.type

	if requirementType == "always" then
		return true
	end

	if requirementType == "currencyBalance" then
		local balances = save.economyState and save.economyState.balances or {}
		return (balances[requirement.currencyType] or 0) >= (requirement.amount or math.huge)
	end

	if requirementType == "generatorLevel" then
		local requiredGeneratorId = requirement.generatorId
		if type(requiredGeneratorId) ~= "string" or requiredGeneratorId == config.generatorId then
			return false
		end

		local requiredConfig = GeneratorRegistry.getGenerator(requiredGeneratorId)
		if not requiredConfig or not requiredConfig.isEnabled then
			return false
		end

		local requiredState = _getRawGeneratorState(save, requiredGeneratorId)
		if not requiredState then
			requiredState = {
				schemaVersion = 2,
				level = 1,
				lastClaimedAt = _now(),
				unlocked = _evaluateUnlock(player, save, requiredConfig),
			}
			save.economyState.generators[requiredGeneratorId] = requiredState
			SaveService.markDirty(player)
		end

		return (requiredState.level or 1) >= (requirement.level or math.huge)
	end

	if requirementType == "stageClear" then
		-- DD-029: unlocked when the player holds any stage index that comes
		-- AFTER requirement.stageId in the shared STAGE_ORDER sequence.
		local targetIndex = StageOrder.getIndex(requirement.stageId)
		if not targetIndex then
			return false
		end

		local unlockedStages = save.worldProgression and save.worldProgression.unlockedStages
		if type(unlockedStages) ~= "table" then
			return false
		end

		for _, unlockedStageId in ipairs(unlockedStages) do
			local unlockedIndex = StageOrder.getIndex(unlockedStageId)
			if unlockedIndex and unlockedIndex > targetIndex then
				return true
			end
		end

		return false
	end

	return false
end

local function _ensureGeneratorState(player: any, generatorId: string, config: any): any
	local save = SaveService.getPlayerSave(player)
	if not save then
		return nil
	end

	_migrateLegacyGeneratorState(save)
	local genState = save.economyState.generators[generatorId]
	local changed = false
	local now = _now()

	if type(genState) ~= "table" then
		genState = {
			schemaVersion = 2,
			level = 1,
			lastClaimedAt = now,
			unlocked = false,
		}
		save.economyState.generators[generatorId] = genState
		changed = true
	end

	if genState.schemaVersion ~= 2 then
		genState.schemaVersion = 2
		changed = true
	end
	if type(genState.level) ~= "number" or genState.level < 1 or genState.level ~= math.floor(genState.level) then
		genState.level = 1
		changed = true
	end
	if type(genState.lastClaimedAt) ~= "number" then
		genState.lastClaimedAt = now
		changed = true
	end

	local wasUnlocked = genState.unlocked == true
	local isUnlocked = _evaluateUnlock(player, save, config)
	if genState.unlocked ~= isUnlocked then
		genState.unlocked = isUnlocked
		changed = true
		if isUnlocked and not wasUnlocked then
			genState.lastClaimedAt = now
		end
	end

	if changed then
		SaveService.markDirty(player)
	end

	return genState
end

local function _calculateAccumulated(genState: any, config: any): number
	if not genState or not genState.lastClaimedAt then
		return 0
	end
	if genState.unlocked ~= true then
		return 0
	end

	local level = genState.level or 1
	local now = _now()
	local elapsed = math.max(0, now - genState.lastClaimedAt)
	local accumulated = math.floor(elapsed * _effectiveRate(config, level))
	return math.min(accumulated, _effectiveCapacity(config, level))
end

--[[
	GeneratorService.getAccumulated(player, generatorId) -> number

	Returns the integer amount of currency accumulated since last claim.
	If the player has never used this generator, initializes state and returns 0.
	Server calculates everything. Never trusts client.
--]]
function GeneratorService.getAccumulated(player: any, generatorId: string): number
	local idResult = _validateGeneratorId(generatorId)
	if not idResult.success then
		return 0
	end

	local config = GeneratorRegistry.getGenerator(generatorId)
	if not config then
		return 0
	end

	local genState = _ensureGeneratorState(player, generatorId, config)
	local accumulated = _calculateAccumulated(genState, config)

	return accumulated
end

function GeneratorService.getSnapshot(player: any, generatorId: string)
	local idResult = _validateGeneratorId(generatorId)
	if not idResult.success then
		return nil
	end

	local config = GeneratorRegistry.getGenerator(generatorId)
	if not config then
		return nil
	end
	if not config.isEnabled then
		return nil
	end

	local genState = _ensureGeneratorState(player, generatorId, config)
	if not genState then
		return nil
	end

	local level = genState.level or 1
	local rate = _effectiveRate(config, level)
	local capacity = _effectiveCapacity(config, level)
	local accumulated = _calculateAccumulated(genState, config)
	local upgradeCost = config.upgradeCost or {}
	local nextUpgradeCost = {
		currencyType = upgradeCost.currencyType,
		amount = _upgradeCostAmount(config, level),
	}

	return {
		generatorId = config.generatorId,
		displayName = config.displayName,
		sortOrder = config.sortOrder or 0,
		currencyType = _currencyType(config),
		currencyId = _currencyType(config),
		baseRate = _baseRate(config),
		ratePerSecond = rate,
		capacity = capacity,
		maxAccumulated = capacity,
		lastClaimedAt = genState.lastClaimedAt,
		accumulated = accumulated,
		level = level,
		maxLevel = config.maxLevel,
		isUnlocked = genState.unlocked == true,
		canClaim = genState.unlocked == true and accumulated >= 1,
		canUpgrade = genState.unlocked == true and level < config.maxLevel,
		upgradeCost = nextUpgradeCost,
		unlockRequirement = config.unlockRequirement,
	}
end

function GeneratorService.getAllSnapshots(player: any)
	local snapshots = {}
	for _, config in ipairs(GeneratorRegistry.getAllGenerators()) do
		if config.isEnabled then
			local snapshot = GeneratorService.getSnapshot(player, config.generatorId)
			if snapshot then
				table.insert(snapshots, snapshot)
			end
		end
	end
	table.sort(snapshots, function(a, b)
		if a.sortOrder == b.sortOrder then
			return a.generatorId < b.generatorId
		end
		return a.sortOrder < b.sortOrder
	end)
	return snapshots
end

function GeneratorService.getSnapshotResult(player: any, generatorId: any?)
	local save = SaveService.getPlayerSave(player)
	if not save then
		return Result.fail("not_loaded", "Player save data not loaded.")
	end

	if generatorId ~= nil then
		local idResult = _validateGeneratorId(generatorId)
		if not idResult.success then
			return idResult
		end
		local config = GeneratorRegistry.getGenerator(generatorId)
		if not config then
			return Result.fail("invalid_generator", "Generator config not found.")
		end
		if not config.isEnabled then
			return Result.fail("generator_disabled", "Generator is disabled.")
		end
		local snapshot = GeneratorService.getSnapshot(player, generatorId)
		if not snapshot then
			return Result.fail("snapshot_failed", "Generator snapshot unavailable.")
		end
		return Result.ok({
			schemaVersion = 1,
			generator = snapshot,
			generators = { snapshot },
			balances = save.economyState.balances or {},
		})
	end

	return Result.ok({
		schemaVersion = 1,
		generators = GeneratorService.getAllSnapshots(player),
		balances = save.economyState.balances or {},
	})
end

local function _withLock(lockTable: { [string]: boolean }, key: string, lockedCode: string, callback: () -> any)
	if lockTable[key] then
		return Result.fail(lockedCode, "Generator request is already being processed.")
	end

	lockTable[key] = true
	local ok, result = pcall(callback)
	lockTable[key] = nil

	if not ok then
		warn("[GeneratorService] Request failed safely: " .. tostring(result))
		return Result.fail("generator_request_failed", "Generator request failed safely.")
	end

	return result
end

local function _getEnabledConfig(generatorId: any)
	local idResult = _validateGeneratorId(generatorId)
	if not idResult.success then
		return nil, idResult
	end

	local config = GeneratorRegistry.getGenerator(generatorId)
	if not config then
		return nil, Result.fail("invalid_generator", "Generator config not found.")
	end
	if not config.isEnabled then
		return nil, Result.fail("generator_disabled", "Generator is disabled.")
	end

	return config, nil
end

local function _ensureUnlocked(player: any, generatorId: string, config: any)
	local genState = _ensureGeneratorState(player, generatorId, config)
	if not genState then
		return nil, Result.fail("not_loaded", "Player save data not loaded.")
	end
	if genState.unlocked ~= true then
		return nil, Result.fail("generator_locked", "Generator is locked.")
	end
	return genState, nil
end

function GeneratorService.tryUpgrade(player: any, generatorId: any)
	local config, configError = _getEnabledConfig(generatorId)
	if not config then
		return configError
	end

	local upgradeKey = _upgradeKey(player, generatorId)
	return _withLock(upgradeLocks, upgradeKey, "upgrade_in_progress", function()
		local lastUpgradeAt = recentUpgradeAtByKey[upgradeKey]
		if lastUpgradeAt and os.clock() - lastUpgradeAt < UPGRADE_SPAM_WINDOW_SECONDS then
			return Result.fail("upgrade_rate_limited", "Generator upgrade was too recent.")
		end

		local genState, unlockError = _ensureUnlocked(player, generatorId, config)
		if not genState then
			return unlockError
		end

		local level = genState.level or 1
		if level >= config.maxLevel then
			return Result.fail("max_level", "Generator is already at max level.")
		end

		local cost = config.upgradeCost or {}
		local costCurrency = cost.currencyType
		local costAmount = _upgradeCostAmount(config, level)
		local spendResult = CurrencyService.trySpend(player, costCurrency, costAmount, "generator_upgrade")
		if not spendResult.success then
			return spendResult
		end

		genState.level = level + 1
		genState.lastClaimedAt = _now()
		genState.unlocked = _evaluateUnlock(player, SaveService.getPlayerSave(player), config)
		recentUpgradeAtByKey[upgradeKey] = os.clock()
		SaveService.savePlayer(player)

		return Result.ok({
			generatorId = generatorId,
			level = genState.level,
			spent = spendResult.value.spent,
			newBalance = spendResult.value.newBalance,
			snapshot = GeneratorService.getSnapshot(player, generatorId),
		})
	end)
end

--[[
	GeneratorService.tryClaim(player, generatorId) -> Result

	Claims accumulated currency from a generator.
	Server calculates the amount. Client cannot specify time or amount.

	Returns Result.ok({ claimed = number, newBalance = number }) on success.
	Returns Result.fail(code, message) on failure.
--]]
function GeneratorService.tryClaim(player: any, generatorId: any)
	local config, configError = _getEnabledConfig(generatorId)
	if not config then
		return configError
	end

	local claimKey = _claimKey(player, generatorId)
	return _withLock(claimLocks, claimKey, "claim_in_progress", function()
		local lastClaimAt = recentClaimAtByKey[claimKey]
		if lastClaimAt and os.clock() - lastClaimAt < CLAIM_SPAM_WINDOW_SECONDS then
			return Result.fail("claim_rate_limited", "Generator claim was too recent.")
		end

		local genState, unlockError = _ensureUnlocked(player, generatorId, config)
		if not genState then
			return unlockError
		end

		local accumulated = _calculateAccumulated(genState, config)
		if accumulated < 1 then
			return Result.fail("NOTHING_TO_CLAIM", "Less than 1 unit accumulated.")
		end

		local grantResult = CurrencyService.tryGrant(player, _currencyType(config), accumulated, "generator_claim")

		if not grantResult.success then
			return grantResult
		end

		genState.lastClaimedAt = _now()
		genState.unlocked = _evaluateUnlock(player, SaveService.getPlayerSave(player), config)
		recentClaimAtByKey[claimKey] = os.clock()
		SaveService.savePlayer(player)

		return Result.ok({
			generatorId = generatorId,
			claimed = grantResult.value.granted,
			newBalance = grantResult.value.newBalance,
			snapshot = GeneratorService.getSnapshot(player, generatorId),
		})
	end)
end

function GeneratorService.ensureAllGeneratorStates(player: any)
	local save = SaveService.getPlayerSave(player)
	if not save then
		return Result.fail("not_loaded", "Player save data not loaded.")
	end

	for _, config in ipairs(GeneratorRegistry.getAllGenerators()) do
		if config.isEnabled then
			_ensureGeneratorState(player, config.generatorId, config)
		end
	end

	return Result.ok(GeneratorService.getAllSnapshots(player))
end

return GeneratorService
