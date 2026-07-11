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
	name: string, -- Field name on the record table.
	fieldType: string, -- Expected Lua type string: "string", "number", "boolean", "table".
	required: boolean, -- Whether the field must be present.
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
	{ name = "id", fieldType = "string", required = true },
	{ name = "schemaVersion", fieldType = "number", required = true },
	{ name = "isEnabled", fieldType = "boolean", required = true },
}

local ConfigValidator = {}

--[[
	Internal: validate a single field against its schema.
	Appends error strings to the provided errors table.
--]]
local function _validateField(record: { [string]: any }, fieldSchema: FieldSchema, errors: { string })
	local value = record[fieldSchema.name]

	-- Check presence.
	if value == nil then
		if fieldSchema.required then
			table.insert(errors, string.format("Missing required field: '%s'", fieldSchema.name))
		end
		return -- Nothing further to check for a missing field.
	end

	-- Check type.
	local actualType = type(value)
	if actualType ~= fieldSchema.fieldType then
		table.insert(
			errors,
			string.format(
				"Field '%s' expected type '%s' but got '%s'",
				fieldSchema.name,
				fieldSchema.fieldType,
				actualType
			)
		)
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
		table.insert(
			errors,
			string.format(
				"Field 'id' value '%s' does not follow stable ID naming rules. "
					.. "Use lowercase snake_case starting with a letter (e.g. 'creature_001').",
				id
			)
		)
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
function ConfigValidator.validate(record: { [string]: any }, extraFields: { FieldSchema }?): ValidationResult
	local errors: { string } = {}

	-- Guard: record must be a table.
	if type(record) ~= "table" then
		return {
			ok = false,
			errors = { string.format("Config record must be a table, got '%s'.", type(record)) },
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
function ConfigValidator.validateAll(records: { { [string]: any } }, extraFields: { FieldSchema }?): ValidationResult
	local allErrors: { string } = {}

	if type(records) ~= "table" then
		return {
			ok = false,
			errors = {
				string.format("validateAll: expected a table of records, got '%s'.", type(records)),
			},
		}
	end

	for i, record in ipairs(records) do
		local result = ConfigValidator.validate(record, extraFields)
		if not result.ok then
			for _, err in ipairs(result.errors) do
				local recordId = (type(record) == "table" and type(record.id) == "string") and ("'" .. record.id .. "'")
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
