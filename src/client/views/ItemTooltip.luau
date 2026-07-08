--[[
	ItemTooltip
	Location: src/client/views/ItemTooltip.luau

	Modal overlay displaying detailed stats, descriptions, and rarity highlights
	for inventory items and equipment. Consumes Theme tokens.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local AnimationService = require(script.Parent.AnimationService)

local ItemTooltip = {}

local function _statsText(equipment: any): string
	if not equipment or type(equipment.statBonuses) ~= "table" then
		return ""
	end

	local stats = equipment.statBonuses
	return string.format(
		"HP +%d  |  ATK +%d  |  DEF +%d  |  SPD +%d",
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
	panel.ZIndex = Theme.ZIndex.Modal + 1
	panel.Parent = modal

	-- Apply rarity border color
	local rarity = "Common"
	if item.rarity == "rare" or item.rarity == "Rare" then
		rarity = "Rare"
	elseif item.rarity == "epic" or item.rarity == "Epic" or item.rarity == "legendary" or item.rarity == "Legendary" then
		rarity = "Legendary"
	end
	UIComponents.applyRarityBorder(panel, rarity)

	local icon = UIComponents.createBasePanel()
	icon.Name = "PlaceholderIcon"
	icon.Size = UDim2.new(0, 72, 0, 72)
	icon.Position = UDim2.new(0, 24, 0, 24)
	icon.ZIndex = Theme.ZIndex.Modal + 2
	icon.Parent = panel

	local iconLabel = UIComponents.createBaseLabel("ICON")
	iconLabel.Size = UDim2.new(1, 0, 1, 0)
	iconLabel.Font = Theme.Fonts.Bold
	iconLabel.TextXAlignment = Enum.TextXAlignment.Center
	iconLabel.TextYAlignment = Enum.TextYAlignment.Center
	iconLabel.ZIndex = Theme.ZIndex.Modal + 3
	iconLabel.Parent = icon

	local title = UIComponents.createBaseLabel(item.displayName or item.itemId or "Item")
	title.Name = "Title"
	title.Size = UDim2.new(1, -130, 0, 32)
	title.Position = UDim2.new(0, 112, 0, 24)
	title.Font = Theme.Fonts.Header
	title.TextSize = 24
	title.ZIndex = Theme.ZIndex.Modal + 2
	title.Parent = panel

	local meta = UIComponents.createBaseLabel(string.format("%s   |   %s", tostring(item.rarity or "Common"), tostring(item.itemType or "item")))
	meta.Name = "Meta"
	meta.Size = UDim2.new(1, -130, 0, 24)
	meta.Position = UDim2.new(0, 112, 0, 62)
	meta.Font = Theme.Fonts.Regular
	meta.TextSize = 15
	meta.TextColor3 = Theme.Colors.Muted
	meta.ZIndex = Theme.ZIndex.Modal + 2
	meta.Parent = panel

	local description = UIComponents.createBaseLabel(item.description or "")
	description.Name = "Description"
	description.Size = UDim2.new(1, -48, 0, 72)
	description.Position = UDim2.new(0, 24, 0, 116)
	description.Font = Theme.Fonts.Regular
	description.TextWrapped = true
	description.TextYAlignment = Enum.TextYAlignment.Top
	description.ZIndex = Theme.ZIndex.Modal + 2
	description.Parent = panel

	local stats = UIComponents.createBaseLabel(_statsText(equipment))
	stats.Name = "Stats"
	stats.Size = UDim2.new(1, -48, 0, 26)
	stats.Position = UDim2.new(0, 24, 0, 198)
	stats.Font = Theme.Fonts.Bold
	stats.TextSize = 14
	stats.TextColor3 = Theme.Colors.Accent
	stats.ZIndex = Theme.ZIndex.Modal + 2
	stats.Parent = panel

	local closeButton = UIComponents.createBaseButton("Close")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 140, 0, 44) -- >= 44 px target size
	closeButton.Position = UDim2.new(0.5, -70, 1, -62)
	closeButton.BackgroundColor3 = Theme.Colors.Error
	closeButton.ZIndex = Theme.ZIndex.Modal + 2
	closeButton.Parent = panel
	closeButton.MouseButton1Click:Connect(onClose)
	AnimationService.hoverScale(closeButton, Theme.Colors.Error, Theme.Colors.Error)

	-- Mount animation
	AnimationService.scalePop(panel)

	return modal
end

return ItemTooltip
