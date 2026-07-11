--[[
	DataStoreWrapper
	Location: src/server/persistence/DataStoreWrapper.luau

	Thin server-side wrapper around Roblox DataStoreService.

	All persistence reads and writes in Project Genesis must route through
	this module. No other module should call DataStoreService directly.

	Responsibilities:
	- Wrap tất cả DataStore API trong pcall.
	- Exponential backoff retry (3 lần) khi gặp lỗi mạng tạm thời.
	- Session Locking: ngăn chặn Dupe Exploit khi người chơi rejoin liên tục.
	- Đếm pending saves để BindToClose chờ hoàn thành trước khi server tắt.
	- Không bao giờ lộ raw DataStore error ra ngoài — chỉ dùng mã lỗi an toàn.

	Session Locking Protocol:
	  1. loadAndClaim:  UpdateAsync để đọc data VÀ ghi SessionId của server này
	                    vào một thao tác nguyên tử duy nhất. Nếu server khác
	                    đang giữ lock → trả về session_locked.
	  2. save:          UpdateAsync kiểm tra SessionId trước khi ghi đè.
	                    Nếu lock bị đánh cắp → trả về session_stolen, không ghi.
	  3. saveAndRelease: UpdateAsync lưu data cuối cùng và xóa SessionId
	                    để server tiếp theo có thể load an sau.

	Session ID field: "_sessionJobId" (tiền tố _ = internal, không dùng cho gameplay)
	Trong Studio Play Solo, game.JobId là "" nên dùng timestamp thay thế.

	Backend: Roblox DataStoreService (DataStore v1)
	Per docs/SAVE_SYSTEM.md.
	Part of MVP-002: Save, Config, and Database Foundation.
--]]

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- ─── Session Identity ─────────────────────────────────────────────────────────
-- game.JobId là "" trong Studio → dùng timestamp để tạo session ID duy nhất.
local SESSION_JOB_ID: string = (game.JobId ~= "" and game.JobId)
	or ("studio_" .. tostring(os.time()) .. "_" .. tostring(math.random(10000, 99999)))

-- Tên field nội bộ lưu trong DataStore để khóa phiên.
local SESSION_FIELD = "_sessionJobId"

-- ─── Retry Config ─────────────────────────────────────────────────────────────
local MAX_RETRIES = 3
local RETRY_BASE_DELAY = 2 -- giây; delay = 2^attempt * base → 2s, 4s, 8s

-- ─── Pending Save Tracker ────────────────────────────────────────────────────
local _pendingSaveCount = 0

-- ─── Result Types ─────────────────────────────────────────────────────────────
export type LoadResult = {
	ok: boolean,
	data: any,
	errorCategory: string?,
}

export type SaveResult = {
	ok: boolean,
	errorCategory: string?,
}

-- ─── Safe Error Categories ────────────────────────────────────────────────────
local ERROR_CATEGORIES = {
	DATASTORE_UNAVAILABLE = "datastore_unavailable",
	REQUEST_BUDGET_EXCEEDED = "request_budget_exceeded",
	SERIALIZATION_FAILED = "serialization_failed",
	KEY_INVALID = "key_invalid",
	UNKNOWN_ERROR = "unknown_error",
	SESSION_LOCKED = "session_locked", -- Server khác đang giữ lock
	SESSION_STOLEN = "session_stolen", -- Lock bị mất giữa chừng (rejoin quá nhanh)
}

-- ─── Internal Helpers ────────────────────────────────────────────────────────

local function _categorizeError(rawError: string): string
	if type(rawError) ~= "string" then
		return ERROR_CATEGORIES.UNKNOWN_ERROR
	end
	local lower = string.lower(rawError)
	if string.find(lower, "budget") or string.find(lower, "throttle") or string.find(lower, "limit") then
		return ERROR_CATEGORIES.REQUEST_BUDGET_EXCEEDED
	end
	if string.find(lower, "serialize") or string.find(lower, "encode") then
		return ERROR_CATEGORIES.SERIALIZATION_FAILED
	end
	if string.find(lower, "key") then
		return ERROR_CATEGORIES.KEY_INVALID
	end
	if string.find(lower, "unavailable") or string.find(lower, "503") or string.find(lower, "connect") then
		return ERROR_CATEGORIES.DATASTORE_UNAVAILABLE
	end
	return ERROR_CATEGORIES.UNKNOWN_ERROR
