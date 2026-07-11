--[[
	ScreenShake
	Location: src/client/views/ScreenShake.luau
	Handles camera shake feedback using RenderStep binding.
--]]

--// Raw Requirings \\--
--// Requirings \\--
local SkillVfxConfig = require(script.Parent.SkillVfxConfig)

--// Variables \\--
local ScreenShake = {}
local camera = workspace.CurrentCamera

--// Service \\--
local RunService = game:GetService("RunService")

-- Performs a screen shake using a bound render step
function ScreenShake.shake(presetName: string)
	local preset = SkillVfxConfig.ShakePresets[presetName]
	if not preset then
		return
	end

	local intensity = preset.intensity
	local duration = preset.duration
	local startTime = os.clock()
	local shakeId = "CombatScreenShake_" .. tostring(math.random(1, 100000))

	RunService:BindToRenderStep(shakeId, Enum.RenderPriority.Camera.Value + 1, function()
		if not camera then
			camera = workspace.CurrentCamera
		end
		
		local elapsed = os.clock() - startTime
		if elapsed >= duration or not camera then
			RunService:UnbindFromRenderStep(shakeId)
			return
		end

		-- Calculate fade-out factor
		local fade = 1 - (elapsed / duration)
		local currentIntensity = intensity * fade

		-- Generate random offsets
		local offsetX = (math.random() * 2 - 1) * currentIntensity
		local offsetY = (math.random() * 2 - 1) * currentIntensity
		local offsetZ = (math.random() * 2 - 1) * currentIntensity

		camera.CFrame = camera.CFrame * CFrame.new(offsetX, offsetY, offsetZ)
	end)
end

return ScreenShake
