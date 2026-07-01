--[[
	SaveKeyBuilder
	Location: src/server/persistence/SaveKeyBuilder.luau
	
	Constructs deterministic, stable save keys for player data.
	
	Rules (from docs/SAVE_SYSTEM.md):
	- Keys use Player.UserId (integer), NOT Player.Name (can change).
	- Key format: "player_{userId}"
	- Key format must never change after data has been saved.
	- Invalid or nil UserId is rejected and returns nil.
	- This module is server-only by architectural convention.
	
	This module has NO knowledge of DataStore names, save schema, or
	gameplay rules. It only builds and validates key strings.
	
	Part of MVP-002: Save, Config, and Database Foundation.
--]]

-- The DataStore name for player save data (documented in docs/SAVE_SYSTEM.md).
local PLAYER_SAVE_STORE_NAME = "PlayerSaveData"

-- Key prefix as documented in docs/SAVE_SYSTEM.md.
local KEY_PREFIX = "player_"

local SaveKeyBuilder = {}

--[[
	SaveKeyBuilder.validateUserId(userId: any) -> boolean
	
	Returns true if the given value is a valid Roblox UserId.
	A valid UserId is an integer greater than 0.
	
	Returns false for nil, non-number, fractional, or non-positive values.
--]]
function SaveKeyBuilder.validateUserId(userId: any): boolean
	if type(userId) ~= "number" then
		return false
	end

	if userId <= 0 then
		return false
	end

	-- Must be a whole number (integer).
	if userId ~= math.floor(userId) then
		return false
	end

	return true
end

--[[
	SaveKeyBuilder.buildPlayerKey(userId: any) -> string?
	
	Constructs the save key string for a player.
	Returns a key string on success.
	Returns nil if the userId is invalid — caller must handle nil.
	
	Key format: "player_{userId}"
	Example: "player_123456"
	
	Never throws.
--]]
function SaveKeyBuilder.buildPlayerKey(userId: any): string?
	if not SaveKeyBuilder.validateUserId(userId) then
		warn(string.format(
			"[SaveKeyBuilder] buildPlayerKey received invalid userId: '%s' (type: %s). Returning nil.",
			tostring(userId),
			type(userId)
		))
		return nil
	end

	return KEY_PREFIX .. tostring(math.floor(userId))
end

--[[
	SaveKeyBuilder.getStoreName() -> string
	
	Returns the canonical DataStore name for player save data.
	Centralised here so all persistence code references one source of truth.
--]]
function SaveKeyBuilder.getStoreName(): string
	return PLAYER_SAVE_STORE_NAME
end

--[[
	SaveKeyBuilder.parseUserIdFromKey(key: string) -> number?
	
	Utility: extracts the UserId from a save key string.
	Returns the UserId as a number, or nil if the key format is unrecognized.
	Useful for debugging and audit tooling.
	
	Never throws.
--]]
function SaveKeyBuilder.parseUserIdFromKey(key: string): number?
	if type(key) ~= "string" then
		return nil
	end

	-- Match "player_<digits>"
	local digits = string.match(key, "^player_(%d+)$")
	if not digits then
		return nil
	end

	local userId = tonumber(digits)
	if userId == nil or not SaveKeyBuilder.validateUserId(userId) then
		return nil
	end

	return userId
end

return SaveKeyBuilder
