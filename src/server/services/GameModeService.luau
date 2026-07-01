--[[
	GameModeService
	Location: src/server/services/GameModeService.luau

	Server-authoritative game mode router for approved MVP modes.
	This service orchestrates requests only; combat resolution remains owned by
	CombatService.
--]]

local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)
local GameModeContract = require(game:GetService("ReplicatedStorage").Genesis.Shared.network.GameModeContract)
local BossRegistry = require(script.Parent.Parent.data.BossRegistry)
local CombatService = require(script.Parent.CombatService)

local GameModeService = {}

local ModeIds = GameModeContract.ModeIds

local function _isNonEmptyString(value: any): boolean
	return type(value) == "string" and value ~= ""
end

local function _isArray(value: any): boolean
	if type(value) ~= "table" then
		return false
	end

	local length = 0
	for key, _ in pairs(value) do
		if type(key) ~= "number" or key < 1 or key ~= math.floor(key) then
			return false
		end
		if key > length then
			length = key
		end
	end

	for index = 1, length do
		if value[index] == nil then
			return false
		end
	end

	return true
end

local function _validateRequest(request: any)
	if type(request) ~= "table" then
		return Result.fail("invalid_request", "Game mode request must be a table.")
	end

	if not GameModeContract.isApprovedModeId(request.modeId) then
		return Result.fail("invalid_mode", "Unknown or unapproved game mode.")
	end

	return Result.ok(request)
end

local function _validateStoryRequest(request: any)
	if not _isNonEmptyString(request.playerCreatureId) then
		return Result.fail("invalid_request", "Story mode requires playerCreatureId.")
	end

	if not _isNonEmptyString(request.enemyConfigId) then
		return Result.fail("invalid_request", "Story mode requires enemyConfigId.")
	end

	return Result.ok(request)
end

local function _validateBossLikeRequest(request: any)
	if not _isNonEmptyString(request.bossId) then
		return Result.fail("invalid_request", "Boss and challenge modes require bossId.")
	end

	if not _isArray(request.playerInstanceIds) then
		return Result.fail("invalid_request", "Boss and challenge modes require playerInstanceIds array.")
	end

	return Result.ok(request)
end

function GameModeService.getApprovedModeIds(): { string }
	return GameModeContract.getApprovedModeIds()
end

function GameModeService.resolveModeBattle(player: Player, request: any)
	local requestResult = _validateRequest(request)
	if not requestResult.success then
		return requestResult
	end

	local modeId = request.modeId

	if modeId == ModeIds.STORY then
		local storyResult = _validateStoryRequest(request)
		if not storyResult.success then
			return storyResult
		end
		return CombatService.resolveStoryBattle(player, request.playerCreatureId, request.enemyConfigId)
	end

	if modeId == ModeIds.BOSS then
		local bossResult = _validateBossLikeRequest(request)
		if not bossResult.success then
			return bossResult
		end
		return CombatService.resolveBossBattle(player, request.playerInstanceIds, request.bossId)
	end

	if modeId == ModeIds.CHALLENGE then
		local challengeResult = _validateBossLikeRequest(request)
		if not challengeResult.success then
			return challengeResult
		end
		return CombatService.resolveChallengeBattle(player, request.playerInstanceIds, request.bossId)
	end

	return Result.fail("invalid_mode", "Unknown or unapproved game mode.")
end

function GameModeService.retryModeBattle(player: Player, previousRequest: any)
	-- Auto Retry intentionally reuses the same server validation and routing path.
	return GameModeService.resolveModeBattle(player, previousRequest)
end

function GameModeService.getModeDisplaySnapshot(request: any)
	local requestResult = _validateRequest(request)
	if not requestResult.success then
		return requestResult
	end

	local modeId = request.modeId
	if modeId == ModeIds.STORY then
		return Result.ok({
			modeId = modeId,
			recommendedPower = nil,
		})
	end

	if modeId == ModeIds.BOSS or modeId == ModeIds.CHALLENGE then
		if not _isNonEmptyString(request.bossId) then
			return Result.fail("invalid_request", "Boss and challenge modes require bossId.")
		end

		local bossSnapshot = BossRegistry.getBossSnapshot(request.bossId)
		if not bossSnapshot then
			return Result.fail("invalid_boss", "Boss config not found or disabled.")
		end

		if bossSnapshot.battleMode ~= modeId then
			return Result.fail("invalid_battle_mode", "Boss config battleMode does not match requested mode.")
		end

		return Result.ok({
			modeId = modeId,
			bossId = bossSnapshot.bossId,
			displayName = bossSnapshot.displayName,
			recommendedPower = bossSnapshot.recommendedPower,
			teamSize = bossSnapshot.teamSize,
		})
	end

	return Result.fail("invalid_mode", "Unknown or unapproved game mode.")
end

return GameModeService
