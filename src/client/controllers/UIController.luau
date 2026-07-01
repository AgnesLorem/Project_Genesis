local Players = game:GetService("Players")

local UIController = {}
local activeScreen = nil
local activeModal = nil
local screenContainer

function UIController.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	if playerGui:FindFirstChild("GenesisMainUI") then
		screenContainer = playerGui:FindFirstChild("GenesisMainUI")
		return
	end
	screenContainer = Instance.new("ScreenGui")
	screenContainer.Name = "GenesisMainUI"
	screenContainer.ResetOnSpawn = false
	screenContainer.Parent = playerGui
end

function UIController.mountScreen(screenInstance)
	if activeScreen then activeScreen:Destroy() end
	activeScreen = screenInstance
	activeScreen.Parent = screenContainer
end

function UIController.mountModal(modalInstance)
	if activeModal then activeModal:Destroy() end
	activeModal = modalInstance
	activeModal.Parent = screenContainer
end

function UIController.clearModal()
	if activeModal then activeModal:Destroy(); activeModal = nil end
end

return UIController
