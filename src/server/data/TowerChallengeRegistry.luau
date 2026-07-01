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
