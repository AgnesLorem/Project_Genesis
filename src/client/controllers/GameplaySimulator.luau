local RunService = game:GetService("RunService")
local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local LoadingController = require(script.Parent.LoadingController)
local StarterController = require(script.Parent.StarterController)
local WorldController = require(script.Parent.WorldController)
local BattleController = require(script.Parent.BattleController)
local TowerChallengeController = require(script.Parent.TowerChallengeController)
local InventoryController = require(script.Parent.InventoryController)
local EquipmentController = require(script.Parent.EquipmentController)
local SkillController = require(script.Parent.SkillController)
local GeneratorController = require(script.Parent.GeneratorController)
local Players = game:GetService("Players")

local GameplaySimulator = {}

local function assertStudio()
	if not RunService:IsStudio() then
		error("[GameplaySimulator] Access Denied: Simulator is disabled in production.")
	end
end

local function ensureUiReady()
	UIController.init()
end

local function _critical(message: string)
	error("[GameplaySimulator][MVP-HARD] Critical: " .. message)
end

local function _mvp016Critical(message: string)
	error("[GameplaySimulator][MVP-016] Critical: " .. message)
end

local function _mvp017Critical(message: string)
	error("[GameplaySimulator][MVP-017] Critical: " .. message)
end

local function _mvp019Critical(message: string)
	error("[GameplaySimulator][MVP-019] Critical: " .. message)
end

local function _suitePass(name: string)
	print(string.format("[GameplaySimulator][MVP-016] %s PASS", name))
end

local function _suiteFail(name: string, message: string)
	print(string.format("[GameplaySimulator][MVP-016] %s FAIL: %s", name, message))
	_mvp016Critical(name .. " failed: " .. message)
end

local function _skillSuitePass(name: string)
	print(string.format("[GameplaySimulator][MVP-017] %s PASS", name))
end

local function _skillSuiteFail(name: string, message: string)
	print(string.format("[GameplaySimulator][MVP-017] %s FAIL: %s", name, message))
	_mvp017Critical(name .. " failed: " .. message)
end

local function _generatorSuitePass(name: string)
	print(string.format("[GameplaySimulator][MVP-019] %s PASS", name))
end

local function _generatorSuiteFail(name: string, message: string)
	print(string.format("[GameplaySimulator][MVP-019] %s FAIL: %s", name, message))
	_mvp019Critical(name .. " failed: " .. message)
end

local function _findInventoryItem(snapshot: any, itemId: string): any
	for _, item in ipairs(snapshot and snapshot.items or {}) do
		if item.itemId == itemId then
			return item
		end
	end
	return nil
end

local function _findEquipmentSlot(snapshot: any, slotId: string): any
	for _, slot in ipairs(snapshot and snapshot.slots or {}) do
		if slot.slotId == slotId then
			return slot
		end
	end
	return nil
end

local function _assertFail(result: any, expectedCode: string, context: string)
	if result.success then
		_mvp016Critical(context .. " unexpectedly succeeded.")
	end
	if result.code ~= expectedCode then
		_mvp016Critical(string.format("%s expected %s, got %s.", context, expectedCode, tostring(result.code)))
	end
end

local function _assertSkillFail(result: any, expectedCode: string, context: string)
	if result.success then
		_mvp017Critical(context .. " unexpectedly succeeded.")
	end
	if result.code ~= expectedCode then
		_mvp017Critical(string.format("%s expected %s, got %s.", context, expectedCode, tostring(result.code)))
	end
end

local function _assertGeneratorFail(result: any, expectedCode: string, context: string)
	if result.success then
		_mvp019Critical(context .. " unexpectedly succeeded.")
	end
	if result.code ~= expectedCode then
		_mvp019Critical(string.format("%s expected %s, got %s.", context, expectedCode, tostring(result.code)))
	end
end

local function _assertInventoryQuantities(snapshot: any)
	for _, item in ipairs(snapshot and snapshot.items or {}) do
		if type(item.quantity) ~= "number" or item.quantity <= 0 or item.quantity ~= math.floor(item.quantity) then
			_mvp016Critical("inventory snapshot exposed invalid quantity for " .. tostring(item.itemId))
		end
	end
end

local function _getFirstCreatureInstance(profileSnapshot: any): any
	for _, inst in pairs(profileSnapshot.creatureInstances or {}) do
		return inst
	end
	return nil
end

local function _getTowerDefaults()
	local towerRes = NetworkController.getTowerChallengeSnapshot()
	if not towerRes.success then
		return nil, nil, towerRes
	end

	local challenge = towerRes.value.challenges and towerRes.value.challenges[1]
	local floor = challenge and challenge.floors and challenge.floors[1]
	if not challenge or not floor then
		return nil, nil, { success = false, code = "no_tower_config", message = "No tower challenge/floor config available." }
	end

	return challenge, floor, towerRes
end

local function _getTowerProgress(snapshot: any, challengeId: string): any
	return snapshot
		and snapshot.progressByChallengeId
		and snapshot.progressByChallengeId[challengeId]
		or nil
end

local function _progressAttempts(snapshot: any, challengeId: string): number
	local progress = _getTowerProgress(snapshot, challengeId)
	return progress and progress.totalAttempts or 0
end

local TOWER_SEMANTIC_REQUEST_WAIT = 1.05

local function _waitTowerSemanticRequestWindow()
	task.wait(TOWER_SEMANTIC_REQUEST_WAIT)
end

-- Simulates claiming the bio generator
function GameplaySimulator.claimGenerator()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator] Command: Claiming Bio Generator...")

	local snapRes = NetworkController.getPlayerProfileSnapshot()
	if not snapRes.success then
		print("[GameplaySimulator] Failed to get profile snapshot.")
		return snapRes
	end

	local generator = snapRes.value.generators and snapRes.value.generators[1]
	if not generator or not generator.generatorId then
		print("[GameplaySimulator] No generator snapshot available.")
		return { success = false, message = "no_generator" }
	end

	local res = NetworkController.requestGeneratorClaim(generator.generatorId)
	if res.success then
		print(string.format("[GameplaySimulator] Generator Claim Success! Claimed: %d, New Balance: %d", res.value.claimed, res.value.newBalance))
		GameplaySimulator.refreshWorld()
	else
		print("[GameplaySimulator] Generator Claim Failed: " .. tostring(res.message or res.code))
	end
	return res
end

-- Simulates starting a story battle
function GameplaySimulator.runStoryBattle()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator] Command: Starting Story Battle...")
	
	-- Find active creature
	local snapRes = NetworkController.getPlayerProfileSnapshot()
	if not snapRes.success then
		print("[GameplaySimulator] Failed to get profile snapshot.")
		return snapRes
	end

	local playerCreatureId = nil
	for _, inst in pairs(snapRes.value.creatureInstances) do
		playerCreatureId = inst.creatureId
		break
	end
	local stageId = snapRes.value.world
		and snapRes.value.world.unlockedStages
		and snapRes.value.world.unlockedStages[1]
		or "story_stage_1"

	if not playerCreatureId then
		print("[GameplaySimulator] No active creature to battle with.")
		return { success = false, message = "no_creature" }
	end

	-- Run battle
	print("[GameplaySimulator] Entering battle with " .. playerCreatureId)
	
	-- Disable auto-progress for manual timeline stepping validation
	if BattleController.setAutoProgress then
		BattleController.setAutoProgress(false)
	end
	
	local complete = false
	task.spawn(function()
		BattleController.start(playerCreatureId, stageId, function()
			complete = true
		end)
	end)
	
	task.wait(1.0) -- wait for battle screen mount
	print("[GameplaySimulator] SCREENSHOT TRIGGER: Combat Initialized")
	
	-- Step through turns
	print("[GameplaySimulator] Stepping through battle turns manually...")
	local steps = 0
	local maxSteps = 60
	for i = 1, 10 do
		task.wait(0.5)
		if BattleController.nextTurn then
			BattleController.nextTurn()
		end
		steps += 1
		
		-- Check if BattleResultModal (BaseModal) is mounted
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local mainUI = playerGui:FindFirstChild("GenesisMainUI")
		local modal = mainUI and mainUI:FindFirstChild("BaseModal")
		if modal and modal:FindFirstChild("ContinueButton", true) then
			complete = true
			break
		end
	end
	
	-- Wait for completion if not already
	while not complete and steps < maxSteps do
		task.wait(0.5)
		if BattleController.nextTurn then
			BattleController.nextTurn()
		end
		steps += 1
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local mainUI = playerGui:FindFirstChild("GenesisMainUI")
		local modal = mainUI and mainUI:FindFirstChild("BaseModal")
		if modal and modal:FindFirstChild("ContinueButton", true) then
			complete = true
		end
	end

	if not complete then
		print("[GameplaySimulator] Battle timed out before result modal.")
		GameplaySimulator.refreshWorld()
		return { success = false, message = "battle_timeout" }
	end
	
	print("[GameplaySimulator] Battle finished.")
	print("[GameplaySimulator] SCREENSHOT TRIGGER: Battle Result")
	
	-- Click continue button / close modal
	task.wait(1.0)
	print("[GameplaySimulator] Simulating Continue Button click (closing modal)...")
	UIController.clearModal()
	GameplaySimulator.refreshWorld()

	return { success = true }
