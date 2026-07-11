local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local SaveService = require(script.Parent.SaveService)
local ItemRegistry = require(script.Parent.Parent.data.ItemRegistry)
local EquipmentRegistry = require(script.Parent.Parent.data.EquipmentRegistry)

local ItemService = {}

local INVENTORY_SCHEMA_VERSION = 1
local INVENTORY_MIGRATION_VERSION = 3

local DEFAULT_ITEM_GRANTS = {
	item_training_blade = 1,
	item_scout_vest = 1,
	item_health_cell = 3,
}

local function _isPositiveInteger(value: any): boolean
	return type(value) == "number" and value > 0 and value == math.floor(value)
end

local function _copyTags(tags: any): { any }
	local output = {}
	if type(tags) == "table" then
		for _, tag in ipairs(tags) do
			table.insert(output, tag)
		end
	end
	return output
end

local function _ensureInventoryState(save: any): (any, boolean)
	local migrated = false
	if type(save.inventoryState) ~= "table" then
		save.inventoryState = {
			schemaVersion = INVENTORY_SCHEMA_VERSION,
			migrationVersion = 0,
			items = {},
		}
		migrated = true
	end

	local inventoryState = save.inventoryState
	if type(inventoryState.schemaVersion) ~= "number" then
		inventoryState.schemaVersion = INVENTORY_SCHEMA_VERSION
		migrated = true
	end
	if type(inventoryState.migrationVersion) ~= "number" then
		inventoryState.migrationVersion = 0
		migrated = true
	end
	if type(inventoryState.items) ~= "table" then
		inventoryState.items = {}
		migrated = true
	end

	if inventoryState.migrationVersion < INVENTORY_MIGRATION_VERSION then
		for itemId, quantity in pairs(DEFAULT_ITEM_GRANTS) do
			local item = ItemRegistry.getItem(itemId)
			if item and item.isEnabled then
				local entry = inventoryState.items[itemId]
				if type(entry) ~= "table" then
					inventoryState.items[itemId] = {
						itemId = itemId,
						quantity = quantity,
					}
				elseif type(entry.quantity) ~= "number" or entry.quantity < quantity then
					entry.itemId = itemId
					entry.quantity = quantity
				end
			end
		end
		inventoryState.migrationVersion = INVENTORY_MIGRATION_VERSION
		migrated = true
	end

	for itemId, entry in pairs(inventoryState.items) do
		if type(itemId) ~= "string" or type(entry) ~= "table" then
			inventoryState.items[itemId] = nil
			migrated = true
		else
			if entry.itemId ~= itemId then
				entry.itemId = itemId
				migrated = true
			end
			if
				type(entry.quantity) ~= "number"
				or entry.quantity < 0
				or entry.quantity ~= math.floor(entry.quantity)
			then
				entry.quantity = 0
				migrated = true
			end
			if entry.quantity <= 0 then
				inventoryState.items[itemId] = nil
				migrated = true
			end
		end
	end

	return inventoryState, migrated
end

local function _buildItemSnapshot(itemId: string, quantity: number): any
	local item = ItemRegistry.getItem(itemId)
	local equipment = item and item.itemType == "equipment" and EquipmentRegistry.getEquipmentByItemId(itemId) or nil
	return {
		itemId = itemId,
		quantity = quantity,
		isKnown = item ~= nil,
		isEnabled = item and item.isEnabled == true or false,
		displayName = item and item.displayName or itemId,
		description = item and item.description or "",
		itemType = item and item.itemType or "unknown",
		rarity = item and item.rarity or "Common",
		iconSlot = item and item.iconSlot or "placeholder_missing_item",
		maxStack = item and item.maxStack or 1,
		equipmentId = item and item.equipmentId or nil,
		sortOrder = item and item.sortOrder or 999999,
		tags = item and _copyTags(item.tags) or {},
		equipment = equipment and EquipmentRegistry.getEquipmentSnapshot(equipment.equipmentId) or nil,
	}
end

