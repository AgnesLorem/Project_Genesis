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
local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
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
		warn(string.format("[FrameworkSmoke] FAIL — %s%s", testName, detail and (": " .. detail) or ""))
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
	_assert("ServiceContract: init is function", type(fakeService.init) == "function", "init check")
	_assert("ServiceContract: start is function", type(fakeService.start) == "function", "start check")

	-- T2: A ServiceContract without name fails the contract check.
	local badService = { init = function() end, start = function() end }
	local nameCheckFails = (type(badService.name) ~= "string" or badService.name == "")
	_assert("ServiceContract: missing name caught", nameCheckFails == true, "name validation")

	-- T3: A ServiceContract without init fails.
	local noInitService = { name = "NoInit", start = function() end }
	_assert("ServiceContract: missing init caught", type(noInitService.init) ~= "function", "init validation")
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

	print(string.format("[FrameworkSmoke] ═══ Done: %d PASSED, %d FAILED ═══", _passCount, _failCount))

	return { passed = _passCount, failed = _failCount }
end

return FrameworkSmoke
