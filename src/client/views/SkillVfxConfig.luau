--[[
	SkillVfxConfig
	Location: src/client/views/SkillVfxConfig.luau
--]]

--// Raw Requirings \\--
--// Requirings \\--
--// Variables \\--
local SkillVfxConfig = {
	Debug = true, -- Toggle detailed console log outputs

	CameraAnchors = {
		Player = Vector3.new(-3, -1.2, -8),
		Enemy = Vector3.new(3, -1.2, -8),
	},

	ShakePresets = {
		light = { intensity = 0.08, duration = 0.15 },
		heavy = { intensity = 0.2, duration = 0.3 },
		ultimate = { intensity = 0.4, duration = 0.5 },
	},

	basic_attack = {
		castTime = 0,
		projectileTime = 0,
		sequence = {
			{
				at = "impact",
				offset = 0,
				asset = "punch_impact",
				scale = 1.0,
				playbackSpeed = 1.2,
				layer = "foreground",
				sound = { id = "rbxassetid://5665639097", volume = 0.5, pitch = 1.0 },
				shake = "light",
				flash = true,
				trigger = "damage",
			},
		},
	},

	verdant_slash = {
		castTime = 0.2,
		projectileTime = 0.2,
		sequence = {
			{
				at = "cast",
				offset = 0,
				asset = "charge_light",
				scale = 0.8,
				layer = "behind",
				sound = { id = "rbxassetid://9112903741", volume = 0.4, pitch = 1.1 },
			},
			{
				at = "projectile",
				offset = 0,
				asset = "slash_wind",
				scale = 1.2,
				layer = "foreground",
				sound = { id = "rbxassetid://9114223157", volume = 0.6, pitch = 1.0 },
			},
			{
				at = "impact",
				offset = 0,
				asset = "slash_impact",
				scale = 1.0,
				layer = "foreground",
				shake = "heavy",
				flash = true,
				trigger = "damage",
			},
		},
	},

	root_guard_passive = {
		castTime = 0.3,
		projectileTime = 0,
		sequence = {
			{
				at = "cast",
				offset = 0,
				asset = "plant_shield",
				scale = 1.0,
				layer = "card",
				sound = { id = "rbxassetid://9112903741", volume = 0.6, pitch = 0.9 },
				trigger = "damage",
			},
		},
	},

	shadow_bolt = {
		castTime = 0.2,
		projectileTime = 0.3,
		sequence = {
			{
				at = "cast",
				offset = 0,
				asset = "charge_light",
				color = Color3.fromRGB(138, 43, 226),
				scale = 0.8,
				layer = "behind",
			},
			{
				at = "projectile",
				offset = 0,
				asset = "fire_bolt",
				color = Color3.fromRGB(138, 43, 226),
				scale = 1.2,
				layer = "foreground",
				sound = { id = "rbxassetid://9113645084", volume = 0.6, pitch = 1.1 },
			},
			{
				at = "impact",
				offset = 0,
				asset = "fire_explosion",
				color = Color3.fromRGB(138, 43, 226),
				scale = 1.0,
				layer = "foreground",
				shake = "light",
				flash = true,
				trigger = "damage",
			},
		},
	},
}

--// Service \\--

return SkillVfxConfig
