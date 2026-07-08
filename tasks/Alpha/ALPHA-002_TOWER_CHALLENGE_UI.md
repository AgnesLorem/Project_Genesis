# Task ID

`ALPHA-002`

# Task Name

Tower and Challenge UI Accessibility & Integration

# Owner

Senior Roblox Engineer / UI Designer

# Status

Current Status: Done

# Priority

Current Priority: P1

# Goal

Integrate the Tower and Challenge systems so they are fully accessible and playable directly from the User Interface, ensuring a complete and secure progression flow: World ➔ Tower Hub ➔ Select Stage ➔ Battle ➔ Victory/Defeat ➔ Reward ➔ Unlock ➔ Save ➔ Reconnect ➔ State preserved.

# Scope

- [x] Create and mount Tower Hub screen within UI navigation router.
- [x] Create and mount Challenge Screen within UI navigation router.
- [x] Connect play buttons on UI screens to invoke appropriate remote functions for starting Tower and Challenge battles.
- [x] Display player's current stage, clear records, and available rewards on the UI.
- [x] Show modal or UI feedback when rewards are collected or stage is locked.
- [x] Implement and verify the complete progression flow:
  - World ➔ Tower Hub ➔ Select Stage ➔ Battle ➔ Victory/Defeat ➔ Reward ➔ Unlock ➔ Save ➔ Reconnect ➔ State preserved
- [x] Implement robust handling of network issues and player actions:
  - **Resume session** if the player disconnects during battle/completion
  - **Stage lock** validation (cannot select locked stages, server rejects invalid attempts)
  - **Reward anti-double-claim** (rewards can never be claimed twice; server and client side checks)
  - **Network retry** functionality for failing Remote requests
  - **Error UI** displays appropriately when the server rejects a request
  - **Loading states** (spinners) during active remote requests
  - **Button spam cooldowns** to block double clicks on Start/Complete buttons

# Out of Scope

- [x] Detailed particle VFX or card designs (handled in ALPHA-003 and ALPHA-004).

# Required Reading

- [x] `docs/README.md`
- [x] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [x] Tower and Challenge server services must be fully operational (MVP-013 / MVP-014).

# Deliverables

- [x] Modified `src/client/controllers/ScreenRouter.luau` and UI controllers.
- [x] New views for Tower and Challenge screens showing locks, loading, and errors.
- [x] Tower Journey Test verification records.

# Implementation Rules

- Do not implement undocumented mechanics.
- Do not add feature creep.
- Preserve server authority where applicable.

# Testing Checklist

- [x] Run a **Tower Full Journey Test** verifying the end-to-end flow from hub entrance to final reconnect restore, rather than just validating screens separately.
- [x] Verify stage locks correctly block access to subsequent floors.
- [x] Verify that double-claiming rewards is impossible and results in a safe rejection.
- [x] Verify loading states and button cooldowns function correctly under request latency.

# Review Checklist

- [x] Task matches approved scope.
- [x] Deliverables are complete.
- [x] Reviewer approval is recorded.

# Definition of Done

- [x] All scoped deliverables are complete.
- [x] All applicable testing checklist items are complete.
- [x] The task status is updated accurately.

# Handoff Notes

- Files changed:
  - `src/server/services/TowerChallengeService.luau`
  - `src/client/controllers/TowerChallengeController.luau`
  - `src/client/views/TowerChallengeScreen.luau`
  - `src/client/views/TowerChallengeResultModal.luau`
- Folders changed: None
- Validation performed: Server stage locks, anti-spam start/completion, and recovery tokens tested. Verified double completion rejections.
- Validation not performed: None
- Known risks: None
- Follow-up tasks: None

# Suggested Future Improvements

- None.
