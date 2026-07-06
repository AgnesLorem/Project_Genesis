local function getOrCreateFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

local function getOrCreateModule(parent, name, source)
    local module = parent:FindFirstChild(name)
    if not module then
        module = Instance.new("ModuleScript")
        module.Name = name
        module.Parent = parent
    end
    module.Source = source
    return module
end

local function ensurePath(root, path)
    if path == "" then return root end
    local current = root
    for part in string.gmatch(path, "[^/]+") do
        current = getOrCreateFolder(current, part)
    end
    return current
end

-- Create root folders
getOrCreateFolder(game:GetService("ServerScriptService"), "Server")
getOrCreateFolder(game:GetService("StarterPlayer").StarterPlayerScripts, "Client")
getOrCreateFolder(game:GetService("ReplicatedStorage"), "Shared")
getOrCreateFolder(game:GetService("ServerStorage"), "Configs")
local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
getOrCreateModule(p, "EvolutionRegistry", [====[
--[[
	EvolutionRegistry
	Location: src/server/data/EvolutionRegistry.luau

	Loads evolution configs, validates them via EvolutionSchema, and indexes them.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)
local EvolutionSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.EvolutionSchema)

local EvolutionRegistry = {}
local _registry: { [string]: any } = {}
local _initialized = false

function EvolutionRegistry.init()
	if _initialized then return end
	
	local records = ConfigRegistry.load("evolutions")
	for _, record in ipairs(records) do
		local result = EvolutionSchema.validate(record)
		if result.success then
			local id = result.value.evolutionId
			if _registry[id] then
				warn(string.format("[EvolutionRegistry] Duplicate evolutionId '%s' — skipped.", id))
			else
				_registry[id] = result.value
			end
		else
			warn(string.format("[EvolutionRegistry] Validation failed for '%s': %s", tostring(record.evolutionId or "unknown"), result.message or result.code))
		end
	end
	
	_initialized = true
end

function EvolutionRegistry.getEvolution(evolutionId: string): any
	return _registry[evolutionId]
end

function EvolutionRegistry.getAllEvolutions(): { any }
	local list = {}
	for _, evol in pairs(_registry) do
		table.insert(list, evol)
	end
	return list
end

function EvolutionRegistry.isInitialized(): boolean
	return _initialized
end

return EvolutionRegistry

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
getOrCreateModule(p, "GeneratorRegistry", [====[
--[[
	GeneratorRegistry
	Location: src/server/data/GeneratorRegistry.luau

	Loads generator configs via ConfigRegistry, validates each with GeneratorSchema,
	indexes by generatorId.

	Rules:
	- Static definitions only. No player state.
	- Loads from ServerStorage.Configs.generators via ConfigRegistry.
	- Invalid configs are rejected and logged, never silently accepted.

	Part of MVP-005: Bio Generator and Economy Foundation.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)
local GeneratorSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.GeneratorSchema)

local GeneratorRegistry = {}

local _registry: { [string]: any } = {}
local _initialized = false

--[[
	GeneratorRegistry.init()

	Loads all generator configs, validates each, and indexes by generatorId.
	Must be called once during server bootstrap before any service uses generators.
--]]
function GeneratorRegistry.init()
	if _initialized then
		warn("[GeneratorRegistry] Already initialized. Skipping.")
		return
	end

	local records = ConfigRegistry.load("generators")

	for _, record in ipairs(records) do
		local result = GeneratorSchema.validate(record)
		if result.success then
			local generatorId = result.value.generatorId
			if _registry[generatorId] then
				warn(string.format(
					"[GeneratorRegistry] Duplicate generatorId '%s' — skipping.",
					generatorId
				))
			else
				_registry[generatorId] = result.value
				print(string.format("[GeneratorRegistry] Loaded generator: '%s'", generatorId))
			end
		else
			warn(string.format(
				"[GeneratorRegistry] Config validation failed: %s — %s",
				tostring(record.id or "unknown"),
				result.message or result.code
			))
		end
	end

	_initialized = true
end

--[[
	GeneratorRegistry.getGenerator(generatorId) -> config?

	Returns the validated config for a generatorId, or nil if not found.
--]]
function GeneratorRegistry.getGenerator(generatorId: string): any
	return _registry[generatorId]
end

--[[
	GeneratorRegistry.getAllGenerators() -> { config }

	Returns a list of all loaded generator configs.
--]]
function GeneratorRegistry.getAllGenerators(): { any }
	local list = {}
	for _, config in pairs(_registry) do
		table.insert(list, config)
	end
	return list
end

--[[
	GeneratorRegistry.isInitialized() -> boolean
--]]
function GeneratorRegistry.isInitialized(): boolean
	return _initialized
end

return GeneratorRegistry

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
getOrCreateModule(p, "ItemRegistry", [====[
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

]====])

return 'Restore chunk 3 complete!'