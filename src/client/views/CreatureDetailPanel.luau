--[[
	CreatureDetailPanel
	Location: src/client/views/CreatureDetailPanel.luau

	Modal overlay showing full detail for a single creature instance.
	Responsive layouts and Theme tokens.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local AnimationService = require(script.Parent.AnimationService)

local CreatureDetailPanel = {}

local function _xpNeededForLevel(level: number): number
	return level * 100
end

function CreatureDetailPanel.create(instance: any, publicConfig: any, isActive: boolean, onClose: () -> ()): Frame
	local modal = UIComponents.createBaseModal()
	modal.Name = "CreatureDetailPanel"

	local panel = UIComponents.createBasePanel()
	panel.Name = "DetailPanel"
	panel.Size = UDim2.new(0, 520, 0, 460)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.ZIndex = Theme.ZIndex.Modal + 1
	panel.Parent = modal

	-- Dynamic rarity highlight
	local rarity = "Common"
	if publicConfig and publicConfig.collectionCategory == "epic" then
		rarity = "Legendary"
	elseif publicConfig and publicConfig.collectionCategory == "rare" then
		rarity = "Rare"
	end

	UIComponents.applyRarityBorder(panel, rarity)

	-- ─── Header ──────────────────────────────────────────────────────────────────

	local headerBg = Instance.new("Frame")
	headerBg.Name = "Header"
	headerBg.Size = UDim2.new(1, 0, 0, 56)
	headerBg.BackgroundColor3 = Theme.Colors.FrostedGlass
	headerBg.BorderSizePixel = 0
	headerBg.Parent = panel

	local hCorner = Instance.new("UICorner")
	hCorner.CornerRadius = Theme.CornerRadius
	hCorner.Parent = headerBg

	local displayName = publicConfig and publicConfig.displayName or (instance and instance.creatureId or "Unknown")
	local titleText = displayName
	if isActive then
		titleText = "⚔ " .. titleText .. "  [ACTIVE]"
	end

	local titleLabel = UIComponents.createBaseLabel(titleText)
	titleLabel.Size = UDim2.new(1, -160, 1, 0)
	titleLabel.Position = UDim2.new(0, 16, 0, 0)
	titleLabel.Font = Theme.Fonts.Header
	titleLabel.TextSize = 22
	titleLabel.Parent = headerBg

	local rarityTag =
		UIComponents.createBaseLabel(publicConfig and string.upper(publicConfig.collectionCategory or "") or "")
	rarityTag.Size = UDim2.new(0, 100, 0, 24)
	rarityTag.AnchorPoint = Vector2.new(1, 0.5)
	rarityTag.Position = UDim2.new(1, -120, 0.5, 0)
	rarityTag.Font = Theme.Fonts.Bold
	rarityTag.TextSize = 12
	rarityTag.TextColor3 = Theme.Colors.Accent
	rarityTag.TextXAlignment = Enum.TextXAlignment.Right
	rarityTag.Parent = headerBg

	-- Close button
	local closeBtn = UIComponents.createBaseButton("✕")
	closeBtn.Size = UDim2.new(0, 44, 0, 44)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -8, 0.5, 0)
	closeBtn.BackgroundColor3 = Theme.Colors.Error
	closeBtn.TextSize = 20
	closeBtn.Parent = headerBg
	closeBtn.Activated:Connect(onClose)

	-- ─── Art Placeholder ─────────────────────────────────────────────────────────

	local artFrame = UIComponents.createBasePanel()
	artFrame.Name = "ArtPlaceholder"
	artFrame.Size = UDim2.new(0, 140, 0, 140)
	artFrame.Position = UDim2.new(0, 20, 0, 76)
	artFrame.Parent = panel

	local artIcon = Instance.new("TextLabel")
	artIcon.Size = UDim2.new(1, 0, 1, 0)
	artIcon.BackgroundTransparency = 1
	artIcon.Text = "🦎"
	artIcon.TextScaled = true
	artIcon.Font = Theme.Fonts.Header
	artIcon.Parent = artFrame

	-- ─── Stats Block ─────────────────────────────────────────────────────────────

	local level = instance and instance.level or 1
	local xp = instance and instance.xp or 0
	local xpNeeded = _xpNeededForLevel(level)
	local xpFraction = math.clamp(xp / math.max(xpNeeded, 1), 0, 1)

	local statsX = 176
	local statsY = 76

	local function _row(labelText: string, valueText: string, offsetY: number)
		local lbl = UIComponents.createBaseLabel(labelText)
		lbl.Size = UDim2.new(0, 120, 0, 22)
		lbl.Position = UDim2.new(0, statsX, 0, statsY + offsetY)
		lbl.Font = Theme.Fonts.Regular
		lbl.TextSize = 14
		lbl.TextColor3 = Theme.Colors.Muted
		lbl.Parent = panel

		local val = UIComponents.createBaseLabel(valueText)
		val.Size = UDim2.new(0, 180, 0, 22)
		val.Position = UDim2.new(0, statsX + 120, 0, statsY + offsetY)
		val.Font = Theme.Fonts.Bold
		val.TextSize = 14
		val.TextColor3 = Theme.Colors.White
		val.TextXAlignment = Enum.TextXAlignment.Left
		val.Parent = panel
	end

	_row("Creature ID:", instance and instance.creatureId or "—", 0)
	_row("Level:", tostring(level), 26)
	_row("XP:", string.format("%d / %d", xp, xpNeeded), 52)

	-- XP bar
	local xpBarBg = Instance.new("Frame")
	xpBarBg.Name = "XPBarBg"
	xpBarBg.Size = UDim2.new(0, 300, 0, 12)
	xpBarBg.Position = UDim2.new(0, statsX, 0, statsY + 80)
	xpBarBg.BackgroundColor3 = Theme.Colors.Background
	xpBarBg.BorderSizePixel = 0
	xpBarBg.Parent = panel

	local xpBarCorner = Instance.new("UICorner")
	xpBarCorner.CornerRadius = UDim.new(1, 0)
	xpBarCorner.Parent = xpBarBg

	local xpFill = Instance.new("Frame")
	xpFill.Name = "XPFill"
	xpFill.Size = UDim2.new(xpFraction, 0, 1, 0)
	xpFill.BackgroundColor3 = Theme.Colors.Success
	xpFill.BorderSizePixel = 0
	xpFill.Parent = xpBarBg

	local xpFillCorner = Instance.new("UICorner")
	xpFillCorner.CornerRadius = UDim.new(1, 0)
	xpFillCorner.Parent = xpFill

	-- ─── Divider ─────────────────────────────────────────────────────────────────

	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.Size = UDim2.new(1, -40, 0, 1)
	divider.Position = UDim2.new(0, 20, 0, 232)
	divider.BackgroundColor3 = Theme.Colors.Border
	divider.BorderSizePixel = 0
	divider.Parent = panel

	-- ─── Evolution Section ───────────────────────────────────────────────────────

	local evoY = 244

	local evoTitle = UIComponents.createBaseLabel("Evolution")
	evoTitle.Size = UDim2.new(1, -40, 0, 24)
	evoTitle.Position = UDim2.new(0, 20, 0, evoY)
	evoTitle.Font = Theme.Fonts.Bold
	evoTitle.TextSize = 18
	evoTitle.TextColor3 = Theme.Colors.Accent
	evoTitle.Parent = panel

	evoY = evoY + 32

	local evo = publicConfig and publicConfig.evolutionAvailable

	if evo then
		local evoName = UIComponents.createBaseLabel(string.format("→ %s", evo.toCreatureId))
		evoName.Size = UDim2.new(1, -40, 0, 22)
		evoName.Position = UDim2.new(0, 20, 0, evoY)
		evoName.Font = Theme.Fonts.Bold
		evoName.TextSize = 16
		evoName.TextColor3 = Theme.Colors.Rare
		evoName.Parent = panel

		local evoReqs = UIComponents.createBaseLabel(
			string.format("Required Level: %d   Biomass Cost: %d", evo.requiredLevel, evo.biomassCost)
		)
		evoReqs.Size = UDim2.new(1, -40, 0, 22)
		evoReqs.Position = UDim2.new(0, 20, 0, evoY + 24)
		evoReqs.Font = Theme.Fonts.Regular
		evoReqs.TextSize = 14
		evoReqs.TextColor3 = Theme.Colors.Muted
		evoReqs.Parent = panel

		-- Eligibility check
		local eligible = level >= evo.requiredLevel
		local statusText = eligible and "✓ Eligible (evolve via inventory)"
			or string.format("✗ Need Level %d (currently %d)", evo.requiredLevel, level)
		local statusLabel = UIComponents.createBaseLabel(statusText)
		statusLabel.Size = UDim2.new(1, -40, 0, 22)
		statusLabel.Position = UDim2.new(0, 20, 0, evoY + 50)
		statusLabel.Font = Theme.Fonts.Bold
		statusLabel.TextSize = 14
		statusLabel.TextColor3 = eligible and Theme.Colors.Success or Theme.Colors.Error
		statusLabel.Parent = panel
	else
		local fullyEvolved = UIComponents.createBaseLabel("✓ Fully Evolved — No further evolution available.")
		fullyEvolved.Size = UDim2.new(1, -40, 0, 22)
		fullyEvolved.Position = UDim2.new(0, 20, 0, evoY)
		fullyEvolved.Font = Theme.Fonts.Regular
		fullyEvolved.TextSize = 14
		fullyEvolved.TextColor3 = Theme.Colors.Success
		fullyEvolved.Parent = panel
	end

	-- ─── Instance ID (debug) ─────────────────────────────────────────────────────

	if instance and instance.instanceId then
		local idLabel = UIComponents.createBaseLabel("ID: " .. tostring(instance.instanceId))
		idLabel.Size = UDim2.new(1, -40, 0, 18)
		idLabel.Position = UDim2.new(0, 20, 1, -30)
		idLabel.Font = Theme.Fonts.Regular
		idLabel.TextSize = 11
		idLabel.TextColor3 = Theme.Colors.Muted
		idLabel.Parent = panel
	end

	return modal
end

return CreatureDetailPanel
