local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local EquipmentScreen = require(script.Parent.Parent.views.EquipmentScreen)
local ItemTooltip = require(script.Parent.Parent.views.ItemTooltip)
local StatePatterns = require(script.Parent.Parent.views.StatePatterns)

local EquipmentController = {}

local lastInventorySnapshot = nil
local lastEquipmentSnapshot = nil

local function _findEquipmentForItem(itemId: string): any
	for _, slot in ipairs(lastEquipmentSnapshot and lastEquipmentSnapshot.slots or {}) do
		if slot.itemId == itemId then
			return slot.equipment
		end
	end
	return nil
end

function EquipmentController.show()
	UIController.init()
	UIController.mountModal(StatePatterns.Loading(nil))

	local inventoryResult = NetworkController.getInventorySnapshot()
	local equipmentResult = NetworkController.getEquipmentSnapshot()
	UIController.clearModal()

	if not inventoryResult.success then
		UIController.mountModal(
			StatePatterns.Error(
				nil,
				"Inventory Load Failed: " .. tostring(inventoryResult.message or inventoryResult.code)
			)
		)
		return inventoryResult
	end
	if not equipmentResult.success then
		UIController.mountModal(
			StatePatterns.Error(
				nil,
				"Equipment Load Failed: " .. tostring(equipmentResult.message or equipmentResult.code)
			)
		)
		return equipmentResult
	end

	lastInventorySnapshot = inventoryResult.value
	lastEquipmentSnapshot = equipmentResult.value

	local screen = EquipmentScreen.create(equipmentResult.value, inventoryResult.value, function(itemId, slotId)
		local equipResult = NetworkController.requestEquipItem(itemId, slotId)
		if equipResult.success then
			EquipmentController.show()
		else
			UIController.mountModal(
				StatePatterns.Error(nil, "Equip Failed: " .. tostring(equipResult.message or equipResult.code))
			)
		end
	end, function(slotId)
		local unequipResult = NetworkController.requestUnequipItem(slotId)
		if unequipResult.success then
			EquipmentController.show()
		else
			UIController.mountModal(
				StatePatterns.Error(nil, "Unequip Failed: " .. tostring(unequipResult.message or unequipResult.code))
			)
		end
	end, function()
		EquipmentController.show()
	end, function(item)
		EquipmentController.showTooltip(item)
	end)
	UIController.mountScreen(screen)
	return equipmentResult
end

function EquipmentController.showTooltip(item: any)
	UIController.mountModal(ItemTooltip.create(item, _findEquipmentForItem(item.itemId) or item.equipment, function()
		UIController.clearModal()
	end))
	return { success = true }
end

return EquipmentController