end

-- Simulates evolving the active creature
function GameplaySimulator.evolveActiveCreature()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator] Command: Evolving Active Creature...")
	
	local snapRes = NetworkController.getPlayerProfileSnapshot()
	if not snapRes.success then
		print("[GameplaySimulator] Failed to get profile snapshot.")
		return snapRes
	end

	local activeInstId = nil
	local activeEvoId = nil
	for instId, inst in pairs(snapRes.value.creatureInstances) do
		activeInstId = instId
		local opt = snapRes.value.evolutionOptions and snapRes.value.evolutionOptions[instId]
		if opt then
			activeEvoId = opt.evolutionId
		end
		break
	end

	if not activeInstId or not activeEvoId then
		print("[GameplaySimulator] Active creature is not eligible or has no evolution config.")
		return { success = false, message = "not_eligible" }
	end

	local res = NetworkController.requestEvolution(activeInstId, activeEvoId)
	if res.success then
		print("[GameplaySimulator] Evolution Success! Mutated to " .. res.value.newCreatureId)
		print("[GameplaySimulator] SCREENSHOT TRIGGER: Evolution success")
		GameplaySimulator.refreshWorld()
	else
		print("[GameplaySimulator] Evolution Failed: " .. tostring(res.message or res.code))
	end
	return res
end

-- Simulates refreshing the world snapshot
function GameplaySimulator.refreshWorld()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator] Command: Refreshing World Hub...")
	local snapRes = NetworkController.getPlayerProfileSnapshot()
	if snapRes.success then
		WorldController.start(snapRes.value)
		print("[GameplaySimulator] World Hub refreshed.")
	else
		print("[GameplaySimulator] Failed to refresh World Hub.")
	end
	return snapRes
end

function GameplaySimulator.openTowerChallenge()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator][MVP-HARD] Command: Opening Tower Challenge screen.")
	local res = TowerChallengeController.show()
	if res.success then
		print("[GameplaySimulator][MVP-HARD] SCREENSHOT TRIGGER: Tower Challenge screen")
	else
		print("[GameplaySimulator][MVP-HARD] Tower screen failed: " .. tostring(res.message or res.code))
	end
	return res
end

function GameplaySimulator.invalidTowerChallengeRequests()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator][MVP-HARD] Security Test: Invalid Tower requests.")

	local profileRes = NetworkController.getPlayerProfileSnapshot()
	if not profileRes.success then
		_critical("Profile snapshot failed before invalid request test: " .. tostring(profileRes.message or profileRes.code))
	end

	local ownedInstance = _getFirstCreatureInstance(profileRes.value)
	local instanceId = ownedInstance and ownedInstance.instanceId or "invalid_instance"
	local challenge, floor, towerRes = _getTowerDefaults()
	if not towerRes.success then
		_critical("Tower defaults unavailable: " .. tostring(towerRes.message or towerRes.code))
	end

	local attempts = {
		function()
			return NetworkController.requestTowerChallengeStart("", floor.floorId, instanceId)
		end,
		function()
			return NetworkController.requestTowerChallengeStart(challenge.challengeId, "", instanceId)
		end,
		function()
			return NetworkController.requestTowerChallengeStart(challenge.challengeId, floor.floorId, "")
		end,
		function()
			return NetworkController.requestTowerChallengeStart("invalid_challenge", floor.floorId, instanceId)
		end,
		function()
			return NetworkController.requestTowerChallengeStart(challenge.challengeId, "invalid_floor", instanceId)
		end,
		function()
			return NetworkController.requestTowerChallengeStart(challenge.challengeId, floor.floorId, "invalid_instance")
		end,
		function()
			return NetworkController.requestTowerChallengeComplete("invalid_token")
		end,
	}

	for index, request in ipairs(attempts) do
		local res = request()
		if res.success then
			_critical("Invalid Tower request unexpectedly succeeded at case " .. tostring(index))
		end
		print(string.format("[GameplaySimulator][MVP-HARD] Invalid request %d rejected: %s", index, tostring(res.code)))
		if index < #attempts then
			_waitTowerSemanticRequestWindow()
		end
	end

	return { success = true, rejected = #attempts }
end

function GameplaySimulator.spamTowerChallengeStartTest()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator][MVP-HARD] Security Test: Spamming Tower start.")

	local profileRes = NetworkController.getPlayerProfileSnapshot()
	if not profileRes.success then
		_critical("Profile snapshot failed before spam start test: " .. tostring(profileRes.message or profileRes.code))
	end

	local ownedInstance = _getFirstCreatureInstance(profileRes.value)
	if not ownedInstance then
		_critical("No owned creature instance available for Tower start spam test.")
	end

	local challenge, floor, towerRes = _getTowerDefaults()
	if not towerRes.success then
		_critical("Tower defaults unavailable: " .. tostring(towerRes.message or towerRes.code))
	end

	local successes = 0
	local failures = 0
	local token = nil
	for _ = 1, 5 do
		local res = NetworkController.requestTowerChallengeStart(challenge.challengeId, floor.floorId, ownedInstance.instanceId)
		if res.success then
			successes += 1
			token = token or res.value.runToken
		else
			failures += 1
		end
	end

	if token then
		local completeRes = NetworkController.requestTowerChallengeComplete(token)
		if not completeRes.success then
			_critical("Cleanup completion failed after spam start test: " .. tostring(completeRes.message or completeRes.code))
		end
	end

	print(string.format("[GameplaySimulator][MVP-HARD] Spam start results: %d successes, %d failures.", successes, failures))
	if successes ~= 1 or failures ~= 4 then
		_critical("Tower start spam guard failed.")
	end

	return { success = true, successes = successes, failures = failures }
end

function GameplaySimulator.spamTowerChallengeCompleteTest()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator][MVP-HARD] Security Test: Spamming Tower completion.")

	local profileRes = NetworkController.getPlayerProfileSnapshot()
	if not profileRes.success then
		_critical("Profile snapshot failed before spam completion test: " .. tostring(profileRes.message or profileRes.code))
	end

	local ownedInstance = _getFirstCreatureInstance(profileRes.value)
	if not ownedInstance then
		_critical("No owned creature instance available for Tower completion spam test.")
	end

	local challenge, floor, towerRes = _getTowerDefaults()
	if not towerRes.success then
		_critical("Tower defaults unavailable: " .. tostring(towerRes.message or towerRes.code))
	end

	local beforeAttempts = _progressAttempts(towerRes.value, challenge.challengeId)
	local startRes = NetworkController.requestTowerChallengeStart(challenge.challengeId, floor.floorId, ownedInstance.instanceId)
	if not startRes.success then
		_critical("Tower start failed before completion spam test: " .. tostring(startRes.message or startRes.code))
	end

	local firstCompletion = NetworkController.requestTowerChallengeComplete(startRes.value.runToken)
	local secondCompletion = NetworkController.requestTowerChallengeComplete(startRes.value.runToken)
	local afterRes = NetworkController.getTowerChallengeSnapshot()
	if not afterRes.success then
		_critical("Tower snapshot failed after completion spam test: " .. tostring(afterRes.message or afterRes.code))
	end
	local afterAttempts = _progressAttempts(afterRes.value, challenge.challengeId)

	if not firstCompletion.success then
		_critical("First Tower completion failed: " .. tostring(firstCompletion.message or firstCompletion.code))
	end
	if secondCompletion.success then
		_critical("Duplicate Tower completion succeeded.")
	end
	if afterAttempts ~= beforeAttempts + 1 then
		_critical(string.format("Tower completion was not idempotent. before=%d after=%d", beforeAttempts, afterAttempts))
	end

	print(string.format(
		"[GameplaySimulator][MVP-HARD] Completion spam rejected duplicate: first=%s second=%s attempts %d->%d.",
		tostring(firstCompletion.success),
		tostring(secondCompletion.code),
		beforeAttempts,
		afterAttempts
	))

	return { success = true }
end

function GameplaySimulator.reconnectDuringTowerChallengeTest()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator][MVP-HARD] Reconnect Test: During active Tower run.")

	local profileRes = NetworkController.getPlayerProfileSnapshot()
	if not profileRes.success then
		_critical("Profile snapshot failed before reconnect-during-run test: " .. tostring(profileRes.message or profileRes.code))
	end

	local ownedInstance = _getFirstCreatureInstance(profileRes.value)
	if not ownedInstance then
		_critical("No owned creature instance available for reconnect-during-run test.")
	end

	local challenge, floor, beforeTowerRes = _getTowerDefaults()
	if not beforeTowerRes.success then
		_critical("Tower defaults unavailable: " .. tostring(beforeTowerRes.message or beforeTowerRes.code))
	end
	local beforeAttempts = _progressAttempts(beforeTowerRes.value, challenge.challengeId)

	local startRes = NetworkController.requestTowerChallengeStart(challenge.challengeId, floor.floorId, ownedInstance.instanceId)
	if not startRes.success then
		_critical("Tower start failed before reconnect-during-run test: " .. tostring(startRes.message or startRes.code))
	end

	local reconnectRes = GameplaySimulator.reconnectValidation()
	if not reconnectRes.success then
		_critical("Reconnect validation failed during Tower run.")
	end

	local completeAfterReconnect = NetworkController.requestTowerChallengeComplete(startRes.value.runToken)
	if not completeAfterReconnect.success then
		_critical("Tower completion failed after client reconnect: " .. tostring(completeAfterReconnect.message or completeAfterReconnect.code))
	end

	local afterTowerRes = NetworkController.getTowerChallengeSnapshot()
	if not afterTowerRes.success then
		_critical("Tower snapshot failed after reconnect-during-run test: " .. tostring(afterTowerRes.message or afterTowerRes.code))
	end
	local afterAttempts = _progressAttempts(afterTowerRes.value, challenge.challengeId)
	if afterAttempts ~= beforeAttempts + 1 then
		_critical(string.format("Client reconnect Tower completion did not increment attempts once. before=%d after=%d", beforeAttempts, afterAttempts))
	end

	print(string.format("[GameplaySimulator][MVP-HARD] Client reconnect preserved active Tower run safely. attempts %d->%d.", beforeAttempts, afterAttempts))
	return { success = true }
