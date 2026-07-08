-- DNA Generator Config
-- Location: ServerStorage/Configs/generators/dna_generator_config
-- Part of MVP-019: Generator Expansion.

return {
	id = "dna_generator",
	schemaVersion = 2,
	generatorId = "dna_generator",
	displayName = "DNA Generator",
	sortOrder = 20,
	currencyType = "dna",
	baseRate = 1,
	capacity = 60,
	upgradeCost = {
		currencyType = "dna",
		amount = 100,
	},
	upgradeCostMultiplier = 1.35,
	maxLevel = 50,
	unlockRequirement = {
		type = "always",
	},
	isEnabled = true,
}
