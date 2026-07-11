-- Client-only UI feedback helper. Audio events safely no-op until approved IDs exist.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local VFXHelper = {}
local SOUND_IDS = {}

local function tween(
	instance: Instance,
	duration: number,
	properties: { [string]: any },
	style: Enum.EasingStyle?
): Tween
	local result = TweenService:Create(
		instance,
		TweenInfo.new(duration, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		properties
	)
	result:Play()
	return result
end

local function getScale(guiObject: GuiObject): UIScale
	local existing = guiObject:FindFirstChild("GenesisVFXScale")
	if existing and existing:IsA("UIScale") then
		return existing
	end
	local scale = Instance.new("UIScale")
	scale.Name = "GenesisVFXScale"
	scale.Parent = guiObject
	return scale
end

local function getOverlay(): ScreenGui?
	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then
		return nil
	end
	local existing = playerGui:FindFirstChild("GenesisVFXOverlay")
	if existing and existing:IsA("ScreenGui") then
		return existing
	end
	local overlay = Instance.new("ScreenGui")
	overlay.Name = "GenesisVFXOverlay"
	overlay.DisplayOrder = 2000
	overlay.IgnoreGuiInset = true
	overlay.ResetOnSpawn = false
	overlay.Parent = playerGui
	return overlay
end

function VFXHelper.safePlaySound(eventName: string): Sound?
	local soundId = SOUND_IDS[eventName]
	if not soundId or soundId == "" then
		return nil
	end
	return nil
end

function VFXHelper.pop(guiObject: GuiObject, startScale: number?, duration: number?): Tween?
	if not guiObject or not guiObject.Parent then
		return nil
	end
	local scale = getScale(guiObject)
	scale.Scale = startScale or 0.94
	return tween(scale, duration or 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
end

function VFXHelper.buttonPress(button: GuiButton)
	if button:GetAttribute("VFXPressRegistered") then
		return
	end
	button:SetAttribute("VFXPressRegistered", true)
	local scale = getScale(button)
	local activeTween: Tween? = nil
	local connection = button.Activated:Connect(function()
		if not button.Active or not button.Parent then
			return
		end
		VFXHelper.safePlaySound("button_click")
		if activeTween then
			activeTween:Cancel()
		end
		scale.Scale = 0.96
		activeTween = tween(scale, 0.16, { Scale = 1 }, Enum.EasingStyle.Back)
	end)
	button.Destroying:Once(function()
		connection:Disconnect()
		if activeTween then
			activeTween:Cancel()
		end
	end)
end

function VFXHelper.floatingText(parent: GuiObject, text: string, color: Color3?, options: any?): TextLabel?
	if not parent or not parent.Parent then
		return nil
	end
	options = options or {}
	local label = Instance.new("TextLabel")
	label.Name = "VFXFloatingText"
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.Font = options.font or Enum.Font.GothamBold
	label.Position = UDim2.fromScale(0.5, 0.3)
	label.Size = UDim2.fromOffset(150, 48)
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(255, 95, 95)
	label.TextSize = options.textSize or 32
	label.TextStrokeTransparency = 0.35
	label.ZIndex = parent.ZIndex + 20
	label.Parent = parent
	local animation = TweenService:Create(label, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.1),
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	animation.Completed:Once(function()
		label:Destroy()
	end)
	animation:Play()
	return label
end

function VFXHelper.hitFlash(parent: GuiObject, color: Color3?): Frame?
	if not parent or not parent.Parent then
		return nil
	end
	local flash = Instance.new("Frame")
	flash.Name = "VFXHitFlash"
	flash.BackgroundColor3 = color or Color3.new(1, 1, 1)
	flash.BackgroundTransparency = 0.3
	flash.BorderSizePixel = 0
	flash.Size = UDim2.fromScale(1, 1)
	flash.ZIndex = parent.ZIndex + 15
	flash.Parent = parent
	local animation = TweenService:Create(flash, TweenInfo.new(0.18), { BackgroundTransparency = 1 })
	animation.Completed:Once(function()
		flash:Destroy()
	end)
	animation:Play()
	return flash
end

function VFXHelper.rewardPopup(text: string, color: Color3?): TextLabel?
	local overlay = getOverlay()
	if not overlay then
		return nil
	end
	local label = Instance.new("TextLabel")
	label.Name = "VFXRewardPopup"
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Position = UDim2.fromScale(0.5, 0.24)
	label.Size = UDim2.fromOffset(320, 54)
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(255, 205, 70)
	label.TextSize = 28
	label.TextStrokeTransparency = 0.25
	label.ZIndex = 2001
	label.Parent = overlay
	VFXHelper.pop(label, 0.88, 0.2)
	local fade = tween(label, 0.9, {
		Position = UDim2.fromScale(0.5, 0.17),
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	fade.Completed:Once(function()
		label:Destroy()
	end)
	return label
end

function VFXHelper.skillCastFeedback(text: string?)
	VFXHelper.safePlaySound("skill_cast")
	VFXHelper.rewardPopup(text or "Skill Cast", Color3.fromRGB(120, 190, 255))
end

function VFXHelper.evolutionBurst(text: string?)
	VFXHelper.safePlaySound("evolution_success")
	local popup = VFXHelper.rewardPopup(text or "Evolution Complete", Color3.fromRGB(120, 255, 180))
	if popup then
		VFXHelper.hitFlash(popup, Color3.fromRGB(120, 255, 180))
	end
end

return VFXHelper