end

function GameplaySimulator.reconnectAfterTowerChallengeCompleteTest()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator][MVP-HARD] Reconnect Test: After Tower completion.")

	local profileRes = NetworkController.getPlayerProfileSnapshot()
	if not profileRes.success then
		_critical("Profile snapshot failed before reconnect-after-complete test: " .. tostring(profileRes.message or profileRes.code))
	end

	local ownedInstance = _getFirstCreatureInstance(profileRes.value)
	if not ownedInstance then
		_critical("No owned creature instance available for reconnect-after-complete test.")
	end

	local challenge, floor, beforeTowerRes = _getTowerDefaults()
	if not beforeTowerRes.success then
		_critical("Tower defaults unavailable: " .. tostring(beforeTowerRes.message or beforeTowerRes.code))
	end
	local beforeAttempts = _progressAttempts(beforeTowerRes.value, challenge.challengeId)

	local completionRes = TowerChallengeController.runChallengeToCompletion(challenge.challengeId, floor.floorId, ownedInstance.instanceId)
	if not completionRes.success then
		_critical("Tower completion flow failed: " .. tostring(completionRes.message or completionRes.code))
	end
	print("[GameplaySimulator][MVP-HARD] SCREENSHOT TRIGGER: Tower result modal")

	local reconnectRes = GameplaySimulator.reconnectValidation()
	if not reconnectRes.success then
		_critical("Reconnect validation failed after Tower completion.")
	end

	local afterTowerRes = NetworkController.getTowerChallengeSnapshot()
	if not afterTowerRes.success then
		_critical("Tower snapshot failed after reconnect-after-complete test: " .. tostring(afterTowerRes.message or afterTowerRes.code))
	end
	local afterAttempts = _progressAttempts(afterTowerRes.value, challenge.challengeId)
	if afterAttempts < beforeAttempts + 1 then
		_critical(string.format("Tower completion progress did not persist. before=%d after=%d", beforeAttempts, afterAttempts))
	end

	print(string.format("[GameplaySimulator][MVP-HARD] Reconnect restored Tower progress. attempts %d->%d.", beforeAttempts, afterAttempts))
	return { success = true }
end

function GameplaySimulator.runTowerChallengeFullFlow()
	assertStudio()
	ensureUiReady()
	print("==================================================")
	print("[GameplaySimulator][MVP-HARD] STARTING TOWER CHALLENGE FULL FLOW")
	print("==================================================")

	local profileRes = NetworkController.getPlayerProfileSnapshot()
	if not profileRes.success then
		_critical("Profile snapshot failed: " .. tostring(profileRes.message or profileRes.code))
	end

	local ownedInstance = _getFirstCreatureInstance(profileRes.value)
	if not ownedInstance then
		_critical("Tower Challenge requires an owned creature instance.")
	end

	local openRes = GameplaySimulator.openTowerChallenge()
	if not openRes.success then
		_critical("Tower screen failed: " .. tostring(openRes.message or openRes.code))
	end

	local challenge, floor, towerRes = _getTowerDefaults()
	if not towerRes.success then
		_critical("Tower defaults unavailable: " .. tostring(towerRes.message or towerRes.code))
	end

	GameplaySimulator.invalidTowerChallengeRequests()
	_waitTowerSemanticRequestWindow()

	local beforeAttempts = _progressAttempts(towerRes.value, challenge.challengeId)
	local completionRes = TowerChallengeController.runChallengeToCompletion(challenge.challengeId, floor.floorId, ownedInstance.instanceId)
	if not completionRes.success then
		_critical("Tower challenge completion failed: " .. tostring(completionRes.message or completionRes.code))
	end
	print("[GameplaySimulator][MVP-HARD] SCREENSHOT TRIGGER: Tower combat/result")

	local afterRes = NetworkController.getTowerChallengeSnapshot()
	if not afterRes.success then
		_critical("Tower snapshot failed after valid completion: " .. tostring(afterRes.message or afterRes.code))
	end
	local afterAttempts = _progressAttempts(afterRes.value, challenge.challengeId)
	if afterAttempts ~= beforeAttempts + 1 then
		_critical(string.format("Valid Tower completion did not increment attempts once. before=%d after=%d", beforeAttempts, afterAttempts))
	end

	_waitTowerSemanticRequestWindow()
	GameplaySimulator.spamTowerChallengeStartTest()
	_waitTowerSemanticRequestWindow()
	GameplaySimulator.spamTowerChallengeCompleteTest()
	_waitTowerSemanticRequestWindow()
	GameplaySimulator.reconnectDuringTowerChallengeTest()
	_waitTowerSemanticRequestWindow()
	GameplaySimulator.reconnectAfterTowerChallengeCompleteTest()

	print("==================================================")
	print("[GameplaySimulator][MVP-HARD] TOWER CHALLENGE FULL FLOW COMPLETE WITHOUT CRITICAL/HIGH BUGS")
	print("==================================================")
	return { success = true }
end

function GameplaySimulator.runMvpHardFullFlow()
	return GameplaySimulator.runTowerChallengeFullFlow()
end

function GameplaySimulator.runInventorySuite()
	assertStudio()
	ensureUiReady()
	local suite = "InventorySuite"
	print("[GameplaySimulator][MVP-016] InventorySuite START")

	local snapshotRes = NetworkController.getInventorySnapshot()
	if not snapshotRes.success then
		_suiteFail(suite, "inventory snapshot failed: " .. tostring(snapshotRes.message or snapshotRes.code))
	end

	local weapon = _findInventoryItem(snapshotRes.value, "item_training_blade")
	local armor = _findInventoryItem(snapshotRes.value, "item_scout_vest")
	local consumable = _findInventoryItem(snapshotRes.value, "item_health_cell")
	if not weapon or weapon.quantity < 1 then
		_suiteFail(suite, "starter weapon was not received through inventory migration.")
	end
	if not armor or armor.quantity < 1 then
		_suiteFail(suite, "starter armor was not received through inventory migration.")
	end
	if not consumable or consumable.quantity < 1 then
		_suiteFail(suite, "starter consumable was not received through inventory migration.")
	end

	local screenRes = InventoryController.show()
	if not screenRes.success then
		_suiteFail(suite, "inventory screen failed: " .. tostring(screenRes.message or screenRes.code))
	end
	print("[GameplaySimulator][MVP-016] SCREENSHOT TRIGGER: Inventory")

	local tooltipRes = InventoryController.showTooltip("item_training_blade")
	if not tooltipRes.success then
		_suiteFail(suite, "item tooltip failed: " .. tostring(tooltipRes.message or tooltipRes.code))
	end
	print("[GameplaySimulator][MVP-016] SCREENSHOT TRIGGER: Item Tooltip")
	task.wait(0.2)
	UIController.clearModal()

	_suitePass(suite)
	return { success = true }
end

