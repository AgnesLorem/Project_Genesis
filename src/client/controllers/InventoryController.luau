local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local InventoryScreen = require(script.Parent.Parent.views.InventoryScreen)
local ItemTooltip = require(script.Parent.Parent.views.ItemTooltip)
local StatePatterns = require(script.Parent.Parent.views.StatePatterns)

local InventoryController = {}

local lastSnapshot = nil

local function _findItem(snapshot: any, itemId: string): any
	for _, item in ipairs(snapshot and snapshot.items or {}) do
		if item.itemId == itemId then
			return item
		end
	end
	return nil
end

function InventoryController.show(onClose: () -> ())
	UIController.init()
	UIController.mountModal(StatePatterns.Loading(nil))

	local snapshotResult = NetworkController.getInventorySnapshot()
	UIController.clearModal()
	if not snapshotResult.success then
		UIController.mountModal(StatePatterns.Error(nil, "Inventory Load Failed: " .. tostring(snapshotResult.message or snapshotResult.code)))
		return snapshotResult
	end

	lastSnapshot = snapshotResult.value
	local screen = InventoryScreen.create(snapshotResult.value, function()
		InventoryController.show(onClose)
	end, function(item)
		InventoryController.showTooltip(item.itemId)
	end, function()
		UIController.unmountScreen("InventoryScreen")
		onClose()
	end)
	UIController.mountScreen(screen)
	return snapshotResult
end

function InventoryController.showTooltip(itemId: string)
	if not lastSnapshot then
		local snapshotResult = NetworkController.getInventorySnapshot()
		if not snapshotResult.success then
			return snapshotResult
		end
		lastSnapshot = snapshotResult.value
	end

	local item = _findItem(lastSnapshot, itemId)
	if not item then
		local fail = { success = false, code = "item_not_found", message = "Item not found in inventory snapshot." }
		UIController.mountModal(StatePatterns.Error(nil, fail.message))
		return fail
	end

	UIController.mountModal(ItemTooltip.create(item, item.equipment, function()
		UIController.clearModal()
	end))
	return { success = true, value = item }
end

function InventoryController.showTooltipForFirstItem()
	if not lastSnapshot then
		local showResult = InventoryController.show()
		if not showResult.success then
			return showResult
		end
	end

	local firstItem = lastSnapshot.items and lastSnapshot.items[1]
	if not firstItem then
		return { success = false, code = "empty_inventory", message = "Inventory is empty." }
	end
	return InventoryController.showTooltip(firstItem.itemId)
end

return InventoryController
