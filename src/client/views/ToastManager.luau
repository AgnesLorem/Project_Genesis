--[[
	ToastManager
	Location: src/client/views/ToastManager.luau
	FIFO Queue for toast notifications in Project Genesis.
--]]

local Players = game:GetService("Players")
local Theme = require(script.Parent.Theme)
local UIComponents = require(script.Parent.UIComponents)
local AnimationService = require(script.Parent.AnimationService)

local ToastManager = {}

local queue = {}
local isProcessing = false

local function getContainer(): Instance?
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	return playerGui:FindFirstChild("GenesisMainUI") or playerGui:WaitForChild("GenesisMainUI", 5)
end

local function createToastFrame(message: string, toastType: string?): Frame
	local panel = UIComponents.createBasePanel()
	panel.Name = "ToastFrame"
	panel.Size = UDim2.new(0, 320, 0, 48)
	-- Start offscreen below the viewport
	panel.Position = UDim2.new(0.5, -160, 1, 100)
	panel.ZIndex = Theme.ZIndex.Toast
	
	-- Apply corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.CornerRadius
	corner.Parent = panel
	
	-- Apply toast type colors
	local typeColor = Theme.Colors.Primary
	if toastType == "success" then
		typeColor = Theme.Colors.Success
	elseif toastType == "error" then
		typeColor = Theme.Colors.Error
	elseif toastType == "reward" then
		typeColor = Theme.Colors.Accent
	end
	
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.StrokeThickness
	stroke.Color = typeColor
	stroke.Parent = panel
	
	-- Text Label
	local label = UIComponents.createBaseLabel(message)
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Font = Theme.Fonts.Bold
	label.TextSize = 16
	label.TextWrapped = true
	label.Parent = panel
	
	return panel
end

local function processQueue()
	if isProcessing or #queue == 0 then
		return
	end
	
	isProcessing = true
	local item = table.remove(queue, 1)
	
	local container = getContainer()
	if not container then
		isProcessing = false
		task.spawn(processQueue)
		return
	end
	
	local toast = createToastFrame(item.message, item.toastType)
	toast.Parent = container
	
	-- Slide in to bottom-center of screen
	local startPos = UDim2.new(0.5, -160, 1, 100)
	local targetPos = UDim2.new(0.5, -160, 1, -80)
	
	local inTween = AnimationService.slideIn(toast, startPos, targetPos, 0.3)
	inTween.Completed:Wait()
	
	-- Hold for 2.2 seconds
	task.wait(2.2)
	
	-- Slide out offscreen
	local outTween = AnimationService.slideOut(toast, startPos, 0.3)
	outTween.Completed:Wait()
	
	toast:Destroy()
	isProcessing = false
	
	-- Process next toast
	task.spawn(processQueue)
end

function ToastManager.showToast(message: string, toastType: string?)
	table.insert(queue, { message = message, toastType = toastType })
	task.spawn(processQueue)
end

-- Clear all pending toasts (useful for cleanup/testing)
function ToastManager.clearAll()
	table.clear(queue)
	isProcessing = false
end

return ToastManager
