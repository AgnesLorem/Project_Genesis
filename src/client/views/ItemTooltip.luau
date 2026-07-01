local UIComponents = require(script.Parent.UIComponents)

local ItemTooltip = {}

local function _statsText(equipment: any): string
	if not equipment or type(equipment.statBonuses) ~= "table" then
		return ""
	end

	local stats = equipment.statBonuses
	return string.format(
		"HP +%d | ATK +%d | DEF +%d | SPD +%d",
		stats.hp or 0,
		stats.atk or 0,
		stats.def or 0,
		stats.spd or 0
	)
end

function ItemTooltip.create(item: any, equipment: any, onClose: () -> ())
	local modal = UIComponents.createBaseModal()
	modal.Name = "ItemTooltipModal"

	local panel = UIComponents.createBasePanel()
	panel.Name = "ItemTooltip"
	panel.Size = UDim2.new(0, 420, 0, 300)
	panel.Position = UDim2.new(0.5, -210, 0.5, -150)
	panel.ZIndex = 101
	panel.Parent = modal

	local icon = Instance.new("Frame")
	icon.Name = "PlaceholderIcon"
	icon.Size = UDim2.new(0, 72, 0, 72)
	icon.Position = UDim2.new(0, 24, 0, 24)
	icon.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	icon.ZIndex = 102
	icon.Parent = panel

	local iconLabel = UIComponents.createBaseLabel("ICON")
	iconLabel.Size = UDim2.new(1, 0, 1, 0)
	iconLabel.TextXAlignment = Enum.TextXAlignment.Center
	iconLabel.TextYAlignment = Enum.TextYAlignment.Center
	iconLabel.ZIndex = 103
	iconLabel.Parent = icon

	local title = UIComponents.createBaseLabel(item.displayName or item.itemId or "Item")
	title.Name = "Title"
	title.Size = UDim2.new(1, -130, 0, 32)
	title.Position = UDim2.new(0, 112, 0, 24)
	title.TextSize = 24
	title.ZIndex = 102
	title.Parent = panel

	local meta = UIComponents.createBaseLabel(string.format("%s | %s", tostring(item.rarity or "Common"), tostring(item.itemType or "item")))
	meta.Name = "Meta"
	meta.Size = UDim2.new(1, -130, 0, 24)
	meta.Position = UDim2.new(0, 112, 0, 62)
	meta.TextSize = 17
	meta.ZIndex = 102
	meta.Parent = panel

	local description = UIComponents.createBaseLabel(item.description or "")
	description.Name = "Description"
	description.Size = UDim2.new(1, -48, 0, 72)
	description.Position = UDim2.new(0, 24, 0, 116)
	description.TextWrapped = true
	description.TextYAlignment = Enum.TextYAlignment.Top
	description.ZIndex = 102
	description.Parent = panel

	local stats = UIComponents.createBaseLabel(_statsText(equipment))
	stats.Name = "Stats"
	stats.Size = UDim2.new(1, -48, 0, 26)
	stats.Position = UDim2.new(0, 24, 0, 198)
	stats.ZIndex = 102
	stats.Parent = panel

	local closeButton = UIComponents.createBaseButton("Close")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 140, 0, 42)
	closeButton.Position = UDim2.new(0.5, -70, 1, -62)
	closeButton.ZIndex = 102
	closeButton.Parent = panel
	closeButton.MouseButton1Click:Connect(onClose)

	return modal
end

return ItemTooltip
