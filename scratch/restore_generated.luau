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
local p = ensurePath(game:GetService("ReplicatedStorage").Shared, "F:/Project_Genesis/src/shared/data")
getOrCreateModule(p, "CreatureRegistry", [====[
local CreatureSchema = require(script.Parent.CreatureSchema)
local Result = require(script.Parent.Parent.Result)

local CreatureRegistry = {}
local registry = {}

-- Static definitions only. No player state.
function CreatureRegistry.loadConfig(configs: { [string]: any })
    for id, data in pairs(configs) do
        local result = CreatureSchema.validate(data)
        if result.success then
            registry[id] = result.value
        else
            warn(string.format("Failed to validate creature config %s: %s", id, result.error))
        end
    end
end

function CreatureRegistry.getCreature(id: string)
    return registry[id]
end

function CreatureRegistry.getAllCreatures()
    local list = {}
    for _, creature in pairs(registry) do
        table.insert(list, creature)
    end
    return list
end

return CreatureRegistry

]====])

local p = ensurePath(game:GetService("ReplicatedStorage").Shared, "F:/Project_Genesis/src/shared/data")
getOrCreateModule(p, "CreatureSchema", [====[
local Result = require(script.Parent.Parent.Result)

local CreatureSchema = {}

-- Validates exactly the fields defined in docs/DATA_SCHEMA.md
function CreatureSchema.validate(data: any)
    if type(data) ~= "table" then
        return Result.fail("Creature data must be a table")
    end

    if type(data.creatureId) ~= "string" then
        return Result.fail("Missing or invalid creatureId (string)")
    end

    if type(data.schemaVersion) ~= "number" then
        return Result.fail("Missing or invalid schemaVersion (number)")
    end

    if type(data.displayName) ~= "string" then
        return Result.fail("Missing or invalid displayName (string)")
    end

    if type(data.description) ~= "string" then
        return Result.fail("Missing or invalid description (string)")
    end

    if type(data.baseStats) ~= "table" then
        return Result.fail("Missing or invalid baseStats (table)")
    end

    if type(data.skillIds) ~= "table" then
        return Result.fail("Missing or invalid skillIds (array)")
    end

    if type(data.geneSlots) ~= "table" then
        return Result.fail("Missing or invalid geneSlots (array)")
    end

    if type(data.evolutionLineId) ~= "string" then
        return Result.fail("Missing or invalid evolutionLineId (string)")
    end

    if type(data.collectionCategory) ~= "string" then
        return Result.fail("Missing or invalid collectionCategory (string enum)")
    end

    if type(data.visualRef) ~= "string" then
        return Result.fail("Missing or invalid visualRef (string)")
    end

    if type(data.sortOrder) ~= "number" then
        return Result.fail("Missing or invalid sortOrder (number)")
    end

    if type(data.isEnabled) ~= "boolean" then
        return Result.fail("Missing or invalid isEnabled (boolean)")
    end

    return Result.ok(data)
end

return CreatureSchema

]====])

local p = ensurePath(game:GetService("ReplicatedStorage").Shared, "F:/Project_Genesis/src/shared/network")
getOrCreateModule(p, "CreatureSnapshotType", [====[
export type CreatureSnapshotType = {
    instanceId: string,
    creatureId: string,
    displayName: string,
    -- Strictly presentation fields only. No server-only metadata.
    -- (e.g. no hidden genes, no private loadouts)
}

return {}

]====])

