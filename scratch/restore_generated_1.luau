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
local p = ensurePath(game:GetService("ReplicatedStorage").Shared, "utilities")
getOrCreateModule(p, "Result", [====[
--[[
	Result
	Location: src/shared/utilities/Result.luau

	Shared success/failure result pattern for Project Genesis.

	Every server service, remote handler, and validation function that can
	fail should return a Result table instead of throwing an error or
	returning raw nil.

	This pattern makes failure handling explicit, prevents silent failures,
	and provides a uniform interface for callers to branch on.

	Rules:
	- Result tables are immutable once created.
	- Result.ok(value) wraps a successful result.
	- Result.fail(code, message?) wraps a failure with a safe error code.
	- Callers must check the "success" field before using the "value" field.
	- Error codes must be strings — never raw error objects or stack traces.
	- This module is shared-safe: no server-only logic, no gameplay values.

	Part of MVP-001: Core Framework Foundation.
--]]

-- Type exports for use by other modules.
export type OkResult<T> = {
	success: true,
	value: T,
}

export type FailResult = {
	success: false,
	code: string,
	message: string?,
}

export type Result<T> = OkResult<T> | FailResult

local Result = {}

--[[
	Result.ok(value) -> OkResult<T>

	Wraps a successful result with the given value.
	"value" may be any type, including nil for void successes.

	Example:
	  local r = Result.ok(42)
	  if r.success then print(r.value) end
--]]
function Result.ok<T>(value: T): OkResult<T>
	return {
		success = true,
		value = value,
	}
end

--[[
	Result.fail(code, message?) -> FailResult

	Wraps a failure result with a safe error code and optional message.

	"code" should be a documented error code string such as:
	  "invalid_input"
	  "not_found"
	  "unauthorized"
	  "service_unavailable"
	  "validation_failed"

	"message" is optional human-readable context for debugging.
	Do NOT put sensitive data, raw stack traces, or save payloads in message.

	Example:
	  local r = Result.fail("not_found", "Player session not found.")
	  if not r.success then warn(r.code) end
--]]
function Result.fail(code: string, message: string?): FailResult
	assert(type(code) == "string" and code ~= "", "[Result] Error code must be a non-empty string.")
	return {
		success = false,
		code = code,
		message = message,
	}
end

--[[
	Result.isOk(result) -> boolean

	Returns true if the result represents success.
	Type-safe guard for branching on result state.
--]]
function Result.isOk(result: { success: boolean }): boolean
	return result.success == true
end

--[[
	Result.isFail(result) -> boolean

	Returns true if the result represents failure.
--]]
function Result.isFail(result: { success: boolean }): boolean
	return result.success == false
end

--[[
	Result.unwrapOr(result, default) -> T

	Returns the result's value on success, or the default value on failure.
	Use when a fallback is appropriate and failure should not propagate.

	Example:
	  local count = Result.unwrapOr(Result.fail("not_found"), 0)
--]]
function Result.unwrapOr<T>(result: OkResult<T> | FailResult, default: T): T
	if result.success then
		return (result :: OkResult<T>).value
	else
		return default
	end
end

return Result

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "bootstrap")
getOrCreateModule(p, "ServerBootstrap", [====[
--[[
	ServerBootstrap
	Location: src/server/bootstrap/ServerBootstrap.luau

	Server-side bootstrap shell for Project Genesis.

	This script is the entry point for all server-side systems.
	It initializes and starts server services in the documented lifecycle order
	using ServiceLifecycle.

	Current registered services: NONE (MVP-001 shell only).
	Future tasks will register their services here after implementation.

	Startup sequence:
	  1. Require all approved services.
	  2. Register each service with ServiceLifecycle.
	  3. Call ServiceLifecycle.init() — runs all init() phases.
	  4. Call ServiceLifecycle.start() — runs all start() phases.

	Rules:
	- This script is server-only. It must live in ServerScriptService.
	- No gameplay values are hardcoded here.
	- No combat, creature, economy, or save systems are started here
	  (those belong in future approved tasks).
	- Bootstrap must fail gracefully — a single service failure must not
	  crash the entire bootstrap.

	Part of MVP-001: Core Framework Foundation.
--]]

-- Services are required here, before bootstrap runs.
-- Example (to be added by future tasks):
--   local SaveService     = require(ServerScriptService.Server.services.SaveService)
--   local CreatureService = require(ServerScriptService.Server.services.CreatureService)

local ServiceLifecycle = require(script.Parent.Parent.runtime.ServiceLifecycle)

print("[ServerBootstrap] ═══ Project Genesis Server Starting ═══")
print(string.format("[ServerBootstrap] Registered services: %d", #ServiceLifecycle.getRegisteredNames()))

-- ─── Register Services ───────────────────────────────────────────────────────
-- (Empty for MVP-001 — future tasks will add service registrations here)
--
-- Template:
--   ServiceLifecycle.register(SaveService)
--   ServiceLifecycle.register(CreatureService)

-- ─── Phase 1: Initialize ─────────────────────────────────────────────────────
ServiceLifecycle.init()
print("[ServerBootstrap] All services initialized.")

-- ─── Phase 2: Start ─────────────────────────────────────────────────────────
ServiceLifecycle.start()
print("[ServerBootstrap] All services started.")

print("[ServerBootstrap] ═══ Server Ready ═══")

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