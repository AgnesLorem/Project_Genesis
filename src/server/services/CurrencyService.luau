--[[
	CurrencyService
	Location: src/server/services/CurrencyService.luau

	Server-authoritative currency balance management.
	Communicates ONLY with SaveService. Never touches DataStore directly.

	Rules:
	- Currency amounts are integer-only.
	- Client-provided amounts are never trusted.
	- All grants must have an approved sourceRef from the currency config.
	- All spends must have an approved sinkRef from the currency config.
	- Grant never exceeds cap. If near cap, grants only remaining amount.
	- If remaining amount is 0, returns Result.fail("CAP_REACHED").
	- Returns actual granted/spent amount in Result data.

	Part of MVP-005: Bio Generator and Economy Foundation.
--]]

local EconomyRegistry = require(script.Parent.Parent.data.EconomyRegistry)
local SaveService = require(script.Parent.SaveService)
local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local CurrencyService = {}

--[[
	CurrencyService.getBalance(player, currencyId) -> number

	Returns the player's current balance for the given currency.
	Returns 0 if the player has no balance recorded.
--]]
function CurrencyService.getBalance(player: any, currencyId: string): number
	local save = SaveService.getPlayerSave(player)
	return save.economyState.balances[currencyId] or 0
end

--[[
	CurrencyService.canAfford(player, currencyId, amount) -> boolean

	Returns true if the player has at least `amount` of the given currency.
--]]
function CurrencyService.canAfford(player: any, currencyId: string, amount: number): boolean
	if type(amount) ~= "number" or amount < 1 or amount ~= math.floor(amount) then
		return false
	end
	return CurrencyService.getBalance(player, currencyId) >= amount
end

--[[
	CurrencyService.tryGrant(player, currencyId, amount, sourceRef) -> Result

	Grants currency to a player. Server-authoritative.

	Validates:
	- currencyId exists in EconomyRegistry
	- amount is a positive integer
	- sourceRef is in the currency config's approved sourceRefs
	- Cap is respected: grants only remaining capacity, or fails if at cap

	Returns Result.ok({ granted = number, newBalance = number }) on success.
	Returns Result.fail(code, message) on failure.
--]]
function CurrencyService.tryGrant(player: any, currencyId: string, amount: number, sourceRef: string)
	-- Validate currencyId
	local config = EconomyRegistry.getCurrency(currencyId)
	if not config then
		return Result.fail("invalid_currency", string.format("Unknown currencyId: '%s'.", currencyId))
	end

	-- Validate amount is positive integer
	if type(amount) ~= "number" or amount < 1 or amount ~= math.floor(amount) then
		return Result.fail("invalid_amount", "Amount must be a positive integer.")
	end

	-- Validate sourceRef is approved
	local sourceApproved = false
	for _, ref in ipairs(config.sourceRefs) do
		if ref == sourceRef then
			sourceApproved = true
			break
		end
	end
	if not sourceApproved then
		return Result.fail(
			"unapproved_source",
			string.format("Source '%s' is not approved for currency '%s'.", sourceRef, currencyId)
		)
	end

	-- Cap check
	local balance = CurrencyService.getBalance(player, currencyId)
	local cap = config.cap
	local remaining = cap - balance

	if remaining <= 0 then
		return Result.fail("CAP_REACHED", string.format("Currency '%s' is at cap (%d).", currencyId, cap))
	end

	-- Grant only remaining capacity (never exceed cap)
	local actualGrant = math.min(amount, remaining)

	-- Apply
	local save = SaveService.getPlayerSave(player)
	save.economyState.balances[currencyId] = balance + actualGrant
	SaveService.savePlayer(player)

	return Result.ok({
		granted = actualGrant,
		newBalance = balance + actualGrant,
	})
end

--[[
	CurrencyService.trySpend(player, currencyId, amount, sinkRef) -> Result

	Spends currency from a player. Server-authoritative.

	Validates:
	- currencyId exists in EconomyRegistry
	- amount is a positive integer
	- sinkRef is in the currency config's approved sinkRefs
	- Player can afford the cost

	Returns Result.ok({ spent = number, newBalance = number }) on success.
	Returns Result.fail(code, message) on failure.
--]]
function CurrencyService.trySpend(player: any, currencyId: string, amount: number, sinkRef: string)
	-- Validate currencyId
	local config = EconomyRegistry.getCurrency(currencyId)
	if not config then
		return Result.fail("invalid_currency", string.format("Unknown currencyId: '%s'.", currencyId))
	end

	-- Validate amount is positive integer
	if type(amount) ~= "number" or amount < 1 or amount ~= math.floor(amount) then
		return Result.fail("invalid_amount", "Amount must be a positive integer.")
	end

	-- Validate sinkRef is approved
	local sinkApproved = false
	for _, ref in ipairs(config.sinkRefs) do
		if ref == sinkRef then
			sinkApproved = true
			break
		end
	end
	if not sinkApproved then
		return Result.fail(
			"unapproved_sink",
			string.format("Sink '%s' is not approved for currency '%s'.", sinkRef, currencyId)
		)
	end

	-- Affordability check
	local balance = CurrencyService.getBalance(player, currencyId)
	if balance < amount then
		return Result.fail(
			"insufficient_balance",
			string.format("Cannot spend %d '%s'. Current balance: %d.", amount, currencyId, balance)
		)
	end

	-- Apply
	local save = SaveService.getPlayerSave(player)
	save.economyState.balances[currencyId] = balance - amount
	SaveService.savePlayer(player)

	return Result.ok({
		spent = amount,
		newBalance = balance - amount,
	})
end

return CurrencyService
