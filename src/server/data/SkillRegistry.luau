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
			warn(
				string.format(
					"[SkillRegistry] Config validation failed: %s - %s",
					tostring(record.id or "unknown"),
					tostring(result.message or result.code)
				)
			)
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
