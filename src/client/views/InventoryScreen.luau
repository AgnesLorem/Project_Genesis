--[[
	InventoryScreen
	Location: src/client/views/InventoryScreen.luau

	Displays the player's items inventory. Consumes Theme design tokens and animates.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local AnimationService = require(script.Parent.AnimationService)

local InventoryScreen = {}

function InventoryScreen.create(snapshot: any, onRefresh: () -> (), onSelectItem: (any) -> (), onClose: () -> ())
	local screen = UIComponents.createBaseContainer()
	screen.Name = "InventoryScreen"

	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	-- Notch safe area padding
	local safeArea = Instance.new("UIPadding")
	safeArea.PaddingLeft = UDim.new(0, 32)
	safeArea.PaddingRight = UDim.new(0, 32)
	safeArea.PaddingTop = UDim.new(0, 24)
	safeArea.PaddingBottom = UDim.new(0, 24)
	safeArea.Parent = panel

	local title = UIComponents.createBaseLabel("Inventory")
	title.Name = "Title"
	title.Size = UDim2.new(0.5, 0, 0, 44)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.Font = Theme.Fonts.Header
	title.TextSize = 28
	title.Parent = panel

	-- Action buttons (Close / Refresh) in top right
	local closeButton = UIComponents.createBaseButton("✕ Close")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 110, 0, 44)
	closeButton.Position = UDim2.new(1, -236, 0, 0)
	closeButton.BackgroundColor3 = Theme.Colors.Error
	closeButton.Parent = panel
	closeButton.MouseButton1Click:Connect(onClose)
	AnimationService.hoverScale(closeButton, Theme.Colors.Error, Theme.Colors.Error)

	local refreshButton = UIComponents.createBaseButton("Refresh")
	refreshButton.Name = "RefreshButton"
	refreshButton.Size = UDim2.new(0, 110, 0, 44)
	refreshButton.Position = UDim2.new(1, -110, 0, 0)
	refreshButton.BackgroundColor3 = Theme.Colors.Primary
	refreshButton.Parent = panel
	refreshButton.MouseButton1Click:Connect(onRefresh)

	local list = Instance.new("ScrollingFrame")
	list.Name = "ItemList"
	list.BackgroundTransparency = 1
	list.Size = UDim2.new(1, 0, 0.76, 0)
	list.Position = UDim2.new(0, 0, 0, 64)
	list.ScrollBarThickness = 6
	list.ScrollBarImageColor3 = Theme.Colors.Border
	list.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.Parent = list

	local layoutConn = layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
	end)

	screen.Destroying:Connect(function()
		layoutConn:Disconnect()
	end)

	for _, item in ipairs(snapshot.items or {}) do
		local row = UIComponents.createBasePanel()
		row.Name = "ItemRow_" .. item.itemId
		row.Size = UDim2.new(1, -6, 0, 76)
		row.Parent = list

		local rarity = "Common"
		if item.rarity == "rare" or item.rarity == "Rare" then
			rarity = "Rare"
		elseif
			item.rarity == "epic"
			or item.rarity == "Epic"
			or item.rarity == "legendary"
			or item.rarity == "Legendary"
		then
			rarity = "Legendary"
		end

		UIComponents.applyRarityBorder(row, rarity)

		local icon = UIComponents.createBasePanel()
		icon.Name = "IconPlaceholder"
		icon.Size = UDim2.new(0, 48, 0, 48)
		icon.Position = UDim2.new(0, 14, 0.5, -24)
		icon.Parent = row

		local nameLabel = UIComponents.createBaseLabel(item.displayName or item.itemId)
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(0.6, 0, 0, 24)
		nameLabel.Position = UDim2.new(0, 76, 0, 12)
		nameLabel.Font = Theme.Fonts.Bold
		nameLabel.TextSize = 18
		nameLabel.Parent = row

		local metaLabel = UIComponents.createBaseLabel(
			string.format(
				"%s   |   %s   |   Qty %d",
				tostring(item.rarity or "Common"),
				tostring(item.itemType or "item"),
				item.quantity or 1
			)
		)
		metaLabel.Name = "MetaLabel"
		metaLabel.Size = UDim2.new(0.6, 0, 0, 22)
		metaLabel.Position = UDim2.new(0, 76, 0, 38)
		metaLabel.Font = Theme.Fonts.Regular
		metaLabel.TextSize = 14
		metaLabel.TextColor3 = Theme.Colors.Muted
		metaLabel.Parent = row

		local tooltipButton = UIComponents.createBaseButton("Details")
		tooltipButton.Name = "DetailsButton"
		tooltipButton.Size = UDim2.new(0, 110, 0, 44) -- >= 44 px target size
		tooltipButton.Position = UDim2.new(1, -126, 0.5, -22)
		tooltipButton.BackgroundColor3 = Theme.Colors.Primary
		tooltipButton.Parent = row
		tooltipButton.MouseButton1Click:Connect(function()
			onSelectItem(item)
		end)
	end

	return screen
end

return InventoryScreen
