--[[
	BattleResultModal
	Location: src/client/views/BattleResultModal.luau

	Displays the outcome of a story battle with timeline logs, rewards details,
	and Theme token styling.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local AnimationService = require(script.Parent.AnimationService)

local BattleResultModal = {}

function BattleResultModal.create(battleData: any, onClose: () -> ()): Frame
	local modal = UIComponents.createBaseModal()

	local panel = UIComponents.createBasePanel()
	panel.Size = UDim2.new(0, 620, 0, 480)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.ZIndex = Theme.ZIndex.Modal + 1
	panel.Parent = modal

	-- Header: VICTORY or DEFEAT
	local resultText = (battleData.isVictory == true) and "⚔ VICTORY" or "💀 DEFEAT"
	local header = UIComponents.createBaseLabel(resultText)
	header.Size = UDim2.new(1, 0, 0, 50)
	header.Font = Theme.Fonts.Header
	header.TextXAlignment = Enum.TextXAlignment.Center
	header.TextSize = 30
	header.ZIndex = Theme.ZIndex.Modal + 2

	if battleData.isVictory then
		header.TextColor3 = Theme.Colors.Success
	else
		header.TextColor3 = Theme.Colors.Error
	end
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
	rewardLabel.Font = Theme.Fonts.Bold
	rewardLabel.TextXAlignment = Enum.TextXAlignment.Center
	rewardLabel.TextSize = 16
	rewardLabel.TextColor3 = Theme.Colors.Accent
	rewardLabel.ZIndex = Theme.ZIndex.Modal + 2
	rewardLabel.Parent = panel

	-- Timeline scroll
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -40, 1, -150)
	scroll.Position = UDim2.new(0, 20, 0, 90)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Theme.Colors.Border
	scroll.ZIndex = Theme.ZIndex.Modal + 2
	scroll.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = scroll

	if battleData.timeline then
		for _, entry in ipairs(battleData.timeline) do
			if entry.text ~= nil then
				local label = UIComponents.createBaseLabel(tostring(entry.text))
				label.Size = UDim2.new(1, -10, 0, 20)
				label.Font = Theme.Fonts.Regular
				label.TextSize = 13
				label.TextColor3 = Theme.Colors.White
				label.ZIndex = Theme.ZIndex.Modal + 2
				label.Parent = scroll
			end
		end
	end

	local layoutConn = layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	modal.Destroying:Connect(function()
		layoutConn:Disconnect()
	end)

	-- Close button
	local btn = UIComponents.createBaseButton("Close")
	btn.Name = "ContinueButton"
	btn.AnchorPoint = Vector2.new(0.5, 1)
	btn.Position = UDim2.new(0.5, 0, 1, -16)
	btn.BackgroundColor3 = Theme.Colors.Success
	btn.ZIndex = Theme.ZIndex.Modal + 2
	btn.Parent = panel

	btn.Activated:Connect(onClose)

	-- Open Transition animation
	AnimationService.scalePop(panel)

	return modal
end

return BattleResultModal
