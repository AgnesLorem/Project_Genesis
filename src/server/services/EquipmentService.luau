local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
local EquipmentSlotSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.EquipmentSlotSchema)

local SaveService = require(script.Parent.SaveService)
local ItemService = require(script.Parent.ItemService)
local ItemRegistry = require(script.Parent.Parent.data.ItemRegistry)
local EquipmentRegistry = require(script.Parent.Parent.data.EquipmentRegistry)

local EquipmentService = {}

local EQUIPMENT_SCHEMA_VERSION = 1
local EQUIPMENT_MIGRATION_VERSION = 1

local function _emptyBonuses(): any
	return {
		hp = 0,
		atk = 0,
		def = 0,
		spd = 0,
	}
end

local function _addBonuses(total: any, bonuses: any)
	for _, statName in ipairs({ "hp", "atk", "def", "spd" }) do
		total[statName] += bonuses[statName] or 0
	end
end

local function _ensureEquipmentState(save: any): (any, boolean)
	local migrated = false
	if type(save.equipmentState) ~= "table" then
		save.equipmentState = {
			schemaVersion = EQUIPMENT_SCHEMA_VERSION,
			migrationVersion = EQUIPMENT_MIGRATION_VERSION,
			equipped = EquipmentSlotSchema.createEmptySlotState(),
		}
		migrated = true
	end

	local equipmentState = save.equipmentState
	if type(equipmentState.schemaVersion) ~= "number" then
		equipmentState.schemaVersion = EQUIPMENT_SCHEMA_VERSION
		migrated = true
	end
	if type(equipmentState.migrationVersion) ~= "number" then
		equipmentState.migrationVersion = EQUIPMENT_MIGRATION_VERSION
		migrated = true
	end
	if type(equipmentState.equipped) ~= "table" then
		equipmentState.equipped = EquipmentSlotSchema.createEmptySlotState()
		migrated = true
	end

	for _, slotId in ipairs(EquipmentSlotSchema.getSlotIds()) do
		local itemId = equipmentState.equipped[slotId]
		if itemId ~= nil and type(itemId) ~= "string" then
			equipmentState.equipped[slotId] = nil
			migrated = true
		end
	end

	return equipmentState, migrated
end

local function _validateEquipRequest(player: Player, itemId: any, slotId: any)
	if type(itemId) ~= "string" or itemId == "" then
		return Result.fail("invalid_item", "Equip request requires a non-empty itemId.")
	end

	local slotResult = EquipmentSlotSchema.validateSlotId(slotId)
	if not slotResult.success then
		return slotResult
	end

	local item = ItemRegistry.getItem(itemId)
	if not item then
		return Result.fail("removed_item", "Item config does not exist.")
	end
	if not item.isEnabled then
		return Result.fail("disabled_item", "Disabled items cannot be equipped.")
	end
	if item.itemType ~= "equipment" then
		return Result.fail("not_equipment", "Only equipment items can be equipped.")
	end

	local equipment = EquipmentRegistry.getEquipmentByItemId(itemId)
	if not equipment then
		return Result.fail("removed_equipment", "Equipment config does not exist.")
	end
	if not equipment.isEnabled then
		return Result.fail("disabled_equipment", "Disabled equipment cannot be equipped.")
	end
	if equipment.slotId ~= slotId then
		return Result.fail("wrong_equipment_type", "Equipment item does not fit this slot.")
	end

	local ownedResult = ItemService.hasItem(player, itemId)
	if not ownedResult.success then
		return ownedResult
	end

	return Result.ok({
		item = item,
		equipment = equipment,
		slotId = slotId,
	})
end

local function _sanitizeEquipped(player: Player, save: any, equipmentState: any): boolean
	local migrated = false
	for _, slotId in ipairs(EquipmentSlotSchema.getSlotIds()) do
		local itemId = equipmentState.equipped[slotId]
		if itemId ~= nil then
			local validation = _validateEquipRequest(player, itemId, slotId)
			if not validation.success then
				equipmentState.equipped[slotId] = nil
				migrated = true
			end
		end
	end
	return migrated
end