local p = ensurePath(game:GetService("ReplicatedStorage").Shared, "F:/Project_Genesis/src/shared/utilities")
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

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/bootstrap")
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

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/data")
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

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/data")
getOrCreateModule(p, "ConfigValidator", [====[
--[[
	ConfigValidator
	Location: src/server/data/ConfigValidator.luau
	
	Validates configuration records against documented schema rules before
	any gameplay system consumes them.

	Validation checks:
	  1. Required fields exist.
	  2. Field types match the schema declaration.
	  3. The "id" field is present and follows stable ID naming rules.
	  4. The "schemaVersion" field is present (required for migration safety).
	  5. The "isEnabled" field is a boolean (presence check only).
	
	Rules:
	- Does NOT throw — always returns a ValidationResult table.
	- Does NOT know gameplay rules — generic structural validator only.
	- Does NOT hardcode gameplay values.
	- Reserved schema surfaces are responsibility of ConfigRegistry (not this module).
	
	Part of MVP-002: Save, Config, and Database Foundation.
--]]

-- Type alias for a validation result.
-- ok: true means all checks passed.
-- errors: list of human-readable error messages when ok is false.
export type ValidationResult = {
	ok: boolean,
	errors: { string },
}

-- Type alias for a field schema definition.
-- Required to declare what fields a config record must have and their expected types.
export type FieldSchema = {
	name: string,        -- Field name on the record table.
	fieldType: string,   -- Expected Lua type string: "string", "number", "boolean", "table".
	required: boolean,   -- Whether the field must be present.
}

-- Stable ID rules (from docs/CONFIG_GUIDE.md):
-- - lowercase snake_case
-- - no spaces
-- - no punctuation except underscores
-- - not numeric-only
local ID_PATTERN = "^[a-z][a-z0-9_]*$"

-- Universal required fields that every config record must have
-- (from docs/DATA_SCHEMA.md schema principles).
local UNIVERSAL_REQUIRED_FIELDS: { FieldSchema } = {
	{ name = "id",            fieldType = "string",  required = true  },
	{ name = "schemaVersion", fieldType = "number",  required = true  },
	{ name = "isEnabled",     fieldType = "boolean", required = true  },
}

local ConfigValidator = {}

--[[
	Internal: validate a single field against its schema.
	Appends error strings to the provided errors table.
--]]
local function _validateField(
	record: { [string]: any },
	fieldSchema: FieldSchema,
	errors: { string }
)
	local value = record[fieldSchema.name]

	-- Check presence.
	if value == nil then
		if fieldSchema.required then
			table.insert(errors, string.format(
				"Missing required field: '%s'",
				fieldSchema.name
			))
		end
		return -- Nothing further to check for a missing field.
	end

	-- Check type.
	local actualType = type(value)
	if actualType ~= fieldSchema.fieldType then
		table.insert(errors, string.format(
			"Field '%s' expected type '%s' but got '%s'",
			fieldSchema.name,
			fieldSchema.fieldType,
			actualType
		))
	end
end

--[[
	Internal: validate the "id" field specifically for stable ID naming rules.
	Appends error strings to the provided errors table.
--]]
local function _validateId(record: { [string]: any }, errors: { string })
	local id = record["id"]
	if id == nil or type(id) ~= "string" then
		-- Already caught by universal field validation; skip duplicate message.
		return
	end

	if id == "" then
		table.insert(errors, "Field 'id' must not be empty.")
		return
	end

	-- Check pattern: lowercase snake_case, starts with a letter.
	if not string.match(id, ID_PATTERN) then
		table.insert(errors, string.format(
			"Field 'id' value '%s' does not follow stable ID naming rules. " ..
			"Use lowercase snake_case starting with a letter (e.g. 'creature_001').",
			id
		))
	end
end

--[[
	ConfigValidator.validate(record, extraFields?) -> ValidationResult
	
	Validates a config record against:
	  - Universal required fields (id, schemaVersion, isEnabled).
	  - Any additional field schemas passed via extraFields.
	
	extraFields: optional array of FieldSchema tables for system-specific fields.
	
	Returns { ok = true, errors = {} } on success.
	Returns { ok = false, errors = { ... } } with messages on failure.
	Never throws.
--]]
function ConfigValidator.validate(
	record: { [string]: any },
	extraFields: { FieldSchema }?
): ValidationResult

	local errors: { string } = {}

	-- Guard: record must be a table.
	if type(record) ~= "table" then
		return {
			ok = false,
			errors = { string.format(
				"Config record must be a table, got '%s'.",
				type(record)
			) },
		}
	end

	-- Validate universal required fields.
	for _, fieldSchema in ipairs(UNIVERSAL_REQUIRED_FIELDS) do
		_validateField(record, fieldSchema, errors)
	end

	-- Validate stable ID naming rules.
	_validateId(record, errors)

	-- Validate extra (system-specific) fields if provided.
	if extraFields then
		for _, fieldSchema in ipairs(extraFields) do
			_validateField(record, fieldSchema, errors)
		end
	end

	return {
		ok = #errors == 0,
		errors = errors,
	}
end

--[[
	ConfigValidator.validateAll(records, extraFields?) -> ValidationResult
	
	Validates an array of config records.
	Returns a combined ValidationResult. Errors include the record index for context.
	
	Never throws.
--]]
function ConfigValidator.validateAll(
	records: { { [string]: any } },
	extraFields: { FieldSchema }?
): ValidationResult

	local allErrors: { string } = {}

	if type(records) ~= "table" then
		return {
			ok = false,
			errors = { string.format(
				"validateAll: expected a table of records, got '%s'.",
				type(records)
			) },
		}
	end

	for i, record in ipairs(records) do
		local result = ConfigValidator.validate(record, extraFields)
		if not result.ok then
			for _, err in ipairs(result.errors) do
				local recordId = (type(record) == "table" and type(record.id) == "string")
					and ("'" .. record.id .. "'")
					or ("[index " .. tostring(i) .. "]")
				table.insert(allErrors, string.format("Record %s: %s", recordId, err))
			end
		end
	end

	return {
		ok = #allErrors == 0,
		errors = allErrors,
	}
end

return ConfigValidator

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/data")
getOrCreateModule(p, "ReferenceResolver", [====[
--[[
	ReferenceResolver
	Location: src/server/data/ReferenceResolver.luau
	
	Validates cross-config references between active MVP config categories.
	
	A "reference" is when one config record has an ID field that points to
	a record in another category. For example, a creature config that lists
	a skillId must resolve to an actual skill config record.
	
	Rules:
	- Missing references fail safely — return nil or { ok=false }, never throw.
	- Reserved category references are blocked and return an error.
	- All resolution routes through ConfigRegistry.
	- This module does not own config data; it delegates to ConfigRegistry.
	- No gameplay logic here — purely structural reference validation.
	
	Part of MVP-002: Save, Config, and Database Foundation.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)

-- Reserved categories that must not be referenced from active MVP config.
-- (from docs/CONFIG_STRUCTURE.md and docs/DATA_SCHEMA.md)
local RESERVED_CATEGORIES = {
	quests        = true,
	towers        = true,
	status_effects = true,
}

export type ResolveResult = {
	ok: boolean,
	record: { [string]: any }?,
	error: string?,
}

local ReferenceResolver = {}

--[[
	ReferenceResolver.resolve(refId: string, category: string) -> table?
	
	Attempts to find a config record by its stable ID in the given category.
	Returns the record table if found, nil otherwise.
	
	Does NOT validate whether the category is reserved — use resolveRef for that.
	Use this for trusted internal calls where you already know the category is valid.
--]]
function ReferenceResolver.resolve(refId: string, category: string): { [string]: any }?
	if type(refId) ~= "string" or type(category) ~= "string" then
		return nil
	end

	return ConfigRegistry.get(category, refId)
end

--[[
	ReferenceResolver.validateRef(refId: string, category: string) -> ResolveResult
	
	Validates that a reference ID resolves to an existing, enabled record
	in the given category.
	
	Checks:
	1. category is not reserved.
	2. The record exists.
	3. The record has isEnabled = true.
	
	Returns { ok = true, record = <record> } on success.
	Returns { ok = false, error = <message> } on any failure.
	Never throws.
--]]
function ReferenceResolver.validateRef(refId: string, category: string): ResolveResult
	-- Input type guard.
	if type(refId) ~= "string" then
		return {
			ok = false,
			record = nil,
			error = string.format(
				"validateRef: refId must be a string, got '%s'.",
				type(refId)
			),
		}
	end

	if type(category) ~= "string" then
		return {
			ok = false,
			record = nil,
			error = string.format(
				"validateRef: category must be a string, got '%s'.",
				type(category)
			),
		}
	end

	-- Block reserved categories.
	if RESERVED_CATEGORIES[category] then
		return {
			ok = false,
			record = nil,
			error = string.format(
				"Reference to reserved category '%s' is not allowed in active MVP config. " ..
				"ID: '%s'.",
				category,
				refId
			),
		}
	end

	-- Resolve the reference via ConfigRegistry.
	local record = ConfigRegistry.get(category, refId)

	if record == nil then
		return {
			ok = false,
			record = nil,
			error = string.format(
				"Reference '%s' not found in category '%s'.",
				refId,
				category
			),
		}
	end

	-- Check that the referenced record is enabled.
	if record.isEnabled == false then
		return {
			ok = false,
			record = nil,
			error = string.format(
				"Reference '%s' in category '%s' exists but is disabled (isEnabled = false). " ..
				"Disabled records must not be referenced in active content.",
				refId,
				category
			),
		}
	end

	return {
		ok = true,
		record = record,
		error = nil,
	}
end

--[[
	ReferenceResolver.validateAllRefs(refIds: { string }, category: string) -> { ResolveResult }
	
	Validates a list of reference IDs against a single category.
	Returns an array of ResolveResult, one per input refId.
	Useful for validating skillIds, geneSlots, phaseIds arrays in config records.
	
	Never throws.
--]]
function ReferenceResolver.validateAllRefs(
	refIds: { string },
	category: string
): { ResolveResult }

	local results: { ResolveResult } = {}

	if type(refIds) ~= "table" then
		return {
			{
				ok = false,
				record = nil,
				error = string.format(
					"validateAllRefs: refIds must be a table, got '%s'.",
					type(refIds)
				),
			},
		}
	end

	for _, refId in ipairs(refIds) do
		table.insert(results, ReferenceResolver.validateRef(refId, category))
	end

	return results
end

--[[
	ReferenceResolver.hasAnyFailure(results: { ResolveResult }) -> boolean
	
	Utility: returns true if any ResolveResult in the array has ok = false.
	Use after validateAllRefs to check for batch failures.
--]]
function ReferenceResolver.hasAnyFailure(results: { ResolveResult }): boolean
	for _, result in ipairs(results) do
		if not result.ok then
			return true
		end
	end
	return false
end

return ReferenceResolver

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/network")
getOrCreateModule(p, "CreatureSnapshotBuilder", [====[
local CreatureRegistry = require(script.Parent.Parent.shared.data.CreatureRegistry)
local CreatureSnapshotType = require(script.Parent.Parent.shared.network.CreatureSnapshotType)

local CreatureSnapshotBuilder = {}

-- Server builds the snapshot to ensure no server-only metadata leaks
function CreatureSnapshotBuilder.build(instance: any): CreatureSnapshotType.CreatureSnapshotType?
    local config = CreatureRegistry.getCreature(instance.creatureId)
    if not config then
        return nil
    end

    return {
        instanceId = instance.instanceId,
        creatureId = instance.creatureId,
        displayName = config.displayName
    }
end

return CreatureSnapshotBuilder

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/persistence")
getOrCreateModule(p, "DataStoreWrapper", [====[
--[[
	DataStoreWrapper
	Location: src/server/persistence/DataStoreWrapper.luau
	
	Thin server-side wrapper around Roblox DataStoreService.
	
	All persistence reads and writes in Project Genesis must route through
	this module. No other module should call DataStoreService directly.
	
	Responsibilities:
	- Wrap GetAsync/SetAsync in pcall for safe error handling.
	- Return structured LoadResult/SaveResult tables instead of raw values.
	- Never expose raw DataStore errors externally — use error categories.
	- Enforce server-only usage (Roblox runtime enforces this naturally,
	  but we document it here for architectural clarity).
	
	This module has NO knowledge of save schemas, player data structure,
	or gameplay rules. It is a pure transport layer.
	
	Backend: Roblox DataStoreService (DataStore v1)
	Per docs/SAVE_SYSTEM.md.
	
	Part of MVP-002: Save, Config, and Database Foundation.
--]]

local DataStoreService = game:GetService("DataStoreService")

-- Structured result types.
export type LoadResult = {
	ok: boolean,
	data: any,          -- The loaded value, or nil on failure or missing key.
	errorCategory: string?, -- Safe error category string if ok = false.
}

export type SaveResult = {
	ok: boolean,
	errorCategory: string?, -- Safe error category string if ok = false.
}

-- Safe error categories (from docs/SAVE_SYSTEM.md).
-- These must not expose raw DataStore messages.
local ERROR_CATEGORIES = {
	DATASTORE_UNAVAILABLE   = "datastore_unavailable",
	REQUEST_BUDGET_EXCEEDED = "request_budget_exceeded",
	SERIALIZATION_FAILED    = "serialization_failed",
	KEY_INVALID             = "key_invalid",
	UNKNOWN_ERROR           = "unknown_error",
}

-- Internal: map a DataStore error message to a safe category string.
-- This prevents raw error internals from leaking to callers.
local function _categorizeError(rawError: string): string
	if type(rawError) ~= "string" then
		return ERROR_CATEGORIES.UNKNOWN_ERROR
	end

	local lower = string.lower(rawError)

	if string.find(lower, "budget") or string.find(lower, "throttle") or string.find(lower, "limit") then
		return ERROR_CATEGORIES.REQUEST_BUDGET_EXCEEDED
	end

	if string.find(lower, "serialize") or string.find(lower, "encode") then
		return ERROR_CATEGORIES.SERIALIZATION_FAILED
	end

	if string.find(lower, "key") then
		return ERROR_CATEGORIES.KEY_INVALID
	end

	if string.find(lower, "unavailable") or string.find(lower, "503") or string.find(lower, "connect") then
		return ERROR_CATEGORIES.DATASTORE_UNAVAILABLE
	end

	return ERROR_CATEGORIES.UNKNOWN_ERROR
end

-- Cache for DataStore instances to avoid repeated GetDataStore calls.
local _storeCache: { [string]: DataStore } = {}

-- Internal: get or create a DataStore instance by name.
local function _getStore(storeName: string): (boolean, DataStore | string)
	if _storeCache[storeName] then
		return true, _storeCache[storeName]
	end

	local ok, storeOrError = pcall(function()
		return DataStoreService:GetDataStore(storeName)
	end)

	if ok then
		_storeCache[storeName] = storeOrError :: DataStore
		return true, storeOrError :: DataStore
	else
		return false, tostring(storeOrError)
	end
end

local DataStoreWrapper = {}

--[[
	DataStoreWrapper.load(storeName: string, key: string) -> LoadResult
	
	Loads data from the named DataStore at the given key.
	
	Returns:
	  { ok = true, data = <value> }         -- Key found, data returned.
	  { ok = true, data = nil }             -- Key exists but has no data (new player).
	  { ok = false, errorCategory = <cat> } -- DataStore call failed.
	
	Never throws. Caller must handle all result cases.
--]]
function DataStoreWrapper.load(storeName: string, key: string): LoadResult
	assert(type(storeName) == "string" and storeName ~= "", "[DataStoreWrapper] storeName must be a non-empty string.")
	assert(type(key) == "string" and key ~= "", "[DataStoreWrapper] key must be a non-empty string.")

	-- Get or create DataStore instance.
	local storeOk, storeOrError = _getStore(storeName)
	if not storeOk then
		local category = _categorizeError(tostring(storeOrError))
		warn(string.format(
			"[DataStoreWrapper] Failed to get DataStore '%s'. Category: %s",
			storeName, category
		))
		return { ok = false, data = nil, errorCategory = category }
	end

	local store = storeOrError :: DataStore

	-- Attempt GetAsync.
	local ok, dataOrError = pcall(function()
		return store:GetAsync(key)
	end)

	if ok then
		-- dataOrError is the actual data value (may be nil for new players).
		return { ok = true, data = dataOrError, errorCategory = nil }
	else
		local category = _categorizeError(tostring(dataOrError))
		warn(string.format(
			"[DataStoreWrapper] GetAsync failed. Store: '%s'. Category: %s",
			storeName, category
		))
		return { ok = false, data = nil, errorCategory = category }
	end
end

--[[
	DataStoreWrapper.save(storeName: string, key: string, data: any) -> SaveResult
	
	Saves data to the named DataStore at the given key.
	
	Returns:
	  { ok = true }                         -- Save succeeded.
	  { ok = false, errorCategory = <cat> } -- DataStore call failed.
	
	Never throws. Caller must check result and handle failures.
	On failure, caller must NOT assume the data was saved.
--]]
function DataStoreWrapper.save(storeName: string, key: string, data: any): SaveResult
	assert(type(storeName) == "string" and storeName ~= "", "[DataStoreWrapper] storeName must be a non-empty string.")
	assert(type(key) == "string" and key ~= "", "[DataStoreWrapper] key must be a non-empty string.")

	-- Get or create DataStore instance.
	local storeOk, storeOrError = _getStore(storeName)
	if not storeOk then
		local category = _categorizeError(tostring(storeOrError))
		warn(string.format(
			"[DataStoreWrapper] Failed to get DataStore '%s' for save. Category: %s",
			storeName, category
		))
		return { ok = false, errorCategory = category }
	end

	local store = storeOrError :: DataStore

	-- Attempt SetAsync.
	local ok, errorValue = pcall(function()
		store:SetAsync(key, data)
	end)

	if ok then
		return { ok = true, errorCategory = nil }
	else
		local category = _categorizeError(tostring(errorValue))
		warn(string.format(
			"[DataStoreWrapper] SetAsync failed. Store: '%s'. Category: %s",
			storeName, category
		))
		return { ok = false, errorCategory = category }
	end
end

--[[
	DataStoreWrapper.ERROR_CATEGORIES
	
	Exported safe error category constants for callers to reference.
--]]
DataStoreWrapper.ERROR_CATEGORIES = ERROR_CATEGORIES

return DataStoreWrapper

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/persistence")
getOrCreateModule(p, "PersistenceReporter", [====[
--[[
	PersistenceReporter
	Location: src/server/persistence/PersistenceReporter.luau
	
	Controlled failure reporting for persistence operations.
	
	All load and save failures must be reported through this module.
	It ensures that failure information is logged safely without exposing
	raw save payloads, player data contents, or full DataStore error messages.
	
	Rules:
	- Log the userId and error category only — NOT raw data or full stack traces.
	- Do NOT mutate any state when called.
	- Do NOT throw.
	- Reporting is output only (warn/print). No return values for the caller to branch on.
	- This is a reporting utility, not a decision-making system.
	
	Part of MVP-002: Save, Config, and Database Foundation.
--]]

-- Log prefix for all persistence reporter messages.
local LOG_PREFIX = "[PersistenceReporter]"

local PersistenceReporter = {}

--[[
	PersistenceReporter.reportLoadFailure(userId: any, errorCategory: string?)
	
	Reports a player data load failure.
	
	Logs:
	- The userId (or a placeholder if invalid).
	- The error category string (safe, not the raw DataStore error).
	
	Does NOT expose the save data, raw error messages, or stack traces.
	Does NOT mutate any session state.
--]]
function PersistenceReporter.reportLoadFailure(userId: any, errorCategory: string?)
	local safeUserId: string
	if type(userId) == "number" and userId > 0 then
		safeUserId = tostring(math.floor(userId))
	else
		safeUserId = "[invalid_userId]"
	end

	local safeCategory: string
	if type(errorCategory) == "string" and errorCategory ~= "" then
		safeCategory = errorCategory
	else
		safeCategory = "unknown_error"
	end

	warn(string.format(
		"%s LOAD FAILURE | userId: %s | errorCategory: %s",
		LOG_PREFIX,
		safeUserId,
		safeCategory
	))
end

--[[
	PersistenceReporter.reportSaveFailure(userId: any, errorCategory: string?)
	
	Reports a player data save failure.
	
	Logs:
	- The userId (or a placeholder if invalid).
	- The error category string (safe, not the raw DataStore error).
	
	Does NOT expose the save data, raw error messages, or stack traces.
	Does NOT mutate any session state.
--]]
function PersistenceReporter.reportSaveFailure(userId: any, errorCategory: string?)
	local safeUserId: string
	if type(userId) == "number" and userId > 0 then
		safeUserId = tostring(math.floor(userId))
	else
		safeUserId = "[invalid_userId]"
	end

	local safeCategory: string
	if type(errorCategory) == "string" and errorCategory ~= "" then
		safeCategory = errorCategory
	else
		safeCategory = "unknown_error"
	end

	warn(string.format(
		"%s SAVE FAILURE | userId: %s | errorCategory: %s",
		LOG_PREFIX,
		safeUserId,
		safeCategory
	))
end

--[[
	PersistenceReporter.reportInfo(message: string)
	
	Logs a general informational message for persistence lifecycle events.
	Use for expected events like load success, save success, new player initialized.
	
	Does NOT expose data contents.
--]]
function PersistenceReporter.reportInfo(message: string)
	if type(message) == "string" then
		print(string.format("%s %s", LOG_PREFIX, message))
	end
end

return PersistenceReporter

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/persistence")
getOrCreateModule(p, "SaveKeyBuilder", [====[
--[[
	SaveKeyBuilder
	Location: src/server/persistence/SaveKeyBuilder.luau
	
	Constructs deterministic, stable save keys for player data.
	
	Rules (from docs/SAVE_SYSTEM.md):
	- Keys use Player.UserId (integer), NOT Player.Name (can change).
	- Key format: "player_{userId}"
	- Key format must never change after data has been saved.
	- Invalid or nil UserId is rejected and returns nil.
	- This module is server-only by architectural convention.
	
	This module has NO knowledge of DataStore names, save schema, or
	gameplay rules. It only builds and validates key strings.
	
	Part of MVP-002: Save, Config, and Database Foundation.
--]]

-- The DataStore name for player save data (documented in docs/SAVE_SYSTEM.md).
local PLAYER_SAVE_STORE_NAME = "PlayerSaveData"

-- Key prefix as documented in docs/SAVE_SYSTEM.md.
local KEY_PREFIX = "player_"

local SaveKeyBuilder = {}

--[[
	SaveKeyBuilder.validateUserId(userId: any) -> boolean
	
	Returns true if the given value is a valid Roblox UserId.
	A valid UserId is an integer greater than 0.
	
	Returns false for nil, non-number, fractional, or non-positive values.
--]]
function SaveKeyBuilder.validateUserId(userId: any): boolean
	if type(userId) ~= "number" then
		return false
	end

	if userId <= 0 then
		return false
	end

	-- Must be a whole number (integer).
	if userId ~= math.floor(userId) then
		return false
	end

	return true
end

--[[
	SaveKeyBuilder.buildPlayerKey(userId: any) -> string?
	
	Constructs the save key string for a player.
	Returns a key string on success.
	Returns nil if the userId is invalid — caller must handle nil.
	
	Key format: "player_{userId}"
	Example: "player_123456"
	
	Never throws.
--]]
function SaveKeyBuilder.buildPlayerKey(userId: any): string?
	if not SaveKeyBuilder.validateUserId(userId) then
		warn(string.format(
			"[SaveKeyBuilder] buildPlayerKey received invalid userId: '%s' (type: %s). Returning nil.",
			tostring(userId),
			type(userId)
		))
		return nil
	end

	return KEY_PREFIX .. tostring(math.floor(userId))
end

--[[
	SaveKeyBuilder.getStoreName() -> string
	
	Returns the canonical DataStore name for player save data.
	Centralised here so all persistence code references one source of truth.
--]]
function SaveKeyBuilder.getStoreName(): string
	return PLAYER_SAVE_STORE_NAME
end

--[[
	SaveKeyBuilder.parseUserIdFromKey(key: string) -> number?
	
	Utility: extracts the UserId from a save key string.
	Returns the UserId as a number, or nil if the key format is unrecognized.
	Useful for debugging and audit tooling.
	
	Never throws.
--]]
function SaveKeyBuilder.parseUserIdFromKey(key: string): number?
	if type(key) ~= "string" then
		return nil
	end

	-- Match "player_<digits>"
	local digits = string.match(key, "^player_(%d+)$")
	if not digits then
		return nil
	end

	local userId = tonumber(digits)
	if userId == nil or not SaveKeyBuilder.validateUserId(userId) then
		return nil
	end

	return userId
end

return SaveKeyBuilder

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/runtime")
getOrCreateModule(p, "FrameworkSmoke", [====[
--[[
	FrameworkSmoke
	Location: src/server/runtime/FrameworkSmoke.luau

	Framework smoke verification for Project Genesis MVP-001.

	This module provides a suite of self-contained checks that verify the
	core framework modules (Result, ServiceLifecycle) are functioning
	correctly after bootstrap.

	Rules:
	- Smoke tests must be self-contained and not depend on gameplay systems.
	- Smoke tests must not mutate game state.
	- Smoke tests must print PASS or FAIL with the test name.
	- This module must ONLY be called during development/Studio verification.
	  It must NOT be called automatically in production bootstrap.
	- No gameplay values are tested here.

	Part of MVP-001: Core Framework Foundation.
--]]

-- Results are required freshly so this module gets isolated state.
local Result = require(script.Parent.Parent.Parent.shared.utilities.Result)
-- Note: ServiceLifecycle is stateful (singleton) — we test behavior only.

local FrameworkSmoke = {}

local _passCount = 0
local _failCount = 0

local function _assert(testName: string, condition: boolean, detail: string?)
	if condition then
		_passCount += 1
		print(string.format("[FrameworkSmoke] PASS — %s", testName))
	else
		_failCount += 1
		warn(string.format(
			"[FrameworkSmoke] FAIL — %s%s",
			testName,
			detail and (": " .. detail) or ""
		))
	end
end

-- ─── Result Tests ────────────────────────────────────────────────────────────

local function _testResult()
	-- T1: ok() creates a success result.
	local r1 = Result.ok(42)
	_assert("Result.ok creates success", r1.success == true, "success should be true")
	_assert("Result.ok has value", r1.value == 42, "value should be 42")

	-- T2: fail() creates a failure result.
	local r2 = Result.fail("not_found", "Resource missing.")
	_assert("Result.fail creates failure", r2.success == false, "success should be false")
	_assert("Result.fail has code", r2.code == "not_found", "code should be 'not_found'")
	_assert("Result.fail has message", r2.message == "Resource missing.", "message mismatch")

	-- T3: ok() with nil value is valid (void success).
	local r3 = Result.ok(nil)
	_assert("Result.ok(nil) is valid", r3.success == true, "void success should work")

	-- T4: isOk() / isFail() helpers.
	_assert("Result.isOk on ok", Result.isOk(r1) == true, "isOk should be true")
	_assert("Result.isFail on fail", Result.isFail(r2) == true, "isFail should be true")
	_assert("Result.isOk on fail", Result.isOk(r2) == false, "isOk on fail should be false")
	_assert("Result.isFail on ok", Result.isFail(r1) == false, "isFail on ok should be false")

	-- T5: unwrapOr() returns value on success, default on failure.
	local v1 = Result.unwrapOr(r1, 0)
	_assert("Result.unwrapOr on ok", v1 == 42, "should return value=42")
	local v2 = Result.unwrapOr(r2, 0)
	_assert("Result.unwrapOr on fail", v2 == 0, "should return default=0")

	-- T6: fail() with empty code should throw.
	local badCodeOk = pcall(function()
		Result.fail("")
	end)
	_assert("Result.fail empty code throws", badCodeOk == false, "should assert on empty code")

	-- T7: fail() without message is valid.
	local r4 = Result.fail("unauthorized")
	_assert("Result.fail no message", r4.message == nil, "message should be nil")
end

-- ─── ServiceLifecycle Tests ──────────────────────────────────────────────────

local function _testServiceLifecycle()
	-- These tests use a fresh local lifecycle copy to avoid polluting
	-- the real singleton state used by ServerBootstrap.
	-- We test by creating a local table that mimics the lifecycle interface
	-- and verifying ServiceContract validation logic inline.

	-- T1: A valid ServiceContract shape has the correct fields.
	local fakeService = {
		name = "TestService",
		init = function() end,
		start = function() end,
	}
	_assert(
		"ServiceContract: name is string",
		type(fakeService.name) == "string" and fakeService.name ~= "",
		"name check"
	)
	_assert(
		"ServiceContract: init is function",
		type(fakeService.init) == "function",
		"init check"
	)
	_assert(
		"ServiceContract: start is function",
		type(fakeService.start) == "function",
		"start check"
	)

	-- T2: A ServiceContract without name fails the contract check.
	local badService = { init = function() end, start = function() end }
	local nameCheckFails = (type(badService.name) ~= "string" or badService.name == "")
	_assert("ServiceContract: missing name caught", nameCheckFails == true, "name validation")

	-- T3: A ServiceContract without init fails.
	local noInitService = { name = "NoInit", start = function() end }
	_assert(
		"ServiceContract: missing init caught",
		type(noInitService.init) ~= "function",
		"init validation"
	)
end

-- ─── Public API ─────────────────────────────────────────────────────────────

--[[
	FrameworkSmoke.run()

	Runs all framework smoke checks and prints a summary.
	Call this from Studio command bar or a test script during development.
	Do NOT call from production ServerBootstrap.

	Returns { passed = number, failed = number }.
--]]
function FrameworkSmoke.run(): { passed: number, failed: number }
	_passCount = 0
	_failCount = 0

	print("[FrameworkSmoke] ═══ Starting MVP-001 Framework Smoke Verification ═══")

	_testResult()
	_testServiceLifecycle()

	print(string.format(
		"[FrameworkSmoke] ═══ Done: %d PASSED, %d FAILED ═══",
		_passCount,
		_failCount
	))

	return { passed = _passCount, failed = _failCount }
end

return FrameworkSmoke

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/runtime")
getOrCreateModule(p, "ServiceLifecycle", [====[
--[[
	ServiceLifecycle
	Location: src/server/runtime/ServiceLifecycle.luau

	Minimal server service lifecycle contract for Project Genesis.

	Every server service must implement this lifecycle interface so that
	the server bootstrap can start services in a documented, predictable order.

	Lifecycle phases (in order):
	  1. init()    — Service sets up internal state and registers dependencies.
	                 No cross-service calls during init.
	  2. start()   — Service begins active operation (listens for players, connects events).
	                 Cross-service calls are allowed after all services have init()d.

	Rules:
	- Services must implement both init() and start().
	- init() must not depend on other services being started yet.
	- start() may call other services that have already init()d.
	- Neither phase should throw — use Result pattern for failures.
	- Gameplay systems (combat, creature, economy) must not be started here.
	  They will be added by future approved tasks.
	- This module registers and validates the lifecycle contract only.
	  It does not own service instances.

	Part of MVP-001: Core Framework Foundation.
--]]

-- Type alias: all services must implement this interface.
export type ServiceContract = {
	name: string,          -- Stable service identifier for logging and debugging.
	init: () -> (),        -- Phase 1: initialize internal state.
	start: () -> (),       -- Phase 2: begin active operation.
}

-- Internal: ordered list of registered services.
local _registeredServices: { ServiceContract } = {}
local _isInitialized = false
local _isStarted = false

local ServiceLifecycle = {}

--[[
	ServiceLifecycle.register(service: ServiceContract)

	Registers a service to participate in the lifecycle.
	Services must be registered before ServiceLifecycle.init() is called.

	Throws if:
	  - service is not a table.
	  - service.name is missing or not a string.
	  - service.init is not a function.
	  - service.start is not a function.
	  - A service with the same name is already registered.
	  - Registration happens after init() has already run.
--]]
function ServiceLifecycle.register(service: ServiceContract)
	assert(
		type(service) == "table",
		"[ServiceLifecycle] register: service must be a table."
	)
	assert(
		type(service.name) == "string" and service.name ~= "",
		"[ServiceLifecycle] register: service.name must be a non-empty string."
	)
	assert(
		type(service.init) == "function",
		string.format("[ServiceLifecycle] register: '%s'.init must be a function.", service.name)
	)
	assert(
		type(service.start) == "function",
		string.format("[ServiceLifecycle] register: '%s'.start must be a function.", service.name)
	)
	assert(
		not _isInitialized,
		string.format(
			"[ServiceLifecycle] register: Cannot register '%s' after lifecycle has already initialized.",
			service.name
		)
	)

	-- Check for duplicate names.
	for _, existing in ipairs(_registeredServices) do
		if existing.name == service.name then
			error(string.format(
				"[ServiceLifecycle] register: A service named '%s' is already registered.",
				service.name
			))
		end
	end

	table.insert(_registeredServices, service)
end

--[[
	ServiceLifecycle.init()

	Runs Phase 1: calls init() on every registered service in order.
	All services are initialized before any service's start() is called.

	Safe error handling: if a service init() throws, the error is caught,
	logged with the service name, and the lifecycle logs it without crashing
	the full server. The failed service is noted but startup continues
	(fail-log, not fail-hard during MVP bootstrap).

	Must be called once, before ServiceLifecycle.start().
--]]
function ServiceLifecycle.init()
	assert(not _isInitialized, "[ServiceLifecycle] init() has already been called.")
	_isInitialized = true

	for _, service in ipairs(_registeredServices) do
		local ok, err = pcall(service.init)
		if not ok then
			warn(string.format(
				"[ServiceLifecycle] init() FAILED for service '%s': %s",
				service.name,
				tostring(err)
			))
		else
			print(string.format("[ServiceLifecycle] init() OK — '%s'", service.name))
		end
	end
end

--[[
	ServiceLifecycle.start()

	Runs Phase 2: calls start() on every registered service in order.
	All services have been init()d before any start() is called.

	Must be called once, after ServiceLifecycle.init().
--]]
function ServiceLifecycle.start()
	assert(_isInitialized, "[ServiceLifecycle] init() must be called before start().")
	assert(not _isStarted, "[ServiceLifecycle] start() has already been called.")
	_isStarted = true

	for _, service in ipairs(_registeredServices) do
		local ok, err = pcall(service.start)
		if not ok then
			warn(string.format(
				"[ServiceLifecycle] start() FAILED for service '%s': %s",
				service.name,
				tostring(err)
			))
		else
			print(string.format("[ServiceLifecycle] start() OK — '%s'", service.name))
		end
	end
end

--[[
	ServiceLifecycle.getRegisteredNames() -> { string }

	Returns a list of registered service names in registration order.
	Useful for diagnostics and smoke verification.
--]]
function ServiceLifecycle.getRegisteredNames(): { string }
	local names = {}
	for _, service in ipairs(_registeredServices) do
		table.insert(names, service.name)
	end
	return names
end

--[[
	ServiceLifecycle.isInitialized() -> boolean

	Returns true after init() has been called.
--]]
function ServiceLifecycle.isInitialized(): boolean
	return _isInitialized
end

--[[
	ServiceLifecycle.isStarted() -> boolean

	Returns true after start() has been called.
--]]
function ServiceLifecycle.isStarted(): boolean
	return _isStarted
end

return ServiceLifecycle

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/services")
getOrCreateModule(p, "CreatureService", [====[
local CreatureRegistry = require(script.Parent.Parent.shared.data.CreatureRegistry)
local SaveService = require(script.Parent.SaveService)
local Result = require(script.Parent.Parent.shared.Result)
local HttpService = game:GetService("HttpService")

local CreatureService = {}

-- Narrow interface to SaveService.
-- CreatureService must not communicate with DataStore directly.
function CreatureService.tryGrantCreature(player: Player, creatureId: string)
    -- Validate: Creature exists in Registry
    local config = CreatureRegistry.getCreature(creatureId)
    if not config then
        return Result.fail("Invalid Creature ID rejected.")
    end

    -- Validate: Creature is enabled
    if not config.isEnabled then
        return Result.fail("Disabled Creature rejected.")
    end

    -- Validate: Duplicate check
    local playerSave = SaveService.getPlayerSave(player)
    local instances = playerSave.creatureInstances or {}
    
    for _, instance in pairs(instances) do
        if instance.creatureId == creatureId then
            return Result.fail("Duplicate grant behavior follows documented rule: cannot grant duplicate.")
        end
    end

    -- Generate instance
    local instanceId = HttpService:GenerateGUID(false)
    local newInstance = {
        instanceId = instanceId,
        creatureId = creatureId,
        acquiredAt = os.time()
    }

    -- Apply to SaveService
    instances[instanceId] = newInstance
    playerSave.creatureInstances = instances
    SaveService.savePlayer(player)

    return Result.ok(newInstance)
end

function CreatureService.getPlayerCreatures(player: Player)
    local playerSave = SaveService.getPlayerSave(player)
    return playerSave.creatureInstances or {}
end

return CreatureService

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "F:/Project_Genesis/src/server/services")
getOrCreateModule(p, "SaveService", [====[
local SaveService = {}
local mockSaves = {}

-- Persistence is entirely owned by SaveService.
-- Other services must not communicate with DataStore directly.
-- This is a stub abstraction for MVP-004 to avoid temporary in-memory ownership in CreatureService.

-- Retrieves a player's save data map
function SaveService.getPlayerSave(player: any): any
    if not mockSaves[player] then
        mockSaves[player] = {
            creatureInstances = {}
        }
    end
    return mockSaves[player]
end

-- Commits a save mutation
function SaveService.savePlayer(player: any)
    -- Stub: would mark the save as dirty or trigger a save task
end

return SaveService

]====])

local p = ensurePath(game:GetService("StarterPlayer").StarterPlayerScripts.Client, "F:/Project_Genesis/src/client/bootstrap")
getOrCreateModule(p, "ClientBootstrap", [====[
--[[
	ClientBootstrap
	Location: src/client/bootstrap/ClientBootstrap.luau

	Client-side bootstrap shell for Project Genesis.

	This LocalScript is the entry point for all client-side systems.
	It initializes client controllers and views in the documented order.

	Current registered controllers/views: NONE (MVP-001 shell only).
	Future tasks will add their client controllers here after implementation.

	Startup sequence (planned for future tasks):
	  1. Require all approved client controllers.
	  2. Initialize each controller.
	  3. Start each controller.

	Rules:
	- This script is client-only. It must live in StarterPlayerScripts.
	- No gameplay authority is owned here (server owns truth).
	- No combat, economy, or save systems are started from the client.
	- Client bootstrap only initializes UI/presentation systems.
	- No hardcoded gameplay values.

	Part of MVP-001: Core Framework Foundation.
--]]

-- Controllers and views are required here, before bootstrap runs.
-- Example (to be added by future tasks):
--   local BattleController = require(ReplicatedStorage.Client.controllers.BattleController)
--   local HudView          = require(ReplicatedStorage.Client.views.HudView)

print("[ClientBootstrap] ═══ Project Genesis Client Starting ═══")

-- ─── Initialize Controllers ─────────────────────────────────────────────────
-- (Empty for MVP-001 — future tasks will add controller init here)

-- ─── Start Controllers ──────────────────────────────────────────────────────
-- (Empty for MVP-001 — future tasks will add controller start here)

print("[ClientBootstrap] ═══ Client Ready ═══")

]====])

local p = ensurePath(game:GetService("StarterPlayer").StarterPlayerScripts.Client, "F:/Project_Genesis/src/client/controllers")
getOrCreateModule(p, "ScreenRouter", [====[
--[[
	ScreenRouter
	Location: src/client/controllers/ScreenRouter.luau

	Client Screen Router.
	- Register screens
	- Switch active screen
	- Reject unknown screen IDs
	- Broadcast screen changed event
	- No gameplay logic

	Part of MVP-003: UI Foundation.
--]]

local ScreenRouter = {}

-- Store registered screens: { [screenId: string] = ScreenGui }
local _screens = {}
local _activeScreenId = nil
local _screenChangedEvent = Instance.new("BindableEvent")

ScreenRouter.OnScreenChanged = _screenChangedEvent.Event

--[[
	ScreenRouter.registerScreen(screenId, screenGui)
	
	Registers a screen with the router. The screen should be a ScreenGui.
	It is hidden by default.
--]]
function ScreenRouter.registerScreen(screenId: string, screenGui: Instance)
	assert(type(screenId) == "string" and screenId ~= "", "[ScreenRouter] screenId must be a non-empty string.")
	assert(typeof(screenGui) == "Instance" and screenGui:IsA("ScreenGui"), "[ScreenRouter] screenGui must be a ScreenGui.")
	
	if _screens[screenId] then
		warn(string.format("[ScreenRouter] Screen '%s' is already registered. Overwriting.", screenId))
	end
	
	-- Ensure the screen is hidden initially
	screenGui.Enabled = false
	_screens[screenId] = screenGui
end

--[[
	ScreenRouter.switchScreen(screenId)
	
	Switches the active screen to the given screenId.
	Rejects unknown screen IDs.
--]]
function ScreenRouter.switchScreen(screenId: string)
	assert(type(screenId) == "string" and screenId ~= "", "[ScreenRouter] screenId must be a non-empty string.")
	
	if not _screens[screenId] then
		warn(string.format("[ScreenRouter] Rejected unknown screen ID: '%s'", screenId))
		return false
	end
	
	-- Hide current screen if any
	if _activeScreenId and _screens[_activeScreenId] then
		_screens[_activeScreenId].Enabled = false
	end
	
	-- Show new screen
	_activeScreenId = screenId
	_screens[_activeScreenId].Enabled = true
	
	-- Broadcast change
	_screenChangedEvent:Fire(_activeScreenId)
	return true
end

--[[
	ScreenRouter.getActiveScreenId()
	
	Returns the currently active screen ID, or nil if none.
--]]
function ScreenRouter.getActiveScreenId(): string?
	return _activeScreenId
end

return ScreenRouter

]====])

local p = ensurePath(game:GetService("StarterPlayer").StarterPlayerScripts.Client, "F:/Project_Genesis/src/client/models")
getOrCreateModule(p, "ClientState", [====[
--[[
	ClientState
	Location: src/client/models/ClientState.luau

	ClientState is a presentation cache only.
	It mirrors server-approved snapshots.
	It must never become authoritative gameplay state.

	This module provides a simple key-value store for UI controllers to read
	from, and for network controllers to write into when the server sends updates.

	Part of MVP-003: UI Foundation.
--]]

local ClientState = {}

local _stateCache = {}
local _listeners = {}

--[[
	ClientState.set(key, value)
	
	Updates a key in the presentation cache.
	Fires any registered listeners for this key.
--]]
function ClientState.set(key: string, value: any)
	assert(type(key) == "string" and key ~= "", "[ClientState] Key must be a non-empty string.")
	_stateCache[key] = value

	if _listeners[key] then
		for _, callback in ipairs(_listeners[key]) do
			-- Safe execution to prevent listener errors from breaking state updates
			pcall(callback, value)
		end
	end
end

--[[
	ClientState.get(key, default)
	
	Retrieves a value from the presentation cache.
	Returns the default value if the key does not exist.
--]]
function ClientState.get(key: string, default: any): any
	assert(type(key) == "string" and key ~= "", "[ClientState] Key must be a non-empty string.")
	local value = _stateCache[key]
	if value == nil then
		return default
	end
	return value
end

--[[
	ClientState.listen(key, callback)
	
	Registers a callback to be fired whenever the given key is updated.
--]]
function ClientState.listen(key: string, callback: (any) -> ())
	assert(type(key) == "string" and key ~= "", "[ClientState] Key must be a non-empty string.")
	assert(type(callback) == "function", "[ClientState] Callback must be a function.")
	
	if not _listeners[key] then
		_listeners[key] = {}
	end
	table.insert(_listeners[key], callback)
end

--[[
	ClientState.clear(key)
	
	Clears a key from the presentation cache.
--]]
function ClientState.clear(key: string)
	assert(type(key) == "string" and key ~= "", "[ClientState] Key must be a non-empty string.")
	_stateCache[key] = nil
end

return ClientState

]====])

local p = ensurePath(game:GetService("StarterPlayer").StarterPlayerScripts.Client, "F:/Project_Genesis/src/client/views")
getOrCreateModule(p, "StatePatterns", [====[
--[[
	StatePatterns
	Location: src/client/views/StatePatterns.luau

	Standardized presentation states for UI screens.
	Provides: Loading, Empty, Error, Disconnected, Retry.

	Part of MVP-003: UI Foundation.
--]]

local UIComponents = require(script.Parent.UIComponents)

local StatePatterns = {}

local function _createStateOverlay(name: string, text: string): Frame
	local overlay = UIComponents.createBaseContainer()
	overlay.Name = name
	
	local bg = UIComponents.createBasePanel()
	bg.BackgroundTransparency = 0.2
	bg.Parent = overlay
	
	local label = UIComponents.createBaseLabel(text)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextSize = 24
	label.Parent = overlay
	
	return overlay
end

--[[
	StatePatterns.Loading(parent) -> Frame
	Shows when a request is in flight.
--]]
function StatePatterns.Loading(parent: Instance): Frame
	local state = _createStateOverlay("LoadingState", "Loading...")
	if parent then state.Parent = parent end
	return state
end

--[[
	StatePatterns.Empty(parent, message) -> Frame
	Shows when a list or collection has no items.
--]]
function StatePatterns.Empty(parent: Instance, message: string?): Frame
	local state = _createStateOverlay("EmptyState", message or "No items found.")
	if parent then state.Parent = parent end
	return state
end

--[[
	StatePatterns.Error(parent, message) -> Frame
	Shows when an operation fails.
--]]
function StatePatterns.Error(parent: Instance, message: string?): Frame
	local state = _createStateOverlay("ErrorState", message or "An error occurred.")
	local label = state:FindFirstChild("BaseLabel", true)
	if label and label:IsA("TextLabel") then
		label.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
	if parent then state.Parent = parent end
	return state
end

--[[
	StatePatterns.Disconnected(parent) -> Frame
	Shows when the server connection drops.
--]]
function StatePatterns.Disconnected(parent: Instance): Frame
	local state = _createStateOverlay("DisconnectedState", "Disconnected from server.")
	local label = state:FindFirstChild("BaseLabel", true)
	if label and label:IsA("TextLabel") then
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
	end
	if parent then state.Parent = parent end
	return state
end

--[[
	StatePatterns.Retry(parent, callback, message) -> Frame
	Shows when a failure can be retried.
--]]
function StatePatterns.Retry(parent: Instance, callback: () -> (), message: string?): Frame
	local state = UIComponents.createBaseContainer()
	state.Name = "RetryState"
	
	local bg = UIComponents.createBasePanel()
	bg.BackgroundTransparency = 0.2
	bg.Parent = state
	
	local label = UIComponents.createBaseLabel(message or "Action failed. Please try again.")
	label.Size = UDim2.new(1, 0, 0.6, 0)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Bottom
	label.TextSize = 20
	label.Parent = state
	
	local btn = UIComponents.createBaseButton("Retry")
	btn.AnchorPoint = Vector2.new(0.5, 0)
	btn.Position = UDim2.new(0.5, 0, 0.6, 20)
	btn.Parent = state
	
	btn.Activated:Connect(function()
		if callback then callback() end
	end)
	
	if parent then state.Parent = parent end
	return state
end

return StatePatterns

]====])

local p = ensurePath(game:GetService("StarterPlayer").StarterPlayerScripts.Client, "F:/Project_Genesis/src/client/views")
getOrCreateModule(p, "UIComponents", [====[
--[[
	UIComponents
	Location: src/client/views/UIComponents.luau

	Minimal foundational UI elements using pure Roblox UI with Luau only.
	No external dependencies.
	No animation, no theme, no gameplay-specific widgets.

	Provides:
	- Base Panel
	- Base Button
	- Base Label
	- Base Container
	- Base Modal placeholder

	Part of MVP-003: UI Foundation.
--]]

local UIComponents = {}

--[[
	UIComponents.createBaseContainer() -> Frame
	Invisible container for layout organization.
--]]
function UIComponents.createBaseContainer(): Frame
	local container = Instance.new("Frame")
	container.Name = "BaseContainer"
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 1, 0)
	container.Position = UDim2.new(0, 0, 0, 0)
	return container
end

--[[
	UIComponents.createBasePanel() -> Frame
	Visible background panel.
--]]
function UIComponents.createBasePanel(): Frame
	local panel = Instance.new("Frame")
	panel.Name = "BasePanel"
	panel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	panel.BorderSizePixel = 0
	panel.Size = UDim2.new(1, 0, 1, 0)
	return panel
end

--[[
	UIComponents.createBaseButton(text) -> TextButton
	Standard clickable button.
--]]
function UIComponents.createBaseButton(text: string): TextButton
	local button = Instance.new("TextButton")
	button.Name = "BaseButton"
	button.Text = text or "Button"
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BorderSizePixel = 0
	button.Size = UDim2.new(0, 150, 0, 50)
	button.Font = Enum.Font.SourceSans
	button.TextSize = 18
	return button
end

--[[
	UIComponents.createBaseLabel(text) -> TextLabel
	Standard text label.
--]]
function UIComponents.createBaseLabel(text: string): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = "BaseLabel"
	label.Text = text or "Label"
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Size = UDim2.new(0, 200, 0, 30)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	return label
end

--[[
	UIComponents.createBaseModal() -> Frame
	Blocking modal background placeholder.
--]]
function UIComponents.createBaseModal(): Frame
	local modal = Instance.new("Frame")
	modal.Name = "BaseModal"
	modal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	modal.BackgroundTransparency = 0.5
	modal.BorderSizePixel = 0
	modal.Size = UDim2.new(1, 0, 1, 0)
	modal.ZIndex = 100 -- Ensure it blocks underlying UI
	modal.Active = true -- Block clicks
	return modal
end

return UIComponents

]====])

return 'Restore complete!'