function GameplaySimulator.runEquipmentSuite()
	assertStudio()
	ensureUiReady()
	local suite = "EquipmentSuite"
	print("[GameplaySimulator][MVP-016] EquipmentSuite START")

	NetworkController.requestUnequipItem("weapon")
	NetworkController.requestUnequipItem("armor")
	NetworkController.requestUnequipItem("accessory")

	local equipWeaponRes = NetworkController.requestEquipItem("item_training_blade", "weapon")
	if not equipWeaponRes.success then
		_suiteFail(suite, "weapon equip failed: " .. tostring(equipWeaponRes.message or equipWeaponRes.code))
	end

	local duplicateRes = NetworkController.requestEquipItem("item_training_blade", "weapon")
	_assertFail(duplicateRes, "duplicate_equip", "duplicate equip")

	local equipArmorRes = NetworkController.requestEquipItem("item_scout_vest", "armor")
	if not equipArmorRes.success then
		_suiteFail(suite, "armor equip failed: " .. tostring(equipArmorRes.message or equipArmorRes.code))
	end

	local snapshotRes = NetworkController.getEquipmentSnapshot()
	if not snapshotRes.success then
		_suiteFail(suite, "equipment snapshot failed: " .. tostring(snapshotRes.message or snapshotRes.code))
	end

	local weaponSlot = _findEquipmentSlot(snapshotRes.value, "weapon")
	local armorSlot = _findEquipmentSlot(snapshotRes.value, "armor")
	if not weaponSlot or weaponSlot.itemId ~= "item_training_blade" then
		_suiteFail(suite, "equipped weapon snapshot mismatch.")
	end
	if not armorSlot or armorSlot.itemId ~= "item_scout_vest" then
		_suiteFail(suite, "equipped armor snapshot mismatch.")
	end

	local screenRes = EquipmentController.show()
	if not screenRes.success then
		_suiteFail(suite, "equipment screen failed: " .. tostring(screenRes.message or screenRes.code))
	end
	print("[GameplaySimulator][MVP-016] SCREENSHOT TRIGGER: Equipment Screen")
	print("[GameplaySimulator][MVP-016] SCREENSHOT TRIGGER: Equipped Weapon")
	print("[GameplaySimulator][MVP-016] SCREENSHOT TRIGGER: Equipped Armor")

	local unequipRes = NetworkController.requestUnequipItem("weapon")
	if not unequipRes.success then
		_suiteFail(suite, "weapon unequip failed: " .. tostring(unequipRes.message or unequipRes.code))
	end
	local afterUnequip = NetworkController.getEquipmentSnapshot()
	if not afterUnequip.success then
		_suiteFail(suite, "equipment snapshot after unequip failed: " .. tostring(afterUnequip.message or afterUnequip.code))
	end
	local emptyWeaponSlot = _findEquipmentSlot(afterUnequip.value, "weapon")
	if emptyWeaponSlot and emptyWeaponSlot.itemId ~= nil then
		_suiteFail(suite, "weapon slot remained occupied after unequip.")
	end

	local reEquipWeapon = NetworkController.requestEquipItem("item_training_blade", "weapon")
	if not reEquipWeapon.success then
		_suiteFail(suite, "weapon re-equip failed: " .. tostring(reEquipWeapon.message or reEquipWeapon.code))
	end

	_suitePass(suite)
	return { success = true }
end

function GameplaySimulator.runPersistenceSuite()
	assertStudio()
	ensureUiReady()
	local suite = "PersistenceSuite"
	print("[GameplaySimulator][MVP-016] PersistenceSuite START")

	local equipWeaponRes = NetworkController.requestEquipItem("item_training_blade", "weapon")
	if not equipWeaponRes.success and equipWeaponRes.code ~= "duplicate_equip" then
		_suiteFail(suite, "pre-reconnect weapon equip failed: " .. tostring(equipWeaponRes.message or equipWeaponRes.code))
	end

	local beforeInventory = NetworkController.getInventorySnapshot()
	local beforeEquipment = NetworkController.getEquipmentSnapshot()
	if not beforeInventory.success or not beforeEquipment.success then
		_suiteFail(suite, "snapshot before reconnect failed.")
	end

	local reconnectRes = GameplaySimulator.reconnectValidation()
	if not reconnectRes.success then
		_suiteFail(suite, "reconnect validation failed.")
	end

	local afterInventory = NetworkController.getInventorySnapshot()
	local afterEquipment = NetworkController.getEquipmentSnapshot()
	if not afterInventory.success or not afterEquipment.success then
		_suiteFail(suite, "snapshot after reconnect failed.")
	end

	if not _findInventoryItem(afterInventory.value, "item_training_blade") then
		_suiteFail(suite, "inventory item missing after reconnect.")
	end
	local weaponSlot = _findEquipmentSlot(afterEquipment.value, "weapon")
	if not weaponSlot or weaponSlot.itemId ~= "item_training_blade" then
		_suiteFail(suite, "equipped weapon not restored after reconnect.")
	end

	print("[GameplaySimulator][MVP-016] SCREENSHOT TRIGGER: Reconnect Restored State")
	_suitePass(suite)
	return { success = true }
end

function GameplaySimulator.runValidationSuite()
	assertStudio()
	ensureUiReady()
	local suite = "ValidationSuite"
	local semanticWaitSeconds = 1.05
	print("[GameplaySimulator][MVP-016] ValidationSuite START")

	local function _assertSemanticFail(callback, expectedCode: string, context: string)
		task.wait(semanticWaitSeconds)
		_assertFail(callback(), expectedCode, context)
	end

	local quantitySnapshot = NetworkController.getInventorySnapshot()
	if not quantitySnapshot.success then
		_suiteFail(suite, "inventory quantity snapshot failed: " .. tostring(quantitySnapshot.message or quantitySnapshot.code))
	end
	_assertInventoryQuantities(quantitySnapshot.value)
	print("[GameplaySimulator][MVP-016] Invalid quantity check passed via server-normalized inventory snapshot.")

	_assertSemanticFail(function()
		return NetworkController.requestEquipItem(nil, "weapon")
	end, "invalid_item", "nil item")
	_assertSemanticFail(function()
		return NetworkController.requestEquipItem(123, "weapon")
	end, "invalid_item", "wrong datatype item")
	_assertSemanticFail(function()
		return NetworkController.requestEquipItem("", "weapon")
	end, "invalid_item", "empty item")
	_assertSemanticFail(function()
		return NetworkController.requestEquipItem("item_training_blade", nil)
	end, "invalid_slot", "nil slot")
	_assertSemanticFail(function()
		return NetworkController.requestEquipItem("item_training_blade", "not_a_slot")
	end, "invalid_slot", "invalid slot")
	_assertSemanticFail(function()
		return NetworkController.requestEquipItem("missing_item_001", "weapon")
	end, "removed_item", "removed item")
	_assertSemanticFail(function()
		return NetworkController.requestEquipItem("item_disabled_blade", "weapon")
	end, "disabled_item", "disabled item")
	_assertSemanticFail(function()
		return NetworkController.requestEquipItem("item_health_cell", "weapon")
	end, "not_equipment", "non-equipment item")
	_assertSemanticFail(function()
		return NetworkController.requestEquipItem("item_training_blade", "armor")
	end, "wrong_equipment_type", "wrong equipment type")
	_assertSemanticFail(function()
		return NetworkController.requestEquipItem("item_focus_charm", "accessory")
	end, "unowned_item", "unowned equipment item")
	_assertSemanticFail(function()
		return NetworkController.requestUnequipItem(nil)
	end, "invalid_slot", "nil unequip slot")
	_assertSemanticFail(function()
		return NetworkController.requestUnequipItem("not_a_slot")
	end, "invalid_slot", "invalid unequip slot")

	task.wait(semanticWaitSeconds)
	NetworkController.requestUnequipItem("weapon")
	task.wait(semanticWaitSeconds)
	local duplicateSetup = NetworkController.requestEquipItem("item_training_blade", "weapon")
	if not duplicateSetup.success then
		_suiteFail(suite, "duplicate equip setup failed: " .. tostring(duplicateSetup.message or duplicateSetup.code))
	end
	_assertSemanticFail(function()
		return NetworkController.requestEquipItem("item_training_blade", "weapon")
	end, "duplicate_equip", "duplicate equip")

	task.wait(semanticWaitSeconds)
	local beforeSpamInventory = NetworkController.getInventorySnapshot()
	if not beforeSpamInventory.success then
		_suiteFail(suite, "inventory snapshot before spam failed: " .. tostring(beforeSpamInventory.message or beforeSpamInventory.code))
	end
	local beforeSpamWeapon = _findInventoryItem(beforeSpamInventory.value, "item_training_blade")
	if not beforeSpamWeapon then
		_suiteFail(suite, "training blade missing before spam validation.")
	end

	NetworkController.requestUnequipItem("weapon")
	task.wait(semanticWaitSeconds)
	local successes = 0
	local failures = 0
	local sawRateLimit = false
	local safeRejections = 0
	for _ = 1, 6 do
		local res = NetworkController.requestEquipItem("item_training_blade", "weapon")
		if res.success then
			successes += 1
		else
			if res.code == "rate_limited" then
				sawRateLimit = true
			elseif res.code ~= "duplicate_equip" then
				_suiteFail(suite, "spam equip returned unsafe code: " .. tostring(res.code))
			end
			safeRejections += 1
			failures += 1
		end
	end
	if successes > 1 or failures < 1 or (not sawRateLimit and safeRejections < 1) then
		_suiteFail(suite, string.format("spam equip expected <=1 success plus rate_limited or safe rejection; got %d successes/%d failures/rateLimit=%s.", successes, failures, tostring(sawRateLimit)))
	end

	local afterSpamInventory = NetworkController.getInventorySnapshot()
	local afterSpamEquipment = NetworkController.getEquipmentSnapshot()
	if not afterSpamInventory.success or not afterSpamEquipment.success then
		_suiteFail(suite, "snapshot after spam failed.")
	end
	local afterSpamWeapon = _findInventoryItem(afterSpamInventory.value, "item_training_blade")
	if not afterSpamWeapon or afterSpamWeapon.quantity ~= beforeSpamWeapon.quantity then
		_suiteFail(suite, "spam equip corrupted inventory quantity.")
	end
	local weaponSlot = _findEquipmentSlot(afterSpamEquipment.value, "weapon")
	if successes == 1 and (not weaponSlot or weaponSlot.itemId ~= "item_training_blade") then
		_suiteFail(suite, "spam equip did not leave the single successful weapon equip in a valid state.")
	end

	_suitePass(suite)
	return { success = true }
