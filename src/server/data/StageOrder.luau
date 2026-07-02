--[[
	StageOrder
	Location: src/server/data/StageOrder.luau

	Single source of truth for the ordered story stage sequence.
	MVP-020: hardcoded here pending a dedicated stage/encounter registry.

	Shared by:
	- RemoteHandlers (RequestStoryBattle victory progression)
	- GeneratorService (stageClear generator unlock requirement, DD-029)
--]]

local StageOrder = {}

local STAGE_ORDER = { "story_stage_1", "story_stage_2", "story_stage_3" }

--[[
	StageOrder.getSequence() -> { string }

	Returns the ordered list of story stage ids.
--]]
function StageOrder.getSequence(): { string }
	return STAGE_ORDER
end

--[[
	StageOrder.getIndex(stageId) -> number?

	Returns the 1-based index of stageId in the sequence, or nil if unknown.
--]]
function StageOrder.getIndex(stageId: string): number?
	return table.find(STAGE_ORDER, stageId)
end

return StageOrder
