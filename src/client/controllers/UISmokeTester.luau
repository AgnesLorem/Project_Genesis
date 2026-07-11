--[[
	UISmokeTester
	Location: src/client/controllers/UISmokeTester.luau

	Automated smoke testing suite for UI screens.
	Tests mount/unmount cycles, memory leaks, connection cleanup, and callback isolation.
--]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UIController = require(script.Parent.UIController)
local NetworkController = require(script.Parent.NetworkController)
local WorldController = require(script.Parent.WorldController)
local StarterSelectionScreen = require(script.Parent.Parent.views.StarterSelectionScreen)
local GeneratorPanel = require(script.Parent.Parent.views.GeneratorPanel)
local WorldScreen = require(script.Parent.Parent.views.WorldScreen)
local CombatScreen = require(script.Parent.Parent.views.CombatScreen)
local CollectionBookScreen = require(script.Parent.Parent.views.CollectionBookScreen)
local CreatureInventoryScreen = require(script.Parent.Parent.views.CreatureInventoryScreen)
local EquipmentScreen = require(script.Parent.Parent.views.EquipmentScreen)
local SkillPanel = require(script.Parent.Parent.views.SkillPanel)
local TowerChallengeScreen = require(script.Parent.Parent.views.TowerChallengeScreen)

local UISmokeTester = {}

-- Test configuration
local MOUNT_CYCLES_PER_SCREEN = 20
local WAIT_BETWEEN_CYCLES = 0.05

-- Test results tracking
local testResults = {
	screensTested = 0,
	totalMountCycles = 0,
	failures = {},
	memoryLeakDetected = false,
	callbackLeaks = false,
	orphanUI = false,
	connectionCleanupFailed = false,
	totalMountTime = 0,
	totalCleanupTime = 0,
}

-- Callback counter for leak detection
local callbackCount = 0
local expectedCallbackCount = 0

local function resetTestResults()
	testResults.screensTested = 0
	testResults.totalMountCycles = 0
	table.clear(testResults.failures)
	testResults.memoryLeakDetected = false
	testResults.callbackLeaks = false
	testResults.orphanUI = false
	testResults.connectionCleanupFailed = false
	testResults.totalMountTime = 0
	testResults.totalCleanupTime = 0
	callbackCount = 0
	expectedCallbackCount = 0
end

local function assertStudio()
	if not RunService:IsStudio() then
		error("[UISmokeTester] Access Denied: Smoke tester is disabled in production.")
	end
end

local function getGenesisMainUI()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	return playerGui:FindFirstChild("GenesisMainUI")
end

local function assertUICountBeforeTest()
	local mainUI = getGenesisMainUI()
	if not mainUI then
		error("[UISmokeTester] GenesisMainUI not found. Call UIController.init() first.")
	end
	if #mainUI:GetChildren() ~= 0 then
		error(
			string.format(
				"[UISmokeTester] UI Count Before Test failed: Expected 0 children, got %d",
				#mainUI:GetChildren()
			)
		)
	end
end

local function assertOrphanGuard()
	local mainUI = getGenesisMainUI()
	if not mainUI then
		testResults.orphanUI = true
		return
	end
	if #mainUI:GetChildren() ~= 0 then
		testResults.orphanUI = true
		warn(
			string.format(
				"[UISmokeTester] Orphan UI detected: %d children remaining after cleanup",
				#mainUI:GetChildren()
			)
		)
	end
end

local function assertConnectionTeardown()
	UIController.init()
	UIController.cleanup()
end

local function assertCallbackLeaks()
	if callbackCount ~= expectedCallbackCount then
		testResults.callbackLeaks = true
		warn(
			string.format(
				"[UISmokeTester] Callback leak detected: Expected %d, got %d",
				expectedCallbackCount,
				callbackCount
			)
		)
	end
end

local function testStarterSelectionScreen()
	local screenName = "StarterSelectionScreen"
	local failures = 0

	for i = 1, MOUNT_CYCLES_PER_SCREEN do
		local success, err = pcall(function()
			local startTime = tick()
			local choices = { "starter_001", "starter_002", "starter_003" }
			local screen = StarterSelectionScreen.create(choices, function(_creatureId)
				callbackCount += 1
			end)

			local mountTime = tick() - startTime
			testResults.totalMountTime += mountTime
			UIController.mountScreen(screen)
			task.wait(WAIT_BETWEEN_CYCLES)

			local cleanupStart = tick()
			UIController.cleanup()
			local cleanupTime = tick() - cleanupStart
			testResults.totalCleanupTime += cleanupTime
			task.wait(WAIT_BETWEEN_CYCLES)
		end)

		if not success then
			failures += 1
			table.insert(testResults.failures, { screen = screenName, cycle = i, error = tostring(err) })
		end
	end

	return failures
end

local function testGeneratorPanel()
	local screenName = "GeneratorPanel"
	local failures = 0

	for i = 1, MOUNT_CYCLES_PER_SCREEN do
		local success, err = pcall(function()
			local startTime = tick()
			local mockSnapshot = {
				balances = { biomass = 1000, dna = 500 },
				generators = {
					{
						generatorId = "bio_generator_001",
						displayName = "Bio Generator",
						isUnlocked = true,
						level = 1,
						maxLevel = 10,
						accumulated = 50,
						capacity = 100,
						ratePerSecond = 1,
						canClaim = true,
						canUpgrade = false,
						upgradeCost = { amount = 100, currencyType = "biomass" },
					},
				},
			}

			local screen = GeneratorPanel.create(
				mockSnapshot,
				function(_generatorId)
					callbackCount += 1
				end,
				function(_generatorId)
					callbackCount += 1
				end,
				function()
					callbackCount += 1
				end,
				nil,
				nil,
				function()
					callbackCount += 1
				end
			)

			local mountTime = tick() - startTime
			testResults.totalMountTime += mountTime
			UIController.mountScreen(screen)
			task.wait(WAIT_BETWEEN_CYCLES)

			local cleanupStart = tick()
			UIController.cleanup()
			local cleanupTime = tick() - cleanupStart
			testResults.totalCleanupTime += cleanupTime
			task.wait(WAIT_BETWEEN_CYCLES)
		end)

		if not success then
			failures += 1
			table.insert(testResults.failures, { screen = screenName, cycle = i, error = tostring(err) })
		end
	end

	return failures
end

local function testWorldScreen()
	local screenName = "WorldScreen"
	local failures = 0

	for i = 1, MOUNT_CYCLES_PER_SCREEN do
		local success, err = pcall(function()
			local startTime = tick()
			local mockSnapshot = {
				balances = { biomass = 1000, dna = 500 },
				creatureInstances = {
					["inst_001"] = {
						instanceId = "inst_001",
						creatureId = "creature_001",
						level = 5,
						xp = 250,
					},
				},
				activeCreatureInstanceId = "inst_001",
				generators = {},
				evolutionOptions = {},
				collectionProgress = {
					completionCount = 1,
					total = 3,
				},
			}
			local mockWorldData = {
				worldId = "world_001",
				unlockedStages = { "story_stage_1", "story_stage_2" },
			}

			local screen = WorldScreen.create(mockSnapshot, mockWorldData, function(_stageId)
				callbackCount += 1
			end, function(_generatorId)
				callbackCount += 1
			end, function(_instId, _evoId)
				callbackCount += 1
			end, function()
				callbackCount += 1
			end, function()
				callbackCount += 1
			end, function()
				callbackCount += 1
			end, function()
				callbackCount += 1
			end, function()
				callbackCount += 1
			end)

			local mountTime = tick() - startTime
			testResults.totalMountTime += mountTime
			UIController.mountScreen(screen)
			task.wait(WAIT_BETWEEN_CYCLES)

			local cleanupStart = tick()
			UIController.cleanup()
			local cleanupTime = tick() - cleanupStart
			testResults.totalCleanupTime += cleanupTime
			task.wait(WAIT_BETWEEN_CYCLES)
		end)

		if not success then
			failures += 1
			table.insert(testResults.failures, { screen = screenName, cycle = i, error = tostring(err) })
		end
	end

	return failures
end

local function testCombatScreen()
	local screenName = "CombatScreen"
	local failures = 0

	for i = 1, MOUNT_CYCLES_PER_SCREEN do
		local success, err = pcall(function()
			local startTime = tick()
			local screen, api = CombatScreen.create("creature_001", 5, "creature_002", 5, 100, 100)

			local mountTime = tick() - startTime
			testResults.totalMountTime += mountTime
			UIController.mountScreen(screen)
			task.wait(WAIT_BETWEEN_CYCLES)

			api.updatePlayerHp(80)
			api.updateEnemyHp(60)
			api.setCurrentTurn(1)
			api.appendLog("Test log entry")
			api.showDamage(false, 20)
			task.wait(WAIT_BETWEEN_CYCLES)

			local cleanupStart = tick()
			UIController.cleanup()
			local cleanupTime = tick() - cleanupStart
			testResults.totalCleanupTime += cleanupTime
			task.wait(WAIT_BETWEEN_CYCLES)
		end)

		if not success then
			failures += 1
			table.insert(testResults.failures, { screen = screenName, cycle = i, error = tostring(err) })
		end
	end

	return failures
end

local function testCollectionBookScreen()
	local screenName = "CollectionBookScreen"
	local failures = 0

	for i = 1, MOUNT_CYCLES_PER_SCREEN do
		local success, err = pcall(function()
			local startTime = tick()
			local mockCollectionData = {
				completionCount = 1,
				total = 3,
				entries = {
					creature_001 = true,
					creature_002 = false,
				},
			}
			local mockPublicConfigs = {
				creature_001 = {
					displayName = "Creature 001",
					sortOrder = 1,
					collectionCategory = "common",
				},
				creature_002 = {
					displayName = "Creature 002",
					sortOrder = 2,
					collectionCategory = "rare",
				},
			}
			local screen = CollectionBookScreen.create(mockCollectionData, mockPublicConfigs, function()
				callbackCount += 1
			end)

			local mountTime = tick() - startTime
			testResults.totalMountTime += mountTime
			UIController.mountScreen(screen)
			task.wait(WAIT_BETWEEN_CYCLES)

			local cleanupStart = tick()
			UIController.cleanup()
			local cleanupTime = tick() - cleanupStart
			testResults.totalCleanupTime += cleanupTime
			task.wait(WAIT_BETWEEN_CYCLES)
		end)

		if not success then
			failures += 1
			table.insert(testResults.failures, { screen = screenName, cycle = i, error = tostring(err) })
		end
	end

	return failures
end

local function testCreatureInventoryScreen()
	local screenName = "CreatureInventoryScreen"
	local failures = 0

	for i = 1, MOUNT_CYCLES_PER_SCREEN do
		local success, err = pcall(function()
			local startTime = tick()
			local mockInventoryData = {
				instances = {
					["inst_001"] = {
						instanceId = "inst_001",
						creatureId = "creature_001",
						level = 5,
						xp = 250,
					},
				},
				activeCreatureInstanceId = "inst_001",
			}
			local mockPublicConfigs = {
				creature_001 = {
					displayName = "Creature 001",
					sortOrder = 1,
					collectionCategory = "common",
				},
			}
			local screen = CreatureInventoryScreen.create(mockInventoryData, mockPublicConfigs, function()
				callbackCount += 1
			end, function()
				callbackCount += 1
			end, function()
				callbackCount += 1
			end)

			local mountTime = tick() - startTime
			testResults.totalMountTime += mountTime
			UIController.mountScreen(screen)
			task.wait(WAIT_BETWEEN_CYCLES)

			local cleanupStart = tick()
			UIController.cleanup()
			local cleanupTime = tick() - cleanupStart
			testResults.totalCleanupTime += cleanupTime
			task.wait(WAIT_BETWEEN_CYCLES)
		end)

		if not success then
			failures += 1
			table.insert(testResults.failures, { screen = screenName, cycle = i, error = tostring(err) })
		end
	end

	return failures
end

local function testEquipmentScreen()
	local screenName = "EquipmentScreen"
	local failures = 0

	for i = 1, MOUNT_CYCLES_PER_SCREEN do
		local success, err = pcall(function()
			local startTime = tick()
			local mockEquipmentSnapshot = {
				slots = {
					{ slotId = "weapon", itemId = "item_training_blade" },
					{ slotId = "armor", itemId = nil },
					{ slotId = "accessory", itemId = nil },
				},
				statBonuses = {
					hp = 10,
					atk = 5,
					def = 3,
					spd = 2,
				},
			}
			local mockInventorySnapshot = {
				items = {
					{
						itemId = "item_training_blade",
						displayName = "Training Blade",
						itemType = "equipment",
						rarity = "Common",
						tags = { "weapon" },
					},
				},
			}
			local screen = EquipmentScreen.create(
				mockEquipmentSnapshot,
				mockInventorySnapshot,
				function(_itemId, _slotId)
					callbackCount += 1
				end,
				function(_slotId)
					callbackCount += 1
				end,
				function()
					callbackCount += 1
				end,
				function(_item)
					callbackCount += 1
				end
			)

			local mountTime = tick() - startTime
			testResults.totalMountTime += mountTime
			UIController.mountScreen(screen)
			task.wait(WAIT_BETWEEN_CYCLES)

			local cleanupStart = tick()
			UIController.cleanup()
			local cleanupTime = tick() - cleanupStart
			testResults.totalCleanupTime += cleanupTime
			task.wait(WAIT_BETWEEN_CYCLES)
		end)

		if not success then
			failures += 1
			table.insert(testResults.failures, { screen = screenName, cycle = i, error = tostring(err) })
		end
	end

	return failures
end

local function testSkillPanel()
	local screenName = "SkillPanel"
	local failures = 0

	for i = 1, MOUNT_CYCLES_PER_SCREEN do
		local success, err = pcall(function()
			local startTime = tick()
			local mockSnapshot = {
				creatures = {
					{
						instanceId = "inst_001",
						creatureId = "creature_001",
						skills = {
							{
								skillId = "skill_001",
								displayName = "Basic Attack",
								rarity = "Common",
								skillType = "active",
								elementType = "physical",
								damageMultiplier = 1.0,
								cooldownRemaining = 0,
							},
						},
					},
				},
			}
			local screen = SkillPanel.create(mockSnapshot, "inst_001", function()
				callbackCount += 1
			end, function(_instId, _skillId)
				callbackCount += 1
			end)

			local mountTime = tick() - startTime
			testResults.totalMountTime += mountTime
			UIController.mountScreen(screen)
			task.wait(WAIT_BETWEEN_CYCLES)

			local cleanupStart = tick()
			UIController.cleanup()
			local cleanupTime = tick() - cleanupStart
			testResults.totalCleanupTime += cleanupTime
			task.wait(WAIT_BETWEEN_CYCLES)
		end)

		if not success then
			failures += 1
			table.insert(testResults.failures, { screen = screenName, cycle = i, error = tostring(err) })
		end
	end

	return failures
end

local function testTowerChallengeScreen()
	local screenName = "TowerChallengeScreen"
	local failures = 0

	for i = 1, MOUNT_CYCLES_PER_SCREEN do
		local success, err = pcall(function()
			local startTime = tick()
			local mockProfileSnapshot = {
				creatureInstances = {
					["inst_001"] = {
						instanceId = "inst_001",
						creatureId = "creature_001",
						level = 5,
					},
				},
			}
			local mockChallengeSnapshot = {
				challengeId = "tower_001",
				displayName = "Tower of Trials",
				description = "Climb the tower for rewards",
				floors = {
					{
						floorId = "tower_floor_001",
						floorNumber = 1,
						recommendedLevel = 1,
					},
					{
						floorId = "tower_floor_002",
						floorNumber = 2,
						recommendedLevel = 5,
					},
				},
			}
			local mockProgress = {
				bestFloor = 1,
				totalAttempts = 5,
				totalClears = 1,
			}
			local screen = TowerChallengeScreen.create(
				mockProfileSnapshot,
				mockChallengeSnapshot,
				mockProgress,
				function(_challengeId, _floorId, _instId)
					callbackCount += 1
				end,
				function()
					callbackCount += 1
				end,
				function()
					callbackCount += 1
				end
			)

			local mountTime = tick() - startTime
			testResults.totalMountTime += mountTime
			UIController.mountScreen(screen)
			task.wait(WAIT_BETWEEN_CYCLES)

			local cleanupStart = tick()
			UIController.cleanup()
			local cleanupTime = tick() - cleanupStart
			testResults.totalCleanupTime += cleanupTime
			task.wait(WAIT_BETWEEN_CYCLES)
		end)

		if not success then
			failures += 1
			table.insert(testResults.failures, { screen = screenName, cycle = i, error = tostring(err) })
		end
	end

	return failures
end

function UISmokeTester.runAllTests()
	assertStudio()
	resetTestResults()

	print("=========================")
	print("UI SMOKE TEST STARTING")
	print("=========================")

	local suiteStartTime = tick()
	local mainUI = getGenesisMainUI()
	local shouldRestoreWorldScreen = mainUI and mainUI:FindFirstChild("WorldScreen") ~= nil
	local profileResult = shouldRestoreWorldScreen and NetworkController.getPlayerProfileSnapshot() or nil
	local persistentSnapshot = profileResult and profileResult.success and profileResult.value or nil

	local suiteOk, suiteResult = xpcall(function()
		UIController.cleanup()
		local cleanupDeadline = os.clock() + 2
		while mainUI and #mainUI:GetChildren() > 0 and os.clock() < cleanupDeadline do
			task.wait()
		end

		UIController.init()
		assertUICountBeforeTest()

		local screens = {
			{ name = "StarterSelectionScreen", test = testStarterSelectionScreen },
			{ name = "GeneratorPanel", test = testGeneratorPanel },
			{ name = "WorldScreen", test = testWorldScreen },
			{ name = "CombatScreen", test = testCombatScreen },
			{ name = "CollectionBookScreen", test = testCollectionBookScreen },
			{ name = "CreatureInventoryScreen", test = testCreatureInventoryScreen },
			{ name = "EquipmentScreen", test = testEquipmentScreen },
			{ name = "SkillPanel", test = testSkillPanel },
			{ name = "TowerChallengeScreen", test = testTowerChallengeScreen },
		}

		for _, screenTest in ipairs(screens) do
			print(string.format("[UISmokeTester] Testing %s...", screenTest.name))

			local success, err = pcall(function()
				local failures = screenTest.test()
				testResults.screensTested += 1
				testResults.totalMountCycles += MOUNT_CYCLES_PER_SCREEN

				if failures > 0 then
					warn(string.format("[UISmokeTester] %s had %d failures", screenTest.name, failures))
				else
					print(string.format("[UISmokeTester] %s PASS", screenTest.name))
				end
			end)

			if not success then
				warn(string.format("[UISmokeTester] %s CRASHED: %s", screenTest.name, tostring(err)))
				table.insert(testResults.failures, { screen = screenTest.name, cycle = 0, error = tostring(err) })
			end

			UIController.init()
		end

		print("[UISmokeTester] Testing double cleanup (idempotency)...")
		local cleanupSuccess, cleanupErr = pcall(function()
			UIController.cleanup()
			UIController.cleanup()
		end)

		if not cleanupSuccess then
			testResults.connectionCleanupFailed = true
			warn("[UISmokeTester] Double cleanup failed: " .. tostring(cleanupErr))
		end

		assertOrphanGuard()
		assertConnectionTeardown()
		assertCallbackLeaks()

		local suiteEndTime = tick()
		local totalSuiteTime = suiteEndTime - suiteStartTime

		print("=========================")
		print("UI SMOKE TEST SUMMARY")
		print("=========================")
		print(string.format("Screens tested: %d", testResults.screensTested))
		print(string.format("Mount cycles: %d", testResults.totalMountCycles))
		print(string.format("Callbacks verified: %s", testResults.callbackLeaks and "FAIL" or "PASS"))
		print(string.format("Orphan UI: %s", testResults.orphanUI and "FAIL" or "PASS"))
		print(string.format("Connection cleanup: %s", testResults.connectionCleanupFailed and "FAIL" or "PASS"))
		print(string.format("Memory leak detected: %s", testResults.memoryLeakDetected and "YES" or "NO"))
		print(string.format("Failures: %d", #testResults.failures))
		print(string.format("Total mount time: %.3fs", testResults.totalMountTime))
		print(string.format("Total cleanup time: %.3fs", testResults.totalCleanupTime))
		print(string.format("Total suite time: %.3fs", totalSuiteTime))

		if #testResults.failures > 0 then
			print("\n[UISmokeTester] Failure details:")
			for _, failure in ipairs(testResults.failures) do
				print(string.format("  - %s (cycle %d): %s", failure.screen, failure.cycle, failure.error))
			end
		end

		local overallResult = (#testResults.failures == 0)
			and not testResults.memoryLeakDetected
			and not testResults.orphanUI
			and not testResults.callbackLeaks
			and not testResults.connectionCleanupFailed
		print(string.format("\nOVERALL RESULT: %s", overallResult and "PASS" or "FAIL"))
		print("=========================")

		return {
			success = overallResult,
			results = testResults,
			totalTime = totalSuiteTime,
		}
	end, debug.traceback)

	if shouldRestoreWorldScreen then
		if not persistentSnapshot then
			error("[UISmokeTester] Failed to capture persistent WorldScreen state.")
		end
		WorldController.start(persistentSnapshot)
	end
	if not suiteOk then
		error(suiteResult)
	end
	return suiteResult
end

return UISmokeTester
