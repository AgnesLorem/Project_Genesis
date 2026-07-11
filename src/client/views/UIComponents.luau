--[[
	UIComponents
	Location: src/client/views/UIComponents.luau

	Foundational UI elements using Theme tokens and rounded/frosted elements.
--]]

local Theme = require(script.Parent.Theme)
local AnimationService = require(script.Parent.AnimationService)
local VFXHelper = require(script.Parent.Parent.effects.VFXHelper)

local UIComponents = {}

function UIComponents.createBaseContainer(): Frame
	local container = Instance.new("Frame")
	container.Name = "BaseContainer"
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 1, 0)
	container.Position = UDim2.new(0, 0, 0, 0)
	return container
end

function UIComponents.createBasePanel(): Frame
	local panel = Instance.new("Frame")
	panel.Name = "BasePanel"
	panel.BackgroundColor3 = Theme.Colors.Background
	panel.BorderSizePixel = 0
	panel.Size = UDim2.new(1, 0, 1, 0)

	-- Rounded corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.CornerRadius
	corner.Parent = panel

	-- Border outline for frosted-glass design
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.StrokeThickness
	stroke.Color = Theme.Colors.BorderTransparent
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Transparency = 0.6
	stroke.Parent = panel

	return panel
end

function UIComponents.createBaseButton(text: string): TextButton
	local button = Instance.new("TextButton")
	button.Name = "BaseButton"
	button.Text = text or "Button"
	button.BackgroundColor3 = Theme.Colors.Primary
	button.TextColor3 = Theme.Colors.White
	button.BorderSizePixel = 0
	button.Size = UDim2.new(0, 150, 0, 44) -- Ensure >= 44 px vertical height for accessibility
	button.Font = Theme.Fonts.Bold
	button.TextSize = 16
	button.TextWrapped = true

	-- Rounded corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.CornerRadius
	corner.Parent = button

	-- Hover animation (returns clean up function if needed)
	AnimationService.hoverScale(button)
	VFXHelper.buttonPress(button)

	return button
end

function UIComponents.createBaseLabel(text: string): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = "BaseLabel"
	label.Text = text or "Label"
	label.BackgroundTransparency = 1
	label.TextColor3 = Theme.Colors.White
	label.Size = UDim2.new(0, 200, 0, 30)
	label.Font = Theme.Fonts.Regular
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true -- Ensure text wrapping for accessibility
	return label
end

function UIComponents.createBaseModal(): Frame
	local modal = Instance.new("Frame")
	modal.Name = "BaseModal"
	modal.BackgroundColor3 = Color3.new(0, 0, 0)
	modal.BackgroundTransparency = 0.6
	modal.BorderSizePixel = 0
	modal.Size = UDim2.new(1, 0, 1, 0)
	modal.ZIndex = Theme.ZIndex.Modal
	modal.Active = true
	return modal
end

function UIComponents.applyRarityBorder(instance: GuiObject, rarity: string)
	local existing = instance:FindFirstChild("RarityBorder")
	if existing then
		existing:Destroy()
	end

	local color = Theme.Colors.Common
	if rarity == "Rare" then
		color = Theme.Colors.Rare
	elseif rarity == "Legendary" then
		color = Theme.Colors.Legendary
	end

	local stroke = Instance.new("UIStroke")
	stroke.Name = "RarityBorder"
	stroke.Thickness = Theme.StrokeThickness or 1
	stroke.Color = color
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
end

function UIComponents.applySelectionOutline(instance: GuiObject)
	local existing = instance:FindFirstChild("SelectionOutline")
	if existing then
		existing:Destroy()
	end

	local stroke = Instance.new("UIStroke")
	stroke.Name = "SelectionOutline"
	stroke.Thickness = Theme.StrokeThicknessSelected
	stroke.Color = Theme.Colors.SelectionOutline
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
end

function UIComponents.removeSelectionOutline(instance: GuiObject)
	local existing = instance:FindFirstChild("SelectionOutline")
	if existing then
		existing:Destroy()
	end
end

function UIComponents.createConfirmationModal(
	message: string,
	confirmCallback: () -> (),
	cancelCallback: (() -> ())?
): Frame
	local modal = UIComponents.createBaseModal()
	modal.Name = "ConfirmationModal"

	local panel = UIComponents.createBasePanel()
	panel.Name = "DialogPanel"
	panel.Size = UDim2.new(0, 400, 0, 200)
	panel.Position = UDim2.new(0.5, -200, 0.5, -100)
	panel.Parent = modal

	local label = UIComponents.createBaseLabel(message)
	label.Size = UDim2.new(1, -40, 0, 80)
	label.Position = UDim2.new(0, 20, 0, 20)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Font = Theme.Fonts.Bold
	label.TextSize = 18
	label.TextWrapped = true
	label.Parent = panel

	local confirmBtn = UIComponents.createBaseButton("Confirm")
	confirmBtn.Name = "ConfirmButton"
	confirmBtn.Size = UDim2.new(0, 140, 0, 44)
	confirmBtn.Position = UDim2.new(0.5, -150, 1, -64)
	confirmBtn.BackgroundColor3 = Theme.Colors.Success
	confirmBtn.Parent = panel

	local cancelBtn = UIComponents.createBaseButton("Cancel")
	cancelBtn.Name = "CancelButton"
	cancelBtn.Size = UDim2.new(0, 140, 0, 44)
	cancelBtn.Position = UDim2.new(0.5, 10, 1, -64)
	cancelBtn.BackgroundColor3 = Theme.Colors.Error
	cancelBtn.Parent = panel

	confirmBtn.MouseButton1Click:Connect(confirmCallback)
	cancelBtn.MouseButton1Click:Connect(function()
		if cancelCallback then
			cancelCallback()
		end
	end)

	-- Hover Scaling
	AnimationService.hoverScale(confirmBtn, Theme.Colors.Success, Theme.Colors.Success)
	AnimationService.hoverScale(cancelBtn, Theme.Colors.Error, Theme.Colors.Error)

	return modal
end

return UIComponents
