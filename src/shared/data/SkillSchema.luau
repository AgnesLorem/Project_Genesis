local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local SkillSchema = {}

local VALID_RARITIES = {
	Common = true,
	Rare = true,
	Epic = true,
	Legend = true,
}

local VALID_SKILL_TYPES = {
	active = true,
	passive = true,
}

local VALID_TARGET_RULES = {
	first_living_enemy = true,
	self = true,
}

local function _isNonEmptyString(value: any): boolean
	return type(value) == "string" and value ~= ""
end

local function _isNonNegativeInteger(value: any): boolean
	return type(value) == "number" and value >= 0 and value == math.floor(value)
end

function SkillSchema.validate(data: any)
	if type(data) ~= "table" then
		return Result.fail("validation_failed", "Skill config must be a table.")
	end

	if not _isNonEmptyString(data.id) then
		return Result.fail("validation_failed", "Missing or invalid id.")
	end

	if type(data.schemaVersion) ~= "number" or data.schemaVersion ~= math.floor(data.schemaVersion) then
		return Result.fail("validation_failed", "Missing or invalid schemaVersion.")
	end

	if not _isNonEmptyString(data.skillId) or data.id ~= data.skillId then
		return Result.fail("validation_failed", "Missing or invalid skillId.")
	end

	if not _isNonEmptyString(data.displayName) then
		return Result.fail("validation_failed", "Missing or invalid displayName.")
	end

	if not _isNonEmptyString(data.description) then
		return Result.fail("validation_failed", "Missing or invalid description.")
	end

	if type(data.isEnabled) ~= "boolean" then
		return Result.fail("validation_failed", "Missing or invalid isEnabled.")
	end

	if not VALID_SKILL_TYPES[data.skillType] then
		return Result.fail("validation_failed", "Missing or invalid skillType.")
	end

	if type(data.rarity) ~= "string" or not VALID_RARITIES[data.rarity] then
		return Result.fail("validation_failed", "Missing or invalid rarity.")
	end

	if not _isNonEmptyString(data.elementType) then
		return Result.fail("validation_failed", "Missing or invalid elementType.")
	end

	if not _isNonNegativeInteger(data.cooldown) then
		return Result.fail("validation_failed", "Missing or invalid cooldown.")
	end

	if type(data.targetRule) ~= "string" or not VALID_TARGET_RULES[data.targetRule] then
		return Result.fail("validation_failed", "Missing or invalid targetRule.")
	end

	if type(data.damageMultiplier) ~= "number" or data.damageMultiplier < 0 then
		return Result.fail("validation_failed", "Missing or invalid damageMultiplier.")
	end

	if type(data.statusEffectRefs) ~= "table" then
		return Result.fail("validation_failed", "Missing or invalid statusEffectRefs.")
	end

	if not _isNonEmptyString(data.iconPlaceholder) then
		return Result.fail("validation_failed", "Missing or invalid iconPlaceholder.")
	end

	return Result.ok(data)
end

function SkillSchema.isActive(skill: any): boolean
	return type(skill) == "table" and skill.skillType == "active"
end

function SkillSchema.isPassive(skill: any): boolean
	return type(skill) == "table" and skill.skillType == "passive"
end

return SkillSchema
