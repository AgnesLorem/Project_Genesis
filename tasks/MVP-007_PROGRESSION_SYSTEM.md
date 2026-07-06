# Task ID

`MVP-007`

# Task Name

Progression, Collection, Evolution, Gene, and Prestige Foundation

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

Implement approved MVP progression-facing foundations that connect player goals, collection, evolution, genes, and prestige only as documented.

This task must avoid inventing requirements, rewards, gene effects, prestige effects, or progression shortcuts.

# Scope

- [x] Finalize hybrid collection rules before implementation.
- [x] Implement server-owned collection state tracker.
- [x] Implement collection UI snapshot.
- [x] Finalize evolution requirements before implementation.
- [x] Implement Evolution Config schema validation.
- [x] Implement server-side evolution transaction flow only after requirements are documented.
- [x] Implement approved evolution level reset behavior.
- [x] Finalize gene meaning before implementation.
- [x] Implement Gene Config schema validation if gene behavior is approved.
- [x] Implement gene save state integration if gene behavior is approved.
- [x] Resolve prestige MVP scope before implementation.

# Out of Scope

- [ ] Branching evolution.
- [ ] Gene inheritance.
- [ ] Gene mutation.
- [ ] Prestige reward multipliers.
- [ ] Undocumented collection rewards.
- [ ] Daily quests.
- [ ] Timed login rewards.
- [ ] Any progression requirement not documented.

# Required Reading

- [x] `docs/README.md`
- [x] `README.md`
- [x] `docs/PROJECT_PRINCIPLES.md`
- [x] `agents/AGENTS.md`
- [x] `docs/GDD_MASTER.md`
- [x] `docs/DECISIONS.md`
- [x] `docs/DEVELOPMENT_WORKFLOW.md`
- [x] `docs/DEFINITION_OF_DONE.md`
- [x] `docs/PROGRESSION.md`
- [x] `docs/DATA_SCHEMA.md`
- [x] `docs/SAVE_SYSTEM.md`
- [x] `docs/BALANCE.md`
- [x] `docs/SECURITY_GUIDE.md`
- [x] `tasks/MVP_MASTER_TASK_LIST.md`

# Dependencies

- `MVP-001_CORE_FRAMEWORK.md`
- `MVP-002_SAVE_CONFIG_DATABASE.md`
- `MVP-004_CREATURE_SYSTEM.md`
- `MVP-005_GENERATOR_ECONOMY.md` if evolution or progression uses costs/rewards.
- Collection, evolution, gene, and prestige rules must be documented before implementation.

# Deliverables

- [x] Updated collection rule documentation.
- [x] Collection state tracker.
- [x] Collection UI snapshot.
- [x] Updated evolution requirement documentation.
- [x] Evolution Config validator.
- [x] Evolution transaction flow if approved.
- [x] Evolution level reset behavior.
- [x] Gene scope decision and documentation.
- [x] Gene Config validator if approved.
- [x] Gene save integration if approved.
- [x] Prestige scope decision.
- [x] Progression validation notes.

# Implementation Rules

- Do not implement undocumented mechanics.
- Do not add feature creep.
- Do not modify unrelated files.
- Do not hardcode gameplay values.
- Preserve server authority where applicable.
- Keep gameplay logic separate from UI where applicable.
- Update documentation when behavior, structure, or process changes.
- Progression state must be server-owned.
- Evolution must follow documented reset behavior.
- Gene and prestige work must remain blocked until meaning and scope are approved.

# Testing Checklist

- [x] Primary success path tested or verified.
- [x] Relevant failure path tested or verified.
- [x] Invalid input handled where applicable.
- [x] No unrelated files changed.
- [x] No `.lua` or `.luau` files created unless this task explicitly allows implementation code.
- [x] Verification evidence recorded in handoff notes.
- [x] Collection state rejects invalid IDs.
- [x] Evolution rejects ineligible requests.
- [x] Evolution reset behavior matches decision log.
- [x] Gene and prestige behavior is absent unless approved.

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
- [x] No branching evolution, gene mutation, or prestige multipliers were added.
- [x] No undocumented rewards were added.

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

- Files changed: `docs/PROGRESSION.md`, `configs/economy/biomass_config.luau`, `src/shared/data/EvolutionSchema.luau`, `src/shared/data/GeneSchema.luau`, `src/shared/data/PrestigeSchema.luau`, `src/server/data/EvolutionRegistry.luau`, `src/server/data/ConfigRegistry.luau`, `src/server/services/SaveService.luau`, `src/server/services/CollectionService.luau`, `src/server/services/CreatureService.luau`, `src/server/services/EvolutionService.luau`
- Folders changed: `configs/evolutions`
- Validation performed: 23 test assertions covering EvolutionSchema, GeneSchema, PrestigeSchema, CollectionService snapshots, discoverCreature validations, Creature Leveling & XP overflow calculation, EvolutionService transaction validations (from/to creature checks, ownership, level checks, biomass deduction), rollback behavior validation, and validation of Gene/Prestige inactive save state. All 23 tests successfully passed in Play Mode.
- Validation not performed: N/A
- Known risks: N/A
- Follow-up tasks: N/A

# Suggested Future Improvements

Do not implement these unless approved.

- Add deeper progression presentation after MVP loop is validated.
- Add additional collection categories after content scope is approved.
- Add prestige implementation details only after prestige scope is accepted.
