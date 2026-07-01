local UIController = require(script.Parent.Parent.controllers.UIController)
local LoadingController = require(script.Parent.Parent.controllers.LoadingController)
local StarterController = require(script.Parent.Parent.controllers.StarterController)
local WorldController = require(script.Parent.Parent.controllers.WorldController)

local ClientBootstrap = {}

function ClientBootstrap.init()
	UIController.init()
	LoadingController.start(function(snapshot)
		if snapshot.starterSelected then
			WorldController.start(snapshot)
		else
			StarterController.start(function()
				LoadingController.start(function(newSnapshot) 
					WorldController.start(newSnapshot) 
				end)
			end)
		end
	end)
end

return ClientBootstrap
