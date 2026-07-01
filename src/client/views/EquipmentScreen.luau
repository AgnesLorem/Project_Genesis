local EquipmentSlot = require(script.Parent.EquipmentSlot)
local UIComponents = require(script.Parent.UIComponents)

local EquipmentScreen = {}

local function _slotFromItemTags(item: any): string?
	for _, tag in ipairs(item.tags or {}) do
		if tag == "weapon" or tag == "armor" or tag == "accessory" then
			return tag
		end
	end
	return nil
end

local function _bonusText(bonuses: any): string
	return string.format(
		"Bonuses: HP +%d | ATK +%d | DEF +%d | SPD +%d",
		bonuses and bonuses.hp or 0,
		bonuses and bonuses.atk or 0,
		bonuses and bonuses.def or 0,
		bonuses and bonuses.spd or 0
	)
end

function EquipmentScreen.create(equipmentSnapshot: any, inventorySnapshot: any, onEquip: (string, string) -> (), onUnequip: (string) -> (), onRefresh: () -> (), onTooltip: (any) -> ())
	local screen = UIComponents.createBaseContainer()
	screen.Name = "EquipmentScreen"

	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	local title = UIComponents.createBaseLabel("Equipment")
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

	local bonusLabel = UIComponents.createBaseLabel(_bonusText(equipmentSnapshot.statBonuses))
	bonusLabel.Name = "BonusLabel"
	bonusLabel.Size = UDim2.new(1, -72, 0, 28)
	bonusLabel.Position = UDim2.new(0, 36, 0, 82)
	bonusLabel.TextSize = 18
	bonusLabel.Parent = panel

	local slotFrame = Instance.new("Frame")
	slotFrame.Name = "Slots"
	slotFrame.BackgroundTransparency = 1
	slotFrame.Size = UDim2.new(0.46, -44, 1, -140)
	slotFrame.Position = UDim2.new(0, 36, 0, 124)
	slotFrame.Parent = panel

	local slotLayout = Instance.new("UIListLayout")
	slotLayout.Padding = UDim.new(0, 12)
	slotLayout.Parent = slotFrame

	for _, slot in ipairs(equipmentSnapshot.slots or {}) do
		EquipmentSlot.create(slot, onUnequip).Parent = slotFrame
	end

	local inventoryFrame = Instance.new("ScrollingFrame")
	inventoryFrame.Name = "EquipmentInventory"
	inventoryFrame.BackgroundTransparency = 1
	inventoryFrame.Size = UDim2.new(0.54, -44, 1, -140)
	inventoryFrame.Position = UDim2.new(0.46, 8, 0, 124)
	inventoryFrame.ScrollBarThickness = 6
	inventoryFrame.Parent = panel

	local inventoryLayout = Instance.new("UIListLayout")
	inventoryLayout.Padding = UDim.new(0, 10)
	inventoryLayout.Parent = inventoryFrame
	inventoryLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		inventoryFrame.CanvasSize = UDim2.new(0, 0, 0, inventoryLayout.AbsoluteContentSize.Y)
	end)

	for _, item in ipairs(inventorySnapshot.items or {}) do
		if item.itemType == "equipment" then
			local slotId = _slotFromItemTags(item)
			local row = UIComponents.createBasePanel()
			row.Name = "EquipRow_" .. item.itemId
			row.Size = UDim2.new(1, -8, 0, 76)
			row.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
			row.Parent = inventoryFrame

			local nameLabel = UIComponents.createBaseLabel(item.displayName)
			nameLabel.Size = UDim2.new(1, -250, 0, 24)
			nameLabel.Position = UDim2.new(0, 16, 0, 10)
			nameLabel.TextSize = 19
			nameLabel.Parent = row

			local metaLabel = UIComponents.createBaseLabel(string.format("%s | %s", item.rarity, slotId or "unknown"))
			metaLabel.Size = UDim2.new(1, -250, 0, 22)
			metaLabel.Position = UDim2.new(0, 16, 0, 42)
			metaLabel.TextSize = 15
			metaLabel.Parent = row

			local detailsButton = UIComponents.createBaseButton("Details")
			detailsButton.Size = UDim2.new(0, 94, 0, 36)
			detailsButton.Position = UDim2.new(1, -210, 0, 20)
			detailsButton.Parent = row
			detailsButton.MouseButton1Click:Connect(function()
				onTooltip(item)
			end)

			local equipButton = UIComponents.createBaseButton("Equip")
			equipButton.Size = UDim2.new(0, 94, 0, 36)
			equipButton.Position = UDim2.new(1, -104, 0, 20)
			equipButton.Parent = row
			equipButton.Active = slotId ~= nil
			equipButton.AutoButtonColor = slotId ~= nil
			if not slotId then
				equipButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			end
			equipButton.MouseButton1Click:Connect(function()
				if slotId then
					onEquip(item.itemId, slotId)
				end
			end)
		end
	end

	return screen
end

return EquipmentScreen
