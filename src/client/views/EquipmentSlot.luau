local UIComponents = require(script.Parent.UIComponents)

local EquipmentSlot = {}

function EquipmentSlot.create(slotSnapshot: any, onUnequip: (string) -> ())
	local panel = UIComponents.createBasePanel()
	panel.Name = "EquipmentSlot_" .. tostring(slotSnapshot.slotId)
	panel.Size = UDim2.new(1, 0, 0, 86)
	panel.BackgroundColor3 = Color3.fromRGB(34, 34, 34)

	local label = UIComponents.createBaseLabel(string.upper(tostring(slotSnapshot.slotId or "slot")))
	label.Name = "SlotLabel"
	label.Size = UDim2.new(0, 120, 0, 26)
	label.Position = UDim2.new(0, 16, 0, 10)
	label.TextSize = 18
	label.Parent = panel

	local itemName = slotSnapshot.item and slotSnapshot.item.displayName or "Empty"
	local itemLabel = UIComponents.createBaseLabel(itemName)
	itemLabel.Name = "ItemLabel"
	itemLabel.Size = UDim2.new(1, -170, 0, 26)
	itemLabel.Position = UDim2.new(0, 16, 0, 46)
	itemLabel.TextSize = 18
	itemLabel.Parent = panel

	if slotSnapshot.isOccupied == true then
		local button = UIComponents.createBaseButton("Unequip")
		button.Name = "UnequipButton"
		button.Size = UDim2.new(0, 120, 0, 40)
		button.Position = UDim2.new(1, -136, 0, 23)
		button.Parent = panel
		button.MouseButton1Click:Connect(function()
			onUnequip(slotSnapshot.slotId)
		end)
	end

	return panel
end

return EquipmentSlot
