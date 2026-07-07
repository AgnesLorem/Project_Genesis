local HttpService = game:GetService("HttpService")

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)
local SaveService = require(script.Parent.SaveService)
local EquipmentService = require(script.Parent.EquipmentService)
local TowerChallengeRegistry = require(script.Parent.Parent.data.TowerChallengeRegistry)
local BalanceRegistry = require(script.Parent.Parent.data.BalanceRegistry)
local SkillRegistry = require(script.Parent.Parent.data.SkillRegistry)
local BattleSession = require(script.Parent.Parent.combat.BattleSession)

local TowerChallengeService = {}

local activeRuns: { [number]: any } = {}

local function _playerKey(player: Player): number
	return player.UserId
end

local function _copyProgress(progress: any): any
	return {
		bestFloor = progress.bestFloor or 0,
		totalAttempts = progress.totalAttempts or 0,
		totalClears = progress.totalClears or 0,
		lastOutcome = progress.lastOutcome,
		lastCompletedAt = progress.lastCompletedAt,
	}
end

local function _ensureChallengeState(save: any): any
	if type(save.challengeState) ~= "table" then
		save.challengeState = {
			towerChallenges = {},
		}
	end

	if type(save.challengeState.towerChallenges) ~= "table" then
		save.challengeState.towerChallenges = {}
	end

	return save.challengeState
end

local function _getProgress(save: any, challengeId: string): any
	local challengeState = _ensureChallengeState(save)
	local progress = challengeState.towerChallenges[challengeId]
	if type(progress) ~= "table" then
		progress = {
			bestFloor = 0,
			totalAttempts = 0,
			totalClears = 0,
			lastOutcome = nil,
			lastCompletedAt = nil,
		}
		challengeState.towerChallenges[challengeId] = progress
	end

	if type(progress.bestFloor) ~= "number" then
		progress.bestFloor = 0
	end
	if type(progress.totalAttempts) ~= "number" then
		progress.totalAttempts = 0
	end
	if type(progress.totalClears) ~= "number" then
		progress.totalClears = 0
	end

	return progress
end

local function _findOwnedInstance(save: any, playerInstanceId: string): any
	local instances = save.creatureInstances
	if type(instances) ~= "table" then
		return nil
	end

	local direct = instances[playerInstanceId]
	if type(direct) == "table" then
		return direct
	end

	for _, inst in pairs(instances) do
		if type(inst) == "table" and inst.instanceId == playerInstanceId then
			return inst
		end
	end

	return nil
end

local function _buildUnit(instanceId: string, creatureId: string, config: any, level: number, bonuses: any): any
	local lvl = level or 1
	local scale = 1 + (lvl - 1) * 0.1
	local spdScale = 1 + (lvl - 1) * 0.01

	local hp = math.floor(config.baseStats.hp * scale) + (bonuses and bonuses.hp or 0)
	local atk = math.floor(config.baseStats.atk * scale) + (bonuses and bonuses.atk or 0)
	local def = math.floor(config.baseStats.def * scale) + (bonuses and bonuses.def or 0)
	local spd = math.floor(config.baseStats.spd * spdScale) + (bonuses and bonuses.spd or 0)

	return {
		instanceId = instanceId,
		creatureId = creatureId,
		stats = {
			hp = hp,
			atk = atk,
			def = def,
			spd = spd,
		},
		skillIds = config.skillIds,
	}
end

local function _resolveBattle(playerInstanceId: string, playerCreatureId: string, enemyInstanceId: string, enemyCreatureId: string, level: number, bonuses: any)
	local playerConfig = CreatureRegistry.getCreature(playerCreatureId)
	if not playerConfig or not playerConfig.isEnabled then
		return Result.fail("invalid_creature", "Player creature config not found or disabled.")
	end

	local enemyConfig = CreatureRegistry.getCreature(enemyCreatureId)
	if not enemyConfig or not enemyConfig.isEnabled then
		return Result.fail("invalid_enemy", "Enemy creature config not found or disabled.")
	end

	local combatConfig = BalanceRegistry.getCombatConfig()
	if not combatConfig then
		return Result.fail("missing_config", "Combat balance config not found.")
	end

	local session = BattleSession.new(
		{ _buildUnit(playerInstanceId, playerCreatureId, playerConfig, level, bonuses) },
		{ _buildUnit(enemyInstanceId, enemyCreatureId, enemyConfig, 1, nil) },
		combatConfig,
		SkillRegistry
	)
	local battleValue = session:simulate()
	session = nil
	
	if battleValue.isStalled then
		return Result.fail("simulation_stalled", "The tower battle simulation timed out or stalled.")
	end

	return Result.ok(battleValue)
end

function TowerChallengeService.getSnapshot(player: Player)
	local save = SaveService.getPlayerSave(player)
	if not save then
		return Result.fail("not_loaded", "Player save data not loaded.")
	end

	local challengeSnapshots = TowerChallengeRegistry.getAllChallengeSnapshots()
	local progressByChallengeId = {}
	for _, challenge in ipairs(challengeSnapshots) do
		progressByChallengeId[challenge.challengeId] = _copyProgress(_getProgress(save, challenge.challengeId))
	end

	return Result.ok({
		challenges = challengeSnapshots,
		progressByChallengeId = progressByChallengeId,
		activeRun = activeRuns[_playerKey(player)] ~= nil,
	})
