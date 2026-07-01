local HttpService = game:GetService("HttpService")

local Network = require(game:GetService("ReplicatedStorage").Genesis.Shared.remotes.Network)
local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local SaveService = require(script.Parent.Parent.services.SaveService)
local CreatureService = require(script.Parent.Parent.services.CreatureService)
local CollectionService = require(script.Parent.Parent.services.CollectionService)
local CurrencyService = require(script.Parent.Parent.services.CurrencyService)
local GeneratorService = require(script.Parent.Parent.services.GeneratorService)
local EvolutionService = require(script.Parent.Parent.services.EvolutionService)
local GameModeService = require(script.Parent.Parent.services.GameModeService)
local TowerChallengeService = require(script.Parent.Parent.services.TowerChallengeService)
local ItemService = require(script.Parent.Parent.services.ItemService)
local EquipmentService = require(script.Parent.Parent.services.EquipmentService)
local SkillService = require(script.Parent.Parent.services.SkillService)
local BalanceRegistry = require(script.Parent.Parent.data.BalanceRegistry)
local EvolutionRegistry = require(script.Parent.Parent.data.EvolutionRegistry)
local WorldRegistry = require(script.Parent.Parent.data.WorldRegistry)

local RemoteHandlers = {}

local DEFAULT_WORLD_ID = "world_001"

-- Existing MVP content mapping moved from client hardcode to server authority.
local STAGE_ENCOUNTERS = {
	story_stage_1 = {
		worldId = DEFAULT_WORLD_ID,
		enemyConfigId = "enemy_001",
	},
}

local activeBattles: { [number]: any } = {}

local function _getPlayerKey(player: Player): number
	return player.UserId
end

local function _getWorldSnapshot()
	local world = WorldRegistry.getWorld(DEFAULT_WORLD_ID)
	local unlockedStages = {}

	if world and type(world.encounterRefs) == "table" then
		for _, stageId in ipairs(world.encounterRefs) do
			if STAGE_ENCOUNTERS[stageId] then
				table.insert(unlockedStages, stageId)
			end
		end
	end

	if #unlockedStages == 0 then
		table.insert(unlockedStages, "story_stage_1")
	end

	return {
		worldId = world and world.worldId or DEFAULT_WORLD_ID,
		unlockedStages = unlockedStages,
	}
end

local function _isStageUnlocked(stageId: string): boolean
	for _, unlockedStageId in ipairs(_getWorldSnapshot().unlockedStages) do
		if unlockedStageId == stageId then
			return true
		end
	end
	return false
end

local function _validateStage(stageId: any)
	if type(stageId) ~= "string" or stageId == "" then
		return Result.fail("invalid_stage", "Story battle requires a non-empty stageId.")
	end

	local encounter = STAGE_ENCOUNTERS[stageId]
	if not encounter then
		return Result.fail("invalid_stage", "Stage config not found.")
	end

	if not _isStageUnlocked(stageId) then
		return Result.fail("stage_locked", "Stage is not unlocked.")
	end

	return Result.ok(encounter)
end

local function _findOwnedInstanceId(save: any, creatureId: string): string?
	for instanceId, inst in pairs(save.creatureInstances or {}) do
		if type(inst) == "table" and inst.creatureId == creatureId then
			return instanceId
		end
	end
	return nil
end

local function _buildEvolutionOptions(save: any)
	local evolutionOptions = {}
	for _, inst in pairs(save.creatureInstances or {}) do
		for _, evol in ipairs(EvolutionRegistry.getAllEvolutions()) do
			if evol.fromCreatureId == inst.creatureId and evol.isEnabled then
				evolutionOptions[inst.instanceId] = {
					evolutionId = evol.evolutionId,
					toCreatureId = evol.toCreatureId,
					requiredLevel = evol.requiredLevel,
					biomassCost = evol.biomassCost,
				}
			end
		end
	end
	return evolutionOptions
end

local function _grantBattleRewards(player: Player, battleSession: any)
	local xpGained = 0
	local biomassGained = 0
	local xpRes = nil

	if battleSession.battleValue.isVictory then
		local combatConfig = BalanceRegistry.getCombatConfig()
		local storyRewards = combatConfig and combatConfig.storyBattleRewards or { biomass = 600, xp = 1000 }
		local grantXp = storyRewards.xp or 1000
		local grantBiomass = storyRewards.biomass or 600

		local addRes = CreatureService.addCreatureXp(player, battleSession.playerInstanceId, grantXp)
		if addRes.success then
			xpGained = grantXp
			xpRes = addRes.value
		end

		local bioRes = CurrencyService.tryGrant(player, "biomass", grantBiomass, "story")
		if bioRes.success then
			biomassGained = bioRes.value.granted
		end

		SaveService.savePlayer(player)
	end

	return {
		outcome = battleSession.battleValue.isVictory and "Victory" or "Defeat",
		rewards = { biomass = biomassGained },
		xpGained = xpGained,
		creatureUpdates = xpRes,
	}
