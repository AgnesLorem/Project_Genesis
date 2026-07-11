--[[
	BattleResultModal
	Location: src/client/views/BattleResultModal.luau

	Displays the outcome of a story battle with timeline logs, rewards details,
	and Theme token styling.
--]]

local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local AnimationService = require(script.Parent.AnimationService)

local BattleResultModal = {}

local function formatTimelineEntry(entry: any): string?
	if type(entry) ~= "table" then
		return nil
	end

	-- Support existing explicit entry.text
	if type(entry.text) == "string" and entry.text ~= "" then
		return entry.text
	end

	local turnStr = entry.turn and string.format("Turn %d: ", entry.turn) or ""
	local eventType = entry.type
	local data = entry.data

	if type(data) ~= "table" then
		if type(eventType) == "string" then
			return string.format("%sEvent: %s", turnStr, eventType)
		end
		return nil
	end

	local actorId = tostring(data.actorId or "Unknown")
	local targetId = tostring(data.targetId or "Unknown")
	local damage = tonumber(data.damage) or 0
	local targetHp = tonumber(data.targetHp) or 0
	local healing = tonumber(data.healing) or 0
	local shield = tonumber(data.shield) or 0
	local skillId = tostring(data.skillId or "basic attack")

	if eventType == "skill_use" then
		if healing > 0 then
			return string.format(
				"%s%s used %s on %s, healing %d HP (Remaining HP: %d)",
				turnStr,
				actorId,
				skillId,
				targetId,
				healing,
				targetHp
			)
		elseif shield > 0 then
			return string.format("%s%s used %s on %s, granting %d shield", turnStr, actorId, skillId, targetId, shield)
		else
			return string.format(
				"%s%s used %s on %s dealing %d damage (Remaining HP: %d)",
				turnStr,
				actorId,
				skillId,
				targetId,
				damage,
				targetHp
			)
		end
	elseif eventType == "fallback_attack" then
		return string.format(
			"%s%s used basic attack on %s dealing %d damage (Remaining HP: %d)",
			turnStr,
			actorId,
			targetId,
			damage,
			targetHp
		)
	elseif eventType == "heal" then
		return string.format("%s%s healed %s for %d HP", turnStr, actorId, targetId, healing)
	elseif eventType == "shield" then
		return string.format("%s%s granted %d shield to %s", turnStr, actorId, shield, targetId)
	elseif eventType == "buff" or eventType == "debuff" then
		local effectId = tostring(data.effectId or "effect")
		return string.format("%s%s applied %s to %s", turnStr, actorId, effectId, targetId)
	elseif eventType == "turn_transition" then
		return string.format("--- Turn %d ---", entry.turn or 0)
	elseif eventType == "victory" or eventType == "defeat" then
		return string.format("Outcome: %s", string.upper(eventType))
	else
		if type(eventType) == "string" then
			return string.format("%sEvent %s by %s on %s", turnStr, eventType, actorId, targetId)
		end
	end

	return nil
end

function BattleResultModal.create(battleData: any, onClose: () -> ()): Frame
	local modal = UIComponents.createBaseModal()

	local panel = UIComponents.createBasePanel()
	panel.Size = UDim2.new(0, 620, 0, 480)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.ZIndex = Theme.ZIndex.Modal + 1
	panel.Parent = modal

	-- Header: VICTORY or DEFEAT
	local resultText = (battleData.isVictory == true) and "⚔ VICTORY" or "💀 DEFEAT"
	local header = UIComponents.createBaseLabel(resultText)
	header.Size = UDim2.new(1, 0, 0, 50)
	header.Font = Theme.Fonts.Header
	header.TextXAlignment = Enum.TextXAlignment.Center
	header.TextSize = 30
	header.ZIndex = Theme.ZIndex.Modal + 2

	if battleData.isVictory then
		header.TextColor3 = Theme.Colors.Success
	else
		header.TextColor3 = Theme.Colors.Error
	end
	header.Parent = panel

	-- Rewards summary
	local rewardText = string.format(
		"Biomass: +%d   XP: +%d",
		battleData.rewards and battleData.rewards.biomass or 0,
		battleData.xpGained or 0
	)
	if battleData.creatureUpdates and battleData.creatureUpdates.leveledUp then
		rewardText = rewardText .. "   [LEVEL UP → Lv." .. tostring(battleData.creatureUpdates.level) .. "]"
	end
	local rewardLabel = UIComponents.createBaseLabel(rewardText)
	rewardLabel.Size = UDim2.new(1, -40, 0, 28)
	rewardLabel.Position = UDim2.new(0, 20, 0, 52)
	rewardLabel.Font = Theme.Fonts.Bold
	rewardLabel.TextXAlignment = Enum.TextXAlignment.Center
	rewardLabel.TextSize = 16
	rewardLabel.TextColor3 = Theme.Colors.Accent
	rewardLabel.ZIndex = Theme.ZIndex.Modal + 2
	rewardLabel.Parent = panel

	-- Timeline scroll
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -40, 1, -150)
	scroll.Position = UDim2.new(0, 20, 0, 90)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Theme.Colors.Border
	scroll.ZIndex = Theme.ZIndex.Modal + 2
	scroll.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = scroll

	if battleData.timeline then
		for _, entry in ipairs(battleData.timeline) do
			local logText = formatTimelineEntry(entry)
			if logText then
				local label = UIComponents.createBaseLabel(logText)
				label.Size = UDim2.new(1, -10, 0, 20)
				label.Font = Theme.Fonts.Regular
				label.TextSize = 13
				label.TextColor3 = Theme.Colors.White
				label.ZIndex = Theme.ZIndex.Modal + 2
				label.Parent = scroll
			end
		end
	end

	local layoutConn = layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	modal.Destroying:Connect(function()
		layoutConn:Disconnect()
	end)

	-- Close button
	local btn = UIComponents.createBaseButton("Close")
	btn.Name = "ContinueButton"
	btn.AnchorPoint = Vector2.new(0.5, 1)
	btn.Position = UDim2.new(0.5, 0, 1, -16)
	btn.BackgroundColor3 = Theme.Colors.Success
	btn.ZIndex = Theme.ZIndex.Modal + 2
	btn.Parent = panel

	btn.Activated:Connect(onClose)

	-- Open Transition animation
	AnimationService.scalePop(panel)

	return modal
end

return BattleResultModal
