--[[
	PersistenceReporter
	Location: src/server/persistence/PersistenceReporter.luau
	
	Controlled failure reporting for persistence operations.
	
	All load and save failures must be reported through this module.
	It ensures that failure information is logged safely without exposing
	raw save payloads, player data contents, or full DataStore error messages.
	
	Rules:
	- Log the userId and error category only — NOT raw data or full stack traces.
	- Do NOT mutate any state when called.
	- Do NOT throw.
	- Reporting is output only (warn/print). No return values for the caller to branch on.
	- This is a reporting utility, not a decision-making system.
	
	Part of MVP-002: Save, Config, and Database Foundation.
--]]

-- Log prefix for all persistence reporter messages.
local LOG_PREFIX = "[PersistenceReporter]"

local PersistenceReporter = {}

--[[
	PersistenceReporter.reportLoadFailure(userId: any, errorCategory: string?)
	
	Reports a player data load failure.
	
	Logs:
	- The userId (or a placeholder if invalid).
	- The error category string (safe, not the raw DataStore error).
	
	Does NOT expose the save data, raw error messages, or stack traces.
	Does NOT mutate any session state.
--]]
function PersistenceReporter.reportLoadFailure(userId: any, errorCategory: string?)
	local safeUserId: string
	if type(userId) == "number" and userId > 0 then
		safeUserId = tostring(math.floor(userId))
	else
		safeUserId = "[invalid_userId]"
	end

	local safeCategory: string
	if type(errorCategory) == "string" and errorCategory ~= "" then
		safeCategory = errorCategory
	else
		safeCategory = "unknown_error"
	end

	warn(string.format("%s LOAD FAILURE | userId: %s | errorCategory: %s", LOG_PREFIX, safeUserId, safeCategory))
end

--[[
	PersistenceReporter.reportSaveFailure(userId: any, errorCategory: string?)
	
	Reports a player data save failure.
	
	Logs:
	- The userId (or a placeholder if invalid).
	- The error category string (safe, not the raw DataStore error).
	
	Does NOT expose the save data, raw error messages, or stack traces.
	Does NOT mutate any session state.
--]]
function PersistenceReporter.reportSaveFailure(userId: any, errorCategory: string?)
	local safeUserId: string
	if type(userId) == "number" and userId > 0 then
		safeUserId = tostring(math.floor(userId))
	else
		safeUserId = "[invalid_userId]"
	end

	local safeCategory: string
	if type(errorCategory) == "string" and errorCategory ~= "" then
		safeCategory = errorCategory
	else
		safeCategory = "unknown_error"
	end

	warn(string.format("%s SAVE FAILURE | userId: %s | errorCategory: %s", LOG_PREFIX, safeUserId, safeCategory))
end

--[[
	PersistenceReporter.reportInfo(message: string)
	
	Logs a general informational message for persistence lifecycle events.
	Use for expected events like load success, save success, new player initialized.
	
	Does NOT expose data contents.
--]]
function PersistenceReporter.reportInfo(message: string)
	if type(message) == "string" then
		print(string.format("%s %s", LOG_PREFIX, message))
	end
end

return PersistenceReporter
