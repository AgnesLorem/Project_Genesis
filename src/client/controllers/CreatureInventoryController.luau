--[[
	CreatureInventoryController
	Location: src/client/controllers/CreatureInventoryController.luau

	Manages owned creature list and detail panels.
--]]

local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local CreatureInventoryScreen = require(script.Parent.Parent.views.CreatureInventoryScreen)
local CreatureDetailPanel = require(script.Parent.Parent.views.CreatureDetailPanel)
local StatePatterns = require(script.Parent.Parent.views.StatePatterns)

local CreatureInventoryController = {}

function CreatureInventoryController.show(onClose: () -> ())
	UIController.init()
	UIController.mountModal(StatePatterns.Loading(nil))

	local profileRes = NetworkController.getPlayerProfileSnapshot()
	local configsRes = NetworkController.getCreatureConfigsPublic()

	UIController.clearModal()

	if not profileRes.success then
		UIController.mountModal(StatePatterns.Error(nil, "Profile Load Failed: " .. tostring(profileRes.message or profileRes.code)))
		return profileRes
	end

	if not configsRes.success then
		UIController.mountModal(StatePatterns.Error(nil, "Creature Configs Load Failed: " .. tostring(configsRes.code)))
		return configsRes
	end

	local screen = CreatureInventoryScreen.create(
		profileRes.value,
		configsRes.value,
		function()
			UIController.unmountScreen("CreatureInventoryScreen")
			onClose()
		end,
		function(instanceId)
			-- Set Active Creature
			UIController.mountModal(StatePatterns.Loading(nil))
			local setRes = NetworkController.requestSetActiveCreature(instanceId)
			UIController.clearModal()
			if setRes.success then
				-- Refresh screen
				CreatureInventoryController.show(onClose)
			else
				UIController.mountModal(StatePatterns.Error(nil, "Failed to set active creature: " .. tostring(setRes.message or setRes.code)))
			end
		end,
		function(instanceId)
			-- Open Details Panel
			CreatureInventoryController.showDetails(instanceId, profileRes.value, configsRes.value, onClose)
		end
	)

	UIController.mountScreen(screen)
	return profileRes
end

function CreatureInventoryController.showDetails(instanceId: string, profileSnapshot: any, publicConfigs: any, onClose: () -> ())
	local instance = profileSnapshot.creatureInstances[instanceId]
	if not instance then return end

	local publicConfig = publicConfigs[instance.creatureId]
	local isActive = profileSnapshot.activeCreatureInstanceId == instanceId

	local modal = CreatureDetailPanel.create(
		instance,
		publicConfig,
		isActive,
		function()
			UIController.clearModal()
		end
	)

	UIController.mountModal(modal)
end

return CreatureInventoryController
