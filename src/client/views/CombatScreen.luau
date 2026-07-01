local UIComponents = require(script.Parent.UIComponents)

local CombatScreen = {}

function CombatScreen.create(playerCreatureId, playerLevel, enemyCreatureId, enemyLevel, maxPlayerHp, maxEnemyHp)
	local screen = UIComponents.createBaseContainer()
	screen.Name = "CombatScreen"
	
	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	-- Turn Indicator
	local turnLabel = UIComponents.createBaseLabel("Combat Initializing...")
	turnLabel.Name = "TurnLabel"
	turnLabel.Size = UDim2.new(1, 0, 0, 40)
	turnLabel.Position = UDim2.new(0, 0, 0, 20)
	turnLabel.TextXAlignment = Enum.TextXAlignment.Center
	turnLabel.TextSize = 24
	turnLabel.Parent = panel

	-- Player Card (Left)
	local playerCard = UIComponents.createBasePanel()
	playerCard.Name = "PlayerCard"
	playerCard.Size = UDim2.new(0, 250, 0, 220)
	playerCard.Position = UDim2.new(0.1, 0, 0.15, 0)
	playerCard.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
	playerCard.Parent = panel

	local pName = UIComponents.createBaseLabel(string.format("%s (Lv. %d)", playerCreatureId, playerLevel))
	pName.Size = UDim2.new(1, -20, 0, 30)
	pName.Position = UDim2.new(0, 10, 0, 10)
	pName.TextSize = 20
	pName.Parent = playerCard

	local pImagePlaceholder = Instance.new("Frame")
	pImagePlaceholder.Size = UDim2.new(1, -20, 0, 100)
	pImagePlaceholder.Position = UDim2.new(0, 10, 0, 45)
	pImagePlaceholder.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
	pImagePlaceholder.Parent = playerCard

	local pImageText = UIComponents.createBaseLabel("[IMAGE PLACEHOLDER]")
	pImageText.Size = UDim2.new(1, 0, 1, 0)
	pImageText.TextXAlignment = Enum.TextXAlignment.Center
	pImageText.TextYAlignment = Enum.TextYAlignment.Center
	pImageText.Parent = pImagePlaceholder

	local pBarContainer = Instance.new("Frame")
	pBarContainer.Size = UDim2.new(1, -20, 0, 20)
	pBarContainer.Position = UDim2.new(0, 10, 0, 155)
	pBarContainer.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	pBarContainer.Parent = playerCard

	local pBarFill = Instance.new("Frame")
	pBarFill.Size = UDim2.new(1, 0, 1, 0)
	pBarFill.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
	pBarFill.BorderSizePixel = 0
	pBarFill.Parent = pBarContainer

	local pHpText = UIComponents.createBaseLabel(string.format("%d / %d", maxPlayerHp, maxPlayerHp))
	pHpText.Size = UDim2.new(1, 0, 1, 0)
	pHpText.TextXAlignment = Enum.TextXAlignment.Center
	pHpText.TextYAlignment = Enum.TextYAlignment.Center
	pHpText.Parent = pBarContainer

	-- Enemy Card (Right)
	local enemyCard = UIComponents.createBasePanel()
	enemyCard.Name = "EnemyCard"
	enemyCard.Size = UDim2.new(0, 250, 0, 220)
	enemyCard.Position = UDim2.new(0.9, -250, 0.15, 0)
	enemyCard.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
	enemyCard.Parent = panel

	local eName = UIComponents.createBaseLabel(string.format("%s (Lv. %d)", enemyCreatureId, enemyLevel))
	eName.Size = UDim2.new(1, -20, 0, 30)
	eName.Position = UDim2.new(0, 10, 0, 10)
	eName.TextSize = 20
	eName.Parent = enemyCard

	local eImagePlaceholder = Instance.new("Frame")
	eImagePlaceholder.Size = UDim2.new(1, -20, 0, 100)
	eImagePlaceholder.Position = UDim2.new(0, 10, 0, 45)
	eImagePlaceholder.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
	eImagePlaceholder.Parent = enemyCard

	local eImageText = UIComponents.createBaseLabel("[IMAGE PLACEHOLDER]")
	eImageText.Size = UDim2.new(1, 0, 1, 0)
	eImageText.TextXAlignment = Enum.TextXAlignment.Center
	eImageText.TextYAlignment = Enum.TextYAlignment.Center
	eImageText.Parent = eImagePlaceholder

	local eBarContainer = Instance.new("Frame")
	eBarContainer.Size = UDim2.new(1, -20, 0, 20)
	eBarContainer.Position = UDim2.new(0, 10, 0, 155)
	eBarContainer.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	eBarContainer.Parent = enemyCard

	local eBarFill = Instance.new("Frame")
	eBarFill.Size = UDim2.new(1, 0, 1, 0)
	eBarFill.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
	eBarFill.BorderSizePixel = 0
	eBarFill.Parent = eBarContainer

	local eHpText = UIComponents.createBaseLabel(string.format("%d / %d", maxEnemyHp, maxEnemyHp))
	eHpText.Size = UDim2.new(1, 0, 1, 0)
	eHpText.TextXAlignment = Enum.TextXAlignment.Center
	eHpText.TextYAlignment = Enum.TextYAlignment.Center
	eHpText.Parent = eBarContainer

	-- Combat Log (Bottom)
	local logFrame = UIComponents.createBasePanel()
	logFrame.Name = "LogFrame"
	logFrame.Size = UDim2.new(0.8, 0, 0.4, 0)
	logFrame.Position = UDim2.new(0.1, 0, 0.55, 0)
	logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	logFrame.Parent = panel

	local logTitle = UIComponents.createBaseLabel("Combat Log")
	logTitle.Size = UDim2.new(1, -20, 0, 25)
	logTitle.Position = UDim2.new(0, 10, 0, 5)
	logTitle.TextSize = 16
	logTitle.Parent = logFrame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -20, 1, -40)
	scroll.Position = UDim2.new(0, 10, 0, 30)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 6
	scroll.Parent = logFrame

	local logLayout = Instance.new("UIListLayout")
	logLayout.Padding = UDim.new(0, 4)
	logLayout.Parent = scroll

	logLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y)
		scroll.CanvasPosition = Vector2.new(0, math.max(0, logLayout.AbsoluteContentSize.Y - scroll.AbsoluteWindowSize.Y))
	end)

	-- Interface API
	local api = {}

	function api.updatePlayerHp(currentHp)
		local ratio = math.clamp(currentHp / maxPlayerHp, 0, 1)
		pBarFill.Size = UDim2.new(ratio, 0, 1, 0)
		pHpText.Text = string.format("%d / %d", currentHp, maxPlayerHp)
	end

	function api.updateEnemyHp(currentHp)
		local ratio = math.clamp(currentHp / maxEnemyHp, 0, 1)
		eBarFill.Size = UDim2.new(ratio, 0, 1, 0)
		eHpText.Text = string.format("%d / %d", currentHp, maxEnemyHp)
	end

	function api.setCurrentTurn(turnNumber)
		turnLabel.Text = string.format("Turn %d", turnNumber)
	end

	function api.appendLog(text)
		local label = UIComponents.createBaseLabel(text)
		label.Size = UDim2.new(1, 0, 0, 18)
		label.TextSize = 13
		label.Parent = scroll
	end

	function api.showDamage(isEnemyTarget, damageAmount)
		local targetCard = isEnemyTarget and enemyCard or playerCard
		
		-- Create floating damage text
		local dmgText = Instance.new("TextLabel")
		dmgText.BackgroundTransparency = 1
		dmgText.Size = UDim2.new(0, 100, 0, 40)
		dmgText.Position = UDim2.new(0.5, -50, 0.2, 0)
		dmgText.Font = Enum.Font.SourceSansBold
		dmgText.TextSize = 36
		dmgText.TextColor3 = Color3.fromRGB(255, 50, 50)
		dmgText.Text = tostring(-damageAmount)
		dmgText.TextXAlignment = Enum.TextXAlignment.Center
		dmgText.TextYAlignment = Enum.TextYAlignment.Center
		dmgText.Parent = targetCard

		-- Simple float up and fade out animation
		task.spawn(function()
			local duration = 0.8
			local steps = 24
			local waitTime = duration / steps
			for i = 1, steps do
				task.wait(waitTime)
				if dmgText.Parent then
					dmgText.Position = UDim2.new(0.5, -50, 0.2 - (0.2 * (i / steps)), 0)
					dmgText.TextTransparency = i / steps
				else
					break
				end
			end
			dmgText:Destroy()
		end)
	end

	return screen, api
end

return CombatScreen
