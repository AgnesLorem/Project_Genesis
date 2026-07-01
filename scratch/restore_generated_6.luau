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
local p = ensurePath(game:GetService("StarterPlayer").StarterPlayerScripts.Client, "models")
getOrCreateModule(p, "ClientState", [====[
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

]====])

local p = ensurePath(game:GetService("StarterPlayer").StarterPlayerScripts.Client, "views")
getOrCreateModule(p, "StatePatterns", [====[
--[[
	StatePatterns
	Location: src/client/views/StatePatterns.luau

	Standardized presentation states for UI screens.
	Provides: Loading, Empty, Error, Disconnected, Retry.

	Part of MVP-003: UI Foundation.
--]]

local UIComponents = require(script.Parent.UIComponents)

local StatePatterns = {}

local function _createStateOverlay(name: string, text: string): Frame
	local overlay = UIComponents.createBaseContainer()
	overlay.Name = name
	
	local bg = UIComponents.createBasePanel()
	bg.BackgroundTransparency = 0.2
	bg.Parent = overlay
	
	local label = UIComponents.createBaseLabel(text)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextSize = 24
	label.Parent = overlay
	
	return overlay
end

--[[
	StatePatterns.Loading(parent) -> Frame
	Shows when a request is in flight.
--]]
function StatePatterns.Loading(parent: Instance): Frame
	local state = _createStateOverlay("LoadingState", "Loading...")
	if parent then state.Parent = parent end
	return state
end

--[[
	StatePatterns.Empty(parent, message) -> Frame
	Shows when a list or collection has no items.
--]]
function StatePatterns.Empty(parent: Instance, message: string?): Frame
	local state = _createStateOverlay("EmptyState", message or "No items found.")
	if parent then state.Parent = parent end
	return state
end

--[[
	StatePatterns.Error(parent, message) -> Frame
	Shows when an operation fails.
--]]
function StatePatterns.Error(parent: Instance, message: string?): Frame
	local state = _createStateOverlay("ErrorState", message or "An error occurred.")
	local label = state:FindFirstChild("BaseLabel", true)
	if label and label:IsA("TextLabel") then
		label.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
	if parent then state.Parent = parent end
	return state
end

--[[
	StatePatterns.Disconnected(parent) -> Frame
	Shows when the server connection drops.
--]]
function StatePatterns.Disconnected(parent: Instance): Frame
	local state = _createStateOverlay("DisconnectedState", "Disconnected from server.")
	local label = state:FindFirstChild("BaseLabel", true)
	if label and label:IsA("TextLabel") then
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
	end
	if parent then state.Parent = parent end
	return state
end

--[[
	StatePatterns.Retry(parent, callback, message) -> Frame
	Shows when a failure can be retried.
--]]
function StatePatterns.Retry(parent: Instance, callback: () -> (), message: string?): Frame
	local state = UIComponents.createBaseContainer()
	state.Name = "RetryState"
	
	local bg = UIComponents.createBasePanel()
	bg.BackgroundTransparency = 0.2
	bg.Parent = state
	
	local label = UIComponents.createBaseLabel(message or "Action failed. Please try again.")
	label.Size = UDim2.new(1, 0, 0.6, 0)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Bottom
	label.TextSize = 20
	label.Parent = state
	
	local btn = UIComponents.createBaseButton("Retry")
	btn.AnchorPoint = Vector2.new(0.5, 0)
	btn.Position = UDim2.new(0.5, 0, 0.6, 20)
	btn.Parent = state
	
	btn.Activated:Connect(function()
		if callback then callback() end
	end)
	
	if parent then state.Parent = parent end
	return state
end

return StatePatterns

]====])

local p = ensurePath(game:GetService("StarterPlayer").StarterPlayerScripts.Client, "views")
getOrCreateModule(p, "UIComponents", [====[
--[[
	UIComponents
	Location: src/client/views/UIComponents.luau

	Minimal foundational UI elements using pure Roblox UI with Luau only.
	No external dependencies.
	No animation, no theme, no gameplay-specific widgets.

	Provides:
	- Base Panel
	- Base Button
	- Base Label
	- Base Container
	- Base Modal placeholder

	Part of MVP-003: UI Foundation.
--]]

local UIComponents = {}

--[[
	UIComponents.createBaseContainer() -> Frame
	Invisible container for layout organization.
--]]
function UIComponents.createBaseContainer(): Frame
	local container = Instance.new("Frame")
	container.Name = "BaseContainer"
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 1, 0)
	container.Position = UDim2.new(0, 0, 0, 0)
	return container
end

--[[
	UIComponents.createBasePanel() -> Frame
	Visible background panel.
--]]
function UIComponents.createBasePanel(): Frame
	local panel = Instance.new("Frame")
	panel.Name = "BasePanel"
	panel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	panel.BorderSizePixel = 0
	panel.Size = UDim2.new(1, 0, 1, 0)
	return panel
end

--[[
	UIComponents.createBaseButton(text) -> TextButton
	Standard clickable button.
--]]
function UIComponents.createBaseButton(text: string): TextButton
	local button = Instance.new("TextButton")
	button.Name = "BaseButton"
	button.Text = text or "Button"
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BorderSizePixel = 0
	button.Size = UDim2.new(0, 150, 0, 50)
	button.Font = Enum.Font.SourceSans
	button.TextSize = 18
	return button
end

--[[
	UIComponents.createBaseLabel(text) -> TextLabel
	Standard text label.
--]]
function UIComponents.createBaseLabel(text: string): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = "BaseLabel"
	label.Text = text or "Label"
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Size = UDim2.new(0, 200, 0, 30)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	return label
end

--[[
	UIComponents.createBaseModal() -> Frame
	Blocking modal background placeholder.
--]]
function UIComponents.createBaseModal(): Frame
	local modal = Instance.new("Frame")
	modal.Name = "BaseModal"
	modal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	modal.BackgroundTransparency = 0.5
	modal.BorderSizePixel = 0
	modal.Size = UDim2.new(1, 0, 1, 0)
	modal.ZIndex = 100 -- Ensure it blocks underlying UI
	modal.Active = true -- Block clicks
	return modal
end

return UIComponents

]====])

return 'Restore chunk 6 complete!'