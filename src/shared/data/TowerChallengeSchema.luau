local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local TowerChallengeSchema = {}

local function _isNonEmptyString(value: any): boolean
	return type(value) == "string" and value ~= ""
end

local function _isInteger(value: any): boolean
	return type(value) == "number" and value == math.floor(value)
end

local function _validateFloor(floor: any, index: number, seenFloorIds: { [string]: boolean }, seenFloorNumbers: { [number]: boolean })
	if type(floor) ~= "table" then
		return Result.fail("invalid_floor", string.format("floors[%d] must be a table.", index))
	end

	if not _isNonEmptyString(floor.floorId) then
		return Result.fail("invalid_floor_id", string.format("floors[%d].floorId must be a non-empty string.", index))
	end

	if seenFloorIds[floor.floorId] then
		return Result.fail("duplicate_floor_id", string.format("Duplicate floorId '%s'.", floor.floorId))
	end
	seenFloorIds[floor.floorId] = true

	if not _isInteger(floor.floorNumber) or floor.floorNumber < 1 then
		return Result.fail("invalid_floor_number", string.format("floors[%d].floorNumber must be a positive integer.", index))
	end

	if seenFloorNumbers[floor.floorNumber] then
		return Result.fail("duplicate_floor_number", string.format("Duplicate floorNumber '%d'.", floor.floorNumber))
	end
	seenFloorNumbers[floor.floorNumber] = true

	if not _isNonEmptyString(floor.enemyCreatureId) then
		return Result.fail("invalid_enemy_creature_id", string.format("floors[%d].enemyCreatureId must be a non-empty string.", index))
	end

	if type(floor.recommendedLevel) ~= "number" or floor.recommendedLevel < 0 then
		return Result.fail("invalid_recommended_level", string.format("floors[%d].recommendedLevel must be a non-negative number.", index))
	end

	if type(floor.isEnabled) ~= "boolean" then
		return Result.fail("invalid_enabled_flag", string.format("floors[%d].isEnabled must be boolean.", index))
	end

	return Result.ok(floor)
end

function TowerChallengeSchema.validate(record: any)
	if type(record) ~= "table" then
		return Result.fail("invalid_record", "Tower challenge config must be a table.")
	end

	if not _isNonEmptyString(record.id) then
		return Result.fail("invalid_id", "Tower challenge config requires non-empty id.")
	end

	if not _isNonEmptyString(record.challengeId) then
		return Result.fail("invalid_challenge_id", "Tower challenge config requires non-empty challengeId.")
	end

	if record.id ~= record.challengeId then
		return Result.fail("id_mismatch", "Tower challenge id and challengeId must match.")
	end

	if not _isInteger(record.schemaVersion) or record.schemaVersion < 1 then
		return Result.fail("invalid_schema_version", "Tower challenge schemaVersion must be a positive integer.")
	end

	if not _isNonEmptyString(record.displayName) then
		return Result.fail("invalid_display_name", "Tower challenge displayName must be a non-empty string.")
	end

	if type(record.description) ~= "string" then
		return Result.fail("invalid_description", "Tower challenge description must be a string.")
	end

	if type(record.isEnabled) ~= "boolean" then
		return Result.fail("invalid_enabled_flag", "Tower challenge isEnabled must be boolean.")
	end

	if type(record.floors) ~= "table" or #record.floors == 0 then
		return Result.fail("invalid_floors", "Tower challenge requires at least one floor.")
	end

	local seenFloorIds = {}
	local seenFloorNumbers = {}
	for index, floor in ipairs(record.floors) do
		local floorResult = _validateFloor(floor, index, seenFloorIds, seenFloorNumbers)
		if not floorResult.success then
			return floorResult
		end
	end

	return Result.ok(record)
end

return TowerChallengeSchema
