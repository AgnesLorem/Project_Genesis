--[[
	CombatBalanceSchema
	Location: src/shared/data/CombatBalanceSchema.luau

	Validates combat balance config entries.
	Rules:
	- Constants must be numbers
	- Safeguards must be valid
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local CombatBalanceSchema = {}

function CombatBalanceSchema.validate(data: any)
	if type(data) ~= "table" then
		return Result.fail("validation_failed", "Combat config must be a table.")
	end

	if type(data.id) ~= "string" or data.id == "" then
		return Result.fail("validation_failed", "Missing or invalid id (non-empty string).")
	end

	if type(data.schemaVersion) ~= "number" or data.schemaVersion ~= math.floor(data.schemaVersion) then
		return Result.fail("validation_failed", "Missing or invalid schemaVersion (integer).")
	end

	if type(data.actionGaugeThreshold) ~= "number" or data.actionGaugeThreshold <= 0 then
		return Result.fail("validation_failed", "Missing or invalid actionGaugeThreshold (positive number).")
	end

	if type(data.gaugeFillCoefficient) ~= "number" or data.gaugeFillCoefficient <= 0 then
		return Result.fail("validation_failed", "Missing or invalid gaugeFillCoefficient (positive number).")
	end

	if type(data.defReductionConstant) ~= "number" or data.defReductionConstant <= 0 then
		return Result.fail("validation_failed", "Missing or invalid defReductionConstant (positive number).")
	end

	if
		type(data.maxTurnSafeguard) ~= "number"
		or data.maxTurnSafeguard <= 0
		or data.maxTurnSafeguard ~= math.floor(data.maxTurnSafeguard)
	then
		return Result.fail("validation_failed", "Missing or invalid maxTurnSafeguard (positive integer).")
	end

	return Result.ok(data)
end

return CombatBalanceSchema
