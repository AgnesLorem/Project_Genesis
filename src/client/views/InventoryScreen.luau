local UIComponents = require(script.Parent.UIComponents)

local InventoryScreen = {}

function InventoryScreen.create(snapshot: any, onRefresh: () -> (), onSelectItem: (any) -> ())
	local screen = UIComponents.createBaseContainer()
	screen.Name = "InventoryScreen"

	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	local title = UIComponents.createBaseLabel("Inventory")
	title.Name = "Title"
	title.Size = UDim2.new(1, -220, 0, 44)
	title.Position = UDim2.new(0, 36, 0, 28)
	title.TextSize = 30
	title.Parent = panel

	local refreshButton = UIComponents.createBaseButton("Refresh")
	refreshButton.Name = "RefreshButton"
	refreshButton.Size = UDim2.new(0, 130, 0, 42)
	refreshButton.Position = UDim2.new(1, -166, 0, 30)
	refreshButton.Parent = panel
	refreshButton.MouseButton1Click:Connect(onRefresh)

	local list = Instance.new("ScrollingFrame")
	list.Name = "ItemList"
	list.BackgroundTransparency = 1
	list.Size = UDim2.new(1, -72, 1, -120)
	list.Position = UDim2.new(0, 36, 0, 96)
	list.ScrollBarThickness = 6
	list.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = list
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	for _, item in ipairs(snapshot.items or {}) do
		local row = UIComponents.createBaseButton("")
		row.Name = "ItemRow_" .. item.itemId
		row.Size = UDim2.new(1, -8, 0, 70)
		row.Text = ""
		row.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
		row.Parent = list

		local icon = Instance.new("Frame")
		icon.Name = "PlaceholderIcon"
		icon.Size = UDim2.new(0, 48, 0, 48)
		icon.Position = UDim2.new(0, 12, 0, 11)
		icon.BackgroundColor3 = Color3.fromRGB(72, 72, 72)
		icon.Parent = row

		local nameLabel = UIComponents.createBaseLabel(item.displayName)
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, -250, 0, 24)
		nameLabel.Position = UDim2.new(0, 74, 0, 10)
		nameLabel.TextSize = 20
		nameLabel.Parent = row

		local metaLabel = UIComponents.createBaseLabel(string.format("%s | %s | Qty %d", item.rarity, item.itemType, item.quantity))
		metaLabel.Name = "MetaLabel"
		metaLabel.Size = UDim2.new(1, -250, 0, 22)
		metaLabel.Position = UDim2.new(0, 74, 0, 40)
		metaLabel.TextSize = 15
		metaLabel.Parent = row

		local tooltipButton = UIComponents.createBaseButton("Details")
		tooltipButton.Name = "DetailsButton"
		tooltipButton.Size = UDim2.new(0, 110, 0, 38)
		tooltipButton.Position = UDim2.new(1, -126, 0, 16)
		tooltipButton.Parent = row
		tooltipButton.MouseButton1Click:Connect(function()
			onSelectItem(item)
		end)
	end

	return screen
end

return InventoryScreen
