local UIComponents = require(script.Parent.UIComponents)

local GeneratorPanel = {}

local function _currencyLabel(currencyType: string?): string
	if currencyType == "dna" then
		return "DNA"
	end
	return "Biomass"
end

local function _unlockText(generator: any): string
	if generator.isUnlocked then
		return "Unlocked"
	end

	local requirement = generator.unlockRequirement or {}
	if requirement.type == "currencyBalance" then
		return string.format(
			"Locked: Requires %d %s",
			requirement.amount or 0,
			_currencyLabel(requirement.currencyType)
		)
	end
	if requirement.type == "generatorLevel" then
		return string.format(
			"Locked: Requires %s Level %d",
			requirement.generatorId or "generator",
			requirement.level or 0
		)
	end

	return "Locked"
end

local function _makeButton(text: string, enabled: boolean, parent: Instance, position: UDim2)
	local button = UIComponents.createBaseButton(text)
	button.Size = UDim2.new(0, 108, 0, 34)
	button.Position = position
	button.Parent = parent
	button.Active = enabled
	button.AutoButtonColor = enabled
	if enabled then
		button.BackgroundColor3 = Color3.fromRGB(50, 104, 72)
	else
		button.BackgroundColor3 = Color3.fromRGB(72, 72, 72)
		button.TextTransparency = 0.35
	end
	return button
end

function GeneratorPanel.create(snapshot: any, onClaim: (string) -> (), onUpgrade: (string) -> (), onRefresh: () -> (), selectedGeneratorId: string?, statusText: string?)
	local screen = UIComponents.createBaseContainer()
	screen.Name = "GeneratorPanel"

	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	local title = UIComponents.createBaseLabel("Generators")
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

	local balances = snapshot.balances or {}
	local balanceLabel = UIComponents.createBaseLabel(string.format(
		"Biomass: %d   |   DNA: %d",
		balances.biomass or 0,
		balances.dna or 0
	))
	balanceLabel.Name = "GeneratorBalances"
	balanceLabel.Size = UDim2.new(1, -72, 0, 28)
	balanceLabel.Position = UDim2.new(0, 36, 0, 78)
	balanceLabel.TextSize = 18
	balanceLabel.Parent = panel

	local statusLabel = UIComponents.createBaseLabel(statusText or "Server-authoritative generator snapshot.")
	statusLabel.Name = "GeneratorStatus"
	statusLabel.Size = UDim2.new(1, -72, 0, 28)
	statusLabel.Position = UDim2.new(0, 36, 0, 108)
	statusLabel.TextSize = 16
	statusLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
	statusLabel.Parent = panel

	local list = Instance.new("ScrollingFrame")
	list.Name = "GeneratorList"
	list.BackgroundTransparency = 1
	list.Size = UDim2.new(1, -72, 1, -162)
	list.Position = UDim2.new(0, 36, 0, 146)
	list.ScrollBarThickness = 6
	list.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = list
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	for _, generator in ipairs(snapshot.generators or {}) do
		local row = UIComponents.createBasePanel()
		row.Name = "GeneratorRow_" .. tostring(generator.generatorId)
		row.Size = UDim2.new(1, -8, 0, 112)
		row.BackgroundColor3 = generator.generatorId == selectedGeneratorId and Color3.fromRGB(42, 58, 70) or Color3.fromRGB(34, 34, 34)
		row.Parent = list

		local nameLabel = UIComponents.createBaseLabel(generator.displayName or generator.generatorId)
		nameLabel.Size = UDim2.new(1, -260, 0, 26)
		nameLabel.Position = UDim2.new(0, 16, 0, 10)
		nameLabel.TextSize = 20
		nameLabel.Parent = row

		local stateLabel = UIComponents.createBaseLabel(_unlockText(generator))
		stateLabel.Name = "GeneratorUnlockState"
		stateLabel.Size = UDim2.new(1, -260, 0, 22)
		stateLabel.Position = UDim2.new(0, 16, 0, 38)
		stateLabel.TextSize = 15
		stateLabel.TextColor3 = generator.isUnlocked and Color3.fromRGB(180, 240, 190) or Color3.fromRGB(240, 180, 120)
		stateLabel.Parent = row

		local infoLabel = UIComponents.createBaseLabel(string.format(
			"Lv %d / %d   %d / %d %s   Rate %d/s",
			generator.level or 1,
			generator.maxLevel or 1,
			generator.accumulated or 0,
			generator.capacity or generator.maxAccumulated or 0,
			_currencyLabel(generator.currencyType),
			generator.ratePerSecond or 0
		))
		infoLabel.Name = "GeneratorInfo"
		infoLabel.Size = UDim2.new(1, -260, 0, 22)
		infoLabel.Position = UDim2.new(0, 16, 0, 62)
		infoLabel.TextSize = 15
		infoLabel.Parent = row

		local cost = generator.upgradeCost or {}
		local costLabel = UIComponents.createBaseLabel(string.format(
			"Upgrade: %d %s",
			cost.amount or 0,
			_currencyLabel(cost.currencyType)
		))
		costLabel.Name = "GeneratorUpgradeCost"
		costLabel.Size = UDim2.new(1, -260, 0, 22)
		costLabel.Position = UDim2.new(0, 16, 0, 84)
		costLabel.TextSize = 15
		costLabel.Parent = row

		local claimButton = _makeButton("Claim", generator.canClaim == true, row, UDim2.new(1, -238, 0, 20))
		claimButton.Name = "Claim_" .. tostring(generator.generatorId)
		claimButton.MouseButton1Click:Connect(function()
			if generator.canClaim then
				onClaim(generator.generatorId)
			end
		end)

		local upgradeButton = _makeButton("Upgrade", generator.canUpgrade == true, row, UDim2.new(1, -120, 0, 20))
		upgradeButton.Name = "Upgrade_" .. tostring(generator.generatorId)
		upgradeButton.MouseButton1Click:Connect(function()
			if generator.canUpgrade then
				onUpgrade(generator.generatorId)
			end
		end)
	end

	return screen
end

return GeneratorPanel
