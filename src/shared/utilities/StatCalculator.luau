local StatCalculator = {}

function StatCalculator.getScaledStats(config: any, level: number, bonuses: any): any
	local lvl = level or 1
	local scale = 1 + (lvl - 1) * 0.1
	local spdScale = 1 + (lvl - 1) * 0.01

	local hp = math.floor(config.baseStats.hp * scale) + (bonuses and bonuses.hp or 0)
	local atk = math.floor(config.baseStats.atk * scale) + (bonuses and bonuses.atk or 0)
	local def = math.floor(config.baseStats.def * scale) + (bonuses and bonuses.def or 0)
	local spd = math.floor(config.baseStats.spd * spdScale) + (bonuses and bonuses.spd or 0)

	return {
		hp = hp,
		atk = atk,
		def = def,
		spd = spd,
	}
end

return StatCalculator
