local CreatureSchema = require(script.Parent.CreatureSchema)
local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local CreatureRegistry = {}
local registry = {}

-- Static definitions only. No player state.
function CreatureRegistry.loadConfig(configs: { [string]: any })
	for id, data in pairs(configs) do
		local result = CreatureSchema.validate(data)
		if result.success then
			registry[id] = result.value
		else
			warn(
				string.format(
					"Failed to validate creature config %s: %s",
					id,
					result.message or result.code or "unknown error"
				)
			)
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
