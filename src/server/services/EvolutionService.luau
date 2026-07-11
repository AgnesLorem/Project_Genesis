--[[
	EvolutionService
	Location: src/server/services/EvolutionService.luau

	Server-authoritative creature evolution transactions.
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
local SaveService = require(script.Parent.SaveService)
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)
local EvolutionRegistry = require(script.Parent.Parent.data.EvolutionRegistry)
local CurrencyService = require(script.Parent.CurrencyService)
local CollectionService = require(script.Parent.CollectionService)

local EvolutionService = {}

function EvolutionService.tryEvolve(player: Player, instanceId: string, evolutionId: string)
	-- 1. Validate Ownership
	local playerSave = SaveService.getPlayerSave(player)
	local instances = playerSave.creatureInstances or {}
	local creature = instances[instanceId]
	if not creature then
		return Result.fail("not_owned", "Player does not own this creature instance.")
	end

	-- 2. Validate Config
	local evolutionConfig = EvolutionRegistry.getEvolution(evolutionId)
	if not evolutionConfig then
		return Result.fail("invalid_config", "Evolution configuration not found.")
	end
	if not evolutionConfig.isEnabled then
		return Result.fail("disabled_evolution", "This evolution path is currently disabled.")
	end

	-- 3. Validate fromCreatureId
	if creature.creatureId ~= evolutionConfig.fromCreatureId then
		return Result.fail("mismatch_from_creature", "Creature ID does not match evolution starting creature.")
	end

	-- 4. Validate Target exists and is enabled
	local targetCreatureConfig = CreatureRegistry.getCreature(evolutionConfig.toCreatureId)
	if not targetCreatureConfig then
		return Result.fail("missing_target_creature", "Evolution target creature species not found in registry.")
	end
	if not targetCreatureConfig.isEnabled then
		return Result.fail("disabled_target_creature", "Evolution target creature species is currently disabled.")
	end

	-- 5. Validate Level
	local currentLevel = creature.level or 1
	if currentLevel < evolutionConfig.requiredLevel then
		return Result.fail(
			"insufficient_level",
			string.format("Creature level %d is below required level %d.", currentLevel, evolutionConfig.requiredLevel)
		)
	end

	-- 6. Spend Biomass
	if evolutionConfig.biomassCost > 0 then
		local spendResult = CurrencyService.trySpend(player, "biomass", evolutionConfig.biomassCost, "evolution")
		if not spendResult.success then
			-- If they don't have enough biomass, the spend fails.
			-- We exit early with no changes.
			return Result.fail("insufficient_biomass", "Insufficient Biomass balance to evolve.")
		end
	end

	-- 7. Mutate creature
	creature.creatureId = evolutionConfig.toCreatureId
	creature.level = 1
	creature.xp = 0

	-- 8. Record Discovery
	CollectionService.discoverCreature(player, evolutionConfig.toCreatureId)

	-- 9. Commit Save
	SaveService.savePlayer(player)

	return Result.ok({
		instanceId = instanceId,
		newCreatureId = evolutionConfig.toCreatureId,
		level = 1,
		xp = 0,
	})
end

return EvolutionService
