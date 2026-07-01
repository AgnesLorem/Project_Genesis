local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local StarterSelectionScreen = require(script.Parent.Parent.views.StarterSelectionScreen)

local StarterController = {}

function StarterController.start(onComplete)
	local res = NetworkController.getStarterChoices()
	local choices = res.success and res.value or { "starter_001" }
	local screen = StarterSelectionScreen.create(choices, function(selectedId)
		local claimRes = NetworkController.requestStarterSelection(selectedId)
		if claimRes.success then 
			onComplete() 
		else 
			warn("Failed to claim starter") 
		end
	end)
	UIController.mountScreen(screen)
end

return StarterController
