-- Combat Balance Config
-- Location: ServerStorage/Configs/balance/combat_config
-- Part of MVP-006: Combat System Foundation.
-- Contains only constants and coefficients. Formulas are in CombatFormulas.

return {
	id = "combat_core",
	schemaVersion = 1,
	
	actionGaugeThreshold = 1000,
	gaugeFillCoefficient = 1.0,
	
	-- DEF / (DEF + defReductionConstant)
	defReductionConstant = 100,
	
	-- Safeguard to prevent infinite loops in auto-battle
	maxTurnSafeguard = 1000,

	-- Config-driven rewards for story stage completion
	storyBattleRewards = {
		biomass = 600,
		xp = 1000,
	},
}