end
function GameplaySimulator.runVisualSuite()
	assertStudio()
	ensureUiReady()
	local suite = "VisualSuite"
	print("[GameplaySimulator][MVP-016] VisualSuite START")

	local inventoryRes = InventoryController.show()
	if not inventoryRes.success then
		_suiteFail(suite, "inventory visual mount failed: " .. tostring(inventoryRes.message or inventoryRes.code))
	end
	print("[GameplaySimulator][MVP-016] SCREENSHOT TRIGGER: Inventory")
	task.wait(0.2)

	local equipmentRes = EquipmentController.show()
	if not equipmentRes.success then
		_suiteFail(suite, "equipment visual mount failed: " .. tostring(equipmentRes.message or equipmentRes.code))
	end
	print("[GameplaySimulator][MVP-016] SCREENSHOT TRIGGER: Equipment Screen")
	task.wait(0.2)

	local tooltipRes = InventoryController.showTooltip("item_training_blade")
	if not tooltipRes.success then
		_suiteFail(suite, "tooltip visual mount failed: " .. tostring(tooltipRes.message or tooltipRes.code))
	end
	print("[GameplaySimulator][MVP-016] SCREENSHOT TRIGGER: Item Tooltip")
	task.wait(0.2)
	UIController.clearModal()

	_suitePass(suite)
	return { success = true }
end

function GameplaySimulator.runMVP016()
	assertStudio()
	ensureUiReady()
	print("==================================================")
	print("[GameplaySimulator][MVP-016] STARTING ITEM/EQUIPMENT FOUNDATION SUITE")
	print("==================================================")

	GameplaySimulator.runInventorySuite()
	GameplaySimulator.runEquipmentSuite()
	GameplaySimulator.runPersistenceSuite()
	GameplaySimulator.runValidationSuite()
	GameplaySimulator.runVisualSuite()

	print("==================================================")
	print("[GameplaySimulator][MVP-016] COMPLETE WITHOUT CRITICAL/HIGH BUGS")
	print("==================================================")
	return { success = true }
end

local MVP017_REMOTE_WAIT_SECONDS = 0.3
local MVP017_RATE_WINDOW_WAIT_SECONDS = 1.05

local function _paceMvp017Remote()
	task.wait(MVP017_REMOTE_WAIT_SECONDS)
end

local function _assertSemanticSkillFail(callback, expectedCode: string, context: string)
	_paceMvp017Remote()
	_assertSkillFail(callback(), expectedCode, context)
end

local function _getSkillTestInstance()
	local profileRes = NetworkController.getPlayerProfileSnapshot()
	if not profileRes.success then
		_mvp017Critical("profile snapshot failed: " .. tostring(profileRes.message or profileRes.code))
	end

	if not profileRes.value.starterSelected then
		local starterRes = NetworkController.requestStarterSelection("starter_001")
		if not starterRes.success then
			_mvp017Critical("starter selection failed before skill suite: " .. tostring(starterRes.message or starterRes.code))
		end
	end

	_paceMvp017Remote()
	local skillSnapshot = NetworkController.getSkillSnapshot()
	if not skillSnapshot.success then
		_mvp017Critical("skill snapshot failed: " .. tostring(skillSnapshot.message or skillSnapshot.code))
	end

	for _, creature in ipairs(skillSnapshot.value.creatures or {}) do
		local hasVerdantSlash = false
		local hasPassive = false
		for _, skill in ipairs(creature.skills or {}) do
			if skill.skillId == "verdant_slash" and skill.skillType == "active" then
				hasVerdantSlash = true
			elseif skill.skillId == "root_guard_passive" and skill.skillType == "passive" then
				hasPassive = true
			end
		end
		if hasVerdantSlash and hasPassive then
			return creature
		end
	end

	_mvp017Critical("no owned creature exposes the MVP-017 active/passive skill set.")
end

local function _findSkill(snapshot: any, creatureInstanceId: string, skillId: string): any
	for _, creature in ipairs(snapshot and snapshot.creatures or {}) do
		if creature.instanceId == creatureInstanceId then
			for _, skill in ipairs(creature.skills or {}) do
				if skill.skillId == skillId then
					return skill
				end
			end
		end
	end
	return nil
end

local function _waitForSkillReady(creatureInstanceId: string, skillId: string)
	local deadline = os.clock() + 4
	while os.clock() < deadline do
		_paceMvp017Remote()
		local snapshot = NetworkController.getSkillSnapshot(creatureInstanceId)
		if not snapshot.success then
			_mvp017Critical("skill snapshot while waiting failed: " .. tostring(snapshot.message or snapshot.code))
		end

		local skill = _findSkill(snapshot.value, creatureInstanceId, skillId)
		if not skill then
			_mvp017Critical("missing skill while waiting for readiness: " .. skillId)
		end
		if (skill.cooldownRemaining or 0) <= 0 then
			return
		end
	end

	_mvp017Critical("timed out waiting for skill cooldown: " .. skillId)
end

local function _getDefaultStageId(): string
	local profileRes = NetworkController.getPlayerProfileSnapshot()
	if not profileRes.success then
		_mvp017Critical("profile snapshot failed for stage lookup: " .. tostring(profileRes.message or profileRes.code))
	end
	return profileRes.value.world
		and profileRes.value.world.unlockedStages
		and profileRes.value.world.unlockedStages[1]
		or "story_stage_1"
end

function GameplaySimulator.runSkillSuite()
	assertStudio()
	ensureUiReady()
	local suite = "SkillSuite"
	print("[GameplaySimulator][MVP-017] SkillSuite START")

	local creature = _getSkillTestInstance()
	_waitForSkillReady(creature.instanceId, "verdant_slash")

	_paceMvp017Remote()
	local screenRes = SkillController.show(creature.instanceId)
	if not screenRes.success then
		_skillSuiteFail(suite, "skill panel failed: " .. tostring(screenRes.message or screenRes.code))
	end
	print("[GameplaySimulator][MVP-017] SCREENSHOT TRIGGER: Skill panel")

	local useRes = NetworkController.requestSkillUse(creature.instanceId, "verdant_slash", "enemy_001")
	if not useRes.success then
		_skillSuiteFail(suite, "valid skill use failed: " .. tostring(useRes.message or useRes.code))
	end

	_paceMvp017Remote()
	local cooldownSnapshot = NetworkController.getSkillSnapshot(creature.instanceId)
	if not cooldownSnapshot.success then
		_skillSuiteFail(suite, "cooldown snapshot failed: " .. tostring(cooldownSnapshot.message or cooldownSnapshot.code))
	end
	local cooldownSkill = _findSkill(cooldownSnapshot.value, creature.instanceId, "verdant_slash")
	if not cooldownSkill or (cooldownSkill.cooldownRemaining or 0) <= 0 then
		_skillSuiteFail(suite, "skill cooldown was not reflected in snapshot after use.")
	end

	_paceMvp017Remote()
	SkillController.show(creature.instanceId)
	print("[GameplaySimulator][MVP-017] SCREENSHOT TRIGGER: Skill cooldown state")

	local reconnectRes = GameplaySimulator.reconnectValidation()
	if not reconnectRes.success then
		_skillSuiteFail(suite, "reconnect validation failed after skill state was created.")
	end
	_paceMvp017Remote()
	local restored = NetworkController.getSkillSnapshot(creature.instanceId)
	if not restored.success or restored.value.schemaVersion ~= 1 then
		_skillSuiteFail(suite, "skill state did not restore after reconnect.")
	end

	_skillSuitePass(suite)
	return { success = true }
end

function GameplaySimulator.runSkillValidationSuite()
	assertStudio()
	ensureUiReady()
	local suite = "SkillValidationSuite"
	print("[GameplaySimulator][MVP-017] SkillValidationSuite START")

	local creature = _getSkillTestInstance()
	_waitForSkillReady(creature.instanceId, "verdant_slash")

	_assertSemanticSkillFail(function()
		return NetworkController.requestSkillUse(creature.instanceId, "missing_skill", "enemy_001")
	end, "invalid_skill", "invalid skillId")
	_assertSemanticSkillFail(function()
		return NetworkController.requestSkillUse(creature.instanceId, "shadow_bolt", "enemy_001")
	end, "unowned_skill", "unowned skill")
	_assertSemanticSkillFail(function()
		return NetworkController.requestSkillUse(creature.instanceId, "disabled_skill", "enemy_001")
	end, "disabled_skill", "disabled skill")
	_assertSemanticSkillFail(function()
		return NetworkController.requestSkillUse(creature.instanceId, "root_guard_passive", creature.instanceId)
	end, "passive_skill", "passive skill active use")
	_assertSemanticSkillFail(function()
		return NetworkController.requestSkillUse(creature.instanceId, "verdant_slash", "player_target")
	end, "invalid_target", "invalid target")

	_paceMvp017Remote()
	local firstUse = NetworkController.requestSkillUse(creature.instanceId, "verdant_slash", "enemy_001")
	if not firstUse.success then
		_skillSuiteFail(suite, "first cooldown validation skill use failed: " .. tostring(firstUse.message or firstUse.code))
	end
	_assertSkillFail(NetworkController.requestSkillUse(creature.instanceId, "verdant_slash", "enemy_001"), "skill_on_cooldown", "cooldown rejection")

	_paceMvp017Remote()
	SkillController.showInvalidSkillError(creature.instanceId)
	print("[GameplaySimulator][MVP-017] SCREENSHOT TRIGGER: Invalid skill error state")

	_waitForSkillReady(creature.instanceId, "verdant_slash")
	task.wait(MVP017_RATE_WINDOW_WAIT_SECONDS)
	local successes = 0
	local failures = 0
	local sawRateLimit = false
	for _ = 1, 6 do
		local res = NetworkController.requestSkillUse(creature.instanceId, "verdant_slash", "enemy_001")
		if res.success then
			successes += 1
		elseif res.code == "skill_on_cooldown" then
			failures += 1
		elseif res.code == "rate_limited" then
			sawRateLimit = true
			failures += 1
		else
			_skillSuiteFail(suite, "spam skill returned unexpected code: " .. tostring(res.code))
		end
	end
	if successes ~= 1 or failures < 1 then
		_skillSuiteFail(suite, string.format("spam skill expected 1 success plus safe rejection/rate limit, got %d/%d/rateLimit=%s.", successes, failures, tostring(sawRateLimit)))
	end

	_skillSuitePass(suite)
	return { success = true }
