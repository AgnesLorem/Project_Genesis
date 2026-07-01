local ServerStorage = game:GetService("ServerStorage")

local ItemSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.ItemSchema)

local ItemRegistry = {}

local _registry: { [string]: any } = {}
local _initialized = false

local function _getConfigFolder(): Folder?
	local configs = ServerStorage:FindFirstChild("Configs")
	if not configs then
		warn("[ItemRegistry] ServerStorage.Configs folder not found.")
		return nil
	end

	local folder = configs:FindFirstChild("items")
	if not folder then
		warn("[ItemRegistry] ServerStorage.Configs.items folder not found.")
		return nil
	end

	if not folder:IsA("Folder") then
		warn("[ItemRegistry] ServerStorage.Configs.items is not a Folder.")
		return nil
	end

	return folder :: Folder
end

local function _buildSnapshot(item: any): any
	return {
		itemId = item.itemId,
		displayName = item.displayName,
		description = item.description,
		itemType = item.itemType,
		rarity = item.rarity,
		iconSlot = item.iconSlot,
		maxStack = item.maxStack,
		equipmentId = item.equipmentId,
		sortOrder = item.sortOrder,
		tags = item.tags,
		isEnabled = item.isEnabled,
	}
end

function ItemRegistry.init()
	if _initialized then
		warn("[ItemRegistry] Already initialized. Skipping.")
		return
	end

	local folder = _getConfigFolder()
	if folder then
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("ModuleScript") then
				local ok, record = pcall(require, child :: ModuleScript)
				if ok and type(record) == "table" then
					local result = ItemSchema.validate(record)
					if result.success then
						local item = result.value
						if _registry[item.itemId] then
							warn(string.format("[ItemRegistry] Duplicate itemId '%s' - skipping.", item.itemId))
						else
							_registry[item.itemId] = item
							print(string.format("[ItemRegistry] Loaded item '%s'.", item.itemId))
						end
					else
						warn(string.format(
							"[ItemRegistry] Validation failed for '%s': %s",
							tostring(record.itemId or record.id or child.Name),
							result.message or result.code
						))
					end
				else
					warn(string.format("[ItemRegistry] Failed to require '%s': %s", child:GetFullName(), tostring(record)))
				end
			end
		end
	end

	_initialized = true
end

function ItemRegistry.getItem(itemId: string): any
	return _registry[itemId]
end

function ItemRegistry.getItemSnapshot(itemId: string): any
	local item = ItemRegistry.getItem(itemId)
	if not item then
		return nil
	end
	return _buildSnapshot(item)
end

function ItemRegistry.getAllItems(): { any }
	local list = {}
	for _, item in pairs(_registry) do
		table.insert(list, item)
	end
	return list
end

function ItemRegistry.isInitialized(): boolean
	return _initialized
end

return ItemRegistry
