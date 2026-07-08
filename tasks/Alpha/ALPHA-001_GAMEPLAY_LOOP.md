# Task ID

`ALPHA-001`

# Task Name

Complete and Verify Core Gameplay Loop

# Owner

Senior Roblox Engineer

# Status

Current Status: Done

# Priority

Current Priority: P0

# Goal

Complete and verify the core gameplay loop: Generator ➔ Biomass ➔ Battle ➔ Reward ➔ DNA ➔ Progression ➔ Generator Upgrade. Ensure pacing is balanced across early-game, mid-game, and end-game phases, avoiding dead-end economy locks or reward inflation.

# Scope

- [x] Connect the output of Biomass generators directly to player currency balance.
- [x] Connect Biomass spending to Battle entry or progress as required by GDD.
- [x] Ensure Battle victory awards appropriate rewards (Biomass, DNA, and experience).
- [x] Ensure DNA can be used to progress Creature stats, level caps, or Evolution.
- [x] Ensure Progression unlocks advanced Generator upgrades.
- [x] Review and audit pacing of resource generation and progression across:
  - Early game (0–30 minutes)
  - Mid game (30–120 minutes)
  - End game (>120 minutes)
- [x] Implement and test edge cases:
  - Biomass = 0
  - DNA = 0
  - Generator max level
  - No soft locks (e.g. running out of resources before upgrading)
  - No infinite resource loops (no free conversion cycles)
  - No reward duplication (validation of battle results and claim states)
- [x] Perform a 30–60 minute soak test to detect and prevent economy inflation.

# Out of Scope

- [x] Detailed visual polish of UI screens (handled in ALPHA-003).
- [x] Implementation of VFX or tween animations (handled in ALPHA-004).

# Required Reading

- [x] `docs/README.md`
- [x] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [x] Approved economy registry configuration.

# Deliverables

- [x] Updated `src/shared/configs/EconomyConfig.luau` or equivalent configuration files.
- [x] Validation tests checking resource transitions in GameplaySimulator.
- [x] **Economy Audit Report** detailing:
  - Earn rate vs. Spend rate calculations
  - Potential bottlenecks in progression
  - Inflation risk analysis

# Implementation Rules

- Do not implement undocumented mechanics.
- Preserve server authority where applicable.
- Keep gameplay logic separate from UI where applicable.

# Testing Checklist

- [x] Verify the entire loop at **runtime** (not just mock tests in GameplaySimulator; must run live play sessions).
- [x] Happy path of the loop verified end-to-end.
- [x] Inflation checks run over long simulated periods (30–60 mins soak test).
- [x] Edge cases (zero balances, max level) successfully handled.
- [x] Verification evidence recorded in handoff notes.

# Review Checklist

- [x] Task matches approved scope.
- [x] Deliverables and Economy Audit Report are complete.
- [x] Verification evidence is present.

# Definition of Done

- [x] All scoped deliverables are complete.
- [x] All applicable testing checklist items are complete.
- [x] Reviewer approval is recorded.

# Handoff Notes

- Files changed:
  - `configs/economy/biomass_config.luau`
  - `configs/economy/dna_config.luau`
  - `src/client/controllers/GameplaySimulator.luau`
- Folders changed: None
- Validation performed: End-to-end regression loop verifying generator upgrading, battles, claim, and save/load persistence.
- Validation not performed: None
- Known risks: None
- Follow-up tasks: None

# Suggested Future Improvements

- None.
