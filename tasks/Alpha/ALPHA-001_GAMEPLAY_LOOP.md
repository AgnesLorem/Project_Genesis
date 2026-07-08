# Task ID

`ALPHA-001`

# Task Name

Complete and Verify Core Gameplay Loop

# Owner

Senior Roblox Engineer

# Status

Current Status: Not Started

# Priority

Current Priority: P0

# Goal

Complete and verify the core gameplay loop: Generator ➔ Biomass ➔ Battle ➔ Reward ➔ DNA ➔ Progression ➔ Generator Upgrade. Ensure pacing is balanced across early-game, mid-game, and end-game phases, avoiding dead-end economy locks or reward inflation.

# Scope

- [ ] Connect the output of Biomass generators directly to player currency balance.
- [ ] Connect Biomass spending to Battle entry or progress as required by GDD.
- [ ] Ensure Battle victory awards appropriate rewards (Biomass, DNA, and experience).
- [ ] Ensure DNA can be used to progress Creature stats, level caps, or Evolution.
- [ ] Ensure Progression unlocks advanced Generator upgrades.
- [ ] Review and audit pacing of resource generation and progression across:
  - Early game (0–30 minutes)
  - Mid game (30–120 minutes)
  - End game (>120 minutes)
- [ ] Implement and test edge cases:
  - Biomass = 0
  - DNA = 0
  - Generator max level
  - No soft locks (e.g. running out of resources before upgrading)
  - No infinite resource loops (no free conversion cycles)
  - No reward duplication (validation of battle results and claim states)
- [ ] Perform a 30–60 minute soak test to detect and prevent economy inflation.

# Out of Scope

- [ ] Detailed visual polish of UI screens (handled in ALPHA-003).
- [ ] Implementation of VFX or tween animations (handled in ALPHA-004).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] Approved economy registry configuration.

# Deliverables

- [ ] Updated `src/shared/configs/EconomyConfig.luau` or equivalent configuration files.
- [ ] Validation tests checking resource transitions in GameplaySimulator.
- [ ] **Economy Audit Report** detailing:
  - Earn rate vs. Spend rate calculations
  - Potential bottlenecks in progression
  - Inflation risk analysis

# Implementation Rules

- Do not implement undocumented mechanics.
- Preserve server authority where applicable.
- Keep gameplay logic separate from UI where applicable.

# Testing Checklist

- [ ] Verify the entire loop at **runtime** (not just mock tests in GameplaySimulator; must run live play sessions).
- [ ] Happy path of the loop verified end-to-end.
- [ ] Inflation checks run over long simulated periods (30–60 mins soak test).
- [ ] Edge cases (zero balances, max level) successfully handled.
- [ ] Verification evidence recorded in handoff notes.

# Review Checklist

- [ ] Task matches approved scope.
- [ ] Deliverables and Economy Audit Report are complete.
- [ ] Verification evidence is present.

# Definition of Done

- [ ] All scoped deliverables are complete.
- [ ] All applicable testing checklist items are complete.
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
