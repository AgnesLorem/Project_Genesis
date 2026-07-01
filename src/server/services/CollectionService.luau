--[[
	CollectionService
	Location: src/server/services/CollectionService.luau

	Server-authoritative collection tracking.
	Logs discovered creatures and returns collection snapshots.
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
local SaveService = require(script.Parent.SaveService)
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)

local CollectionService = {}

function CollectionService.discoverCreature(player: Player, creatureId: string)
	local creatureConfig = CreatureRegistry.getCreature(creatureId)
	if not creatureConfig then
		return Result.fail("invalid_creature", "Creature does not exist in registry.")
	end

	local save = SaveService.getPlayerSave(player)
	local discovered = save.collectionState.discoveredCreatureIds
	if not discovered[creatureId] then
		discovered[creatureId] = true
		SaveService.savePlayer(player)
		return Result.ok(true) -- newly discovered
	end

	return Result.ok(false) -- already discovered
end

function CollectionService.getCollectionSnapshot(player: Player)
	local save = SaveService.getPlayerSave(player)
	local discovered = save.collectionState.discoveredCreatureIds
	local allCreatures = CreatureRegistry.getAllCreatures()
	
	local total = 0
	local completionCount = 0
	local entries = {}
	
	for _, creature in ipairs(allCreatures) do
		-- Only count enabled creatures in the total available checklist
		if creature.isEnabled then
			total += 1
			local cid = creature.creatureId
			local hasDiscovered = not not discovered[cid]
			entries[cid] = hasDiscovered
			if hasDiscovered then
				completionCount += 1
			end
		end
	end
	
	return Result.ok({
		completionCount = completionCount,
		total = total,
		entries = entries
	})
end

return CollectionService
