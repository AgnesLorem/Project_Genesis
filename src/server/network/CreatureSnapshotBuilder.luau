local CreatureRegistry = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.CreatureRegistry)
local CreatureSnapshotType = require(game:GetService("ReplicatedStorage").Genesis.Shared.network.CreatureSnapshotType)

local CreatureSnapshotBuilder = {}

-- Server builds the snapshot to ensure no server-only metadata leaks
function CreatureSnapshotBuilder.build(instance: any): CreatureSnapshotType.CreatureSnapshotType?
	local config = CreatureRegistry.getCreature(instance.creatureId)
	if not config then
		return nil
	end

	return {
		instanceId = instance.instanceId,
		creatureId = instance.creatureId,
		displayName = config.displayName,
	}
end

return CreatureSnapshotBuilder
