local CreatureSchema = require(game.ReplicatedStorage.Shared.data.CreatureSchema)
local CreatureRegistry = require(game.ReplicatedStorage.Shared.data.CreatureRegistry)
local CreatureService = require(game.ServerScriptService.Server.services.CreatureService)
local CreatureSnapshotBuilder = require(game.ServerScriptService.Server.network.CreatureSnapshotBuilder)

local passed = 0
local total = 0
local function test(name, result)
    total += 1
    if result then
        passed += 1
        print("✅ " .. name)
    else
        warn("❌ " .. name)
    end
end

-- 1. Test Schema
local validConfig = {
    creatureId = "c_001",
    schemaVersion = 1,
    displayName = "Test Creature",
    description = "A valid creature.",
    baseStats = {hp=10, atk=5, def=5, spd=5},
    skillIds = {},
    geneSlots = {},
    evolutionLineId = "evo_none",
    collectionCategory = "creature",
    visualRef = "vis_001",
    sortOrder = 1,
    isEnabled = true
}

local invalidConfig = {
    creatureId = "c_002",
    -- missing schemaVersion
}

test("Schema validates valid config", CreatureSchema.validate(validConfig).success)
test("Schema rejects invalid config", CreatureSchema.validate(invalidConfig).success == false)

-- 2. Test Registry
CreatureRegistry.loadConfig({
    ["c_001"] = validConfig,
    ["c_invalid"] = invalidConfig,
    ["c_disabled"] = {
        creatureId = "c_disabled",
        schemaVersion = 1,
        displayName = "Disabled",
        description = "Disabled.",
        baseStats = {}, skillIds = {}, geneSlots = {}, evolutionLineId = "",
        collectionCategory = "creature", visualRef = "", sortOrder = 2,
        isEnabled = false
    }
})

test("Registry loaded valid config", CreatureRegistry.getCreature("c_001") ~= nil)
test("Registry rejected invalid config", CreatureRegistry.getCreature("c_invalid") == nil)

-- 3. Test CreatureService
local mockPlayer = Instance.new("Player")

test("tryGrantCreature rejects unknown ID", CreatureService.tryGrantCreature(mockPlayer, "c_unknown").success == false)
test("tryGrantCreature rejects disabled creature", CreatureService.tryGrantCreature(mockPlayer, "c_disabled").success == false)

local grantResult = CreatureService.tryGrantCreature(mockPlayer, "c_001")
test("tryGrantCreature grants valid creature", grantResult.success == true)

test("tryGrantCreature rejects duplicate grant", CreatureService.tryGrantCreature(mockPlayer, "c_001").success == false)

-- 4. Test SnapshotBuilder
local instance = grantResult.value
local snapshot = CreatureSnapshotBuilder.build(instance)

test("Snapshot builds successfully", snapshot ~= nil)
test("Snapshot has instanceId", snapshot.instanceId == instance.instanceId)
test("Snapshot has displayName", snapshot.displayName == "Test Creature")
test("Snapshot has no server-only acquiredAt metadata", snapshot.acquiredAt == nil)

return string.format("Tests Finished: %d/%d Passed", passed, total)
