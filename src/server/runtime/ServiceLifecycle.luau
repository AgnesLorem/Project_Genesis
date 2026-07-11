--[[
	ServiceLifecycle
	Location: src/server/runtime/ServiceLifecycle.luau

	Minimal server service lifecycle contract for Project Genesis.

	Every server service must implement this lifecycle interface so that
	the server bootstrap can start services in a documented, predictable order.

	Lifecycle phases (in order):
	  1. init()    — Service sets up internal state and registers dependencies.
	                 No cross-service calls during init.
	  2. start()   — Service begins active operation (listens for players, connects events).
	                 Cross-service calls are allowed after all services have init()d.

	Rules:
	- Services must implement both init() and start().
	- init() must not depend on other services being started yet.
	- start() may call other services that have already init()d.
	- Neither phase should throw — use Result pattern for failures.
	- Gameplay systems (combat, creature, economy) must not be started here.
	  They will be added by future approved tasks.
	- This module registers and validates the lifecycle contract only.
	  It does not own service instances.

	Part of MVP-001: Core Framework Foundation.
--]]

-- Type alias: all services must implement this interface.
export type ServiceContract = {
	name: string, -- Stable service identifier for logging and debugging.
	init: () -> (), -- Phase 1: initialize internal state.
	start: () -> (), -- Phase 2: begin active operation.
}

-- Internal: ordered list of registered services.
local _registeredServices: { ServiceContract } = {}
local _isInitialized = false
local _isStarted = false

local ServiceLifecycle = {}

--[[
	ServiceLifecycle.register(service: ServiceContract)

	Registers a service to participate in the lifecycle.
	Services must be registered before ServiceLifecycle.init() is called.

	Throws if:
	  - service is not a table.
	  - service.name is missing or not a string.
	  - service.init is not a function.
	  - service.start is not a function.
	  - A service with the same name is already registered.
	  - Registration happens after init() has already run.
--]]
function ServiceLifecycle.register(service: ServiceContract)
	assert(type(service) == "table", "[ServiceLifecycle] register: service must be a table.")
	assert(
		type(service.name) == "string" and service.name ~= "",
		"[ServiceLifecycle] register: service.name must be a non-empty string."
	)
	assert(
		type(service.init) == "function",
		string.format("[ServiceLifecycle] register: '%s'.init must be a function.", service.name)
	)
	assert(
		type(service.start) == "function",
		string.format("[ServiceLifecycle] register: '%s'.start must be a function.", service.name)
	)
	assert(
		not _isInitialized,
		string.format(
			"[ServiceLifecycle] register: Cannot register '%s' after lifecycle has already initialized.",
			service.name
		)
	)

	-- Check for duplicate names.
	for _, existing in ipairs(_registeredServices) do
		if existing.name == service.name then
			error(
				string.format("[ServiceLifecycle] register: A service named '%s' is already registered.", service.name)
			)
		end
	end

	table.insert(_registeredServices, service)
end

--[[
	ServiceLifecycle.init()

	Runs Phase 1: calls init() on every registered service in order.
	All services are initialized before any service's start() is called.

	Safe error handling: if a service init() throws, the error is caught,
	logged with the service name, and the lifecycle logs it without crashing
	the full server. The failed service is noted but startup continues
	(fail-log, not fail-hard during MVP bootstrap).

	Must be called once, before ServiceLifecycle.start().
--]]
function ServiceLifecycle.init()
	assert(not _isInitialized, "[ServiceLifecycle] init() has already been called.")
	_isInitialized = true

	for _, service in ipairs(_registeredServices) do
		local ok, err = pcall(service.init)
		if not ok then
			warn(string.format("[ServiceLifecycle] init() FAILED for service '%s': %s", service.name, tostring(err)))
		else
			print(string.format("[ServiceLifecycle] init() OK — '%s'", service.name))
		end
	end
end

--[[
	ServiceLifecycle.start()

	Runs Phase 2: calls start() on every registered service in order.
	All services have been init()d before any start() is called.

	Must be called once, after ServiceLifecycle.init().
--]]
function ServiceLifecycle.start()
	assert(_isInitialized, "[ServiceLifecycle] init() must be called before start().")
	assert(not _isStarted, "[ServiceLifecycle] start() has already been called.")
	_isStarted = true

	for _, service in ipairs(_registeredServices) do
		local ok, err = pcall(service.start)
		if not ok then
			warn(string.format("[ServiceLifecycle] start() FAILED for service '%s': %s", service.name, tostring(err)))
		else
			print(string.format("[ServiceLifecycle] start() OK — '%s'", service.name))
		end
	end
end

--[[
	ServiceLifecycle.getRegisteredNames() -> { string }

	Returns a list of registered service names in registration order.
	Useful for diagnostics and smoke verification.
--]]
function ServiceLifecycle.getRegisteredNames(): { string }
	local names = {}
	for _, service in ipairs(_registeredServices) do
		table.insert(names, service.name)
	end
	return names
end

--[[
	ServiceLifecycle.isInitialized() -> boolean

	Returns true after init() has been called.
--]]
function ServiceLifecycle.isInitialized(): boolean
	return _isInitialized
end

--[[
	ServiceLifecycle.isStarted() -> boolean

	Returns true after start() has been called.
--]]
function ServiceLifecycle.isStarted(): boolean
	return _isStarted
end

return ServiceLifecycle
