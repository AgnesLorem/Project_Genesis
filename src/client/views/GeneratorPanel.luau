--[[
	GeneratorPanel
	Location: src/client/views/GeneratorPanel.luau

	Displays resource generators with earn rates, capacities, claiming action,
	and level upgrades. Responsive layouts and Theme tokens.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local AnimationService = require(script.Parent.AnimationService)
local UIController = require(script.Parent.Parent.controllers.UIController)

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
	button.Size = UDim2.new(0, 108, 0, 44) -- Ensure >= 44 px target size for accessibility
	button.Position = position
	button.Parent = parent
	button.Active = enabled
	button.AutoButtonColor = enabled
	
	if enabled then
		button.BackgroundColor3 = Theme.Colors.Success
	else
		button.BackgroundColor3 = Theme.Colors.Border
		button.TextTransparency = 0.35
	end
	return button
end

function GeneratorPanel.create(snapshot: any, onClaim: (string) -> (), onUpgrade: (string) -> (), onRefresh: () -> (), selectedGeneratorId: string?, statusText: string?, onClose: () -> ())
	local screen = UIComponents.createBaseContainer()
	screen.Name = "GeneratorPanel"

	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	-- Notch safe area padding
	local safeArea = Instance.new("UIPadding")
	safeArea.PaddingLeft = UDim.new(0, 32)
	safeArea.PaddingRight = UDim.new(0, 32)
	safeArea.PaddingTop = UDim.new(0, 24)
	safeArea.PaddingBottom = UDim.new(0, 24)
	safeArea.Parent = panel

	local title = UIComponents.createBaseLabel("Generators")
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

	local refreshButton = UIComponents.createBaseButton("Refresh")
	refreshButton.Name = "RefreshButton"
	refreshButton.Size = UDim2.new(0, 110, 0, 44)
	refreshButton.Position = UDim2.new(1, -110, 0, 0)
	refreshButton.BackgroundColor3 = Theme.Colors.Primary
	refreshButton.Parent = panel
	refreshButton.MouseButton1Click:Connect(onRefresh)

	local balances = snapshot.balances or {}
	local balanceLabel = UIComponents.createBaseLabel(string.format(
		"Biomass: %d   |   DNA: %d",
		balances.biomass or 0,
		balances.dna or 0
	))
	balanceLabel.Name = "GeneratorBalances"
	balanceLabel.Size = UDim2.new(1, 0, 0, 24)
	balanceLabel.Position = UDim2.new(0, 0, 0, 56)
	balanceLabel.Font = Theme.Fonts.Bold
	balanceLabel.TextSize = 18
	balanceLabel.TextColor3 = Theme.Colors.Accent
	balanceLabel.Parent = panel

	local statusLabel = UIComponents.createBaseLabel(statusText or "Server-authoritative generator snapshot.")
	statusLabel.Name = "GeneratorStatus"
	statusLabel.Size = UDim2.new(1, 0, 0, 24)
	statusLabel.Position = UDim2.new(0, 0, 0, 84)
	statusLabel.Font = Theme.Fonts.Regular
	statusLabel.TextSize = 16
	statusLabel.TextColor3 = Theme.Colors.Rare
	statusLabel.Parent = panel

	local list = Instance.new("ScrollingFrame")
	list.Name = "GeneratorList"
	list.BackgroundTransparency = 1
	list.Size = UDim2.new(1, 0, 0.7, 0)
	list.Position = UDim2.new(0, 0, 0, 120)
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

	for idx, generator in ipairs(snapshot.generators or {}) do
		local row = UIComponents.createBasePanel()
		row.Name = "GeneratorRow_" .. tostring(generator.generatorId)
		row.Size = UDim2.new(1, -6, 0, 116)
		row.Parent = list

		-- Highlight selected generator
		if generator.generatorId == selectedGeneratorId then
			row.BackgroundColor3 = Theme.Colors.FrostedGlass
			UIComponents.applySelectionOutline(row)
		end

		local nameLabel = UIComponents.createBaseLabel(generator.displayName or generator.generatorId)
		nameLabel.Size = UDim2.new(0.6, 0, 0, 26)
		nameLabel.Position = UDim2.new(0, 16, 0, 10)
		nameLabel.Font = Theme.Fonts.Bold
		nameLabel.TextSize = 20
		nameLabel.Parent = row

		local stateLabel = UIComponents.createBaseLabel(_unlockText(generator))
		stateLabel.Name = "GeneratorUnlockState"
		stateLabel.Size = UDim2.new(0.6, 0, 0, 22)
		stateLabel.Position = UDim2.new(0, 16, 0, 38)
		stateLabel.Font = Theme.Fonts.Regular
		stateLabel.TextSize = 15
		stateLabel.TextColor3 = generator.isUnlocked and Theme.Colors.Success or Theme.Colors.Accent
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
		infoLabel.Size = UDim2.new(0.6, 0, 0, 22)
		infoLabel.Position = UDim2.new(0, 16, 0, 62)
		infoLabel.Font = Theme.Fonts.Regular
		infoLabel.TextSize = 14
		infoLabel.TextColor3 = Theme.Colors.Muted
		infoLabel.Parent = row

		local cost = generator.upgradeCost or {}
		local costLabel = UIComponents.createBaseLabel(string.format(
			"Upgrade Cost: %d %s",
			cost.amount or 0,
			_currencyLabel(cost.currencyType)
		))
		costLabel.Name = "GeneratorUpgradeCost"
		costLabel.Size = UDim2.new(0.6, 0, 0, 22)
		costLabel.Position = UDim2.new(0, 16, 0, 84)
		costLabel.Font = Theme.Fonts.Regular
		costLabel.TextSize = 14
		costLabel.TextColor3 = Theme.Colors.Accent
		costLabel.Parent = row

		-- Dynamic buttons positioning with vertical centers
		local claimButton = _makeButton("Claim", generator.canClaim == true, row, UDim2.new(1, -238, 0.5, -22))
		claimButton.Name = "Claim_" .. tostring(generator.generatorId)
		claimButton.MouseButton1Click:Connect(function()
			if generator.canClaim then
				onClaim(generator.generatorId)
			end
		end)

		local upgradeButton = _makeButton("Upgrade", generator.canUpgrade == true, row, UDim2.new(1, -120, 0.5, -22))
		upgradeButton.Name = "Upgrade_" .. tostring(generator.generatorId)
		upgradeButton.MouseButton1Click:Connect(function()
			if generator.canUpgrade then
				-- Trigger confirmation modal dialog
				local confirmModal = UIComponents.createConfirmationModal(
					string.format("Upgrade %s to Level %d for %d %s?", 
						generator.displayName or generator.generatorId,
						(generator.level or 1) + 1,
						cost.amount or 0,
						_currencyLabel(cost.currencyType)
					),
					function()
						UIController.clearModal()
						onUpgrade(generator.generatorId)
					end,
					function()
						UIController.clearModal()
					end
				)
				UIController.mountModal(confirmModal, function()
					UIController.clearModal()
				end)
			end
		end)
	end

	return screen
end

return GeneratorPanel
