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
getOrCreateModule(p, "EconomyRegistry", [====[
--[[
	EconomyRegistry
	Location: src/server/data/EconomyRegistry.luau

	Loads currency configs via ConfigRegistry, validates each with EconomySchema,
	indexes by currencyId.

	Rules:
	- Static definitions only. No player state.
	- Loads from ServerStorage.Configs.economy via ConfigRegistry.
	- Invalid configs are rejected and logged, never silently accepted.

	Part of MVP-005: Bio Generator and Economy Foundation.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)
local EconomySchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.EconomySchema)

local EconomyRegistry = {}

local _registry: { [string]: any } = {}
local _initialized = false

--[[
	EconomyRegistry.init()

	Loads all economy configs, validates each, and indexes by currencyId.
	Must be called once during server bootstrap before any service uses currencies.
--]]
function EconomyRegistry.init()
	if _initialized then
		warn("[EconomyRegistry] Already initialized. Skipping.")
		return
	end

	local records = ConfigRegistry.load("economy")

	for _, record in ipairs(records) do
		local result = EconomySchema.validate(record)
		if result.success then
			local currencyId = result.value.currencyId
			if _registry[currencyId] then
				warn(string.format(
					"[EconomyRegistry] Duplicate currencyId '%s' — skipping.",
					currencyId
				))
			else
				_registry[currencyId] = result.value
				print(string.format("[EconomyRegistry] Loaded currency: '%s'", currencyId))
			end
		else
			warn(string.format(
				"[EconomyRegistry] Config validation failed: %s — %s",
				tostring(record.id or "unknown"),
				result.message or result.code
			))
		end
	end

	_initialized = true
end

--[[
	EconomyRegistry.getCurrency(currencyId) -> config?

	Returns the validated config for a currencyId, or nil if not found.
--]]
function EconomyRegistry.getCurrency(currencyId: string): any
	return _registry[currencyId]
end

--[[
	EconomyRegistry.getAllCurrencies() -> { config }

	Returns a list of all loaded currency configs.
--]]
function EconomyRegistry.getAllCurrencies(): { any }
	local list = {}
	for _, config in pairs(_registry) do
		table.insert(list, config)
	end
	return list
end

--[[
	EconomyRegistry.isInitialized() -> boolean
--]]
function EconomyRegistry.isInitialized(): boolean
	return _initialized
end

return EconomyRegistry

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
getOrCreateModule(p, "EquipmentRegistry", [====[
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

]====])

return 'Restore chunk 2 complete!'