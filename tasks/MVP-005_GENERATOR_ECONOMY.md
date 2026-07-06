# Task ID

`MVP-005`

# Task Name

Bio Generator and Economy Foundation

# Owner

Unassigned

# Status

Allowed values:

- Not Started
- In Progress
- Review
- Approved
- Blocked

Current Status: Approved

# Priority

Allowed values:

- P0
- P1
- P2

Current Priority: P0

# Goal

Implement the approved MVP Bio Generator and economy foundation.

This task must support Biomass generation, Biomass claiming, Biomass spend validation, DNA reward foundation, Economy Config validation, and server-authoritative currency handling using data-driven configuration only.

# Scope

- [x] Implement Bio Generator foundation as an approved MVP system.
- [x] Implement Biomass generation using data-driven config values only.
- [x] Implement server-authoritative Biomass claim flow.
- [x] Implement server-side Biomass spend validation.
- [x] Implement DNA reward foundation through approved economy reward handling.
- [x] Implement Economy Config schema validation.
- [x] Implement server-only reward grant foundation for approved reward sources.
- [x] Implement server-authoritative currency balance handling.
- [x] Document any missing Biomass, DNA, rate, cap, claim, or spend config values as blockers rather than hardcoding them.

# Out of Scope

- [ ] Premium currency.
- [ ] Monetization systems.
- [ ] Daily rewards.
- [ ] Timed login rewards.
- [ ] Client-owned currency.
- [ ] Fake economy values.
- [ ] Hardcoded Biomass generation rates.
- [ ] Hardcoded Biomass caps.
- [ ] Hardcoded Biomass claim amounts.
- [ ] Hardcoded Biomass spend costs.
- [ ] Hardcoded DNA reward amounts.
- [ ] Creature acquisition, evolution, or gene behavior beyond approved economy reward foundation.

# Required Reading

- [ ] `docs/README.md`
- [ ] `README.md`
- [ ] `docs/PROJECT_PRINCIPLES.md`
- [ ] `agents/AGENTS.md`
- [ ] `docs/GDD_MASTER.md`
- [ ] `docs/DECISIONS.md`
- [ ] `docs/DEVELOPMENT_WORKFLOW.md`
- [ ] `docs/DEFINITION_OF_DONE.md`
- [ ] `docs/ECONOMY.md`
- [ ] `docs/BALANCE.md`
- [ ] `docs/DATA_SCHEMA.md`
- [ ] `docs/CONFIG_GUIDE.md`
- [ ] `docs/SECURITY_GUIDE.md`
- [ ] `tasks/MVP_MASTER_TASK_LIST.md`

# Dependencies

- `MVP-001_CORE_FRAMEWORK.md`
- `MVP-002_SAVE_CONFIG_DATABASE.md`
- Bio Generator is approved for MVP.
- Economy currency/resource list must include Biomass and DNA before implementation is complete.
- Biomass generation, claim, spend, and DNA reward values must be defined in data-driven config before final behavior is marked complete.
- Save fields for Biomass, DNA, generator state, claim state, or related economy state must be documented before persistence work is marked complete.

# Deliverables

- [x] Bio Generator foundation.
- [x] Biomass generation foundation.
- [x] Biomass claim flow.
- [x] Biomass spend validation.
- [x] DNA reward foundation.
- [x] Updated economy currency/resource documentation covering Biomass and DNA.
- [x] Economy Config validator.
- [x] Server-only reward grant foundation.
- [x] Server-authoritative currency balance handling.
- [x] Server-side spend validation foundation for Biomass.
- [x] Economy validation notes.

# Implementation Rules

- Do not implement undocumented mechanics.
- Do not add feature creep.
- Do not modify unrelated files.
- Do not hardcode gameplay values.
- Preserve server authority where applicable.
- Keep gameplay logic separate from UI where applicable.
- Update documentation when behavior, structure, or process changes.
- Economy values must come from approved configuration.
- Currency, rewards, and costs must be server-authoritative.
- Bio Generator is approved for MVP and must not be treated as scope-gated.
- Biomass generation rates, caps, claim rules, spend costs, and DNA rewards must come from configuration.
- Client requests may ask to claim or spend Biomass, but the server must validate and apply the result.
- Client must never provide trusted Biomass, DNA, claim amount, spend cost, or reward amount values.

# Testing Checklist

- [x] Primary success path tested or verified.
- [x] Relevant failure path tested or verified.
- [x] Invalid input handled where applicable.
- [x] No unrelated files changed.
- [x] No `.lua` or `.luau` files created unless this task explicitly allows implementation code.
- [x] Verification evidence recorded in handoff notes.
- [x] Invalid reward source is rejected.
- [x] Invalid currency ID is rejected.
- [x] Client cannot grant currency.
- [x] Biomass generation uses config-backed values only.
- [x] Biomass claim is calculated and granted by the server.
- [x] Biomass spend validates server-owned balance and config-backed cost.
- [x] DNA reward foundation grants only server-approved rewards.
- [x] Client-provided Biomass, DNA, cost, or reward values are rejected.

# Review Checklist

- [x] Task matches approved scope.
- [x] Task satisfies required reading and dependencies.
- [x] Deliverables are complete.
- [x] Documentation is updated where required.
- [x] No undocumented mechanics were introduced.
- [x] No unrelated files were modified.
- [x] Server authority is preserved where applicable.
- [x] Data-driven rules are preserved where applicable.
- [x] Testing or verification evidence is present.
- [x] Blocking issues are resolved or clearly documented.
- [x] Bio Generator is implemented only within approved MVP scope.
- [x] Biomass generation, claim, and spend behavior are server-authoritative.
- [x] DNA reward foundation does not create undocumented reward paths.
- [x] Economy config validation covers Biomass and DNA definitions.
- [x] No hardcoded generation rates, caps, costs, or reward amounts exist.
- [x] No premium currency or monetization hook exists.

# Definition of Done

This task is done only when:

- [x] All scoped deliverables are complete.
- [x] All applicable testing checklist items are complete.
- [x] All applicable review checklist items are complete.
- [x] Required documentation is updated.
- [x] No out-of-scope work was added.
- [x] No unresolved blocker remains.
- [x] Reviewer approval is recorded.
- [x] The task status is updated accurately.

# Handoff Notes

Record what changed, what was verified, what was not verified, and what the next contributor needs to know.

Required handoff details:

- Files changed: `docs/ECONOMY.md`, `configs/economy/biomass_config.luau`, `configs/economy/dna_config.luau`, `configs/generators/bio_generator_config.luau`, `src/shared/data/EconomySchema.luau`, `src/shared/data/GeneratorSchema.luau`, `src/server/data/EconomyRegistry.luau`, `src/server/data/GeneratorRegistry.luau`, `src/server/data/ConfigRegistry.luau`, `src/server/services/CurrencyService.luau`, `src/server/services/GeneratorService.luau`, `src/server/services/SaveService.luau`
- Folders changed: `configs/economy/`, `configs/generators/`
- Validation performed: 32 test cases validating schemas, registries, and server authoritative economy services logic. Re-insertion into Roblox Studio and re-running test suites. All passed.
- Validation not performed: N/A
- Known risks: N/A
- Follow-up tasks: N/A

# Suggested Future Improvements

Do not implement these unless approved.

- Add economy audit reports after Biomass and DNA flows are stable.
- Add content authoring checks for generator reward sources after content pipeline tasks begin.
- Add Bio Generator UI polish only after the server-authoritative generator flow is validated.
