local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)
local SaveService = require(script.Parent.SaveService)
local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
local HttpService = game:GetService("HttpService")

local CreatureService = {}

-- Narrow interface to SaveService.
-- CreatureService must not communicate with DataStore directly.
function CreatureService.tryGrantCreature(player: Player, creatureId: string)
    -- Validate: Creature exists in Registry
    local config = CreatureRegistry.getCreature(creatureId)
    if not config then
        return Result.fail("Invalid Creature ID rejected.")
    end

    -- Validate: Creature is enabled
    if not config.isEnabled then
        return Result.fail("Disabled Creature rejected.")
    end

    -- Validate: Duplicate check
    local playerSave = SaveService.getPlayerSave(player)
    local instances = playerSave.creatureInstances or {}
    
    for _, instance in pairs(instances) do
        if instance.creatureId == creatureId then
            return Result.fail("Duplicate grant behavior follows documented rule: cannot grant duplicate.")
        end
    end

    -- Generate instance
    local instanceId = HttpService:GenerateGUID(false)
    local newInstance = {
        instanceId = instanceId,
        creatureId = creatureId,
        level = 1,
        xp = 0,
        acquiredAt = os.time()
    }

    -- Apply to SaveService
    instances[instanceId] = newInstance
    playerSave.creatureInstances = instances
    SaveService.savePlayer(player)

    -- decoupled discovery registration
    local CollectionService = require(script.Parent.CollectionService)
    CollectionService.discoverCreature(player, creatureId)

    return Result.ok(newInstance)
end

function CreatureService.getPlayerCreatures(player: Player)
    local playerSave = SaveService.getPlayerSave(player)
    return playerSave.creatureInstances or {}
end

function CreatureService.addCreatureXp(player: Player, instanceId: string, amount: number)
	if type(amount) ~= "number" or amount < 0 or amount ~= math.floor(amount) then
		return Result.fail("invalid_amount", "XP amount must be a positive integer.")
	end

	local playerSave = SaveService.getPlayerSave(player)
	local instances = playerSave.creatureInstances or {}
	local creature = instances[instanceId]
	if not creature then
		return Result.fail("not_found", "Creature instance not found.")
	end

	-- Initialize level/xp if missing (for legacy creature instances)
	if not creature.level then creature.level = 1 end
	if not creature.xp then creature.xp = 0 end

	creature.xp += amount

	local function getXpNeeded(level)
		return level * 100
	end

	local leveledUp = false
	while creature.xp >= getXpNeeded(creature.level) do
		creature.xp -= getXpNeeded(creature.level)
		creature.level += 1
		leveledUp = true
	end

	SaveService.savePlayer(player)

	return Result.ok({
		level = creature.level,
		xp = creature.xp,
		leveledUp = leveledUp
	})
end

return CreatureService
