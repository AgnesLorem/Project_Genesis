local ServerStorage = game:GetService("ServerStorage")

local EquipmentSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.EquipmentSchema)

local EquipmentRegistry = {}

local _registry: { [string]: any } = {}
local _byItemId: { [string]: any } = {}
local _initialized = false

local function _getConfigFolder(): Folder?
	local configs = ServerStorage:FindFirstChild("Configs")
	if not configs then
		warn("[EquipmentRegistry] ServerStorage.Configs folder not found.")
		return nil
	end

	local folder = configs:FindFirstChild("equipment")
	if not folder then
		warn("[EquipmentRegistry] ServerStorage.Configs.equipment folder not found.")
		return nil
	end

	if not folder:IsA("Folder") then
		warn("[EquipmentRegistry] ServerStorage.Configs.equipment is not a Folder.")
		return nil
	end

	return folder :: Folder
end

local function _buildSnapshot(equipment: any): any
	return {
		equipmentId = equipment.equipmentId,
		itemId = equipment.itemId,
		displayName = equipment.displayName,
		slotId = equipment.slotId,
		equipmentType = equipment.equipmentType,
		statBonuses = {
			hp = equipment.statBonuses.hp,
			atk = equipment.statBonuses.atk,
			def = equipment.statBonuses.def,
			spd = equipment.statBonuses.spd,
		},
		isEnabled = equipment.isEnabled,
	}
end

function EquipmentRegistry.init()
	if _initialized then
		warn("[EquipmentRegistry] Already initialized. Skipping.")
		return
	end

	local folder = _getConfigFolder()
	if folder then
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("ModuleScript") then
				local ok, record = pcall(require, child :: ModuleScript)
				if ok and type(record) == "table" then
					local result = EquipmentSchema.validate(record)
					if result.success then
						local equipment = result.value
						if _registry[equipment.equipmentId] then
							warn(string.format("[EquipmentRegistry] Duplicate equipmentId '%s' - skipping.", equipment.equipmentId))
						else
							_registry[equipment.equipmentId] = equipment
							_byItemId[equipment.itemId] = equipment
							print(string.format("[EquipmentRegistry] Loaded equipment '%s'.", equipment.equipmentId))
						end
					else
						warn(string.format(
							"[EquipmentRegistry] Validation failed for '%s': %s",
							tostring(record.equipmentId or record.id or child.Name),
							result.message or result.code
						))
					end
				else
					warn(string.format("[EquipmentRegistry] Failed to require '%s': %s", child:GetFullName(), tostring(record)))
				end
			end
		end
	end

	_initialized = true
end

function EquipmentRegistry.getEquipment(equipmentId: string): any
	return _registry[equipmentId]
end

function EquipmentRegistry.getEquipmentByItemId(itemId: string): any
	return _byItemId[itemId]
end

function EquipmentRegistry.getEquipmentSnapshot(equipmentId: string): any
	local equipment = EquipmentRegistry.getEquipment(equipmentId)
	if not equipment then
		return nil
	end
	return _buildSnapshot(equipment)
end

function EquipmentRegistry.getEquipmentSnapshotByItemId(itemId: string): any
	local equipment = EquipmentRegistry.getEquipmentByItemId(itemId)
	if not equipment then
		return nil
	end
	return _buildSnapshot(equipment)
end

function EquipmentRegistry.getAllEquipment(): { any }
	local list = {}
	for _, equipment in pairs(_registry) do
		table.insert(list, equipment)
	end
	return list
end

function EquipmentRegistry.isInitialized(): boolean
	return _initialized
end

return EquipmentRegistry
