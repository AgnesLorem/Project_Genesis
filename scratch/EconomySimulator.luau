--[[
	EconomySimulator
	Location: scratch/EconomySimulator.luau
	
	Offline mathematical simulation of the Project Genesis economy.
	Used to audit progression pacing, bottlenecks, resource inflation, and hard/soft locks.
	Part of Task ALPHA-001: Phase A Economy Audit.
--]]

local ServerStorage = game:GetService("ServerStorage")
local GeneratorRegistry = require(ServerStorage.Genesis.Configs.generators.bio_generator_config) -- we can just load configs manually or via registries

local EconomySimulator = {}

function EconomySimulator.runSimulation()
	-- ── Load Configs ──
	-- Since they are ModuleScripts, we require them directly from ServerStorage
	local bioConfig = require(ServerStorage.Configs.generators.bio_generator_config)
	local dnaConfig = require(ServerStorage.Configs.generators.dna_generator_config)
	local advBioConfig = require(ServerStorage.Configs.generators.advanced_bio_generator_config)
	
	local BIOMASS_CAP = 999999
	local DNA_CAP = 999999
	
	-- Helper formulas matching GeneratorService.luau
	local function getEffectiveRate(config, level)
		return (config.baseRate or 1) * level
	end
	
	local function getEffectiveCapacity(config, level)
		return (config.capacity or 100) * level
	end
	
	local function getUpgradeCost(config, level)
		local cost = config.upgradeCost or {}
		return math.max(1, math.floor((cost.amount or 1) * level))
	end
	
	-- ── Running Scenario 1: Active Play ──
	-- Player battles repeatedly. Battle takes 15 seconds.
	-- Rewards: 50 DNA, 100 XP.
	-- Claims generators after every battle.
	-- Upgrades generators immediately when affordable.
	
	local timeElapsed = 0
	local balances = { biomass = 0, dna = 0 }
	local generators = {
		bio_generator = { level = 1, lastClaimedAt = 0, accumulated = 0 },
		dna_generator = { level = 1, lastClaimedAt = 0, accumulated = 0 },
		advanced_bio_generator = { level = 1, lastClaimedAt = 0, accumulated = 0, unlocked = false }
	}
	
	local creature = { level = 1, xp = 0 }
	local activeLogs = {}
	
	local bioLvl10Time = nil
	local bioLvl20Time = nil
	local advBioUnlockTime = nil
	local dnaLvl2Time = nil
	local hasHardLock = false
	local hardLockReason = nil
	local maxLevelReached = false
	
	local totalBiomassEarned = 0
	local totalDnaEarned = 0
	local battlesPlayed = 0
	
	-- Run active simulation step by step
	-- Limit simulation to 24 hours of game time (86400 seconds)
	local simDuration = 86400
	local timeStep = 1 -- 1 second per tick
	
	while timeElapsed < simDuration do
		timeElapsed += timeStep
		
		-- 1. Generators accumulate
		for id, gen in pairs(generators) do
			local config = id == "bio_generator" and bioConfig or (id == "dna_generator" and dnaConfig or advBioConfig)
			if id ~= "advanced_bio_generator" or gen.unlocked then
				local rate = getEffectiveRate(config, gen.level)
				local capacity = getEffectiveCapacity(config, gen.level)
				local elapsed = timeElapsed - gen.lastClaimedAt
				gen.accumulated = math.min(capacity, math.floor(elapsed * rate))
			end
		end
		
		-- 2. Battle simulation
		-- Every 15 seconds, player finishes a battle
		if timeElapsed % 15 == 0 then
			battlesPlayed += 1
			-- Grant DNA and XP
			balances.dna = math.min(DNA_CAP, balances.dna + 50)
			totalDnaEarned += 50
			creature.xp += 100
			
			-- Level up creature
			local xpNeeded = creature.level * 100
			if creature.xp >= xpNeeded then
				creature.xp -= xpNeeded
				creature.level += 1
			end
			
			-- Claim all generators
			for id, gen in pairs(generators) do
				if id ~= "advanced_bio_generator" or gen.unlocked then
					local config = id == "bio_generator" and bioConfig or (id == "dna_generator" and dnaConfig or advBioConfig)
					if gen.accumulated >= 1 then
						local currency = config.currencyType
						local cap = currency == "biomass" and BIOMASS_CAP or DNA_CAP
						local remaining = cap - balances[currency]
						local grantAmount = math.min(gen.accumulated, remaining)
						
						balances[currency] += grantAmount
						if currency == "biomass" then
							totalBiomassEarned += grantAmount
						else
							totalDnaEarned += grantAmount
						end
						
						gen.accumulated = 0
						gen.lastClaimedAt = timeElapsed
					end
				end
			end
		end
		
		-- 3. Upgrade decisions
		-- Upgrade Bio Generator
		local bioCost = getUpgradeCost(bioConfig, generators.bio_generator.level)
		if balances.biomass >= bioCost and generators.bio_generator.level < bioConfig.maxLevel then
			balances.biomass -= bioCost
			generators.bio_generator.level += 1
			generators.bio_generator.lastClaimedAt = timeElapsed -- resets accumulation time
			
			if generators.bio_generator.level == 10 and not bioLvl10Time then
				bioLvl10Time = timeElapsed
			end
			if generators.bio_generator.level == 20 and not bioLvl20Time then
				bioLvl20Time = timeElapsed
			end
			
			-- Check Advanced Bio Generator unlock
			if generators.bio_generator.level >= (advBioConfig.unlockRequirement.level or 1000) and not generators.advanced_bio_generator.unlocked then
				generators.advanced_bio_generator.unlocked = true
				generators.advanced_bio_generator.lastClaimedAt = timeElapsed
				advBioUnlockTime = timeElapsed
			end
		end
		
		-- Upgrade DNA Generator
		local dnaCost = getUpgradeCost(dnaConfig, generators.dna_generator.level)
		if balances.dna >= dnaCost and generators.dna_generator.level < dnaConfig.maxLevel then
			balances.dna -= dnaCost
			generators.dna_generator.level += 1
			generators.dna_generator.lastClaimedAt = timeElapsed
			
			if generators.dna_generator.level == 2 and not dnaLvl2Time then
				dnaLvl2Time = timeElapsed
			end
		elseif dnaCost > DNA_CAP then
			hasHardLock = true
			hardLockReason = string.format("DNA Generator level %d upgrade cost (%d) exceeds DNA currency cap (%d).", generators.dna_generator.level, dnaCost, DNA_CAP)
		end
		
		-- Upgrade Advanced Bio Generator
		if generators.advanced_bio_generator.unlocked then
			local advCost = getUpgradeCost(advBioConfig, generators.advanced_bio_generator.level)
			if balances.biomass >= advCost and generators.advanced_bio_generator.level < advBioConfig.maxLevel then
				balances.biomass -= advCost
				generators.advanced_bio_generator.level += 1
				generators.advanced_bio_generator.lastClaimedAt = timeElapsed
			end
		end
		
		-- Escape early if we hit a hard lock to prevent infinite loop or useless run
		if hasHardLock and not dnaLvl2Time and timeElapsed > 3600 then
			break
		end
	end
	
	return {
		simulatedHours = timeElapsed / 3600,
		battlesPlayed = battlesPlayed,
		balances = balances,
		levels = {
			bio = generators.bio_generator.level,
			dna = generators.dna_generator.level,
			adv = generators.advanced_bio_generator.level
		},
		milestones = {
			bioLvl10 = bioLvl10Time,
			bioLvl20 = bioLvl20Time,
			advBioUnlock = advBioUnlockTime,
			dnaLvl2 = dnaLvl2Time
		},
		telemetry = {
			totalBiomassEarned = totalBiomassEarned,
			totalDnaEarned = totalDnaEarned,
			biomassPerHour = totalBiomassEarned / (timeElapsed / 3600),
			dnaPerHour = totalDnaEarned / (timeElapsed / 3600)
		},
		hardLock = {
			detected = hasHardLock,
			reason = hardLockReason
		}
	}
end

return EconomySimulator
