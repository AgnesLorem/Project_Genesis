--[[
	SaveService
	Location: src/server/services/SaveService.luau

	Persistence is owned by SaveService. Gameplay services read and mutate the
	loaded save table through this module; DataStore access stays isolated in
	DataStoreWrapper.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DataStoreWrapper = require(script.Parent.Parent.persistence.DataStoreWrapper)
local SaveKeyBuilder = require(script.Parent.Parent.persistence.SaveKeyBuilder)
local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local SaveService = {}

local AUTOSAVE_INTERVAL_SECONDS = 60
local STUDIO_FALLBACK_USER_ID = 1000000001

local savesByUserId: { [number]: any } = {}
local dirtyByUserId: { [number]: boolean } = {}
local loadFailedByUserId: { [number]: string } = {}
local initialized = false
local shuttingDown = false

local function _createDefaultSave()
	return {
		schemaVersion = 1,
		creatureInstances = {},
		economyState = {
			balances = {},
			generators = {},
		},
		collectionState = {
			discoveredCreatureIds = {},
		},
	}
end

local function _normalizeSave(save: any): any
	if type(save) ~= "table" then
		save = _createDefaultSave()
	end

	if type(save.schemaVersion) ~= "number" then
		save.schemaVersion = 1
	end

	if type(save.creatureInstances) ~= "table" then
		save.creatureInstances = {}
	end

	if type(save.economyState) ~= "table" then
		save.economyState = {
			balances = {},
			generators = {},
		}
	end
	if type(save.economyState.balances) ~= "table" then
		save.economyState.balances = {}
	end
	if type(save.economyState.generators) ~= "table" then
		save.economyState.generators = {}
	end

	if type(save.collectionState) ~= "table" then
		save.collectionState = {
			discoveredCreatureIds = {},
		}
	end
	if type(save.collectionState.discoveredCreatureIds) ~= "table" then
		save.collectionState.discoveredCreatureIds = {}
	end

	return save
end

local function _resolveUserId(player: any): number?
	if typeof(player) == "Instance" and player:IsA("Player") then
		if SaveKeyBuilder.validateUserId(player.UserId) then
			return player.UserId
		end

		if RunService:IsStudio() then
			return STUDIO_FALLBACK_USER_ID
		end
		return nil
	end

	if type(player) == "table" and SaveKeyBuilder.validateUserId(player.UserId) then
		return player.UserId
	end

	if SaveKeyBuilder.validateUserId(player) then
		return player
	end

	return nil
end

local function _buildKey(userId: number): string?
	return SaveKeyBuilder.buildPlayerKey(userId)
end

local function _loadUserId(userId: number)
	if savesByUserId[userId] then
		return Result.ok(savesByUserId[userId])
	end

	local key = _buildKey(userId)
	if not key then
		return Result.fail("invalid_user_id", "Cannot build save key for player.")
	end

	local loadResult = DataStoreWrapper.load(SaveKeyBuilder.getStoreName(), key)
	if not loadResult.ok then
		local category = loadResult.errorCategory or "unknown_error"
		loadFailedByUserId[userId] = category
		savesByUserId[userId] = _createDefaultSave()
		dirtyByUserId[userId] = false
		warn(string.format("[SaveService] Load failed for userId %d. Category: %s", userId, category))
		return Result.fail("load_failed", category)
	end

	local save = _normalizeSave(loadResult.data)
	savesByUserId[userId] = save
	dirtyByUserId[userId] = loadResult.data == nil
	loadFailedByUserId[userId] = nil

	if loadResult.data == nil then
		print(string.format("[SaveService] Created new save for userId %d.", userId))
	else
		print(string.format("[SaveService] Loaded save for userId %d.", userId))
	end

	return Result.ok(save)
end

function SaveService.loadPlayer(player: any)
	local userId = _resolveUserId(player)
	if not userId then
		return Result.fail("invalid_user_id", "Player has no valid UserId for save load.")
	end

	return _loadUserId(userId)
end

function SaveService.getPlayerSave(player: any): any
	local userId = _resolveUserId(player)
	if not userId then
		warn("[SaveService] getPlayerSave called without a valid player/UserId.")
		return nil
	end

	if not savesByUserId[userId] then
		local loadResult = _loadUserId(userId)
		if not loadResult.success then
			return savesByUserId[userId]
		end
	end

	return savesByUserId[userId]
end

function SaveService.markDirty(player: any)
	local userId = _resolveUserId(player)
	if not userId then
		return Result.fail("invalid_user_id", "Cannot mark save dirty without a valid UserId.")
	end

	if savesByUserId[userId] then
		dirtyByUserId[userId] = true
	end

	return Result.ok(nil)
end

function SaveService.savePlayer(player: any)
	local userId = _resolveUserId(player)
	if not userId then
		return Result.fail("invalid_user_id", "Cannot save without a valid UserId.")
	end

	local save = savesByUserId[userId]
	if not save then
		local loadResult = _loadUserId(userId)
		if not loadResult.success then
			return loadResult
		end
		save = loadResult.value
	end

	if loadFailedByUserId[userId] then
		return Result.fail("load_failed", "Refusing to overwrite persisted data after failed load.")
	end

	local key = _buildKey(userId)
	if not key then
		return Result.fail("invalid_user_id", "Cannot build save key for player.")
	end

	local saveResult = DataStoreWrapper.save(SaveKeyBuilder.getStoreName(), key, _normalizeSave(save))
	if not saveResult.ok then
		dirtyByUserId[userId] = true
		return Result.fail("save_failed", saveResult.errorCategory or "unknown_error")
	end

	dirtyByUserId[userId] = false
	print(string.format("[SaveService] Saved player data for userId %d.", userId))
	return Result.ok(nil)
end

function SaveService.saveDirtyPlayers()
	for userId, isDirty in pairs(dirtyByUserId) do
		if isDirty and savesByUserId[userId] then
			SaveService.savePlayer(userId)
		end
	end
end

function SaveService.unloadPlayer(player: any)
	local userId = _resolveUserId(player)
	if not userId then
		return Result.fail("invalid_user_id", "Cannot unload without a valid UserId.")
	end

	if savesByUserId[userId] and not loadFailedByUserId[userId] then
		SaveService.savePlayer(userId)
	end

	savesByUserId[userId] = nil
	dirtyByUserId[userId] = nil
	loadFailedByUserId[userId] = nil

	return Result.ok(nil)
end

function SaveService.init()
	if initialized then
		return
	end
	initialized = true

	Players.PlayerAdded:Connect(function(player)
		SaveService.loadPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		SaveService.unloadPlayer(player)
	end)

	game:BindToClose(function()
		shuttingDown = true
		for _, player in ipairs(Players:GetPlayers()) do
			SaveService.unloadPlayer(player)
		end
	end)

	task.spawn(function()
		while not shuttingDown do
			task.wait(AUTOSAVE_INTERVAL_SECONDS)
			if not shuttingDown then
				SaveService.saveDirtyPlayers()
			end
		end
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			SaveService.loadPlayer(player)
		end)
	end
end

function SaveService.wipePlayerSave(player: any)
	local userId = _resolveUserId(player)
	if not userId then
		return Result.fail("invalid_user_id", "Cannot wipe without a valid UserId.")
	end

	savesByUserId[userId] = _createDefaultSave()
	dirtyByUserId[userId] = true
	loadFailedByUserId[userId] = nil
	return Result.ok(nil)
end

return SaveService
