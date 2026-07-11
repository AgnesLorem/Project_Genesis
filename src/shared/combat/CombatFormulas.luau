--[[
	CombatFormulas
	Location: src/shared/combat/CombatFormulas.luau

	Pure functions for combat calculations.
	Takes constants from configs, avoids hardcoded values.
	
	Minimum damage clamp rule:
	- If a damage skill produces raw damage > 0, final damage must be at least 1.
	- Do not force non-damage effects or 0 multiplier effects to deal 1 damage.
--]]

local CombatFormulas = {}

CombatFormulas.GaugeFormula = {}
function CombatFormulas.GaugeFormula.fill(spd: number, coeff: number): number
	return spd * coeff
end

CombatFormulas.DefenseFormula = {}
function CombatFormulas.DefenseFormula.reduce(def: number, defConstant: number): number
	if def < 0 then
		def = 0
	end
	return def / (def + defConstant)
end

CombatFormulas.DamageFormula = {}
function CombatFormulas.DamageFormula.calculate(atk: number, skillMult: number, defReduction: number): number
	local rawDamage = atk * skillMult

	if rawDamage <= 0 then
		return 0
	end

	local finalDamage = math.floor(rawDamage * (1 - defReduction))

	-- Minimum damage clamp: raw > 0 implies final >= 1
	if finalDamage < 1 then
		finalDamage = 1
	end

	return finalDamage
end

return CombatFormulas
