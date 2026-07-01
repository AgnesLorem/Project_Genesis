local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local ItemSchema = {}

local VALID_ITEM_TYPES = {
	equipment = true,
	consumable = true,
	material = true,
}

local VALID_RARITIES = {
	Common = true,
	Rare = true,
	Epic = true,
	Legend = true,
}

local function _isNonEmptyString(value: any): boolean
	return type(value) == "string" and value ~= ""
end

local function _isPositiveInteger(value: any): boolean
	return type(value) == "number" and value > 0 and value == math.floor(value)
end

function ItemSchema.validate(data: any)
	if type(data) ~= "table" then
		return Result.fail("validation_failed", "Item config must be a table.")
	end

	if not _isNonEmptyString(data.id) then
		return Result.fail("validation_failed", "Missing or invalid id.")
	end

	if not _isNonEmptyString(data.itemId) then
		return Result.fail("validation_failed", "Missing or invalid itemId.")
	end

	if data.id ~= data.itemId then
		return Result.fail("validation_failed", "id must match itemId.")
	end

	if type(data.schemaVersion) ~= "number" or data.schemaVersion ~= math.floor(data.schemaVersion) then
		return Result.fail("validation_failed", "Missing or invalid schemaVersion.")
	end

	if not _isNonEmptyString(data.displayName) then
		return Result.fail("validation_failed", "Missing or invalid displayName.")
	end

	if type(data.description) ~= "string" then
		return Result.fail("validation_failed", "Missing or invalid description.")
	end

	if type(data.itemType) ~= "string" or not VALID_ITEM_TYPES[data.itemType] then
		return Result.fail("validation_failed", "Missing or invalid itemType.")
	end

	if type(data.rarity) ~= "string" or not VALID_RARITIES[data.rarity] then
		return Result.fail("validation_failed", "Missing or invalid rarity.")
	end

	if not _isNonEmptyString(data.iconSlot) then
		return Result.fail("validation_failed", "Missing or invalid iconSlot.")
	end

	if not _isPositiveInteger(data.maxStack) then
		return Result.fail("validation_failed", "Missing or invalid maxStack.")
	end

	if type(data.sortOrder) ~= "number" or data.sortOrder ~= math.floor(data.sortOrder) then
		return Result.fail("validation_failed", "Missing or invalid sortOrder.")
	end

	if type(data.tags) ~= "table" then
		return Result.fail("validation_failed", "Missing or invalid tags.")
	end

	if data.itemType == "equipment" then
		if not _isNonEmptyString(data.equipmentId) then
			return Result.fail("validation_failed", "Equipment items require equipmentId.")
		end
	else
		if data.equipmentId ~= nil then
			return Result.fail("validation_failed", "Non-equipment items must not define equipmentId.")
		end
	end

	if type(data.isEnabled) ~= "boolean" then
		return Result.fail("validation_failed", "Missing or invalid isEnabled.")
	end

	return Result.ok(data)
end

return ItemSchema
