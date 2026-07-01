local UIComponents = require(script.Parent.UIComponents)

local SkillPanel = {}

local function _cooldownText(skill: any): string
	if skill.skillType == "passive" then
		return "Passive"
	end
	if (skill.cooldownRemaining or 0) > 0 then
		return string.format("Cooldown %ds", skill.cooldownRemaining)
	end
	return "Ready"
end

function SkillPanel.create(snapshot: any, selectedCreatureInstanceId: string?, onRefresh: () -> (), onUseSkill: (string, string) -> ())
	local screen = UIComponents.createBaseContainer()
	screen.Name = "SkillPanel"

	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	local title = UIComponents.createBaseLabel("Skills")
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

	local creature = nil
	for _, entry in ipairs(snapshot.creatures or {}) do
		if selectedCreatureInstanceId == nil or entry.instanceId == selectedCreatureInstanceId then
			creature = entry
			break
		end
	end

	local subtitle = UIComponents.createBaseLabel(creature and string.format("%s | %s", creature.creatureId, creature.instanceId) or "No creature selected")
	subtitle.Name = "CreatureLabel"
	subtitle.Size = UDim2.new(1, -72, 0, 28)
	subtitle.Position = UDim2.new(0, 36, 0, 82)
	subtitle.TextSize = 18
	subtitle.Parent = panel

	local list = Instance.new("ScrollingFrame")
	list.Name = "SkillList"
	list.BackgroundTransparency = 1
	list.Size = UDim2.new(1, -72, 1, -132)
	list.Position = UDim2.new(0, 36, 0, 124)
	list.ScrollBarThickness = 6
	list.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = list
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	if not creature then
		local empty = UIComponents.createBaseLabel("No skills available.")
		empty.Size = UDim2.new(1, 0, 0, 40)
		empty.TextSize = 18
		empty.Parent = list
		return screen
	end

	for _, skill in ipairs(creature.skills or {}) do
		local row = UIComponents.createBasePanel()
		row.Name = "SkillRow_" .. skill.skillId
		row.Size = UDim2.new(1, -8, 0, 86)
		row.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
		row.Parent = list

		local icon = Instance.new("Frame")
		icon.Name = "IconPlaceholder"
		icon.Size = UDim2.new(0, 52, 0, 52)
		icon.Position = UDim2.new(0, 14, 0, 17)
		icon.BackgroundColor3 = Color3.fromRGB(72, 72, 72)
		icon.Parent = row

		local nameLabel = UIComponents.createBaseLabel(skill.displayName)
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, -330, 0, 24)
		nameLabel.Position = UDim2.new(0, 82, 0, 12)
		nameLabel.TextSize = 20
		nameLabel.Parent = row

		local metaLabel = UIComponents.createBaseLabel(string.format("%s | %s | %s | %.2fx", skill.rarity, skill.skillType, skill.elementType, skill.damageMultiplier))
		metaLabel.Name = "MetaLabel"
		metaLabel.Size = UDim2.new(1, -330, 0, 22)
		metaLabel.Position = UDim2.new(0, 82, 0, 38)
		metaLabel.TextSize = 15
		metaLabel.Parent = row

		local cooldownLabel = UIComponents.createBaseLabel(_cooldownText(skill))
		cooldownLabel.Name = "CooldownLabel"
		cooldownLabel.Size = UDim2.new(0, 120, 0, 24)
		cooldownLabel.Position = UDim2.new(1, -268, 0, 31)
		cooldownLabel.TextSize = 16
		cooldownLabel.TextXAlignment = Enum.TextXAlignment.Center
		cooldownLabel.Parent = row

		if skill.skillType == "active" then
			local useButton = UIComponents.createBaseButton("Use")
			useButton.Name = "UseButton"
			useButton.Size = UDim2.new(0, 110, 0, 40)
			useButton.Position = UDim2.new(1, -126, 0, 23)
			useButton.Parent = row
			useButton.Active = (skill.cooldownRemaining or 0) <= 0
			useButton.AutoButtonColor = useButton.Active
			if not useButton.Active then
				useButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			end
			useButton.MouseButton1Click:Connect(function()
				if useButton.Active then
					onUseSkill(creature.instanceId, skill.skillId)
				end
			end)
		end
	end

	return screen
end

return SkillPanel
