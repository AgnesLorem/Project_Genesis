local UIComponents = require(script.Parent.UIComponents)
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)

local BattleResultModal = {}

function BattleResultModal.create(battleData, onClose)
	local modal = UIComponents.createBaseModal()
	local panel = UIComponents.createBasePanel()
	panel.Size = UDim2.new(0, 500, 0, 380)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.Parent = modal

	-- Outcome Title
	local outcome = battleData.outcome or "Battle Complete"
	local header = UIComponents.createBaseLabel(tostring(outcome))
	header.Size = UDim2.new(1, 0, 0, 50)
	header.TextXAlignment = Enum.TextXAlignment.Center
	header.TextSize = 32
	header.TextColor3 = outcome == "Victory" and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
	header.Parent = panel

	-- Rewards Info
	local xpGained = battleData.xpGained or 0
	local biomassGained = battleData.rewards and battleData.rewards.biomass or 0
	
	local rewardsText = string.format("Rewards Earned:\n+ %d XP\n+ %d Biomass", xpGained, biomassGained)
	local rewardsLabel = UIComponents.createBaseLabel(rewardsText)
	rewardsLabel.Size = UDim2.new(1, -40, 0, 80)
	rewardsLabel.Position = UDim2.new(0, 20, 0, 60)
	rewardsLabel.TextXAlignment = Enum.TextXAlignment.Center
	rewardsLabel.TextSize = 18
	rewardsLabel.Parent = panel

	-- Level Up Celebration
	local updates = battleData.creatureUpdates
	if updates and updates.leveledUp then
		local lvlUpLabel = UIComponents.createBaseLabel("⭐ LEVEL UP! ⭐")
		lvlUpLabel.Size = UDim2.new(1, 0, 0, 30)
		lvlUpLabel.Position = UDim2.new(0, 0, 0, 150)
		lvlUpLabel.TextXAlignment = Enum.TextXAlignment.Center
		lvlUpLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
		lvlUpLabel.TextSize = 22
		lvlUpLabel.Parent = panel
	end

	-- Updated Stats Display
	local statsText = ""
	if updates then
		statsText = string.format("New Level: %d (XP: %d / %d)", updates.level, updates.xp, updates.level * 100)
	else
		statsText = "No progression updates."
	end

	local statsLabel = UIComponents.createBaseLabel(statsText)
	statsLabel.Size = UDim2.new(1, -40, 0, 60)
	statsLabel.Position = UDim2.new(0, 20, 0, 190)
	statsLabel.TextXAlignment = Enum.TextXAlignment.Center
	statsLabel.TextSize = 16
	statsLabel.Parent = panel

	-- Continue Button
	local btn = UIComponents.createBaseButton("Continue")
	btn.Name = "ContinueButton"
	btn.Size = UDim2.new(0, 150, 0, 40)
	btn.AnchorPoint = Vector2.new(0.5, 1)
	btn.Position = UDim2.new(0.5, 0, 1, -20)
	btn.Parent = panel
	btn.Activated:Connect(function() 
		onClose() 
	end)

	return modal
end

return BattleResultModal
