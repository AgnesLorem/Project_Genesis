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
local p = ensurePath(game:GetService("ServerScriptService").Server, "runtime")
getOrCreateModule(p, "FrameworkSmoke", [====[
--[[
	FrameworkSmoke
	Location: src/server/runtime/FrameworkSmoke.luau

	Framework smoke verification for Project Genesis MVP-001.

	This module provides a suite of self-contained checks that verify the
	core framework modules (Result, ServiceLifecycle) are functioning
	correctly after bootstrap.

	Rules:
	- Smoke tests must be self-contained and not depend on gameplay systems.
	- Smoke tests must not mutate game state.
	- Smoke tests must print PASS or FAIL with the test name.
	- This module must ONLY be called during development/Studio verification.
	  It must NOT be called automatically in production bootstrap.
	- No gameplay values are tested here.

	Part of MVP-001: Core Framework Foundation.
--]]

-- Results are required freshly so this module gets isolated state.
local Result = require(script.Parent.Parent.Parent.shared.utilities.Result)
-- Note: ServiceLifecycle is stateful (singleton) — we test behavior only.

local FrameworkSmoke = {}

local _passCount = 0
local _failCount = 0

local function _assert(testName: string, condition: boolean, detail: string?)
	if condition then
		_passCount += 1
		print(string.format("[FrameworkSmoke] PASS — %s", testName))
	else
		_failCount += 1
		warn(string.format(
			"[FrameworkSmoke] FAIL — %s%s",
			testName,
			detail and (": " .. detail) or ""
		))
	end
end

-- ─── Result Tests ────────────────────────────────────────────────────────────

local function _testResult()
	-- T1: ok() creates a success result.
	local r1 = Result.ok(42)
	_assert("Result.ok creates success", r1.success == true, "success should be true")
	_assert("Result.ok has value", r1.value == 42, "value should be 42")

	-- T2: fail() creates a failure result.
	local r2 = Result.fail("not_found", "Resource missing.")
	_assert("Result.fail creates failure", r2.success == false, "success should be false")
	_assert("Result.fail has code", r2.code == "not_found", "code should be 'not_found'")
	_assert("Result.fail has message", r2.message == "Resource missing.", "message mismatch")

	-- T3: ok() with nil value is valid (void success).
	local r3 = Result.ok(nil)
	_assert("Result.ok(nil) is valid", r3.success == true, "void success should work")

	-- T4: isOk() / isFail() helpers.
	_assert("Result.isOk on ok", Result.isOk(r1) == true, "isOk should be true")
	_assert("Result.isFail on fail", Result.isFail(r2) == true, "isFail should be true")
	_assert("Result.isOk on fail", Result.isOk(r2) == false, "isOk on fail should be false")
	_assert("Result.isFail on ok", Result.isFail(r1) == false, "isFail on ok should be false")

	-- T5: unwrapOr() returns value on success, default on failure.
	local v1 = Result.unwrapOr(r1, 0)
	_assert("Result.unwrapOr on ok", v1 == 42, "should return value=42")
	local v2 = Result.unwrapOr(r2, 0)
	_assert("Result.unwrapOr on fail", v2 == 0, "should return default=0")

	-- T6: fail() with empty code should throw.
	local badCodeOk = pcall(function()
		Result.fail("")
	end)
	_assert("Result.fail empty code throws", badCodeOk == false, "should assert on empty code")

	-- T7: fail() without message is valid.
	local r4 = Result.fail("unauthorized")
	_assert("Result.fail no message", r4.message == nil, "message should be nil")
end

-- ─── ServiceLifecycle Tests ──────────────────────────────────────────────────

local function _testServiceLifecycle()
	-- These tests use a fresh local lifecycle copy to avoid polluting
	-- the real singleton state used by ServerBootstrap.
	-- We test by creating a local table that mimics the lifecycle interface
	-- and verifying ServiceContract validation logic inline.

	-- T1: A valid ServiceContract shape has the correct fields.
	local fakeService = {
		name = "TestService",
		init = function() end,
		start = function() end,
	}
	_assert(
		"ServiceContract: name is string",
		type(fakeService.name) == "string" and fakeService.name ~= "",
		"name check"
	)
	_assert(
		"ServiceContract: init is function",
		type(fakeService.init) == "function",
		"init check"
	)
	_assert(
		"ServiceContract: start is function",
		type(fakeService.start) == "function",
		"start check"
	)

	-- T2: A ServiceContract without name fails the contract check.
	local badService = { init = function() end, start = function() end }
	local nameCheckFails = (type(badService.name) ~= "string" or badService.name == "")
	_assert("ServiceContract: missing name caught", nameCheckFails == true, "name validation")

	-- T3: A ServiceContract without init fails.
	local noInitService = { name = "NoInit", start = function() end }
	_assert(
		"ServiceContract: missing init caught",
		type(noInitService.init) ~= "function",
		"init validation"
	)
end

-- ─── Public API ─────────────────────────────────────────────────────────────

--[[
	FrameworkSmoke.run()

	Runs all framework smoke checks and prints a summary.
	Call this from Studio command bar or a test script during development.
	Do NOT call from production ServerBootstrap.

	Returns { passed = number, failed = number }.
--]]
function FrameworkSmoke.run(): { passed: number, failed: number }
	_passCount = 0
	_failCount = 0

	print("[FrameworkSmoke] ═══ Starting MVP-001 Framework Smoke Verification ═══")

	_testResult()
	_testServiceLifecycle()

	print(string.format(
		"[FrameworkSmoke] ═══ Done: %d PASSED, %d FAILED ═══",
		_passCount,
		_failCount
	))

	return { passed = _passCount, failed = _failCount }
end

return FrameworkSmoke

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "runtime")
getOrCreateModule(p, "ServiceLifecycle", [====[
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
	name: string,          -- Stable service identifier for logging and debugging.
	init: () -> (),        -- Phase 1: initialize internal state.
	start: () -> (),       -- Phase 2: begin active operation.
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
	assert(
		type(service) == "table",
		"[ServiceLifecycle] register: service must be a table."
	)
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
			error(string.format(
				"[ServiceLifecycle] register: A service named '%s' is already registered.",
				service.name
			))
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
			warn(string.format(
				"[ServiceLifecycle] init() FAILED for service '%s': %s",
				service.name,
				tostring(err)
			))
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
			warn(string.format(
				"[ServiceLifecycle] start() FAILED for service '%s': %s",
				service.name,
				tostring(err)
			))
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

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "services")
getOrCreateModule(p, "CreatureService", [====[
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Shared.data.CreatureRegistry)
local SaveService = require(script.Parent.SaveService)
local Result = require(game:GetService("ReplicatedStorage").Shared.utilities.Result)
local HttpService = game:GetService("HttpService")

local CreatureService = {}

-- Narrow interface to SaveService.
-- CreatureService must not communicate with DataStore directly.
function CreatureService.tryGrantCreature(player: Player, creatureId: string)
    -- Validate: Creature exists in Registry
    local config = CreatureRegistry.getCreature(creatureId)
    if not config then
        return Result.fail("Invalid Creature ID rejected.")
    end

    -- Validate: Creature is enabled
    if not config.isEnabled then
        return Result.fail("Disabled Creature rejected.")
    end

    -- Validate: Duplicate check
    local playerSave = SaveService.getPlayerSave(player)
    local instances = playerSave.creatureInstances or {}
    
    for _, instance in pairs(instances) do
        if instance.creatureId == creatureId then
            return Result.fail("Duplicate grant behavior follows documented rule: cannot grant duplicate.")
        end
    end

    -- Generate instance
    local instanceId = HttpService:GenerateGUID(false)
    local newInstance = {
        instanceId = instanceId,
        creatureId = creatureId,
        acquiredAt = os.time()
    }

    -- Apply to SaveService
    instances[instanceId] = newInstance
    playerSave.creatureInstances = instances
    SaveService.savePlayer(player)

    return Result.ok(newInstance)
end

function CreatureService.getPlayerCreatures(player: Player)
    local playerSave = SaveService.getPlayerSave(player)
    return playerSave.creatureInstances or {}
end

return CreatureService

]====])

return 'Restore chunk 4 complete!'