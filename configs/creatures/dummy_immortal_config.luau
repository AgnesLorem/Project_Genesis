--[[
	Dummy Immortal Config
	Location: configs/creatures/dummy_immortal_config.luau
--]]

return {
	id = "dummy_immortal",
	creatureId = "dummy_immortal",
	schemaVersion = 2,
	displayName = "Immortal Dummy",
	rarity = "Legend", -- Match valid schema rarity
	elementType = "Neutral",
	description = "An immortal dummy used for testing combat effects.",
	placeholderArtSlot = "creature_common_terra_001",
	evolutionTarget = "",
	baseStats = {
		hp = 9999999,
		atk = 0, -- Deal 0 damage to player
		def = 99999, -- Take minimal damage
		spd = 1, -- Very slow turns
	},
	skillIds = { "basic_attack" },
	geneSlots = {},
	evolutionLineId = "evolution_line_dummy",
	collectionCategory = "creature",
	visualRef = "visual_dummy",
	sortOrder = 99,
	isEnabled = true,
}
