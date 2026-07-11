local UIController = require(script.Parent.Parent.controllers.UIController)
local LoadingController = require(script.Parent.Parent.controllers.LoadingController)
local StarterController = require(script.Parent.Parent.controllers.StarterController)
local WorldController = require(script.Parent.Parent.controllers.WorldController)
local GameplaySimulator = require(script.Parent.Parent.controllers.GameplaySimulator)
local Theme = require(script.Parent.Parent.views.Theme)

local ClientBootstrap = {}
local qaCommandRunning = false

local function runLoadingTransitionStress(options)
	local cycles = options and options.cycles or 50
	local mainUI = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("GenesisMainUI")
	local failures = {}

	for cycle = 1, cycles do
		local completed = false
		LoadingController.start(function(snapshot)
			WorldController.start(snapshot)
			completed = true
		end)
		task.wait(Theme.AnimationDuration * 2)

		local loadingCount = 0
		local worldCount = 0
		for _, child in ipairs(mainUI:GetChildren()) do
			if child.Name == "LoadingScreen" then
				loadingCount += 1
			elseif child.Name == "WorldScreen" then
				worldCount += 1
			end
		end
		if not completed or loadingCount ~= 0 or worldCount ~= 1 then
			table.insert(failures, {
				cycle = cycle,
				completed = completed,
				loadingCount = loadingCount,
				worldCount = worldCount,
			})
		end
	end

	return { success = #failures == 0, cycles = cycles, failures = failures }
end

function ClientBootstrap.init()
	local NetworkController = require(script.Parent.Parent.controllers.NetworkController)
	local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)
	
	local configRes = NetworkController.getCreatureConfigsPublic()
	if configRes and configRes.success and CreatureRegistry.loadConfig then
		CreatureRegistry.loadConfig(configRes.value)
	else
		warn("[ClientBootstrap] Failed to load public creature configs from server")
	end

	UIController.init()
	LoadingController.start(function(snapshot)
		if snapshot.starterSelected then
			WorldController.start(snapshot)
		else
			StarterController.start(function()
				LoadingController.start(function(newSnapshot)
					WorldController.start(newSnapshot)
				end)
			end)
		end
	end)
end

function ClientBootstrap.runQaCommand(commandName: string, ...)
	if not game:GetService("RunService"):IsStudio() then
		error("QA commands are disabled outside Studio.")
	end
	local command = commandName == "runLoadingTransitionStress" and runLoadingTransitionStress
		or GameplaySimulator[commandName]
	if type(command) ~= "function" then
		error("Unknown GameplaySimulator command: " .. tostring(commandName))
	end
	if qaCommandRunning then
		error("A QA command is already running.")
	end

	qaCommandRunning = true
	local arguments = table.pack(...)
	local results = table.pack(xpcall(function()
		return command(table.unpack(arguments, 1, arguments.n))
	end, debug.traceback))
	qaCommandRunning = false

	if not results[1] then
		error(results[2])
	end
	return table.unpack(results, 2, results.n)
end

return ClientBootstrap
