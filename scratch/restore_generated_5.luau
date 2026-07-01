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
local p = ensurePath(game:GetService("ServerScriptService").Server, "services")
getOrCreateModule(p, "SaveService", [====[
local SaveService = {}
local mockSaves = {}

-- Persistence is entirely owned by SaveService.
-- Other services must not communicate with DataStore directly.
-- This is a stub abstraction for MVP-004 to avoid temporary in-memory ownership in CreatureService.

-- Retrieves a player's save data map
function SaveService.getPlayerSave(player: any): any
    if not mockSaves[player] then
        mockSaves[player] = {
            creatureInstances = {}
        }
    end
    return mockSaves[player]
end

-- Commits a save mutation
function SaveService.savePlayer(player: any)
    -- Stub: would mark the save as dirty or trigger a save task
end

return SaveService

]====])

local p = ensurePath(game:GetService("StarterPlayer").StarterPlayerScripts.Client, "bootstrap")
getOrCreateModule(p, "ClientBootstrap", [====[
--[[
	ClientBootstrap
	Location: src/client/bootstrap/ClientBootstrap.luau

	Client-side bootstrap shell for Project Genesis.

	This LocalScript is the entry point for all client-side systems.
	It initializes client controllers and views in the documented order.

	Current registered controllers/views: NONE (MVP-001 shell only).
	Future tasks will add their client controllers here after implementation.

	Startup sequence (planned for future tasks):
	  1. Require all approved client controllers.
	  2. Initialize each controller.
	  3. Start each controller.

	Rules:
	- This script is client-only. It must live in StarterPlayerScripts.
	- No gameplay authority is owned here (server owns truth).
	- No combat, economy, or save systems are started from the client.
	- Client bootstrap only initializes UI/presentation systems.
	- No hardcoded gameplay values.

	Part of MVP-001: Core Framework Foundation.
--]]

-- Controllers and views are required here, before bootstrap runs.
-- Example (to be added by future tasks):
--   local BattleController = require(ReplicatedStorage.Client.controllers.BattleController)
--   local HudView          = require(ReplicatedStorage.Client.views.HudView)

print("[ClientBootstrap] ═══ Project Genesis Client Starting ═══")

-- ─── Initialize Controllers ─────────────────────────────────────────────────
-- (Empty for MVP-001 — future tasks will add controller init here)

-- ─── Start Controllers ──────────────────────────────────────────────────────
-- (Empty for MVP-001 — future tasks will add controller start here)

print("[ClientBootstrap] ═══ Client Ready ═══")

]====])

local p = ensurePath(game:GetService("StarterPlayer").StarterPlayerScripts.Client, "controllers")
getOrCreateModule(p, "ScreenRouter", [====[
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
	assert(typeof(screenGui) == "Instance" and screenGui:IsA("ScreenGui"), "[ScreenRouter] screenGui must be a ScreenGui.")
	
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

]====])

return 'Restore chunk 5 complete!'