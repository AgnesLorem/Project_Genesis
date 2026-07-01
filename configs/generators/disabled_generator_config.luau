-- Disabled Generator Config
-- Location: ServerStorage/Configs/generators/disabled_generator_config
-- Part of MVP-019: Generator Expansion validation fixture.

return {
	id = "disabled_generator",
	schemaVersion = 2,
	generatorId = "disabled_generator",
	displayName = "Disabled Generator",
	sortOrder = 999,
	currencyType = "biomass",
	baseRate = 1,
	capacity = 10,
	upgradeCost = {
		currencyType = "biomass",
		amount = 1,
	},
	maxLevel = 1,
	unlockRequirement = {
		type = "always",
	},
	isEnabled = false,
}