end

local function _isTransientError(category: string): boolean
	return category == ERROR_CATEGORIES.DATASTORE_UNAVAILABLE
		or category == ERROR_CATEGORIES.REQUEST_BUDGET_EXCEEDED
		or category == ERROR_CATEGORIES.UNKNOWN_ERROR
end

local _storeCache: { [string]: DataStore } = {}

local function _getStore(storeName: string): (boolean, DataStore | string)
	if _storeCache[storeName] then
		return true, _storeCache[storeName]
	end
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(storeName)
	end)
	if ok then
		_storeCache[storeName] = result :: DataStore
		return true, result :: DataStore
	else
		return false, tostring(result)
	end
end

-- Thực thi callback với exponential backoff retry.
-- callback phải trả về (boolean, any) theo chuẩn pcall.
local function _withRetry(label: string, callback: () -> (boolean, any)): (boolean, any)
	local lastOk, lastResult
	for attempt = 1, MAX_RETRIES do
		lastOk, lastResult = callback()
		if lastOk then
			return true, lastResult
		end
		local category = _categorizeError(tostring(lastResult))
		if not _isTransientError(category) then
			warn(
				string.format(
					"[DataStoreWrapper] %s — lỗi cố định, không retry. Category: %s",
					label,
					category
				)
			)
			return false, lastResult
		end
		if attempt < MAX_RETRIES then
			local delay = RETRY_BASE_DELAY * (2 ^ (attempt - 1))
			warn(
				string.format(
					"[DataStoreWrapper] %s — lần %d/%d thất bại (%s). Thử lại sau %.0fs...",
					label,
					attempt,
					MAX_RETRIES,
					category,
					delay
				)
			)
			task.wait(delay)
		end
	end
	warn(string.format("[DataStoreWrapper] %s — đã thử %d lần, tất cả thất bại.", label, MAX_RETRIES))
	return false, lastResult
end

-- ─── Public API ───────────────────────────────────────────────────────────────

local DataStoreWrapper = {}

