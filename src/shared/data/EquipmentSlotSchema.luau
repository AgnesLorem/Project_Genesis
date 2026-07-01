local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local EquipmentSlotSchema = {}

local SLOT_ORDER = { "weapon", "armor", "accessory" }
local VALID_SLOTS = {
	weapon = true,
	armor = true,
	accessory = true,
}

function EquipmentSlotSchema.validateSlotId(slotId: any)
	if type(slotId) ~= "string" or slotId == "" then
		return Result.fail("invalid_slot", "Equipment slot must be a non-empty string.")
	end

	if not VALID_SLOTS[slotId] then
		return Result.fail("invalid_slot", "Unknown equipment slot.")
	end

	return Result.ok(slotId)
end

function EquipmentSlotSchema.getSlotIds(): { string }
	return table.clone(SLOT_ORDER)
end

function EquipmentSlotSchema.createEmptySlotState(): any
	local equipped = {}
	for _, slotId in ipairs(SLOT_ORDER) do
		equipped[slotId] = nil
	end
	return equipped
end

return EquipmentSlotSchema
