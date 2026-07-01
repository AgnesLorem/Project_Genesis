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
