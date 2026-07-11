--[[
	BossRegistry
	Location: src/server/data/BossRegistry.luau

	Loads enabled boss/challenge configs, validates them via BossSchema, and
	exposes static lookup/display data. It does not resolve rewards or switch
	boss phases at runtime.
--]]

local ConfigRegistry = require(script.Parent.ConfigRegistry)
local BossSchema = require(game:GetService("ReplicatedStorage").Genesis.Shared.data.BossSchema)

local BossRegistry = {}
local _registry: { [string]: any } = {}
local _initialized = false

local function _cloneArray(value: { any }): { any }
	local output = {}
	for _, item in ipairs(value) do
		table.insert(output, item)
	end
	return output
end

local function _buildSnapshot(boss: any): any
	return {
		bossId = boss.bossId,
		displayName = boss.displayName,
		battleMode = boss.battleMode,
		teamSize = boss.teamSize,
		recommendedPower = boss.recommendedPower,
		enemyRefs = _cloneArray(boss.enemyRefs),
		retryPolicyRef = boss.retryPolicyRef,
		isEnabled = boss.isEnabled,
	}
end

function BossRegistry.init()
	if _initialized then
		warn("[BossRegistry] Already initialized. Skipping.")
		return
	end

	local records = ConfigRegistry.load("bosses")
	for _, record in ipairs(records) do
		local result = BossSchema.validate(record)
		if result.success then
			local boss = result.value
			if boss.isEnabled then
				local bossId = boss.bossId
				if _registry[bossId] then
					warn(string.format("[BossRegistry] Duplicate bossId '%s' - skipping.", bossId))
				else
					_registry[bossId] = boss
				end
			end
		else
			warn(
				string.format(
					"[BossRegistry] Validation failed for '%s': %s",
					tostring(record.bossId or record.id or "unknown"),
					result.message or result.code
				)
			)
		end
	end

	_initialized = true
end

function BossRegistry.getBoss(bossId: string): any
	return _registry[bossId]
end

function BossRegistry.getBossSnapshot(bossId: string): any
	local boss = BossRegistry.getBoss(bossId)
	if not boss then
		return nil
	end

	return _buildSnapshot(boss)
end

function BossRegistry.getAllBosses(): { any }
	local list = {}
	for _, boss in pairs(_registry) do
		table.insert(list, boss)
	end
	return list
end

function BossRegistry.getAllBossSnapshots(): { any }
	local list = {}
	for _, boss in pairs(_registry) do
		table.insert(list, _buildSnapshot(boss))
	end
	table.sort(list, function(a, b)
		return a.bossId < b.bossId
	end)
	return list
end

function BossRegistry.isInitialized(): boolean
	return _initialized
end

return BossRegistry
