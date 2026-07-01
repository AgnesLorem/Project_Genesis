local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = {}
local isServer = RunService:IsServer()
local remoteFolder

if isServer then
	local sharedFolder = ReplicatedStorage:WaitForChild("Genesis"):WaitForChild("Shared")
	remoteFolder = sharedFolder:FindFirstChild("Remotes")
	if not remoteFolder then
		remoteFolder = Instance.new("Folder")
		remoteFolder.Name = "Remotes"
		remoteFolder.Parent = sharedFolder
	end
else
	remoteFolder = ReplicatedStorage:WaitForChild("Genesis"):WaitForChild("Shared"):WaitForChild("Remotes")
end

function Network.getRemoteFunction(name)
	if isServer then
		local rf = remoteFolder:FindFirstChild(name)
		if not rf then 
			rf = Instance.new("RemoteFunction")
			rf.Name = name
			rf.Parent = remoteFolder 
		end
		return rf
	else
		return remoteFolder:WaitForChild(name)
	end
end

function Network.getRemoteEvent(name)
	if isServer then
		local re = remoteFolder:FindFirstChild(name)
		if not re then 
			re = Instance.new("RemoteEvent")
			re.Name = name
			re.Parent = remoteFolder 
		end
		return re
	else
		return remoteFolder:WaitForChild(name)
	end
end

return Network