end

function TowerChallengeService.startRun(player: Player, challengeId: any, floorId: any, playerInstanceId: any)
	if type(challengeId) ~= "string" or challengeId == "" then
		return Result.fail("invalid_challenge_id", "Tower run requires a non-empty challengeId.")
	end
	if type(floorId) ~= "string" or floorId == "" then
		return Result.fail("invalid_floor_id", "Tower run requires a non-empty floorId.")
	end
	if type(playerInstanceId) ~= "string" or playerInstanceId == "" then
		return Result.fail("invalid_creature_instance", "Tower run requires a non-empty playerInstanceId.")
	end

	local playerKey = _playerKey(player)
	if activeRuns[playerKey] then
		return Result.fail("active_tower_run_exists", "A tower challenge run is already active.")
	end

	local challenge = TowerChallengeRegistry.getChallenge(challengeId)
	if not challenge or not challenge.isEnabled then
		return Result.fail("invalid_challenge", "Tower challenge config not found or disabled.")
	end

	local floor = TowerChallengeRegistry.getFloor(challengeId, floorId)
	if not floor or not floor.isEnabled then
		return Result.fail("invalid_floor", "Tower challenge floor config not found or disabled.")
	end

	local save = SaveService.getPlayerSave(player)
	if not save then
		return Result.fail("not_loaded", "Player save data not loaded.")
	end

	local ownedInstance = _findOwnedInstance(save, playerInstanceId)
	if not ownedInstance then
		return Result.fail("unowned_creature", "Player does not own the requested creature instance.")
	end

	local playerCreatureId = ownedInstance.creatureId
	local level = ownedInstance.level or 1

	local bonuses = nil
	local bonusResult = EquipmentService.calculateStatBonuses(player)
	if bonusResult.success then
		bonuses = bonusResult.value
	end

	local enemyInstanceId = string.format("enemy_tower_%s_%s", challengeId, floorId)
	local battleResult = _resolveBattle(playerInstanceId, playerCreatureId, enemyInstanceId, floor.enemyCreatureId, level, bonuses)
	if not battleResult.success then
		return battleResult
	end

	local runToken = HttpService:GenerateGUID(false)
	activeRuns[playerKey] = {
		runToken = runToken,
		challengeId = challengeId,
		floorId = floorId,
		floorNumber = floor.floorNumber,
		playerInstanceId = playerInstanceId,
		playerCreatureId = playerCreatureId,
		enemyCreatureId = floor.enemyCreatureId,
		enemyInstanceId = enemyInstanceId,
		battleValue = battleResult.value,
		startedAt = os.time(),
	}

	print(string.format(
		"[TowerChallengeService] Started run challenge=%s floor=%s player=%d token=%s.",
		challengeId,
		floorId,
		player.UserId,
		runToken
	))

	return Result.ok({
		runToken = runToken,
		challengeId = challengeId,
		floorId = floorId,
		floorNumber = floor.floorNumber,
		playerInstanceId = playerInstanceId,
		playerCreatureId = playerCreatureId,
		enemyCreatureId = floor.enemyCreatureId,
		timeline = battleResult.value.timeline,
		playerUnitIds = { playerInstanceId },
		enemyUnitIds = { enemyInstanceId },
	})
end

function TowerChallengeService.completeRun(player: Player, runToken: any)
	if type(runToken) ~= "string" or runToken == "" then
		return Result.fail("invalid_tower_token", "Tower completion requires a token.")
	end

	local playerKey = _playerKey(player)
	local activeRun = activeRuns[playerKey]
	if not activeRun then
		return Result.fail("no_active_tower_run", "No active tower challenge run is pending completion.")
	end
	if activeRun.runToken ~= runToken then
		return Result.fail("invalid_tower_token", "Tower completion token does not match the active run.")
	end

	activeRuns[playerKey] = nil

	local save = SaveService.getPlayerSave(player)
	if not save then
		return Result.fail("not_loaded", "Player save data not loaded.")
	end

	local progress = _getProgress(save, activeRun.challengeId)
	progress.totalAttempts += 1

	local outcome = activeRun.battleValue.isVictory and "Victory" or "Defeat"
	if activeRun.battleValue.isVictory then
		progress.totalClears += 1
		progress.bestFloor = math.max(progress.bestFloor, activeRun.floorNumber)
	end

	progress.lastOutcome = outcome
	progress.lastCompletedAt = os.time()

	local saveResult = SaveService.savePlayer(player)
	if not saveResult.success then
		return saveResult
	end

	print(string.format(
		"[TowerChallengeService] Completed run challenge=%s floor=%s player=%d outcome=%s attempts=%d clears=%d.",
		activeRun.challengeId,
		activeRun.floorId,
		player.UserId,
		outcome,
		progress.totalAttempts,
		progress.totalClears
	))

	return Result.ok({
		outcome = outcome,
		challengeId = activeRun.challengeId,
		floorId = activeRun.floorId,
		floorNumber = activeRun.floorNumber,
		progress = _copyProgress(progress),
	})
end

function TowerChallengeService.abandonActiveRun(player: Player)
	local playerKey = _playerKey(player)
	if activeRuns[playerKey] then
		print(string.format("[TowerChallengeService] Abandoned active run for player=%d.", player.UserId))
	end
	activeRuns[playerKey] = nil
	return Result.ok(nil)
end

return TowerChallengeService
