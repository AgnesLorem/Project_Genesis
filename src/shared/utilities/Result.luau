--[[
	Result
	Location: src/shared/utilities/Result.luau

	Shared success/failure result pattern for Project Genesis.

	Every server service, remote handler, and validation function that can
	fail should return a Result table instead of throwing an error or
	returning raw nil.

	This pattern makes failure handling explicit, prevents silent failures,
	and provides a uniform interface for callers to branch on.

	Rules:
	- Result tables are immutable once created.
	- Result.ok(value) wraps a successful result.
	- Result.fail(code, message?) wraps a failure with a safe error code.
	- Callers must check the "success" field before using the "value" field.
	- Error codes must be strings — never raw error objects or stack traces.
	- This module is shared-safe: no server-only logic, no gameplay values.

	Part of MVP-001: Core Framework Foundation.
--]]

-- Type exports for use by other modules.
export type OkResult<T> = {
	success: true,
	value: T,
}

export type FailResult = {
	success: false,
	code: string,
	message: string?,
}

export type Result<T> = OkResult<T> | FailResult

local Result = {}

--[[
	Result.ok(value) -> OkResult<T>

	Wraps a successful result with the given value.
	"value" may be any type, including nil for void successes.

	Example:
	  local r = Result.ok(42)
	  if r.success then print(r.value) end
--]]
function Result.ok<T>(value: T): OkResult<T>
	return {
		success = true,
		value = value,
	}
end

--[[
	Result.fail(code, message?) -> FailResult

	Wraps a failure result with a safe error code and optional message.

	"code" should be a documented error code string such as:
	  "invalid_input"
	  "not_found"
	  "unauthorized"
	  "service_unavailable"
	  "validation_failed"

	"message" is optional human-readable context for debugging.
	Do NOT put sensitive data, raw stack traces, or save payloads in message.

	Example:
	  local r = Result.fail("not_found", "Player session not found.")
	  if not r.success then warn(r.code) end
--]]
function Result.fail(code: string, message: string?): FailResult
	assert(type(code) == "string" and code ~= "", "[Result] Error code must be a non-empty string.")
	return {
		success = false,
		code = code,
		message = message,
	}
end

--[[
	Result.isOk(result) -> boolean

	Returns true if the result represents success.
	Type-safe guard for branching on result state.
--]]
function Result.isOk(result: { success: boolean }): boolean
	return result.success == true
end

--[[
	Result.isFail(result) -> boolean

	Returns true if the result represents failure.
--]]
function Result.isFail(result: { success: boolean }): boolean
	return result.success == false
end

--[[
	Result.unwrapOr(result, default) -> T

	Returns the result's value on success, or the default value on failure.
	Use when a fallback is appropriate and failure should not propagate.

	Example:
	  local count = Result.unwrapOr(Result.fail("not_found"), 0)
--]]
function Result.unwrapOr<T>(result: OkResult<T> | FailResult, default: T): T
	if result.success then
		return (result :: OkResult<T>).value
	else
		return default
	end
end

return Result
