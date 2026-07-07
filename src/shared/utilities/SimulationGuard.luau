--[[
	SimulationGuard
	Location: src/shared/utilities/SimulationGuard.luau

	A generic safety utility to prevent infinite loops and server hangs.
	Part of MVP-020: RC-001 Release Gate Safety Guard Audit.
--]]

local SimulationGuard = {}
SimulationGuard.__index = SimulationGuard

export type SimulationGuardConfig = {
	maxSteps: number?,
	timeoutSeconds: number?,
	noProgressLimit: number?,
	context: string?
}

function SimulationGuard.new(config: SimulationGuardConfig)
	local self = setmetatable({}, SimulationGuard)
	self.maxSteps = config.maxSteps or 100000
	self.timeoutSeconds = config.timeoutSeconds or 2.0
	self.noProgressLimit = config.noProgressLimit or 5000
	self.context = config.context or "Unknown Loop"
	
	self.steps = 0
	self.stepsSinceProgress = 0
	self.startTime = os.clock()
	
	self.stalled = false
	self._failReason = nil
	self.diagnosticLogged = false
	
	return self
end

function SimulationGuard:step(): boolean
	if self.stalled then return false end
	
	self.steps += 1
	self.stepsSinceProgress += 1
	
	if self.steps > self.maxSteps then
		self.stalled = true
		self._failReason = "max_steps_exceeded"
	elseif self.stepsSinceProgress > self.noProgressLimit then
		self.stalled = true
		self._failReason = "no_progress_limit"
	elseif (os.clock() - self.startTime) > self.timeoutSeconds then
		self.stalled = true
		self._failReason = "timeout"
	end
	
	return not self.stalled
end

function SimulationGuard:markProgress()
	self.stepsSinceProgress = 0
end

function SimulationGuard:shouldStop(): boolean
	return self.stalled
end

function SimulationGuard:failReason(): string?
	return self._failReason
end

function SimulationGuard:logDiagnostic(snapshot: any)
	if self.diagnosticLogged then return end
	self.diagnosticLogged = true
	
	local timeTaken = os.clock() - self.startTime
	
	local HttpService = game:GetService("HttpService")
	local ok, snapJson = pcall(function() return HttpService:JSONEncode(snapshot or {}) end)
	if not ok then snapJson = tostring(snapshot) end
	
	warn(string.format(
		"[SimulationGuard] LOOP STALLED in '%s'. Reason: %s. Steps: %d. Time: %.3fs. Snapshot: %s",
		self.context,
		tostring(self._failReason),
		self.steps,
		timeTaken,
		snapJson
	))
end

return SimulationGuard
