# Task ID

`MVP-008`

# Task Name

World, Stage, and Boss Foundation

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

Current Priority: P1

# Goal

Implement the approved MVP world progression and boss/challenge foundation using data-driven configuration and server authority.

This task supports MVP content structure without creating unapproved quest, tower, or open-world systems.

# Scope

- [x] Implement World Config schema validation.
- [x] Implement World Registry.
- [ ] Implement server-owned world progression state after save fields are ready. Deferred: save fields are not ready.
- [x] Implement recommended power display data as guidance only.
- [x] Implement Boss Config schema validation.
- [x] Implement Boss Registry.
- [x] Implement Boss/Challenge 3v3 battle setup after combat foundation is ready.
- [ ] Implement documented boss phase resolver. Deferred: `KI-COMBAT-004` is still open; MVP-008 validates phase IDs only.
- [x] Document unresolved stage terminology or content blockers.

# Out of Scope

- [ ] Power gates.
- [ ] Large-scale open world content.
- [ ] Procedural world generation.
- [ ] Quest systems.
- [ ] Tower systems.
- [ ] Advanced boss AI.
- [ ] Undocumented boss mechanics.
- [ ] Final content quantity decisions.

# Required Reading

- [x] `docs/README.md`
- [x] `README.md`
- [x] `docs/PROJECT_PRINCIPLES.md`
- [x] `agents/AGENTS.md`
- [x] `docs/GDD_MASTER.md`
- [x] `docs/DECISIONS.md`
- [x] `docs/DEVELOPMENT_WORKFLOW.md`
- [x] `docs/DEFINITION_OF_DONE.md`
- [x] `docs/DATA_SCHEMA.md`
- [x] `docs/CONFIG_GUIDE.md`
- [x] `docs/CONFIG_STRUCTURE.md`
- [x] `docs/COMBAT.md`
- [x] `docs/BALANCE.md`
- [x] `docs/PROGRESSION.md`
- [x] `docs/SECURITY_GUIDE.md`
- [x] `tasks/MVP_MASTER_TASK_LIST.md`

# Dependencies

- `MVP-001_CORE_FRAMEWORK.md`
- `MVP-002_SAVE_CONFIG_DATABASE.md`
- `MVP-004_CREATURE_SYSTEM.md`
- `MVP-006_COMBAT_SYSTEM.md`
- `MVP-007_PROGRESSION_SYSTEM.md` for progression state alignment.

# Deliverables

- [x] World Config validator.
- [x] World Registry.
- [ ] World progression state integration. Deferred: save fields are not ready.
- [x] Recommended power display snapshot.
- [x] Boss Config validator.
- [x] Boss Registry.
- [x] Boss/Challenge 3v3 setup.
- [ ] Boss phase resolver. Deferred: no phase switching until `KI-COMBAT-004` is resolved.
- [x] World and boss validation notes.

# Implementation Rules

- Do not implement undocumented mechanics.
- Do not add feature creep.
- Do not modify unrelated files.
- Do not hardcode gameplay values.
- Preserve server authority where applicable.
- Keep gameplay logic separate from UI where applicable.
- Update documentation when behavior, structure, or process changes.
- Recommended Power must remain guidance only.
- Boss and world data must come from configuration.
- Boss results must be server-authoritative.

# Testing Checklist

- [x] Primary success path tested or verified.
- [x] Relevant failure path tested or verified.
- [x] Invalid input handled where applicable.
- [x] No unrelated files changed.
- [x] No `.lua` or `.luau` files created unless this task explicitly allows implementation code.
- [x] Verification evidence recorded in handoff notes.
- [x] Invalid world ID is rejected.
- [x] Recommended power does not block access.
- [x] Invalid boss ID is rejected.
- [x] Boss 3v3 setup validates team size.
- [ ] Boss phase resolver uses documented phase data only. Deferred: no phase resolver or switching until `KI-COMBAT-004` is resolved.

# Review Checklist

- [x] Task matches approved scope.
- [x] Task satisfies required reading and dependencies.
- [ ] Deliverables are complete. Deferred items remain blocked by save-field and boss-phase decisions.
- [x] Documentation is updated where required.
- [x] No undocumented mechanics were introduced.
- [x] No unrelated files were modified.
- [x] Server authority is preserved where applicable.
- [x] Data-driven rules are preserved where applicable.
- [x] Testing or verification evidence is present.
- [x] Blocking issues are resolved or clearly documented.
- [x] No power gate was added.
- [x] No quest, tower, or procedural world system was added.

# Definition of Done

This task is done only when:

- [ ] All scoped deliverables are complete. Deferred items remain blocked by save-field and boss-phase decisions.
- [ ] All applicable testing checklist items are complete. Runtime Studio verification passed for implemented scope; deferred boss phase resolver remains intentionally incomplete.
- [ ] All applicable review checklist items are complete. Reviewer approval is still pending.
- [x] Required documentation is updated.
- [x] No out-of-scope work was added.
- [ ] No unresolved blocker remains. `KI-COMBAT-004` and world save-field readiness remain blockers for deferred scope.
- [ ] Reviewer approval is recorded.
- [x] The task status is updated accurately.

# Handoff Notes

Record what changed, what was verified, what was not verified, and what the next contributor needs to know.

Required handoff details:

- Files changed: `src/shared/data/WorldSchema.luau`, `src/shared/data/BossSchema.luau`, `src/server/data/WorldRegistry.luau`, `src/server/data/BossRegistry.luau`, `src/server/services/CombatService.luau`, `docs/DATA_SCHEMA.md`, `docs/COMBAT.md`, `docs/KNOWN_ISSUES.md`, `tasks/MVP-008_WORLD_STAGE_BOSS.md`.
- Folders changed: `src/shared/data`, `src/server/data`, `src/server/services`, `docs`, `tasks`.
- Validation performed: synced MVP-008 modules into Roblox Studio canonical Genesis folders and ran Studio Edit-mode verification. Passed WorldSchema valid/invalid, BossSchema valid/invalid, WorldRegistry load/reject, BossRegistry load/reject, boss/challenge 3v3 validation, recommendedPower non-gating with extreme recommended power, no reward grant, no phase switching, no Quest/Tower runtime, and no duplicate ModuleScripts.
- Validation not performed: full play-mode Grand Check/release audit was not run; no Luau CLI, `luau-lsp`, `stylua`, or `rojo` was available in the shell.
- Known risks: `WorldRegistry` and `BossRegistry` follow the existing manual `init()` registry pattern; no sample world/boss config was added because content IDs are not approved; world progression save state remains deferred until save fields are ready; boss phase switching remains deferred until `KI-COMBAT-004` is resolved.
- Follow-up tasks: add approved world/boss content configs and runtime tests when content is approved; wire registry initialization into the accepted bootstrap/test harness; resolve `KI-COMBAT-004` before implementing phase triggers/effects; add world progression save fields before implementing player world runtime state.

# Suggested Future Improvements

Do not implement these unless approved.

- Add more world content after MVP content quantities are approved.
- Add richer boss presentation after combat and UI flows are stable.
- Add tower task breakdown only if tower scope is accepted.
