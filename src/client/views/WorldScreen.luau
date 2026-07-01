local UIComponents = require(script.Parent.UIComponents)
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)

local WorldScreen = {}

function WorldScreen.create(snapshot, worldData, onStartStage, onClaimGenerator, onEvolve)
	local screen = UIComponents.createBaseContainer()
	screen.Name = "WorldScreen"
	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	-- Header
	local header = UIComponents.createBaseLabel("World Hub - " .. (worldData.worldId or "Unknown World"))
	header.Size = UDim2.new(1, 0, 0, 40)
	header.Position = UDim2.new(0, 20, 0, 20)
	header.TextSize = 28
	header.Parent = panel

	-- Currency balances
	local biomassVal = snapshot.balances and snapshot.balances.biomass or 0
	local dnaVal = snapshot.balances and snapshot.balances.dna or 0
	local balanceLabel = UIComponents.createBaseLabel(string.format("Biomass: %d   |   DNA: %d", biomassVal, dnaVal))
	balanceLabel.Size = UDim2.new(0, 400, 0, 30)
	balanceLabel.Position = UDim2.new(1, -420, 0, 20)
	balanceLabel.TextXAlignment = Enum.TextXAlignment.Right
	balanceLabel.Parent = panel

	-- Active Creature Panel
	local creaturePanel = UIComponents.createBasePanel()
	creaturePanel.Name = "CreaturePanel"
	creaturePanel.Size = UDim2.new(0, 300, 0, 220)
	creaturePanel.Position = UDim2.new(0, 20, 0, 80)
	creaturePanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	creaturePanel.Parent = panel

	local cTitle = UIComponents.createBaseLabel("Active Creature")
	cTitle.Position = UDim2.new(0, 10, 0, 10)
	cTitle.TextSize = 18
	cTitle.Parent = creaturePanel

	local activeInst = nil
	local activeCreatureId = nil
	local activeInstId = nil
	for instId, inst in pairs(snapshot.creatureInstances) do
		activeInst = inst
		activeCreatureId = inst.creatureId
		activeInstId = instId
		break
	end

	if activeInst and activeCreatureId then
		-- Load max HP and stats from CreatureRegistry
		local config = CreatureRegistry.getCreature(activeCreatureId)
		local maxHp = config and config.baseStats and config.baseStats.hp or 100
		local atk = config and config.baseStats and config.baseStats.atk or 10
		local def = config and config.baseStats and config.baseStats.def or 5
		local spd = config and config.baseStats and config.baseStats.spd or 10

		-- Experience needed formula
		local xpNeeded = activeInst.level * 100

		local cInfo = UIComponents.createBaseLabel(string.format(
			"Species: %s\nLevel: %d\nXP: %d / %d\nHP: %d / %d\nATK: %d  DEF: %d  SPD: %d",
			activeCreatureId, activeInst.level, activeInst.xp, xpNeeded, maxHp, maxHp, atk, def, spd
		))
		cInfo.Position = UDim2.new(0, 10, 0, 40)
		cInfo.Size = UDim2.new(1, -20, 0, 100)
		cInfo.Parent = creaturePanel

		-- Check if evolution options exist
		local evoOpt = snapshot.evolutionOptions and snapshot.evolutionOptions[activeInstId]
		if evoOpt then
			local evolveBtn = UIComponents.createBaseButton(string.format(
				"Evolve to %s\n(Req. Lv. %d, %d Biomass)", 
				evoOpt.toCreatureId, evoOpt.requiredLevel, evoOpt.biomassCost
			))
			evolveBtn.Name = "EvolveButton"
			evolveBtn.Size = UDim2.new(1, -20, 0, 50)
			evolveBtn.Position = UDim2.new(0, 10, 0, 150)
			evolveBtn.Parent = creaturePanel

			local levelMet = activeInst.level >= evoOpt.requiredLevel
			local biomassMet = biomassVal >= evoOpt.biomassCost
			if levelMet and biomassMet then
				evolveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
				evolveBtn.Activated:Connect(function()
					onEvolve(activeInstId, evoOpt.evolutionId)
				end)
			else
				evolveBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				evolveBtn.TextTransparency = 0.5
				evolveBtn.Activated:Connect(function()
					warn("Cannot evolve: Requirements not met.")
				end)
			end
		end
	else
		local cInfo = UIComponents.createBaseLabel("No active creature selection.")
		cInfo.Position = UDim2.new(0, 10, 0, 40)
		cInfo.Parent = creaturePanel
	end

	-- Generator Panel
	local generatorPanel = UIComponents.createBasePanel()
	generatorPanel.Name = "GeneratorPanel"
	generatorPanel.Size = UDim2.new(0, 300, 0, 120)
	generatorPanel.Position = UDim2.new(0, 20, 0, 320)
	generatorPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	generatorPanel.Parent = panel

	local generators = snapshot.generators or snapshot.generatorSnapshots or {}
	local genSnapshot = generators[1]

	local genTitle = UIComponents.createBaseLabel(genSnapshot and genSnapshot.displayName or "Bio Generator")
	genTitle.Position = UDim2.new(0, 10, 0, 10)
	genTitle.TextSize = 18
	genTitle.Parent = generatorPanel

	local rate = genSnapshot and genSnapshot.ratePerSecond or 0
	local maxAcc = genSnapshot and genSnapshot.maxAccumulated or 0
	local lastClaimedAt = genSnapshot and genSnapshot.lastClaimedAt or nil
	local serverAccumulated = genSnapshot and genSnapshot.accumulated or 0

	local function getAccumulatedAmount()
		if not lastClaimedAt or rate <= 0 then return serverAccumulated end
		local elapsed = math.max(0, os.time() - lastClaimedAt)
		return math.min(maxAcc, math.floor(elapsed * rate))
	end

	local initialAcc = getAccumulatedAmount()
	local genInfo = UIComponents.createBaseLabel(string.format("Accumulating: %d / %d Biomass", initialAcc, maxAcc))
	genInfo.Name = "GeneratorInfo"
	genInfo.Position = UDim2.new(0, 10, 0, 40)
	genInfo.Size = UDim2.new(1, -20, 0, 30)
	genInfo.Parent = generatorPanel

	local claimBtn = UIComponents.createBaseButton("Claim Generator")
	claimBtn.Name = "ClaimGeneratorButton"
	claimBtn.Size = UDim2.new(0, 180, 0, 30)
	claimBtn.Position = UDim2.new(0, 10, 0, 80)
	claimBtn.Parent = generatorPanel
	
	if initialAcc >= 1 then
		claimBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
	else
		claimBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	end

	claimBtn.Activated:Connect(function()
		if genSnapshot and genSnapshot.generatorId then
			onClaimGenerator(genSnapshot.generatorId)
		end
	end)

	-- Update loop for generator accumulation display
	local running = true
	task.spawn(function()
		while running and screen.Parent do
			task.wait(0.5)
			if screen.Parent then
				local acc = getAccumulatedAmount()
				genInfo.Text = string.format("Accumulating: %d / %d Biomass", acc, maxAcc)
				if acc >= 1 then
					claimBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
				else
					claimBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				end
			end
		end
	end)

	screen.Destroying:Connect(function()
		running = false
	end)

	-- Collection Progress Panel
	local collectionPanel = UIComponents.createBasePanel()
	collectionPanel.Name = "CollectionProgress"
	collectionPanel.Size = UDim2.new(0, 300, 0, 80)
	collectionPanel.Position = UDim2.new(0, 20, 0, 460)
	collectionPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	collectionPanel.Parent = panel

	local colTitle = UIComponents.createBaseLabel("Collection Progress")
	colTitle.Position = UDim2.new(0, 10, 0, 10)
	colTitle.Parent = collectionPanel

	local discoveredCount = snapshot.collectionProgress and snapshot.collectionProgress.completionCount or 0
	local totalCount = snapshot.collectionProgress and snapshot.collectionProgress.total or 3
	local colInfo = UIComponents.createBaseLabel(string.format("Discovered: %d / %d", discoveredCount, totalCount))
	colInfo.Position = UDim2.new(0, 10, 0, 40)
	colInfo.Parent = collectionPanel

	-- Available Stages Panel
	local stagesLabel = UIComponents.createBaseLabel("Available Stages:")
	stagesLabel.Position = UDim2.new(0, 350, 0, 80)
	stagesLabel.TextSize = 20
	stagesLabel.Parent = panel

	local stagesList = Instance.new("Frame")
	stagesList.Name = "StagesList"
	stagesList.BackgroundTransparency = 1
	stagesList.Position = UDim2.new(0, 350, 0, 120)
	stagesList.Size = UDim2.new(0, 400, 1, -140)
	stagesList.Parent = panel
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = stagesList

	for _, stageId in ipairs(worldData.unlockedStages or {}) do
		local stageBtn = UIComponents.createBaseButton("Start " .. stageId)
		stageBtn.Name = "Start_" .. stageId
		stageBtn.Size = UDim2.new(1, 0, 0, 50)
		stageBtn.Parent = stagesList
		stageBtn.Activated:Connect(function() 
			onStartStage(stageId) 
		end)
	end

	return screen
end

return WorldScreen
