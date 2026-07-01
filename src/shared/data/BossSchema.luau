--[[
	BossSchema
	Location: src/shared/data/BossSchema.luau

	Validates boss and challenge encounter config entries against DATA_SCHEMA.md.
	Phase IDs and reward refs are validated as data only; runtime phase behavior
	and reward distribution are not implemented by this schema.
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
local GameModeContract = require(game:GetService("ReplicatedStorage").Genesis.Shared.network.GameModeContract)

local BossSchema = {}

local MVP_TEAM_SIZE = 3
local ModeIds = GameModeContract.ModeIds

local VALID_BATTLE_MODES = {
	[ModeIds.BOSS] = true,
	[ModeIds.CHALLENGE] = true,
}

local function _isInteger(value: any): boolean
	return type(value) == "number" and value == math.floor(value)
end

local function _isNonEmptyString(value: any): boolean
	return type(value) == "string" and value ~= ""
end

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

local function _validateStringArray(value: any, fieldName: string)
	local length = _getArrayLength(value)
	if length == nil then
		return Result.fail("validation_failed", string.format("Missing or invalid %s (array).", fieldName))
	end

	for index = 1, length do
		if not _isNonEmptyString(value[index]) then
			return Result.fail(
				"validation_failed",
				string.format("Invalid %s[%d] (non-empty string expected).", fieldName, index)
			)
		end
	end

	return Result.ok(value)
end

function BossSchema.validate(data: any)
	if type(data) ~= "table" then
		return Result.fail("validation_failed", "Boss config must be a table.")
	end

	if not _isNonEmptyString(data.id) then
		return Result.fail("validation_failed", "Missing or invalid id (non-empty string).")
	end

	if not _isNonEmptyString(data.bossId) then
		return Result.fail("validation_failed", "Missing or invalid bossId (non-empty string).")
	end

	if data.id ~= data.bossId then
		return Result.fail("validation_failed", "id must match bossId.")
	end

	if not _isInteger(data.schemaVersion) then
		return Result.fail("validation_failed", "Missing or invalid schemaVersion (integer).")
	end

	if not _isNonEmptyString(data.displayName) then
		return Result.fail("validation_failed", "Missing or invalid displayName (non-empty string).")
	end

	if type(data.battleMode) ~= "string" or not VALID_BATTLE_MODES[data.battleMode] then
		return Result.fail(
			"validation_failed",
			string.format("Invalid battleMode. Expected '%s' or '%s'.", ModeIds.BOSS, ModeIds.CHALLENGE)
		)
	end

	if not _isInteger(data.teamSize) or data.teamSize ~= MVP_TEAM_SIZE then
		return Result.fail("validation_failed", "teamSize must be 3 for boss/challenge MVP battles.")
	end

	if type(data.recommendedPower) ~= "number" or data.recommendedPower < 0 then
		return Result.fail("validation_failed", "Missing or invalid recommendedPower (non-negative number).")
	end

	local phaseResult = _validateStringArray(data.phaseIds, "phaseIds")
	if not phaseResult.success then
		return phaseResult
	end

	local enemyResult = _validateStringArray(data.enemyRefs, "enemyRefs")
	if not enemyResult.success then
		return enemyResult
	end

	if #data.enemyRefs ~= data.teamSize then
		return Result.fail("validation_failed", "enemyRefs length must match teamSize.")
	end

	local rewardResult = _validateStringArray(data.rewardRefs, "rewardRefs")
	if not rewardResult.success then
		return rewardResult
	end

	if not _isNonEmptyString(data.retryPolicyRef) then
		return Result.fail("validation_failed", "Missing or invalid retryPolicyRef (non-empty string).")
	end

	if type(data.isEnabled) ~= "boolean" then
		return Result.fail("validation_failed", "Missing or invalid isEnabled (boolean).")
	end

	return Result.ok(data)
end

return BossSchema
