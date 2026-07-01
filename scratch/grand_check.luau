local passed = 0
local total = 0
local missingModules = {}

local function test(name, condition)
    total += 1
    if condition then
        passed += 1
        print("✅ " .. name)
    else
        warn("❌ " .. name)
    end
end

local function safeRequire(pathFunc, name)
    local success, module = pcall(pathFunc)
    if success and module then
        return module
    else
        table.insert(missingModules, name)
        warn(string.format("❌ Missing Module: %s | Error: %s", name, tostring(module)))
        return nil
    end
end

print("\n\n=== GRAND CHECK: MVP 001 - 004 ===")

-- ==========================================
-- MVP-001: Core Framework
-- ==========================================
print("\n--- MVP-001: Core Framework ---")
local Result = safeRequire(function() return require(game.ReplicatedStorage.Shared.utilities.Result) end, "Result")
local ServiceLifecycle = safeRequire(function() return require(game.ServerScriptService.Server.runtime.ServiceLifecycle) end, "ServiceLifecycle")

if Result then
    test("Result.ok works", Result.ok("test").success == true)
    test("Result.fail works", Result.fail("error").success == false)
end

-- ==========================================
-- MVP-002: Save / Config Database
-- ==========================================
print("\n--- MVP-002: Persistence & Config ---")
local ConfigRegistry = safeRequire(function() return require(game.ServerScriptService.Server.data.ConfigRegistry) end, "ConfigRegistry")
local DataStoreWrapper = safeRequire(function() return require(game.ServerScriptService.Server.persistence.DataStoreWrapper) end, "DataStoreWrapper")
local PersistenceReporter = safeRequire(function() return require(game.ServerScriptService.Server.persistence.PersistenceReporter) end, "PersistenceReporter")

if ConfigRegistry then
    test("ConfigRegistry exists", type(ConfigRegistry) == "table")
end

-- ==========================================
-- MVP-003: UI Foundation
-- ==========================================
print("\n--- MVP-003: UI Foundation ---")
local ScreenRouter = safeRequire(function() return require(game.StarterPlayer.StarterPlayerScripts.Client.controllers.ScreenRouter) end, "ScreenRouter")
local ClientState = safeRequire(function() return require(game.StarterPlayer.StarterPlayerScripts.Client.models.ClientState) end, "ClientState")
local UIComponents = safeRequire(function() return require(game.StarterPlayer.StarterPlayerScripts.Client.views.UIComponents) end, "UIComponents")
local StatePatterns = safeRequire(function() return require(game.StarterPlayer.StarterPlayerScripts.Client.views.StatePatterns) end, "StatePatterns")

if ClientState then
    ClientState.set("test_key", 123)
    test("ClientState cache works", ClientState.get("test_key") == 123)
end

if UIComponents then
    local btn = UIComponents.createBaseButton("TestBtn")
    test("UIComponents can create button", btn and btn:IsA("TextButton"))
end

-- ==========================================
-- MVP-004: Creature System
-- ==========================================
print("\n--- MVP-004: Creature System ---")
local CreatureSchema = safeRequire(function() return require(game.ReplicatedStorage.Shared.data.CreatureSchema) end, "CreatureSchema")
local CreatureRegistry = safeRequire(function() return require(game.ReplicatedStorage.Shared.data.CreatureRegistry) end, "CreatureRegistry")
local SaveService = safeRequire(function() return require(game.ServerScriptService.Server.services.SaveService) end, "SaveService")
local CreatureService = safeRequire(function() return require(game.ServerScriptService.Server.services.CreatureService) end, "CreatureService")
local CreatureSnapshotBuilder = safeRequire(function() return require(game.ServerScriptService.Server.network.CreatureSnapshotBuilder) end, "CreatureSnapshotBuilder")

if CreatureSchema and CreatureService then
    local mockPlayer = {} :: any
    local res = CreatureService.tryGrantCreature(mockPlayer, "c_001")
    test("CreatureService exists and handles grant safely", res ~= nil)
end

print("\n======================================")
print(string.format("Grand Check Completed: %d/%d passed", passed, total))

if #missingModules > 0 then
    print("\n⚠️ WARNING: The following modules are missing or failed to require:")
    for _, name in ipairs(missingModules) do
        print(" - " .. name)
    end
else
    print("\n✅ All MVP 001 - 004 modules are present.")
end

return string.format("Completed: %d/%d. Missing modules: %d", passed, total, #missingModules)
