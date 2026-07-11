# Task ID

`ALPHA-006`

# Task Name

UI Smoke Testing Suite Implementation

# Owner

QA Engineer / Client Developer

# Status

Current Status: Done

# Priority

Current Priority: P1

# Goal

Develop automated smoke tests for each main UI screen, ensuring they can be mounted, navigated, and unmounted without throwing Lua exceptions or hanging the client thread.

# Scope

- [x] Write smoke tests for Starter Selection Screen.
- [x] Write smoke tests for Generator Panel UI.
- [x] Write smoke tests for World Screen and Stage selection UI.
- [x] Write smoke tests for Combat Screen (initialization and completion states).
- [x] Write smoke tests for Collection UI.
- [x] Write smoke tests for Inventory and Equipment screens.
- [x] Write smoke tests for Skill Panel UI.
- [x] Write smoke tests for Tower and Challenge screens.
- [x] Integrate smoke tests into a central QA utility or GameplaySimulator.

# Out of Scope

- [ ] Real-user playtesting (automated validation only).

# Required Reading

- [x] `docs/README.md`
- [x] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [x] UI screens must be implemented (functional layouts).

# Deliverables

- [x] New UI smoke testing script (`src/client/controllers/UISmokeTester.luau` or additions to `GameplaySimulator.luau`).
- [x] Test report containing results of mounting/unmounting checks.

# Implementation Rules

- Test scripts must run on Client threads and check for visual nodes.
- Do not make changes to production UI layout code during test runs.

# Testing Checklist

- [x] All main UI screens tested for successful mount/unmount.
- [x] Interacting with key buttons (open/close) verified without error.

# Review Checklist

- [x] Smoke tests cover all defined UI screens.
- [x] Reviewer approval is recorded.

# Definition of Done

- [x] All scoped deliverables are complete.
- [x] Automation runs cleanly on Play Solo.
- [x] Reviewer approval is recorded.

# Handoff Notes

- Files changed:
  - `src/client/controllers/UISmokeTester.luau` (New)
  - `src/client/controllers/GameplaySimulator.luau` (Modified to run tests)
- Folders changed: None
- Validation performed:
  - Executed UI Smoke Testing suite via `GameplaySimulator.runUISmokeTests()` in Roblox Studio Play Solo mode (Client data model).
  - All 9 screens tested (StarterSelectionScreen, GeneratorPanel, WorldScreen, CombatScreen, CollectionBookScreen, CreatureInventoryScreen, EquipmentScreen, SkillPanel, TowerChallengeScreen).
  - 180 total mount/cleanup cycles run (20 per screen) with 0 failures, 0 callback leaks, 0 orphan UI elements, and connection cleanup successfully validated via idempotent double cleanup.
- Validation not performed:
  - StyLua check, Selene check, and python configuration validation (tools not present on the host environment).
- Known risks: None.
- Follow-up tasks: None.

# Suggested Future Improvements

- None.
