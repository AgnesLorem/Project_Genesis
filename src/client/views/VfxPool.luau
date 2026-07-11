--[[
	VfxPool
	Location: src/client/views/VfxPool.luau
	Object pool for 3D VFX assets to optimize memory and CPU performance.
--]]

--// Raw Requirings \\--
--// Requirings \\--
local VfxAssetRegistry = require(script.Parent.VfxAssetRegistry)

--// Variables \\--
local VfxPool = {}
local poolFolder: Folder = nil
local activeCount = 0
local MAX_TOTAL_VFX = 25
local pooledInstances: { [string]: { Instance } } = {}

--// Service \\--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Initialize pool folder in ReplicatedStorage
local function getPoolFolder(): Folder
	if not poolFolder then
		poolFolder = Instance.new("Folder")
		poolFolder.Name = "VfxPoolCache"
		poolFolder.Parent = ReplicatedStorage
	end
	return poolFolder
end

-- Safely resolves a dot-separated path string into a Roblox Instance
local function resolvePath(path: string): Instance?
	local parts = string.split(path, ".")
	local current: Instance = game
	for _, part in ipairs(parts) do
		current = current:FindFirstChild(part)
		if not current then
			return nil
		end
	end
	return current
end

-- Helper to enable/disable emitters, beams, and trails
local function setVfxState(instance: Instance, enabled: boolean)
	for _, desc in ipairs(instance:GetDescendants()) do
		if desc:IsA("ParticleEmitter") or desc:IsA("Beam") or desc:IsA("Trail") then
			desc.Enabled = enabled
		end
	end
end

-- Acquires a VFX instance for the given asset key
function VfxPool.Acquire(assetKey: string): Instance?
	local path = VfxAssetRegistry[assetKey] or VfxAssetRegistry.fallback_vfx
	local original = resolvePath(path)
	
	if not original then
		warn(string.format("[VfxPool] Failed to resolve path for asset key '%s' (path: '%s')", tostring(assetKey), tostring(path)))
		-- Try fallback
		original = resolvePath(VfxAssetRegistry.fallback_vfx)
		if not original then
			error("[VfxPool] Critical error: Fallback VFX asset not found in Workspace!")
		end
	end

	local cacheList = pooledInstances[assetKey]
	if cacheList and #cacheList > 0 then
		local instance = table.remove(cacheList)
		setVfxState(instance, true)
		activeCount += 1
		return instance
	end

	-- Under budget or fallback cloning
	local instance = original:Clone()
	setVfxState(instance, true)
	activeCount += 1
	return instance
end

-- Releases a VFX instance back to the pool
function VfxPool.Release(instance: Instance, assetKey: string)
	if not instance then return end
	
	activeCount = math.max(0, activeCount - 1)
	setVfxState(instance, false)

	-- If we exceed the MAX_TOTAL_VFX budget, destroy the instance instead of caching it
	local cacheList = pooledInstances[assetKey]
	if not cacheList then
		cacheList = {}
		pooledInstances[assetKey] = cacheList
	end

	if activeCount + #cacheList >= MAX_TOTAL_VFX then
		instance:Destroy()
	else
		instance.Parent = getPoolFolder()
		table.insert(cacheList, instance)
	end
end

return VfxPool
