--[[
	GameModeContract
	Location: src/shared/network/GameModeContract.luau

	Shared contract for approved MVP game mode identifiers.
	Do not add new modes here unless source-of-truth docs approve them.
--]]

local GameModeContract = {}

GameModeContract.ModeIds = table.freeze({
	STORY = "story",
	BOSS = "boss",
	CHALLENGE = "challenge",
})

local APPROVED_MODE_IDS = table.freeze({
	[GameModeContract.ModeIds.STORY] = true,
	[GameModeContract.ModeIds.BOSS] = true,
	[GameModeContract.ModeIds.CHALLENGE] = true,
})

function GameModeContract.isApprovedModeId(modeId: any): boolean
	return type(modeId) == "string" and APPROVED_MODE_IDS[modeId] == true
end

function GameModeContract.getApprovedModeIds(): { string }
	return {
		GameModeContract.ModeIds.STORY,
		GameModeContract.ModeIds.BOSS,
		GameModeContract.ModeIds.CHALLENGE,
	}
end

return GameModeContract
