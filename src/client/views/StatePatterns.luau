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
