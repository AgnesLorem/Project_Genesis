--[[
	EconomySchema
	Location: src/shared/data/EconomySchema.luau

	Validates currency config entries against DATA_SCHEMA.md Section 15.
	Currency amounts are integer-only.
	Premium currency is not approved for MVP.

	Rules:
	- Validate exactly the fields defined in docs/DATA_SCHEMA.md.
	- Do not introduce additional required fields.
	- Do not infer optional fields.
	- currencyType must be "soft" (premium not approved for MVP).

	Part of MVP-005: Bio Generator and Economy Foundation.
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local EconomySchema = {}

local VALID_CURRENCY_TYPES = {
	soft = true,
}

local VALID_AUDIT_CATEGORIES = {
	progression_reward = true,
	economy_sink = true,
}

--[[
	EconomySchema.validate(data) -> Result

	Validates a currency config table.
	Returns Result.ok(data) on success, Result.fail(code, message) on failure.
--]]
function EconomySchema.validate(data: any)
	if type(data) ~= "table" then
		return Result.fail("validation_failed", "Economy config must be a table.")
	end

	if type(data.id) ~= "string" or data.id == "" then
		return Result.fail("validation_failed", "Missing or invalid id (non-empty string).")
	end

	if type(data.schemaVersion) ~= "number" or data.schemaVersion ~= math.floor(data.schemaVersion) then
		return Result.fail("validation_failed", "Missing or invalid schemaVersion (integer).")
	end

	if type(data.currencyId) ~= "string" or data.currencyId == "" then
		return Result.fail("validation_failed", "Missing or invalid currencyId (non-empty string).")
	end

	if type(data.displayName) ~= "string" or data.displayName == "" then
		return Result.fail("validation_failed", "Missing or invalid displayName (non-empty string).")
	end

	if type(data.currencyType) ~= "string" or not VALID_CURRENCY_TYPES[data.currencyType] then
		return Result.fail("validation_failed", "Invalid currencyType. Must be 'soft'. Premium not approved for MVP.")
	end

	if type(data.sourceRefs) ~= "table" then
		return Result.fail("validation_failed", "Missing or invalid sourceRefs (array).")
	end

	if type(data.sinkRefs) ~= "table" then
		return Result.fail("validation_failed", "Missing or invalid sinkRefs (array).")
	end

	if type(data.cap) ~= "number" or data.cap ~= math.floor(data.cap) or data.cap < 0 then
		return Result.fail("validation_failed", "Missing or invalid cap (non-negative integer).")
	end

	if type(data.auditCategory) ~= "string" or not VALID_AUDIT_CATEGORIES[data.auditCategory] then
		return Result.fail("validation_failed", "Missing or invalid auditCategory.")
	end

	return Result.ok(data)
end

return EconomySchema
