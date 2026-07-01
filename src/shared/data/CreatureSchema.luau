local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local CreatureSchema = {}

local VALID_RARITIES = {
	Common = true,
	Rare = true,
	Epic = true,
	Legend = true,
}

-- Validates exactly the fields defined in docs/DATA_SCHEMA.md
function CreatureSchema.validate(data: any)
    if type(data) ~= "table" then
        return Result.fail("Creature data must be a table")
    end

    if type(data.creatureId) ~= "string" then
        return Result.fail("Missing or invalid creatureId (string)")
    end

    if type(data.schemaVersion) ~= "number" then
        return Result.fail("Missing or invalid schemaVersion (number)")
    end

    if type(data.displayName) ~= "string" then
        return Result.fail("Missing or invalid displayName (string)")
    end

    if type(data.description) ~= "string" then
        return Result.fail("Missing or invalid description (string)")
    end

    if type(data.rarity) ~= "string" or not VALID_RARITIES[data.rarity] then
        return Result.fail("Missing or invalid rarity (Common/Rare/Epic/Legend)")
    end

    if type(data.elementType) ~= "string" then
        return Result.fail("Missing or invalid elementType (string)")
    end

    if type(data.placeholderArtSlot) ~= "string" then
        return Result.fail("Missing or invalid placeholderArtSlot (string)")
    end

    if data.evolutionTarget ~= nil and type(data.evolutionTarget) ~= "string" then
        return Result.fail("Missing or invalid evolutionTarget (string or nil)")
    end

    if type(data.baseStats) ~= "table" then
        return Result.fail("Missing or invalid baseStats (table)")
    end

    for _, statName in ipairs({ "hp", "atk", "def", "spd" }) do
        if type(data.baseStats[statName]) ~= "number" then
            return Result.fail("Missing or invalid baseStats." .. statName .. " (number)")
        end
    end

    if type(data.skillIds) ~= "table" then
        return Result.fail("Missing or invalid skillIds (array)")
    end

    if type(data.geneSlots) ~= "table" then
        return Result.fail("Missing or invalid geneSlots (array)")
    end

    if type(data.evolutionLineId) ~= "string" then
        return Result.fail("Missing or invalid evolutionLineId (string)")
    end

    if type(data.collectionCategory) ~= "string" then
        return Result.fail("Missing or invalid collectionCategory (string enum)")
    end

    if type(data.visualRef) ~= "string" then
        return Result.fail("Missing or invalid visualRef (string)")
    end

    if type(data.sortOrder) ~= "number" then
        return Result.fail("Missing or invalid sortOrder (number)")
    end

    if type(data.isEnabled) ~= "boolean" then
        return Result.fail("Missing or invalid isEnabled (boolean)")
    end

    if type(data.cardMetadata) ~= "table" then
        return Result.fail("Missing or invalid cardMetadata (table)")
    end

    if data.cardMetadata.displayName ~= data.displayName then
        return Result.fail("cardMetadata.displayName must match displayName")
    end

    if data.cardMetadata.rarity ~= data.rarity then
        return Result.fail("cardMetadata.rarity must match rarity")
    end

    if data.cardMetadata.elementType ~= data.elementType then
        return Result.fail("cardMetadata.elementType must match elementType")
    end

    if data.cardMetadata.description ~= data.description then
        return Result.fail("cardMetadata.description must match description")
    end

    if data.cardMetadata.placeholderArtSlot ~= data.placeholderArtSlot then
        return Result.fail("cardMetadata.placeholderArtSlot must match placeholderArtSlot")
    end

    if data.cardMetadata.evolutionTarget ~= data.evolutionTarget then
        return Result.fail("cardMetadata.evolutionTarget must match evolutionTarget")
    end

    if type(data.cardMetadata.stats) ~= "table" then
        return Result.fail("Missing or invalid cardMetadata.stats (table)")
    end

    for _, statName in ipairs({ "hp", "atk", "def", "spd" }) do
        if data.cardMetadata.stats[statName] ~= data.baseStats[statName] then
            return Result.fail("cardMetadata.stats must match baseStats")
        end
    end

    return Result.ok(data)
end

return CreatureSchema
