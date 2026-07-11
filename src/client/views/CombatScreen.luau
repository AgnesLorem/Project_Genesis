--[[
	CombatScreen
	Location: src/client/views/CombatScreen.luau

	Displays the active combat state between player and enemy creatures.
	Responsive layout and Theme token support.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local VFXHelper = require(script.Parent.Parent.effects.VFXHelper)

local CombatScreen = {}

function CombatScreen.create(
	playerCreatureId,
	playerLevel,
	enemyCreatureId,
	enemyLevel,
	maxPlayerHp,
	maxEnemyHp,
	onExit
)
	local screen = UIComponents.createBaseContainer()
	screen.Name = "CombatScreen"

	local panel = UIComponents.createBasePanel()
	panel.BackgroundTransparency = 0.8 -- Make it semi-transparent so the 3D workspace behind is visible
	panel.Parent = screen

	-- Safe area padding
	local safeArea = Instance.new("UIPadding")
	safeArea.PaddingLeft = UDim.new(0, 32)
	safeArea.PaddingRight = UDim.new(0, 32)
	safeArea.PaddingTop = UDim.new(0, 24)
	safeArea.PaddingBottom = UDim.new(0, 24)
	safeArea.Parent = panel

	-- Return Button
	if onExit then
		local returnBtn = UIComponents.createBaseButton("Return")
		returnBtn.Name = "ReturnButton"
		returnBtn.Size = UDim2.new(0, 100, 0, 36)
		returnBtn.Position = UDim2.new(0, 0, 0, 0)
		returnBtn.BackgroundColor3 = Theme.Colors.Error
		returnBtn.ZIndex = Theme.ZIndex.Overlay
		returnBtn.Parent = panel
		returnBtn.Activated:Connect(onExit)
	end

	-- Turn Indicator
	local turnLabel = UIComponents.createBaseLabel("Combat Initializing...")
	turnLabel.Name = "TurnLabel"
	turnLabel.Size = UDim2.new(1, 0, 0, 40)
	turnLabel.Position = UDim2.new(0, 0, 0, 0)
	turnLabel.TextXAlignment = Enum.TextXAlignment.Center
	turnLabel.Font = Theme.Fonts.Header
	turnLabel.TextSize = 24
	turnLabel.Parent = panel

	-- Player Card (Left)
	local playerCard = UIComponents.createBasePanel()
	playerCard.Name = "PlayerCard"
	playerCard.Size = UDim2.new(0, 250, 0, 220)
	playerCard.Position = UDim2.new(0.08, 0, 0.14, 0)
	playerCard.BackgroundTransparency = 0.5 -- Semi-transparent
	playerCard.Parent = panel
	UIComponents.applyRarityBorder(playerCard, "Rare")

	local pName = UIComponents.createBaseLabel(string.format("%s (Lv. %d)", playerCreatureId, playerLevel))
	pName.Size = UDim2.new(1, -20, 0, 30)
	pName.Position = UDim2.new(0, 10, 0, 10)
	pName.Font = Theme.Fonts.Bold
	pName.TextSize = 20
	pName.Parent = playerCard

	local pImagePlaceholder = UIComponents.createBasePanel()
	pImagePlaceholder.Size = UDim2.new(1, -20, 0, 100)
	pImagePlaceholder.Position = UDim2.new(0, 10, 0, 45)
	pImagePlaceholder.BackgroundTransparency = 1 -- Fully transparent to show 3D VFX behind it
	pImagePlaceholder.Parent = playerCard

	local pImageText = UIComponents.createBaseLabel("🦎")
	pImageText.Size = UDim2.new(1, 0, 1, 0)
	pImageText.Font = Theme.Fonts.Bold
	pImageText.TextXAlignment = Enum.TextXAlignment.Center
	pImageText.TextYAlignment = Enum.TextYAlignment.Center
	pImageText.Parent = pImagePlaceholder

	local pBarContainer = Instance.new("Frame")
	pBarContainer.Size = UDim2.new(1, -20, 0, 20)
	pBarContainer.Position = UDim2.new(0, 10, 0, 155)
	pBarContainer.BackgroundColor3 = Theme.Colors.Error
	pBarContainer.Parent = playerCard

	local pBarCorner = Instance.new("UICorner")
	pBarCorner.CornerRadius = Theme.CornerRadius
	pBarCorner.Parent = pBarContainer

	local pBarFill = Instance.new("Frame")
	pBarFill.Size = UDim2.new(1, 0, 1, 0)
	pBarFill.BackgroundColor3 = Theme.Colors.Success
	pBarFill.BorderSizePixel = 0
	pBarFill.Parent = pBarContainer

	local pBarFillCorner = Instance.new("UICorner")
	pBarFillCorner.CornerRadius = Theme.CornerRadius
	pBarFillCorner.Parent = pBarFill

	local pHpText = UIComponents.createBaseLabel(string.format("%d / %d", maxPlayerHp, maxPlayerHp))
	pHpText.Size = UDim2.new(1, 0, 1, 0)
	pHpText.Font = Theme.Fonts.Bold
	pHpText.TextXAlignment = Enum.TextXAlignment.Center
	pHpText.TextYAlignment = Enum.TextYAlignment.Center
	pHpText.Parent = pBarContainer

	-- Enemy Card (Right)
	local enemyCard = UIComponents.createBasePanel()
	enemyCard.Name = "EnemyCard"
	enemyCard.Size = UDim2.new(0, 250, 0, 220)
	enemyCard.Position = UDim2.new(0.92, -250, 0.14, 0)
	enemyCard.BackgroundTransparency = 0.5 -- Semi-transparent
	enemyCard.Parent = panel
	UIComponents.applyRarityBorder(enemyCard, "Legendary")

	local eName = UIComponents.createBaseLabel(string.format("%s (Lv. %d)", enemyCreatureId, enemyLevel))
	eName.Size = UDim2.new(1, -20, 0, 30)
	eName.Position = UDim2.new(0, 10, 0, 10)
	eName.Font = Theme.Fonts.Bold
	eName.TextSize = 20
	eName.Parent = enemyCard

	local eImagePlaceholder = UIComponents.createBasePanel()
	eImagePlaceholder.Size = UDim2.new(1, -20, 0, 100)
	eImagePlaceholder.Position = UDim2.new(0, 10, 0, 45)
	eImagePlaceholder.BackgroundTransparency = 1 -- Fully transparent to show 3D VFX behind it
	eImagePlaceholder.Parent = enemyCard

	local eImageText = UIComponents.createBaseLabel("😈")
	eImageText.Size = UDim2.new(1, 0, 1, 0)
	eImageText.Font = Theme.Fonts.Bold
	eImageText.TextXAlignment = Enum.TextXAlignment.Center
	eImageText.TextYAlignment = Enum.TextYAlignment.Center
	eImageText.Parent = eImagePlaceholder

	local eBarContainer = Instance.new("Frame")
	eBarContainer.Size = UDim2.new(1, -20, 0, 20)
	eBarContainer.Position = UDim2.new(0, 10, 0, 155)
	eBarContainer.BackgroundColor3 = Theme.Colors.Error
	eBarContainer.Parent = enemyCard

	local eBarCorner = Instance.new("UICorner")
	eBarCorner.CornerRadius = Theme.CornerRadius
	eBarCorner.Parent = eBarContainer

	local eBarFill = Instance.new("Frame")
	eBarFill.Size = UDim2.new(1, 0, 1, 0)
	eBarFill.BackgroundColor3 = Theme.Colors.Success
	eBarFill.BorderSizePixel = 0
	eBarFill.Parent = eBarContainer

	local eBarFillCorner = Instance.new("UICorner")
	eBarFillCorner.CornerRadius = Theme.CornerRadius
	eBarFillCorner.Parent = eBarFill

	local eHpText = UIComponents.createBaseLabel(string.format("%d / %d", maxEnemyHp, maxEnemyHp))
	eHpText.Size = UDim2.new(1, 0, 1, 0)
	eHpText.Font = Theme.Fonts.Bold
	eHpText.TextXAlignment = Enum.TextXAlignment.Center
	eHpText.TextYAlignment = Enum.TextYAlignment.Center
	eHpText.Parent = eBarContainer

	-- Combat Log (Bottom)
	local logFrame = UIComponents.createBasePanel()
	logFrame.Name = "LogFrame"
	logFrame.Size = UDim2.new(0.84, 0, 0.4, 0)
	logFrame.Position = UDim2.new(0.08, 0, 0.55, 0)
	logFrame.Parent = panel

	local logTitle = UIComponents.createBaseLabel("Combat Log")
	logTitle.Size = UDim2.new(1, -20, 0, 25)
	logTitle.Position = UDim2.new(0, 16, 0, 6)
	logTitle.Font = Theme.Fonts.Bold
	logTitle.TextSize = 16
	logTitle.Parent = logFrame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -32, 1, -40)
	scroll.Position = UDim2.new(0, 16, 0, 30)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Theme.Colors.Border
	scroll.Parent = logFrame

	local logLayout = Instance.new("UIListLayout")
	logLayout.Padding = UDim.new(0, 4)
	logLayout.Parent = scroll

	local logConn = logLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y)
		scroll.CanvasPosition =
			Vector2.new(0, math.max(0, logLayout.AbsoluteContentSize.Y - scroll.AbsoluteWindowSize.Y))
	end)

	screen.Destroying:Connect(function()
		logConn:Disconnect()
	end)

	-- Interface API
	local api = {}
	api.playerCard = playerCard
	api.enemyCard = enemyCard

	function api.updatePlayerHp(currentHp)
		local clampedHp = math.clamp(currentHp, 0, maxPlayerHp)
		local ratio = math.clamp(clampedHp / maxPlayerHp, 0, 1)
		pBarFill.Size = UDim2.new(ratio, 0, 1, 0)
		pHpText.Text = string.format("%d / %d", clampedHp, maxPlayerHp)
	end

	function api.updateEnemyHp(currentHp)
		local clampedHp = math.clamp(currentHp, 0, maxEnemyHp)
		local ratio = math.clamp(clampedHp / maxEnemyHp, 0, 1)
		eBarFill.Size = UDim2.new(ratio, 0, 1, 0)
		eHpText.Text = string.format("%d / %d", clampedHp, maxEnemyHp)
	end

	function api.setCurrentTurn(turnNumber)
		turnLabel.Text = string.format("Turn %d", turnNumber)
	end

	function api.appendLog(text)
		local label = UIComponents.createBaseLabel(text)
		label.Size = UDim2.new(1, 0, 0, 20)
		label.Font = Theme.Fonts.Regular
		label.TextSize = 13
		label.TextColor3 = Theme.Colors.White
		label.Parent = scroll
	end

	function api.showDamage(isEnemyTarget, damageAmount)
		local targetCard = isEnemyTarget and enemyCard or playerCard
		VFXHelper.floatingText(targetCard, tostring(-damageAmount), Theme.Colors.Error, {
			font = Theme.Fonts.Bold,
			textSize = 36,
		})
		VFXHelper.hitFlash(targetCard, Theme.Colors.Error)
	end

	return screen, api
end

return CombatScreen
