local UIComponents = require(script.Parent.UIComponents)

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
		"Best Floor: %d | Attempts: %d | Clears: %d",
		progress.bestFloor or 0,
		progress.totalAttempts or 0,
		progress.totalClears or 0
	)
end

function TowerChallengeScreen.create(profileSnapshot: any, challengeSnapshot: any, progress: any, onStart: (string, string, string) -> (), onRefresh: () -> ())
	local screen = UIComponents.createBaseContainer()
	screen.Name = "TowerChallengeScreen"

	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	local title = UIComponents.createBaseLabel(challengeSnapshot.displayName or "Tower Challenge")
	title.Name = "Title"
	title.Size = UDim2.new(1, -80, 0, 44)
	title.Position = UDim2.new(0, 40, 0, 28)
	title.TextSize = 30
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel

	local refreshButton = UIComponents.createBaseButton("Refresh")
	refreshButton.Name = "RefreshButton"
	refreshButton.Size = UDim2.new(0, 120, 0, 42)
	refreshButton.Position = UDim2.new(1, -160, 0, 28)
	refreshButton.Parent = panel
	refreshButton.MouseButton1Click:Connect(onRefresh)

	local description = UIComponents.createBaseLabel(challengeSnapshot.description or "")
	description.Name = "Description"
	description.Size = UDim2.new(1, -80, 0, 28)
	description.Position = UDim2.new(0, 40, 0, 80)
	description.TextSize = 18
	description.Parent = panel

	local progressLabel = UIComponents.createBaseLabel(_formatProgress(progress))
	progressLabel.Name = "ProgressLabel"
	progressLabel.Size = UDim2.new(1, -80, 0, 28)
	progressLabel.Position = UDim2.new(0, 40, 0, 120)
	progressLabel.TextSize = 18
	progressLabel.Parent = panel

	local ownedInstance = _firstOwnedInstance(profileSnapshot)
	local creatureText = ownedInstance
		and string.format("Selected: %s Lv. %d", tostring(ownedInstance.creatureId), ownedInstance.level or 1)
		or "No eligible creature"

	local creatureLabel = UIComponents.createBaseLabel(creatureText)
	creatureLabel.Name = "CreatureLabel"
	creatureLabel.Size = UDim2.new(1, -80, 0, 28)
	creatureLabel.Position = UDim2.new(0, 40, 0, 160)
	creatureLabel.TextSize = 18
	creatureLabel.Parent = panel

	local listFrame = Instance.new("Frame")
	listFrame.Name = "FloorList"
	listFrame.BackgroundTransparency = 1
	listFrame.Size = UDim2.new(1, -80, 0, 280)
	listFrame.Position = UDim2.new(0, 40, 0, 210)
	listFrame.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.Parent = listFrame

	for _, floor in ipairs(challengeSnapshot.floors or {}) do
		local row = UIComponents.createBasePanel()
		row.Name = "FloorRow"
		row.Size = UDim2.new(1, 0, 0, 72)
		row.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
		row.Parent = listFrame

		local floorLabel = UIComponents.createBaseLabel(string.format("Floor %d", floor.floorNumber or 0))
		floorLabel.Name = "FloorLabel"
		floorLabel.Size = UDim2.new(0.4, 0, 0, 28)
		floorLabel.Position = UDim2.new(0, 18, 0, 10)
		floorLabel.TextSize = 20
		floorLabel.Parent = row

		local requirementLabel = UIComponents.createBaseLabel(string.format("Recommended Lv. %d", floor.recommendedLevel or 1))
		requirementLabel.Name = "RequirementLabel"
		requirementLabel.Size = UDim2.new(0.4, 0, 0, 22)
		requirementLabel.Position = UDim2.new(0, 18, 0, 42)
		requirementLabel.TextSize = 15
		requirementLabel.Parent = row

		local startButton = UIComponents.createBaseButton("Start")
		startButton.Name = "StartButton"
		startButton.Size = UDim2.new(0, 120, 0, 42)
		startButton.Position = UDim2.new(1, -140, 0, 15)
		startButton.Parent = row
		startButton.Active = ownedInstance ~= nil
		startButton.AutoButtonColor = ownedInstance ~= nil
		if not ownedInstance then
			startButton.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
		end

		startButton.MouseButton1Click:Connect(function()
			if ownedInstance then
				onStart(challengeSnapshot.challengeId, floor.floorId, ownedInstance.instanceId)
			end
		end)
	end

	return screen
end

return TowerChallengeScreen
