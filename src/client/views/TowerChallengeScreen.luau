--[[
	TowerChallengeScreen
	Location: src/client/views/TowerChallengeScreen.luau

	Displays the active tower challenge with stage listings, progression locks,
	and rewards configuration. Responsive layout and Theme token support.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local AnimationService = require(script.Parent.AnimationService)

local TowerChallengeScreen = {}

local function _firstOwnedInstance(profileSnapshot: any): any
	for _, inst in pairs(profileSnapshot.creatureInstances or {}) do
		return inst
	end
	return nil
end

local function _formatProgress(progress: any): string
	if type(progress) ~= "table" then
		return "Best Floor: 0 | Attempts: 0 | Clears: 0"
	end

	return string.format(
		"Best Floor: %d   |   Attempts: %d   |   Clears: %d",
		progress.bestFloor or 0,
		progress.totalAttempts or 0,
		progress.totalClears or 0
	)
end

function TowerChallengeScreen.create(profileSnapshot: any, challengeSnapshot: any, progress: any, onStart: (string, string, string) -> (), onRefresh: () -> (), onClose: () -> ())
	local screen = UIComponents.createBaseContainer()
	screen.Name = "TowerChallengeScreen"

	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	-- Safe area padding
	local safeArea = Instance.new("UIPadding")
	safeArea.PaddingLeft = UDim.new(0, 32)
	safeArea.PaddingRight = UDim.new(0, 32)
	safeArea.PaddingTop = UDim.new(0, 24)
	safeArea.PaddingBottom = UDim.new(0, 24)
	safeArea.Parent = panel

	-- Title header
	local title = UIComponents.createBaseLabel(challengeSnapshot.displayName or "Tower Challenge")
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

	-- Info panel details
	local description = UIComponents.createBaseLabel(challengeSnapshot.description or "")
	description.Name = "Description"
	description.Size = UDim2.new(1, 0, 0, 24)
	description.Position = UDim2.new(0, 0, 0, 56)
	description.Font = Theme.Fonts.Regular
	description.TextSize = 16
	description.TextColor3 = Theme.Colors.Muted
	description.Parent = panel

	local progressLabel = UIComponents.createBaseLabel(_formatProgress(progress))
	progressLabel.Name = "ProgressLabel"
	progressLabel.Size = UDim2.new(1, 0, 0, 24)
	progressLabel.Position = UDim2.new(0, 0, 0, 84)
	progressLabel.Font = Theme.Fonts.Bold
	progressLabel.TextSize = 16
	progressLabel.TextColor3 = Theme.Colors.Accent
	progressLabel.Parent = panel

	local ownedInstance = _firstOwnedInstance(profileSnapshot)
	local creatureText = ownedInstance
		and string.format("Selected Fighter: %s Lv. %d", tostring(ownedInstance.creatureId), ownedInstance.level or 1)
		or "No eligible creature found"

	local creatureLabel = UIComponents.createBaseLabel(creatureText)
	creatureLabel.Name = "CreatureLabel"
	creatureLabel.Size = UDim2.new(1, 0, 0, 24)
	creatureLabel.Position = UDim2.new(0, 0, 0, 112)
	creatureLabel.Font = Theme.Fonts.Regular
	creatureLabel.TextSize = 16
	creatureLabel.TextColor3 = Theme.Colors.Rare
	creatureLabel.Parent = panel

	-- Scrollable or listing frame for tower floors
	local listFrame = Instance.new("Frame")
	listFrame.Name = "FloorList"
	listFrame.BackgroundTransparency = 1
	listFrame.Size = UDim2.new(1, 0, 0.6, 0)
	listFrame.Position = UDim2.new(0, 0, 0, 156)
	listFrame.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = listFrame

	for idx, floor in ipairs(challengeSnapshot.floors or {}) do
		local row = UIComponents.createBasePanel()
		row.Name = "FloorRow"
		row.Size = UDim2.new(1, 0, 0, 72)
		row.LayoutOrder = idx
		row.Parent = listFrame

		-- Highlight current floor
		local bestFloor = progress and progress.bestFloor or 0
		local isUnlocked = floor.floorNumber <= bestFloor + 1
		
		if isUnlocked and floor.floorNumber == bestFloor + 1 then
			row.BackgroundColor3 = Theme.Colors.FrostedGlass
			local activeOutline = Instance.new("UIStroke")
			activeOutline.Thickness = Theme.StrokeThickness
			activeOutline.Color = Theme.Colors.Primary
			activeOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			activeOutline.Parent = row
		end

		local floorLabel = UIComponents.createBaseLabel(string.format("Floor %d", floor.floorNumber or 0))
		floorLabel.Name = "FloorLabel"
		floorLabel.Size = UDim2.new(0.4, 0, 0, 28)
		floorLabel.Position = UDim2.new(0, 18, 0, 10)
		floorLabel.Font = Theme.Fonts.Bold
		floorLabel.TextSize = 20
		floorLabel.Parent = row

		local requirementLabel = UIComponents.createBaseLabel(string.format("Recommended Lv. %d", floor.recommendedLevel or 1))
		requirementLabel.Name = "RequirementLabel"
		requirementLabel.Size = UDim2.new(0.4, 0, 0, 22)
		requirementLabel.Position = UDim2.new(0, 18, 0, 40)
		requirementLabel.Font = Theme.Fonts.Regular
		requirementLabel.TextSize = 14
		requirementLabel.TextColor3 = Theme.Colors.Muted
		requirementLabel.Parent = row

		local buttonText = isUnlocked and "Start" or "Locked"
		local canClick = ownedInstance ~= nil and isUnlocked

		local startButton = UIComponents.createBaseButton(buttonText)
		startButton.Name = "Start_" .. tostring(floor.floorId)
		startButton.Size = UDim2.new(0, 120, 0, 44)
		startButton.Position = UDim2.new(1, -138, 0.5, -22)
		startButton.Parent = row
		startButton.Active = canClick
		startButton.AutoButtonColor = canClick
		
		if not canClick then
			startButton.BackgroundColor3 = Theme.Colors.Border
			startButton.TextTransparency = 0.5
		else
			startButton.BackgroundColor3 = Theme.Colors.Success
		end

		startButton.MouseButton1Click:Connect(function()
			if canClick then
				onStart(challengeSnapshot.challengeId, floor.floorId, ownedInstance.instanceId)
			end
		end)
	end

	return screen
end

return TowerChallengeScreen
