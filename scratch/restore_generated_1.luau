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
getOrCreateModule(p, "BalanceRegistry", [====[
--[[
	BalanceRegistry
	Location: src/server/data/BalanceRegistry.luau

	Loads balance configs (including combat_config) via ConfigRegistry.
	Validates with respective schemas.

	Rules:
	- Static definitions only.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)
local CombatBalanceSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CombatBalanceSchema)

local BalanceRegistry = {}

local _registry: { [string]: any } = {}
local _initialized = false

function BalanceRegistry.init()
	if _initialized then
		warn("[BalanceRegistry] Already initialized. Skipping.")
		return
	end

	local records = ConfigRegistry.load("balance")

	for _, record in ipairs(records) do
		if record.id == "combat_core" then
			local result = CombatBalanceSchema.validate(record)
			if result.success then
				_registry["combat_core"] = result.value
				print("[BalanceRegistry] Loaded combat_core config")
			else
				warn("[BalanceRegistry] combat_core validation failed: " .. (result.message or result.code))
			end
		else
			-- Other balance configs go here
			_registry[record.id] = record
		end
	end

	_initialized = true
end

function BalanceRegistry.getCombatConfig(): any
	return _registry["combat_core"]
end

function BalanceRegistry.isInitialized(): boolean
	return _initialized
end

return BalanceRegistry

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
getOrCreateModule(p, "BossRegistry", [====[
--[[
	BossRegistry
	Location: src/server/data/BossRegistry.luau

	Loads enabled boss/challenge configs, validates them via BossSchema, and
	exposes static lookup/display data. It does not resolve rewards or switch
	boss phases at runtime.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)
local BossSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.BossSchema)

local BossRegistry = {}
local _registry: { [string]: any } = {}
local _initialized = false

local function _cloneArray(value: { any }): { any }
	local output = {}
	for _, item in ipairs(value) do
		table.insert(output, item)
	end
	return output
end

local function _buildSnapshot(boss: any): any
	return {
		bossId = boss.bossId,
		displayName = boss.displayName,
		battleMode = boss.battleMode,
		teamSize = boss.teamSize,
		recommendedPower = boss.recommendedPower,
		enemyRefs = _cloneArray(boss.enemyRefs),
		retryPolicyRef = boss.retryPolicyRef,
		isEnabled = boss.isEnabled,
	}
end

function BossRegistry.init()
	if _initialized then
		warn("[BossRegistry] Already initialized. Skipping.")
		return
	end

	local records = ConfigRegistry.load("bosses")
	for _, record in ipairs(records) do
		local result = BossSchema.validate(record)
		if result.success then
			local boss = result.value
			if boss.isEnabled then
				local bossId = boss.bossId
				if _registry[bossId] then
					warn(string.format("[BossRegistry] Duplicate bossId '%s' - skipping.", bossId))
				else
					_registry[bossId] = boss
				end
			end
		else
			warn(string.format(
				"[BossRegistry] Validation failed for '%s': %s",
				tostring(record.bossId or record.id or "unknown"),
				result.message or result.code
			))
		end
	end

	_initialized = true
end

function BossRegistry.getBoss(bossId: string): any
	return _registry[bossId]
end

function BossRegistry.getBossSnapshot(bossId: string): any
	local boss = BossRegistry.getBoss(bossId)
	if not boss then
		return nil
	end

	return _buildSnapshot(boss)
end

function BossRegistry.getAllBosses(): { any }
	local list = {}
	for _, boss in pairs(_registry) do
		table.insert(list, boss)
	end
	return list
end

function BossRegistry.getAllBossSnapshots(): { any }
	local list = {}
	for _, boss in pairs(_registry) do
		table.insert(list, _buildSnapshot(boss))
	end
	table.sort(list, function(a, b)
		return a.bossId < b.bossId
	end)
	return list
end

function BossRegistry.isInitialized(): boolean
	return _initialized
end

return BossRegistry

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
getOrCreateModule(p, "ConfigRegistry", [====[
--[[
	ConfigRegistry
	Location: ServerStorage.Configs (server-only)
	
	Loads and caches static configuration records by category.
	All config records are read from ModuleScripts parented under
	ServerStorage.Configs.<category>.
	
	Rules:
	- Config is loaded server-side only.
	- Missing categories return empty tables, never throw.
	- No gameplay values are hardcoded here — this is routing logic only.
	- Cache is populated on first load per category.
	
	Part of MVP-002: Save, Config, and Database Foundation.
--]]

local ServerStorage = game:GetService("ServerStorage")

-- Active MVP config categories (from docs/CONFIG_STRUCTURE.md)
-- Reserved categories (quest, tower, status_effects) are excluded here.
local ACTIVE_CATEGORIES = {
	"creatures",
	"skills",
	"genes",
	"worlds",
	"bosses",
	"economy",
	"balance",
	"drop_tables",
	"shared",
	"generators",
	"evolutions",
}

-- Reserved categories that must NOT be loaded as active gameplay.
local RESERVED_CATEGORIES = {
	"quests",
	"towers",
	"status_effects",
}

local RESERVED_SET = {}
for _, cat in ipairs(RESERVED_CATEGORIES) do
	RESERVED_SET[cat] = true
end

local ConfigRegistry = {}

-- Internal cache: category (string) -> array of record tables
local _cache: { [string]: { [string]: any } } = {}

-- Internal: get the Configs root Folder from ServerStorage.
-- Returns nil if not found.
local function _getConfigsRoot(): Folder?
	local configs = ServerStorage:FindFirstChild("Configs")
	if not configs then
		warn("[ConfigRegistry] ServerStorage.Configs folder not found. Config loading will return empty results.")
		return nil
	end
	return configs :: Folder
end

-- Internal: load all ModuleScript records from a category folder.
-- Returns a list of tables. Each ModuleScript must return a table.
local function _loadCategoryFolder(categoryFolder: Folder): { [string]: any }
	local records: { [string]: any } = {}

	for _, child in ipairs(categoryFolder:GetChildren()) do
		if child:IsA("ModuleScript") then
			local ok, result = pcall(require, child :: ModuleScript)
			if ok then
				if type(result) == "table" then
					table.insert(records, result)
				else
					warn(string.format(
						"[ConfigRegistry] ModuleScript '%s' did not return a table — skipped.",
						child:GetFullName()
					))
				end
			else
				warn(string.format(
					"[ConfigRegistry] Failed to require '%s': %s",
					child:GetFullName(),
					tostring(result)
				))
			end
		end
	end

	return records
end

--[[ 
	ConfigRegistry.load(category: string) -> { table }
	
	Returns all config records for the given category.
	Returns an empty table if the category folder is missing or empty.
	Never throws. Caches results after first load.
--]]
function ConfigRegistry.load(category: string): { [string]: any }
	assert(type(category) == "string", "[ConfigRegistry] category must be a string")

	-- Block reserved categories from active use.
	if RESERVED_SET[category] then
		warn(string.format(
			"[ConfigRegistry] Category '%s' is reserved and must not be loaded as active gameplay. Returning empty.",
			category
		))
		return {}
	end

	-- Return cached result if available.
	if _cache[category] then
		return _cache[category]
	end

	-- Attempt to load from ServerStorage.Configs.<category>
	local configsRoot = _getConfigsRoot()
	if not configsRoot then
		_cache[category] = {}
		return {}
	end

	local categoryFolder = configsRoot:FindFirstChild(category)
	if not categoryFolder then
		warn(string.format(
			"[ConfigRegistry] Category folder '%s' not found in ServerStorage.Configs. Returning empty.",
			category
		))
		_cache[category] = {}
		return {}
	end

	if not categoryFolder:IsA("Folder") then
		warn(string.format(
			"[ConfigRegistry] '%s' in ServerStorage.Configs is not a Folder — skipped.",
			category
		))
		_cache[category] = {}
		return {}
	end

	local records = _loadCategoryFolder(categoryFolder :: Folder)
	_cache[category] = records

	return records
end

--[[
	ConfigRegistry.get(category: string, id: string) -> table?
	
	Returns a single config record by its stable ID field.
	Returns nil if not found.
	The record must have an "id" field matching the expected ID format.
	Never throws.
--]]
function ConfigRegistry.get(category: string, id: string): { [string]: any }?
	assert(type(category) == "string", "[ConfigRegistry] category must be a string")
	assert(type(id) == "string", "[ConfigRegistry] id must be a string")

	local records = ConfigRegistry.load(category)
	for _, record in ipairs(records) do
		if type(record) == "table" and record.id == id then
			return record
		end
	end

	return nil
end

--[[
	ConfigRegistry.getActiveCategories() -> { string }
	
	Returns the list of active MVP config category names.
	Does not include reserved categories.
--]]
function ConfigRegistry.getActiveCategories(): { string }
	return table.clone(ACTIVE_CATEGORIES)
end

--[[
	ConfigRegistry.invalidateCache(category: string?)
	
	Clears the cache for a specific category, or all categories if nil.
	Use when config data is changed at runtime (testing only).
--]]
function ConfigRegistry.invalidateCache(category: string?)
	if category then
		_cache[category] = nil
	else
		table.clear(_cache)
	end
end

return ConfigRegistry

]====])

return 'Restore chunk 1 complete!'