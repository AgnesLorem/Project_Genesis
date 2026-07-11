--[[
	VfxAssetRegistry
	Location: src/client/views/VfxAssetRegistry.luau
--]]

--// Raw Requirings \\--
--// Requirings \\--
--// Variables \\--
local VfxAssetRegistry = {
	charge_light = "Workspace.VFX_Priority.Anime.Charge-01",
	punch_impact = "Workspace.VFX_Priority.Anime.Punch-01",
	slash_wind = "Workspace.VFX_Priority.Anime.Slashes-01",
	slash_impact = "Workspace.VFX_Priority.Anime.Slash-Impact-01",
	fire_bolt = "Workspace.VFX_Priority.Anime.Fire-01",
	fire_explosion = "Workspace.VFX_Priority.Anime.Explosion-01",
	plant_shield = "Workspace.VFX_Priority.Anime.Shield-01",
	
	-- Fallbacks
	fallback_vfx = "Workspace.VFX.Circle",
}

--// Service \\--

return VfxAssetRegistry
