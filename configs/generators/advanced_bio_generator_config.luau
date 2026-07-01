-- Advanced Bio Generator Config
-- Location: ServerStorage/Configs/generators/advanced_bio_generator_config
-- Part of MVP-019: Generator Expansion.

return {
	id = "advanced_bio_generator",
	schemaVersion = 2,
	generatorId = "advanced_bio_generator",
	displayName = "Advanced Bio Generator",
	sortOrder = 30,
	currencyType = "biomass",
	baseRate = 3,
	capacity = 240,
	upgradeCost = {
		currencyType = "biomass",
		amount = 3,
	},
	maxLevel = 20,
	unlockRequirement = {
		type = "generatorLevel",
		generatorId = "bio_generator",
		level = 1000,
	},
	isEnabled = true,
}
