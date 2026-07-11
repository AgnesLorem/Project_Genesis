--[[
	AnimationService
	Location: src/client/views/AnimationService.luau
	Centralized animations and hover effects for Project Genesis UI.
--]]

local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Theme)

local AnimationService = {}

-- Standard Fade In
function AnimationService.fadeIn(instance: GuiObject, duration: number?): Tween
	local dur = duration or Theme.AnimationDuration
	instance.BackgroundTransparency = 1
	local canvasGroup = instance:IsA("CanvasGroup")
	if canvasGroup then
		instance.GroupTransparency = 1
	end

	local targetProp = canvasGroup and "GroupTransparency" or "BackgroundTransparency"
	local info = TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, { [targetProp] = 0 })
	tween:Play()
	return tween
end

-- Standard Fade Out
function AnimationService.fadeOut(instance: GuiObject, duration: number?): Tween
	local dur = duration or Theme.AnimationDuration
	local canvasGroup = instance:IsA("CanvasGroup")
	local targetProp = canvasGroup and "GroupTransparency" or "BackgroundTransparency"

	local info = TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, { [targetProp] = 1 })
	tween:Play()
	return tween
end

-- Standard Slide In
function AnimationService.slideIn(instance: GuiObject, fromPos: UDim2, toPos: UDim2, duration: number?): Tween
	local dur = duration or Theme.AnimationDuration
	instance.Position = fromPos

	local info = TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, { Position = toPos })
	tween:Play()
	return tween
end

-- Standard Slide Out
function AnimationService.slideOut(instance: GuiObject, toPos: UDim2, duration: number?): Tween
	local dur = duration or Theme.AnimationDuration
	local info = TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, { Position = toPos })
	tween:Play()
	return tween
end

-- Scale pop bounce (e.g. for modals and cards)
function AnimationService.scalePop(instance: GuiObject, duration: number?): Tween
	local dur = duration or Theme.AnimationDuration
	local originalSize = instance.Size

	-- Start smaller
	instance.Size = UDim2.new(
		originalSize.X.Scale * 0.9,
		originalSize.X.Offset * 0.9,
		originalSize.Y.Scale * 0.9,
		originalSize.Y.Offset * 0.9
	)

	local info = TweenInfo.new(dur, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, { Size = originalSize })
	tween:Play()
	return tween
end

-- Hover scale and color highlight for buttons
function AnimationService.hoverScale(button: TextButton, originalColor: Color3?, hoverColor: Color3?)
	if button:GetAttribute("HoverScaleRegistered") then
		return function() end
	end
	button:SetAttribute("HoverScaleRegistered", true)

	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local baseSize = button.Size
	local isHovered = false
	local activeTweens = {}

	local function clearTweens()
		for _, tween in ipairs(activeTweens) do
			tween:Cancel()
		end
		table.clear(activeTweens)
	end

	local function getTargetColors()
		local currentBg = button.BackgroundColor3
		if
			currentBg == Theme.Colors.Border
			or currentBg == Theme.Colors.Muted
			or currentBg == Color3.fromRGB(45, 45, 45)
			or not button.Active
		then
			return currentBg, currentBg
		end

		local targetColor
		if currentBg == Theme.Colors.Primary then
			targetColor = Theme.Colors.PrimaryHover
		elseif currentBg == Theme.Colors.Success then
			targetColor = Theme.Colors.SuccessHover
		elseif currentBg == Theme.Colors.Error then
			targetColor = Theme.Colors.ErrorHover
		else
			-- Fallback: slightly brighten the color
			local h, s, v = Color3.toHSV(currentBg)
			targetColor = Color3.fromHSV(h, s, math.min(1, v * 1.2))
		end

		return currentBg, targetColor
	end

	local conn1 = button.MouseEnter:Connect(function()
		local currentBg = button.BackgroundColor3
		-- Disable hover effect completely for disabled/inactive states
		if
			not button.Active
			or currentBg == Theme.Colors.Border
			or currentBg == Theme.Colors.Muted
			or currentBg == Color3.fromRGB(45, 45, 45)
		then
			return
		end

		isHovered = true
		clearTweens()

		local hoverScale = UDim2.new(baseSize.X.Scale, baseSize.X.Offset + 4, baseSize.Y.Scale, baseSize.Y.Offset + 4)

		local _, targetBg = getTargetColors()

		local sizeTween = TweenService:Create(button, info, { Size = hoverScale })
		local colorTween = TweenService:Create(button, info, { BackgroundColor3 = targetBg })

		table.insert(activeTweens, sizeTween)
		table.insert(activeTweens, colorTween)

		sizeTween:Play()
		colorTween:Play()
	end)

	local conn2 = button.MouseLeave:Connect(function()
		if not isHovered then
			return
		end
		isHovered = false
		clearTweens()

		local defaultBg, _ = getTargetColors()

		local sizeTween = TweenService:Create(button, info, { Size = baseSize })
		local colorTween = TweenService:Create(button, info, { BackgroundColor3 = defaultBg })

		table.insert(activeTweens, sizeTween)
		table.insert(activeTweens, colorTween)

		sizeTween:Play()
		colorTween:Play()
	end)

	-- Keep baseSize updated as long as we are not actively hovering/tweening
	local conn3 = button:GetPropertyChangedSignal("Size"):Connect(function()
		if not isHovered then
			baseSize = button.Size
		end
	end)

	-- Return a function to clean up the connections to prevent memory leaks
	return function()
		conn1:Disconnect()
		conn2:Disconnect()
		conn3:Disconnect()
		clearTweens()
	end
end

return AnimationService