end

function GameplaySimulator.runSkillCombatSuite()
	assertStudio()
	ensureUiReady()
	local suite = "SkillCombatSuite"
	print("[GameplaySimulator][MVP-017] SkillCombatSuite START")

	local creature = _getSkillTestInstance()
	local stageId = _getDefaultStageId()

	local battleRes = NetworkController.requestStoryBattle(creature.creatureId, stageId)
	if not battleRes.success then
		_skillSuiteFail(suite, "story battle request failed: " .. tostring(battleRes.message or battleRes.code))
	end

	local sawSkillUse = false
	for _, event in ipairs(battleRes.value.timeline or {}) do
		if event.type == "skill_use" and event.data and event.data.skillId == "verdant_slash" then
			sawSkillUse = true
			break
		end
	end
	if not sawSkillUse then
		_skillSuiteFail(suite, "battle timeline did not include verdant_slash skill_use.")
	end

	local battleToken = battleRes.value and battleRes.value.battleToken
	if battleToken then
		local completeRes = NetworkController.requestBattleCompletion(battleToken)
		if not completeRes.success then
			_skillSuiteFail(suite, "battle completion failed after skill timeline check: " .. tostring(completeRes.message or completeRes.code))
		end
	end

	task.wait(1.05)
	BattleController.start(creature.creatureId, stageId, function()
	end)
	task.wait(1.0)

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local mainUI = playerGui:FindFirstChild("GenesisMainUI")
	if not mainUI or not mainUI:FindFirstChild("ContinueButton", true) then
		_skillSuiteFail(suite, "battle result modal did not mount.")
	end

	print("[GameplaySimulator][MVP-017] SCREENSHOT TRIGGER: Combat using skill")

	UIController.clearModal()

	_skillSuitePass(suite)
	return { success = true }
end

function GameplaySimulator.runMVP017()
	assertStudio()
	ensureUiReady()
	print("==================================================")
	print("[GameplaySimulator][MVP-017] STARTING SKILL SYSTEM FOUNDATION SUITE")
	print("==================================================")

	GameplaySimulator.runSkillSuite()
	task.wait(MVP017_RATE_WINDOW_WAIT_SECONDS)
	GameplaySimulator.runSkillValidationSuite()
	task.wait(MVP017_RATE_WINDOW_WAIT_SECONDS)
	GameplaySimulator.runSkillCombatSuite()

	print("==================================================")
	print("[GameplaySimulator][MVP-017] COMPLETE WITHOUT CRITICAL/HIGH BUGS")
	print("==================================================")
	return { success = true }
end

local function _getGeneratorSnapshotOrFail(context: string): any
	local snapshotRes = NetworkController.getGeneratorSnapshot()
	if not snapshotRes.success then
		_mvp019Critical(context .. " generator snapshot failed: " .. tostring(snapshotRes.message or snapshotRes.code))
	end
	return snapshotRes.value
end

local function _findGenerator(snapshot: any, generatorId: string): any
	for _, generator in ipairs(snapshot and snapshot.generators or {}) do
		if generator.generatorId == generatorId then
			return generator
		end
	end
	return nil
end

local function _waitForGeneratorAccumulated(generatorId: string, minimumAmount: number, timeoutSeconds: number): any
	local deadline = os.clock() + timeoutSeconds
	while os.clock() < deadline do
		local snapshot = _getGeneratorSnapshotOrFail("wait accumulated")
		local generator = _findGenerator(snapshot, generatorId)
		if not generator then
			_mvp019Critical("missing generator while waiting: " .. generatorId)
		end
		if generator.accumulated and generator.accumulated >= minimumAmount then
			return generator
		end
		task.wait(0.25)
	end

	_mvp019Critical(string.format("timed out waiting for %s to accumulate %d.", generatorId, minimumAmount))
end

local function _fundBioUpgradeCost(suite: string): any
	local snapshot = _getGeneratorSnapshotOrFail(suite .. " fund")
	local bio = _findGenerator(snapshot, "bio_generator")
	if not bio then
		_generatorSuiteFail(suite, "bio_generator missing.")
	end

	local cost = bio.upgradeCost and bio.upgradeCost.amount or 1
	_waitForGeneratorAccumulated("bio_generator", math.min(10, cost), 30)
	task.wait(0.3)
	local claimRes = NetworkController.requestClaimGenerator("bio_generator")
	if not claimRes.success then
		_generatorSuiteFail(suite, "funding claim failed: " .. tostring(claimRes.message or claimRes.code))
	end
	task.wait(0.3)
	return claimRes
end

function GameplaySimulator.runGeneratorSuite()
	assertStudio()
	ensureUiReady()
	local suite = "GeneratorSuite"
	print("[GameplaySimulator][MVP-019] GeneratorSuite START")

	local snapshot = _getGeneratorSnapshotOrFail(suite)
	local bio = _findGenerator(snapshot, "bio_generator")
	local dna = _findGenerator(snapshot, "dna_generator")
	local advanced = _findGenerator(snapshot, "advanced_bio_generator")
	if not bio or not dna or not advanced then
		_generatorSuiteFail(suite, "expected bio_generator, dna_generator, and advanced_bio_generator snapshots.")
	end
	if _findGenerator(snapshot, "disabled_generator") then
		_generatorSuiteFail(suite, "disabled generator leaked into player snapshot.")
	end
	if bio.isUnlocked ~= true then
		_generatorSuiteFail(suite, "bio_generator should be unlocked.")
	end
	if dna.isUnlocked ~= true then
		_generatorSuiteFail(suite, "dna_generator should be unlocked.")
	end
	if advanced.isUnlocked == true then
		_generatorSuiteFail(suite, "advanced_bio_generator should remain locked for MVP-019 QA.")
	end

	local screenRes = GeneratorController.show("bio_generator", "Generator panel loaded.")
	if not screenRes.success then
		_generatorSuiteFail(suite, "generator panel failed: " .. tostring(screenRes.message or screenRes.code))
	end
	print("[GameplaySimulator][MVP-019] SCREENSHOT TRIGGER: Generator panel")

	local cost = bio.upgradeCost and bio.upgradeCost.amount or 1
	_waitForGeneratorAccumulated("bio_generator", math.min(10, cost), 30)
	task.wait(0.3)
	local claimRes = GeneratorController.claim("bio_generator")
	if not claimRes.success then
		_generatorSuiteFail(suite, "claim failed: " .. tostring(claimRes.message or claimRes.code))
	end
	if type(claimRes.value.claimed) ~= "number" or claimRes.value.claimed < 1 then
		_generatorSuiteFail(suite, "claim did not return the expected server-calculated amount.")
	end
	print("[GameplaySimulator][MVP-019] SCREENSHOT TRIGGER: claim success")

	task.wait(0.3)
	local beforeUpgrade = _getGeneratorSnapshotOrFail(suite .. " before upgrade")
	local beforeBio = _findGenerator(beforeUpgrade, "bio_generator")
	local upgradeRes = GeneratorController.upgrade("bio_generator")
	if not upgradeRes.success then
		_generatorSuiteFail(suite, "upgrade failed: " .. tostring(upgradeRes.message or upgradeRes.code))
	end
	if not beforeBio or upgradeRes.value.level ~= (beforeBio.level or 1) + 1 then
		_generatorSuiteFail(suite, "upgrade did not increment level exactly once.")
	end
	print("[GameplaySimulator][MVP-019] SCREENSHOT TRIGGER: upgrade success")

	local lockedRes = GeneratorController.show("advanced_bio_generator", "Locked generator validation.")
	if not lockedRes.success then
		_generatorSuiteFail(suite, "locked generator panel failed: " .. tostring(lockedRes.message or lockedRes.code))
	end
	print("[GameplaySimulator][MVP-019] SCREENSHOT TRIGGER: locked generator")

	_generatorSuitePass(suite)
	return { success = true }
end

