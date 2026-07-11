--[[
	FloatingText
	Location: src/client/views/FloatingText.luau
	Handles floating numbers (damage, heal, shield, miss, crit) overlayed on cards.
--]]

--// Raw Requirings \\--
--// Requirings \\--
local Theme = require(script.Parent.Theme)

--// Variables \\--
local FloatingText = {}

--// Service \\--
local TweenService = game:GetService("TweenService")

-- Shows a floating text overlay on the specified card
function FloatingText.show(card: Frame, textType: string, amountOrText: any)
	if not card or not card.Parent then return end

	local label = Instance.new("TextLabel")
	label.Name = "FloatingTextLabel"
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0, 200, 0, 40)
	-- Start centered vertically and horizontally over the card
	label.Position = UDim2.new(0.5, -100, 0.3, 0)
	label.Font = Theme.Fonts.Bold
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = card.ZIndex + 15
	label.Parent = card

	-- Determine styling
	local textColor = Theme.Colors.White
	local textSize = 32
	local displayText = tostring(amountOrText)

	if textType == "damage" then
		textColor = Theme.Colors.Error
		textSize = 36
		displayText = "-" .. tostring(amountOrText)
	elseif textType == "critical" then
		textColor = Theme.Colors.Accent
		textSize = 48
		displayText = "💥 -" .. tostring(amountOrText) .. "!"
	elseif textType == "heal" then
		textColor = Theme.Colors.Success
		textSize = 36
		displayText = "+" .. tostring(amountOrText)
	elseif textType == "shield" then
		textColor = Theme.Colors.Primary
		textSize = 36
		displayText = "🛡️ +" .. tostring(amountOrText)
	elseif textType == "miss" then
		textColor = Theme.Colors.Muted
		textSize = 32
		displayText = "MISS"
	elseif textType == "dodge" then
		textColor = Theme.Colors.Muted
		textSize = 32
		displayText = "DODGE"
	elseif textType == "buff" then
		textColor = Theme.Colors.Accent
		textSize = 30
		displayText = "▲ " .. tostring(amountOrText)
	elseif textType == "debuff" then
		textColor = Theme.Colors.Warning
		textSize = 30
		displayText = "▼ " .. tostring(amountOrText)
	end

	label.TextColor3 = textColor
	label.TextSize = textSize
	label.Text = displayText

	-- Animate float up and fade out using TweenService
	local floatInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenPosition = TweenService:Create(label, floatInfo, {
		Position = UDim2.new(0.5, -100, 0.05, 0)
	})
	local tweenFade = TweenService:Create(label, floatInfo, {
		TextTransparency = 1
	})

	tweenPosition.Completed:Connect(function()
		label:Destroy()
	end)

	tweenPosition:Play()
	tweenFade:Play()
end

return FloatingText
