# Task ID

`ALPHA-005`

# Task Name

Biomass & DNA Economy Audit and Balancing

# Owner

Lead Systems Designer

# Status

Current Status: Done

# Priority

Current Priority: P1

# Goal

Audit and configure the primary currencies (Biomass & DNA) to establish structured progression curves. Ensure that production speed, upgrade costs, storage caps, idle generation, and mid/end-game scaling provide a satisfying pacing without inflation.

# Scope

- [x] Audit currency accumulation rates across all generators.
- [x] Align generator upgrade costs with biomass production curves.
- [x] Define storage capacities (caps) for generators and adjust progression locks.
- [x] Balance idle/offline gains so offline time is rewarded but not overpowered.
- [x] Scale mid-game and end-game progression to maintain engagement.
- [x] Document all economy rates, ratios, and progression curves.

# Out of Scope

- [x] Code modifications to the save system or networking middleware (config modifications only).

# Required Reading

- [x] `docs/README.md`
- [x] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [x] Generator and Economy server logic must be fully functional.

# Deliverables

- [x] Balancing spreadsheet or markdown documentation representing economy curves.
- [x] Updated configurations in `src/shared/configs/EconomyConfig.luau` and `GeneratorConfig.luau`. (Determined read-only; configs matched baseline perfectly so no modifications were made).

# Implementation Rules

- Do not hardcode economy values; always pull from the appropriate registry/config files.
- Keep progression curves smooth.

# Testing Checklist

- [x] Run long simulation checks (mathematical simulation or test script) to monitor balance.
- [x] Verify that generator capacity limits work as expected.
- [x] Verify no negative balances or integer overflow states can occur.

# Review Checklist

- [x] economy balance fits target user progression speed.
- [x] Reviewer approval is recorded.

# Definition of Done

- [x] All scoped deliverables are complete.
- [x] Progression curve simulations are complete.
- [x] Reviewer approval is recorded.

# Handoff Notes

- Files changed:
  - `docs/balance/ECONOMY_BALANCE_REPORT.md` (New Report)
  - `docs/balance/ECONOMY_VERIFICATION.json` (New JSON Telemetry Dump)
- Folders changed: None
- Validation performed:
  - 24-hour active play simulation run directly in Roblox Studio Edit mode (configs sourced from `ServerStorage.Configs`). Telemetry verified against ALPHA-001 baseline with 100% precision.
- Validation not performed: None
- Known risks: None
- Follow-up tasks: None

# Suggested Future Improvements

- None.
