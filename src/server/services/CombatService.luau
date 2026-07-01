--[[
	CombatService
	Location: src/server/services/CombatService.luau

	Server-authoritative combat resolution.
	Validates requests, builds isolated BattleSession, and executes simulation.
	
	Rules:
	- No client trust for damage or results.
	- Returns battle result only until reward mapping is approved.
	- Updates persistence (Future MVP).
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
local GameModeContract = require(game:GetService("ReplicatedStorage").Genesis.Shared.network.GameModeContract)
local SaveService = require(script.Parent.SaveService)
local EquipmentService = require(script.Parent.EquipmentService)
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)
local BossRegistry = require(script.Parent.Parent.data.BossRegistry)
local BalanceRegistry = require(script.Parent.Parent.data.BalanceRegistry)
local SkillRegistry = require(script.Parent.Parent.data.SkillRegistry)
local BattleSession = require(script.Parent.Parent.combat.BattleSession)

local CombatService = {}

local MVP_BOSS_TEAM_SIZE = 3
local ModeIds = GameModeContract.ModeIds

local function _getArrayLength(value: any): number?
	if type(value) ~= "table" then
		return nil
	end

	local length = 0
	for key, _ in pairs(value) do
		if type(key) ~= "number" or key < 1 or key ~= math.floor(key) then
			return nil
		end
		if key > length then
			length = key
		end
	end

	for index = 1, length do
		if value[index] == nil then
			return nil
		end
	end

	return length
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

local function _findOwnedInstanceById(instances: any, instanceId: string): any
	if type(instances) ~= "table" then
		return nil
	end

	local direct = instances[instanceId]
	if type(direct) == "table" then
		return direct
	end

	for _, inst in pairs(instances) do
		if type(inst) == "table" and inst.instanceId == instanceId then
			return inst
		end
	end

	return nil
end

local function _buildPlayerTeam(player: Player, playerInstanceIds: any, expectedTeamSize: number)
	local length = _getArrayLength(playerInstanceIds)
	if length == nil then
		return Result.fail("invalid_team", "playerInstanceIds must be an array.")
	end

	if length ~= expectedTeamSize then
		return Result.fail("invalid_team_size", string.format(
			"Expected exactly %d player creature instances.",
			expectedTeamSize
		))
	end

	local save = SaveService.getPlayerSave(player)
	local instances = save.creatureInstances or {}
	local seen: { [string]: boolean } = {}
	local team = {}

	for index = 1, length do
		local instanceId = playerInstanceIds[index]
		if type(instanceId) ~= "string" or instanceId == "" then
			return Result.fail("invalid_team", string.format("Invalid playerInstanceIds[%d].", index))
		end
		if seen[instanceId] then
			return Result.fail("duplicate_creature_instance", "Duplicate player creature instance in team.")
		end
		seen[instanceId] = true

		local inst = _findOwnedInstanceById(instances, instanceId)
		if not inst then
			return Result.fail("unowned_creature", "Player does not own one or more requested creatures.")
		end

		local creatureId = inst.creatureId
		local config = CreatureRegistry.getCreature(creatureId)
		if not config or not config.isEnabled then
			return Result.fail("invalid_creature", "Player creature config not found or disabled.")
		end

		local level = inst.level or 1
		local eqResult = EquipmentService.calculateStatBonuses(player)
		local bonuses = eqResult.success and eqResult.value or { hp = 0, atk = 0, def = 0, spd = 0 }
		table.insert(team, _buildUnit(inst.instanceId or instanceId, creatureId, config, level, bonuses))
	end

	return Result.ok(team)
end

local function _buildEnemyTeam(enemyRefs: any, expectedTeamSize: number, bossId: string, battleMode: string)
	local length = _getArrayLength(enemyRefs)
	if length == nil then
		return Result.fail("invalid_enemy_team", "enemyRefs must be an array.")
	end

	if length ~= expectedTeamSize then
		return Result.fail("invalid_enemy_team_size", string.format(
			"Expected exactly %d enemy refs.",
			expectedTeamSize
		))
	end

	local team = {}
	for index = 1, length do
		local enemyCreatureId = enemyRefs[index]
		if type(enemyCreatureId) ~= "string" or enemyCreatureId == "" then
			return Result.fail("invalid_enemy", string.format("Invalid enemyRefs[%d].", index))
		end

		local config = CreatureRegistry.getCreature(enemyCreatureId)
		if not config or not config.isEnabled then
			return Result.fail("invalid_enemy", "Enemy creature config not found or disabled.")
		end

		table.insert(team, _buildUnit(
			string.format("enemy_%s_%s_%d", battleMode, bossId, index),
			enemyCreatureId,
			config,
			1,
			nil
		))
	end

	return Result.ok(team)
end

local function _runBattle(playerTeam: { any }, enemyTeam: { any })
	local combatConfig = BalanceRegistry.getCombatConfig()
	if not combatConfig then
		return Result.fail("missing_config", "Combat balance config not found.")
	end

	local session = BattleSession.new(playerTeam, enemyTeam, combatConfig, SkillRegistry)
	local result = session:simulate()
	session = nil

	return Result.ok(result)
end

local function _resolveConfiguredTeamBattle(player: Player, playerInstanceIds: any, bossId: string, expectedBattleMode: string)
	if type(bossId) ~= "string" or bossId == "" then
		return Result.fail("invalid_boss", "Missing or invalid bossId.")
	end

	local bossConfig = BossRegistry.getBoss(bossId)
	if not bossConfig then
		return Result.fail("invalid_boss", "Boss config not found or disabled.")
	end

	if bossConfig.battleMode ~= expectedBattleMode then
		return Result.fail("invalid_battle_mode", string.format(
			"Boss '%s' is configured for '%s', not '%s'.",
			bossId,
			tostring(bossConfig.battleMode),
			expectedBattleMode
		))
	end

	if bossConfig.teamSize ~= MVP_BOSS_TEAM_SIZE then
		return Result.fail("invalid_team_size", "Boss/challenge battles must be 3v3 for MVP.")
	end

	local playerTeamResult = _buildPlayerTeam(player, playerInstanceIds, bossConfig.teamSize)
	if not playerTeamResult.success then
		return playerTeamResult
	end

	local enemyTeamResult = _buildEnemyTeam(bossConfig.enemyRefs, bossConfig.teamSize, bossId, expectedBattleMode)
	if not enemyTeamResult.success then
		return enemyTeamResult
	end

	-- Boss phase IDs are intentionally ignored by MVP-008 combat.
	return _runBattle(playerTeamResult.value, enemyTeamResult.value)
end

function CombatService.resolveStoryBattle(player: Player, playerCreatureId: string, enemyConfigId: string)
	-- Validate Player Creature
	local save = SaveService.getPlayerSave(player)
	local pInstances = save.creatureInstances or {}
	local pInst = nil
	for _, inst in pairs(pInstances) do
		if inst.instanceId == playerCreatureId or inst.creatureId == playerCreatureId then
			pInst = inst
			break
		end
	end
	
	if not pInst then
		return Result.fail("unowned_creature", "Player does not own this creature.")
	end
	
	local pConfig = CreatureRegistry.getCreature(playerCreatureId)
	if not pConfig then
		return Result.fail("invalid_creature", "Player creature config not found.")
	end
	
	-- Validate Enemy Creature
	local eConfig = CreatureRegistry.getCreature(enemyConfigId)
	if not eConfig then
		return Result.fail("invalid_enemy", "Enemy creature config not found.")
	end
	
	-- Prepare isolated session stats
	local level = pInst.level or 1
	local eqResult = EquipmentService.calculateStatBonuses(player)
	local bonuses = eqResult.success and eqResult.value or { hp = 0, atk = 0, def = 0, spd = 0 }

	local playerTeam = {
		_buildUnit(pInst.instanceId, pInst.creatureId, pConfig, level, bonuses)
	}

	local enemyTeam = {
		_buildUnit("enemy_" .. enemyConfigId, enemyConfigId, eConfig, 1, nil)
	}

	-- Build & Execute Isolated Session
	-- No rewards are applied here; current combat returns the battle result only.
	-- For MVP-006, post-battle full heal is implied because persistent state is never mutated
	-- and always starts at max HP. No injury state is saved.
	return _runBattle(playerTeam, enemyTeam)
end

function CombatService.resolveBossBattle(player: Player, playerInstanceIds: { string }, bossId: string)
	return _resolveConfiguredTeamBattle(player, playerInstanceIds, bossId, ModeIds.BOSS)
end

function CombatService.resolveChallengeBattle(player: Player, playerInstanceIds: { string }, bossId: string)
	return _resolveConfiguredTeamBattle(player, playerInstanceIds, bossId, ModeIds.CHALLENGE)
end

return CombatService
