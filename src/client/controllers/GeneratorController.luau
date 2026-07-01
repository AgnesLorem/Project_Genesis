local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local GeneratorPanel = require(script.Parent.Parent.views.GeneratorPanel)
local StatePatterns = require(script.Parent.Parent.views.StatePatterns)

local GeneratorController = {}

local lastSelectedGeneratorId = nil
local lastStatusText = nil

local function _statusFromResult(prefix: string, result: any): string
	if result.success then
		if result.value and result.value.claimed then
			return string.format("%s: Claimed %d.", prefix, result.value.claimed)
		end
		if result.value and result.value.level then
			return string.format("%s: Level %d.", prefix, result.value.level)
		end
		return prefix .. ": Success."
	end
	return string.format("%s failed: %s", prefix, tostring(result.message or result.code))
end

function GeneratorController.show(selectedGeneratorId: string?, statusText: string?)
	UIController.init()
	UIController.mountModal(StatePatterns.Loading(nil))

	local snapshotResult = NetworkController.getGeneratorSnapshot()
	UIController.clearModal()
	if not snapshotResult.success then
		UIController.mountModal(StatePatterns.Error(nil, "Generator Load Failed: " .. tostring(snapshotResult.message or snapshotResult.code)))
		return snapshotResult
	end

	lastSelectedGeneratorId = selectedGeneratorId or lastSelectedGeneratorId
	lastStatusText = statusText or lastStatusText
	local screen = GeneratorPanel.create(snapshotResult.value, function(generatorId)
		GeneratorController.claim(generatorId)
	end, function(generatorId)
		GeneratorController.upgrade(generatorId)
	end, function()
		GeneratorController.show(lastSelectedGeneratorId, lastStatusText)
	end, lastSelectedGeneratorId, lastStatusText)

	UIController.mountScreen(screen)
	return snapshotResult
end

function GeneratorController.claim(generatorId: string)
	lastSelectedGeneratorId = generatorId
	local result = NetworkController.requestClaimGenerator(generatorId)
	lastStatusText = _statusFromResult("Claim", result)
	GeneratorController.show(generatorId, lastStatusText)
	return result
end

function GeneratorController.upgrade(generatorId: string)
	lastSelectedGeneratorId = generatorId
	local result = NetworkController.requestUpgradeGenerator(generatorId)
	lastStatusText = _statusFromResult("Upgrade", result)
	GeneratorController.show(generatorId, lastStatusText)
	return result
end

function GeneratorController.showErrorState(generatorId: string)
	local result = NetworkController.requestClaimGenerator(generatorId)
	lastStatusText = _statusFromResult("Claim", result)
	GeneratorController.show(generatorId, lastStatusText)
	return result
end

return GeneratorController
