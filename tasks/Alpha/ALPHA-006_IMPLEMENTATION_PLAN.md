# Implementation Plan: ALPHA-006 (UI Smoke Testing Suite)

> [!IMPORTANT]
> **Scope Restriction**: ALPHA-006 is a QA and verification task only. It must not introduce gameplay features, economy tuning, server-authoritative logic changes, networking changes, persistence/schema changes, or UI redesigns unless explicitly required to make the test infrastructure function.

## Goal
Develop automated smoke tests for each main UI screen, ensuring they can be mounted, navigated, and unmounted without throwing Lua exceptions or hanging the client thread.

---

## Objectives & Test Scenarios
Implement `UISmokeTester.luau` to run client-side smoke tests for the 8 main UI screens:
1. **StarterSelectionScreen**
2. **GeneratorPanel**
3. **WorldScreen**
4. **CombatScreen** (and `BattleResultModal`)
5. **CollectionBookScreen**
6. **CreatureInventoryScreen** (and `CreatureDetailPanel`)
7. **EquipmentScreen**
8. **SkillPanel** & **TowerChallengeScreen**

---

## Custom Testing Assertions
- **UI Count Before Test**: Before running the suite, assert that the children count under `GenesisMainUI` is exactly `0`.
- **Rapid Open/Close**: Iterate `mount -> wait -> cleanup -> wait` 20 times sequentially for each screen to detect memory leaks and instability.
- **Double Cleanup**: Call `UIController.cleanup()` twice consecutively during teardown to verify that cleanup is idempotent.
- **Exception Isolation (Non-Aborting)**: Wrap each screen test in a separate `pcall`. If a screen fails, record it as a failure and log it. Individual failures **must not** abort the remaining test executions—the test runner must always proceed to completion and produce the final summary.
- **Time Budgeting**: Measure and record the mount time, cleanup time, and total suite execution time.
- **Orphan Guard**: Verify that `GenesisMainUI` has exactly 0 children after calling `cleanup()`.
- **Callback Leak Check**: Verify that callbacks are executed exactly `expectedCount` times (i.e. `callbackCount == expectedCount`), confirming no callback leaks across multiple mount cycles.
- **Connection Teardown**: Verify that `UIController.uisConnection` is disconnected.

---

## Proposed Changes

### 1. `src/client/controllers/UISmokeTester.luau` [NEW]
A standalone client-side QA controller:
- Implements `UISmokeTester.runAllTests()`.
- Uses `pcall` execution guards for every test stage.
- Implements a stress-mount check running 20 mount/cleanup iterations for each screen.
- Validates the count of children under `GenesisMainUI` after unmounting to guarantee no orphan objects.
- Asserts callback counters are exactly equal to expected execution counts.
- Reports test summaries (pass/fail/telemetry logs) to the console.

### 2. `src/client/controllers/GameplaySimulator.luau` [MODIFY]
- Import `UISmokeTester`.
- Add `GameplaySimulator.runUISmokeTests()` method.
- Integrate the UI smoke testing sequence into the default automated regression loop so that both UI and gameplay loops are covered in a single test run.

---

## Final Summary Format
Print the output in the following formatted block:
```text
=========================
UI SMOKE TEST SUMMARY
=========================
Screens tested: 8
Mount cycles: 160
Callbacks verified: PASS
Orphan UI: PASS
Connection cleanup: PASS
Memory leak detected: NO
Failures: 0

OVERALL RESULT: PASS
```

---

## Acceptance Criteria
- All 8 UI screens complete the smoke suite.
- No F9 errors.
- No new warnings.
- No orphan UI objects.
- No callback leaks.
- No lingering tracked connections.
- Overall result: PASS.
