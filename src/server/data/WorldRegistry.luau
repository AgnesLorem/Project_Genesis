--[[
	WorldRegistry
	Location: src/server/data/WorldRegistry.luau

	Loads enabled world configs, validates them via WorldSchema, and exposes
	lookup/display snapshots. This module owns no player runtime state.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)
local WorldSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.WorldSchema)

local WorldRegistry = {}
local _registry: { [string]: any } = {}
local _initialized = false

local function _cloneArray(value: { any }): { any }
	local output = {}
	for _, item in ipairs(value) do
		table.insert(output, item)
	end
	return output
end

local function _buildSnapshot(world: any): any
	return {
		worldId = world.worldId,
		displayName = world.displayName,
		description = world.description,
		unlockRequirementRefs = _cloneArray(world.unlockRequirementRefs),
		encounterRefs = _cloneArray(world.encounterRefs),
		bossRefs = _cloneArray(world.bossRefs),
		recommendedPowerRange = {
			min = world.recommendedPowerRange.min,
			max = world.recommendedPowerRange.max,
		},
		sortOrder = world.sortOrder,
		isEnabled = world.isEnabled,
	}
end

function WorldRegistry.init()
	if _initialized then
		warn("[WorldRegistry] Already initialized. Skipping.")
		return
	end

	local records = ConfigRegistry.load("worlds")
	for _, record in ipairs(records) do
		local result = WorldSchema.validate(record)
		if result.success then
			local world = result.value
			if world.isEnabled then
				local worldId = world.worldId
				if _registry[worldId] then
					warn(string.format("[WorldRegistry] Duplicate worldId '%s' - skipping.", worldId))
				else
					_registry[worldId] = world
				end
			end
		else
			warn(
				string.format(
					"[WorldRegistry] Validation failed for '%s': %s",
					tostring(record.worldId or record.id or "unknown"),
					result.message or result.code
				)
			)
		end
	end

	_initialized = true
end

function WorldRegistry.getWorld(worldId: string): any
	return _registry[worldId]
end

function WorldRegistry.getWorldSnapshot(worldId: string): any
	local world = WorldRegistry.getWorld(worldId)
	if not world then
		return nil
	end

	return _buildSnapshot(world)
end

function WorldRegistry.getAllWorlds(): { any }
	local list = {}
	for _, world in pairs(_registry) do
		table.insert(list, world)
	end
	return list
end

function WorldRegistry.getAllWorldSnapshots(): { any }
	local list = {}
	for _, world in pairs(_registry) do
		table.insert(list, _buildSnapshot(world))
	end
	table.sort(list, function(a, b)
		if a.sortOrder ~= b.sortOrder then
			return a.sortOrder < b.sortOrder
		end
		return a.worldId < b.worldId
	end)
	return list
end

function WorldRegistry.isInitialized(): boolean
	return _initialized
end

return WorldRegistry
