local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local CombatScreen = require(script.Parent.Parent.views.CombatScreen)
local BattleResultModal = require(script.Parent.Parent.views.BattleResultModal)
local StatePatterns = require(script.Parent.Parent.views.StatePatterns)
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)

local BattleController = {}

local currentTimeline = nil
local currentStepIndex = 0
local currentApi = nil
local currentBattleValue = nil
local currentOnComplete = nil
local currentEnemyConfigId = nil
local currentBattleToken = nil
local currentPlayerUnitIds = {}
local currentEnemyUnitIds = {}
local currentCompletionRequested = false
local autoProgress = true
local stepPromise = nil

-- Configures auto progress (Studio/QA simulator support)
function BattleController.setAutoProgress(enabled)
	autoProgress = enabled
end

-- Advances one turn in the timeline manually
function BattleController.nextTurn()
	if autoProgress then return end
	if not currentTimeline or currentStepIndex > #currentTimeline then return end
	BattleController._step()
end

local function _containsUnitId(unitIds, targetId)
	for _, unitId in ipairs(unitIds or {}) do
		if unitId == targetId then
			return true
		end
	end
	return false
end

function BattleController._step()
	currentStepIndex += 1
	if currentStepIndex > #currentTimeline then
		if currentCompletionRequested then
			return
		end
		currentCompletionRequested = true

		local completionRes = NetworkController.requestBattleCompletion(currentBattleToken)
		if not completionRes.success then
			UIController.mountModal(StatePatterns.Error(nil, "Battle Completion Failed: " .. tostring(completionRes.message or completionRes.code)))
			task.delay(3, function()
				UIController.clearModal()
				if currentOnComplete then
					currentOnComplete()
				end
			end)
			return
		end

		currentBattleValue = completionRes.value

		-- Battle finished, show result modal
		UIController.mountModal(BattleResultModal.create(currentBattleValue, function()
			UIController.clearModal()
			if currentOnComplete then 
				currentOnComplete() 
			end
		end))
		return
	end

	local event = currentTimeline[currentStepIndex]
	currentApi.setCurrentTurn(event.turn)

	local data = event.data
	if event.type == "skill_use" or event.type == "fallback_attack" then
		local isEnemyTarget = _containsUnitId(currentEnemyUnitIds, data.targetId)
		local isPlayerTarget = _containsUnitId(currentPlayerUnitIds, data.targetId)
		
		-- Update HP
		if isEnemyTarget then
			currentApi.updateEnemyHp(data.targetHp)
			currentApi.showDamage(true, data.damage)
		elseif isPlayerTarget then
			currentApi.updatePlayerHp(data.targetHp)
			currentApi.showDamage(false, data.damage)
		end

		-- Log entry
		local logText = ""
		if event.type == "skill_use" then
			logText = string.format("[Turn %d] %s used %s on %s, dealing %d damage!", event.turn, data.actorId, data.skillId, data.targetId, data.damage)
		else
			logText = string.format("[Turn %d] %s fallback attacked %s, dealing %d damage!", event.turn, data.actorId, data.targetId, data.damage)
		end
		currentApi.appendLog(logText)
	end

	-- Auto-progression timing
	if autoProgress then
		task.delay(1.2, function()
			BattleController._step()
		end)
	end
end

function BattleController.start(playerCreatureId, stageId, onComplete)
	UIController.mountModal(StatePatterns.Loading(nil))

	-- Fetch initial player creature level
	local initialLevel = 1
	local profileRes = NetworkController.getPlayerProfileSnapshot()
	if profileRes.success then
		for _, inst in pairs(profileRes.value.creatureInstances) do
			if inst.creatureId == playerCreatureId then
				initialLevel = inst.level
				break
			end
		end
	end

	local res = NetworkController.requestStoryBattle(playerCreatureId, stageId)
	UIController.clearModal()

	if not res.success then
		UIController.mountModal(StatePatterns.Error(nil, "Battle Request Failed: " .. tostring(res.message or res.code)))
		task.delay(3, function()
			UIController.clearModal()
			onComplete()
		end)
		return
	end

	local val = res.value
	local enemyConfigId = val.enemyConfigId
	local pConfig = CreatureRegistry.getCreature(playerCreatureId)
	local eConfig = CreatureRegistry.getCreature(enemyConfigId)
	local maxPlayerHp = pConfig and pConfig.baseStats and pConfig.baseStats.hp or 100
	local maxEnemyHp = eConfig and eConfig.baseStats and eConfig.baseStats.hp or 50

	-- Create Combat Screen
	local screen, api = CombatScreen.create(
		playerCreatureId, 
		initialLevel, 
		enemyConfigId, 
		1, 
		maxPlayerHp, 
		maxEnemyHp
	)
	UIController.mountScreen(screen)

	-- Initialize simulation parameters
	currentTimeline = val.timeline or {}
	currentStepIndex = 0
	currentApi = api
	currentBattleValue = nil
	currentOnComplete = onComplete
	currentEnemyConfigId = enemyConfigId
	currentBattleToken = val.battleToken
	currentPlayerUnitIds = val.playerUnitIds or {}
	currentEnemyUnitIds = val.enemyUnitIds or {}
	currentCompletionRequested = false

	currentApi.updatePlayerHp(maxPlayerHp)
	currentApi.updateEnemyHp(maxEnemyHp)
	currentApi.appendLog("Battle Commenced! Click Continue when done.")

	if #currentTimeline == 0 then
		-- No turns, go straight to result
		BattleController._step()
	else
		if autoProgress then
			task.delay(1.2, function()
				BattleController._step()
			end)
		end
	end
end

return BattleController
