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

local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
getOrCreateModule(p, "SkillRegistry", [====[
local ConfigRegistry = require(script.Parent.ConfigRegistry)
local SkillSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.SkillSchema)

local SkillRegistry = {}

local _registry: { [string]: any } = {}
local _allRegistry: { [string]: any } = {}
local _initialized = false

local function _copyArray(values: any): { any }
	local output = {}
	if type(values) == "table" then
		for _, value in ipairs(values) do
			table.insert(output, value)
		end
	end
	return output
end

local function _buildSnapshot(config: any)
	return {
		skillId = config.skillId,
		displayName = config.displayName,
		description = config.description,
		skillType = config.skillType,
		rarity = config.rarity,
		elementType = config.elementType,
		cooldown = config.cooldown,
		targetRule = config.targetRule,
		damageMultiplier = config.damageMultiplier,
		statusEffectRefs = _copyArray(config.statusEffectRefs),
		iconPlaceholder = config.iconPlaceholder,
		isEnabled = config.isEnabled,
	}
end

function SkillRegistry.init()
	if _initialized then
		warn("[SkillRegistry] Already initialized. Skipping.")
		return
	end

	local records = ConfigRegistry.load("skills")

	for _, record in ipairs(records) do
		local result = SkillSchema.validate(record)
		if result.success then
			local skill = result.value
			if _allRegistry[skill.skillId] then
				warn(string.format("[SkillRegistry] Duplicate skillId '%s' skipped.", skill.skillId))
			else
				_allRegistry[skill.skillId] = skill
			end

			if _allRegistry[skill.skillId] ~= skill then
				continue
			elseif not skill.isEnabled then
				print(string.format("[SkillRegistry] Skipped disabled skill '%s'.", skill.skillId))
			elseif _registry[skill.skillId] then
				warn(string.format("[SkillRegistry] Duplicate skillId '%s' skipped.", skill.skillId))
			else
				_registry[skill.skillId] = skill
				print(string.format("[SkillRegistry] Loaded skill '%s'.", skill.skillId))
			end
		else
			warn(string.format(
				"[SkillRegistry] Config validation failed: %s - %s",
				tostring(record.id or "unknown"),
				tostring(result.message or result.code)
			))
		end
	end

	_initialized = true
end

function SkillRegistry.getSkill(skillId: string): any
	return _allRegistry[skillId]
end

function SkillRegistry.getEnabledSkill(skillId: string): any
	return _registry[skillId]
end

function SkillRegistry.getSkillSnapshot(skillId: string): any
	local config = SkillRegistry.getEnabledSkill(skillId)
	return config and _buildSnapshot(config) or nil
end

function SkillRegistry.getAllSkills(): { any }
	local list = {}
	for _, config in pairs(_registry) do
		table.insert(list, config)
	end
	table.sort(list, function(a, b)
		return a.skillId < b.skillId
	end)
	return list
end

function SkillRegistry.getAllSkillSnapshots(): { any }
	local list = {}
	for _, config in ipairs(SkillRegistry.getAllSkills()) do
		table.insert(list, _buildSnapshot(config))
	end
	return list
end

function SkillRegistry.isInitialized(): boolean
	return _initialized
end

return SkillRegistry

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
getOrCreateModule(p, "StageOrder", [====[
--[[
	StageOrder
	Location: src/server/data/StageOrder.luau

	Single source of truth for the ordered story stage sequence.
	MVP-020: hardcoded here pending a dedicated stage/encounter registry.

	Shared by:
	- RemoteHandlers (RequestStoryBattle victory progression)
	- GeneratorService (stageClear generator unlock requirement, DD-029)
--]]

local StageOrder = {}

local STAGE_ORDER = { "story_stage_1", "story_stage_2", "story_stage_3" }

--[[
	StageOrder.getSequence() -> { string }

	Returns the ordered list of story stage ids.
--]]
function StageOrder.getSequence(): { string }
	return STAGE_ORDER
end

--[[
	StageOrder.getIndex(stageId) -> number?

	Returns the 1-based index of stageId in the sequence, or nil if unknown.
--]]
function StageOrder.getIndex(stageId: string): number?
	return table.find(STAGE_ORDER, stageId)
end

return StageOrder

]====])

return 'Restore chunk 4 complete!'