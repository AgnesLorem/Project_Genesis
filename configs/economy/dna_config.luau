-- DNA Currency Config
-- Location: ServerStorage/Configs/economy/dna_config
-- Part of MVP-005: Bio Generator and Economy Foundation.
-- All values are data-driven. Do not hardcode these in service logic.
-- DNA reward amounts are defined by future combat/milestone configs.

return {
	id = "dna",
	schemaVersion = 1,
	currencyId = "dna",
	displayName = "DNA",
	currencyType = "soft",
	sourceRefs = { "reward_combat", "reward_milestone", "generator_claim", "tower_first_clear_reward" },
	sinkRefs = { "spend_generic", "generator_upgrade" },
	cap = 999999,
	auditCategory = "progression_reward",
}
