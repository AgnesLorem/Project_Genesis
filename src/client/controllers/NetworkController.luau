local Network = require(game:GetService("ReplicatedStorage").Genesis.Shared.remotes.Network)

local NetworkController = {}

function NetworkController.getPlayerProfileSnapshot() 
	return Network.getRemoteFunction("GetPlayerProfileSnapshot"):InvokeServer() 
end

function NetworkController.getStarterChoices() 
	return Network.getRemoteFunction("GetStarterChoices"):InvokeServer() 
end

function NetworkController.requestStarterSelection(creatureId) 
	return Network.getRemoteFunction("RequestStarterSelection"):InvokeServer(creatureId) 
end

function NetworkController.requestWorldSnapshot() 
	return Network.getRemoteFunction("RequestWorldSnapshot"):InvokeServer() 
end

function NetworkController.requestStoryBattle(playerCreatureId, stageId) 
	return Network.getRemoteFunction("RequestStoryBattle"):InvokeServer(playerCreatureId, stageId) 
end

function NetworkController.requestBattleCompletion(battleToken)
	return Network.getRemoteFunction("RequestBattleCompletion"):InvokeServer(battleToken)
end

function NetworkController.getGeneratorSnapshot(generatorId)
	return Network.getRemoteFunction("GetGeneratorSnapshot"):InvokeServer(generatorId)
end

function NetworkController.requestClaimGenerator(generatorId)
	return Network.getRemoteFunction("RequestClaimGenerator"):InvokeServer(generatorId)
end

function NetworkController.requestUpgradeGenerator(generatorId)
	return Network.getRemoteFunction("RequestUpgradeGenerator"):InvokeServer(generatorId)
end

function NetworkController.requestGeneratorClaim(generatorId)
	return NetworkController.requestClaimGenerator(generatorId)
end

function NetworkController.requestEvolution(instanceId, evolutionId)
	return Network.getRemoteFunction("RequestEvolution"):InvokeServer(instanceId, evolutionId)
end

function NetworkController.getTowerChallengeSnapshot()
	return Network.getRemoteFunction("GetTowerChallengeSnapshot"):InvokeServer()
end

function NetworkController.requestTowerChallengeStart(challengeId, floorId, playerInstanceId)
	return Network.getRemoteFunction("RequestTowerChallengeStart"):InvokeServer(challengeId, floorId, playerInstanceId)
end

function NetworkController.requestTowerChallengeComplete(runToken)
	return Network.getRemoteFunction("RequestTowerChallengeComplete"):InvokeServer(runToken)
end

function NetworkController.getInventorySnapshot()
	return Network.getRemoteFunction("GetInventorySnapshot"):InvokeServer()
end

function NetworkController.getEquipmentSnapshot()
	return Network.getRemoteFunction("GetEquipmentSnapshot"):InvokeServer()
end

function NetworkController.requestEquipItem(itemId, slotId)
	return Network.getRemoteFunction("RequestEquipItem"):InvokeServer(itemId, slotId)
end

function NetworkController.requestUnequipItem(slotId)
	return Network.getRemoteFunction("RequestUnequipItem"):InvokeServer(slotId)
end

function NetworkController.getSkillSnapshot(creatureInstanceId)
	return Network.getRemoteFunction("GetSkillSnapshot"):InvokeServer(creatureInstanceId)
end

function NetworkController.requestSkillUse(creatureInstanceId, skillId, targetId)
	return Network.getRemoteFunction("RequestSkillUse"):InvokeServer(creatureInstanceId, skillId, targetId)
end

return NetworkController
