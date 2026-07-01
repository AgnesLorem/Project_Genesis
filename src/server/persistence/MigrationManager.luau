--[[
	MigrationManager
	Location: src/server/persistence/MigrationManager.luau
	
	Handles schema migrations for player save data.
--]]

local MigrationManager = {}

local CURRENT_SAVE_VERSION = 3
local DEFAULT_UNLOCKED_STAGES = { "story_stage_1" }

-- v0 (Mock/Empty) to v1
local function _migrateToV1(data: any): any
    if type(data) ~= "table" then
        data = {}
    end
    
    local migrated = {
        saveVersion = 1,
        creatureInstances = data.creatureInstances or {},
        economyState = data.economyState or {
            balances = {},
            generators = {},
        },
        collectionState = data.collectionState or {
            discoveredCreatureIds = {},
        },
    }
    
    return migrated
end

-- v1 to v2: added activeCreatureInstanceId
local function _migrateToV2(data: any): any
    data.saveVersion = 2
    -- Default nil — will be set when player first selects a creature
    if data.activeCreatureInstanceId == nil then
        data.activeCreatureInstanceId = nil
    end
    return data
end

-- v2 to v3: added worldProgression (persistent story stage unlocks)
local function _migrateToV3(data: any): any
    data.saveVersion = 3
    if type(data.worldProgression) ~= "table" then
        data.worldProgression = { unlockedStages = { table.unpack(DEFAULT_UNLOCKED_STAGES) } }
    end
    return data
end

function MigrationManager.migrate(data: any): any
    if not data or type(data) ~= "table" then
        data = _migrateToV1(data)
    end
    
    local version = data.saveVersion or 0
    
    if version < 1 then
        data = _migrateToV1(data)
    end
    
    -- Backfill guard: ensure required fields exist even on v1 saves
    -- that may have been written before the full schema was in place.
    if not data.creatureInstances then data.creatureInstances = {} end
    if type(data.economyState) ~= "table" then
        data.economyState = { balances = {}, generators = {} }
    else
        if not data.economyState.balances then data.economyState.balances = {} end
        if not data.economyState.generators then data.economyState.generators = {} end
    end
    if type(data.collectionState) ~= "table" then
        data.collectionState = { discoveredCreatureIds = {} }
    else
        if not data.collectionState.discoveredCreatureIds then data.collectionState.discoveredCreatureIds = {} end
    end

    if data.saveVersion < 2 then
        data = _migrateToV2(data)
    end

    if data.saveVersion < 3 then
        data = _migrateToV3(data)
    end

    -- v3+ guard: ensure worldProgression.unlockedStages is a valid, non-empty
    -- array of strings. Falls back to the default starting stage otherwise.
    if type(data.worldProgression) ~= "table" then
        data.worldProgression = { unlockedStages = { table.unpack(DEFAULT_UNLOCKED_STAGES) } }
    else
        local stages = data.worldProgression.unlockedStages
        local isValid = type(stages) == "table"
        if isValid then
            local count = 0
            for key, stageId in pairs(stages) do
                count += 1
                if type(key) ~= "number" or type(stageId) ~= "string" or stageId == "" then
                    isValid = false
                    break
                end
            end
            if count == 0 then
                isValid = false
            end
        end
        if not isValid then
            data.worldProgression.unlockedStages = { table.unpack(DEFAULT_UNLOCKED_STAGES) }
        end
    end

    -- v2+ guard: ensure activeCreatureInstanceId key exists (even if nil)
    -- and that it references a creature the player actually owns.
    -- If it points to a non-existent instance, clear it so auto-recovery
    -- can select a valid one at runtime.
    if data.activeCreatureInstanceId ~= nil then
        local instances = data.creatureInstances or {}
        local stillOwned = (
            type(instances[data.activeCreatureInstanceId]) == "table"
        )
        if not stillOwned then
            warn(string.format(
                "[MigrationManager] activeCreatureInstanceId '%s' no longer owned — cleared.",
                tostring(data.activeCreatureInstanceId)
            ))
            data.activeCreatureInstanceId = nil
        end
    end
    
    return data
end

function MigrationManager.getCurrentVersion(): number
    return CURRENT_SAVE_VERSION
end

function MigrationManager.getTemplate(): any
    return {
        saveVersion = CURRENT_SAVE_VERSION,
        creatureInstances = {},
        economyState = {
            balances = {},
            generators = {},
        },
        collectionState = {
            discoveredCreatureIds = {},
        },
        activeCreatureInstanceId = nil,
        worldProgression = {
            unlockedStages = { table.unpack(DEFAULT_UNLOCKED_STAGES) },
        },
    }
end

return MigrationManager
