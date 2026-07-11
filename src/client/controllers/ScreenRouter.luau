--[[
	ScreenRouter
	Location: src/client/controllers/ScreenRouter.luau

	Client Screen Router.
	- Register screens
	- Switch active screen
	- Reject unknown screen IDs
	- Broadcast screen changed event
	- No gameplay logic

	Part of MVP-003: UI Foundation.
--]]

local ScreenRouter = {}

-- Store registered screens: { [screenId: string] = ScreenGui }
local _screens = {}
local _activeScreenId = nil
local _screenChangedEvent = Instance.new("BindableEvent")

ScreenRouter.OnScreenChanged = _screenChangedEvent.Event

--[[
	ScreenRouter.registerScreen(screenId, screenGui)
	
	Registers a screen with the router. The screen should be a ScreenGui.
	It is hidden by default.
--]]
function ScreenRouter.registerScreen(screenId: string, screenGui: Instance)
	assert(type(screenId) == "string" and screenId ~= "", "[ScreenRouter] screenId must be a non-empty string.")
	assert(
		typeof(screenGui) == "Instance" and screenGui:IsA("ScreenGui"),
		"[ScreenRouter] screenGui must be a ScreenGui."
	)

	if _screens[screenId] then
		warn(string.format("[ScreenRouter] Screen '%s' is already registered. Overwriting.", screenId))
	end

	-- Ensure the screen is hidden initially
	screenGui.Enabled = false
	_screens[screenId] = screenGui
end

--[[
	ScreenRouter.switchScreen(screenId)
	
	Switches the active screen to the given screenId.
	Rejects unknown screen IDs.
--]]
function ScreenRouter.switchScreen(screenId: string)
	assert(type(screenId) == "string" and screenId ~= "", "[ScreenRouter] screenId must be a non-empty string.")

	if not _screens[screenId] then
		warn(string.format("[ScreenRouter] Rejected unknown screen ID: '%s'", screenId))
		return false
	end

	-- Hide current screen if any
	if _activeScreenId and _screens[_activeScreenId] then
		_screens[_activeScreenId].Enabled = false
	end

	-- Show new screen
	_activeScreenId = screenId
	_screens[_activeScreenId].Enabled = true

	-- Broadcast change
	_screenChangedEvent:Fire(_activeScreenId)
	return true
end

--[[
	ScreenRouter.getActiveScreenId()
	
	Returns the currently active screen ID, or nil if none.
--]]
function ScreenRouter.getActiveScreenId(): string?
	return _activeScreenId
end

return ScreenRouter