--[[
	DataStoreWrapper.loadAndClaim(storeName, key) -> LoadResult

	Tải dữ liệu VÀ ghi Session Lock của server hiện tại trong MỘT thao tác
	UpdateAsync nguyên tử duy nhất. Điều này đảm bảo:
	  - Không có race condition giữa đọc và ghi lock.
	  - Nếu server khác đang giữ lock → trả về session_locked ngay lập tức.

	Kết quả trả về KHÔNG chứa field "_sessionJobId" (đã được lọc ra).
	Caller nhận data sạch, không có metadata nội bộ.

	Trả về:
	  { ok = true,  data = <value> }                 — Load + lock thành công.
	  { ok = true,  data = nil }                     — Người chơi mới, lock được thiết lập.
	  { ok = false, errorCategory = "session_locked" } — Server khác đang giữ lock.
	  { ok = false, errorCategory = <other> }          — Lỗi DataStore.
--]]
function DataStoreWrapper.loadAndClaim(storeName: string, key: string): LoadResult
	assert(
		type(storeName) == "string" and storeName ~= "",
		"[DataStoreWrapper] storeName phải là chuỗi không rỗng."
	)
	assert(type(key) == "string" and key ~= "", "[DataStoreWrapper] key phải là chuỗi không rỗng.")

	local storeOk, storeOrError = _getStore(storeName)
	if not storeOk then
		local category = _categorizeError(tostring(storeOrError))
		warn(
			string.format(
				"[DataStoreWrapper] loadAndClaim: không lấy được DataStore '%s'. Category: %s",
				storeName,
				category
			)
		)
		return { ok = false, data = nil, errorCategory = category }
	end

	local store = storeOrError :: DataStore
	local label = string.format("loadAndClaim('%s', '%s')", storeName, key)

	-- Biến capture từ trong closure của UpdateAsync
	local sessionWasLocked = false
	local capturedCleanData = nil -- Data đã lọc bỏ SESSION_FIELD

	local ok, result = _withRetry(label, function()
		return pcall(function()
			store:UpdateAsync(key, function(oldValue: any)
				-- ── Kiểm tra Session Lock ──
				if
					type(oldValue) == "table"
					and type(oldValue[SESSION_FIELD]) == "string"
					and oldValue[SESSION_FIELD] ~= ""
					and oldValue[SESSION_FIELD] ~= SESSION_JOB_ID
				then
					-- Nếu lock thuộc về một Studio session cũ và hiện tại đang chạy trong Studio -> Cho phép claim đè
					local isOldLockStudio = string.sub(oldValue[SESSION_FIELD], 1, 7) == "studio_"
					local isCurrentStudio = RunService:IsStudio()

					if not (isOldLockStudio and isCurrentStudio) then
						-- Server khác thực sự đang giữ lock → huỷ UpdateAsync bằng cách return nil.
						-- Roblox sẽ không ghi gì vào DataStore khi transform trả về nil.
						sessionWasLocked = true
						return nil
					end
				end

				-- ── Lock còn trống hoặc là của server này → Claim ──
				-- Deep-copy để không mutate oldValue trực tiếp.
				local newData: { [string]: any } = {}
				if type(oldValue) == "table" then
					for k, v in pairs(oldValue) do
						newData[k] = v
					end
				end

				-- Ghi Session ID của server này để các server khác không ghi đè.
				newData[SESSION_FIELD] = SESSION_JOB_ID

				-- Lưu bản sạch (không có SESSION_FIELD) để trả về cho SaveService.
				capturedCleanData = {}
				for k, v in pairs(newData) do
					if k ~= SESSION_FIELD then
						capturedCleanData[k] = v
					end
				end

				return newData
			end)
		end)
	end)

	if not ok then
		local category = _categorizeError(tostring(result))
		warn(
			string.format(
				"[DataStoreWrapper] loadAndClaim UpdateAsync thất bại cuối cùng. Category: %s",
				category
			)
		)
		return { ok = false, data = nil, errorCategory = category }
	end

	if sessionWasLocked then
		warn(
			string.format(
				"[DataStoreWrapper] loadAndClaim: key '%s' đang bị lock bởi server khác. Từ chối load.",
				key
			)
		)
		return { ok = false, data = nil, errorCategory = ERROR_CATEGORIES.SESSION_LOCKED }
	end

	-- capturedCleanData == nil chỉ khi oldValue là nil (người chơi mới).
	return { ok = true, data = capturedCleanData, errorCategory = nil }
end

--[[
	DataStoreWrapper.save(storeName, key, data) -> SaveResult

	Lưu data với kiểm tra Session Lock. Nếu lock bị đánh cắp (server khác
	đã claim trong khi server này đang chạy), từ chối ghi và báo session_stolen.

	Trả về:
	  { ok = true }                                    — Lưu thành công.
	  { ok = false, errorCategory = "session_stolen" } — Lock bị mất, không ghi.
	  { ok = false, errorCategory = <other> }           — Lỗi DataStore.
--]]
function DataStoreWrapper.save(storeName: string, key: string, data: any): SaveResult
	assert(
		type(storeName) == "string" and storeName ~= "",
		"[DataStoreWrapper] storeName phải là chuỗi không rỗng."
	)
	assert(type(key) == "string" and key ~= "", "[DataStoreWrapper] key phải là chuỗi không rỗng.")

	local storeOk, storeOrError = _getStore(storeName)
	if not storeOk then
		local category = _categorizeError(tostring(storeOrError))
		warn(
			string.format(
				"[DataStoreWrapper] save: không lấy được DataStore '%s'. Category: %s",
				storeName,
				category
			)
		)
		return { ok = false, errorCategory = category }
	end

	local store = storeOrError :: DataStore
	local label = string.format("save('%s', '%s')", storeName, key)

	local sessionWasStolen = false
	_pendingSaveCount += 1

	local ok, result = _withRetry(label, function()
		return pcall(function()
			store:UpdateAsync(key, function(oldValue: any)
				-- ── Kiểm tra Lock bị đánh cắp ──
				if
					type(oldValue) == "table"
					and type(oldValue[SESSION_FIELD]) == "string"
					and oldValue[SESSION_FIELD] ~= ""
					and oldValue[SESSION_FIELD] ~= SESSION_JOB_ID
				then
					-- Server khác đã giành lock → không ghi gì cả.
					sessionWasStolen = true
					return nil
				end

				-- ── Lock vẫn là của server này → Ghi data mới, giữ lock ──
				local newData: { [string]: any } = {}
				if type(data) == "table" then
					for k, v in pairs(data) do
						newData[k] = v
					end
				end
				-- Đảm bảo SESSION_FIELD luôn được ghi lại (lock không bị xoá khi save).
				newData[SESSION_FIELD] = SESSION_JOB_ID
				return newData
			end)
		end)
	end)

	_pendingSaveCount -= 1

	if not ok then
		local category = _categorizeError(tostring(result))
		warn(string.format("[DataStoreWrapper] save UpdateAsync thất bại cuối cùng. Category: %s", category))
		return { ok = false, errorCategory = category }
	end

	if sessionWasStolen then
		warn(
			string.format(
				"[DataStoreWrapper] save: Session lock bị đánh cắp tại key '%s'! Không ghi đè.",
				key
			)
		)
		return { ok = false, errorCategory = ERROR_CATEGORIES.SESSION_STOLEN }
	end

	return { ok = true, errorCategory = nil }
