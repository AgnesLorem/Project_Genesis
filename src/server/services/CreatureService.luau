local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)
local SaveService = require(script.Parent.SaveService)
local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
local HttpService = game:GetService("HttpService")

local CreatureService = {}

function CreatureService.tryGrantCreature(player: Player, creatureId: string)
	local config = CreatureRegistry.getCreature(creatureId)
	if not config then
		return Result.fail("invalid_creature", "Invalid Creature ID rejected.")
	end

	if not config.isEnabled then
		return Result.fail("disabled_creature", "Disabled Creature rejected.")
	end

	local playerSave = SaveService.getPlayerSave(player)
	local instances = playerSave.creatureInstances or {}

	for _, instance in pairs(instances) do
		if instance.creatureId == creatureId then
			return Result.fail(
				"duplicate_grant",
				"Duplicate grant behavior follows documented rule: cannot grant duplicate."
			)
		end
	end

	local instanceId = HttpService:GenerateGUID(false)
	local newInstance = {
		instanceId = instanceId,
		creatureId = creatureId,
		level = 1,
		xp = 0,
		acquiredAt = os.time(),
	}

	instances[instanceId] = newInstance
	playerSave.creatureInstances = instances
	SaveService.markDirty(player)

	local CollectionService = require(script.Parent.CollectionService)
	CollectionService.discoverCreature(player, creatureId)

	return Result.ok(newInstance)
end

function CreatureService.getPlayerCreatures(player: Player)
	local playerSave = SaveService.getPlayerSave(player)
	return playerSave.creatureInstances or {}
end

function CreatureService.addCreatureXp(player: Player, instanceId: string, amount: number)
	if type(instanceId) ~= "string" or instanceId == "" then
		return Result.fail("invalid_request", "instanceId must be a non-empty string.")
	end
	if type(amount) ~= "number" or amount < 1 or amount ~= math.floor(amount) then
		return Result.fail("invalid_amount", "XP amount must be a positive integer.")
	end

	local playerSave = SaveService.getPlayerSave(player)
	local instances = playerSave.creatureInstances or {}
	local creature = instances[instanceId]
	if not creature then
		return Result.fail("not_found", "Creature instance not found.")
	end

	if not creature.level then
		creature.level = 1
	end
	if not creature.xp then
		creature.xp = 0
	end

	creature.xp += amount

	local function getXpNeeded(level)
		return level * 100
	end

	local SimulationGuard = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.SimulationGuard)
	local guard = SimulationGuard.new({
		maxSteps = 500,
		timeoutSeconds = 0.5,
		noProgressLimit = 100,
		context = "CreatureService:addXp",
	})

	local leveledUp = false
	while creature.xp >= getXpNeeded(creature.level) and guard:step() do
		creature.xp -= getXpNeeded(creature.level)
		creature.level += 1
		leveledUp = true
		guard:markProgress()
	end

	if guard:shouldStop() then
		guard:logDiagnostic({ creatureId = creature.creatureId, finalLevel = creature.level, remainingXp = creature.xp })
		warn("[CreatureService] Loop stalled while leveling up instance: " .. tostring(instanceId))
	end

	SaveService.markDirty(player)

	return Result.ok({
		level = creature.level,
		xp = creature.xp,
		leveledUp = leveledUp,
	})
end

--[[
	CreatureService.setActiveCreature(player, instanceId) -> Result
	Sets the player's active creature for battle.
	Validates:
	  - instanceId is a non-empty string
	  - player owns the instance
	Marks save dirty on success.
--]]
function CreatureService.setActiveCreature(player: Player, instanceId: string)
	if type(instanceId) ~= "string" or instanceId == "" then
		return Result.fail("invalid_request", "instanceId must be a non-empty string.")
	end

	local playerSave = SaveService.getPlayerSave(player)
	local instances = playerSave.creatureInstances or {}
	local creature = instances[instanceId]

	if not creature then
		return Result.fail("unowned_creature", "Player does not own a creature with that instanceId.")
	end

	playerSave.activeCreatureInstanceId = instanceId
	SaveService.markDirty(player)

	return Result.ok(instanceId)
end

--[[
	CreatureService.getActiveCreatureInstanceId(player) -> string?
	Returns the player's current active creature instanceId.
	Auto-recovers: if the stored id is no longer valid (creature was removed),
	selects the first owned creature and persists the recovery.
	Returns nil if the player has no creatures.
--]]
function CreatureService.getActiveCreatureInstanceId(player: Player): string?
	local playerSave = SaveService.getPlayerSave(player)
	local instances = playerSave.creatureInstances or {}
	local activeId = playerSave.activeCreatureInstanceId

	-- Validate stored id still refers to an owned instance
	if activeId ~= nil then
		if type(instances[activeId]) == "table" then
			return activeId
		else
			-- Stale reference — clear and fall through to auto-recovery
			warn(
				string.format(
					"[CreatureService] activeCreatureInstanceId '%s' no longer valid for player %d — recovering.",
					tostring(activeId),
					player.UserId
				)
			)
			playerSave.activeCreatureInstanceId = nil
		end
	end

	-- Auto-recovery: pick first available owned creature
	for id, inst in pairs(instances) do
		if type(inst) == "table" then
			playerSave.activeCreatureInstanceId = id
			SaveService.markDirty(player)
			return id
		end
	end

	-- No creatures owned
	return nil
end

return CreatureService
