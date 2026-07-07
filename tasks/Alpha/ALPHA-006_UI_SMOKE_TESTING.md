# Task ID

`ALPHA-006`

# Task Name

UI Smoke Testing Suite Implementation

# Owner

QA Engineer / Client Developer

# Status

Current Status: Not Started

# Priority

Current Priority: P1

# Goal

Develop automated smoke tests for each main UI screen, ensuring they can be mounted, navigated, and unmounted without throwing Lua exceptions or hanging the client thread.

# Scope

- [ ] Write smoke tests for Starter Selection Screen.
- [ ] Write smoke tests for Generator Panel UI.
- [ ] Write smoke tests for World Screen and Stage selection UI.
- [ ] Write smoke tests for Combat Screen (initialization and completion states).
- [ ] Write smoke tests for Collection UI.
- [ ] Write smoke tests for Inventory and Equipment screens.
- [ ] Write smoke tests for Skill Panel UI.
- [ ] Write smoke tests for Tower and Challenge screens.
- [ ] Integrate smoke tests into a central QA utility or GameplaySimulator.

# Out of Scope

- [ ] Real-user playtesting (automated validation only).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] UI screens must be implemented (functional layouts).

# Deliverables

- [ ] New UI smoke testing script (`src/client/controllers/UISmokeTester.luau` or additions to `GameplaySimulator.luau`).
- [ ] Test report containing results of mounting/unmounting checks.

# Implementation Rules

- Test scripts must run on Client threads and check for visual nodes.
- Do not make changes to production UI layout code during test runs.

# Testing Checklist

- [ ] All main UI screens tested for successful mount/unmount.
- [ ] Interacting with key buttons (open/close) verified without error.

# Review Checklist

- [ ] Smoke tests cover all defined UI screens.
- [ ] Reviewer approval is recorded.

# Definition of Done

- [ ] All scoped deliverables are complete.
- [ ] Automation runs cleanly on Play Solo.
- [ ] Reviewer approval is recorded.

# Handoff Notes

- Files changed:
- Folders changed:
- Validation performed:
- Validation not performed:
- Known risks:
- Follow-up tasks:

# Suggested Future Improvements

- None.
