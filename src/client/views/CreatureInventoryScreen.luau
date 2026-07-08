--[[
	CreatureInventoryScreen
	Location: src/client/views/CreatureInventoryScreen.luau

	Shows all owned creature instances. Responsive layouts and Theme tokens.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local AnimationService = require(script.Parent.AnimationService)

local CreatureInventoryScreen = {}

local function _xpNeededForLevel(level: number): number
	return level * 100
end

function CreatureInventoryScreen.create(
	inventoryData: any,
	publicConfigs: any,
	onClose: () -> (),
	onSetActive: (string) -> (),
	onOpenDetail: (string) -> ()
): Frame

	local screen = UIComponents.createBaseContainer()
	screen.Name = "CreatureInventoryScreen"

	local panel = UIComponents.createBasePanel()
	panel.Parent = screen

	-- Safe area padding
	local safeArea = Instance.new("UIPadding")
	safeArea.PaddingLeft = UDim.new(0, 24)
	safeArea.PaddingRight = UDim.new(0, 24)
	safeArea.PaddingTop = UDim.new(0, 20)
	safeArea.PaddingBottom = UDim.new(0, 20)
	safeArea.Parent = panel

	-- ─── Header ──────────────────────────────────────────────────────────────────

	local header = UIComponents.createBaseContainer()
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 44)
	header.Parent = panel

	local title = UIComponents.createBaseLabel("🦎 My Creatures")
	title.Size = UDim2.new(0.5, 0, 1, 0)
	title.Font = Theme.Fonts.Header
	title.TextSize = 26
	title.Parent = header

	local closeBtn = UIComponents.createBaseButton("✕ Close")
	closeBtn.Size = UDim2.new(0, 110, 0, 44)
	closeBtn.Position = UDim2.new(1, -110, 0, 0)
	closeBtn.BackgroundColor3 = Theme.Colors.Error
	closeBtn.Parent = header
	closeBtn.Activated:Connect(onClose)

	-- ─── Scrollable List ─────────────────────────────────────────────────────────

	local scrollArea = Instance.new("ScrollingFrame")
	scrollArea.Name = "InventoryScroll"
	scrollArea.Size = UDim2.new(1, 0, 1, -64)
	scrollArea.Position = UDim2.new(0, 0, 0, 64)
	scrollArea.BackgroundTransparency = 1
	scrollArea.BorderSizePixel = 0
	scrollArea.ScrollBarThickness = 6
	scrollArea.ScrollBarImageColor3 = Theme.Colors.Border
	scrollArea.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scrollArea

	local instances = inventoryData and inventoryData.instances or {}
	local activeId = inventoryData and inventoryData.activeCreatureInstanceId

	local sortedInstances = {}
	for instanceId, inst in pairs(instances) do
		if type(inst) == "table" then
			table.insert(sortedInstances, inst)
		end
	end
	table.sort(sortedInstances, function(a, b)
		local ca = publicConfigs and publicConfigs[a.creatureId]
		local cb = publicConfigs and publicConfigs[b.creatureId]
		local pa = ca and ca.sortOrder or 999
		local pb = cb and cb.sortOrder or 999
		if pa ~= pb then return pa < pb end
		return (a.creatureId or "") < (b.creatureId or "")
	end)

	-- Empty state
	if #sortedInstances == 0 then
		local emptyLabel = UIComponents.createBaseLabel("You don't own any creatures yet.")
		emptyLabel.Size = UDim2.new(1, 0, 0, 40)
		emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
		emptyLabel.TextSize = 20
		emptyLabel.TextColor3 = Theme.Colors.Muted
		emptyLabel.Parent = scrollArea
		return screen
	end

	-- Only create visual strokes on selected or active cards to optimize performance
	for i, inst in ipairs(sortedInstances) do
		local instanceId = inst.instanceId
		local isActive = instanceId == activeId
		local cfg = publicConfigs and publicConfigs[inst.creatureId]

		-- ─── Row Card ──────────────────────────────────────────────────────────

		local card = UIComponents.createBasePanel()
		card.Name = "Card_" .. tostring(instanceId)
		card.Size = UDim2.new(1, -6, 0, 94)
		card.LayoutOrder = i
		card.Parent = scrollArea

		-- Performance: Only apply rarity highlight on card background color or thin border
		local rarity = "Common"
		if cfg and cfg.collectionCategory == "epic" then
			rarity = "Legendary"
		elseif cfg and cfg.collectionCategory == "rare" then
			rarity = "Rare"
		end
		
		UIComponents.applyRarityBorder(card, rarity)

		-- Active border highlight
		if isActive then
			UIComponents.applySelectionOutline(card)
			
			local badge = Instance.new("TextLabel")
			badge.Name = "ActiveBadge"
			badge.Size = UDim2.new(0, 80, 0, 22)
			badge.Position = UDim2.new(0, 12, 0, 8)
			badge.BackgroundColor3 = Theme.Colors.Success
			badge.BorderSizePixel = 0
			badge.Text = "⚔ ACTIVE"
			badge.TextSize = 12
			badge.TextColor3 = Theme.Colors.White
			badge.Font = Theme.Fonts.Bold
			badge.TextXAlignment = Enum.TextXAlignment.Center
			badge.Parent = card

			local badgeCorner = Instance.new("UICorner")
			badgeCorner.CornerRadius = UDim.new(0, 4)
			badgeCorner.Parent = badge
		end

		-- Creature name
		local nameY = isActive and 32 or 12
		local nameLabel = UIComponents.createBaseLabel(
			cfg and cfg.displayName or inst.creatureId
		)
		nameLabel.Size = UDim2.new(0.4, 0, 0, 24)
		nameLabel.Position = UDim2.new(0, 12, 0, nameY)
		nameLabel.Font = Theme.Fonts.Bold
		nameLabel.TextSize = 18
		nameLabel.Parent = card

		-- Level label
		local levelLabel = UIComponents.createBaseLabel(
			string.format("Lv. %d", inst.level or 1)
		)
		levelLabel.Size = UDim2.new(0, 70, 0, 22)
		levelLabel.Position = UDim2.new(0, 12, 0, nameY + 26)
		levelLabel.TextSize = 14
		levelLabel.TextColor3 = Theme.Colors.Success
		levelLabel.Parent = card

		-- XP bar
		local lvl = inst.level or 1
		local xp = inst.xp or 0
		local xpFraction = math.clamp(xp / math.max(_xpNeededForLevel(lvl), 1), 0, 1)

		local xpBg = Instance.new("Frame")
		xpBg.Size = UDim2.new(0, 180, 0, 8)
		xpBg.Position = UDim2.new(0, 85, 0, nameY + 33)
		xpBg.BackgroundColor3 = Theme.Colors.Background
		xpBg.BorderSizePixel = 0
		xpBg.Parent = card

		local xpBgCorner = Instance.new("UICorner")
		xpBgCorner.CornerRadius = UDim.new(1, 0)
		xpBgCorner.Parent = xpBg

		local xpFill = Instance.new("Frame")
		xpFill.Size = UDim2.new(xpFraction, 0, 1, 0)
		xpFill.BackgroundColor3 = Theme.Colors.Success
		xpFill.BorderSizePixel = 0
		xpFill.Parent = xpBg

		local xpFillCorner = Instance.new("UICorner")
		xpFillCorner.CornerRadius = UDim.new(1, 0)
		xpFillCorner.Parent = xpFill

		local xpText = UIComponents.createBaseLabel(
			string.format("XP %d/%d", xp, _xpNeededForLevel(lvl))
		)
		xpText.Size = UDim2.new(0, 120, 0, 18)
		xpText.Position = UDim2.new(0, 85, 0, nameY + 43)
		xpText.TextSize = 11
		xpText.TextColor3 = Theme.Colors.Muted
		xpText.Parent = card

		-- ─── Buttons (Ensuring >= 44 px size bounds) ───────────────────────────

		local detailBtn = UIComponents.createBaseButton("Details")
		detailBtn.Size = UDim2.new(0, 94, 0, 44)
		detailBtn.AnchorPoint = Vector2.new(1, 0.5)
		detailBtn.Position = UDim2.new(1, -16, 0.5, 0)
		detailBtn.BackgroundColor3 = Theme.Colors.Primary
		detailBtn.Parent = card
		detailBtn.Activated:Connect(function()
			if onOpenDetail then onOpenDetail(instanceId) end
		end)

		if not isActive then
			local setActiveBtn = UIComponents.createBaseButton("Set Active")
			setActiveBtn.Size = UDim2.new(0, 94, 0, 44)
			setActiveBtn.AnchorPoint = Vector2.new(1, 0.5)
			setActiveBtn.Position = UDim2.new(1, -122, 0.5, 0)
			setActiveBtn.BackgroundColor3 = Theme.Colors.Success
			setActiveBtn.Parent = card
			setActiveBtn.Activated:Connect(function()
				if onSetActive then onSetActive(instanceId) end
			end)
		end
	end

	-- Canvas resize listener
	local layoutConn = layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollArea.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
	end)

	screen.Destroying:Connect(function()
		layoutConn:Disconnect()
	end)

	return screen
end

return CreatureInventoryScreen
