--[[
	PrestigeSchema
	Location: src/shared/data/PrestigeSchema.luau

	Validates prestige config records against DATA_SCHEMA.md.
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local PrestigeSchema = {}

function PrestigeSchema.validate(data: any)
	if type(data) ~= "table" then
		return Result.fail("validation_failed", "Prestige config must be a table.")
	end

	if type(data.prestigeId) ~= "string" or data.prestigeId == "" then
		return Result.fail("validation_failed", "Missing or invalid prestigeId.")
	end

	if type(data.schemaVersion) ~= "number" or data.schemaVersion ~= math.floor(data.schemaVersion) then
		return Result.fail("validation_failed", "Missing or invalid schemaVersion.")
	end

	if
		type(data.prestigeLevel) ~= "number"
		or data.prestigeLevel < 0
		or data.prestigeLevel ~= math.floor(data.prestigeLevel)
	then
		return Result.fail("validation_failed", "Missing or invalid prestigeLevel.")
	end

	if type(data.isEnabled) ~= "boolean" then
		return Result.fail("validation_failed", "Missing or invalid isEnabled.")
	end

	return Result.ok(data)
end

return PrestigeSchema
