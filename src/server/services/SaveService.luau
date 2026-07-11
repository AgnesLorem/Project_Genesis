--[[
	SaveService
	Location: src/server/services/SaveService.luau

	Persistence is owned by SaveService. Gameplay services read and mutate the
	loaded save table through this module; DataStore access stays isolated in
	DataStoreWrapper.

	Key design decisions:
	- Session Locking: dùng loadAndClaim/saveAndRelease của DataStoreWrapper để
	  ngăn Dupe Exploit khi người chơi rejoin. Nếu server khác đang giữ lock,
	  _loadUserId trả về fail → người chơi không thể vào game cho đến khi lock
	  được nhả (tối đa 25s — thời gian BindToClose của server cũ).
	- Migration: MigrationManager.migrate() chạy trong pcall. Nếu lỗi →
	  load bị từ chối (fail closed), không trả về data hỏng.
	- Fail Closed: Nếu load thất bại, savePlayer sẽ từ chối ghi đè DataStore,
	  bảo vệ dữ liệu gốc của người chơi.
	- BindToClose: Chờ tất cả UpdateAsync đang chạy hoàn thành trước khi server
	  tắt (dùng DataStoreWrapper.getPendingSaveCount()).

	BUG FIX: _buildKey helper function đã bị xoá. Tất cả calls now sử dụng
	trực tiếp SaveKeyBuilder.buildPlayerKey(userId).
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DataStoreWrapper = require(script.Parent.Parent.persistence.DataStoreWrapper)
local SaveKeyBuilder = require(script.Parent.Parent.persistence.SaveKeyBuilder)
local MigrationManager = require(script.Parent.Parent.persistence.MigrationManager)
local Result = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.Result)

local SaveService = {}

-- ─── Config ───────────────────────────────────────────────────────────────────
local AUTOSAVE_INTERVAL_SECONDS = 60
local STUDIO_FALLBACK_USER_ID = 1000000001
local BIND_TO_CLOSE_TIMEOUT_SECONDS = 25

-- ─── Session State ────────────────────────────────────────────────────────────
local savesByUserId: { [number]: any } = {}
local dirtyByUserId: { [number]: boolean } = {}
local loadFailedByUserId: { [number]: string } = {}
local loadingByUserId: { [number]: boolean } = {}
local initialized = false
local shuttingDown = false

-- ─── Internal Helpers ─────────────────────────────────────────────────────────

local function _createDefaultSave()
	return MigrationManager.getTemplate()
end

local function _resolveUserId(player: any): number?
	if typeof(player) == "Instance" and player:IsA("Player") then
		if SaveKeyBuilder.validateUserId(player.UserId) then
			return player.UserId
		end
		-- Studio có thể trả về UserId âm cho tài khoản chưa đăng nhập.
		if RunService:IsStudio() then
			return STUDIO_FALLBACK_USER_ID
		end
		return nil
	end

	if type(player) == "table" and SaveKeyBuilder.validateUserId(player.UserId) then
		return player.UserId
	end

	if SaveKeyBuilder.validateUserId(player) then
		return player
	end

	return nil
end

--[[
	_loadUserId: tải dữ liệu từ DataStore, claim session lock, và chạy migration.

	Thứ tự xử lý:
	1. loadAndClaim → Đọc data + ghi SESSION_FIELD atomically.
	   - Nếu session_locked → fail (server khác đang dùng).
	   - Nếu lỗi DataStore → fail closed.
	2. Nếu data nil → người chơi mới, tạo template v3.
	3. Nếu có data → MigrationManager.migrate() trong pcall.
	   - Nếu migrate lỗi → fail, không trả về data hỏng.
	4. Nạp vào session cache.
--]]
local function _loadUserId(userId: number)
	if savesByUserId[userId] then
		return Result.ok(savesByUserId[userId])
	end

	if loadingByUserId[userId] then
		local SimulationGuard = require(game:GetService("ReplicatedStorage").Genesis.Shared.utilities.SimulationGuard)
		local guard = SimulationGuard.new({
			maxSteps = 10000,
			timeoutSeconds = 5.0,
			context = "SaveService:wait_for_load",
		})

		while loadingByUserId[userId] and guard:step() do
			task.wait()
		end

		if guard:shouldStop() then
			guard:logDiagnostic({ userId = userId })
			return Result.fail("load_timeout", "Tiến trình chờ nạp dữ liệu bị treo.")
		end

		if savesByUserId[userId] then
			return Result.ok(savesByUserId[userId])
		end

		local loadFailure = loadFailedByUserId[userId]
		if loadFailure then
			return Result.fail("load_failed", loadFailure)
		end
	end

	loadingByUserId[userId] = true
	local function finishLoad(result: any)
		loadingByUserId[userId] = nil
		return result
	end

	-- BUG FIX: Gọi trực tiếp SaveKeyBuilder.buildPlayerKey thay vì _buildKey (đã xoá).
	local key = SaveKeyBuilder.buildPlayerKey(userId)
	if not key then
		return finishLoad(Result.fail("invalid_user_id", "Không thể tạo save key cho người chơi."))
	end

	-- ── Bước 1: Load + Claim Session Lock (atomic) ──
	local loadResult = DataStoreWrapper.loadAndClaim(SaveKeyBuilder.getStoreName(), key)

	if not loadResult.ok then
		local category = loadResult.errorCategory or "unknown_error"
		loadFailedByUserId[userId] = category

		if category == DataStoreWrapper.ERROR_CATEGORIES.SESSION_LOCKED then
			warn(
				string.format(
					"[SaveService] UserId %d đang bị lock bởi server khác. Từ chối load để bảo vệ dữ liệu.",
					userId
				)
			)
		else
			warn(string.format("[SaveService] Load thất bại cho userId %d. Category: %s", userId, category))
		end
		-- Fail closed: không nạp session.
		return finishLoad(Result.fail("load_failed", category))
	end

	-- ── Bước 2: Người chơi mới (nil data) ──
	if loadResult.data == nil then
		local defaultSave = _createDefaultSave()
		savesByUserId[userId] = defaultSave
		dirtyByUserId[userId] = true -- Đánh dấu dirty để lưu template lần đầu.
		loadFailedByUserId[userId] = nil
		print(
			string.format(
				"[SaveService] Tạo save mới (schema v%d) cho userId %d.",
				MigrationManager.getCurrentVersion(),
				userId
			)
		)
		return finishLoad(Result.ok(defaultSave))
	end

	-- ── Bước 3: Migration (pcall để ngăn crash nếu logic lỗi) ──
	local migrateOk, migratedOrError = pcall(function()
		return MigrationManager.migrate(loadResult.data)
	end)

	if not migrateOk then
		-- Migration lỗi → từ chối nạp session, không trả về data hỏng.
		local errMsg = tostring(migratedOrError)
		loadFailedByUserId[userId] = "migration_failed"
		warn(
			string.format(
				"[SaveService] Migration thất bại cho userId %d — KHÔNG nạp session. Lỗi: %s",
				userId,
				errMsg
			)
		)
		return finishLoad(Result.fail("migration_failed", errMsg))
	end

	local save = migratedOrError
	savesByUserId[userId] = save
	dirtyByUserId[userId] = false
	loadFailedByUserId[userId] = nil

	print(
		string.format(
			"[SaveService] Đã tải và migrate save (schema v%d) cho userId %d.",
			save.saveVersion or 0,
			userId
		)
	)
	return finishLoad(Result.ok(save))
end

-- ─── Public API ───────────────────────────────────────────────────────────────

function SaveService.loadPlayer(player: any)
	local userId = _resolveUserId(player)
	if not userId then
		return Result.fail("invalid_user_id", "Người chơi không có UserId hợp lệ.")
	end
	return _loadUserId(userId)
end

function SaveService.getPlayerSave(player: any): any
	local userId = _resolveUserId(player)
	if not userId then
		warn("[SaveService] getPlayerSave được gọi mà không có player/UserId hợp lệ.")
		return nil
	end
	if not savesByUserId[userId] then
		_loadUserId(userId)
	end
	return savesByUserId[userId]
end

function SaveService.markDirty(player: any)
	local userId = _resolveUserId(player)
	if not userId then
		return Result.fail("invalid_user_id", "Không thể đánh dấu dirty mà không có UserId hợp lệ.")
	end
	if savesByUserId[userId] then
		dirtyByUserId[userId] = true
	end
	return Result.ok(nil)
end

--[[
	savePlayer: lưu data giữa chừng (autosave / gọi thủ công).
	Giữ Session Lock sau khi lưu (không release).
	BUG FIX: Gọi trực tiếp SaveKeyBuilder.buildPlayerKey thay vì _buildKey (đã xoá).
--]]
function SaveService.savePlayer(player: any)
	local userId = _resolveUserId(player)
	if not userId then
		return Result.fail("invalid_user_id", "Không thể lưu mà không có UserId hợp lệ.")
	end

	local save = savesByUserId[userId]
	if not save then
		return Result.fail("not_loaded", "Không có dữ liệu session để lưu.")
	end

	-- Fail closed: không ghi đè nếu load ban đầu đã thất bại.
	if loadFailedByUserId[userId] then
		return Result.fail("load_failed", "Từ chối ghi đè dữ liệu sau khi load thất bại.")
	end

	-- BUG FIX: Dùng SaveKeyBuilder.buildPlayerKey trực tiếp.
	local key = SaveKeyBuilder.buildPlayerKey(userId)
	if not key then
		return Result.fail("invalid_user_id", "Không thể tạo save key.")
	end

	local saveResult = DataStoreWrapper.save(SaveKeyBuilder.getStoreName(), key, save)
	if not saveResult.ok then
		dirtyByUserId[userId] = true -- Giữ dirty để autosave thử lại.
		return Result.fail("save_failed", saveResult.errorCategory or "unknown_error")
	end

	dirtyByUserId[userId] = false
	print(string.format("[SaveService] Đã lưu dữ liệu cho userId %d.", userId))
	return Result.ok(nil)
end

function SaveService.saveDirtyPlayers()
	for userId, isDirty in pairs(dirtyByUserId) do
		if isDirty and savesByUserId[userId] then
			SaveService.savePlayer(userId)
		end
	end
end

--[[
	unloadPlayer: lưu data lần cuối + NHẢ Session Lock + xoá session cache.
	Dùng saveAndRelease để server tiếp theo có thể claim key.
	BUG FIX: Dùng SaveKeyBuilder.buildPlayerKey trực tiếp.
--]]
function SaveService.unloadPlayer(player: any)
	local userId = _resolveUserId(player)
	if not userId then
		return Result.fail("invalid_user_id", "Không thể unload mà không có UserId hợp lệ.")
	end

	if savesByUserId[userId] and not loadFailedByUserId[userId] then
		-- BUG FIX: Dùng SaveKeyBuilder.buildPlayerKey trực tiếp.
		local key = SaveKeyBuilder.buildPlayerKey(userId)
		if key then
			-- saveAndRelease: lưu data + xoá SESSION_FIELD trong một atomic operation.
			local releaseResult =
				DataStoreWrapper.saveAndRelease(SaveKeyBuilder.getStoreName(), key, savesByUserId[userId])
			if not releaseResult.ok then
				warn(
					string.format(
						"[SaveService] saveAndRelease thất bại cho userId %d. Category: %s",
						userId,
						releaseResult.errorCategory or "unknown"
					)
				)
			else
				print(string.format("[SaveService] Đã lưu và nhả lock cho userId %d.", userId))
			end
		end
	end

	savesByUserId[userId] = nil
	dirtyByUserId[userId] = nil
	loadFailedByUserId[userId] = nil
	loadingByUserId[userId] = nil

	return Result.ok(nil)
end

function SaveService.wipePlayerSave(player: any)
	local userId = _resolveUserId(player)
	if not userId then
		return Result.fail("invalid_user_id", "Không thể wipe mà không có UserId hợp lệ.")
	end
	savesByUserId[userId] = _createDefaultSave()
	dirtyByUserId[userId] = true
	loadFailedByUserId[userId] = nil
	loadingByUserId[userId] = nil
	return Result.ok(nil)
end

function SaveService.init()
	if initialized then
		return
	end
	initialized = true

	Players.PlayerAdded:Connect(function(player)
		SaveService.loadPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		SaveService.unloadPlayer(player)
	end)

	-- ── BindToClose: Chờ tất cả UpdateAsync đang chạy trước khi server tắt ──
	game:BindToClose(function()
		shuttingDown = true
		print("[SaveService] Server đang tắt — lưu tất cả người chơi và nhả lock...")

		-- Gọi unloadPlayer cho từng người chơi (saveAndRelease + xoá cache).
		for _, player in ipairs(Players:GetPlayers()) do
			SaveService.unloadPlayer(player)
		end

		-- Chờ tất cả UpdateAsync (kể cả retry đang chạy) hoàn thành.
		local deadline = os.clock() + BIND_TO_CLOSE_TIMEOUT_SECONDS
		while DataStoreWrapper.getPendingSaveCount() > 0 and os.clock() < deadline do
			task.wait(0.1)
		end

		local remaining = DataStoreWrapper.getPendingSaveCount()
		if remaining > 0 then
			warn(string.format("[SaveService] BindToClose timeout — %d lệnh lưu chưa hoàn thành!", remaining))
		else
			print("[SaveService] Tất cả lệnh lưu hoàn thành. Server tắt an sau.")
		end
	end)

	-- Autosave loop.
	task.spawn(function()
		while not shuttingDown do
			task.wait(AUTOSAVE_INTERVAL_SECONDS)
			if not shuttingDown then
				SaveService.saveDirtyPlayers()
			end
		end
	end)

	-- Load người chơi đã vào trước SaveService.init().
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			SaveService.loadPlayer(player)
		end)
	end
end

return SaveService
