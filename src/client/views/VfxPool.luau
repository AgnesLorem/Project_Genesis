--[[
	VfxPool
	Bounded pool for code-generated combat VFX.
--]]

local VfxAssetRegistry = require(script.Parent.VfxAssetRegistry)

local VfxPool = {}
local MAX_TOTAL_VFX = 25
local activeCount = 0
local pooledCount = 0
local pooledInstances: { [string]: { Instance } } = {}
local activeInstances: { [Instance]: string } = {}
local originalStates: { [Instance]: { [Instance]: { [string]: any } } } = {}

local RESET_PROPERTIES = {
	Frame = { "Size", "Position", "Rotation", "BackgroundColor3", "BackgroundTransparency", "Visible" },
	UIStroke = { "Color", "Thickness", "Transparency", "Enabled" },
	ParticleEmitter = { "Rate", "Speed", "Color", "Size", "Transparency", "LightEmission", "Lifetime", "Enabled" },
	Beam = { "Color", "Transparency", "LightEmission", "Enabled" },
	Trail = { "Color", "Transparency", "LightEmission", "Lifetime", "Enabled" },
}

local function captureState(root: Instance)
	local state = {}
	local descendants = root:GetDescendants()
	table.insert(descendants, root)
	for _, item in ipairs(descendants) do
		local propertyNames = RESET_PROPERTIES[item.ClassName]
		if propertyNames then
			local properties = {}
			for _, propertyName in ipairs(propertyNames) do
				properties[propertyName] = item[propertyName]
			end
			state[item] = properties
		end
	end
	originalStates[root] = state
end

local function restoreState(root: Instance)
	local state = originalStates[root]
	if not state then
		return
	end
	for item, properties in pairs(state) do
		if item.Parent or item == root then
			for propertyName, value in pairs(properties) do
				item[propertyName] = value
			end
		end
	end
end

local function createEffect(assetKey: string): Frame
	local config = VfxAssetRegistry[assetKey] or VfxAssetRegistry.fallback_vfx
	local frame = Instance.new("Frame")
	frame.Name = "CombatVfx_" .. assetKey
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = config.color
	frame.BackgroundTransparency = 0.18
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromOffset(54, 54)
	frame.ZIndex = 40
	frame:SetAttribute("VfxAssetKey", assetKey)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = config.shape == "slash" and UDim.new(0, 5) or UDim.new(1, 0)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Name = "EffectStroke"
	stroke.Color = config.color:Lerp(Color3.new(1, 1, 1), 0.55)
	stroke.Thickness = config.shape == "shield" and 5 or 3
	stroke.Transparency = 0.05
	stroke.Parent = frame

	if config.shape == "ring" or config.shape == "shield" then
		frame.BackgroundTransparency = 0.75
	elseif config.shape == "slash" then
		frame.Size = UDim2.fromOffset(74, 16)
		frame.Rotation = -25
	elseif config.shape == "burst" then
		frame.Rotation = 45
	end

	return frame
end

function VfxPool.Acquire(assetKey: string): Instance?
	if activeCount >= MAX_TOTAL_VFX then
		return nil
	end

	local cacheList = pooledInstances[assetKey]
	local instance = cacheList and table.remove(cacheList) or nil
	if instance then
		pooledCount -= 1
		restoreState(instance)
	else
		instance = createEffect(assetKey)
		captureState(instance)
	end

	activeInstances[instance] = assetKey
	activeCount += 1
	return instance
end

function VfxPool.Release(instance: Instance)
	local assetKey = activeInstances[instance]
	if not assetKey then
		return
	end

	activeInstances[instance] = nil
	activeCount -= 1
	restoreState(instance)
	instance.Parent = nil

	local cacheList = pooledInstances[assetKey]
	if not cacheList then
		cacheList = {}
		pooledInstances[assetKey] = cacheList
	end
	table.insert(cacheList, instance)
	pooledCount += 1
end

function VfxPool.GetStats()
	return {
		activeCount = activeCount,
		pooledCount = pooledCount,
		maxTotalVfx = MAX_TOTAL_VFX,
	}
end

return VfxPool
