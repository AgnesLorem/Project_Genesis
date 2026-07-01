local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local function getOrCreateFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

local function createModule(parent, name, source)
    local module = parent:FindFirstChild(name)
    if not module then
        module = Instance.new("ModuleScript")
        module.Name = name
        module.Parent = parent
    end
    module.Source = source
    return module
end

-- Create Folders
local sharedFolder = getOrCreateFolder(ReplicatedStorage, "Shared")
local sharedData = getOrCreateFolder(sharedFolder, "data")
local sharedNetwork = getOrCreateFolder(sharedFolder, "network")

local serverFolder = getOrCreateFolder(ServerScriptService, "Server")
local serverServices = getOrCreateFolder(serverFolder, "services")
local serverNetwork = getOrCreateFolder(serverFolder, "network")

-- We also need a Result module for Shared since CreatureSchema and CreatureService depend on it.
local resultSource = [==[
local Result = {}
function Result.ok(value) return { success = true, value = value } end
function Result.fail(err) return { success = false, error = err } end
return Result
]==]
createModule(sharedFolder, "Result", resultSource)

-- Insert CreatureSchema
local creatureSchemaSource = [==[
local Result = require(script.Parent.Parent.Result)

local CreatureSchema = {}

-- Validates exactly the fields defined in docs/DATA_SCHEMA.md
function CreatureSchema.validate(data: any)
    if type(data) ~= "table" then return Result.fail("Creature data must be a table") end
    if type(data.creatureId) ~= "string" then return Result.fail("Missing or invalid creatureId (string)") end
    if type(data.schemaVersion) ~= "number" then return Result.fail("Missing or invalid schemaVersion (number)") end
    if type(data.displayName) ~= "string" then return Result.fail("Missing or invalid displayName (string)") end
    if type(data.description) ~= "string" then return Result.fail("Missing or invalid description (string)") end
    if type(data.baseStats) ~= "table" then return Result.fail("Missing or invalid baseStats (table)") end
    if type(data.skillIds) ~= "table" then return Result.fail("Missing or invalid skillIds (array)") end
    if type(data.geneSlots) ~= "table" then return Result.fail("Missing or invalid geneSlots (array)") end
    if type(data.evolutionLineId) ~= "string" then return Result.fail("Missing or invalid evolutionLineId (string)") end
    if type(data.collectionCategory) ~= "string" then return Result.fail("Missing or invalid collectionCategory (string enum)") end
    if type(data.visualRef) ~= "string" then return Result.fail("Missing or invalid visualRef (string)") end
    if type(data.sortOrder) ~= "number" then return Result.fail("Missing or invalid sortOrder (number)") end
    if type(data.isEnabled) ~= "boolean" then return Result.fail("Missing or invalid isEnabled (boolean)") end

    return Result.ok(data)
end
return CreatureSchema
]==]
createModule(sharedData, "CreatureSchema", creatureSchemaSource)

-- Insert CreatureRegistry
local creatureRegistrySource = [==[
local CreatureSchema = require(script.Parent.CreatureSchema)
local Result = require(script.Parent.Parent.Result)

local CreatureRegistry = {}
local registry = {}

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

function CreatureRegistry.getCreature(id: string) return registry[id] end
function CreatureRegistry.getAllCreatures()
    local list = {}
    for _, creature in pairs(registry) do table.insert(list, creature) end
    return list
end
return CreatureRegistry
]==]
createModule(sharedData, "CreatureRegistry", creatureRegistrySource)

-- Insert CreatureSnapshotType
local snapshotTypeSource = [==[
export type CreatureSnapshotType = {
    instanceId: string,
    creatureId: string,
    displayName: string,
}
return {}
]==]
createModule(sharedNetwork, "CreatureSnapshotType", snapshotTypeSource)

-- Insert SaveService
local saveServiceSource = [==[
local SaveService = {}
function SaveService.getPlayerSave(player: Player): any
    return { creatureInstances = {} }
end
function SaveService.savePlayer(player: Player) end
return SaveService
]==]
createModule(serverServices, "SaveService", saveServiceSource)

-- Insert CreatureService
local creatureServiceSource = [==[
local CreatureRegistry = require(game.ReplicatedStorage.Shared.data.CreatureRegistry)
local SaveService = require(script.Parent.SaveService)
local Result = require(game.ReplicatedStorage.Shared.Result)
local HttpService = game:GetService("HttpService")

local CreatureService = {}

function CreatureService.tryGrantCreature(player: Player, creatureId: string)
    local config = CreatureRegistry.getCreature(creatureId)
    if not config then return Result.fail("Invalid Creature ID rejected.") end
    if not config.isEnabled then return Result.fail("Disabled Creature rejected.") end

    local playerSave = SaveService.getPlayerSave(player)
    local instances = playerSave.creatureInstances or {}
    
    for _, instance in pairs(instances) do
        if instance.creatureId == creatureId then
            return Result.fail("Duplicate grant behavior follows documented rule: cannot grant duplicate.")
        end
    end

    local instanceId = HttpService:GenerateGUID(false)
    local newInstance = {
        instanceId = instanceId,
        creatureId = creatureId,
        acquiredAt = os.time()
    }

    instances[instanceId] = newInstance
    playerSave.creatureInstances = instances
    SaveService.savePlayer(player)

    return Result.ok(newInstance)
end

function CreatureService.getPlayerCreatures(player: Player)
    local playerSave = SaveService.getPlayerSave(player)
    return playerSave.creatureInstances or {}
end
return CreatureService
]==]
createModule(serverServices, "CreatureService", creatureServiceSource)

-- Insert CreatureSnapshotBuilder
local snapshotBuilderSource = [==[
local CreatureRegistry = require(game.ReplicatedStorage.Shared.data.CreatureRegistry)

local CreatureSnapshotBuilder = {}
function CreatureSnapshotBuilder.build(instance: any)
    local config = CreatureRegistry.getCreature(instance.creatureId)
    if not config then return nil end

    return {
        instanceId = instance.instanceId,
        creatureId = instance.creatureId,
        displayName = config.displayName
    }
end
return CreatureSnapshotBuilder
]==]
createModule(serverNetwork, "CreatureSnapshotBuilder", snapshotBuilderSource)

return "Successfully created modules in Studio"
