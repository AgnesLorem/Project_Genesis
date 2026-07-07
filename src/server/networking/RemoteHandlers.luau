--[[
	RemoteHandlers
	Location: src/server/networking/RemoteHandlers.luau

	Server-authoritative boundary for client requests.
	Maps RemoteFunctions to internal Services with Middleware protections.
--]]

local Players = game:GetService("Players")
local Network = require(game:GetService("ReplicatedStorage").Genesis.Shared.remotes.Network)
local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local SaveService = require(script.Parent.Parent.services.SaveService)
local CreatureService = require(script.Parent.Parent.services.CreatureService)
local CollectionService = require(script.Parent.Parent.services.CollectionService)
local CurrencyService = require(script.Parent.Parent.services.CurrencyService)
local EquipmentService = require(script.Parent.Parent.services.EquipmentService)
local EvolutionService = require(script.Parent.Parent.services.EvolutionService)
local GeneratorService = require(script.Parent.Parent.services.GeneratorService)
local GameModeService = require(script.Parent.Parent.services.GameModeService)
local ItemService = require(script.Parent.Parent.services.ItemService)
local SkillService = require(script.Parent.Parent.services.SkillService)
local TowerChallengeService = require(script.Parent.Parent.services.TowerChallengeService)
local RemoteMiddleware = require(script.Parent.RemoteMiddleware)

local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)
local EvolutionRegistry = require(script.Parent.Parent.data.EvolutionRegistry)
local StageOrder = require(script.Parent.Parent.data.StageOrder)

local RemoteHandlers = {}

-- Cached static data
local cachedPublicConfigs = nil

-- ─── Story Stage Sequence ───────────────────────────────────────────────────
-- Ordered story stage sequence. Defeating a stage unlocks the next entry.
-- MVP-020: hardcoded pending a dedicated stage/encounter registry.
-- Sequence itself lives in StageOrder (shared with GeneratorService's
-- stageClear unlock requirement, DD-029).
local STAGE_ORDER = StageOrder.getSequence()
local STAGE_ENCOUNTERS = {
	story_stage_1 = "enemy_001",
	story_stage_2 = "mossbit_001",
	story_stage_3 = "thornhorn_001",
}

-- Story battle victory reward amounts. Foundation values per docs/ECONOMY.md
-- reward_combat source; final balance values remain TBD in docs/BALANCE.md.
local STORY_VICTORY_BIOMASS = 50
local STORY_VICTORY_DNA = 50
local STORY_BATTLE_COOLDOWN_SECONDS = 1.0

local storyBattleLastRequestByUserId: { [number]: number } = {}

local function _tryReserveStoryBattle(player: Player)
	local userId = player.UserId
	local now = os.clock()
	local lastRequestAt = storyBattleLastRequestByUserId[userId]

	if lastRequestAt and now - lastRequestAt < STORY_BATTLE_COOLDOWN_SECONDS then
		return Result.fail("battle_rate_limited", "Story battle requests are cooling down.")
	end

	storyBattleLastRequestByUserId[userId] = now
	return Result.ok(now)
end

local function _buildPublicConfigsCache()
	local all = CreatureRegistry.getAllCreatures()
	local publicConfigs = {}

	for _, config in ipairs(all) do
		if config.isEnabled then
			local evolutionAvailable = nil
			for _, evol in ipairs(EvolutionRegistry.getAllEvolutions()) do
				if evol.fromCreatureId == config.creatureId and evol.isEnabled then
					evolutionAvailable = {
						evolutionId = evol.evolutionId,
						toCreatureId = evol.toCreatureId,
						requiredLevel = evol.requiredLevel,
						biomassCost = evol.biomassCost,
					}
					break
				end
			end

			publicConfigs[config.creatureId] = {
				creatureId = config.creatureId,
				displayName = config.displayName,
				collectionCategory = config.collectionCategory,
				sortOrder = config.sortOrder,
				isEnabled = config.isEnabled,
				evolutionLineId = config.evolutionLineId,
				evolutionAvailable = evolutionAvailable,
			}
		end
	end
	return publicConfigs
end

