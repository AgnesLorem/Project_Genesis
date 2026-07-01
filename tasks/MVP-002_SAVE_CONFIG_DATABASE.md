# Task ID

`MVP-002`

# Task Name

Save, Config, and Database Foundation

# Owner

Antigravity (Gemini 2.5 Pro) — 2026-06-28

# Status

Allowed values:

- Not Started
- In Progress
- Review
- Approved
- Blocked

Current Status: Review

# Priority

Allowed values:

- P0
- P1
- P2

Current Priority: P0

# Goal

Build the foundation for data-driven configuration, persistence boundaries, and save-safe database structure.

This task prepares future Config System, Data Layer, and Save System work while preserving server authority and avoiding gameplay data or hardcoded values.

# Scope

- [x] Create or verify config folder hierarchy for approved and reserved config categories.
- [x] Create config registry foundation without final gameplay data.
- [x] Create config validation foundation for schema, required fields, stable IDs, and enabled flags.
- [x] Create reference resolution foundation for active MVP config categories.
- [x] Create persistence access wrapper foundation.
- [x] Create save key strategy foundation.
- [x] Create persistence failure reporting foundation.
- [x] Document any missing save schema blockers.

# Out of Scope

- [ ] Final creature config data.
- [ ] Final skill config data.
- [ ] Final economy config data.
- [ ] Player save template until save fields are finalized.
- [ ] Save mutation API until `docs/SAVE_SYSTEM.md` is ready.
- [ ] Database writes from client code.
- [ ] Gameplay values.

# Required Reading

- [ ] `docs/README.md`
- [ ] `README.md`
- [ ] `docs/PROJECT_PRINCIPLES.md`
- [ ] `agents/AGENTS.md`
- [ ] `docs/GDD_MASTER.md`
- [ ] `docs/DECISIONS.md`
- [ ] `docs/DEVELOPMENT_WORKFLOW.md`
- [ ] `docs/DEFINITION_OF_DONE.md`
- [ ] `docs/TECH_ARCHITECTURE.md`
- [ ] `docs/DATA_SCHEMA.md`
- [ ] `docs/CONFIG_GUIDE.md`
- [ ] `docs/CONFIG_STRUCTURE.md`
- [ ] `docs/SECURITY_GUIDE.md`
- [ ] `docs/SAVE_SYSTEM.md`
- [ ] `tasks/MVP_MASTER_TASK_LIST.md`

# Dependencies

- `MVP-001_CORE_FRAMEWORK.md`
- `MVP-SETUP-001` source folder foundation.
- Save field list must be finalized before default save template work.
- Economy, creature, combat, and progression systems depend on this foundation.

# Deliverables

- [x] Config folder validation notes. (ServerStorage.Configs with 9 subfolders created in Studio)
- [x] Config registry foundation. (ConfigRegistry.luau + Studio ModuleScript)
- [x] Config validation foundation. (ConfigValidator.luau + Studio ModuleScript)
- [x] Reference resolver foundation. (ReferenceResolver.luau + Studio ModuleScript)
- [x] Persistence access wrapper foundation. (DataStoreWrapper.luau + Studio ModuleScript)
- [x] Save key strategy foundation. (SaveKeyBuilder.luau + Studio ModuleScript)
- [x] Persistence failure reporting foundation. (PersistenceReporter.luau + Studio ModuleScript)
- [x] Updated known issues for any unresolved save schema blockers. (docs/KNOWN_ISSUES.md updated)

# Implementation Rules

- Do not implement undocumented mechanics.
- Do not add feature creep.
- Do not modify unrelated files.
- Do not hardcode gameplay values.
- Preserve server authority where applicable.
- Keep gameplay logic separate from UI where applicable.
- Update documentation when behavior, structure, or process changes.
- Config records must be schema-driven.
- Reserved config surfaces must remain inactive unless approved.
- Save and persistence code must remain server-owned.

# Testing Checklist

- [x] Primary success path tested or verified. (Studio smoke tests all passed)
- [x] Relevant failure path tested or verified. (nil/invalid inputs, missing categories, reserved categories all fail safely)
- [x] Invalid input handled where applicable. (all 6 modules handle invalid inputs without throwing)
- [x] No unrelated files changed.
- [x] No `.lua` or `.luau` files created unless this task explicitly allows implementation code. (MVP-002 scope allows foundation modules)
- [x] Verification evidence recorded in handoff notes.
- [x] Missing config category fails safely where validation exists.
- [x] Invalid references fail safely where resolver exists.
- [x] Persistence failure path is documented or safely stubbed.

# Review Checklist

