--[[
	RemoteMiddleware
	Location: src/server/networking/RemoteMiddleware.luau

	Provides reusable security layers for RemoteFunctions:
	- Rate Limiting
	- Payload Validation
]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local RemoteMiddleware = {}

local rateLimits: { [string]: { lastTime: number, count: number } } = {}
local MAX_REQUESTS_PER_SEC = 5
local MAX_STRING_LENGTH = 100
local MAX_TABLE_SIZE = 50

-- Rate Limiting

function RemoteMiddleware.checkRateLimit(player: Player, remoteName: string)
	local key = player.UserId .. "_" .. remoteName
	local now = os.clock()
	local record = rateLimits[key]

	if record then
		if now - record.lastTime < 1 then
			record.count += 1
			if record.count > MAX_REQUESTS_PER_SEC then
				return Result.fail("rate_limited", "Too many requests to " .. remoteName .. ". Slow down.")
			end
		else
			record.count = 1
			record.lastTime = now
		end
	else
		rateLimits[key] = { count = 1, lastTime = now }
	end

	return Result.ok(true)
end

-- Payload Validation

function RemoteMiddleware.validateString(value: any, maxLen: number?)
	if type(value) ~= "string" or value == "" then
		return Result.fail("invalid_payload", "Expected non-empty string.")
	end

	local limit = maxLen or MAX_STRING_LENGTH
	if string.len(value) > limit then
		return Result.fail("invalid_payload", "String payload exceeds limit.")
	end

	return Result.ok(value)
end

function RemoteMiddleware.validateTable(value: any, maxElements: number?)
	if type(value) ~= "table" then
		return Result.fail("invalid_payload", "Expected table.")
	end

	local limit = maxElements or MAX_TABLE_SIZE
	local count = 0
	for _, _ in pairs(value) do
		count += 1
		if count > limit then
			return Result.fail("invalid_payload", "Table payload exceeds element limit.")
		end
	end

	return Result.ok(value)
end

-- Middleware Wrapper

function RemoteMiddleware.createHandler(remoteName: string, handler: (Player, ...any) -> any)
	return function(player: Player, ...)
		local rateLimitRes = RemoteMiddleware.checkRateLimit(player, remoteName)
		if not rateLimitRes.success then
			return rateLimitRes
		end

		return handler(player, ...)
	end
end

return RemoteMiddleware
