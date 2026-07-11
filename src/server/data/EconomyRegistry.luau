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
				warn(string.format("[EconomyRegistry] Duplicate currencyId '%s' — skipping.", currencyId))
			else
				_registry[currencyId] = result.value
				print(string.format("[EconomyRegistry] Loaded currency: '%s'", currencyId))
			end
		else
			warn(
				string.format(
					"[EconomyRegistry] Config validation failed: %s — %s",
					tostring(record.id or "unknown"),
					result.message or result.code
				)
			)
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