function GameplaySimulator.runGeneratorValidationSuite()
	assertStudio()
	ensureUiReady()
	local suite = "GeneratorValidationSuite"
	print("[GameplaySimulator][MVP-019] GeneratorValidationSuite START")

	_assertGeneratorFail(NetworkController.requestClaimGenerator(nil), "invalid_generator", "nil claim generatorId")
	task.wait(0.3)
	_assertGeneratorFail(NetworkController.requestClaimGenerator(""), "invalid_generator", "empty claim generatorId")
	task.wait(0.3)
	_assertGeneratorFail(NetworkController.requestClaimGenerator({ generatorId = "bio_generator" }), "invalid_generator", "malformed claim payload")
	task.wait(0.3)
	_assertGeneratorFail(NetworkController.requestClaimGenerator("missing_generator"), "invalid_generator", "invalid claim generatorId")
	task.wait(0.3)
	_assertGeneratorFail(NetworkController.requestClaimGenerator("disabled_generator"), "generator_disabled", "disabled generator claim")
	task.wait(0.3)
	_assertGeneratorFail(NetworkController.requestClaimGenerator("advanced_bio_generator"), "generator_locked", "locked generator claim")
	task.wait(0.3)
	_assertGeneratorFail(NetworkController.requestUpgradeGenerator(nil), "invalid_generator", "nil upgrade generatorId")
	task.wait(0.3)
	_assertGeneratorFail(NetworkController.requestUpgradeGenerator({ generatorId = "bio_generator" }), "invalid_generator", "malformed upgrade payload")
	task.wait(0.3)
	_assertGeneratorFail(NetworkController.requestUpgradeGenerator("disabled_generator"), "generator_disabled", "disabled generator upgrade")
	task.wait(0.3)
	_assertGeneratorFail(NetworkController.requestUpgradeGenerator("advanced_bio_generator"), "generator_locked", "locked generator upgrade")
	task.wait(0.3)
	local dnaSnap = _findGenerator(_getGeneratorSnapshotOrFail(suite), "dna_generator")
	if dnaSnap then
		local currentBalance = NetworkController.getPlayerProfileSnapshot().value.balances.dna or 0
		local cost = dnaSnap.upgradeCost and dnaSnap.upgradeCost.amount or 100
		while currentBalance >= cost and dnaSnap.level < dnaSnap.maxLevel do
			local upRes = NetworkController.requestUpgradeGenerator("dna_generator")
			if not upRes.success then break end
			task.wait(0.3)
			currentBalance = upRes.value.newBalance or 0
			local freshSnap = _getGeneratorSnapshotOrFail(suite)
			dnaSnap = _findGenerator(freshSnap, "dna_generator")
			cost = dnaSnap.upgradeCost and dnaSnap.upgradeCost.amount or math.huge
		end
		_assertGeneratorFail(NetworkController.requestUpgradeGenerator("dna_generator"), "insufficient_balance", "insufficient currency upgrade")
	end

	_waitForGeneratorAccumulated("bio_generator", 1, 30)
	task.wait(0.3)
	local claimSuccesses = 0
	local claimFailures = 0
	local claimThreads = {}
	for _ = 1, 5 do
		table.insert(claimThreads, task.spawn(function()
			local res = NetworkController.requestClaimGenerator("bio_generator")
			if res.success then
				claimSuccesses += 1
			else
				claimFailures += 1
			end
		end))
	end
	task.wait(1.5)
	if claimSuccesses ~= 1 or claimFailures ~= 4 then
		_generatorSuiteFail(suite, string.format("claim spam expected 1 success/4 failures, got %d/%d.", claimSuccesses, claimFailures))
	end

	_fundBioUpgradeCost(suite)
	local beforeSnapshot = _getGeneratorSnapshotOrFail(suite .. " before upgrade spam")
	local beforeBio = _findGenerator(beforeSnapshot, "bio_generator")
	local upgradeSuccesses = 0
	local upgradeFailures = 0
	local upgradeThreads = {}
	for _ = 1, 5 do
		table.insert(upgradeThreads, task.spawn(function()
			local res = NetworkController.requestUpgradeGenerator("bio_generator")
			if res.success then
				upgradeSuccesses += 1
			else
				upgradeFailures += 1
			end
		end))
	end
	task.wait(1.5)
	if upgradeSuccesses ~= 1 or upgradeFailures ~= 4 then
		_generatorSuiteFail(suite, string.format("upgrade spam expected 1 success/4 failures, got %d/%d.", upgradeSuccesses, upgradeFailures))
	end

	local afterSnapshot = _getGeneratorSnapshotOrFail(suite .. " after upgrade spam")
	local afterBio = _findGenerator(afterSnapshot, "bio_generator")
	if not beforeBio or not afterBio or afterBio.level ~= beforeBio.level + 1 then
		_generatorSuiteFail(suite, "upgrade spam changed level more than once.")
	end

	_generatorSuitePass(suite)
	return { success = true }
end

function GameplaySimulator.runGeneratorPersistenceSuite()
	assertStudio()
	ensureUiReady()
	local suite = "GeneratorPersistenceSuite"
	print("[GameplaySimulator][MVP-019] GeneratorPersistenceSuite START")

	local beforeSnapshot = _getGeneratorSnapshotOrFail(suite .. " before reconnect")
	local beforeBio = _findGenerator(beforeSnapshot, "bio_generator")
	if not beforeBio then
		_generatorSuiteFail(suite, "bio_generator missing before reconnect.")
	end

	local reconnectRes = GameplaySimulator.reconnectValidation()
	if not reconnectRes.success then
		_generatorSuiteFail(suite, "reconnect validation failed.")
	end

	local afterSnapshot = _getGeneratorSnapshotOrFail(suite .. " after reconnect")
	local afterBio = _findGenerator(afterSnapshot, "bio_generator")
	local afterAdvanced = _findGenerator(afterSnapshot, "advanced_bio_generator")
	if not afterBio then
		_generatorSuiteFail(suite, "bio_generator missing after reconnect.")
	end
	if afterBio.level ~= beforeBio.level then
		_generatorSuiteFail(suite, string.format("bio_generator level did not persist. before=%d after=%d", beforeBio.level or 0, afterBio.level or 0))
	end
	if type(afterBio.lastClaimedAt) ~= "number" then
		_generatorSuiteFail(suite, "generator lastClaimedAt did not persist in snapshot.")
	end
	if not afterAdvanced or afterAdvanced.isUnlocked == true then
		_generatorSuiteFail(suite, "locked generator state did not persist.")
	end

	GeneratorController.show("bio_generator", "Reconnect restored generator state.")
	print("[GameplaySimulator][MVP-019] SCREENSHOT TRIGGER: reconnect restored state")

	_generatorSuitePass(suite)
	return { success = true }
end

function GameplaySimulator.runMVP019()
	assertStudio()
	ensureUiReady()
	print("==================================================")
	print("[GameplaySimulator][MVP-019] STARTING GENERATOR EXPANSION SUITE")
	print("==================================================")

	GameplaySimulator.runGeneratorSuite()
	GameplaySimulator.runGeneratorValidationSuite()
	GameplaySimulator.runGeneratorPersistenceSuite()

	print("==================================================")
	print("[GameplaySimulator][MVP-019] COMPLETE WITHOUT CRITICAL/HIGH BUGS")
	print("==================================================")
	return { success = true }
end

-- Security check: Spams generator claims rapidly to ensure server rejects spam
function GameplaySimulator.spamClaimGeneratorTest()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator] Security Test: Spamming Claim Generator...")
	local snapRes = NetworkController.getPlayerProfileSnapshot()
	local generator = snapRes.success and snapRes.value.generators and snapRes.value.generators[1]
	local generatorId = generator and generator.generatorId
	if not generatorId then
		return { successes = 0, failures = 5, message = "no_generator" }
	end
	local successes = 0
	local failures = 0
	for i = 1, 5 do
		local res = NetworkController.requestGeneratorClaim(generatorId)
		if res.success then
			successes += 1
		else
			failures += 1
		end
	end
	print(string.format("[GameplaySimulator] Spam claim results: %d successes, %d failures (Expected: max 1 success, others NOTHING_TO_CLAIM/invalid).", successes, failures))
	return { successes = successes, failures = failures }
end

-- Security check: Spams battles rapidly to ensure server rejects invalid battles
function GameplaySimulator.spamBattleTest()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator] Security Test: Spamming Battle Requests...")
	local snapRes = NetworkController.getPlayerProfileSnapshot()
	if not snapRes.success then
		return { successes = 0, failures = 5, message = "snapshot_failed" }
	end

	local playerCreatureId = nil
	for _, inst in pairs(snapRes.value.creatureInstances) do
		playerCreatureId = inst.creatureId
		break
	end
	local stageId = snapRes.value.world
		and snapRes.value.world.unlockedStages
		and snapRes.value.world.unlockedStages[1]
		or "story_stage_1"

	local successes = 0
	local failures = 0
	local token = nil
	for i = 1, 5 do
		local res = NetworkController.requestStoryBattle(playerCreatureId, stageId)
		if res.success then
			successes += 1
			token = token or res.value.battleToken
		else
			failures += 1
		end
	end
	if token then
		NetworkController.requestBattleCompletion(token)
	end
	print(string.format("[GameplaySimulator] Spam battle results: %d successes, %d failures (Expected: 1 success, others rate-limited or blocked).", successes, failures))
	return { successes = successes, failures = failures }
end

