--[[
	BattleController
	Location: src/client/controllers/BattleController.luau
--]]

local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local BattleResultModal = require(script.Parent.Parent.views.BattleResultModal)
local StatePatterns = require(script.Parent.Parent.views.StatePatterns)

local BattleController = {}

function BattleController.start(playerCreatureId: string, stageId: string, onComplete: () -> ())
	UIController.mountModal(StatePatterns.Loading(nil))

	local res = NetworkController.requestStoryBattle(playerCreatureId, stageId)
	
	UIController.clearModal()

	if res.success then
		local modal = BattleResultModal.create(res.value, function()
			UIController.clearModal()
			onComplete()
		end)
		UIController.mountModal(modal)
	else
		local errorModal = StatePatterns.Error(nil, "Battle failed: " .. tostring(res.code))
		UIController.mountModal(errorModal)
		task.delay(3, function()
			UIController.clearModal()
			onComplete()
		end)
	end
end

return BattleController
