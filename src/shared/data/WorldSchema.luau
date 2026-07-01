--[[
	WorldSchema
	Location: src/shared/data/WorldSchema.luau

	Validates world config entries against DATA_SCHEMA.md.
	World data is static lookup/display data only; it does not own runtime
	player progression state.
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local WorldSchema = {}

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

function WorldSchema.validate(data: any)
	if type(data) ~= "table" then
		return Result.fail("validation_failed", "World config must be a table.")
	end

	if not _isNonEmptyString(data.id) then
		return Result.fail("validation_failed", "Missing or invalid id (non-empty string).")
	end

	if not _isNonEmptyString(data.worldId) then
		return Result.fail("validation_failed", "Missing or invalid worldId (non-empty string).")
	end

	if data.id ~= data.worldId then
		return Result.fail("validation_failed", "id must match worldId.")
	end

	if not _isInteger(data.schemaVersion) then
		return Result.fail("validation_failed", "Missing or invalid schemaVersion (integer).")
	end

	if not _isNonEmptyString(data.displayName) then
		return Result.fail("validation_failed", "Missing or invalid displayName (non-empty string).")
	end

	if type(data.description) ~= "string" then
		return Result.fail("validation_failed", "Missing or invalid description (string).")
	end

	local unlockResult = _validateStringArray(data.unlockRequirementRefs, "unlockRequirementRefs")
	if not unlockResult.success then
		return unlockResult
	end

	local encounterResult = _validateStringArray(data.encounterRefs, "encounterRefs")
	if not encounterResult.success then
		return encounterResult
	end

	local bossResult = _validateStringArray(data.bossRefs, "bossRefs")
	if not bossResult.success then
		return bossResult
	end

	if type(data.recommendedPowerRange) ~= "table" then
		return Result.fail("validation_failed", "Missing or invalid recommendedPowerRange (table).")
	end

	local minPower = data.recommendedPowerRange.min
	local maxPower = data.recommendedPowerRange.max
	if type(minPower) ~= "number" or minPower < 0 then
		return Result.fail("validation_failed", "Missing or invalid recommendedPowerRange.min (non-negative number).")
	end
	if type(maxPower) ~= "number" or maxPower < 0 then
		return Result.fail("validation_failed", "Missing or invalid recommendedPowerRange.max (non-negative number).")
	end
	if minPower > maxPower then
		return Result.fail("validation_failed", "recommendedPowerRange.min must be <= recommendedPowerRange.max.")
	end

	if not _isInteger(data.sortOrder) then
		return Result.fail("validation_failed", "Missing or invalid sortOrder (integer).")
	end

	if type(data.isEnabled) ~= "boolean" then
		return Result.fail("validation_failed", "Missing or invalid isEnabled (boolean).")
	end

	return Result.ok(data)
end

return WorldSchema
