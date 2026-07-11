--[[
	WorldController
	Location: src/client/controllers/WorldController.luau
--]]

local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local BattleController = require(script.Parent.BattleController)
local CollectionController = require(script.Parent.CollectionController)
local InventoryController = require(script.Parent.InventoryController)
local GeneratorController = require(script.Parent.GeneratorController)
local CreatureInventoryController = require(script.Parent.CreatureInventoryController)
local TowerChallengeController = require(script.Parent.TowerChallengeController)
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

	screen = WorldScreen.create(snapshot, worldData, function(stageId)
		-- onStartStage
		local playerCreatureId = snapshot.activeCreatureInstanceId

		if not playerCreatureId then
			UIController.mountModal(
				StatePatterns.Error(
					nil,
					"No active creature found to battle with.\nPlease select one from your inventory."
				)
			)
			task.delay(3, function()
				UIController.clearModal()
			end)
			return
		end

		BattleController.start(playerCreatureId, stageId, function()
			_refreshAndRemount()
		end)
	end, function(generatorId)
		-- onClaimGenerator
		UIController.mountModal(StatePatterns.Loading(nil))
		local res = NetworkController.requestClaimGenerator(generatorId)
		UIController.clearModal()
		if res.success then
			_refreshAndRemount()
		else
			UIController.mountModal(StatePatterns.Error(nil, "Claim failed: " .. tostring(res.message or res.code)))
		end
	end, function(activeInstId, evolutionId)
		-- onEvolve
		UIController.mountModal(StatePatterns.Loading(nil))
		local res = NetworkController.requestEvolution(activeInstId, evolutionId)
		UIController.clearModal()
		if res.success then
			_refreshAndRemount()
		else
			UIController.mountModal(StatePatterns.Error(nil, "Evolution failed: " .. tostring(res.message or res.code)))
		end
	end, function()
		-- onOpenGenerators
		GeneratorController.show(nil, nil, function()
			_refreshAndRemount()
		end)
	end, function()
		-- onOpenCreatures
		CreatureInventoryController.show(function()
			_refreshAndRemount()
		end)
	end, function()
		-- onOpenCollection
		CollectionController.openCollectionBook(function()
			_refreshAndRemount()
		end)
	end, function()
		-- onOpenTower
		TowerChallengeController.show(function()
			_refreshAndRemount()
		end)
	end, function()
		-- onOpenInventory
		InventoryController.show(function()
			_refreshAndRemount()
		end)
	end)

	UIController.mountScreen(screen)
end

return WorldController
