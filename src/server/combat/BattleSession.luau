--[[
	BattleSession
	Location: src/server/combat/BattleSession.luau

	Completely isolated combat simulation.
	Never mutates persistent creature state directly.
	
	Rules:
	- Deep copies HP, ATK, DEF, SPD, Cooldowns, Gauge.
	- Determines action order via Action Gauge.
	- Resolves damage via CombatFormulas.
	- Breaks SPD ties deterministically.
	- Terminates instantly and returns timeline.
	- Prevents infinite loops via maxTurnSafeguard.
--]]

local CombatFormulas = require(game:GetService("ReplicatedStorage").Genesis.Shared.combat.CombatFormulas)

local BattleSession = {}
BattleSession.__index = BattleSession

local function _getSkillCooldown(skillConfig: any): number
	if type(skillConfig.cooldown) == "number" then
		return skillConfig.cooldown
	end
	return skillConfig.cooldownValue or 0
end

local function _getSkillPriority(skillConfig: any): number
	return type(skillConfig.priority) == "number" and skillConfig.priority or 0
end

local function _getDamageMultiplier(skillConfig: any): number
	if type(skillConfig.damageMultiplier) == "number" then
		return skillConfig.damageMultiplier
	end

	for _, effect in ipairs(skillConfig.effects or {}) do
		if effect.type == "damage" and type(effect.multiplier) == "number" then
			return effect.multiplier
		end
	end

	return 1.0
end

-- Creates a new isolated battle session
function BattleSession.new(playerTeam, enemyTeam, combatConfig, skillRegistry)
	local self = setmetatable({}, BattleSession)
	
	self.config = combatConfig
	self.skillRegistry = skillRegistry
	
	self.units = {}
	self.timeline = {}
	
	self.teamA = 1
	self.teamB = 2
	
	self.turnCount = 0
	
	-- Build isolated unit state
	local function addUnit(data, teamId)
		local unit = {
			id = data.instanceId or data.creatureId, -- unique id for timeline
			creatureId = data.creatureId,
			team = teamId,
			hp = data.stats.hp,
			maxHp = data.stats.hp,
			atk = data.stats.atk,
			def = data.stats.def,
			spd = data.stats.spd,
			gauge = 0,
			skills = {}, -- array of { skillId, cooldown, priority }
		}
		
		-- Load skills
		if data.skillIds then
			for _, sid in ipairs(data.skillIds) do
				local sConf = skillRegistry.getSkill(sid)
				if sConf and sConf.isEnabled and (sConf.skillType == nil or sConf.skillType == "active") then
					table.insert(unit.skills, {
						id = sid,
						cooldown = 0, -- ready at start
						priority = _getSkillPriority(sConf),
						config = sConf
					})
				end
			end
		end
		
		-- Sort skills by priority (descending)
		table.sort(unit.skills, function(a, b)
			return a.priority > b.priority
		end)
		
		table.insert(self.units, unit)
	end
	
	for _, pData in ipairs(playerTeam) do addUnit(pData, self.teamA) end
	for _, eData in ipairs(enemyTeam) do addUnit(eData, self.teamB) end
	
	return self
end

function BattleSession:_recordEvent(eventType, data)
	table.insert(self.timeline, {
		type = eventType,
		data = data,
		turn = self.turnCount
	})
end

function BattleSession:_getAliveEnemies(team)
	local enemies = {}
	for _, u in ipairs(self.units) do
		if u.team ~= team and u.hp > 0 then
			table.insert(enemies, u)
		end
	end
	return enemies
end

function BattleSession:_isTeamDead(team)
	for _, u in ipairs(self.units) do
		if u.team == team and u.hp > 0 then
			return false
		end
	end
	return true
end

function BattleSession:_selectTarget(actor, targetRule)
	local enemies = self:_getAliveEnemies(self.teamA)
	if actor.team == self.teamB then
		enemies = self:_getAliveEnemies(self.teamB)
	end
	
	if #enemies == 0 then return nil end
	
	-- Simple front-to-back targeting MVP
	return enemies[1]
end

