--[[
	HitFlash
	Location: src/client/views/HitFlash.luau
	Flashes a 2D UI Card container on hit.
--]]

--// Raw Requirings \\--
--// Requirings \\--
local Theme = require(script.Parent.Theme)

--// Variables \\--
local HitFlash = {}

--// Service \\--
local TweenService = game:GetService("TweenService")

-- Performs a hit flash overlay on the specified card
function HitFlash.flash(card: Frame)
	if not card or not card.Parent then
		return
	end

	local flashFrame = Instance.new("Frame")
	flashFrame.Name = "HitFlashOverlay"
	flashFrame.Size = UDim2.new(1, 0, 1, 0)
	flashFrame.BackgroundColor3 = Theme.Colors.White
	flashFrame.BackgroundTransparency = 0.2
	flashFrame.BorderSizePixel = 0
	flashFrame.ZIndex = card.ZIndex + 10
	flashFrame.Parent = card

	local cardCorner = card:FindFirstChildOfClass("UICorner")
	if cardCorner then
		local cornerClone = cardCorner:Clone()
		cornerClone.Parent = flashFrame
	end

	local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(flashFrame, info, { BackgroundTransparency = 1 })

	tween.Completed:Connect(function()
		flashFrame:Destroy()
	end)
	tween:Play()
end

return HitFlash
