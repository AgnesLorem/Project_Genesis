return {
	id = "tower_trial_001",
	schemaVersion = 1,
	challengeId = "tower_trial_001",
	displayName = "Tower Trial",
	description = "Repeatable isolated challenge combat.",
	isEnabled = true,
	floors = {
		{
			floorId = "tower_floor_001",
			floorNumber = 1,
			enemyCreatureId = "enemy_001",
			recommendedLevel = 1,
			rewards = {
				{ currencyType = "dna", amount = 100 }
			},
			isEnabled = true,
		},
		{
			floorId = "tower_floor_002",
			floorNumber = 2,
			enemyCreatureId = "enemy_001", -- reuse enemy_001 for test simplicity
			recommendedLevel = 5,
			isEnabled = true,
		},
	},
}
