# Task ID

`ALPHA-005`

# Task Name

Biomass & DNA Economy Audit and Balancing

# Owner

Lead Systems Designer

# Status

Current Status: Not Started

# Priority

Current Priority: P1

# Goal

Audit and configure the primary currencies (Biomass & DNA) to establish structured progression curves. Ensure that production speed, upgrade costs, storage caps, idle generation, and mid/end-game scaling provide a satisfying pacing without inflation.

# Scope

- [ ] Audit currency accumulation rates across all generators.
- [ ] Align generator upgrade costs with biomass production curves.
- [ ] Define storage capacities (caps) for generators and adjust progression locks.
- [ ] Balance idle/offline gains so offline time is rewarded but not overpowered.
- [ ] Scale mid-game and end-game progression to maintain engagement.
- [ ] Document all economy rates, ratios, and progression curves.

# Out of Scope

- [ ] Code modifications to the save system or networking middleware (config modifications only).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] Generator and Economy server logic must be fully functional.

# Deliverables

- [ ] Balancing spreadsheet or markdown documentation representing economy curves.
- [ ] Updated configurations in `src/shared/configs/EconomyConfig.luau` and `GeneratorConfig.luau`.

# Implementation Rules

- Do not hardcode economy values; always pull from the appropriate registry/config files.
- Keep progression curves smooth.

# Testing Checklist

- [ ] Run long simulation checks (mathematical simulation or test script) to monitor balance.
- [ ] Verify that generator capacity limits work as expected.
- [ ] Verify no negative balances or integer overflow states can occur.

# Review Checklist

- [ ] economy balance fits target user progression speed.
- [ ] Reviewer approval is recorded.

# Definition of Done

- [ ] All scoped deliverables are complete.
- [ ] Progression curve simulations are complete.
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
