local ClientBootstrap = require(script.Parent.bootstrap.ClientBootstrap)
ClientBootstrap.init()

if game:GetService("RunService"):IsStudio() then
	local qaBridge = Instance.new("BindableFunction")
	qaBridge.Name = "GenesisQABridge"
	qaBridge.OnInvoke = function(commandName: string, ...)
		return ClientBootstrap.runQaCommand(commandName, ...)
	end
	qaBridge.Parent = script.Parent
end
