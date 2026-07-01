--[[
	EvolutionRegistry
	Location: src/server/data/EvolutionRegistry.luau

	Loads evolution configs, validates them via EvolutionSchema, and indexes them.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)
local EvolutionSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.EvolutionSchema)

local EvolutionRegistry = {}
local _registry: { [string]: any } = {}
local _initialized = false

function EvolutionRegistry.init()
	if _initialized then return end
	
	local records = ConfigRegistry.load("evolutions")
	for _, record in ipairs(records) do
		local result = EvolutionSchema.validate(record)
		if result.success then
			local id = result.value.evolutionId
			if _registry[id] then
				warn(string.format("[EvolutionRegistry] Duplicate evolutionId '%s' — skipped.", id))
			else
				_registry[id] = result.value
			end
		else
			warn(string.format("[EvolutionRegistry] Validation failed for '%s': %s", tostring(record.evolutionId or "unknown"), result.message or result.code))
		end
	end
	
	_initialized = true
end

function EvolutionRegistry.getEvolution(evolutionId: string): any
	return _registry[evolutionId]
end

function EvolutionRegistry.getAllEvolutions(): { any }
	local list = {}
	for _, evol in pairs(_registry) do
		table.insert(list, evol)
	end
	return list
end

function EvolutionRegistry.isInitialized(): boolean
	return _initialized
end

return EvolutionRegistry
