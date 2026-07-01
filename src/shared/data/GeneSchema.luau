--[[
	GeneSchema
	Location: src/shared/data/GeneSchema.luau

	Validates gene config records against DATA_SCHEMA.md.
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local GeneSchema = {}

function GeneSchema.validate(data: any)
	if type(data) ~= "table" then
		return Result.fail("validation_failed", "Gene config must be a table.")
	end

	if type(data.geneId) ~= "string" or data.geneId == "" then
		return Result.fail("validation_failed", "Missing or invalid geneId.")
	end

	if type(data.schemaVersion) ~= "number" or data.schemaVersion ~= math.floor(data.schemaVersion) then
		return Result.fail("validation_failed", "Missing or invalid schemaVersion.")
	end

	if type(data.displayName) ~= "string" or data.displayName == "" then
		return Result.fail("validation_failed", "Missing or invalid displayName.")
	end

	if type(data.isEnabled) ~= "boolean" then
		return Result.fail("validation_failed", "Missing or invalid isEnabled.")
	end

	return Result.ok(data)
end

return GeneSchema