function BattleSession:_executeAction(actor)
	self.turnCount += 1
	
	-- Reduce cooldowns
	for _, s in ipairs(actor.skills) do
		if s.cooldown > 0 then
			s.cooldown -= 1
		end
	end
	
	-- Pick skill
	local chosenSkill = nil
	for _, s in ipairs(actor.skills) do
		if s.cooldown <= 0 then
			chosenSkill = s
			break
		end
	end
	
	-- Target
	local target = self:_selectTarget(actor, chosenSkill and chosenSkill.config.targetRule or "first_living_enemy")
	if not target then return end -- Should not happen if battle hasn't ended
	
	if chosenSkill then
		-- Apply skill damage. MVP-017 keeps statusEffectRefs as placeholders only.
		chosenSkill.cooldown = _getSkillCooldown(chosenSkill.config)

		local defRed = CombatFormulas.DefenseFormula.reduce(target.def, self.config.defReductionConstant)
		local totalDamage = CombatFormulas.DamageFormula.calculate(actor.atk, _getDamageMultiplier(chosenSkill.config), defRed)
		target.hp -= totalDamage
		if target.hp < 0 then target.hp = 0 end
		
		self:_recordEvent("skill_use", {
			actorId = actor.id,
			targetId = target.id,
			skillId = chosenSkill.id,
			damage = totalDamage,
			targetHp = target.hp
		})
	else
		-- Fallback basic attack (if no skills available or all on CD)
		local defRed = CombatFormulas.DefenseFormula.reduce(target.def, self.config.defReductionConstant)
		local dmg = CombatFormulas.DamageFormula.calculate(actor.atk, 1.0, defRed)
		
		target.hp -= dmg
		if target.hp < 0 then target.hp = 0 end
		
		self:_recordEvent("fallback_attack", {
			actorId = actor.id,
			targetId = target.id,
			damage = dmg,
			targetHp = target.hp
		})
	end
	
	-- Reset gauge
	actor.gauge = 0
end

local SimulationGuard = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.SimulationGuard)

-- Simulates the entire battle instantly
function BattleSession:simulate()
	local maxTurns = self.config.maxTurnSafeguard
	
	local guard = SimulationGuard.new({
		maxSteps = 50000,
		timeoutSeconds = 2.0,
		noProgressLimit = 1000,
		context = "BattleSession:simulate"
	})
	
	while guard:step() do
		-- Check win/loss
		if self:_isTeamDead(self.teamA) then
			return { isVictory = false, timeline = self.timeline, summary = { turns = self.turnCount, reason = "defeat" } }
		end
		if self:_isTeamDead(self.teamB) then
			return { isVictory = true, timeline = self.timeline, summary = { turns = self.turnCount, reason = "victory" } }
		end
		
		-- Advance gauges
		local actorsThisTick = {}
		for _, u in ipairs(self.units) do
			if u.hp > 0 then
				u.gauge += CombatFormulas.GaugeFormula.fill(u.spd, self.config.gaugeFillCoefficient)
				if u.gauge >= self.config.actionGaugeThreshold then
					table.insert(actorsThisTick, u)
				end
			end
		end
		
		-- Tie-breaking: Highest gauge first, then SPD, then Team A > Team B, then ID
		table.sort(actorsThisTick, function(a, b)
			if a.gauge ~= b.gauge then return a.gauge > b.gauge end
			if a.spd ~= b.spd then return a.spd > b.spd end
			if a.team ~= b.team then return a.team < b.team end
			return a.id < b.id
		end)
		
		-- Execute actions
		for _, actor in ipairs(actorsThisTick) do
			if actor.hp > 0 then -- might have died during this tick from another actor
				self:_executeAction(actor)
				guard:markProgress()
				
				-- Recheck win/loss immediately after action to prevent dead units acting
				if self:_isTeamDead(self.teamA) or self:_isTeamDead(self.teamB) then
					break
				end
			end
		end
		
		-- Also break immediately if win/loss happened during the tick
		if self:_isTeamDead(self.teamA) or self:_isTeamDead(self.teamB) then
			break -- let the next tick handle returning
		end
	end
	
	if guard:shouldStop() then
		local p1 = self.units[1] and { id = self.units[1].id, hp = self.units[1].hp, spd = self.units[1].spd, gauge = self.units[1].gauge }
		local p2 = self.units[2] and { id = self.units[2].id, hp = self.units[2].hp, spd = self.units[2].spd, gauge = self.units[2].gauge }
		guard:logDiagnostic({
			turnCount = self.turnCount,
			units = { p1, p2 }
		})
		return { isStalled = true, failReason = guard:failReason(), timeline = self.timeline, summary = { turns = self.turnCount } }
	end
	
	return { isVictory = false, timeline = self.timeline, summary = { turns = self.turnCount, reason = "max_turns_safeguard" } }
end

return BattleSession
