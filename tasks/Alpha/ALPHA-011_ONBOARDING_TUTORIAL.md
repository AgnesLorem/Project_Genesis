# Task ID

`ALPHA-011`

# Task Name

Onboarding and Interactive Tutorial

# Owner

Game Designer / Client Engineer

# Status

Current Status: Not Started

# Priority

Current Priority: P0

# Goal

Design and implement a clear 3-5 step onboarding tutorial for new players. The tutorial should guide the player through selecting their starter, upgrading their first generator, claiming biomass, entering a story battle, and explaining basic economy loops (Biomass, DNA) and navigation.

# Scope

- [ ] Implement onboarding state tracker in PlayerSave structure (e.g. `tutorialStep`).
- [ ] Create UI Highlight Controller to draw overlay circles and pointers pointing to specific buttons.
- [ ] Implement Step 1: Guided Starter Selection (locked highlights).
- [ ] Implement Step 2: Generator Intro (highlight generator tab, upgrade button, claim button).
- [ ] Implement Step 3: Battle Intro (highlight world tab, start battle button).
- [ ] Implement Step 4: Progression Intro (explain DNA, level ups, and unlocks).
- [ ] Create Starter Quest checklist visible on the HUD.
- [ ] Add tooltips/dialog boxes guiding the user through steps.

# Out of Scope

- [ ] Detailed story cutscenes or cinematic sequences.

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] Core UI components and screen routing must be fully stable.

# Deliverables

- [ ] UI highlight helper (`src/client/views/UIHighlightHelper.luau`).
- [ ] Tutorial Controller (`src/client/controllers/TutorialController.luau`).
- [ ] Updated Save Schema containing tutorial states.

# Implementation Rules

- Keep tutorial logic modular so it can be skipped or easily modified.
- Do not let the tutorial lock up input permanently in case of unexpected errors.

# Testing Checklist

- [ ] Complete the entire tutorial flow from a fresh account.
- [ ] Verify that skipping or reloading during the tutorial loads the correct step state.
- [ ] Verify that UI highlights align correctly across different screen resolutions.

# Review Checklist

- [ ] Onboarding is intuitive and guides new players clearly.
- [ ] Reviewer approval is recorded.

# Definition of Done

- [ ] Scoped tutorial steps are complete.
- [ ] Fresh account test runs succeed.
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
