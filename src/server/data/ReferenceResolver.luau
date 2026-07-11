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
	quests = true,
	towers = true,
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
			error = string.format("validateRef: refId must be a string, got '%s'.", type(refId)),
		}
	end

	if type(category) ~= "string" then
		return {
			ok = false,
			record = nil,
			error = string.format("validateRef: category must be a string, got '%s'.", type(category)),
		}
	end

	-- Block reserved categories.
	if RESERVED_CATEGORIES[category] then
		return {
			ok = false,
			record = nil,
			error = string.format(
				"Reference to reserved category '%s' is not allowed in active MVP config. " .. "ID: '%s'.",
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
			error = string.format("Reference '%s' not found in category '%s'.", refId, category),
		}
	end

	-- Check that the referenced record is enabled.
	if record.isEnabled == false then
		return {
			ok = false,
			record = nil,
			error = string.format(
				"Reference '%s' in category '%s' exists but is disabled (isEnabled = false). "
					.. "Disabled records must not be referenced in active content.",
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
function ReferenceResolver.validateAllRefs(refIds: { string }, category: string): { ResolveResult }
	local results: { ResolveResult } = {}

	if type(refIds) ~= "table" then
		return {
			{
				ok = false,
				record = nil,
				error = string.format("validateAllRefs: refIds must be a table, got '%s'.", type(refIds)),
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
