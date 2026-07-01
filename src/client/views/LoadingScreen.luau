local UIComponents = require(script.Parent.UIComponents)

local LoadingScreen = {}

function LoadingScreen.create()
	local screen = UIComponents.createBaseContainer()
	screen.Name = "LoadingScreen"
	local panel = UIComponents.createBasePanel()
	panel.Parent = screen
	local label = UIComponents.createBaseLabel("Fetching Player Profile...")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextSize = 24
	label.Parent = panel
	return screen
end

return LoadingScreen
