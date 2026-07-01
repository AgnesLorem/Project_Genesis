local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Genesis"):WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Genesis"):WaitForChild("Server")

local ConfigRegistry = require(Server.data.ConfigRegistry)
local BalanceRegistry = require(Server.data.BalanceRegistry)
local SkillRegistry = require(Server.data.SkillRegistry)
local BossRegistry = require(Server.data.BossRegistry)
local EconomyRegistry = require(Server.data.EconomyRegistry)
local EvolutionRegistry = require(Server.data.EvolutionRegistry)
local GeneratorRegistry = require(Server.data.GeneratorRegistry)
local WorldRegistry = require(Server.data.WorldRegistry)
local TowerChallengeRegistry = require(Server.data.TowerChallengeRegistry)
local ItemRegistry = require(Server.data.ItemRegistry)
local EquipmentRegistry = require(Server.data.EquipmentRegistry)
local CreatureRegistry = require(Shared.data.CreatureRegistry)

local SaveService = require(Server.services.SaveService)
local RemoteHandlers = require(Server.networking.RemoteHandlers)

local ServerBootstrap = {}
local initialized = false

local function _initRegistry(name: string, registry: any)
	if registry and registry.init then
		local ok, err = pcall(function()
			registry.init()
		end)
		if not ok then
			warn(string.format("[ServerBootstrap] %s init failed: %s", name, tostring(err)))
		end
	end
end

local function _loadCreatureConfigs()
	local creatureRecords = ConfigRegistry.load("creatures")
	local creatureDict = {}

	for _, record in ipairs(creatureRecords) do
		if type(record) == "table" and record.id then
			creatureDict[record.id] = record
		end
	end

	if CreatureRegistry.loadConfig then
		CreatureRegistry.loadConfig(creatureDict)
	end
end

function ServerBootstrap.init()
	if initialized then
		return
	end
	initialized = true

	print("[ServerBootstrap] Project Genesis server starting.")

	_initRegistry("BalanceRegistry", BalanceRegistry)
	_initRegistry("SkillRegistry", SkillRegistry)
	_initRegistry("BossRegistry", BossRegistry)
	_initRegistry("EconomyRegistry", EconomyRegistry)
	_initRegistry("EvolutionRegistry", EvolutionRegistry)
	_initRegistry("GeneratorRegistry", GeneratorRegistry)
	_initRegistry("WorldRegistry", WorldRegistry)
	_initRegistry("TowerChallengeRegistry", TowerChallengeRegistry)
	_initRegistry("ItemRegistry", ItemRegistry)
	_initRegistry("EquipmentRegistry", EquipmentRegistry)
	_loadCreatureConfigs()

	SaveService.init()
	RemoteHandlers.init()

	print("[ServerBootstrap] Server ready.")
end

return ServerBootstrap