function ItemService.ensureInventoryState(player: Player)
	local save = SaveService.getPlayerSave(player)
	if not save then
		return Result.fail("not_loaded", "Player save data not loaded.")
	end

	local inventoryState, migrated = _ensureInventoryState(save)
	if migrated then
		local saveResult = SaveService.savePlayer(player)
		if not saveResult.success then
			return saveResult
		end
	end

	return Result.ok(inventoryState)
end

function ItemService.getSnapshot(player: Player)
	local stateResult = ItemService.ensureInventoryState(player)
	if not stateResult.success then
		return stateResult
	end

	local items = {}
	for itemId, entry in pairs(stateResult.value.items) do
		if type(entry) == "table" and _isPositiveInteger(entry.quantity) then
			table.insert(items, _buildItemSnapshot(itemId, entry.quantity))
		end
	end

	table.sort(items, function(a, b)
		if a.sortOrder ~= b.sortOrder then
			return a.sortOrder < b.sortOrder
		end
		return a.itemId < b.itemId
	end)

	return Result.ok({
		schemaVersion = stateResult.value.schemaVersion,
		migrationVersion = stateResult.value.migrationVersion,
		items = items,
	})
end

function ItemService.hasItem(player: Player, itemId: any)
	if type(itemId) ~= "string" or itemId == "" then
		return Result.fail("invalid_item", "Item id must be a non-empty string.")
	end

	local stateResult = ItemService.ensureInventoryState(player)
	if not stateResult.success then
		return stateResult
	end

	local entry = stateResult.value.items[itemId]
	if type(entry) ~= "table" or not _isPositiveInteger(entry.quantity) then
		return Result.fail("unowned_item", "Player does not own this item.")
	end

	return Result.ok(entry)
end

function ItemService.grantItem(player: Player, itemId: any, quantity: any, source: string?)
	if type(itemId) ~= "string" or itemId == "" then
		return Result.fail("invalid_item", "Item id must be a non-empty string.")
	end
	if not _isPositiveInteger(quantity) then
		return Result.fail("invalid_quantity", "Grant quantity must be a positive integer.")
	end

	local item = ItemRegistry.getItem(itemId)
	if not item then
		return Result.fail("removed_item", "Item config does not exist.")
	end
	if not item.isEnabled then
		return Result.fail("disabled_item", "Disabled items cannot be granted.")
	end

	local stateResult = ItemService.ensureInventoryState(player)
	if not stateResult.success then
		return stateResult
	end

	local entry = stateResult.value.items[itemId]
	if type(entry) ~= "table" then
		entry = {
			itemId = itemId,
			quantity = 0,
		}
		stateResult.value.items[itemId] = entry
	end

	entry.quantity = math.min(item.maxStack, entry.quantity + quantity)

	local saveResult = SaveService.savePlayer(player)
	if not saveResult.success then
		return saveResult
	end

	return Result.ok({
		itemId = itemId,
		quantity = entry.quantity,
		source = source or "system",
	})
end

function ItemService.removeItem(player: Player, itemId: any, quantity: any)
	if type(itemId) ~= "string" or itemId == "" then
		return Result.fail("invalid_item", "Item id must be a non-empty string.")
	end
	if not _isPositiveInteger(quantity) then
		return Result.fail("invalid_quantity", "Remove quantity must be a positive integer.")
	end

	local stateResult = ItemService.ensureInventoryState(player)
	if not stateResult.success then
		return stateResult
	end

	local entry = stateResult.value.items[itemId]
	if type(entry) ~= "table" or not _isPositiveInteger(entry.quantity) then
		return Result.fail("unowned_item", "Player does not own this item.")
	end
	if entry.quantity < quantity then
		return Result.fail("invalid_quantity", "Cannot remove more items than owned.")
	end

	entry.quantity -= quantity
	if entry.quantity <= 0 then
		stateResult.value.items[itemId] = nil
	end

	local saveResult = SaveService.savePlayer(player)
	if not saveResult.success then
		return saveResult
	end

	return Result.ok({
		itemId = itemId,
		quantity = entry.quantity or 0,
	})
end

return ItemService