local function _buildSlotSnapshot(slotId: string, itemId: string?): any
	local item = itemId and ItemRegistry.getItem(itemId) or nil
	local equipment = itemId and EquipmentRegistry.getEquipmentByItemId(itemId) or nil
	return {
		slotId = slotId,
		itemId = itemId,
		isOccupied = itemId ~= nil,
		item = item and ItemRegistry.getItemSnapshot(itemId) or nil,
		equipment = equipment and EquipmentRegistry.getEquipmentSnapshot(equipment.equipmentId) or nil,
	}
end

function EquipmentService.ensureEquipmentState(player: Player)
	local save = SaveService.getPlayerSave(player)
	if not save then
		return Result.fail("not_loaded", "Player save data not loaded.")
	end

	local equipmentState, migrated = _ensureEquipmentState(save)
	if _sanitizeEquipped(player, save, equipmentState) then
		migrated = true
	end

	if migrated then
		local saveResult = SaveService.savePlayer(player)
		if not saveResult.success then
			return saveResult
		end
	end

	return Result.ok(equipmentState)
end

function EquipmentService.calculateStatBonuses(player: Player)
	local stateResult = EquipmentService.ensureEquipmentState(player)
	if not stateResult.success then
		return stateResult
	end

	local total = _emptyBonuses()
	for _, slotId in ipairs(EquipmentSlotSchema.getSlotIds()) do
		local itemId = stateResult.value.equipped[slotId]
		if itemId then
			local equipment = EquipmentRegistry.getEquipmentByItemId(itemId)
			if equipment and equipment.isEnabled then
				_addBonuses(total, equipment.statBonuses)
			end
		end
	end

	return Result.ok(total)
end

function EquipmentService.getSnapshot(player: Player)
	local stateResult = EquipmentService.ensureEquipmentState(player)
	if not stateResult.success then
		return stateResult
	end

	local slots = {}
	for _, slotId in ipairs(EquipmentSlotSchema.getSlotIds()) do
		table.insert(slots, _buildSlotSnapshot(slotId, stateResult.value.equipped[slotId]))
	end

	local bonusResult = EquipmentService.calculateStatBonuses(player)
	if not bonusResult.success then
		return bonusResult
	end

	return Result.ok({
		schemaVersion = stateResult.value.schemaVersion,
		migrationVersion = stateResult.value.migrationVersion,
		slots = slots,
		statBonuses = bonusResult.value,
	})
end

function EquipmentService.tryEquip(player: Player, itemId: any, slotId: any)
	local validation = _validateEquipRequest(player, itemId, slotId)
	if not validation.success then
		return validation
	end

	local stateResult = EquipmentService.ensureEquipmentState(player)
	if not stateResult.success then
		return stateResult
	end

	for equippedSlotId, equippedItemId in pairs(stateResult.value.equipped) do
		if equippedItemId == itemId then
			return Result.fail("duplicate_equip", string.format("Item is already equipped in %s.", equippedSlotId))
		end
	end

	stateResult.value.equipped[slotId] = itemId

	local saveResult = SaveService.savePlayer(player)
	if not saveResult.success then
		return saveResult
	end

	local snapshotResult = EquipmentService.getSnapshot(player)
	if not snapshotResult.success then
		return snapshotResult
	end

	return Result.ok(snapshotResult.value)
end

function EquipmentService.tryUnequip(player: Player, slotId: any)
	local slotResult = EquipmentSlotSchema.validateSlotId(slotId)
	if not slotResult.success then
		return slotResult
	end

	local stateResult = EquipmentService.ensureEquipmentState(player)
	if not stateResult.success then
		return stateResult
	end

	if stateResult.value.equipped[slotId] == nil then
		return Result.fail("slot_empty", "Equipment slot is already empty.")
	end

	stateResult.value.equipped[slotId] = nil

	local saveResult = SaveService.savePlayer(player)
	if not saveResult.success then
		return saveResult
	end

	local snapshotResult = EquipmentService.getSnapshot(player)
	if not snapshotResult.success then
		return snapshotResult
	end

	return Result.ok(snapshotResult.value)
end

return EquipmentService
