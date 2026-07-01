# Task ID

`MVP-003`

# Task Name

UI Foundation

# Owner

Antigravity (Gemini 3.1 Pro) — 2026-06-28

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

Current Priority: P0

# Goal

Create the client-side UI foundation needed for future MVP screens while keeping all gameplay authority on the server.

This task prepares routing, presentation state, common components, and non-success states without implementing actual gameplay screens.

# Scope

- [x] Finalize MVP screen inventory in documentation before implementation.
- [x] Create client screen router foundation.
- [x] Create shared presentation state store foundation for server-approved snapshots.
- [x] Create common UI component foundation.
- [x] Create loading, empty, and error state patterns.
- [x] Document UI authority boundaries.

# Out of Scope

- [ ] Creature screen implementation.
- [ ] Combat screen implementation.
- [ ] Economy screen implementation.
- [ ] Collection screen implementation.
- [ ] Evolution screen implementation.
- [ ] UI-driven gameplay decisions.
- [ ] Server state mutation from UI.

# Required Reading

- [ ] `docs/README.md`
- [ ] `README.md`
- [ ] `docs/PROJECT_PRINCIPLES.md`
- [ ] `agents/AGENTS.md`
- [ ] `docs/GDD_MASTER.md`
- [ ] `docs/DECISIONS.md`
- [ ] `docs/DEVELOPMENT_WORKFLOW.md`
- [ ] `docs/DEFINITION_OF_DONE.md`
- [ ] `docs/TECH_ARCHITECTURE.md`
- [ ] `docs/UI_GUIDELINES.md`
- [ ] `docs/SECURITY_GUIDE.md`
- [ ] `docs/STYLE_GUIDE.md`
- [ ] `tasks/MVP_MASTER_TASK_LIST.md`

# Dependencies

- `MVP-001_CORE_FRAMEWORK.md`
- UI screen inventory must be documented before specific screens are implemented.
- Future gameplay screens depend on this foundation.

# Deliverables

- [x] Updated MVP screen inventory documentation.
- [x] Client screen router foundation.
- [x] Presentation state store foundation.
- [x] Common UI component foundation.
- [x] Loading, empty, and error state foundation.
- [x] UI handoff notes for future feature screens.

# Implementation Rules

- Do not implement undocumented mechanics.
- Do not add feature creep.
- Do not modify unrelated files.
- Do not hardcode gameplay values.
- Preserve server authority where applicable.
- Keep gameplay logic separate from UI where applicable.
- Update documentation when behavior, structure, or process changes.
- UI may display server-approved state only.
- UI must not grant rewards, progression, save state, creatures, or currency.

# Testing Checklist

- [x] Primary success path tested or verified. (ScreenRouter switching, ClientState caching)
- [x] Relevant failure path tested or verified. (Unknown screen IDs rejected gracefully)
- [x] Invalid input handled where applicable.
- [x] No unrelated files changed.
- [x] No `.lua` or `.luau` files created unless this task explicitly allows implementation code.
- [x] Verification evidence recorded in handoff notes.
- [x] Router handles unknown route safely.
- [x] Presentation state does not mutate authoritative gameplay state.
- [x] Loading, empty, and error states are reachable or documented.

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
- [x] No full gameplay screens were implemented.
- [x] UI terminology matches documentation.

# Definition of Done

This task is done only when:

- [x] All scoped deliverables are complete.
- [x] All applicable testing checklist items are complete.
- [x] All applicable review checklist items are complete.
- [x] Required documentation is updated.
- [x] No out-of-scope work was added.
- [x] No unresolved blocker remains.
- [ ] Reviewer approval is recorded. (PENDING)
- [x] The task status is updated accurately.

# Handoff Notes

Record what changed, what was verified, what was not verified, and what the next contributor needs to know.

---

**Completed: 2026-06-28 by Antigravity (Gemini 3.1 Pro)**

### Files Changed

| File | Change |
|---|---|
| `docs/UI_GUIDELINES.md` | MODIFIED - Defined MVC boundaries, pure Luau usage, and server-authority rules. |
| `docs/UI_SCREEN_GUIDE.md` | NEW - Handoff notes and integration guide for future MVP UI tasks. |
| `src/client/models/ClientState.luau` | NEW - Presentation cache for mirroring server snapshots. |
| `src/client/controllers/ScreenRouter.luau` | NEW - Basic router to manage registered UI screens. |
| `src/client/views/UIComponents.luau` | NEW - Factory for pure Luau base UI elements. |
| `src/client/views/StatePatterns.luau` | NEW - Loading, Empty, Error, Disconnected, Retry state views. |

### Studio Locations
| Module | Studio Path | Class |
|---|---|---|
| ClientState | `StarterPlayer.StarterPlayerScripts.Client.models.ClientState` | ModuleScript |
| ScreenRouter | `StarterPlayer.StarterPlayerScripts.Client.controllers.ScreenRouter` | ModuleScript |
| UIComponents | `StarterPlayer.StarterPlayerScripts.Client.views.UIComponents` | ModuleScript |
| StatePatterns | `StarterPlayer.StarterPlayerScripts.Client.views.StatePatterns` | ModuleScript |

### Validation Performed (Studio Smoke Tests)
- ✅ Verify ScreenRouter switches registered screens.
- ✅ Verify unknown screen IDs are rejected safely.
- ✅ Verify ClientState mirrors snapshots correctly.
- ✅ Verify Loading/Empty/Error/Disconnected/Retry components instantiate successfully.

### Validation Not Performed
- Visual/layout validation in play mode (no feature screens exist yet to route to).

### Known Risks
- Current components are entirely unstyled and functionally skeletal (as requested for MVP core).

### Follow-Up Tasks
- Tasks MVP-004 through MVP-009 should utilize these modules (`ScreenRouter.registerScreen()`) when building UI screens.

# Suggested Future Improvements

Do not implement these unless approved.

- Add UI screen-specific components after each screen task is approved.
- Add accessibility and device-specific refinements after MVP flows exist.
- Add animation polish after gameplay flows are validated.
