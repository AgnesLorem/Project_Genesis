local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
local EquipmentSlotSchema = require(script.Parent.EquipmentSlotSchema)

local EquipmentSchema = {}

local VALID_EQUIPMENT_TYPES = {
	weapon = true,
	armor = true,
	accessory = true,
}

local function _isNonEmptyString(value: any): boolean
	return type(value) == "string" and value ~= ""
end

function EquipmentSchema.validate(data: any)
	if type(data) ~= "table" then
		return Result.fail("validation_failed", "Equipment config must be a table.")
	end

	if not _isNonEmptyString(data.id) then
		return Result.fail("validation_failed", "Missing or invalid id.")
	end

	if not _isNonEmptyString(data.equipmentId) then
		return Result.fail("validation_failed", "Missing or invalid equipmentId.")
	end

	if data.id ~= data.equipmentId then
		return Result.fail("validation_failed", "id must match equipmentId.")
	end

	if type(data.schemaVersion) ~= "number" or data.schemaVersion ~= math.floor(data.schemaVersion) then
		return Result.fail("validation_failed", "Missing or invalid schemaVersion.")
	end

	if not _isNonEmptyString(data.itemId) then
		return Result.fail("validation_failed", "Missing or invalid itemId.")
	end

	if not _isNonEmptyString(data.displayName) then
		return Result.fail("validation_failed", "Missing or invalid displayName.")
	end

	local slotResult = EquipmentSlotSchema.validateSlotId(data.slotId)
	if not slotResult.success then
		return slotResult
	end

	if type(data.equipmentType) ~= "string" or not VALID_EQUIPMENT_TYPES[data.equipmentType] then
		return Result.fail("validation_failed", "Missing or invalid equipmentType.")
	end

	if data.equipmentType ~= data.slotId then
		return Result.fail("validation_failed", "equipmentType must match slotId.")
	end

	if type(data.statBonuses) ~= "table" then
		return Result.fail("validation_failed", "Missing or invalid statBonuses.")
	end

	for _, statName in ipairs({ "hp", "atk", "def", "spd" }) do
		local value = data.statBonuses[statName]
		if type(value) ~= "number" or value < 0 then
			return Result.fail("validation_failed", "Invalid stat bonus: " .. statName)
		end
	end

	if type(data.isEnabled) ~= "boolean" then
		return Result.fail("validation_failed", "Missing or invalid isEnabled.")
	end

	return Result.ok(data)
end

return EquipmentSchema
