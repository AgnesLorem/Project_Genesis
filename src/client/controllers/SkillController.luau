local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local SkillPanel = require(script.Parent.Parent.views.SkillPanel)
local StatePatterns = require(script.Parent.Parent.views.StatePatterns)

local SkillController = {}

local lastCreatureInstanceId = nil

local function _firstCreatureInstanceId(snapshot: any): string?
	local first = snapshot and snapshot.creatures and snapshot.creatures[1]
	return first and first.instanceId or nil
end

function SkillController.show(creatureInstanceId: string?)
	UIController.init()
	UIController.mountModal(StatePatterns.Loading(nil))

	local snapshotResult = NetworkController.getSkillSnapshot(creatureInstanceId)
	UIController.clearModal()
	if not snapshotResult.success then
		UIController.mountModal(
			StatePatterns.Error(nil, "Skill Load Failed: " .. tostring(snapshotResult.message or snapshotResult.code))
		)
		return snapshotResult
	end

	lastCreatureInstanceId = creatureInstanceId or _firstCreatureInstanceId(snapshotResult.value)
	local screen = SkillPanel.create(snapshotResult.value, lastCreatureInstanceId, function()
		SkillController.show(lastCreatureInstanceId)
	end, function(instanceId, skillId)
		SkillController.useSkill(instanceId, skillId, "enemy_001")
	end)
	UIController.mountScreen(screen)
	return snapshotResult
end

function SkillController.useSkill(creatureInstanceId: string, skillId: string, targetId: string)
	local result = NetworkController.requestSkillUse(creatureInstanceId, skillId, targetId)
	if result.success then
		SkillController.show(creatureInstanceId)
	else
		UIController.mountModal(StatePatterns.Error(nil, "Skill Failed: " .. tostring(result.message or result.code)))
	end
	return result
end

function SkillController.showInvalidSkillError(creatureInstanceId: string)
	local result = NetworkController.requestSkillUse(creatureInstanceId, "invalid_skill_id", "enemy_001")
	if result.success then
		UIController.mountModal(StatePatterns.Error(nil, "Invalid skill unexpectedly succeeded."))
	else
		UIController.mountModal(StatePatterns.Error(nil, "Skill Failed: " .. tostring(result.message or result.code)))
	end
	return result
end

return SkillController
