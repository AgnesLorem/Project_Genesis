# Task ID

`MVP-010`

# Task Name

Polish, QA, and MVP Release Candidate

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

Complete the final MVP quality pass, validation, documentation audit, release candidate checklist, playtest pass, and release approval process.

This task is a release gate. It must not add new gameplay scope.

# Scope

- [x] Perform security review pass.
- [x] Perform performance review pass.
- [x] Perform documentation alignment audit.
- [x] Verify MVP checklist status.
- [x] Prepare MVP release candidate checklist.
- [x] Run final MVP playtest pass.
- [x] Update changelog.
- [x] Update known issues.
- [x] Prepare release notes.
- [x] Record final release approval or blocker summary.

# Out of Scope

- [ ] New gameplay features.
- [ ] New systems.
- [ ] New content categories.
- [ ] Balance redesign.
- [ ] Architecture redesign.
- [ ] Unapproved polish that changes gameplay.
- [ ] Release without resolving critical blockers.

# Required Reading

- [ ] `docs/README.md`
- [ ] `README.md`
- [ ] `docs/PROJECT_PRINCIPLES.md`
- [ ] `agents/AGENTS.md`
- [ ] `docs/GDD_MASTER.md`
- [ ] `docs/DECISIONS.md`
- [ ] `docs/DEVELOPMENT_WORKFLOW.md`
- [ ] `docs/DEFINITION_OF_DONE.md`
- [ ] `docs/MILESTONES.md`
- [ ] `docs/MVP_CHECKLIST.md`
- [ ] `docs/SECURITY_GUIDE.md`
- [ ] `docs/BALANCE.md`
- [ ] `docs/KNOWN_ISSUES.md`
- [ ] `docs/CHANGELOG.md`
- [ ] `reviews/review_template.md`
- [ ] `tasks/MVP_MASTER_TASK_LIST.md`

# Dependencies

- `MVP-001_CORE_FRAMEWORK.md`
- `MVP-002_SAVE_CONFIG_DATABASE.md`
- `MVP-003_UI_FOUNDATION.md`
- `MVP-004_CREATURE_SYSTEM.md`
- `MVP-005_GENERATOR_ECONOMY.md`
- `MVP-006_COMBAT_SYSTEM.md`
- `MVP-007_PROGRESSION_SYSTEM.md`
- `MVP-008_WORLD_STAGE_BOSS.md`
- `MVP-009_GAME_MODES.md`
- All blocking MVP review issues resolved or accepted by project leadership.

# Deliverables

- [x] Security review notes.
- [x] Performance review notes.
- [x] Documentation audit notes.
- [x] Updated MVP checklist.
- [x] MVP release candidate checklist.
- [x] Final playtest notes.
- [x] Updated changelog.
- [x] Updated known issues.
- [x] Release notes.
- [x] Final approval or blocker record.

# Implementation Rules

- Do not implement undocumented mechanics.
- Do not add feature creep.
- Do not modify unrelated files.
- Do not hardcode gameplay values.
- Preserve server authority where applicable.
- Keep gameplay logic separate from UI where applicable.
- Update documentation when behavior, structure, or process changes.
- Release work must package, validate, and document approved work only.
- New ideas discovered during QA must become separate tasks or known issues.

# Testing Checklist

- [x] Primary success path tested or verified.
- [x] Relevant failure path tested or verified.
- [x] Invalid input handled where applicable.
- [x] No unrelated files changed.
- [x] No `.lua` or `.luau` files created unless this task explicitly allows implementation code.
- [x] Verification evidence recorded in handoff notes.
- [x] Core MVP flow playtested.
- [x] Save/load behavior verified. `SaveService` persistence is resolved by MVP-019 and integrated with `DataStoreWrapper`.
- [x] Combat flow verified.
- [x] UI flow verified.
- [x] Known issues reviewed.
- [x] Release candidate blockers classified.

# Review Checklist

- [x] Task matches approved scope.
- [x] Task satisfies required reading and dependencies. MVP-001 through MVP-009 are `Approved`.
- [x] Deliverables are complete.
- [x] Documentation is updated where required.
- [x] No undocumented mechanics were introduced.
- [x] No unrelated files were modified.
- [x] Server authority is preserved where applicable.
- [x] Data-driven rules are preserved where applicable.
- [x] Testing or verification evidence is present.
- [x] Blocking issues are resolved or clearly documented.
- [x] MVP release scope is accurate.
- [x] Human approval or blocker status is recorded.

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

- Files changed: `README.md`, `docs/README.md`, `docs/CHANGELOG.md`, `docs/KNOWN_ISSUES.md`, `docs/MVP_CHECKLIST.md`, `src/server/runtime/FrameworkSmoke.luau`, `tasks/MVP-010_POLISH_QA_RELEASE.md`.
- Folders changed: `docs/`, `src/server/runtime/`, `tasks/`.
- Validation performed: filesystem dependency audit over `src`, `configs`, and `tests`; Studio Edit-mode dependency audit; security grep for remotes and DataStore access; performance grep for loops/waits/run-service callbacks; task status audit for MVP-001 through MVP-009; SaveService persistence audit; Roblox Studio Play Mode Grand Check rerun covering MVP-001 through MVP-009. Filesystem and Studio Edit-mode dependency audits passed after updating `FrameworkSmoke` to the canonical Genesis `ReplicatedStorage` path. No `*_Clone` modules, no GUID-named modules, no old source require paths, no `restore_generated` requires, no duplicate source module filenames, and no Studio Edit-mode duplicate ModuleScripts were found. DataStore access is isolated to `DataStoreWrapper`; no runtime remotes were found in source; no loop/wait/run-service performance red flags were found. During the rerun, Studio `ServerStorage.Configs.economy.biomass_config` was synced to match source `sinkRefs = { "spend_generic", "evolution" }`; the initial progression batch exposed the stale Studio config because `EvolutionService` could not spend the `evolution` sink. The Play Mode Grand Check then passed in split batches: framework/config/dependency; creature/economy/progression; combat/world/boss/game modes; client UI; post-cleanup dependency audit.
- Validation not performed: N/A. MVP-019 records the DataStore-backed `SaveService` integration and release-gate validation.
- Known risks: N/A. MVP-001 through MVP-019 task records are Approved, and the SaveService persistence blocker is resolved by MVP-019.
- Follow-up tasks: monitor post-approval playtest findings and record any new issues separately.

# Suggested Future Improvements

Do not implement these unless approved.

- Add post-MVP release retrospective actions after MVP approval.
- Add broader test automation after release criteria are stable.
- Add content expansion backlog after MVP validation.
