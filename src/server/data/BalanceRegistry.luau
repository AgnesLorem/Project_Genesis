--[[
	BalanceRegistry
	Location: src/server/data/BalanceRegistry.luau

	Loads balance configs (including combat_config) via ConfigRegistry.
	Validates with respective schemas.

	Rules:
	- Static definitions only.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)
local CombatBalanceSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CombatBalanceSchema)

local BalanceRegistry = {}

local _registry: { [string]: any } = {}
local _initialized = false

function BalanceRegistry.init()
	if _initialized then
		warn("[BalanceRegistry] Already initialized. Skipping.")
		return
	end

	local records = ConfigRegistry.load("balance")

	for _, record in ipairs(records) do
		if record.id == "combat_core" then
			local result = CombatBalanceSchema.validate(record)
			if result.success then
				_registry["combat_core"] = result.value
				print("[BalanceRegistry] Loaded combat_core config")
			else
				warn("[BalanceRegistry] combat_core validation failed: " .. (result.message or result.code))
			end
		else
			-- Other balance configs go here
			_registry[record.id] = record
		end
	end

	_initialized = true
end

function BalanceRegistry.getCombatConfig(): any
	return _registry["combat_core"]
end

function BalanceRegistry.isInitialized(): boolean
	return _initialized
end

return BalanceRegistry