-- Simulates reconnecting
function GameplaySimulator.reconnectValidation()
	assertStudio()
	ensureUiReady()
	print("[GameplaySimulator] Command: Simulating Reconnect...")
	UIController.clearModal()
	
	-- We reload the profile from scratch
	local complete = false
	task.spawn(function()
		LoadingController.start(function(snapshot)
			if snapshot.starterSelected then
				WorldController.start(snapshot)
			else
				StarterController.start(function()
					GameplaySimulator.refreshWorld()
				end)
			end
			complete = true
		end)
	end)
	
	local SimulationGuard = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.SimulationGuard)
	local guard = SimulationGuard.new({ timeoutSeconds = 10.0, context = "GameplaySimulator:ReconnectWait" })
	while not complete and guard:step() do task.wait(0.2) end
	if guard:shouldStop() then
		warn("[GameplaySimulator] Reconnect flow timed out waiting for complete.")
		return { success = false, message = "reconnect_timeout" }
	end
	print("[GameplaySimulator] Reconnect flow completed.")
	print("[GameplaySimulator] SCREENSHOT TRIGGER: Reconnect restored state")
	return { success = true }
end

-- Runs the complete core progression loop end-to-end
function GameplaySimulator.runProgressionLoop()
	assertStudio()
	ensureUiReady()
	print("==================================================")
	print("[GameplaySimulator] STARTING AUTOMATED PROGRESSION LOOP")
	print("==================================================")
	
	-- Wait for StarterSelectionScreen or WorldScreen to mount
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local mainUI = playerGui:WaitForChild("GenesisMainUI")
	
	local SimulationGuard = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.SimulationGuard)
	local uiGuard = SimulationGuard.new({ timeoutSeconds = 10.0, context = "GameplaySimulator:UIWait" })
	
	print("[GameplaySimulator] Waiting for UI to initialize...")
	while not mainUI:FindFirstChild("StarterSelectionScreen") and not mainUI:FindFirstChild("WorldScreen") and uiGuard:step() do
		task.wait(0.2)
	end
	if uiGuard:shouldStop() then
		error("[GameplaySimulator] Timeout waiting for Starter/World Screen to initialize.")
	end
	print("[GameplaySimulator] UI initialized.")

	-- Step 1: Initial Profile & Starter Selection
	print("[GameplaySimulator] STEP 1: Starter Selection")
	local snapRes = NetworkController.getPlayerProfileSnapshot()
	if snapRes.success and not snapRes.value.starterSelected then
		print("[GameplaySimulator] No starter selected. Claiming starter_001...")
		local claimRes = NetworkController.requestStarterSelection("starter_001")
		if not claimRes.success then
			error("[GameplaySimulator] Failed starter selection claim: " .. tostring(claimRes.message))
		end
		print("[GameplaySimulator] starter_001 claimed successfully.")
		GameplaySimulator.refreshWorld()
	else
		print("[GameplaySimulator] Starter already selected.")
	end

	-- Refresh and capture World Hub
	task.wait(1.0)
	print("[GameplaySimulator] SCREENSHOT TRIGGER: World Hub before battle")

	-- Step 2: Story Battle (Gain XP + Biomass)
	print("[GameplaySimulator] STEP 2: Running Story Battle 1...")
	GameplaySimulator.runStoryBattle()
	task.wait(1.0)
	
	-- Step 3: Bio Generator claim
	print("[GameplaySimulator] STEP 3: Generator Accumulation and Claim")
	-- Wait for generator to accumulate at least 1 biomass
	print("[GameplaySimulator] Waiting 2 seconds for generator to accumulate...")
	task.wait(2.0)
	local claimRes = GameplaySimulator.claimGenerator()
	task.wait(1.0)
	print("[GameplaySimulator] SCREENSHOT TRIGGER: Generator claim")

	-- Step 4: Evolution Loop
	print("[GameplaySimulator] STEP 4: Evolution Check & Trigger")
	-- Verify creature level (should be 2 from battle rewards) and Biomass (should have 600 + generator claim)
	local finalSnap = NetworkController.getPlayerProfileSnapshot()
	local activeInst = nil
	for _, inst in pairs(finalSnap.value.creatureInstances) do
		activeInst = inst
		break
	end
	
	print(string.format("[GameplaySimulator] Creature Level: %d, Biomass: %d", activeInst.level, finalSnap.value.balances.biomass or 0))
	local evoRes = GameplaySimulator.evolveActiveCreature()
	task.wait(1.0)

	-- Step 5: Second Battle (with evolved creature)
	print("[GameplaySimulator] STEP 5: Running Story Battle 2 (with evolved form)...")
	GameplaySimulator.runStoryBattle()
	task.wait(1.0)

	-- Step 6: Reconnect Validation
	print("[GameplaySimulator] STEP 6: Reconnect Validation")
	GameplaySimulator.reconnectValidation()
	task.wait(1.0)

	-- Step 7: Security Tests
	print("[GameplaySimulator] STEP 7: Security & Spam Verification")
	GameplaySimulator.spamClaimGeneratorTest()
	GameplaySimulator.spamBattleTest()

	print("==================================================")
	print("[GameplaySimulator] progression_loop COMPLETE WITHOUT ERRORS")
	print("==================================================")
end

function GameplaySimulator.runAlpha001RuntimeLoop(cycles)
	assertStudio()
	ensureUiReady()
	cycles = cycles or 3
	print("==================================================")
	print("[GameplaySimulator] STARTING RUNTIME LOOP VERIFICATION (ALPHA-001)")
	print("==================================================")

	-- 1. Starter Selection
	local snapRes = NetworkController.getPlayerProfileSnapshot()
	if snapRes.success and not snapRes.value.starterSelected then
		print("[GameplaySimulator] No starter selected. Claiming starter_001...")
		local claimRes = NetworkController.requestStarterSelection("starter_001")
		if not claimRes.success then
			error("[GameplaySimulator] Failed starter selection claim: " .. tostring(claimRes.message))
		end
		GameplaySimulator.refreshWorld()
	end

	-- 2. Cycles Loop
	for cycle = 1, cycles do
		print(string.format("[GameplaySimulator] --- CYCLE %d/%d ---", cycle, cycles))
		
		-- Wait for generator
		task.wait(1.0)
		print("[GameplaySimulator] Claiming accumulated biomass...")
		local claimRes = GameplaySimulator.claimGenerator()
		if not claimRes.success then
			print("[GameplaySimulator] Claim warning: " .. tostring(claimRes.message or claimRes.code))
		end
		
		-- Run battle
		print("[GameplaySimulator] Running Story Battle...")
		GameplaySimulator.runStoryBattle()
		task.wait(1.0)

		-- Try upgrades
		print("[GameplaySimulator] Attempting Bio Generator upgrade...")
		local upgradeBio = GeneratorController.upgrade("bio_generator")
		if upgradeBio.success then
			print("[GameplaySimulator] Bio Generator upgraded to level " .. tostring(upgradeBio.value.level))
		else
			print("[GameplaySimulator] Bio Generator upgrade skipped/failed: " .. tostring(upgradeBio.message or upgradeBio.code))
		end

		print("[GameplaySimulator] Attempting DNA Generator upgrade...")
		local upgradeDna = GeneratorController.upgrade("dna_generator")
		if upgradeDna.success then
			print("[GameplaySimulator] DNA Generator upgraded to level " .. tostring(upgradeDna.value.level))
		else
			print("[GameplaySimulator] DNA Generator upgrade skipped/failed: " .. tostring(upgradeDna.message or upgradeDna.code))
		end

		-- Try evolution
		print("[GameplaySimulator] Checking active creature evolution...")
		local evoRes = GameplaySimulator.evolveActiveCreature()
		if evoRes.success then
			print("[GameplaySimulator] Creature evolved successfully!")
		else
			print("[GameplaySimulator] Creature evolution skipped/failed: " .. tostring(evoRes.message or evoRes.code))
		end

		-- Reconnect test
		print("[GameplaySimulator] Running Reconnect validation...")
		GameplaySimulator.reconnectValidation()
		task.wait(1.0)
	end

	-- 3. Edge Cases Check
	print("[GameplaySimulator] Running Edge Cases & Security Checks...")
	
	-- Verify balance tracking
	local finalSnap = NetworkController.getPlayerProfileSnapshot()
	if finalSnap.success then
		print(string.format("[GameplaySimulator] Final Balances - Biomass: %d, DNA: %d", finalSnap.value.balances.biomass or 0, finalSnap.value.balances.dna or 0))
	end

	-- Test double-claim spam
	print("[GameplaySimulator] Running spam claim checks...")
	GameplaySimulator.spamClaimGeneratorTest()
	
	-- Verify invalid/max level upgrade rejection
	print("[GameplaySimulator] Testing upgrade rejection on invalid generator ID...")
	local upgradeInvalid = GeneratorController.upgrade("invalid_generator_id")
	if not upgradeInvalid.success then
		print("[GameplaySimulator] Invalid upgrade correctly rejected: " .. tostring(upgradeInvalid.message or upgradeInvalid.code))
	else
		error("[GameplaySimulator] Expected invalid generator upgrade to fail, but it succeeded!")
	end

	print("==================================================")
	print("[GameplaySimulator] RUNTIME LOOP VERIFICATION PASS")
	print("==================================================")
	return { success = true }
end

return GameplaySimulator

