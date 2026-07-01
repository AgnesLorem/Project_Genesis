--[[
	WorldController
	Location: src/client/controllers/WorldController.luau
--]]

local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local BattleController = require(script.Parent.BattleController)
local CollectionController = require(script.Parent.CollectionController)
local InventoryController = require(script.Parent.InventoryController)
local WorldScreen = require(script.Parent.Parent.views.WorldScreen)
local StatePatterns = require(script.Parent.Parent.views.StatePatterns)

local WorldController = {}

function WorldController.start(snapshot: any)
	local worldRes = NetworkController.requestWorldSnapshot()
	if not worldRes.success then
		UIController.mountModal(StatePatterns.Error(nil, "Failed to load world data: " .. tostring(worldRes.code)))
		return
	end
	local worldData = worldRes.value

	local screen
	
	local function _refreshAndRemount()
		local newSnapRes = NetworkController.getPlayerProfileSnapshot()
		if newSnapRes.success then
			WorldController.start(newSnapRes.value)
		end
	end

	screen = WorldScreen.create(snapshot, worldData, 
		function(stageId)
			-- On Start Stage Click
			local playerCreatureId = snapshot.activeCreatureInstanceId

			if not playerCreatureId then
				UIController.mountModal(StatePatterns.Error(nil, "No active creature found to battle with.\nPlease select one from your inventory."))
				task.delay(3, function() UIController.clearModal() end)
				return
			end

			BattleController.start(playerCreatureId, stageId, function()
				_refreshAndRemount()
			end)
		end,
		function()
			-- On Open Collection
			CollectionController.openCollectionBook(function()
				-- Optional refresh if collection could change, but it's read-only for now
			end)
		end,
		function()
			-- On Open Inventory
			InventoryController.openInventory(function()
				-- Inventory can change active creature
				_refreshAndRemount()
			end, function(newActiveId)
				-- Optional: handle live active update without full remount
				snapshot.activeCreatureInstanceId = newActiveId
			end)
		end
	)

	UIController.mountScreen(screen)
end

return WorldController
