--[[
	GeneratorSchema
	Location: src/shared/data/GeneratorSchema.luau

	Validates generator config entries.
	Generators produce currency over time at a data-driven rate.

	Rules:
	- baseRate must be > 0.
	- capacity must be > 0.
	- upgradeCost must specify a positive integer amount and currencyType.
	- maxLevel must be a positive integer.
	- unlockRequirement must be server-evaluable.

	Part of MVP-019: Generator Expansion.
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local GeneratorSchema = {}

local VALID_UNLOCK_TYPES = {
	always = true,
	currencyBalance = true,
	generatorLevel = true,
	stageClear = true,
}

local function _positiveNumber(value: any): boolean
	return type(value) == "number" and value > 0
end

local function _positiveInteger(value: any): boolean
	return type(value) == "number" and value > 0 and value == math.floor(value)
end

local function _nonEmptyString(value: any): boolean
	return type(value) == "string" and value ~= ""
end

local function _validateUpgradeCost(cost: any)
	if type(cost) ~= "table" then
		return Result.fail("validation_failed", "upgradeCost must be a table.")
	end

	if not _nonEmptyString(cost.currencyType) then
		return Result.fail("validation_failed", "upgradeCost.currencyType must be a non-empty string.")
	end

	if not _positiveInteger(cost.amount) then
		return Result.fail("validation_failed", "upgradeCost.amount must be a positive integer.")
	end

	return Result.ok(cost)
end

local function _validateUnlockRequirement(requirement: any)
	if type(requirement) ~= "table" then
		return Result.fail("validation_failed", "unlockRequirement must be a table.")
	end

	if not _nonEmptyString(requirement.type) or not VALID_UNLOCK_TYPES[requirement.type] then
		return Result.fail("validation_failed", "unlockRequirement.type is invalid.")
	end

	if requirement.type == "currencyBalance" then
		if not _nonEmptyString(requirement.currencyType) then
			return Result.fail("validation_failed", "currencyBalance unlock requires currencyType.")
		end
		if not _positiveInteger(requirement.amount) then
			return Result.fail("validation_failed", "currencyBalance unlock requires a positive integer amount.")
		end
	elseif requirement.type == "generatorLevel" then
		if not _nonEmptyString(requirement.generatorId) then
			return Result.fail("validation_failed", "generatorLevel unlock requires generatorId.")
		end
		if not _positiveInteger(requirement.level) then
			return Result.fail("validation_failed", "generatorLevel unlock requires a positive integer level.")
		end
	elseif requirement.type == "stageClear" then
		if not _nonEmptyString(requirement.stageId) then
			return Result.fail("validation_failed", "stageClear unlock requires stageId.")
		end
	end

	return Result.ok(requirement)
end

--[[
	GeneratorSchema.validate(data) -> Result

	Validates a generator config table.
	Returns Result.ok(data) on success, Result.fail(code, message) on failure.
--]]
function GeneratorSchema.validate(data: any)
	if type(data) ~= "table" then
		return Result.fail("validation_failed", "Generator config must be a table.")
	end

	if type(data.id) ~= "string" or data.id == "" then
		return Result.fail("validation_failed", "Missing or invalid id (non-empty string).")
	end

	if type(data.schemaVersion) ~= "number" or data.schemaVersion ~= math.floor(data.schemaVersion) then
		return Result.fail("validation_failed", "Missing or invalid schemaVersion (integer).")
	end

	if type(data.generatorId) ~= "string" or data.generatorId == "" then
		return Result.fail("validation_failed", "Missing or invalid generatorId (non-empty string).")
	end

	if type(data.displayName) ~= "string" or data.displayName == "" then
		return Result.fail("validation_failed", "Missing or invalid displayName (non-empty string).")
	end

	if data.sortOrder ~= nil and (type(data.sortOrder) ~= "number" or data.sortOrder ~= math.floor(data.sortOrder)) then
		return Result.fail("validation_failed", "sortOrder must be an integer when present.")
	end

	if not _nonEmptyString(data.currencyType) and not _nonEmptyString(data.currencyId) then
		return Result.fail("validation_failed", "Missing or invalid currencyType (non-empty string).")
	end

	if data.currencyType == nil then
		data.currencyType = data.currencyId
	end

	if data.baseRate == nil then
		data.baseRate = data.ratePerSecond
	end
	if not _positiveNumber(data.baseRate) then
		return Result.fail("validation_failed", "baseRate must be a number > 0.")
	end

	if data.capacity == nil then
		data.capacity = data.maxAccumulated
	end
	if not _positiveInteger(data.capacity) then
		return Result.fail("validation_failed", "capacity must be a positive integer.")
	end

	local upgradeCostResult = _validateUpgradeCost(data.upgradeCost)
	if not upgradeCostResult.success then
		return upgradeCostResult
	end

	if not _positiveInteger(data.maxLevel) then
		return Result.fail("validation_failed", "maxLevel must be a positive integer.")
	end

	local unlockResult = _validateUnlockRequirement(data.unlockRequirement)
	if not unlockResult.success then
		return unlockResult
	end

	if type(data.isEnabled) ~= "boolean" then
		return Result.fail("validation_failed", "Missing or invalid isEnabled (boolean).")
	end

	return Result.ok(data)
end

return GeneratorSchema
