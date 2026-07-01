--[[
	EvolutionSchema
	Location: src/shared/data/EvolutionSchema.luau

	Validates evolution config records against DATA_SCHEMA.md.
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local EvolutionSchema = {}

function EvolutionSchema.validate(data: any)
	if type(data) ~= "table" then
		return Result.fail("validation_failed", "Evolution config must be a table.")
	end

	if type(data.evolutionId) ~= "string" or data.evolutionId == "" then
		return Result.fail("validation_failed", "Missing or invalid evolutionId.")
	end

	if type(data.schemaVersion) ~= "number" or data.schemaVersion ~= math.floor(data.schemaVersion) then
		return Result.fail("validation_failed", "Missing or invalid schemaVersion.")
	end

	if type(data.evolutionLineId) ~= "string" or data.evolutionLineId == "" then
		return Result.fail("validation_failed", "Missing or invalid evolutionLineId.")
	end

	if type(data.fromCreatureId) ~= "string" or data.fromCreatureId == "" then
		return Result.fail("validation_failed", "Missing or invalid fromCreatureId.")
	end

	if type(data.toCreatureId) ~= "string" or data.toCreatureId == "" then
		return Result.fail("validation_failed", "Missing or invalid toCreatureId.")
	end

	if type(data.requiredLevel) ~= "number" or data.requiredLevel <= 0 or data.requiredLevel ~= math.floor(data.requiredLevel) then
		return Result.fail("validation_failed", "Missing or invalid requiredLevel (positive integer).")
	end

	if type(data.biomassCost) ~= "number" or data.biomassCost < 0 or data.biomassCost ~= math.floor(data.biomassCost) then
		return Result.fail("validation_failed", "Missing or invalid biomassCost (non-negative integer).")
	end

	if type(data.isEnabled) ~= "boolean" then
		return Result.fail("validation_failed", "Missing or invalid isEnabled.")
	end

	return Result.ok(data)
end

return EvolutionSchema
