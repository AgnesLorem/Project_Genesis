--[[
	CollectionBookScreen
	Location: src/client/views/CollectionBookScreen.luau

	Displays discovered/undiscovered creatures in a paginated grid.
	Responsive layout and Theme token support.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local AnimationService = require(script.Parent.AnimationService)

local CollectionBookScreen = {}

local CARD_W = 160
local CARD_H = 120
local PADDING = 12

function CollectionBookScreen.create(collectionData: any, publicConfigs: any, onClose: () -> ()): Frame
	local screen = UIComponents.createBaseContainer()
	screen.Name = "CollectionBookScreen"

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

	local title = UIComponents.createBaseLabel(
		string.format("📖 Collection  %d / %d", collectionData.completionCount or 0, collectionData.total or 0)
	)
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

	-- ─── Scrollable Grid ─────────────────────────────────────────────────────────

	local scrollArea = Instance.new("ScrollingFrame")
	scrollArea.Name = "GridScroll"
	scrollArea.Size = UDim2.new(1, 0, 1, -64)
	scrollArea.Position = UDim2.new(0, 0, 0, 64)
	scrollArea.BackgroundTransparency = 1
	scrollArea.BorderSizePixel = 0
	scrollArea.ScrollBarThickness = 6
	scrollArea.ScrollBarImageColor3 = Theme.Colors.Border
	scrollArea.Parent = panel

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, CARD_W, 0, CARD_H)
	grid.CellPadding = UDim2.new(0, PADDING, 0, PADDING)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
	grid.VerticalAlignment = Enum.VerticalAlignment.Top
	grid.Parent = scrollArea

	-- Sort creatures by sortOrder, then creatureId
	local sortedIds = {}
	for creatureId, _ in pairs(collectionData.entries or {}) do
		table.insert(sortedIds, creatureId)
	end
	-- Include any in publicConfigs not yet in entries (future creatures)
	for creatureId, _ in pairs(publicConfigs or {}) do
		if not collectionData.entries or collectionData.entries[creatureId] == nil then
			table.insert(sortedIds, creatureId)
		end
	end
	table.sort(sortedIds, function(a, b)
		local pa = publicConfigs and publicConfigs[a] and publicConfigs[a].sortOrder or 999
		local pb = publicConfigs and publicConfigs[b] and publicConfigs[b].sortOrder or 999
		if pa ~= pb then
			return pa < pb
		end
		return a < b
	end)

	for _, creatureId in ipairs(sortedIds) do
		local discovered = collectionData.entries and collectionData.entries[creatureId] == true
		local cfg = publicConfigs and publicConfigs[creatureId]

		local card = UIComponents.createBasePanel()
		card.Name = "Card_" .. creatureId
		card.Parent = scrollArea

		local rarity = "Common"
		if cfg and cfg.collectionCategory == "epic" then
			rarity = "Legendary"
		elseif cfg and cfg.collectionCategory == "rare" then
			rarity = "Rare"
		end

		UIComponents.applyRarityBorder(card, rarity)

		-- Active outline highlight
		if discovered then
			UIComponents.applySelectionOutline(card)
		end

		-- Art placeholder
		local artFrame = UIComponents.createBasePanel()
		artFrame.Name = "ArtPlaceholder"
		artFrame.Size = UDim2.new(1, -16, 0, 60)
		artFrame.Position = UDim2.new(0, 8, 0, 8)
		artFrame.Parent = card

		local artLabel = Instance.new("TextLabel")
		artLabel.Size = UDim2.new(1, 0, 1, 0)
		artLabel.BackgroundTransparency = 1
		artLabel.Text = discovered and "🦎" or "❓"
		artLabel.TextScaled = true
		artLabel.Font = Theme.Fonts.Bold
		artLabel.TextColor3 = discovered and Theme.Colors.White or Theme.Colors.Muted
		artLabel.Parent = artFrame

		-- Name
		local nameLabel = UIComponents.createBaseLabel(discovered and (cfg and cfg.displayName or creatureId) or "???")
		nameLabel.Size = UDim2.new(1, -8, 0, 24)
		nameLabel.Position = UDim2.new(0, 4, 0, 72)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Center
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = discovered and Theme.Colors.White or Theme.Colors.Muted
		nameLabel.Parent = card

		-- Rarity tag
		if cfg then
			local rarityLabel = UIComponents.createBaseLabel(discovered and cfg.collectionCategory or "")
			rarityLabel.Size = UDim2.new(1, -8, 0, 18)
			rarityLabel.Position = UDim2.new(0, 4, 0, 96)
			rarityLabel.TextXAlignment = Enum.TextXAlignment.Center
			rarityLabel.TextSize = 11
			rarityLabel.TextColor3 = Theme.Colors.Muted
			rarityLabel.Parent = card
		end
	end

	-- Update canvas height after grid fills
	local gridConn = grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollArea.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + PADDING)
	end)

	screen.Destroying:Connect(function()
		gridConn:Disconnect()
	end)

	-- Empty state
	if #sortedIds == 0 then
		local emptyLabel = UIComponents.createBaseLabel("No creatures to display.")
		emptyLabel.Size = UDim2.new(1, 0, 0, 40)
		emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
		emptyLabel.TextSize = 20
		emptyLabel.TextColor3 = Theme.Colors.Muted
		emptyLabel.Parent = scrollArea
	end

	return screen
end

return CollectionBookScreen
