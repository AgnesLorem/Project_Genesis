--[[
	VfxPlayer
	Location: src/client/views/VfxPlayer.luau
	Plays and tweens 3D VFX parts relative to the camera viewport using VfxPool.
	Converts 2D card bounds into camera-relative 3D positions using ScreenPointToRay.
	Uses GuiService:GetGuiInset() and LockedToPart=true to ensure perfect alignment.
	Implements the Idempotent Registry pattern for dynamic lifecycles.
--]]

--// Raw Requirings \\--
--// Requirings \\--
local SkillVfxConfig = require(script.Parent.SkillVfxConfig)
local VfxPool = require(script.Parent.VfxPool)

--// Variables \\--
local VfxPlayer = {}
local camera = workspace.CurrentCamera
local activeRegistry = {}

--// Service \\--
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

-- Class representing a tracked VFX lifecycle instance
local VfxInstance = {}
VfxInstance.__index = VfxInstance

function VfxInstance.new(clone: Instance, assetKey: string)
	local self = setmetatable({
		Instance = clone,
		AssetKey = assetKey,
		Connections = {},
		Tasks = {},
		IsDestroyed = false,
	}, VfxInstance)
	return self
end

function VfxInstance:TrackConnection(conn)
	table.insert(self.Connections, conn)
end

function VfxInstance:TrackTask(thread)
	table.insert(self.Tasks, thread)
end

function VfxInstance:Destroy()
	if self.IsDestroyed then return end
	self.IsDestroyed = true

	-- Disconnect all connections
	for _, conn in ipairs(self.Connections) do
		if typeof(conn) == "RBXScriptConnection" and conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(self.Connections)

	-- Cancel all task threads
	for _, thread in ipairs(self.Tasks) do
		if typeof(thread) == "thread" and coroutine.status(thread) ~= "dead" then
			pcall(task.cancel, thread)
		end
	end
	table.clear(self.Tasks)

	-- Destroy the clone to prevent leaks
	if self.Instance then
		self.Instance:Destroy()
		self.Instance = nil
	end
end

-- Recolor particle emitter color sequences
local function applyRecolor(instance: Instance, color: Color3)
	local seq = ColorSequence.new(color)
	for _, desc in ipairs(instance:GetDescendants()) do
		if desc:IsA("ParticleEmitter") then
			desc.Color = seq
		elseif desc:IsA("Light") then
			desc.Color = color
		end
	end
end

-- Adjust particle emitter rate and speed based on playback speed multiplier
local function applyPlaybackSpeed(instance: Instance, speed: number)
	for _, desc in ipairs(instance:GetDescendants()) do
		if desc:IsA("ParticleEmitter") then
			desc.Rate = desc.Rate * speed
			local minSpeed = desc.Speed.Min * speed
			local maxSpeed = desc.Speed.Max * speed
			desc.Speed = NumberRange.new(minSpeed, maxSpeed)
		end
	end
end

-- Lock particles to their parent part so they don't drift in world space
local function applyLockedToPart(instance: Instance)
	for _, desc in ipairs(instance:GetDescendants()) do
		if desc:IsA("ParticleEmitter") then
			desc.LockedToPart = true
		end
	end
end

-- Helper to convert 2D card center to 3D world space immediately in front of the camera using ScreenPointToRay
local function getCardWorldPosition(card: Frame, depth: number): Vector3
	if not camera then
		camera = workspace.CurrentCamera
	end
	
	local center = card.AbsolutePosition + card.AbsoluteSize / 2
	local inset = GuiService:GetGuiInset()
	
	-- Subtract top bar offset to get screen-space coordinates
	local screenX = center.X - inset.X
	local screenY = center.Y - inset.Y
	
	local ray = camera:ScreenPointToRay(screenX, screenY)
	return ray.Origin + ray.Direction.Unit * depth
end

-- Helper to calculate the 3D size in studs that corresponds to a 2D card's pixel size
local function getCardWorldSize(card: Frame, depth: number): Vector3
	if not camera then
		camera = workspace.CurrentCamera
	end
	local fov = camera.FieldOfView
	local viewportSize = camera.ViewportSize
	
	-- Height and width of the camera frustum at the given depth
	local heightStuds = 2 * depth * math.tan(math.rad(fov) / 2)
	local widthStuds = heightStuds * (viewportSize.X / viewportSize.Y)
	
	-- Conversion factor from pixels to studs
	local studsPerPixelX = widthStuds / viewportSize.X
	local studsPerPixelY = heightStuds / viewportSize.Y
	
	return Vector3.new(
		card.AbsoluteSize.X * studsPerPixelX,
		card.AbsoluteSize.Y * studsPerPixelY,
		card.AbsoluteSize.X * studsPerPixelX
	)
