local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local CombatScreen = require(script.Parent.Parent.views.CombatScreen)
local TowerChallengeScreen = require(script.Parent.Parent.views.TowerChallengeScreen)
local TowerChallengeResultModal = require(script.Parent.Parent.views.TowerChallengeResultModal)
local StatePatterns = require(script.Parent.Parent.views.StatePatterns)
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)

local TowerChallengeController = {}

local function _containsUnitId(unitIds: { string }, targetId: string): boolean
	for _, unitId in ipairs(unitIds or {}) do
		if unitId == targetId then
			return true
		end
	end
	return false
end

local function _findInstance(profileSnapshot: any, instanceId: string): any
	local instances = profileSnapshot and profileSnapshot.creatureInstances or {}
	local direct = instances[instanceId]
	if type(direct) == "table" then
		return direct
	end

	for _, inst in pairs(instances) do
		if type(inst) == "table" and inst.instanceId == instanceId then
			return inst
		end
	end

	return nil
end

local function _getFirstChallenge(snapshot: any): any
	local challenges = snapshot and snapshot.challenges or {}
	return challenges[1]
end

function TowerChallengeController.show()
	UIController.init()
	UIController.mountModal(StatePatterns.Loading(nil))

	local profileRes = NetworkController.getPlayerProfileSnapshot()
	local towerRes = NetworkController.getTowerChallengeSnapshot()
	UIController.clearModal()

	if not profileRes.success then
		UIController.mountModal(StatePatterns.Error(nil, "Profile Load Failed: " .. tostring(profileRes.message or profileRes.code)))
		return profileRes
	end
	if not towerRes.success then
		UIController.mountModal(StatePatterns.Error(nil, "Tower Load Failed: " .. tostring(towerRes.message or towerRes.code)))
		return towerRes
	end

	local challenge = _getFirstChallenge(towerRes.value)
	if not challenge then
		local fail = { success = false, code = "no_tower_challenge", message = "No tower challenge config available." }
		UIController.mountModal(StatePatterns.Error(nil, fail.message))
		return fail
	end

	local progress = towerRes.value.progressByChallengeId and towerRes.value.progressByChallengeId[challenge.challengeId]
	local screen = TowerChallengeScreen.create(profileRes.value, challenge, progress, function(challengeId, floorId, playerInstanceId)
		task.spawn(function()
			TowerChallengeController.runChallengeToCompletion(challengeId, floorId, playerInstanceId)
		end)
	end, function()
		TowerChallengeController.show()
	end)
	UIController.mountScreen(screen)

	return towerRes
end

function TowerChallengeController.runChallengeToCompletion(challengeId: string, floorId: string, playerInstanceId: string)
	UIController.init()
	UIController.mountModal(StatePatterns.Loading(nil))

	local profileRes = NetworkController.getPlayerProfileSnapshot()
	if not profileRes.success then
		UIController.clearModal()
		UIController.mountModal(StatePatterns.Error(nil, "Profile Load Failed: " .. tostring(profileRes.message or profileRes.code)))
		return profileRes
	end

	local playerInstance = _findInstance(profileRes.value, playerInstanceId)
	if not playerInstance then
		UIController.clearModal()
		local fail = { success = false, code = "missing_creature_instance", message = "Creature instance not found in profile." }
		UIController.mountModal(StatePatterns.Error(nil, fail.message))
		return fail
	end

	local startRes = NetworkController.requestTowerChallengeStart(challengeId, floorId, playerInstanceId)
	UIController.clearModal()
	if not startRes.success then
		UIController.mountModal(StatePatterns.Error(nil, "Tower Start Failed: " .. tostring(startRes.message or startRes.code)))
		return startRes
	end

	local startValue = startRes.value
	local playerConfig = CreatureRegistry.getCreature(playerInstance.creatureId)
	local enemyConfig = CreatureRegistry.getCreature(startValue.enemyCreatureId)
	local maxPlayerHp = playerConfig and playerConfig.baseStats and playerConfig.baseStats.hp or 100
	local maxEnemyHp = enemyConfig and enemyConfig.baseStats and enemyConfig.baseStats.hp or 100

	local screen, api = CombatScreen.create(
		playerInstance.creatureId,
		playerInstance.level or 1,
		startValue.enemyCreatureId,
		1,
		maxPlayerHp,
		maxEnemyHp
	)
	UIController.mountScreen(screen)
	api.updatePlayerHp(maxPlayerHp)
	api.updateEnemyHp(maxEnemyHp)
	api.appendLog("Tower Challenge started.")

	local timeline = startValue.timeline or {}
	local playerUnitIds = startValue.playerUnitIds or {}
	local enemyUnitIds = startValue.enemyUnitIds or {}

	for _, event in ipairs(timeline) do
		api.setCurrentTurn(event.turn or 0)
		local data = event.data or {}
		if event.type == "skill_use" or event.type == "fallback_attack" then
			local targetId = data.targetId
			local isEnemyTarget = _containsUnitId(enemyUnitIds, targetId)
			local isPlayerTarget = _containsUnitId(playerUnitIds, targetId)

			if isEnemyTarget then
				api.updateEnemyHp(data.targetHp or 0)
				api.showDamage(true, data.damage or 0)
				print(string.format("[TowerChallengeController] HP update target=enemy targetId=%s hp=%s", tostring(targetId), tostring(data.targetHp)))
			elseif isPlayerTarget then
				api.updatePlayerHp(data.targetHp or 0)
				api.showDamage(false, data.damage or 0)
				print(string.format("[TowerChallengeController] HP update target=player targetId=%s hp=%s", tostring(targetId), tostring(data.targetHp)))
			else
				warn(string.format("[TowerChallengeController] Timeline target did not map to any HP bar: %s", tostring(targetId)))
			end

			if event.type == "skill_use" then
				api.appendLog(string.format("[Turn %d] %s used %s on %s for %d.", event.turn or 0, tostring(data.actorId), tostring(data.skillId), tostring(targetId), data.damage or 0))
			else
				api.appendLog(string.format("[Turn %d] %s attacked %s for %d.", event.turn or 0, tostring(data.actorId), tostring(targetId), data.damage or 0))
			end
		end
		task.wait(0.35)
	end

	local completionRes = NetworkController.requestTowerChallengeComplete(startValue.runToken)
	if not completionRes.success then
		UIController.mountModal(StatePatterns.Error(nil, "Tower Completion Failed: " .. tostring(completionRes.message or completionRes.code)))
		return completionRes
	end

	UIController.mountModal(TowerChallengeResultModal.create(completionRes.value, function()
		UIController.clearModal()
		TowerChallengeController.show()
	end))

	return completionRes
end

return TowerChallengeController