end

function RemoteHandlers.init()
	local GetPlayerProfileSnapshot = Network.getRemoteFunction("GetPlayerProfileSnapshot")
	local GetStarterChoices = Network.getRemoteFunction("GetStarterChoices")
	local RequestStarterSelection = Network.getRemoteFunction("RequestStarterSelection")
	local RequestWorldSnapshot = Network.getRemoteFunction("RequestWorldSnapshot")
	local RequestStoryBattle = Network.getRemoteFunction("RequestStoryBattle")
	local RequestBattleCompletion = Network.getRemoteFunction("RequestBattleCompletion")
	local GetGeneratorSnapshot = Network.getRemoteFunction("GetGeneratorSnapshot")
	local RequestClaimGenerator = Network.getRemoteFunction("RequestClaimGenerator")
	local RequestUpgradeGenerator = Network.getRemoteFunction("RequestUpgradeGenerator")
	local RequestGeneratorClaim = Network.getRemoteFunction("RequestGeneratorClaim")
	local RequestEvolution = Network.getRemoteFunction("RequestEvolution")
	local GetTowerChallengeSnapshot = Network.getRemoteFunction("GetTowerChallengeSnapshot")
	local RequestTowerChallengeStart = Network.getRemoteFunction("RequestTowerChallengeStart")
	local RequestTowerChallengeComplete = Network.getRemoteFunction("RequestTowerChallengeComplete")
	local GetInventorySnapshot = Network.getRemoteFunction("GetInventorySnapshot")
	local GetEquipmentSnapshot = Network.getRemoteFunction("GetEquipmentSnapshot")
	local RequestEquipItem = Network.getRemoteFunction("RequestEquipItem")
	local RequestUnequipItem = Network.getRemoteFunction("RequestUnequipItem")
	local GetSkillSnapshot = Network.getRemoteFunction("GetSkillSnapshot")
	local RequestSkillUse = Network.getRemoteFunction("RequestSkillUse")

	GetPlayerProfileSnapshot.OnServerInvoke = function(player)
		local save = SaveService.getPlayerSave(player)
		if not save then
			return Result.fail("not_loaded", "Player save data not loaded.")
		end

		-- Loading/reconnect returns the player to hub; pending battles are abandoned
		-- without rewards because completion tokens are the only reward path.
		activeBattles[_getPlayerKey(player)] = nil
		TowerChallengeService.abandonActiveRun(player)

		local collectionSnap = CollectionService.getCollectionSnapshot(player).value
		local snapshot = {
			creatureInstances = save.creatureInstances or {},
			collectionState = save.collectionState or { discoveredCreatureIds = {} },
			collectionProgress = collectionSnap,
			balances = save.economyState and save.economyState.balances or {},
			starterSelected = save.collectionState
				and save.collectionState.discoveredCreatureIds
				and save.collectionState.discoveredCreatureIds["starter_001"] == true,
			evolutionOptions = _buildEvolutionOptions(save),
			generators = GeneratorService.getAllSnapshots(player),
			world = _getWorldSnapshot(),
		}
		return Result.ok(snapshot)
	end

	GetStarterChoices.OnServerInvoke = function(_player)
		return Result.ok({ "starter_001" })
	end

	RequestStarterSelection.OnServerInvoke = function(player, creatureId)
		if creatureId ~= "starter_001" then
			return Result.fail("unapproved_starter", "Only starter_001 is available in MVP.")
		end

		local grantRes = CreatureService.tryGrantCreature(player, creatureId)
		if grantRes.success then
			SaveService.savePlayer(player)
			return Result.ok(grantRes.value)
		end
		return grantRes
	end

	RequestWorldSnapshot.OnServerInvoke = function(_player)
		return Result.ok(_getWorldSnapshot())
	end

	RequestStoryBattle.OnServerInvoke = function(player, playerCreatureId, stageId)
		local stageResult = _validateStage(stageId)
		if not stageResult.success then
			return stageResult
		end

		local playerKey = _getPlayerKey(player)
		if activeBattles[playerKey] then
			return Result.fail("battle_in_progress", "A battle is already pending completion.")
		end

		local save = SaveService.getPlayerSave(player)
		if not save then
			return Result.fail("not_loaded", "Player save data not loaded.")
		end

		local playerInstanceId = _findOwnedInstanceId(save, playerCreatureId)
		if not playerInstanceId then
			return Result.fail("unowned_creature", "Player does not own this creature.")
		end

		local enemyConfigId = stageResult.value.enemyConfigId
		local battleRes = GameModeService.resolveModeBattle(player, {
			modeId = "story",
			playerCreatureId = playerCreatureId,
			enemyConfigId = enemyConfigId,
		})

		if not battleRes.success then
			return battleRes
		end

		local battleToken = HttpService:GenerateGUID(false)
		local enemyInstanceId = "enemy_" .. enemyConfigId
		activeBattles[playerKey] = {
			token = battleToken,
			stageId = stageId,
			playerCreatureId = playerCreatureId,
			playerInstanceId = playerInstanceId,
			enemyConfigId = enemyConfigId,
			enemyInstanceId = enemyInstanceId,
			battleValue = battleRes.value,
			rewardClaimed = false,
		}

		return Result.ok({
			battleToken = battleToken,
			stageId = stageId,
			enemyConfigId = enemyConfigId,
			timeline = battleRes.value.timeline,
			playerUnitIds = { playerInstanceId },
			enemyUnitIds = { enemyInstanceId },
		})
	end

	RequestBattleCompletion.OnServerInvoke = function(player, battleToken)
		if type(battleToken) ~= "string" or battleToken == "" then
			return Result.fail("invalid_battle_token", "Battle completion requires a token.")
		end

		local playerKey = _getPlayerKey(player)
		local battleSession = activeBattles[playerKey]
		if not battleSession then
			return Result.fail("no_active_battle", "No active battle is pending completion.")
		end

		if battleSession.token ~= battleToken then
			return Result.fail("invalid_battle_token", "Battle token does not match the active battle.")
		end

		if battleSession.rewardClaimed then
			return Result.fail("reward_already_claimed", "Battle reward has already been claimed.")
		end

		battleSession.rewardClaimed = true
		activeBattles[playerKey] = nil

		return Result.ok(_grantBattleRewards(player, battleSession))
	end

	RequestGeneratorClaim.OnServerInvoke = function(player, generatorId)
		local res = GeneratorService.tryClaim(player, generatorId)
		if res.success then
			SaveService.savePlayer(player)
		end
		return res
	end

	GetGeneratorSnapshot.OnServerInvoke = function(player, generatorId)
		return GeneratorService.getSnapshotResult(player, generatorId)
	end

	RequestClaimGenerator.OnServerInvoke = function(player, generatorId)
		local res = GeneratorService.tryClaim(player, generatorId)
		if res.success then
			SaveService.savePlayer(player)
		end
		return res
	end

	RequestUpgradeGenerator.OnServerInvoke = function(player, generatorId)
		local res = GeneratorService.tryUpgrade(player, generatorId)
		if res.success then
			SaveService.savePlayer(player)
		end
		return res
	end

	RequestEvolution.OnServerInvoke = function(player, instanceId, evolutionId)
		local res = EvolutionService.tryEvolve(player, instanceId, evolutionId)
		if res.success then
			SaveService.savePlayer(player)
		end
		return res
	end

	GetTowerChallengeSnapshot.OnServerInvoke = function(player)
		return TowerChallengeService.getSnapshot(player)
	end

	RequestTowerChallengeStart.OnServerInvoke = function(player, challengeId, floorId, playerInstanceId)
		return TowerChallengeService.startRun(player, challengeId, floorId, playerInstanceId)
	end

	RequestTowerChallengeComplete.OnServerInvoke = function(player, runToken)
		return TowerChallengeService.completeRun(player, runToken)
	end

	GetInventorySnapshot.OnServerInvoke = function(player)
		return ItemService.getSnapshot(player)
	end

	GetEquipmentSnapshot.OnServerInvoke = function(player)
		return EquipmentService.getSnapshot(player)
	end

	RequestEquipItem.OnServerInvoke = function(player, itemId, slotId)
		return EquipmentService.tryEquip(player, itemId, slotId)
	end

	RequestUnequipItem.OnServerInvoke = function(player, slotId)
		return EquipmentService.tryUnequip(player, slotId)
	end

	GetSkillSnapshot.OnServerInvoke = function(player, creatureInstanceId)
		return SkillService.getSnapshot(player, creatureInstanceId)
	end

	RequestSkillUse.OnServerInvoke = function(player, creatureInstanceId, skillId, targetId)
		return SkillService.tryUseSkill(player, creatureInstanceId, skillId, targetId)
	end
end

return RemoteHandlers