function RemoteHandlers.init()
	-- Pre-build caches
	cachedPublicConfigs = _buildPublicConfigsCache()

	Players.PlayerRemoving:Connect(function(player)
		storyBattleLastRequestByUserId[player.UserId] = nil
	end)

	-- ─── Remotes ─────────────────────────────────────────────────────────────────
	local GetPlayerProfileSnapshot = Network.getRemoteFunction("GetPlayerProfileSnapshot")
	local GetStarterChoices = Network.getRemoteFunction("GetStarterChoices")
	local RequestStarterSelection = Network.getRemoteFunction("RequestStarterSelection")
	local RequestWorldSnapshot = Network.getRemoteFunction("RequestWorldSnapshot")
	local RequestStoryBattle = Network.getRemoteFunction("RequestStoryBattle")
	local GetCollectionSnapshot = Network.getRemoteFunction("GetCollectionSnapshot")
	local GetCreatureInventory = Network.getRemoteFunction("GetCreatureInventory")
	local SetActiveCreature = Network.getRemoteFunction("SetActiveCreature")
	local GetCreatureConfigsPublic = Network.getRemoteFunction("GetCreatureConfigsPublic")
	local GetSkillSnapshot = Network.getRemoteFunction("GetSkillSnapshot")
	local RequestSkillUse = Network.getRemoteFunction("RequestSkillUse")
	local GetGeneratorSnapshot = Network.getRemoteFunction("GetGeneratorSnapshot")
	local RequestClaimGenerator = Network.getRemoteFunction("RequestClaimGenerator")
	local RequestUpgradeGenerator = Network.getRemoteFunction("RequestUpgradeGenerator")
	local RequestEvolution = Network.getRemoteFunction("RequestEvolution")
	local GetTowerChallengeSnapshot = Network.getRemoteFunction("GetTowerChallengeSnapshot")
	local RequestTowerChallengeStart = Network.getRemoteFunction("RequestTowerChallengeStart")
	local RequestTowerChallengeComplete = Network.getRemoteFunction("RequestTowerChallengeComplete")
	local GetInventorySnapshot = Network.getRemoteFunction("GetInventorySnapshot")
	local GetEquipmentSnapshot = Network.getRemoteFunction("GetEquipmentSnapshot")
	local RequestEquipItem = Network.getRemoteFunction("RequestEquipItem")
	local RequestUnequipItem = Network.getRemoteFunction("RequestUnequipItem")

	-- ─── Handlers ────────────────────────────────────────────────────────────────

	GetPlayerProfileSnapshot.OnServerInvoke = RemoteMiddleware.createHandler("GetPlayerProfileSnapshot", function(player)
		local save = SaveService.getPlayerSave(player)
		if not save then
			return Result.fail("not_loaded", "Player save data not loaded.")
		end

		local activeId = CreatureService.getActiveCreatureInstanceId(player)

		local snapshot = {
			creatureInstances = save.creatureInstances or {},
			collectionState = save.collectionState or { discoveredCreatureIds = {} },
			balances = save.economyState and save.economyState.balances or {},
			starterSelected = save.collectionState
				and save.collectionState.discoveredCreatureIds
				and save.collectionState.discoveredCreatureIds["starter_001"] == true,
			activeCreatureInstanceId = activeId,
		}
		return Result.ok(snapshot)
	end)

	GetStarterChoices.OnServerInvoke = RemoteMiddleware.createHandler("GetStarterChoices", function(player)
		return Result.ok({ "starter_001" })
	end)

	RequestStarterSelection.OnServerInvoke = RemoteMiddleware.createHandler("RequestStarterSelection", function(player, creatureId)
		local valRes = RemoteMiddleware.validateString(creatureId, 50)
		if not valRes.success then return valRes end

		if creatureId ~= "starter_001" then
			return Result.fail("unapproved_starter", "Only starter_001 is available in MVP.")
		end

		local grantRes = CreatureService.tryGrantCreature(player, creatureId)
		if grantRes.success then
			CreatureService.setActiveCreature(player, grantRes.value.instanceId)
			SaveService.markDirty(player)
			return Result.ok(grantRes.value)
		end
		return grantRes
	end)

	RequestWorldSnapshot.OnServerInvoke = RemoteMiddleware.createHandler("RequestWorldSnapshot", function(player)
		local save = SaveService.getPlayerSave(player)
		if not save then
			return Result.fail("not_loaded", "Player save data not loaded.")
		end

		-- worldProgression is guaranteed by MigrationManager, but stay defensive.
		save.worldProgression = save.worldProgression or { unlockedStages = { "story_stage_1" } }

		return Result.ok({
			worldId = "world_001",
			unlockedStages = save.worldProgression.unlockedStages
		})
	end)

	RequestStoryBattle.OnServerInvoke = RemoteMiddleware.createHandler("RequestStoryBattle", function(player, _clientCreatureId, stageId)
		local stageRes = RemoteMiddleware.validateString(stageId, 50)
		if not stageRes.success then return stageRes end

		local enemyConfigId = STAGE_ENCOUNTERS[stageId]
		if not enemyConfigId then
			return Result.fail("invalid_stage", "Unknown stageId.")
		end

		local save = SaveService.getPlayerSave(player)
		if not save then
			return Result.fail("not_loaded", "Player save data not loaded.")
		end

		-- worldProgression is guaranteed by MigrationManager, but stay defensive.
		save.worldProgression = save.worldProgression or { unlockedStages = { "story_stage_1" } }
		local unlockedStages = save.worldProgression.unlockedStages

		-- SERVER AUTHORITY: Access to a stage is validated against the player's
		-- persisted unlock list, never trusted from the client.
		local isUnlocked = false
		for _, unlockedId in ipairs(unlockedStages) do
			if unlockedId == stageId then
				isUnlocked = true
				break
			end
		end
		if not isUnlocked then
			return Result.fail("stage_locked", "This stage has not been unlocked yet.")
		end

		-- SERVER AUTHORITY: Enforce active creature, discard client-provided creature ID
		local activeCreatureId = CreatureService.getActiveCreatureInstanceId(player)
		if not activeCreatureId then
			return Result.fail("invalid_request", "Player has no active creature assigned.")
		end

		local cooldownRes = _tryReserveStoryBattle(player)
		if not cooldownRes.success then return cooldownRes end

		local battleRes = GameModeService.resolveModeBattle(player, {
			modeId = "story",
			playerCreatureId = activeCreatureId,
			enemyConfigId = enemyConfigId
		})

		if not battleRes.success then
			return battleRes
		end

		local xpGained = 0
		local xpRes = CreatureService.addCreatureXp(player, activeCreatureId, 1000)
		if xpRes.success then
			xpGained = 1000
		end

		local biomassGained = 0
		local dnaGained = 0
		local newlyUnlockedStage = nil

		if battleRes.value.isVictory then
			local bioRes = CurrencyService.tryGrant(player, "biomass", STORY_VICTORY_BIOMASS, "story")
			if bioRes.success then
				biomassGained = bioRes.value.granted
			end

			local dnaRes = CurrencyService.tryGrant(player, "dna", STORY_VICTORY_DNA, "reward_combat")
			if dnaRes.success then
				dnaGained = dnaRes.value.granted
			end

			-- Stage progression: unlock the next stage in the sequence, if any.
			local stageIndex = table.find(STAGE_ORDER, stageId)
			local nextStageId = stageIndex and STAGE_ORDER[stageIndex + 1]
			if nextStageId then
				local alreadyUnlocked = false
				for _, unlockedId in ipairs(unlockedStages) do
					if unlockedId == nextStageId then
						alreadyUnlocked = true
						break
					end
				end
				if not alreadyUnlocked then
					table.insert(unlockedStages, nextStageId)
					newlyUnlockedStage = nextStageId
				end
			end
		end

		SaveService.markDirty(player)

		return Result.ok({
			isVictory = battleRes.value.isVictory,
			timeline = battleRes.value.timeline,
			summary = battleRes.value.summary,
			rewards = {
				biomass = biomassGained,
				dna = dnaGained,
			},
			xpGained = xpGained,
			creatureUpdates = xpRes.success and xpRes.value or nil,
			newlyUnlockedStage = newlyUnlockedStage,
		})
	end)

	GetCollectionSnapshot.OnServerInvoke = RemoteMiddleware.createHandler("GetCollectionSnapshot", function(player)
		return CollectionService.getCollectionSnapshot(player)
	end)

	GetCreatureInventory.OnServerInvoke = RemoteMiddleware.createHandler("GetCreatureInventory", function(player)
		local save = SaveService.getPlayerSave(player)
		if not save then
			return Result.fail("not_loaded", "Player save data not loaded.")
		end

		local activeId = CreatureService.getActiveCreatureInstanceId(player)

		return Result.ok({
			instances = save.creatureInstances or {},
			activeCreatureInstanceId = activeId,
		})
	end)

	SetActiveCreature.OnServerInvoke = RemoteMiddleware.createHandler("SetActiveCreature", function(player, instanceId)
		local valRes = RemoteMiddleware.validateString(instanceId, 100)
		if not valRes.success then return valRes end
		
		return CreatureService.setActiveCreature(player, instanceId)
	end)

	GetCreatureConfigsPublic.OnServerInvoke = RemoteMiddleware.createHandler("GetCreatureConfigsPublic", function(player)
		-- O(1) Cache hit
		return Result.ok(cachedPublicConfigs)
	end)
	GetSkillSnapshot.OnServerInvoke = RemoteMiddleware.createHandler("GetSkillSnapshot", function(player, creatureInstanceId)
		return SkillService.getSnapshot(player, creatureInstanceId)
	end)

	RequestSkillUse.OnServerInvoke = RemoteMiddleware.createHandler("RequestSkillUse", function(player, creatureInstanceId, skillId, targetId)
		return SkillService.tryUseSkill(player, creatureInstanceId, skillId, targetId)
	end)

	GetGeneratorSnapshot.OnServerInvoke = RemoteMiddleware.createHandler("GetGeneratorSnapshot", function(player, generatorId)
		return GeneratorService.getSnapshotResult(player, generatorId)
	end)

	RequestClaimGenerator.OnServerInvoke = RemoteMiddleware.createHandler("RequestClaimGenerator", function(player, generatorId)
		return GeneratorService.tryClaim(player, generatorId)
	end)

	RequestUpgradeGenerator.OnServerInvoke = RemoteMiddleware.createHandler("RequestUpgradeGenerator", function(player, generatorId)
		return GeneratorService.tryUpgrade(player, generatorId)
	end)

	RequestEvolution.OnServerInvoke = RemoteMiddleware.createHandler("RequestEvolution", function(player, instanceId, evolutionId)
		return EvolutionService.tryEvolve(player, instanceId, evolutionId)
	end)

	GetTowerChallengeSnapshot.OnServerInvoke = RemoteMiddleware.createHandler("GetTowerChallengeSnapshot", function(player)
		return TowerChallengeService.getSnapshot(player)
	end)

	RequestTowerChallengeStart.OnServerInvoke = RemoteMiddleware.createHandler("RequestTowerChallengeStart", function(player, challengeId, floorId, playerInstanceId)
		return TowerChallengeService.startRun(player, challengeId, floorId, playerInstanceId)
	end)

	RequestTowerChallengeComplete.OnServerInvoke = RemoteMiddleware.createHandler("RequestTowerChallengeComplete", function(player, runToken)
		return TowerChallengeService.completeRun(player, runToken)
	end)

	GetInventorySnapshot.OnServerInvoke = RemoteMiddleware.createHandler("GetInventorySnapshot", function(player)
		return ItemService.getSnapshot(player)
	end)

	GetEquipmentSnapshot.OnServerInvoke = RemoteMiddleware.createHandler("GetEquipmentSnapshot", function(player)
		return EquipmentService.getSnapshot(player)
	end)

	RequestEquipItem.OnServerInvoke = RemoteMiddleware.createHandler("RequestEquipItem", function(player, itemId, slotId)
		return EquipmentService.tryEquip(player, itemId, slotId)
	end)

	RequestUnequipItem.OnServerInvoke = RemoteMiddleware.createHandler("RequestUnequipItem", function(player, slotId)
		return EquipmentService.tryUnequip(player, slotId)
	end)
end

return RemoteHandlers
