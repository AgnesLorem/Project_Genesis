--[[
	PresentationPlayer
	Location: src/client/views/PresentationPlayer.luau
	Coordinates combat event timelines, sounds, camera shakes, and card flashes.
--]]

--// Raw Requirings \\--
--// Requirings \\--
local SkillVfxConfig = require(script.Parent.SkillVfxConfig)
local VfxPlayer = require(script.Parent.VfxPlayer)
local AudioPlayer = require(script.Parent.AudioPlayer)
local ScreenShake = require(script.Parent.ScreenShake)
local HitFlash = require(script.Parent.HitFlash)
local FloatingText = require(script.Parent.FloatingText)

--// Variables \\--
local PresentationPlayer = {}
local isCombatActive = false

--// Service \\--

-- Set the active state of combat, clearing VFX if false
function PresentationPlayer.setCombatActive(active: boolean)
	isCombatActive = active
	if not active then
		VfxPlayer.clearAllActiveVfx()
	end
end

-- Check if combat is currently active
function PresentationPlayer.isCombatActive(): boolean
	return isCombatActive
end

-- Helper to check if unit ID belongs to the player team
local function isPlayerUnit(playerUnitIds: { string }, id: string): boolean
	for _, uid in ipairs(playerUnitIds or {}) do
		if uid == id then
			return true
		end
	end
	return false
end

local function cardsAreValid(actorCard: GuiObject?, targetCard: GuiObject?): boolean
	return actorCard ~= nil and targetCard ~= nil and actorCard.Parent ~= nil and targetCard.Parent ~= nil
end

-- Plays a combat event blocking the thread until completion
function PresentationPlayer.playEvent(event: any, playerUnitIds: { string }, enemyUnitIds: { string }, api: any)
	if not isCombatActive then
		return
	end

	local eventType = event.type
	if eventType ~= "skill_use" and eventType ~= "fallback_attack" then
		return
	end

	local data = event.data or {}
	local skillId = (eventType == "skill_use") and data.skillId or "basic_attack"

	local actorSide = isPlayerUnit(playerUnitIds, data.actorId) and "Player" or "Enemy"
	local targetSide = isPlayerUnit(playerUnitIds, data.targetId) and "Player" or "Enemy"

	-- Extract context
	local context = {
		skillId = skillId,
		attacker = data.actorId,
		target = data.targetId,
		damage = data.damage or 0,
		targetHp = data.targetHp or 0,
		isCritical = data.isCritical or false,
		isBlocked = data.isBlocked or false,
		isHeal = data.isHeal or false,
	}

	-- Load configuration
	local config = SkillVfxConfig[skillId]
	if not config then
		if SkillVfxConfig.Debug then
			warn(
				string.format(
					"[PresentationPlayer] No VFX config for skillId '%s'. Falling back to basic_attack.",
					tostring(skillId)
				)
			)
		end
		config = SkillVfxConfig.basic_attack
	end

	local castTime = config.castTime or 0
	local projectileTime = config.projectileTime or 0
	local settleTime = 0.4 -- Default settle/recovery time for impact VFX

	if SkillVfxConfig.Debug then
		print(
			string.format(
				"[VFX DEBUG] [Turn %d] Skill: %s | Actor: %s (%s) | Target: %s (%s)",
				event.turn or 0,
				skillId,
				tostring(context.attacker),
				actorSide,
				tostring(context.target),
				targetSide
			)
		)
	end

	-- Retrieve target and actor cards
	local targetCard = (targetSide == "Enemy") and api.enemyCard or api.playerCard
	local actorCard = (actorSide == "Enemy") and api.enemyCard or api.playerCard
	if not cardsAreValid(actorCard, targetCard) then
		return
	end

	-- Helper to execute steps for a specific phase
	local function playPhase(phaseName: string)
		if not isCombatActive or not cardsAreValid(actorCard, targetCard) then
			return
		end

		if SkillVfxConfig.Debug then
			print(string.format("[VFX DEBUG] Phase: %s", phaseName))
		end

		for _, step in ipairs(config.sequence or {}) do
			if step.at == phaseName then
				task.spawn(function()
					if not isCombatActive or not cardsAreValid(actorCard, targetCard) then
						return
					end

					-- Apply delay relative to phase start
					if step.offset and step.offset > 0 then
						task.wait(step.offset)
					end

					if not isCombatActive or not cardsAreValid(actorCard, targetCard) then
						return
					end

					-- Play Sound
					if step.sound then
						AudioPlayer.play(step.sound)
					end

					-- Play 3D Particles
					VfxPlayer.playStep(step, actorCard, targetCard, projectileTime)

					-- Play Screen Shake
					if step.shake then
						ScreenShake.shake(step.shake)
					end

					-- Play Hit Flash
					if step.flash then
						HitFlash.flash(targetCard)
					end

					-- Trigger callbacks/damage sync
					if step.trigger == "damage" then
						-- Update target HP
						if targetSide == "Enemy" then
							api.updateEnemyHp(context.targetHp)
						else
							api.updatePlayerHp(context.targetHp)
						end

						-- Spawn floating text
						local textType = "damage"
						if context.isCritical then
							textType = "critical"
						elseif context.isHeal then
							textType = "heal"
						elseif context.isBlocked then
							textType = "shield"
						end
						FloatingText.show(targetCard, textType, context.damage)
					end
				end)
			end
		end
	end

	-- Log turn text in combat screen
	if eventType == "skill_use" then
		api.appendLog(
			string.format(
				"[Turn %d] %s used %s on %s.",
				event.turn or 0,
				tostring(context.attacker),
				tostring(context.skillId),
				tostring(context.target)
			)
		)
	else
		api.appendLog(
			string.format(
				"[Turn %d] %s attacked %s.",
				event.turn or 0,
				tostring(context.attacker),
				tostring(context.target)
			)
		)
	end

	-- Execute sequenced phases
	playPhase("cast")
	if castTime > 0 then
		local startWait = os.clock()
		while os.clock() - startWait < castTime do
			if not isCombatActive then
				return
			end
			task.wait()
		end
	end

	playPhase("projectile")
	if projectileTime > 0 then
		local startWait = os.clock()
		while os.clock() - startWait < projectileTime do
			if not isCombatActive then
				return
			end
			task.wait()
		end
	end

	playPhase("impact")
	local startWait = os.clock()
	while os.clock() - startWait < settleTime do
		if not isCombatActive then
			return
		end
		task.wait()
	end
end

return PresentationPlayer
