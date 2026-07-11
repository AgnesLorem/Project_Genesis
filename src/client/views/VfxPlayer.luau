--[[
	VfxPlayer
	Plays pooled 2D effects inside the combat UI.
--]]

local TweenService = game:GetService("TweenService")

local VfxPool = require(script.Parent.VfxPool)

local VfxPlayer = {}
local activeRegistry = {}

local function cardsAreValid(actorCard: GuiObject?, targetCard: GuiObject?): boolean
	return actorCard ~= nil and targetCard ~= nil and actorCard.Parent ~= nil and targetCard.Parent ~= nil
end

local function cardCenterInParent(card: GuiObject, parent: GuiObject): UDim2
	local center = card.AbsolutePosition + card.AbsoluteSize / 2 - parent.AbsolutePosition
	return UDim2.fromOffset(center.X, center.Y)
end

local function scaleSize(size: UDim2, scale: number): UDim2
	return UDim2.new(size.X.Scale * scale, size.X.Offset * scale, size.Y.Scale * scale, size.Y.Offset * scale)
end

local function releaseEntry(entry)
	if entry.released then
		return
	end
	entry.released = true
	if entry.tween then
		entry.tween:Cancel()
	end
	activeRegistry[entry] = nil
	VfxPool.Release(entry.instance)
end

function VfxPlayer.clearAllActiveVfx()
	local entries = {}
	for entry in pairs(activeRegistry) do
		table.insert(entries, entry)
	end
	for _, entry in ipairs(entries) do
		releaseEntry(entry)
	end
end

function VfxPlayer.playStep(stepConfig: any, actorCard: GuiObject, targetCard: GuiObject, projectileTime: number?)
	if not cardsAreValid(actorCard, targetCard) then
		return
	end

	local instance = VfxPool.Acquire(stepConfig.asset)
	if not instance or not instance:IsA("GuiObject") then
		return
	end

	local entry = { instance = instance, tween = nil, released = false }
	activeRegistry[entry] = true
	local parent = targetCard
	local startPosition = UDim2.fromScale(0.5, 0.5)
	local endPosition = startPosition

	if stepConfig.at == "cast" then
		parent = actorCard
	elseif stepConfig.at == "projectile" then
		local commonParent = actorCard.Parent
		if not commonParent or commonParent ~= targetCard.Parent or not commonParent:IsA("GuiObject") then
			releaseEntry(entry)
			return
		end
		parent = commonParent
		startPosition = cardCenterInParent(actorCard, commonParent)
		endPosition = cardCenterInParent(targetCard, commonParent)
	end

	if not cardsAreValid(actorCard, targetCard) or not parent.Parent then
		releaseEntry(entry)
		return
	end

	instance.Position = startPosition
	instance.Size = scaleSize(instance.Size, stepConfig.scale or 1)
	if stepConfig.color then
		instance.BackgroundColor3 = stepConfig.color
		local stroke = instance:FindFirstChild("EffectStroke")
		if stroke and stroke:IsA("UIStroke") then
			stroke.Color = stepConfig.color:Lerp(Color3.new(1, 1, 1), 0.55)
		end
	end
	instance.Parent = parent

	local duration = stepConfig.at == "projectile" and (projectileTime or 0.2) or 0.35
	duration /= math.max(stepConfig.playbackSpeed or 1, 0.1)
	local goal = {
		Position = endPosition,
		Size = scaleSize(instance.Size, 1.45),
		BackgroundTransparency = 1,
		Rotation = instance.Rotation + 35,
	}
	local tween =
		TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
	entry.tween = tween
	tween.Completed:Once(function()
		releaseEntry(entry)
	end)
	tween:Play()

	task.delay(duration + 0.25, function()
		releaseEntry(entry)
	end)
end

function VfxPlayer.getPoolStats()
	return VfxPool.GetStats()
end

return VfxPlayer
