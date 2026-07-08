--[[
	StatePatterns
	Location: src/client/views/StatePatterns.luau

	Standardized presentation states for UI screens with theme support.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)

local StatePatterns = {}

local function _createStateOverlay(name: string, text: string): Frame
	local overlay = UIComponents.createBaseContainer()
	overlay.Name = name
	
	local bg = UIComponents.createBasePanel()
	bg.BackgroundTransparency = 0.15
	bg.Parent = overlay
	
	local label = UIComponents.createBaseLabel(text)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Font = Theme.Fonts.Bold
	label.TextSize = 24
	label.Parent = overlay
	
	return overlay
end

function StatePatterns.Loading(parent: Instance): Frame
	local state = _createStateOverlay("LoadingState", "Loading...")
	
	-- Spinning inline loader indicator
	local spinner = Instance.new("Frame")
	spinner.Name = "Spinner"
	spinner.Size = UDim2.new(0, 36, 0, 36)
	spinner.Position = UDim2.new(0.5, -18, 0.5, 40)
	spinner.BackgroundColor3 = Theme.Colors.Primary
	spinner.BorderSizePixel = 0
	spinner.Parent = state
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = spinner
	
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Theme.Colors.White
	stroke.Parent = spinner
	
	task.spawn(function()
		while state.Parent do
			spinner.Rotation = (spinner.Rotation + 6) % 360
			task.wait(0.02)
		end
	end)
	
	if parent then state.Parent = parent end
	return state
end

function StatePatterns.Empty(parent: Instance, message: string?): Frame
	local state = _createStateOverlay("EmptyState", message or "No items found.")
	local label = state:FindFirstChild("BaseLabel", true)
	if label and label:IsA("TextLabel") then
		label.TextColor3 = Theme.Colors.Muted
	end
	
	if parent then state.Parent = parent end
	return state
end

function StatePatterns.Error(parent: Instance, message: string?): Frame
	local state = _createStateOverlay("ErrorState", message or "An error occurred.")
	local label = state:FindFirstChild("BaseLabel", true)
	if label and label:IsA("TextLabel") then
		label.TextColor3 = Theme.Colors.Error
	end
	if parent then state.Parent = parent end
	return state
end

function StatePatterns.Disconnected(parent: Instance): Frame
	local state = _createStateOverlay("DisconnectedState", "Disconnected from server.")
	local label = state:FindFirstChild("BaseLabel", true)
	if label and label:IsA("TextLabel") then
		label.TextColor3 = Theme.Colors.Muted
	end
	if parent then state.Parent = parent end
	return state
end

function StatePatterns.Retry(parent: Instance, callback: () -> (), message: string?): Frame
	local state = UIComponents.createBaseContainer()
	state.Name = "RetryState"
	
	local bg = UIComponents.createBasePanel()
	bg.BackgroundTransparency = 0.15
	bg.Parent = state
	
	local label = UIComponents.createBaseLabel(message or "Action failed. Please try again.")
	label.Size = UDim2.new(1, 0, 0.6, 0)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Bottom
	label.Font = Theme.Fonts.Bold
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
