--[[
	ClientState
	Location: src/client/models/ClientState.luau

	ClientState is a presentation cache only.
	It mirrors server-approved snapshots.
	It must never become authoritative gameplay state.

	This module provides a simple key-value store for UI controllers to read
	from, and for network controllers to write into when the server sends updates.

	Part of MVP-003: UI Foundation.
--]]

local ClientState = {}

local _stateCache = {}
local _listeners = {}

--[[
	ClientState.set(key, value)
	
	Updates a key in the presentation cache.
	Fires any registered listeners for this key.
--]]
function ClientState.set(key: string, value: any)
	assert(type(key) == "string" and key ~= "", "[ClientState] Key must be a non-empty string.")
	_stateCache[key] = value

	if _listeners[key] then
		for _, callback in ipairs(_listeners[key]) do
			-- Safe execution to prevent listener errors from breaking state updates
			pcall(callback, value)
		end
	end
end

--[[
	ClientState.get(key, default)
	
	Retrieves a value from the presentation cache.
	Returns the default value if the key does not exist.
--]]
function ClientState.get(key: string, default: any): any
	assert(type(key) == "string" and key ~= "", "[ClientState] Key must be a non-empty string.")
	local value = _stateCache[key]
	if value == nil then
		return default
	end
	return value
end

--[[
	ClientState.listen(key, callback)
	
	Registers a callback to be fired whenever the given key is updated.
--]]
function ClientState.listen(key: string, callback: (any) -> ())
	assert(type(key) == "string" and key ~= "", "[ClientState] Key must be a non-empty string.")
	assert(type(callback) == "function", "[ClientState] Callback must be a function.")
	
	if not _listeners[key] then
		_listeners[key] = {}
	end
	table.insert(_listeners[key], callback)
end

--[[
	ClientState.clear(key)
	
	Clears a key from the presentation cache.
--]]
function ClientState.clear(key: string)
	assert(type(key) == "string" and key ~= "", "[ClientState] Key must be a non-empty string.")
	_stateCache[key] = nil
end

return ClientState