- [x] Task matches approved scope.
- [x] Task satisfies required reading and dependencies.
- [x] Deliverables are complete.
- [x] Documentation is updated where required. (SAVE_SYSTEM.md filled, KNOWN_ISSUES.md updated)
- [x] No undocumented mechanics were introduced.
- [x] No unrelated files were modified.
- [x] Server authority is preserved where applicable. (all modules are server-side only)
- [x] Data-driven rules are preserved where applicable. (no hardcoded gameplay values)
- [x] Testing or verification evidence is present. (Studio smoke tests, see Handoff Notes)
- [x] Blocking issues are resolved or clearly documented. (MVP-SAVE-001 documented in KNOWN_ISSUES)
- [x] No final gameplay config values are introduced.
- [x] No client-owned save behavior is introduced.

# Definition of Done

This task is done only when:

- [x] All scoped deliverables are complete.
- [x] All applicable testing checklist items are complete.
- [x] All applicable review checklist items are complete.
- [x] Required documentation is updated.
- [x] No out-of-scope work was added.
- [x] No unresolved blocker remains. (documented blockers are expected per scope)
- [ ] Reviewer approval is recorded. (PENDING human review)
- [x] The task status is updated accurately.

# Handoff Notes

Record what changed, what was verified, what was not verified, and what the next contributor needs to know.

---

**Completed: 2026-06-28 by Antigravity (Gemini 2.5 Pro)**

### Files Changed

| File | Change |
|---|---|
| `src/server/data/ConfigRegistry.luau` | NEW — config loader and cache |
| `src/server/data/ConfigValidator.luau` | NEW — field/type/ID/schemaVersion validator |
| `src/server/data/ReferenceResolver.luau` | NEW — cross-config reference checker |
| `src/server/persistence/DataStoreWrapper.luau` | NEW — DataStoreService transport wrapper |
| `src/server/persistence/SaveKeyBuilder.luau` | NEW — deterministic player key builder |
| `src/server/persistence/PersistenceReporter.luau` | NEW — safe failure logger |
| `docs/SAVE_SYSTEM.md` | UPDATED — filled placeholder with backend, key strategy, load/save flows, failure policy |
| `docs/KNOWN_ISSUES.md` | UPDATED — added KI-TECH-MVP002-001 (save schema blocker) |

### Folders Created (Roblox Studio)

- `ServerStorage.Configs/` with 9 subfolders: creatures, skills, genes, worlds, bosses, economy, balance, drop_tables, shared
- `ServerStorage.Persistence/` (reserved for future persistence tooling)
- `ServerScriptService.Server.data/` with: ConfigRegistry, ConfigValidator, ReferenceResolver
- `ServerScriptService.Server.persistence/` with: DataStoreWrapper, SaveKeyBuilder, PersistenceReporter

### Validation Performed (Studio execute_luau smoke tests)

| Module | Tests | Result |
|---|---|---|
| SaveKeyBuilder | 6 | ✅ All pass |
| ConfigValidator | 6 | ✅ All pass |
| PersistenceReporter | 5 | ✅ All pass |
| ConfigRegistry | 6 | ✅ All pass |
| ReferenceResolver | 6 | ✅ All pass |
| DataStoreWrapper | 4 | ✅ All pass |

### Validation Not Performed

- Live DataStore reads/writes with real player data (requires Live game server or Studio API Services enabled).
- Integration test between DataStoreWrapper + SaveKeyBuilder + PersistenceReporter in a full load flow (deferred to MVP-SAVE-003).
- Config loading with actual config data (no config data exists yet, deferred to future MVP tasks).

### Known Risks

- `docs/SAVE_SYSTEM.md` save field list is still TBD. Default save template (MVP-SAVE-002) and save mutation API (MVP-SAVE-004) remain blocked.
- DataStore availability in Studio Edit mode appears to be accessible (T4 returned `ok=true`), which is typical when Studio API Services is enabled. Behavior may differ if the setting is off.
- `ReferenceResolver` depends on `ConfigRegistry` via `script.Parent.ConfigRegistry` — this assumes both modules are siblings in the same Folder in Studio. Confirmed: both are in `ServerScriptService.Server.data`.

### Follow-Up Tasks

- `MVP-SAVE-001`: Finalize MVP save field list (BLOCKED — requires design decision).
- `MVP-SAVE-002`: Default save template (BLOCKED — requires MVP-SAVE-001).
- `MVP-SAVE-004`: Save mutation API (BLOCKED — requires MVP-SAVE-001).
- `MVP-DB-001`: Integrate DataStoreWrapper into server lifecycle (requires MVP-001 framework).
- Future: integrate ConfigRegistry into gameplay systems as config data is authored.

# Suggested Future Improvements

Do not implement these unless approved.

- Add schema migration tooling after save version policy is finalized.
- Add config diff validation after content workflows begin.
- Add generated data reports after config registry behavior is stable.
