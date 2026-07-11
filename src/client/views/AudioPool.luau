--[[
	AudioPool
	Location: src/client/views/AudioPool.luau
	Object pool for Sound instances to optimize game performance and prevent GC spikes.
--]]

--// Raw Requirings \\--
--// Requirings \\--
--// Variables \\--
local AudioPool = {}
local poolFolder: Folder = nil
local pooledSounds: { [string]: { Sound } } = {}

--// Service \\--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- Get pool folder under ReplicatedStorage
local function getPoolFolder(): Folder
	if not poolFolder then
		poolFolder = Instance.new("Folder")
		poolFolder.Name = "AudioPoolCache"
		poolFolder.Parent = ReplicatedStorage
	end
	return poolFolder
end

-- Acquires a sound instance
function AudioPool.Acquire(soundId: string): Sound
	local list = pooledSounds[soundId]
	if list and #list > 0 then
		local sound = table.remove(list)
		sound.Parent = SoundService
		return sound
	end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Parent = SoundService
	return sound
end

-- Releases a sound instance
function AudioPool.Release(sound: Sound, soundId: string)
	if not sound then
		return
	end
	sound:Stop()
	sound.Parent = getPoolFolder()

	local list = pooledSounds[soundId]
	if not list then
		list = {}
		pooledSounds[soundId] = list
	end
	table.insert(list, sound)
end

return AudioPool
