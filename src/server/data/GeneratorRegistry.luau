--[[
	GeneratorRegistry
	Location: src/server/data/GeneratorRegistry.luau

	Loads generator configs via ConfigRegistry, validates each with GeneratorSchema,
	indexes by generatorId.

	Rules:
	- Static definitions only. No player state.
	- Loads from ServerStorage.Configs.generators via ConfigRegistry.
	- Invalid configs are rejected and logged, never silently accepted.

	Part of MVP-005: Bio Generator and Economy Foundation.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)
local GeneratorSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.GeneratorSchema)

local GeneratorRegistry = {}

local _registry: { [string]: any } = {}
local _initialized = false

--[[
	GeneratorRegistry.init()

	Loads all generator configs, validates each, and indexes by generatorId.
	Must be called once during server bootstrap before any service uses generators.
--]]
function GeneratorRegistry.init()
	if _initialized then
		warn("[GeneratorRegistry] Already initialized. Skipping.")
		return
	end

	local records = ConfigRegistry.load("generators")

	for _, record in ipairs(records) do
		local result = GeneratorSchema.validate(record)
		if result.success then
			local generatorId = result.value.generatorId
			if _registry[generatorId] then
				warn(string.format("[GeneratorRegistry] Duplicate generatorId '%s' — skipping.", generatorId))
			else
				_registry[generatorId] = result.value
				print(string.format("[GeneratorRegistry] Loaded generator: '%s'", generatorId))
			end
		else
			warn(
				string.format(
					"[GeneratorRegistry] Config validation failed: %s — %s",
					tostring(record.id or "unknown"),
					result.message or result.code
				)
			)
		end
	end

	_initialized = true
end

--[[
	GeneratorRegistry.getGenerator(generatorId) -> config?

	Returns the validated config for a generatorId, or nil if not found.
--]]
function GeneratorRegistry.getGenerator(generatorId: string): any
	return _registry[generatorId]
end

--[[
	GeneratorRegistry.getAllGenerators() -> { config }

	Returns a list of all loaded generator configs.
--]]
function GeneratorRegistry.getAllGenerators(): { any }
	local list = {}
	for _, config in pairs(_registry) do
		table.insert(list, config)
	end
	return list
end

--[[
	GeneratorRegistry.isInitialized() -> boolean
--]]
function GeneratorRegistry.isInitialized(): boolean
	return _initialized
end

return GeneratorRegistry
