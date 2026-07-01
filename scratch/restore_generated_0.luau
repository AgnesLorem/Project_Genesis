local function getOrCreateFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

local function getOrCreateModule(parent, name, source)
    local module = parent:FindFirstChild(name)
    if not module then
        module = Instance.new("ModuleScript")
        module.Name = name
        module.Parent = parent
    end
    module.Source = source
    return module
end

local function ensurePath(root, path)
    if path == "" then return root end
    local current = root
    for part in string.gmatch(path, "[^/]+") do
        current = getOrCreateFolder(current, part)
    end
    return current
end

-- Create root folders
getOrCreateFolder(game:GetService("ServerScriptService"), "Server")
getOrCreateFolder(game:GetService("StarterPlayer").StarterPlayerScripts, "Client")
getOrCreateFolder(game:GetService("ReplicatedStorage"), "Shared")
local p = ensurePath(game:GetService("ReplicatedStorage").Shared, "data")
getOrCreateModule(p, "CreatureRegistry", [====[
local CreatureSchema = require(script.Parent.CreatureSchema)
local Result = require(game:GetService("ReplicatedStorage").Shared.utilities.Result)

local CreatureRegistry = {}
local registry = {}

-- Static definitions only. No player state.
function CreatureRegistry.loadConfig(configs: { [string]: any })
    for id, data in pairs(configs) do
        local result = CreatureSchema.validate(data)
        if result.success then
            registry[id] = result.value
        else
            warn(string.format("Failed to validate creature config %s: %s", id, result.error))
        end
    end
end

function CreatureRegistry.getCreature(id: string)
    return registry[id]
end

function CreatureRegistry.getAllCreatures()
    local list = {}
    for _, creature in pairs(registry) do
        table.insert(list, creature)
    end
    return list
end

return CreatureRegistry

]====])

local p = ensurePath(game:GetService("ReplicatedStorage").Shared, "data")
getOrCreateModule(p, "CreatureSchema", [====[
local Result = require(game:GetService("ReplicatedStorage").Shared.utilities.Result)

local CreatureSchema = {}

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

    if type(data.baseStats) ~= "table" then
        return Result.fail("Missing or invalid baseStats (table)")
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

    return Result.ok(data)
end

return CreatureSchema

]====])

local p = ensurePath(game:GetService("ReplicatedStorage").Shared, "network")
getOrCreateModule(p, "CreatureSnapshotType", [====[
export type CreatureSnapshotType = {
    instanceId: string,
    creatureId: string,
    displayName: string,
    -- Strictly presentation fields only. No server-only metadata.
    -- (e.g. no hidden genes, no private loadouts)
}

return {}

]====])

return 'Restore chunk 0 complete!'