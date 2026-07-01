local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local BattleController = require(script.Parent.BattleController)
local WorldScreen = require(script.Parent.Parent.views.WorldScreen)

local WorldController = {}

function WorldController.start(snapshot)
	local worldRes = NetworkController.requestWorldSnapshot()
	local worldData = worldRes.success and worldRes.value or { unlockedStages = { "story_stage_1" } }

	local function refresh()
		local newSnapRes = NetworkController.getPlayerProfileSnapshot()
		if newSnapRes.success then 
			WorldController.start(newSnapRes.value) 
		end
	end

	local screen = WorldScreen.create(
		snapshot, 
		worldData, 
		function(stageId)
			-- Start Battle
			local playerCreatureId = nil
			for _, inst in pairs(snapshot.creatureInstances) do 
				playerCreatureId = inst.creatureId 
				break 
			end
			if not playerCreatureId then 
				warn("No creature found to battle with.")
				return 
			end

			BattleController.start(playerCreatureId, stageId, refresh)
		end,
		function(generatorId)
			-- Claim Generator
			local claimRes = NetworkController.requestGeneratorClaim(generatorId)
			if claimRes.success then
				refresh()
			else
				warn("Generator claim failed: " .. tostring(claimRes.message or claimRes.code))
			end
		end,
		function(instanceId, evolutionId)
			-- Evolve Creature
			local evoRes = NetworkController.requestEvolution(instanceId, evolutionId)
			if evoRes.success then
				refresh()
			else
				warn("Evolution failed: " .. tostring(evoRes.message or evoRes.code))
			end
		end
	)

	UIController.mountScreen(screen)
end

return WorldController
