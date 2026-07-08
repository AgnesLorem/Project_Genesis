-- Biomass Currency Config
-- Location: ServerStorage/Configs/economy/biomass_config
-- Part of MVP-005: Bio Generator and Economy Foundation.
-- All values are data-driven. Do not hardcode these in service logic.

return {
	id = "biomass",
	schemaVersion = 1,
	currencyId = "biomass",
	displayName = "Biomass",
	currencyType = "soft",
	sourceRefs = { "bio_generator_claim", "generator_claim", "story", "tower_first_clear_reward" },
	sinkRefs = { "spend_generic", "evolution", "generator_upgrade" },
	cap = 9999999,
	auditCategory = "progression_reward",
}
