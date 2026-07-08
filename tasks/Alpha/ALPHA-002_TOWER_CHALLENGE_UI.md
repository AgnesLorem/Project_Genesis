# Task ID

`ALPHA-002`

# Task Name

Tower and Challenge UI Accessibility & Integration

# Owner

Senior Roblox Engineer / UI Designer

# Status

Current Status: Not Started

# Priority

Current Priority: P1

# Goal

Integrate the Tower and Challenge systems so they are fully accessible and playable directly from the User Interface, ensuring a complete and secure progression flow: World ➔ Tower Hub ➔ Select Stage ➔ Battle ➔ Victory/Defeat ➔ Reward ➔ Unlock ➔ Save ➔ Reconnect ➔ State preserved.

# Scope

- [ ] Create and mount Tower Hub screen within UI navigation router.
- [ ] Create and mount Challenge Screen within UI navigation router.
- [ ] Connect play buttons on UI screens to invoke appropriate remote functions for starting Tower and Challenge battles.
- [ ] Display player's current stage, clear records, and available rewards on the UI.
- [ ] Show modal or UI feedback when rewards are collected or stage is locked.
- [ ] Implement and verify the complete progression flow:
  - World ➔ Tower Hub ➔ Select Stage ➔ Battle ➔ Victory/Defeat ➔ Reward ➔ Unlock ➔ Save ➔ Reconnect ➔ State preserved
- [ ] Implement robust handling of network issues and player actions:
  - **Resume session** if the player disconnects during battle/completion
  - **Stage lock** validation (cannot select locked stages, server rejects invalid attempts)
  - **Reward anti-double-claim** (rewards can never be claimed twice; server and client side checks)
  - **Network retry** functionality for failing Remote requests
  - **Error UI** displays appropriately when the server rejects a request
  - **Loading states** (spinners) during active remote requests
  - **Button spam cooldowns** to block double clicks on Start/Complete buttons

# Out of Scope

- [ ] Detailed particle VFX or card designs (handled in ALPHA-003 and ALPHA-004).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] Tower and Challenge server services must be fully operational (MVP-013 / MVP-014).

# Deliverables

- [ ] Modified `src/client/controllers/ScreenRouter.luau` and UI controllers.
- [ ] New views for Tower and Challenge screens showing locks, loading, and errors.
- [ ] Tower Full Journey Test verification records.

# Implementation Rules

- Do not implement undocumented mechanics.
- Do not add feature creep.
- Preserve server authority where applicable.

# Testing Checklist

- [ ] Run a **Tower Full Journey Test** verifying the end-to-end flow from hub entrance to final reconnect restore, rather than just validating screens separately.
- [ ] Verify stage locks correctly block access to subsequent floors.
- [ ] Verify that double-claiming rewards is impossible and results in a safe rejection.
- [ ] Verify loading states and button cooldowns function correctly under request latency.

# Review Checklist

- [ ] Task matches approved scope.
- [ ] Deliverables are complete.
- [ ] Reviewer approval is recorded.

# Definition of Done

- [ ] All scoped deliverables are complete.
- [ ] All applicable testing checklist items are complete.
- [ ] The task status is updated accurately.

# Handoff Notes

- Files changed:
- Folders changed:
- Validation performed:
- Validation not performed:
- Known risks:
- Follow-up tasks:

# Suggested Future Improvements

- None.
