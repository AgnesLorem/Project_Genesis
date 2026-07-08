--[[
	TowerChallengeResultModal
	Location: src/client/views/TowerChallengeResultModal.luau

	Displays the result of a completed Tower run with rewards details, themed styling,
	and responsive layout.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local AnimationService = require(script.Parent.AnimationService)

local TowerChallengeResultModal = {}

function TowerChallengeResultModal.create(resultValue: any, onContinue: () -> ())
	local modal = UIComponents.createBaseModal()

	local panel = UIComponents.createBasePanel()
	panel.Name = "TowerChallengeResultPanel"
	panel.Size = UDim2.new(0, 420, 0, 300)
	panel.Position = UDim2.new(0.5, -210, 0.5, -150)
	panel.ZIndex = Theme.ZIndex.Modal + 1
	panel.Parent = modal

	local title = UIComponents.createBaseLabel("Tower Result")
	title.Name = "Title"
	title.Size = UDim2.new(1, -40, 0, 42)
	title.Position = UDim2.new(0, 20, 0, 20)
	title.Font = Theme.Fonts.Header
	title.TextSize = 28
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = Theme.ZIndex.Modal + 2
	title.Parent = panel

	local outcome = UIComponents.createBaseLabel(tostring(resultValue.outcome or "Unknown"))
	outcome.Name = "OutcomeLabel"
	outcome.Size = UDim2.new(1, -40, 0, 32)
	outcome.Position = UDim2.new(0, 20, 0, 78)
	outcome.Font = Theme.Fonts.Bold
	outcome.TextSize = 24
	outcome.TextXAlignment = Enum.TextXAlignment.Center
	outcome.ZIndex = Theme.ZIndex.Modal + 2
	
	if resultValue.outcome == "Victory" then
		outcome.TextColor3 = Theme.Colors.Success
	else
		outcome.TextColor3 = Theme.Colors.Error
	end
	outcome.Parent = panel

	local progress = resultValue.progress or {}
	local progressText = string.format(
		"Floor %d   |   Best %d   |   Attempts %d   |   Clears %d",
		resultValue.floorNumber or 0,
		progress.bestFloor or 0,
		progress.totalAttempts or 0,
		progress.totalClears or 0
	)

	local progressLabel = UIComponents.createBaseLabel(progressText)
	progressLabel.Name = "ProgressLabel"
	progressLabel.Size = UDim2.new(1, -40, 0, 30)
	progressLabel.Position = UDim2.new(0, 20, 0, 128)
	progressLabel.Font = Theme.Fonts.Regular
	progressLabel.TextSize = 16
	progressLabel.TextXAlignment = Enum.TextXAlignment.Center
	progressLabel.TextColor3 = Theme.Colors.Muted
	progressLabel.ZIndex = Theme.ZIndex.Modal + 2
	progressLabel.Parent = panel

	local rewardsList = resultValue.rewards or {}
	local rewardsText = ""
	if #rewardsList > 0 then
		local pieces = {}
		for _, r in ipairs(rewardsList) do
			table.insert(pieces, string.format("+%d %s", r.amount, r.currencyType:upper()))
		end
		rewardsText = "🏆 Reward: " .. table.concat(pieces, ", ")
	else
		rewardsText = resultValue.outcome == "Victory" and "Floor Cleared!" or "Try again to clear!"
	end

	local rewardLabel = UIComponents.createBaseLabel(rewardsText)
	rewardLabel.Name = "RewardLabel"
	rewardLabel.Size = UDim2.new(1, -40, 0, 24)
	rewardLabel.Position = UDim2.new(0, 20, 0, 172)
	rewardLabel.Font = Theme.Fonts.Bold
	rewardLabel.TextSize = 16
	rewardLabel.TextColor3 = Theme.Colors.Accent
	rewardLabel.TextXAlignment = Enum.TextXAlignment.Center
	rewardLabel.ZIndex = Theme.ZIndex.Modal + 2
	rewardLabel.Parent = panel

	local continueButton = UIComponents.createBaseButton("Continue")
	continueButton.Name = "ContinueButton"
	continueButton.Size = UDim2.new(0, 160, 0, 44)
	continueButton.Position = UDim2.new(0.5, -80, 1, -66)
	continueButton.BackgroundColor3 = Theme.Colors.Success
	continueButton.ZIndex = Theme.ZIndex.Modal + 2
	continueButton.Parent = panel
	continueButton.MouseButton1Click:Connect(onContinue)
	AnimationService.hoverScale(continueButton, Theme.Colors.Success, Theme.Colors.Success)

	return modal
end

return TowerChallengeResultModal