end

--[[
	DataStoreWrapper.saveAndRelease(storeName, key, data) -> SaveResult

	Lưu data cuối cùng VÀ xoá Session Lock trong một thao tác UpdateAsync
	nguyên tử. Gọi khi người chơi rời server (PlayerRemoving / BindToClose).

	Sau khi hoàn thành, server tiếp theo có thể claim lock bình thường.

	Không kiểm tra lock vì đây là hành động kết thúc phiên — nếu lock bị
	stolen, ta vẫn muốn xoá SESSION_FIELD để tránh orphaned lock.
--]]
function DataStoreWrapper.saveAndRelease(storeName: string, key: string, data: any): SaveResult
	assert(
		type(storeName) == "string" and storeName ~= "",
		"[DataStoreWrapper] storeName phải là chuỗi không rỗng."
	)
	assert(type(key) == "string" and key ~= "", "[DataStoreWrapper] key phải là chuỗi không rỗng.")

	local storeOk, storeOrError = _getStore(storeName)
	if not storeOk then
		local category = _categorizeError(tostring(storeOrError))
		warn(
			string.format(
				"[DataStoreWrapper] saveAndRelease: không lấy được DataStore '%s'. Category: %s",
				storeName,
				category
			)
		)
		return { ok = false, errorCategory = category }
	end

	local store = storeOrError :: DataStore
	local label = string.format("saveAndRelease('%s', '%s')", storeName, key)

	_pendingSaveCount += 1

	local ok, result = _withRetry(label, function()
		return pcall(function()
			store:UpdateAsync(key, function(_oldValue: any)
				-- Ghi data mới và XOÁ SESSION_FIELD để nhả lock.
				local newData: { [string]: any } = {}
				if type(data) == "table" then
					for k, v in pairs(data) do
						if k ~= SESSION_FIELD then -- Lọc bỏ SESSION_FIELD khỏi payload
							newData[k] = v
						end
					end
				end
				-- SESSION_FIELD được để nil (không set) → DataStore xoá field này.
				-- Server tiếp theo sẽ không thấy lock cũ.
				return newData
			end)
		end)
	end)

	_pendingSaveCount -= 1

	if not ok then
		local category = _categorizeError(tostring(result))
		warn(
			string.format(
				"[DataStoreWrapper] saveAndRelease UpdateAsync thất bại cuối cùng. Category: %s",
				category
			)
		)
		return { ok = false, errorCategory = category }
	end

	return { ok = true, errorCategory = nil }
end

--[[
	DataStoreWrapper.getPendingSaveCount() -> number
	Số lệnh UpdateAsync đang chạy. BindToClose dùng để biết khi nào an toàn để tắt.
--]]
function DataStoreWrapper.getPendingSaveCount(): number
	return _pendingSaveCount
end

DataStoreWrapper.ERROR_CATEGORIES = ERROR_CATEGORIES
DataStoreWrapper.SESSION_JOB_ID = SESSION_JOB_ID -- Export để SaveSmoke có thể test

return DataStoreWrapper
