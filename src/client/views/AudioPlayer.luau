--[[
	AudioPlayer
	Location: src/client/views/AudioPlayer.luau
	Plays sound assets using AudioPool with custom volume and pitch modifiers.
--]]

--// Raw Requirings \\--
--// Requirings \\--
local AudioPool = require(script.Parent.AudioPool)

--// Variables \\--
local AudioPlayer = {}

--// Service \\--

-- Plays a sound configuration
function AudioPlayer.play(soundConfig: any)
	if not soundConfig or not soundConfig.id then
		return
	end

	local soundId = soundConfig.id
	local volume = soundConfig.volume or 0.5
	local pitch = soundConfig.pitch or 1.0

	local sound = AudioPool.Acquire(soundId)
	sound.Volume = volume
	sound.PlaybackSpeed = pitch
	sound:Play()

	local connection
	local released = false

	local function releaseSound()
		if released then
			return
		end
		released = true
		if connection then
			connection:Disconnect()
		end
		AudioPool.Release(sound, soundId)
	end

	connection = sound.Ended:Connect(releaseSound)

	-- Fallback timeout safety (5 seconds max duration per play event)
	task.delay(5.0, releaseSound)
end

return AudioPlayer
