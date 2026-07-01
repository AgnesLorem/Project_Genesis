# Task ID

`MVP-009`

# Task Name

Approved Game Modes Foundation

# Owner

Unassigned

# Status

Allowed values:

- Not Started
- In Progress
- Review
- Approved
- Blocked

Current Status: Review

# Priority

Allowed values:

- P0
- P1
- P2

Current Priority: P1

# Goal

Create the approved game mode routing foundation for MVP play without adding unapproved modes.

This task must support only documented Story Mode 1v1 and Boss/Challenge 3v3 behavior, plus approved Auto Retry support.

# Scope

- [x] Define mode identifiers only for approved MVP modes.
- [x] Route Story Mode requests to approved 1v1 setup.
- [x] Route Boss/Challenge requests to approved 3v3 setup.
- [x] Apply Recommended Power as display guidance only.
- [x] Support approved Auto Retry request state if documented.
- [x] Resolve Quest and Tower scope gates without implementing them.
- [x] Document any missing mode terminology blockers.

# Out of Scope

- [ ] PvP.
- [ ] Ranked modes.
- [ ] Live event modes.
- [ ] Seasonal modes.
- [ ] Tower mode unless explicitly approved.
- [ ] Quest systems unless explicitly approved.
- [ ] Challenge variants beyond documented Boss/Challenge rules.
- [ ] Client-authoritative mode completion.

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
- [x] `docs/DATA_SCHEMA.md`
- [x] `docs/CONFIG_STRUCTURE.md`
- [x] `docs/SECURITY_GUIDE.md`
- [x] `docs/MVP_CHECKLIST.md`
- [x] `tasks/MVP_MASTER_TASK_LIST.md`

# Dependencies

- `MVP-001_CORE_FRAMEWORK.md`
- `MVP-006_COMBAT_SYSTEM.md`
- `MVP-008_WORLD_STAGE_BOSS.md`
- Quest and Tower scope decisions remain blocked unless approved.

# Deliverables

- [x] Approved mode identifier list.
- [x] Story Mode routing foundation.
- [x] Boss/Challenge routing foundation.
- [x] Recommended Power display-only confirmation.
- [x] Auto Retry support path if documented.
- [x] Quest scope gate decision record or known issue.
- [x] Tower scope gate decision record or known issue.
- [x] Mode validation notes.

# Implementation Rules

- Do not implement undocumented mechanics.
- Do not add feature creep.
- Do not modify unrelated files.
- Do not hardcode gameplay values.
- Preserve server authority where applicable.
- Keep gameplay logic separate from UI where applicable.
- Update documentation when behavior, structure, or process changes.
- Modes must route to existing approved systems.
- Modes must not create new gameplay rules.
- Client requests must be validated by the server.

# Testing Checklist

- [x] Primary success path tested or verified.
- [x] Relevant failure path tested or verified.
- [x] Invalid input handled where applicable.
- [x] No unrelated files changed.
- [x] No `.lua` or `.luau` files created unless this task explicitly allows implementation code.
- [x] Verification evidence recorded in handoff notes.
- [x] Story Mode routes to 1v1 only.
- [x] Boss/Challenge routes to 3v3 only.
- [x] Unknown mode is rejected.
- [x] Recommended Power does not block access.
- [x] Auto Retry does not bypass server validation.

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
- [x] No unapproved mode was added.
- [x] Quest and Tower remain gated unless approved.

# Definition of Done

This task is done only when:

- [x] All scoped deliverables are complete.
- [x] All applicable testing checklist items are complete.
- [x] All applicable review checklist items are complete.
- [x] Required documentation is updated.
- [x] No out-of-scope work was added.
- [x] No unresolved blocker remains for approved MVP modes; Quest/Tower remain gated by known issues and are not implemented.
- [ ] Reviewer approval is recorded.
- [x] The task status is updated accurately.

# Handoff Notes

Record what changed, what was verified, what was not verified, and what the next contributor needs to know.

Required handoff details:

- Files changed: `src/shared/network/GameModeContract.luau`, `src/server/services/GameModeService.luau`, `src/shared/data/BossSchema.luau`, `src/server/services/CombatService.luau`, `docs/COMBAT.md`, `docs/KNOWN_ISSUES.md`, `tasks/MVP-009_GAME_MODES.md`.
- Folders changed: `src/shared/network`, `src/shared/data`, `src/server/services`, `docs`, `tasks`.
- Validation performed: synced MVP-009 modules into Roblox Studio canonical Genesis folders and ran Studio Edit-mode verification. Passed approved mode IDs exactly `story`, `boss`, `challenge`; Quest/Tower mode rejection; Story Mode route to existing 1v1 API; Boss/Challenge route to existing 3v3 validation; unknown mode rejection; Auto Retry calling the same `resolveModeBattle` path and failing invalid requests; recommendedPower display snapshot with extreme value not gating battle; no reward grant; no Quest/Tower runtime; no duplicate MVP-009 modules. Post-cleanup check reported `leftovers=0` and exactly one `GameModeContract`, `GameModeService`, `BossSchema`, and `CombatService` in canonical folders.
- Validation not performed: full play-mode Grand Check/release audit was not run; no Luau CLI, `luau-lsp`, `stylua`, or `rojo` was available in the shell.
- Known risks: no RemoteFunction/RemoteEvent wiring is added yet; `GameModeService` is service-level routing only. Registry initialization still follows existing manual registry pattern. Auto Retry has no UI/client persistence path yet; it intentionally reuses the same server request path.
- Follow-up tasks: wire approved remotes through `GameModeService` when network contracts are implemented; add UI Auto Retry controls later using the same server API; continue to keep Quest/Tower out of mode IDs until their scope gates are accepted.

# Suggested Future Improvements

Do not implement these unless approved.

- Add additional modes only after design decisions and GDD updates.
- Add mode-specific UI polish after MVP mode routing is validated.
- Add Tower or Quest mode tasks only if their scope gates are accepted.
