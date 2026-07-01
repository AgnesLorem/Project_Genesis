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
local p = ensurePath(game:GetService("ServerScriptService").Server, "persistence")
getOrCreateModule(p, "DataStoreWrapper", [====[
--[[
	DataStoreWrapper
	Location: src/server/persistence/DataStoreWrapper.luau
	
	Thin server-side wrapper around Roblox DataStoreService.
	
	All persistence reads and writes in Project Genesis must route through
	this module. No other module should call DataStoreService directly.
	
	Responsibilities:
	- Wrap GetAsync/SetAsync in pcall for safe error handling.
	- Return structured LoadResult/SaveResult tables instead of raw values.
	- Never expose raw DataStore errors externally — use error categories.
	- Enforce server-only usage (Roblox runtime enforces this naturally,
	  but we document it here for architectural clarity).
	
	This module has NO knowledge of save schemas, player data structure,
	or gameplay rules. It is a pure transport layer.
	
	Backend: Roblox DataStoreService (DataStore v1)
	Per docs/SAVE_SYSTEM.md.
	
	Part of MVP-002: Save, Config, and Database Foundation.
--]]

local DataStoreService = game:GetService("DataStoreService")

-- Structured result types.
export type LoadResult = {
	ok: boolean,
	data: any,          -- The loaded value, or nil on failure or missing key.
	errorCategory: string?, -- Safe error category string if ok = false.
}

export type SaveResult = {
	ok: boolean,
	errorCategory: string?, -- Safe error category string if ok = false.
}

-- Safe error categories (from docs/SAVE_SYSTEM.md).
-- These must not expose raw DataStore messages.
local ERROR_CATEGORIES = {
	DATASTORE_UNAVAILABLE   = "datastore_unavailable",
	REQUEST_BUDGET_EXCEEDED = "request_budget_exceeded",
	SERIALIZATION_FAILED    = "serialization_failed",
	KEY_INVALID             = "key_invalid",
	UNKNOWN_ERROR           = "unknown_error",
}

-- Internal: map a DataStore error message to a safe category string.
-- This prevents raw error internals from leaking to callers.
local function _categorizeError(rawError: string): string
	if type(rawError) ~= "string" then
		return ERROR_CATEGORIES.UNKNOWN_ERROR
	end

	local lower = string.lower(rawError)

	if string.find(lower, "budget") or string.find(lower, "throttle") or string.find(lower, "limit") then
		return ERROR_CATEGORIES.REQUEST_BUDGET_EXCEEDED
	end

	if string.find(lower, "serialize") or string.find(lower, "encode") then
		return ERROR_CATEGORIES.SERIALIZATION_FAILED
	end

	if string.find(lower, "key") then
		return ERROR_CATEGORIES.KEY_INVALID
	end

	if string.find(lower, "unavailable") or string.find(lower, "503") or string.find(lower, "connect") then
		return ERROR_CATEGORIES.DATASTORE_UNAVAILABLE
	end

	return ERROR_CATEGORIES.UNKNOWN_ERROR
end

-- Cache for DataStore instances to avoid repeated GetDataStore calls.
local _storeCache: { [string]: DataStore } = {}

-- Internal: get or create a DataStore instance by name.
local function _getStore(storeName: string): (boolean, DataStore | string)
	if _storeCache[storeName] then
		return true, _storeCache[storeName]
	end

	local ok, storeOrError = pcall(function()
		return DataStoreService:GetDataStore(storeName)
	end)

	if ok then
		_storeCache[storeName] = storeOrError :: DataStore
		return true, storeOrError :: DataStore
	else
		return false, tostring(storeOrError)
	end
end

local DataStoreWrapper = {}

--[[
	DataStoreWrapper.load(storeName: string, key: string) -> LoadResult
	
	Loads data from the named DataStore at the given key.
	
	Returns:
	  { ok = true, data = <value> }         -- Key found, data returned.
	  { ok = true, data = nil }             -- Key exists but has no data (new player).
	  { ok = false, errorCategory = <cat> } -- DataStore call failed.
	
	Never throws. Caller must handle all result cases.
--]]
function DataStoreWrapper.load(storeName: string, key: string): LoadResult
	assert(type(storeName) == "string" and storeName ~= "", "[DataStoreWrapper] storeName must be a non-empty string.")
	assert(type(key) == "string" and key ~= "", "[DataStoreWrapper] key must be a non-empty string.")

	-- Get or create DataStore instance.
	local storeOk, storeOrError = _getStore(storeName)
	if not storeOk then
		local category = _categorizeError(tostring(storeOrError))
		warn(string.format(
			"[DataStoreWrapper] Failed to get DataStore '%s'. Category: %s",
			storeName, category
		))
		return { ok = false, data = nil, errorCategory = category }
	end

	local store = storeOrError :: DataStore

	-- Attempt GetAsync.
	local ok, dataOrError = pcall(function()
		return store:GetAsync(key)
	end)

	if ok then
		-- dataOrError is the actual data value (may be nil for new players).
		return { ok = true, data = dataOrError, errorCategory = nil }
	else
		local category = _categorizeError(tostring(dataOrError))
		warn(string.format(
			"[DataStoreWrapper] GetAsync failed. Store: '%s'. Category: %s",
			storeName, category
		))
		return { ok = false, data = nil, errorCategory = category }
	end
end

--[[
	DataStoreWrapper.save(storeName: string, key: string, data: any) -> SaveResult
	
	Saves data to the named DataStore at the given key.
	
	Returns:
	  { ok = true }                         -- Save succeeded.
	  { ok = false, errorCategory = <cat> } -- DataStore call failed.
	
	Never throws. Caller must check result and handle failures.
	On failure, caller must NOT assume the data was saved.
--]]
function DataStoreWrapper.save(storeName: string, key: string, data: any): SaveResult
	assert(type(storeName) == "string" and storeName ~= "", "[DataStoreWrapper] storeName must be a non-empty string.")
	assert(type(key) == "string" and key ~= "", "[DataStoreWrapper] key must be a non-empty string.")

	-- Get or create DataStore instance.
	local storeOk, storeOrError = _getStore(storeName)
	if not storeOk then
		local category = _categorizeError(tostring(storeOrError))
		warn(string.format(
			"[DataStoreWrapper] Failed to get DataStore '%s' for save. Category: %s",
			storeName, category
		))
		return { ok = false, errorCategory = category }
	end

	local store = storeOrError :: DataStore

	-- Attempt SetAsync.
	local ok, errorValue = pcall(function()
		store:SetAsync(key, data)
	end)

	if ok then
		return { ok = true, errorCategory = nil }
	else
		local category = _categorizeError(tostring(errorValue))
		warn(string.format(
			"[DataStoreWrapper] SetAsync failed. Store: '%s'. Category: %s",
			storeName, category
		))
		return { ok = false, errorCategory = category }
	end
end

--[[
	DataStoreWrapper.ERROR_CATEGORIES
	
	Exported safe error category constants for callers to reference.
--]]
DataStoreWrapper.ERROR_CATEGORIES = ERROR_CATEGORIES

return DataStoreWrapper

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "persistence")
getOrCreateModule(p, "PersistenceReporter", [====[
--[[
	PersistenceReporter
	Location: src/server/persistence/PersistenceReporter.luau
	
	Controlled failure reporting for persistence operations.
	
	All load and save failures must be reported through this module.
	It ensures that failure information is logged safely without exposing
	raw save payloads, player data contents, or full DataStore error messages.
	
	Rules:
	- Log the userId and error category only — NOT raw data or full stack traces.
	- Do NOT mutate any state when called.
	- Do NOT throw.
	- Reporting is output only (warn/print). No return values for the caller to branch on.
	- This is a reporting utility, not a decision-making system.
	
	Part of MVP-002: Save, Config, and Database Foundation.
--]]

-- Log prefix for all persistence reporter messages.
local LOG_PREFIX = "[PersistenceReporter]"

local PersistenceReporter = {}

--[[
	PersistenceReporter.reportLoadFailure(userId: any, errorCategory: string?)
	
	Reports a player data load failure.
	
	Logs:
	- The userId (or a placeholder if invalid).
	- The error category string (safe, not the raw DataStore error).
	
	Does NOT expose the save data, raw error messages, or stack traces.
	Does NOT mutate any session state.
--]]
function PersistenceReporter.reportLoadFailure(userId: any, errorCategory: string?)
	local safeUserId: string
	if type(userId) == "number" and userId > 0 then
		safeUserId = tostring(math.floor(userId))
	else
		safeUserId = "[invalid_userId]"
	end

	local safeCategory: string
	if type(errorCategory) == "string" and errorCategory ~= "" then
		safeCategory = errorCategory
	else
		safeCategory = "unknown_error"
	end

	warn(string.format(
		"%s LOAD FAILURE | userId: %s | errorCategory: %s",
		LOG_PREFIX,
		safeUserId,
		safeCategory
	))
end

--[[
	PersistenceReporter.reportSaveFailure(userId: any, errorCategory: string?)
	
	Reports a player data save failure.
	
	Logs:
	- The userId (or a placeholder if invalid).
	- The error category string (safe, not the raw DataStore error).
	
	Does NOT expose the save data, raw error messages, or stack traces.
	Does NOT mutate any session state.
--]]
function PersistenceReporter.reportSaveFailure(userId: any, errorCategory: string?)
	local safeUserId: string
	if type(userId) == "number" and userId > 0 then
		safeUserId = tostring(math.floor(userId))
	else
		safeUserId = "[invalid_userId]"
	end

	local safeCategory: string
	if type(errorCategory) == "string" and errorCategory ~= "" then
		safeCategory = errorCategory
	else
		safeCategory = "unknown_error"
	end

	warn(string.format(
		"%s SAVE FAILURE | userId: %s | errorCategory: %s",
		LOG_PREFIX,
		safeUserId,
		safeCategory
	))
end

--[[
	PersistenceReporter.reportInfo(message: string)
	
	Logs a general informational message for persistence lifecycle events.
	Use for expected events like load success, save success, new player initialized.
	
	Does NOT expose data contents.
--]]
function PersistenceReporter.reportInfo(message: string)
	if type(message) == "string" then
		print(string.format("%s %s", LOG_PREFIX, message))
	end
end

return PersistenceReporter

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "persistence")
getOrCreateModule(p, "SaveKeyBuilder", [====[
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

]====])

return 'Restore chunk 3 complete!'