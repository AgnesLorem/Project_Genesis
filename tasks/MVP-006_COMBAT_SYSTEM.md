# Task ID

`MVP-006`

# Task Name

Combat System Foundation

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

Implement the approved MVP combat foundation using server-authoritative, data-driven rules.

This task covers only documented combat behavior: Auto Battle, Action Time Bar, SPD gauge fill, cooldown skills, no mana, Story 1v1, Boss/Challenge 3v3 support, recommended power as guidance only, simplified damage, DEF percentage reduction, full heal after battle, simple enemy AI, boss phase support, and Auto Retry support.

# Scope

- [x] Finalize documented combat formula and Action Gauge parameters before implementation.
- [x] Implement Skill Config schema validation.
- [x] Implement server-owned battle session model.
- [x] Implement Story 1v1 battle setup.
- [x] Implement simplified server-side damage resolver.
- [x] Implement SPD Action Gauge resolver.
- [x] Implement server-owned cooldown state.
- [x] Implement skill execution resolver for approved effects only.
- [x] Implement battle completion flow and full post-battle heal.
- [x] Prepare extension points for boss/challenge 3v3 without implementing unapproved modes.

# Out of Scope

- [ ] Manual combat controls.
- [ ] Mana.
- [ ] PvP.
- [ ] Advanced enemy AI.
- [ ] Undocumented status effects.
- [ ] Power gates.
- [ ] Client-calculated damage.
- [ ] Client-calculated victory or rewards.
- [ ] New combat mechanics not documented in `docs/COMBAT.md`.

# Required Reading

- [x] `docs/README.md`
- [x] `README.md`
- [x] `docs/PROJECT_PRINCIPLES.md`
- [x] `agents/AGENTS.md`
- [x] `docs/GDD_MASTER.md`
- [x] `docs/DECISIONS.md`
- [x] `docs/DEVELOPMENT_WORKFLOW.md`
- [x] `docs/DEFINITION_OF_DONE.md`
- [x] `docs/COMBAT.md`
- [x] `docs/BALANCE.md`
- [x] `docs/DATA_SCHEMA.md`
- [x] `docs/SECURITY_GUIDE.md`
- [x] `tasks/MVP_MASTER_TASK_LIST.md`

# Dependencies

- `MVP-001_CORE_FRAMEWORK.md`
- `MVP-002_SAVE_CONFIG_DATABASE.md`
- `MVP-004_CREATURE_SYSTEM.md`
- `MVP-005_GENERATOR_ECONOMY.md` for reward handoff foundation.
- Combat formula and Action Gauge parameters must be documented before implementation.

# Deliverables

- [x] Updated combat formula and Action Gauge documentation if required.
- [x] Skill Config validator.
- [x] Battle session model.
- [x] Story 1v1 battle setup.
- [x] Simplified damage resolver.
- [x] SPD Action Gauge resolver.
- [x] Cooldown state model.
- [x] Skill execution resolver.
- [x] Battle completion flow.
- [x] Combat validation notes.

# Implementation Rules

- Do not implement undocumented mechanics.
- Do not add feature creep.
- Do not modify unrelated files.
- Do not hardcode gameplay values.
- Preserve server authority where applicable.
- Keep gameplay logic separate from UI where applicable.
- Update documentation when behavior, structure, or process changes.
- Server must calculate damage and battle results.
- Client must never be trusted for combat outcomes.
- Recommended Power must remain guidance only.

# Testing Checklist

- [x] Primary success path tested or verified.
- [x] Relevant failure path tested or verified.
- [x] Invalid input handled where applicable.
- [x] No unrelated files changed.
- [x] No `.lua` or `.luau` files created unless this task explicitly allows implementation code.
- [x] Verification evidence recorded in handoff notes.
- [x] Story 1v1 setup validates player creature ownership.
- [x] Damage resolver rejects client damage.
- [x] Cooldown state remains server-owned.
- [x] Action Gauge behavior follows documented SPD rules.
- [x] Full heal after battle occurs through server-owned state.

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
- [x] No mana, PvP, manual combat, or status effect system was added.
- [x] No power gate was introduced.

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

- Files changed: `docs/COMBAT.md`, `configs/balance/combat_config.luau`, `configs/skills/basic_attack_config.luau`, `src/shared/data/SkillSchema.luau`, `src/shared/data/CombatBalanceSchema.luau`, `src/shared/combat/CombatFormulas.luau`, `src/server/data/SkillRegistry.luau`, `src/server/data/BalanceRegistry.luau`, `src/server/combat/BattleSession.luau`, `src/server/services/CombatService.luau`
- Folders changed: `configs/skills`, `configs/balance`, `src/shared/combat`, `src/server/combat`
- Validation performed: 15 verification test cases in Roblox Studio (7 for schemas/formulas, 4 for BattleSession simulation, 4 for CombatService integration) verifying Skill schemas, Balance schemas, Damage logic (DEF reduction & Minimum damage clamp of 1), BattleSession infinite loop safeguard (1000 turns limit), deterministic tie-breaking (Gauge -> SPD -> Team -> ID), and strict isolation of persistent data.
- Validation not performed: Reward distribution mapping and persistent UI (out of scope, handled in MVP-007).
- Known risks: If any skills are added in the future, ensure they conform to the existing schema or update `SkillSchema.luau`.
- Follow-up tasks: Wire up combat flow to client UI in future MVP stages.

# Suggested Future Improvements

Do not implement these unless approved.

- Add deeper combat AI only after MVP validation.
- Add status effects only after combat documentation and decision approval.
- Add richer combat presentation after UI and VFX tasks are approved.
