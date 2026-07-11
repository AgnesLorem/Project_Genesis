--[[
	WorldScreen
	Location: src/client/views/WorldScreen.luau

	Displays the main world hub with stats, active creature, generator rates,
	navigation to sub-menus (Generators, Creatures, Collection, Tower, Inventory),
	and lists unlocked stages for story battle.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)
local StatCalculator = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.StatCalculator)

local WorldScreen = {}

function WorldScreen.create(
	snapshot: any,
	worldData: any,
	onStartStage: (string) -> (),
	onClaimGenerator: (string) -> (),
	onEvolve: (string, string) -> (),
	onOpenGenerators: () -> (),
	onOpenCreatures: () -> (),
	onOpenCollection: () -> (),
	onOpenTower: () -> (),
	onOpenInventory: () -> ()
): Frame
	local screen = UIComponents.createBaseContainer()
	screen.Name = "WorldScreen"

	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	-- Apply Mobile notch Safe Area constraints
	local safeArea = Instance.new("UIPadding")
	safeArea.PaddingLeft = UDim.new(0, 24)
	safeArea.PaddingRight = UDim.new(0, 24)
	safeArea.PaddingTop = UDim.new(0, 20)
	safeArea.PaddingBottom = UDim.new(0, 20)
	safeArea.Parent = panel

	-- ─── Header ──────────────────────────────────────────────────────────────────

	local header = UIComponents.createBaseLabel("World Hub - " .. (worldData.worldId or "Unknown World"))
	header.Size = UDim2.new(0.5, 0, 0, 44)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.Font = Theme.Fonts.Header
	header.TextSize = 28
	header.Parent = panel

	-- Currency balances
	local biomassVal = snapshot.balances and snapshot.balances.biomass or 0
	local dnaVal = snapshot.balances and snapshot.balances.dna or 0
	local balanceLabel = UIComponents.createBaseLabel(string.format("Biomass: %d   |   DNA: %d", biomassVal, dnaVal))
	balanceLabel.Size = UDim2.new(0.5, 0, 0, 44)
	balanceLabel.Position = UDim2.new(0.5, 0, 0, 0)
	balanceLabel.Font = Theme.Fonts.Bold
	balanceLabel.TextColor3 = Theme.Colors.Accent
	balanceLabel.TextXAlignment = Enum.TextXAlignment.Right
	balanceLabel.Parent = panel

	-- ─── Top Navigation Bar ──────────────────────────────────────────────────────

	local navBar = Instance.new("Frame")
	navBar.Name = "NavBar"
	navBar.BackgroundTransparency = 1
	navBar.Position = UDim2.new(0, 0, 0, 56)
	navBar.Size = UDim2.new(1, 0, 0, 44)
	navBar.Parent = panel

	local navLayout = Instance.new("UIListLayout")
	navLayout.FillDirection = Enum.FillDirection.Horizontal
	navLayout.Padding = UDim.new(0, 12)
	navLayout.SortOrder = Enum.SortOrder.LayoutOrder
	navLayout.Parent = navBar

	local function addNavButton(text: string, order: number, onClick: () -> ())
		local btn = UIComponents.createBaseButton(text)
		btn.Size = UDim2.new(0.18, 0, 1, 0)
		btn.LayoutOrder = order
		btn.Parent = navBar
		btn.Activated:Connect(onClick)
		return btn
	end

	addNavButton("⚡ Generators", 1, onOpenGenerators)
	addNavButton("🦎 My Creatures", 2, onOpenCreatures)
	addNavButton("📖 Collection", 3, onOpenCollection)
	addNavButton("🏰 Tower Hub", 4, onOpenTower)
	addNavButton("🎒 Inventory", 5, onOpenInventory)

	-- ─── Active Creature Panel ───────────────────────────────────────────────────

	local creaturePanel = UIComponents.createBasePanel()
	creaturePanel.Name = "CreaturePanel"
	creaturePanel.Size = UDim2.new(0.44, 0, 0.38, 0)
	creaturePanel.Position = UDim2.new(0, 0, 0, 120)
	creaturePanel.Parent = panel

	local cTitle = UIComponents.createBaseLabel("Active Creature")
	cTitle.Position = UDim2.new(0, 16, 0, 12)
	cTitle.Font = Theme.Fonts.Bold
	cTitle.TextSize = 18
	cTitle.Parent = creaturePanel

	local activeInst = nil
	local activeCreatureId = nil
	local activeInstId = nil
	for instId, inst in pairs(snapshot.creatureInstances) do
		if instId == snapshot.activeCreatureInstanceId then
			activeInst = inst
			activeCreatureId = inst.creatureId
			activeInstId = instId
			break
		end
	end

	-- Fallback to first owned creature if no active selection is explicitly set
	if not activeInst then
		for instId, inst in pairs(snapshot.creatureInstances) do
			activeInst = inst
			activeCreatureId = inst.creatureId
			activeInstId = instId
			break
		end
	end

	local isProcessingEvolve = false

	if activeInst and activeCreatureId then
		local config = CreatureRegistry.getCreature(activeCreatureId)
		local scaledStats = StatCalculator.getScaledStats(config, activeInst.level, nil)
		local maxHp = scaledStats.hp
		local atk = scaledStats.atk
		local def = scaledStats.def
		local spd = scaledStats.spd

		local xpNeeded = activeInst.level * 100

		local cInfo = UIComponents.createBaseLabel(
			string.format(
				"Species: %s\nLevel: %d\nXP: %d / %d\nHP: %d / %d\nATK: %d  DEF: %d  SPD: %d",
				activeCreatureId,
				activeInst.level,
				activeInst.xp,
				xpNeeded,
				maxHp,
				maxHp,
				atk,
				def,
				spd
			)
		)
		cInfo.Position = UDim2.new(0, 16, 0, 44)
		cInfo.Size = UDim2.new(1, -32, 0.5, 0)
		cInfo.TextColor3 = Theme.Colors.Muted
		cInfo.Parent = creaturePanel

		-- Check if evolution options exist
		local evoOpt = snapshot.evolutionOptions and snapshot.evolutionOptions[activeInstId]
		if evoOpt then
			local evolveBtn = UIComponents.createBaseButton(
				string.format(
					"Evolve to %s (Req. Lv. %d, %d Biomass)",
					evoOpt.toCreatureId,
					evoOpt.requiredLevel,
					evoOpt.biomassCost
				)
			)
			evolveBtn.Name = "EvolveButton"
			evolveBtn.Size = UDim2.new(1, -32, 0, 44)
			evolveBtn.Position = UDim2.new(0, 16, 1, -60)
			evolveBtn.Parent = creaturePanel

			local levelMet = activeInst.level >= evoOpt.requiredLevel
			local biomassMet = biomassVal >= evoOpt.biomassCost
			if levelMet and biomassMet then
				evolveBtn.BackgroundColor3 = Theme.Colors.Success
				evolveBtn.Activated:Connect(function()
					if isProcessingEvolve then
						return
					end
					isProcessingEvolve = true
					onEvolve(activeInstId, evoOpt.evolutionId)
				end)
			else
				evolveBtn.BackgroundColor3 = Theme.Colors.Border
				evolveBtn.TextTransparency = 0.5
				evolveBtn.Activated:Connect(function()
					warn("Cannot evolve: Requirements not met.")
				end)
			end
		end
	else
		local cInfo = UIComponents.createBaseLabel("No active creature selection.")
		cInfo.Position = UDim2.new(0, 16, 0, 44)
		cInfo.Parent = creaturePanel
	end

	-- ─── Generator Panel ─────────────────────────────────────────────────────────

	local generatorPanel = UIComponents.createBasePanel()
	generatorPanel.Name = "GeneratorPanel"
	generatorPanel.Size = UDim2.new(0.44, 0, 0.22, 0)
	generatorPanel.Position = UDim2.new(0, 0, 0.38, 140)
	generatorPanel.Parent = panel

	local generators = snapshot.generators or snapshot.generatorSnapshots or {}
	local genSnapshot = generators[1]

	local genTitle = UIComponents.createBaseLabel(genSnapshot and genSnapshot.displayName or "Bio Generator")
	genTitle.Position = UDim2.new(0, 16, 0, 12)
	genTitle.Font = Theme.Fonts.Bold
	genTitle.TextSize = 18
	genTitle.Parent = generatorPanel

	local rate = genSnapshot and genSnapshot.ratePerSecond or 0
	local maxAcc = genSnapshot and genSnapshot.capacity or (genSnapshot and genSnapshot.maxAccumulated) or 0
	local lastClaimedAt = genSnapshot and genSnapshot.lastClaimedAt or nil
	local serverAccumulated = genSnapshot and genSnapshot.accumulated or 0

	local function getAccumulatedAmount()
		if not lastClaimedAt or rate <= 0 then
			return serverAccumulated
		end
		local elapsed = math.max(0, os.time() - lastClaimedAt)
		return math.min(maxAcc, math.floor(elapsed * rate))
	end

	local initialAcc = getAccumulatedAmount()
	local genInfo = UIComponents.createBaseLabel(string.format("Accumulating: %d / %d Biomass", initialAcc, maxAcc))
	genInfo.Name = "GeneratorInfo"
	genInfo.Position = UDim2.new(0, 16, 0, 40)
	genInfo.Size = UDim2.new(1, -32, 0, 30)
	genInfo.TextColor3 = Theme.Colors.Muted
	genInfo.Parent = generatorPanel

	local claimBtn = UIComponents.createBaseButton("Claim Generator")
	claimBtn.Name = "ClaimGeneratorButton"
	claimBtn.Size = UDim2.new(0.8, 0, 0, 44)
	claimBtn.Position = UDim2.new(0.1, 0, 1, -56)
	claimBtn.Parent = generatorPanel

	if initialAcc >= 1 then
		claimBtn.BackgroundColor3 = Theme.Colors.Success
	else
		claimBtn.BackgroundColor3 = Theme.Colors.Border
	end

	local isProcessingClaim = false
	claimBtn.Activated:Connect(function()
		if isProcessingClaim then
			return
		end
		if genSnapshot and genSnapshot.generatorId then
			isProcessingClaim = true
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
					claimBtn.BackgroundColor3 = Theme.Colors.Success
				else
					claimBtn.BackgroundColor3 = Theme.Colors.Border
				end
			end
		end
	end)

	screen.Destroying:Connect(function()
		running = false
	end)

	-- ─── Collection Progress Panel ───────────────────────────────────────────────

	local collectionPanel = UIComponents.createBasePanel()
	collectionPanel.Name = "CollectionProgress"
	collectionPanel.Size = UDim2.new(0.44, 0, 0.16, 0)
	collectionPanel.Position = UDim2.new(0, 0, 0.6, 160)
	collectionPanel.Parent = panel

	local colTitle = UIComponents.createBaseLabel("Collection Progress")
	colTitle.Position = UDim2.new(0, 16, 0, 12)
	colTitle.Font = Theme.Fonts.Bold
	colTitle.Parent = collectionPanel

	local discoveredCount = snapshot.collectionProgress and snapshot.collectionProgress.completionCount or 0
	local totalCount = snapshot.collectionProgress and snapshot.collectionProgress.total or 3
	local colInfo = UIComponents.createBaseLabel(string.format("Discovered: %d / %d", discoveredCount, totalCount))
	colInfo.Position = UDim2.new(0, 16, 0, 36)
	colInfo.TextColor3 = Theme.Colors.Rare
	colInfo.Parent = collectionPanel

	-- ─── Available Stages Panel ──────────────────────────────────────────────────

	local stagesLabel = UIComponents.createBaseLabel("Available Stages:")
	stagesLabel.Position = UDim2.new(0.5, 24, 0, 120)
	stagesLabel.Font = Theme.Fonts.Bold
	stagesLabel.TextSize = 20
	stagesLabel.Parent = panel

	local stagesList = Instance.new("Frame")
	stagesList.Name = "StagesList"
	stagesList.BackgroundTransparency = 1
	stagesList.Position = UDim2.new(0.5, 24, 0, 160)
	stagesList.Size = UDim2.new(0.46, 0, 0.7, 0)
	stagesList.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.Parent = stagesList

	local isProcessingStage = false
	for _, stageId in ipairs(worldData.unlockedStages or {}) do
		local stageBtn = UIComponents.createBaseButton("Start " .. stageId)
		stageBtn.Name = "Start_" .. stageId
		stageBtn.Size = UDim2.new(1, 0, 0, 48)
		stageBtn.BackgroundColor3 = Theme.Colors.Primary
		stageBtn.Parent = stagesList
		stageBtn.Activated:Connect(function()
			if isProcessingStage then
				return
			end
			isProcessingStage = true
			onStartStage(stageId)
		end)
	end

	return screen
end

return WorldScreen
