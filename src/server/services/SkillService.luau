local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)

local SaveService = require(script.Parent.SaveService)
local SkillRegistry = require(script.Parent.Parent.data.SkillRegistry)

local SkillService = {}

local SKILL_STATE_SCHEMA_VERSION = 1
local SKILL_STATE_MIGRATION_VERSION = 1

local function _isNonEmptyString(value: any): boolean
	return type(value) == "string" and value ~= ""
end

local function _now(): number
	return DateTime.now().UnixTimestampMillis / 1000
end

local function _copyArray(values: any): { any }
	local output = {}
	if type(values) == "table" then
		for _, value in ipairs(values) do
			table.insert(output, value)
		end
	end
	return output
end

local function _ensureSkillState(save: any): (any, boolean)
	local migrated = false
	if type(save.skillState) ~= "table" then
		save.skillState = {
			schemaVersion = SKILL_STATE_SCHEMA_VERSION,
			migrationVersion = SKILL_STATE_MIGRATION_VERSION,
			cooldowns = {},
		}
		migrated = true
	end

	local state = save.skillState
	if type(state.schemaVersion) ~= "number" then
		state.schemaVersion = SKILL_STATE_SCHEMA_VERSION
		migrated = true
	end
	if type(state.migrationVersion) ~= "number" then
		state.migrationVersion = SKILL_STATE_MIGRATION_VERSION
		migrated = true
	end
	if type(state.cooldowns) ~= "table" then
		state.cooldowns = {}
		migrated = true
	end

	for creatureInstanceId, skillCooldowns in pairs(state.cooldowns) do
		if type(creatureInstanceId) ~= "string" or type(skillCooldowns) ~= "table" then
			state.cooldowns[creatureInstanceId] = nil
			migrated = true
		else
			for skillId, readyAt in pairs(skillCooldowns) do
				if type(skillId) ~= "string" or type(readyAt) ~= "number" or readyAt <= _now() then
					skillCooldowns[skillId] = nil
					migrated = true
				end
			end
			if next(skillCooldowns) == nil then
				state.cooldowns[creatureInstanceId] = nil
			end
		end
	end

	return state, migrated
end

local function _findOwnedInstance(save: any, creatureInstanceId: any)
	if not _isNonEmptyString(creatureInstanceId) then
		return Result.fail("invalid_creature_instance", "Creature instance id must be a non-empty string.")
	end

	local instances = save.creatureInstances
	if type(instances) ~= "table" then
		return Result.fail("unowned_creature", "Player has no creature instances.")
	end

	local direct = instances[creatureInstanceId]
	if type(direct) == "table" then
		return Result.ok(direct)
	end

	for _, inst in pairs(instances) do
		if type(inst) == "table" and inst.instanceId == creatureInstanceId then
			return Result.ok(inst)
		end
	end

	return Result.fail("unowned_creature", "Player does not own this creature instance.")
end

local function _creatureOwnsSkill(creatureConfig: any, skillId: string): boolean
	for _, ownedSkillId in ipairs(creatureConfig and creatureConfig.skillIds or {}) do
		if ownedSkillId == skillId then
			return true
		end
	end
	return false
end

local function _getCooldownRemaining(state: any, creatureInstanceId: string, skillId: string): number
	local readyAt = state.cooldowns
			and state.cooldowns[creatureInstanceId]
			and state.cooldowns[creatureInstanceId][skillId]
		or 0
	return math.max(0, math.ceil(readyAt - _now()))
end

local function _buildSkillSnapshot(skill: any, cooldownRemaining: number)
	return {
		skillId = skill.skillId,
		displayName = skill.displayName,
		description = skill.description,
		skillType = skill.skillType,
		rarity = skill.rarity,
		elementType = skill.elementType,
		cooldown = skill.cooldown,
		cooldownRemaining = cooldownRemaining,
		targetRule = skill.targetRule,
		damageMultiplier = skill.damageMultiplier,
		statusEffectRefs = _copyArray(skill.statusEffectRefs),
		iconPlaceholder = skill.iconPlaceholder,
	}
end

local function _validateTarget(skill: any, creatureInstanceId: string, targetId: any)
	if not _isNonEmptyString(targetId) then
		return Result.fail("invalid_target", "Target id must be a non-empty string.")
	end

	if skill.targetRule == "first_living_enemy" then
		if string.sub(targetId, 1, 6) ~= "enemy_" then
			return Result.fail("invalid_target", "Skill target must be an enemy target.")
		end
		return Result.ok(targetId)
	end

	if skill.targetRule == "self" then
		if targetId ~= creatureInstanceId then
			return Result.fail("invalid_target", "Skill target must be the acting creature.")
		end
		return Result.ok(targetId)
	end

	return Result.fail("invalid_target", "Unsupported target rule.")
end

function SkillService.ensureSkillState(player: Player)
	local save = SaveService.getPlayerSave(player)
	if not save then
		return Result.fail("not_loaded", "Player save data not loaded.")
	end

	local state, migrated = _ensureSkillState(save)
	if migrated then
		local saveResult = SaveService.savePlayer(player)
		if not saveResult.success then
			return saveResult
		end
	end

	return Result.ok(state)
end

