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

Integrate the Tower and Challenge systems so they are fully accessible and playable directly from the User Interface, rather than requiring debug commands or console scripts.

# Scope

- [ ] Create and mount Tower Hub screen within UI navigation router.
- [ ] Create and mount Challenge Screen within UI navigation router.
- [ ] Connect play buttons on UI screens to invoke appropriate remote functions for starting Tower and Challenge battles.
- [ ] Display player's current stage, clear records, and available rewards on the UI.
- [ ] Show modal or UI feedback when rewards are collected or stage is locked.

# Out of Scope

- [ ] Detailed particle VFX or card designs (handled in ALPHA-003 and ALPHA-004).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] Tower and Challenge server services must be fully operational (MVP-013 / MVP-014).

# Deliverables

- [ ] Modified `src/client/controllers/ScreenRouter.luau` and UI controllers.
- [ ] New views for Tower and Challenge screens.

# Implementation Rules

- Do not implement undocumented mechanics.
- Do not add feature creep.
- Preserve server authority where applicable.

# Testing Checklist

- [ ] Tower battles can be entered and completed from UI.
- [ ] Challenge battles can be entered and completed from UI.
- [ ] UI correctly updates stage locks/unlocks.

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
