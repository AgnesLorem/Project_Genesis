--[[
	CollectionController
	Location: src/client/controllers/CollectionController.luau

	Opens the Collection Book screen.
	Fetches collection data + public creature configs from the server.
	Shows error state with retry if network call fails.
--]]

local NetworkController = require(script.Parent.NetworkController)
local UIController = require(script.Parent.UIController)
local CollectionBookScreen = require(script.Parent.Parent.views.CollectionBookScreen)
local StatePatterns = require(script.Parent.Parent.views.StatePatterns)

local CollectionController = {}

function CollectionController.openCollectionBook(onClose: () -> ())
	-- Show loading state while fetching
	UIController.mountModal(StatePatterns.Loading(nil))

	-- Fetch both in sequence (server is authoritative on both)
	local collectionRes = NetworkController.getCollectionSnapshot()
	local configsRes = NetworkController.getCreatureConfigsPublic()

	UIController.clearModal()

	if not collectionRes.success then
		UIController.mountModal(StatePatterns.Retry(nil, function()
			UIController.clearModal()
			CollectionController.openCollectionBook(onClose)
		end, "Failed to load collection: " .. tostring(collectionRes.code)))
		return
	end

	if not configsRes.success then
		UIController.mountModal(StatePatterns.Retry(nil, function()
			UIController.clearModal()
			CollectionController.openCollectionBook(onClose)
		end, "Failed to load creature configs: " .. tostring(configsRes.code)))
		return
	end

	local screen = CollectionBookScreen.create(collectionRes.value, configsRes.value, function()
		UIController.unmountScreen("CollectionBookScreen")
		onClose()
	end)

	UIController.mountOverlay(screen, "CollectionBookScreen")
end

return CollectionController
