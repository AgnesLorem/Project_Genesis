local UIComponents = require(script.Parent.UIComponents)

local StarterSelectionScreen = {}

function StarterSelectionScreen.create(choices, onSelect)
	local screen = UIComponents.createBaseContainer()
	screen.Name = "StarterSelectionScreen"
	local panel = UIComponents.createBasePanel()
	panel.Parent = screen
	local title = UIComponents.createBaseLabel("Choose Your Starter")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Position = UDim2.new(0, 0, 0, 50)
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.TextSize = 32
	title.Parent = panel

	local listFrame = Instance.new("Frame")
	listFrame.Name = "ListFrame"
	listFrame.BackgroundTransparency = 1
	listFrame.Size = UDim2.new(1, 0, 0.5, 0)
	listFrame.Position = UDim2.new(0, 0, 0.3, 0)
	listFrame.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 20)
	layout.Parent = listFrame

	for _, creatureId in ipairs(choices) do
		local card = UIComponents.createBasePanel()
		card.Name = "Card_" .. creatureId
		card.Size = UDim2.new(0, 200, 0, 300)
		card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		card.Parent = listFrame

		local imagePlaceholder = Instance.new("Frame")
		imagePlaceholder.Name = "ImageContainer"
		imagePlaceholder.Size = UDim2.new(1, -20, 0, 180)
		imagePlaceholder.Position = UDim2.new(0, 10, 0, 10)
		imagePlaceholder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		imagePlaceholder.BorderSizePixel = 0
		imagePlaceholder.Parent = card

		local imageText = UIComponents.createBaseLabel("[IMAGE PLACEHOLDER]\nUpload artwork later")
		imageText.Size = UDim2.new(1, 0, 1, 0)
		imageText.TextXAlignment = Enum.TextXAlignment.Center
		imageText.TextYAlignment = Enum.TextYAlignment.Center
		imageText.Parent = imagePlaceholder

		local nameLabel = UIComponents.createBaseLabel(creatureId)
		nameLabel.Size = UDim2.new(1, 0, 0, 30)
		nameLabel.Position = UDim2.new(0, 0, 0, 200)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Center
		nameLabel.Parent = card

		local btn = UIComponents.createBaseButton("Claim")
		btn.Size = UDim2.new(0, 100, 0, 40)
		btn.AnchorPoint = Vector2.new(0.5, 0)
		btn.Position = UDim2.new(0.5, 0, 0, 240)
		btn.Parent = card

		btn.Activated:Connect(function() 
			onSelect(creatureId) 
		end)
	end
	return screen
end

return StarterSelectionScreen
