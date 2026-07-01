local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local LoadingScreen = require(script.Parent.Parent.views.LoadingScreen)

local LoadingController = {}

function LoadingController.start(onComplete)
	UIController.mountScreen(LoadingScreen.create())
	local result = NetworkController.getPlayerProfileSnapshot()
	if result.success then 
		onComplete(result.value) 
	else 
		task.wait(1) 
		LoadingController.start(onComplete) 
	end
end

return LoadingController
