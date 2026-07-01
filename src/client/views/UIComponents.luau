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