end

-- Clear all active VFX (Idempotent Registry teardown)
function VfxPlayer.clearAllActiveVfx()
	for _, vfxInst in ipairs(activeRegistry) do
		vfxInst:Destroy()
	end
	table.clear(activeRegistry)
end

-- Plays a single VFX step config projected onto 2D UI cards
function VfxPlayer.playStep(stepConfig: any, actorCard: Frame, targetCard: Frame, projectileTime: number?)
	if not camera then
		camera = workspace.CurrentCamera
	end

	local assetKey = stepConfig.asset
	local clone = VfxPool.Acquire(assetKey)
	if not clone then
		return
	end

	-- Create registry tracking instance
	local vfxInst = VfxInstance.new(clone, assetKey)
	table.insert(activeRegistry, vfxInst)

	-- Retrieve configured depth (between 8 and 10 studs to avoid Clip Plane clipping)
	local depth = 9.0 -- default depth in front of camera
	if stepConfig.layer == "behind" then
		depth = 10.0
	elseif stepConfig.layer == "foreground" then
		depth = 8.0
	end

	-- Lock particles to the part to prevent them from drifting when camera rotates
	applyLockedToPart(clone)

	-- Calculate dynamic size in studs to match the 2D card size on screen
	local targetCardSize = getCardWorldSize(targetCard, depth)
	local actorCardSize = getCardWorldSize(actorCard, depth)

	-- Apply configuration modifiers
	if clone:IsA("Part") then
		local baseCardSize = (stepConfig.at == "cast") and actorCardSize or targetCardSize
		clone.Size = baseCardSize * (stepConfig.scale or 1.0)
	end
	
	if stepConfig.color then
		applyRecolor(clone, stepConfig.color)
	end

	if stepConfig.playbackSpeed then
		applyPlaybackSpeed(clone, stepConfig.playbackSpeed)
	end

	clone.Parent = workspace
	
	local cameraRotation = camera.CFrame - camera.CFrame.Position

	if stepConfig.at == "cast" then
		if clone:IsA("Part") then
			local worldPos = getCardWorldPosition(actorCard, depth)
			clone.CFrame = CFrame.new(worldPos) * cameraRotation
		end
	elseif stepConfig.at == "impact" then
		if clone:IsA("Part") then
			local worldPos = getCardWorldPosition(targetCard, depth)
			clone.CFrame = CFrame.new(worldPos) * cameraRotation
		end
	elseif stepConfig.at == "projectile" then
		-- Tween from actor card position to target card position
		local startPos = getCardWorldPosition(actorCard, depth)
		local endPos = getCardWorldPosition(targetCard, depth)
		
		if clone:IsA("Part") then
			clone.CFrame = CFrame.new(startPos) * cameraRotation
			
			local duration = projectileTime or 0.2
			local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(clone, info, { CFrame = CFrame.new(endPos) * cameraRotation })
			
			-- Track the tween task
			local tweenThread = task.spawn(function()
				tween:Play()
				tween.Completed:Wait()
			end)
			vfxInst:TrackTask(tweenThread)
		end
	end

	-- Safe cleanup task
	local cleanupThread = task.spawn(function()
		task.wait(0.5)
		if vfxInst.IsDestroyed then return end
		-- Disable emitters
		for _, desc in ipairs(clone:GetDescendants()) do
			if desc:IsA("ParticleEmitter") or desc:IsA("Beam") or desc:IsA("Trail") then
				desc.Enabled = false
			end
		end

		task.wait(1.5)
		if vfxInst.IsDestroyed then return end
		
		-- Remove from active registry
		local idx = table.find(activeRegistry, vfxInst)
		if idx then table.remove(activeRegistry, idx) end
		
		-- Release back to pool
		VfxPool.Release(clone, assetKey)
	end)
	
	vfxInst:TrackTask(cleanupThread)
end

return VfxPlayer
