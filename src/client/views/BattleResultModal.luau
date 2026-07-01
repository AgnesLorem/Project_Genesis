--[[
	BattleResultModal
	Location: src/client/views/BattleResultModal.luau

	Displays the result of a story battle.
	battleData shape: { isVictory: boolean, timeline: [{text}], summary: {turns, reason},
	                    rewards: {biomass}, xpGained: number, creatureUpdates: {level, xp, leveledUp}? }
--]]

local UIComponents = require(script.Parent.UIComponents)

local BattleResultModal = {}

function BattleResultModal.create(battleData: any, onClose: () -> ()): Frame
	local modal = UIComponents.createBaseModal()

	local panel = UIComponents.createBasePanel()
	panel.Size = UDim2.new(0, 620, 0, 480)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.Parent = modal

	-- Header: VICTORY or DEFEAT
	local resultText = (battleData.isVictory == true) and "⚔ VICTORY" or "💀 DEFEAT"
	local header = UIComponents.createBaseLabel(resultText)
	header.Size = UDim2.new(1, 0, 0, 50)
	header.TextXAlignment = Enum.TextXAlignment.Center
	header.TextSize = 30
	header.TextColor3 = battleData.isVictory and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 80, 80)
	header.Parent = panel

	-- Rewards summary
	local rewardText = string.format(
		"Biomass: +%d   XP: +%d",
		battleData.rewards and battleData.rewards.biomass or 0,
		battleData.xpGained or 0
	)
	if battleData.creatureUpdates and battleData.creatureUpdates.leveledUp then
		rewardText = rewardText .. "   [LEVEL UP → Lv." .. tostring(battleData.creatureUpdates.level) .. "]"
	end
	local rewardLabel = UIComponents.createBaseLabel(rewardText)
	rewardLabel.Size = UDim2.new(1, -40, 0, 28)
	rewardLabel.Position = UDim2.new(0, 20, 0, 52)
	rewardLabel.TextXAlignment = Enum.TextXAlignment.Center
	rewardLabel.TextSize = 16
	rewardLabel.TextColor3 = Color3.fromRGB(220, 220, 100)
	rewardLabel.Parent = panel

	-- Timeline scroll
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -40, 1, -150)
	scroll.Position = UDim2.new(0, 20, 0, 90)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 6
	scroll.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = scroll

	if battleData.timeline then
		for _, entry in ipairs(battleData.timeline) do
			local label = UIComponents.createBaseLabel(tostring(entry.text))
			label.Size = UDim2.new(1, -10, 0, 20)
			label.TextSize = 13
			label.TextColor3 = Color3.fromRGB(200, 200, 200)
			label.Parent = scroll
		end
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	-- Close button
	local btn = UIComponents.createBaseButton("Close")
	btn.Name = "ContinueButton"
	btn.AnchorPoint = Vector2.new(0.5, 1)
	btn.Position = UDim2.new(0.5, 0, 1, -15)
	btn.Parent = panel

	btn.Activated:Connect(function()
		onClose()
	end)

	return modal
end

return BattleResultModal
