--[[
	UIController
	Location: src/client/controllers/UIController.luau

	Manages mounting and unmounting screens in PlayerGui with transitions.
	Acts as the Modal Manager.
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local AnimationService = require(script.Parent.Parent.views.AnimationService)
local Theme = require(script.Parent.Parent.views.Theme)

local UIController = {}

local activeScreen: Frame? = nil
local activeModal: Frame? = nil
local activeModalCloseCallback: (() -> ())? = nil
local activeOverlays: { [string]: Frame } = {}
local screenContainer: ScreenGui
local uisConnection: RBXScriptConnection? = nil
local pendingReleases: { [GuiObject]: { tween: Tween?, released: boolean } } = setmetatable({}, { __mode = "k" })

local function releaseNow(instance: GuiObject)
	local record = pendingReleases[instance]
	if record then
		if record.released then
			return
		end
		record.released = true
		if record.tween and record.tween.PlaybackState == Enum.PlaybackState.Playing then
			record.tween:Cancel()
		end
	end
	instance:Destroy()
end

local function releaseAfterFade(instance: GuiObject)
	local record = { tween = nil, released = false }
	pendingReleases[instance] = record
	local tween = AnimationService.fadeOut(instance, Theme.AnimationDuration)
	record.tween = tween
	tween.Completed:Once(function()
		releaseNow(instance)
	end)
	task.delay(Theme.AnimationDuration, function()
		releaseNow(instance)
	end)
end

local function releaseAllPending()
	local instances = {}
	for instance in pairs(pendingReleases) do
		table.insert(instances, instance)
	end
	for _, instance in ipairs(instances) do
		releaseNow(instance)
	end
end

function UIController.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	if playerGui:FindFirstChild("GenesisMainUI") then
		screenContainer = playerGui:FindFirstChild("GenesisMainUI")
	else
		screenContainer = Instance.new("ScreenGui")
		screenContainer.Name = "GenesisMainUI"
		screenContainer.ResetOnSpawn = false
		screenContainer.Parent = playerGui
	end

	-- Enforce single ESC key close modal listener
	if not uisConnection then
		uisConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.Escape then
				if activeModal then
					if activeModalCloseCallback then
						activeModalCloseCallback()
					else
						UIController.clearModal()
					end
				end
			end
		end)
	end
end

function UIController.mountScreen(screenInstance: Frame)
	if activeScreen then
		local oldScreen = activeScreen
		activeScreen = nil
		releaseAfterFade(oldScreen)
	end
	activeScreen = screenInstance
	activeScreen.Parent = screenContainer
	AnimationService.fadeIn(screenInstance)
end

function UIController.mountOverlay(overlayInstance: Frame, overlayId: string)
	if activeOverlays[overlayId] then
		local oldOverlay = activeOverlays[overlayId]
		activeOverlays[overlayId] = nil
		releaseAfterFade(oldOverlay)
	end
	activeOverlays[overlayId] = overlayInstance
	overlayInstance.Parent = screenContainer
	AnimationService.fadeIn(overlayInstance)
end

function UIController.unmountOverlay(overlayId: string)
	if activeOverlays[overlayId] then
		local oldOverlay = activeOverlays[overlayId]
		activeOverlays[overlayId] = nil
		releaseAfterFade(oldOverlay)
	end
end

-- Backward compatibility for the `unmountScreen` call used in CollectionController (which is actually an overlay)
function UIController.unmountScreen(screenId: string)
	UIController.unmountOverlay(screenId)
end

function UIController.mountModal(modalInstance: Frame, onClose: (() -> ())?)
	if activeModal then
		UIController.clearModal()
	end
	activeModal = modalInstance
	activeModalCloseCallback = onClose
	activeModal.Parent = screenContainer
	AnimationService.scalePop(modalInstance)
end

function UIController.clearModal()
	if activeModal then
		local current = activeModal
		activeModal = nil
		activeModalCloseCallback = nil
		releaseAfterFade(current)
	end
end

-- Cleanup method for testing / resetting state
function UIController.cleanup()
	releaseAllPending()
	if uisConnection then
		uisConnection:Disconnect()
		uisConnection = nil
	end
	if activeScreen then
		activeScreen:Destroy()
		activeScreen = nil
	end
	if activeModal then
		activeModal:Destroy()
		activeModal = nil
		activeModalCloseCallback = nil
	end
	for id, overlay in pairs(activeOverlays) do
		overlay:Destroy()
	end
	table.clear(activeOverlays)
end

return UIController
