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
local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
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

local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
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

local p = ensurePath(game:GetService("ServerScriptService").Server, "network")
getOrCreateModule(p, "CreatureSnapshotBuilder", [====[
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Shared.data.CreatureRegistry)
local CreatureSnapshotType = require(game:GetService("ReplicatedStorage").Shared.network.CreatureSnapshotType)

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

return 'Restore chunk 2 complete!'