function SkillService.getSnapshot(player: Player, requestedCreatureInstanceId: any?)
	local save = SaveService.getPlayerSave(player)
	if not save then
		return Result.fail("not_loaded", "Player save data not loaded.")
	end
	if requestedCreatureInstanceId ~= nil and not _isNonEmptyString(requestedCreatureInstanceId) then
		return Result.fail("invalid_creature_instance", "Creature instance id must be nil or a non-empty string.")
	end

	local stateResult = SkillService.ensureSkillState(player)
	if not stateResult.success then
		return stateResult
	end

	local creatures = {}
	for _, inst in pairs(save.creatureInstances or {}) do
		if type(inst) == "table" then
			local instanceId = inst.instanceId
			if
				_isNonEmptyString(instanceId)
				and (requestedCreatureInstanceId == nil or requestedCreatureInstanceId == instanceId)
			then
				local creatureConfig = CreatureRegistry.getCreature(inst.creatureId)
				local skills = {}
				for _, skillId in ipairs(creatureConfig and creatureConfig.skillIds or {}) do
					local skill = SkillRegistry.getSkill(skillId)
					if skill and skill.isEnabled then
						table.insert(
							skills,
							_buildSkillSnapshot(skill, _getCooldownRemaining(stateResult.value, instanceId, skillId))
						)
					end
				end
				table.insert(creatures, {
					instanceId = instanceId,
					creatureId = inst.creatureId,
					skills = skills,
				})
			end
		end
	end

	if requestedCreatureInstanceId ~= nil and #creatures == 0 then
		return Result.fail("unowned_creature", "Player does not own this creature instance.")
	end

	table.sort(creatures, function(a, b)
		return a.instanceId < b.instanceId
	end)

	return Result.ok({
		schemaVersion = stateResult.value.schemaVersion,
		migrationVersion = stateResult.value.migrationVersion,
		creatures = creatures,
	})
end

function SkillService.tryUseSkill(player: Player, creatureInstanceId: any, skillId: any, targetId: any)
	if not _isNonEmptyString(skillId) then
		return Result.fail("invalid_skill", "Skill id must be a non-empty string.")
	end

	local save = SaveService.getPlayerSave(player)
	if not save then
		return Result.fail("not_loaded", "Player save data not loaded.")
	end

	local stateResult = SkillService.ensureSkillState(player)
	if not stateResult.success then
		return stateResult
	end

	local instanceResult = _findOwnedInstance(save, creatureInstanceId)
	if not instanceResult.success then
		return instanceResult
	end

	local skill = SkillRegistry.getSkill(skillId)
	if not skill then
		return Result.fail("invalid_skill", "Skill config not found.")
	end
	if not skill.isEnabled then
		return Result.fail("disabled_skill", "Disabled skills cannot be used.")
	end
	if skill.skillType ~= "active" then
		return Result.fail("passive_skill", "Passive skills cannot be actively used.")
	end

	local creatureConfig = CreatureRegistry.getCreature(instanceResult.value.creatureId)
	if not creatureConfig or not creatureConfig.isEnabled then
		return Result.fail("invalid_creature", "Creature config not found or disabled.")
	end
	if not _creatureOwnsSkill(creatureConfig, skillId) then
		return Result.fail("unowned_skill", "Creature does not own this skill.")
	end

	local targetResult = _validateTarget(skill, instanceResult.value.instanceId, targetId)
	if not targetResult.success then
		return targetResult
	end

	local remaining = _getCooldownRemaining(stateResult.value, instanceResult.value.instanceId, skillId)
	if remaining > 0 then
		return Result.fail("skill_on_cooldown", "Skill is on cooldown.")
	end

	if skill.cooldown > 0 then
		stateResult.value.cooldowns[instanceResult.value.instanceId] = stateResult.value.cooldowns[instanceResult.value.instanceId]
			or {}
		stateResult.value.cooldowns[instanceResult.value.instanceId][skillId] = _now() + skill.cooldown
	end

	-- Keep the authoritative cooldown in the live server session; autosave/unload persists it.
	local dirtyResult = SaveService.markDirty(player)
	if not dirtyResult.success then
		return dirtyResult
	end

	return Result.ok({
		creatureInstanceId = instanceResult.value.instanceId,
		creatureId = instanceResult.value.creatureId,
		skill = _buildSkillSnapshot(
			skill,
			_getCooldownRemaining(stateResult.value, instanceResult.value.instanceId, skillId)
		),
		targetId = targetId,
	})
end

function SkillService.runUnitTests()
	print("[SkillService] Running unit tests...")

	local testSave = {
		skillState = {
			schemaVersion = 1,
			migrationVersion = 1,
			cooldowns = {
				creature_001 = {
					[123] = _now() + 10,
					skill_002 = "invalid_readyAt",
					skill_003 = _now() - 5,
					skill_004 = _now() + 100,
				},
			},
		},
	}

	local state, migrated = _ensureSkillState(testSave)
	assert(migrated == true, "Expected migration to occur.")

	local cd = state.cooldowns.creature_001
	assert(cd ~= nil, "Cooldowns table for creature_001 should exist.")
	assert(cd[123] == nil, "Invalid skill ID key (123) should be cleaned up.")
	assert(cd.skill_002 == nil, "Invalid readyAt type (string) should be cleaned up.")
	assert(cd.skill_003 == nil, "Expired cooldown should be cleaned up.")
	assert(cd.skill_004 ~= nil, "Valid future cooldown should remain untouched.")
	assert(math.abs(cd.skill_004 - (_now() + 100)) < 2, "Valid future cooldown value modified.")

	print("[SkillService] Unit tests PASS.")
	return true
end

if game:GetService("RunService"):IsStudio() then
	SkillService.runUnitTests()
end

return SkillService
