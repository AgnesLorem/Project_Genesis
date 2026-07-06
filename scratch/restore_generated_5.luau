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
getOrCreateFolder(game:GetService("ServerStorage"), "Configs")
local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
getOrCreateModule(p, "TowerChallengeRegistry", [====[
local ServerStorage = game:GetService("ServerStorage")

local TowerChallengeSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.TowerChallengeSchema)

local TowerChallengeRegistry = {}

local _registry: { [string]: any } = {}
local _initialized = false

local function _cloneFloors(floors: { any }): { any }
	local output = {}
	for _, floor in ipairs(floors) do
		table.insert(output, {
			floorId = floor.floorId,
			floorNumber = floor.floorNumber,
			enemyCreatureId = floor.enemyCreatureId,
			recommendedLevel = floor.recommendedLevel,
			isEnabled = floor.isEnabled,
		})
	end
	table.sort(output, function(a, b)
		return a.floorNumber < b.floorNumber
	end)
	return output
end

local function _buildSnapshot(challenge: any): any
	return {
		challengeId = challenge.challengeId,
		displayName = challenge.displayName,
		description = challenge.description,
		isEnabled = challenge.isEnabled,
		floors = _cloneFloors(challenge.floors),
	}
end

local function _getChallengeFolder(): Folder?
	local configs = ServerStorage:FindFirstChild("Configs")
	if not configs then
		warn("[TowerChallengeRegistry] ServerStorage.Configs folder not found.")
		return nil
	end

	local folder = configs:FindFirstChild("tower_challenges")
	if not folder then
		warn("[TowerChallengeRegistry] ServerStorage.Configs.tower_challenges folder not found.")
		return nil
	end

	if not folder:IsA("Folder") then
		warn("[TowerChallengeRegistry] ServerStorage.Configs.tower_challenges is not a Folder.")
		return nil
	end

	return folder :: Folder
end

function TowerChallengeRegistry.init()
	if _initialized then
		warn("[TowerChallengeRegistry] Already initialized. Skipping.")
		return
	end

	local folder = _getChallengeFolder()
	if folder then
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("ModuleScript") then
				local ok, record = pcall(require, child :: ModuleScript)
				if ok and type(record) == "table" then
					local result = TowerChallengeSchema.validate(record)
					if result.success then
						local challenge = result.value
						if challenge.isEnabled then
							if _registry[challenge.challengeId] then
								warn(string.format("[TowerChallengeRegistry] Duplicate challengeId '%s' - skipping.", challenge.challengeId))
							else
								_registry[challenge.challengeId] = challenge
								print(string.format("[TowerChallengeRegistry] Loaded challenge '%s'.", challenge.challengeId))
							end
						end
					else
						warn(string.format(
							"[TowerChallengeRegistry] Validation failed for '%s': %s",
							tostring(record.challengeId or record.id or child.Name),
							result.message or result.code
						))
					end
				else
					warn(string.format("[TowerChallengeRegistry] Failed to require '%s': %s", child:GetFullName(), tostring(record)))
				end
			end
		end
	end

	_initialized = true
end

function TowerChallengeRegistry.getChallenge(challengeId: string): any
	return _registry[challengeId]
end

function TowerChallengeRegistry.getFloor(challengeId: string, floorId: string): any
	local challenge = TowerChallengeRegistry.getChallenge(challengeId)
	if not challenge then
		return nil
	end

	for _, floor in ipairs(challenge.floors) do
		if floor.floorId == floorId then
			return floor
		end
	end

	return nil
end

function TowerChallengeRegistry.getAllChallenges(): { any }
	local list = {}
	for _, challenge in pairs(_registry) do
		table.insert(list, challenge)
	end
	return list
end

function TowerChallengeRegistry.getAllChallengeSnapshots(): { any }
	local list = {}
	for _, challenge in pairs(_registry) do
		table.insert(list, _buildSnapshot(challenge))
	end
	table.sort(list, function(a, b)
		return a.challengeId < b.challengeId
	end)
	return list
end

function TowerChallengeRegistry.isInitialized(): boolean
	return _initialized
end

return TowerChallengeRegistry

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "data")
getOrCreateModule(p, "WorldRegistry", [====[
--[[
	WorldRegistry
	Location: src/server/data/WorldRegistry.luau

	Loads enabled world configs, validates them via WorldSchema, and exposes
	lookup/display snapshots. This module owns no player runtime state.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)
local WorldSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.WorldSchema)

local WorldRegistry = {}
local _registry: { [string]: any } = {}
local _initialized = false

local function _cloneArray(value: { any }): { any }
	local output = {}
	for _, item in ipairs(value) do
		table.insert(output, item)
	end
	return output
end

local function _buildSnapshot(world: any): any
	return {
		worldId = world.worldId,
		displayName = world.displayName,
		description = world.description,
		unlockRequirementRefs = _cloneArray(world.unlockRequirementRefs),
		encounterRefs = _cloneArray(world.encounterRefs),
		bossRefs = _cloneArray(world.bossRefs),
		recommendedPowerRange = {
			min = world.recommendedPowerRange.min,
			max = world.recommendedPowerRange.max,
		},
		sortOrder = world.sortOrder,
		isEnabled = world.isEnabled,
	}
end

function WorldRegistry.init()
	if _initialized then
		warn("[WorldRegistry] Already initialized. Skipping.")
		return
	end

	local records = ConfigRegistry.load("worlds")
	for _, record in ipairs(records) do
		local result = WorldSchema.validate(record)
		if result.success then
			local world = result.value
			if world.isEnabled then
				local worldId = world.worldId
				if _registry[worldId] then
					warn(string.format("[WorldRegistry] Duplicate worldId '%s' - skipping.", worldId))
				else
					_registry[worldId] = world
				end
			end
		else
			warn(string.format(
				"[WorldRegistry] Validation failed for '%s': %s",
				tostring(record.worldId or record.id or "unknown"),
				result.message or result.code
			))
		end
	end

	_initialized = true
end

function WorldRegistry.getWorld(worldId: string): any
	return _registry[worldId]
end

function WorldRegistry.getWorldSnapshot(worldId: string): any
	local world = WorldRegistry.getWorld(worldId)
	if not world then
		return nil
	end

	return _buildSnapshot(world)
end

function WorldRegistry.getAllWorlds(): { any }
	local list = {}
	for _, world in pairs(_registry) do
		table.insert(list, world)
	end
	return list
end

function WorldRegistry.getAllWorldSnapshots(): { any }
	local list = {}
	for _, world in pairs(_registry) do
		table.insert(list, _buildSnapshot(world))
	end
	table.sort(list, function(a, b)
		if a.sortOrder ~= b.sortOrder then
			return a.sortOrder < b.sortOrder
		end
		return a.worldId < b.worldId
	end)
	return list
end

function WorldRegistry.isInitialized(): boolean
	return _initialized
end

return WorldRegistry

]====])

local p = ensurePath(game:GetService("ServerScriptService").Server, "network")
getOrCreateModule(p, "CreatureSnapshotBuilder", [====[
local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)
local CreatureSnapshotType = require(game:GetService("ReplicatedStorage").Genesis.Shared.network.CreatureSnapshotType)

local CreatureSnapshotBuilder = {}

-- Server builds the snapshot to ensure no server-only metadata leaks
function CreatureSnapshotBuilder.build(instance: any): CreatureSnapshotType.CreatureSnapshotType?
    local config = CreatureRegistry.getCreature(instance.creatureId)
    if not config then
        return nil
    end

    return {
        instanceId = instance.instanceId,
        creatureId = instance.creatureId,
        displayName = config.displayName
    }
end

return CreatureSnapshotBuilder

]====])

return 'Restore chunk 5 complete!'