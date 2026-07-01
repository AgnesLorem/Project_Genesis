-- Bio Generator Config
-- Location: ServerStorage/Configs/generators/bio_generator_config
-- Part of MVP-019: Generator Expansion.
-- All values are data-driven. Do not hardcode these in service logic.

return {
	id = "bio_generator",
	schemaVersion = 2,
	generatorId = "bio_generator",
	displayName = "Bio Generator",
	sortOrder = 10,
	currencyType = "biomass",
	baseRate = 1,
	capacity = 120,
	upgradeCost = {
		currencyType = "biomass",
		amount = 1,
	},
	maxLevel = 999,
	unlockRequirement = {
		type = "always",
	},
	isEnabled = true,
}
