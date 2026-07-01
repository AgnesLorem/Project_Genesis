# Project Genesis MVP Master Task List

## Purpose

This document is the complete MVP production backlog for Project Genesis.

It breaks the MVP into small, reviewable implementation tasks intended to be completable in approximately 2-6 hours each.

This backlog is written for production planning. It does not implement gameplay, does not define new mechanics, and does not override the source-of-truth documentation.

All work must remain consistent with:

- `docs/README.md`
- `docs/PROJECT_PRINCIPLES.md`
- `docs/GDD_MASTER.md`
- `docs/DECISIONS.md`
- `docs/DEVELOPMENT_WORKFLOW.md`
- `docs/DEFINITION_OF_DONE.md`
- `docs/MVP_CHECKLIST.md`
- `docs/MILESTONES.md`
- `docs/TECH_ARCHITECTURE.md`
- `docs/DATA_SCHEMA.md`
- `docs/CONFIG_GUIDE.md`
- `docs/CONFIG_STRUCTURE.md`
- `docs/SECURITY_GUIDE.md`

## Status

- Document Status: Draft
- Project Phase: MVP Production
- Current Milestone: Milestone 0 - Project Foundation
- Owner: Technical Producer
- Last Updated: 2026-06-28

## Priority Legend

| Priority | Meaning |
|---|---|
| P0 | Required for MVP foundation, implementation safety, or release viability |
| P1 | Required for MVP usability, completeness, or validation |
| P2 | Polish, support work, or quality improvement after critical MVP needs |

## Status Legend

| Status | Meaning |
|---|---|
| Not Started | Task has not begun |
| Blocked | Task cannot begin until dependency, decision, or approval is resolved |
| In Progress | Task has started and is not complete |
| Review | Task is ready for review |
| Done | Task is complete, reviewed, and verified |

## Backlog Rules

- Tasks must not introduce undocumented mechanics.
- Tasks must not hardcode gameplay values.
- Tasks must not combine unrelated systems.
- Tasks must not modify unrelated files.
- Tasks must follow the recommended implementation order unless production leadership changes priority.
- Tasks that depend on unresolved design must remain blocked.
- Reserved systems such as Quest, Tower, Status Effect, and Bio Generator must not be implemented unless explicitly approved in source-of-truth documentation.
- Every completed task must satisfy `docs/DEFINITION_OF_DONE.md`.

## Suggested Implementation Order

| Order | Category | Task IDs |
|---|---|---|
| 1 | Project Setup | MVP-SETUP-001 to MVP-SETUP-004 |
| 2 | Core Framework | MVP-FRAME-001 to MVP-FRAME-005 |
| 3 | Shared Types | MVP-TYPE-001 to MVP-TYPE-003 |
| 4 | Config System | MVP-CONFIG-001 to MVP-CONFIG-005 |
| 5 | Database Layer | MVP-DB-001 to MVP-DB-003 |
| 6 | Networking | MVP-NET-001 to MVP-NET-004 |
| 7 | Save System | MVP-SAVE-001 to MVP-SAVE-005 |
| 8 | UI Framework | MVP-UI-001 to MVP-UI-005 |
| 9 | Creature Database | MVP-CREATURE-001 to MVP-CREATURE-004 |
| 10 | Economy | MVP-ECO-001 to MVP-ECO-005 |
| 11 | World | MVP-WORLD-001 to MVP-WORLD-004 |
| 12 | Skills | MVP-SKILL-001 to MVP-SKILL-003 |
| 13 | Combat | MVP-COMBAT-001 to MVP-COMBAT-005 |
| 14 | Action Gauge | MVP-GAUGE-001 to MVP-GAUGE-003 |
| 15 | Boss | MVP-BOSS-001 to MVP-BOSS-004 |
| 16 | Collection | MVP-COLLECTION-001 to MVP-COLLECTION-003 |
| 17 | Evolution | MVP-EVOLUTION-001 to MVP-EVOLUTION-004 |
| 18 | Gene | MVP-GENE-001 to MVP-GENE-003 |
| 19 | Prestige | MVP-PRESTIGE-001 to MVP-PRESTIGE-002 |
| 20 | Quest Scope Gate | MVP-QUEST-001 to MVP-QUEST-002 |
| 21 | Tower Scope Gate | MVP-TOWER-001 to MVP-TOWER-002 |
| 22 | Bio Generator Scope Gate | MVP-BIO-001 |
| 23 | Settings Scope Gate | MVP-SETTINGS-001 |
| 24 | Audio | MVP-AUDIO-001 to MVP-AUDIO-002 |
| 25 | Visual Effects | MVP-VFX-001 to MVP-VFX-002 |
| 26 | Testing | MVP-TEST-001 to MVP-TEST-004 |
| 27 | Polish | MVP-POLISH-001 to MVP-POLISH-003 |
| 28 | Release Candidate | MVP-RC-001 to MVP-RC-003 |

## Project Setup

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-SETUP-001 | Establish Source Folder Structure | P0 | `docs/TECH_ARCHITECTURE.md`, `docs/STYLE_GUIDE.md` | Create the approved Roblox source, shared, client, server, config, and test folder layout after architecture review. | Folder structure; folder ownership notes. | `docs/TECH_ARCHITECTURE.md`, `docs/CONFIG_STRUCTURE.md`, `docs/STYLE_GUIDE.md` | Folders exist, names follow style guide, no gameplay code added. | Low | 2h | [ ] Inspect folder tree; [ ] confirm no Lua gameplay added. | [ ] Architecture alignment; [ ] no unrelated files. | Review |
| MVP-SETUP-002 | Create Project Tooling Inventory | P0 | MVP-SETUP-001 | Document required local tools, Roblox Studio expectations, and repository commands without installing gameplay systems. | Tooling notes; setup checklist. | `README.md`, `docs/DEVELOPMENT_WORKFLOW.md` | Contributors can identify required tools and setup steps. | Low | 2h | [ ] Verify instructions are accurate; [ ] check links/paths. | [ ] Clear onboarding; [ ] no unapproved tools required. | Not Started |
| MVP-SETUP-003 | Add Repository Ignore Rules | P0 | MVP-SETUP-001 | Add ignore rules for generated files, local caches, temporary exports, and platform noise. | Ignore file updates. | `docs/STYLE_GUIDE.md` | Generated and local-only files are excluded without hiding source assets or docs. | Low | 2h | [ ] Confirm ignored files are appropriate; [ ] verify docs remain tracked. | [ ] No source files ignored; [ ] no destructive cleanup. | Not Started |
| MVP-SETUP-004 | Create Task Status Board Structure | P1 | `docs/SPRINT_GUIDE.md` | Create task folders or status conventions for active, blocked, review, done, and archived task records. | Task status structure; status usage notes. | `docs/SPRINT_GUIDE.md`, `docs/DEVELOPMENT_WORKFLOW.md` | Task tracking structure exists and matches status legend. | Low | 2h | [ ] Inspect task folders; [ ] validate status labels. | [ ] Workflow alignment; [ ] no task content lost. | Not Started |

## Core Framework

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-FRAME-001 | Define Service Lifecycle Contract | P0 | MVP-SETUP-001 | Implement the minimal service lifecycle pattern for server systems without gameplay behavior. | Service contract module or equivalent; lifecycle docs. | `docs/TECH_ARCHITECTURE.md` | Services can initialize and start in a predictable order. | Medium | 4h | [ ] Run startup smoke test; [ ] verify error path. | [ ] Modular architecture; [ ] no monolithic manager. | Not Started |
| MVP-FRAME-002 | Create Server Bootstrap Shell | P0 | MVP-FRAME-001 | Create the server bootstrap entry point that loads approved services through the lifecycle contract. | Server bootstrap shell. | `docs/TECH_ARCHITECTURE.md`, `docs/SECURITY_GUIDE.md` | Bootstrap starts services and reports failures safely. | Medium | 4h | [ ] Start place; [ ] confirm bootstrap logs. | [ ] Server authority preserved; [ ] no gameplay rules added. | Not Started |
| MVP-FRAME-003 | Create Client Bootstrap Shell | P0 | MVP-FRAME-001 | Create the client bootstrap entry point for UI controllers and presentation-only client systems. | Client bootstrap shell. | `docs/TECH_ARCHITECTURE.md`, `docs/UI_GUIDELINES.md` | Client startup can initialize UI controllers without owning gameplay state. | Medium | 4h | [ ] Start client; [ ] confirm no authoritative state mutation. | [ ] MVC-inspired separation; [ ] no gameplay logic in UI. | Not Started |
| MVP-FRAME-004 | Add Shared Result Pattern | P0 | MVP-TYPE-001 | Create a consistent success/failure result contract for services and remote handlers. | Result type; usage notes. | `docs/STYLE_GUIDE.md`, `docs/SECURITY_GUIDE.md` | Services can return predictable success/failure without throwing for normal validation failure. | Low | 3h | [ ] Validate success path; [ ] validate failure path. | [ ] Naming consistency; [ ] readable failure reasons. | Not Started |
| MVP-FRAME-005 | Add Framework Smoke Test | P0 | MVP-FRAME-002, MVP-FRAME-003 | Add a minimal startup validation that confirms server and client bootstraps initialize. | Smoke test or manual checklist. | `docs/DEFINITION_OF_DONE.md` | Startup validation exists and is documented. | Low | 2h | [ ] Run startup; [ ] record output. | [ ] Evidence recorded; [ ] no unrelated systems. | Not Started |

## Shared Types

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-TYPE-001 | Create Shared ID Conventions | P0 | MVP-SETUP-001 | Define shared identifier conventions for creatures, skills, worlds, bosses, currencies, rewards, and config records. | Shared ID convention definitions. | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md` | ID conventions are centralized and match docs. | Low | 2h | [ ] Validate sample IDs; [ ] check naming format. | [ ] Stable IDs; [ ] no display names as IDs. | Not Started |
| MVP-TYPE-002 | Create Shared Enum Definitions | P0 | MVP-TYPE-001 | Define approved enum categories required by active MVP systems only. | Shared enum definitions. | `docs/DATA_SCHEMA.md`, `docs/DECISIONS.md` | Enums exist only for documented active categories. | Medium | 3h | [ ] Validate enum references; [ ] reject unknown values. | [ ] No reserved systems activated; [ ] no speculative enums. | Not Started |
| MVP-TYPE-003 | Create State Snapshot Contracts | P0 | MVP-TYPE-001 | Define server-to-client read-only state snapshot shapes for UI display. | Snapshot contracts for display data. | `docs/TECH_ARCHITECTURE.md`, `docs/SECURITY_GUIDE.md` | UI-facing snapshots are explicit and non-authoritative. | Medium | 4h | [ ] Validate snapshot shape; [ ] confirm no server secrets exposed. | [ ] Client is presentation-only; [ ] fields documented. | Not Started |

## Config System

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-CONFIG-001 | Create Config Folder Structure | P0 | MVP-SETUP-001 | Create approved config folders for active MVP data categories and reserved folders only where explicitly documented. | Config folder hierarchy. | `docs/CONFIG_STRUCTURE.md`, `docs/CONFIG_GUIDE.md` | Config folders exist and match documented hierarchy. | Low | 2h | [ ] Inspect tree; [ ] confirm reserved labels. | [ ] Folder ownership clear; [ ] no active reserved content. | Not Started |
| MVP-CONFIG-002 | Implement Static Config Registry | P0 | MVP-CONFIG-001 | Implement a registry that loads approved static configuration records. | Static config registry. | `docs/CONFIG_GUIDE.md`, `docs/TECH_ARCHITECTURE.md` | Active config categories can be loaded through one registry. | Medium | 5h | [ ] Load empty/minimal configs; [ ] handle missing category. | [ ] Data-driven design; [ ] no hardcoded gameplay values. | Not Started |
| MVP-CONFIG-003 | Implement Config Validation Runner | P0 | MVP-CONFIG-002 | Implement validation for required fields, field types, stable IDs, and enabled flags. | Validation runner; validation result output. | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md` | Invalid config is rejected before gameplay systems consume it. | Medium | 5h | [ ] Valid config passes; [ ] invalid config fails. | [ ] Schema alignment; [ ] useful validation errors. | Not Started |
| MVP-CONFIG-004 | Implement Reference Resolver | P0 | MVP-CONFIG-003 | Implement cross-config reference validation for active MVP categories. | Reference resolver; missing reference failures. | `docs/CONFIG_STRUCTURE.md` | References fail safely when missing or pointing to wrong category. | Medium | 5h | [ ] Missing reference fails; [ ] valid reference resolves. | [ ] No circular dependencies; [ ] reserved refs blocked. | Not Started |
| MVP-CONFIG-005 | Add Config Version Metadata Validation | P1 | MVP-CONFIG-003 | Validate schema and config version metadata for save-impacting and gameplay-facing config. | Version validation rules. | `docs/CONFIG_GUIDE.md`, `docs/DATA_SCHEMA.md` | Config records expose version metadata where required. | Medium | 3h | [ ] Missing version fails where required; [ ] valid version passes. | [ ] Migration risk considered; [ ] docs aligned. | Not Started |

## Database Layer

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-DB-001 | Define Persistence Access Wrapper | P0 | MVP-FRAME-001 | Implement a thin server-side persistence access wrapper without gameplay-specific save mutation. | Persistence wrapper; error handling surface. | `docs/SAVE_SYSTEM.md`, `docs/SECURITY_GUIDE.md` | All persistence calls route through the wrapper. | Medium | 5h | [ ] Success path; [ ] failure path; [ ] retry path if documented. | [ ] Server-owned persistence; [ ] no client save writes. | Not Started |
| MVP-DB-002 | Implement Save Key Strategy | P0 | MVP-DB-001 | Implement documented save key construction for player data. | Save key utility. | `docs/SAVE_SYSTEM.md`, `docs/SECURITY_GUIDE.md` | Save keys are deterministic and server-only. | Low | 2h | [ ] Same player gives same key; [ ] invalid player rejected. | [ ] No sensitive leakage; [ ] naming consistent. | Not Started |
| MVP-DB-003 | Add Persistence Failure Reporting | P1 | MVP-DB-001 | Add controlled warning/reporting behavior for load and save failures. | Failure reporting path. | `docs/SECURITY_GUIDE.md`, `docs/DEFINITION_OF_DONE.md` | Failures are visible without exposing full save payloads. | Low | 3h | [ ] Simulated failure logs safely; [ ] no state mutation on failure. | [ ] Logs useful; [ ] no sensitive data. | Not Started |

## Networking

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-NET-001 | Create Remote Folder Structure | P0 | MVP-SETUP-001 | Create the documented RemoteEvent and RemoteFunction organization without adding gameplay remotes. | Remote folder structure. | `docs/TECH_ARCHITECTURE.md`, `docs/SECURITY_GUIDE.md` | Remote containers exist and naming follows style guide. | Low | 2h | [ ] Inspect tree; [ ] confirm no undocumented remotes. | [ ] Naming correct; [ ] no gameplay authority exposed. | Not Started |
| MVP-NET-002 | Implement Remote Contract Registry | P0 | MVP-NET-001, MVP-TYPE-002 | Implement a registry documenting expected inputs, outputs, owner, and validation path for remotes. | Remote contract registry. | `docs/SECURITY_GUIDE.md`, `docs/STYLE_GUIDE.md` | Every active remote must be registered before use. | Medium | 4h | [ ] Registered remote resolves; [ ] unregistered remote blocked. | [ ] Validation path clear; [ ] no undocumented remotes. | Not Started |
| MVP-NET-003 | Implement Remote Request Validation Layer | P0 | MVP-NET-002, MVP-FRAME-004 | Implement reusable server-side parameter and ownership validation hooks. | Validation middleware. | `docs/SECURITY_GUIDE.md` | Remote handlers can validate inputs before state changes. | Medium | 5h | [ ] Invalid type rejected; [ ] missing input rejected. | [ ] Server authority; [ ] safe failure behavior. | Not Started |
| MVP-NET-004 | Implement Remote Rate Limit Utility | P1 | MVP-NET-002 | Implement server-side rate limiting utility for mutating remotes. | Rate limit utility. | `docs/SECURITY_GUIDE.md` | Repeated requests can be rejected safely. | Medium | 4h | [ ] Rapid calls rejected; [ ] normal calls accepted. | [ ] No client timer trust; [ ] logging appropriate. | Not Started |

## Save System

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-SAVE-001 | Finalize MVP Save Field List | P0 | `docs/SAVE_SYSTEM.md` update required | Document exact save fields required by MVP systems before implementation. | Updated save field list. | `docs/SAVE_SYSTEM.md`, `docs/DATA_SCHEMA.md` | Required save fields are documented and reviewed. | Medium | 3h | [ ] Cross-check all MVP systems; [ ] unresolved fields logged. | [ ] No speculative fields; [ ] schema alignment. | Blocked |
| MVP-SAVE-002 | Implement Default Save Template | P0 | MVP-SAVE-001 | Implement the server-owned default save structure for new players. | Default save template. | `docs/SAVE_SYSTEM.md`, `docs/DATA_SCHEMA.md` | New player save initializes with documented fields only. | Medium | 4h | [ ] New save validates; [ ] no reserved fields active. | [ ] Server-owned state; [ ] schema alignment. | Blocked |
| MVP-SAVE-003 | Implement Save Load Flow | P0 | MVP-DB-001, MVP-SAVE-002 | Load, validate, and prepare player save state on join. | Load flow; failure handling. | `docs/SAVE_SYSTEM.md`, `docs/SECURITY_GUIDE.md` | Player state loads safely or fails gracefully. | Medium | 5h | [ ] Existing save loads; [ ] missing save initializes; [ ] invalid save rejected/repaired per docs. | [ ] No client save trust; [ ] failure path safe. | Blocked |
| MVP-SAVE-004 | Implement Save Mutation API | P0 | MVP-SAVE-003 | Create server-only API for approved systems to mutate save state. | Save mutation API. | `docs/SAVE_SYSTEM.md`, `docs/TECH_ARCHITECTURE.md` | Systems can mutate only documented save fields through server API. | Medium | 5h | [ ] Valid mutation applies; [ ] invalid mutation rejected. | [ ] Encapsulation; [ ] no direct client mutation. | Blocked |
| MVP-SAVE-005 | Implement Save Write Flow | P0 | MVP-SAVE-004 | Write validated player save state through the persistence wrapper. | Save write flow; validation before write. | `docs/SAVE_SYSTEM.md`, `docs/SECURITY_GUIDE.md` | Save writes happen server-side after validation. | Medium | 5h | [ ] Save on exit; [ ] write failure reported; [ ] excessive writes avoided. | [ ] Server authority; [ ] no raw client payloads. | Blocked |

## UI Framework

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-UI-001 | Finalize MVP Screen Inventory | P0 | `docs/UI_GUIDELINES.md` update required | Document the MVP screens required to operate approved systems. | Updated UI screen inventory. | `docs/UI_GUIDELINES.md`, `docs/GDD_MASTER.md` | Screens map only to approved MVP scope. | Medium | 3h | [ ] Cross-check MVP systems; [ ] no unapproved flows. | [ ] UI scope clear; [ ] no gameplay invention. | Blocked |
| MVP-UI-002 | Implement Client Screen Router | P0 | MVP-FRAME-003, MVP-UI-001 | Implement client-side screen navigation for approved MVP screens. | Screen router. | `docs/TECH_ARCHITECTURE.md`, `docs/UI_GUIDELINES.md` | Screens can open/close without owning gameplay state. | Medium | 5h | [ ] Navigate between screens; [ ] invalid route handled. | [ ] UI-only authority; [ ] naming consistent. | Blocked |
| MVP-UI-003 | Implement Shared UI State Store | P0 | MVP-TYPE-003, MVP-UI-002 | Implement presentation state store fed by server-approved snapshots. | UI state store. | `docs/TECH_ARCHITECTURE.md`, `docs/SECURITY_GUIDE.md` | UI reads display state without mutating authoritative state. | Medium | 5h | [ ] Snapshot applied; [ ] stale data handled. | [ ] No gameplay logic in UI; [ ] state shape documented. | Blocked |
| MVP-UI-004 | Implement Common UI Components | P1 | MVP-UI-002 | Build reusable buttons, panels, lists, status rows, and modal patterns for MVP screens. | Common UI components. | `docs/UI_GUIDELINES.md`, `docs/STYLE_GUIDE.md` | Components support MVP screens consistently. | Medium | 5h | [ ] Components render; [ ] mobile/desktop smoke check. | [ ] Style consistency; [ ] no nested card clutter. | Blocked |
| MVP-UI-005 | Implement Loading, Empty, and Error States | P1 | MVP-UI-003 | Add shared UI states for loading data, missing data, and rejected requests. | UI state components. | `docs/UI_GUIDELINES.md`, `docs/DEFINITION_OF_DONE.md` | MVP screens can show clear non-success states. | Low | 4h | [ ] Loading state; [ ] empty state; [ ] error state. | [ ] User clarity; [ ] no misleading success. | Blocked |

## Bio Generator

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-BIO-001 | Resolve Bio Generator MVP Scope | P2 | Project Director decision | Determine whether Bio Generator is part of MVP, presentation-only, or out of scope. Do not implement generation logic in this task. | Decision entry or known issue update. | `docs/DECISIONS.md`, `docs/GDD_MASTER.md`, `docs/KNOWN_ISSUES.md` | Bio Generator is accepted, rejected, or deferred before any task is created. | Low | 2h | [ ] Confirm current docs; [ ] record decision outcome. | [ ] No mechanics invented; [ ] scope clear. | Blocked |

## Creature Database

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-CREATURE-001 | Implement Creature Config Schema | P0 | MVP-CONFIG-003 | Implement validation for documented Creature Config fields. | Creature config validator. | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md` | Creature configs validate required fields and references. | Medium | 4h | [ ] Valid creature passes; [ ] invalid field fails. | [ ] Schema alignment; [ ] no unapproved fields. | Not Started |
| MVP-CREATURE-002 | Implement Creature Registry | P0 | MVP-CREATURE-001 | Implement server-readable registry for active creature definitions. | Creature registry. | `docs/DATA_SCHEMA.md`, `docs/CONFIG_STRUCTURE.md` | Systems can fetch active creature definitions by stable ID. | Medium | 4h | [ ] Fetch valid ID; [ ] reject unknown ID. | [ ] Data-driven; [ ] no hardcoded creatures. | Not Started |
| MVP-CREATURE-003 | Implement Player Creature State Model | P0 | MVP-SAVE-004, MVP-CREATURE-002 | Implement server-owned player creature state based on save fields. | Player creature state model. | `docs/SAVE_SYSTEM.md`, `docs/DATA_SCHEMA.md` | Owned creature state exists and validates against config. | Medium | 5h | [ ] Owned creature loads; [ ] invalid creature rejected. | [ ] Save compatibility; [ ] ownership server-side. | Blocked |
| MVP-CREATURE-004 | Implement Creature Display Snapshot | P1 | MVP-CREATURE-003, MVP-TYPE-003 | Build read-only creature data snapshots for UI. | Creature UI snapshot adapter. | `docs/TECH_ARCHITECTURE.md`, `docs/UI_GUIDELINES.md` | UI can display creature state without authority. | Low | 3h | [ ] Snapshot fields render; [ ] missing visual handled. | [ ] No gameplay mutation; [ ] terminology consistent. | Blocked |

## Collection

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-COLLECTION-001 | Finalize Hybrid Collection Rules | P0 | `docs/PROGRESSION.md` update required | Document exact MVP hybrid collection behavior before implementation. | Updated collection rules. | `docs/GDD_MASTER.md`, `docs/DATA_SCHEMA.md`, `docs/DECISIONS.md` | Collection rules are documented without unapproved rewards. | Medium | 3h | [ ] Check GDD/decisions; [ ] unresolved questions logged. | [ ] Hybrid model preserved; [ ] no hidden rewards. | Blocked |
| MVP-COLLECTION-002 | Implement Collection State Tracker | P1 | MVP-COLLECTION-001, MVP-SAVE-004 | Implement server-owned collection progress tracking for approved collection data. | Collection state tracker. | `docs/DATA_SCHEMA.md`, `docs/SAVE_SYSTEM.md` | Collection state updates only through server-approved events. | Medium | 5h | [ ] Track owned creature; [ ] reject invalid collection ID. | [ ] Server authority; [ ] save compatibility. | Blocked |
| MVP-COLLECTION-003 | Implement Collection UI Snapshot | P1 | MVP-COLLECTION-002, MVP-UI-003 | Provide read-only collection display data for UI. | Collection UI snapshot. | `docs/UI_GUIDELINES.md`, `docs/TECH_ARCHITECTURE.md` | UI can show collection progress without modifying it. | Low | 3h | [ ] Display collected/uncollected states; [ ] empty state. | [ ] UI-only authority; [ ] terminology consistent. | Blocked |

## Combat

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-COMBAT-001 | Finalize Combat Formula Values | P0 | Balance approval required | Resolve documented MVP damage, DEF, and power placeholder values before formula implementation. | Updated combat and balance docs. | `docs/COMBAT.md`, `docs/BALANCE.md`, `docs/DECISIONS.md` | Formula inputs are approved or explicitly placeholder-gated. | Medium | 3h | [ ] Confirm no fake values; [ ] unresolved values logged. | [ ] Simplified MVP formula; [ ] data-driven values. | Blocked |
| MVP-COMBAT-002 | Implement Battle Session Model | P0 | MVP-CREATURE-003, MVP-CONFIG-004 | Implement server-side battle session state container without UI authority. | Battle session model. | `docs/COMBAT.md`, `docs/TECH_ARCHITECTURE.md` | Battle state is server-owned and scoped to a player/session. | Medium | 5h | [ ] Create session; [ ] reject invalid state. | [ ] Server authoritative; [ ] no client battle truth. | Blocked |
| MVP-COMBAT-003 | Implement Story 1v1 Battle Setup | P0 | MVP-COMBAT-002, MVP-WORLD-002 | Implement documented Story Mode 1v1 battle initialization. | Story battle setup path. | `docs/COMBAT.md`, `docs/DATA_SCHEMA.md` | Story battle starts only with valid owned creature and valid enemy. | Medium | 5h | [ ] Valid 1v1 starts; [ ] invalid creature rejected. | [ ] 1v1 preserved; [ ] no power gate. | Blocked |
| MVP-COMBAT-004 | Implement Simplified Damage Resolver | P0 | MVP-COMBAT-001, MVP-COMBAT-002 | Implement approved simplified damage formula and DEF percentage reduction. | Damage resolver. | `docs/COMBAT.md`, `docs/BALANCE.md` | Damage is server-calculated and matches documented formula. | Medium | 5h | [ ] Damage cases; [ ] DEF reduction cases; [ ] no client damage. | [ ] Formula documented; [ ] values config-driven. | Blocked |
| MVP-COMBAT-005 | Implement Battle Completion Flow | P0 | MVP-COMBAT-003, MVP-COMBAT-004, MVP-ECO-003 | Resolve victory/defeat, full heal after battle, and reward handoff through server-approved paths. | Battle completion flow. | `docs/COMBAT.md`, `docs/SECURITY_GUIDE.md` | Battle completion updates state safely and heals creatures after battle. | Medium | 6h | [ ] Win path; [ ] loss path; [ ] heal path; [ ] reward handoff. | [ ] Server result; [ ] no client reward claims. | Blocked |

## Action Gauge

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-GAUGE-001 | Finalize Action Gauge Parameters | P0 | `docs/COMBAT.md`, `docs/BALANCE.md` update required | Document the exact MVP Action Time Bar and SPD gauge behavior. | Updated gauge documentation. | `docs/COMBAT.md`, `docs/BALANCE.md` | Gauge behavior is documented without extra-turn systems. | Medium | 3h | [ ] Confirm SPD rule; [ ] no extra systems added. | [ ] Decision alignment; [ ] no fake numbers. | Blocked |
| MVP-GAUGE-002 | Implement SPD Gauge Fill Resolver | P0 | MVP-GAUGE-001, MVP-COMBAT-002 | Implement server-side gauge fill from SPD according to approved formula. | Gauge fill resolver. | `docs/COMBAT.md` | Gauge state advances based on documented SPD behavior. | Medium | 5h | [ ] Low SPD case; [ ] high SPD case; [ ] tie case. | [ ] Server authority; [ ] formula documented. | Blocked |
| MVP-GAUGE-003 | Implement Action Selection Resolver | P0 | MVP-GAUGE-002, MVP-SKILL-002 | Resolve which combatant acts when gauge threshold is reached. | Action resolver. | `docs/COMBAT.md` | Combat turn order follows documented gauge state. | Medium | 5h | [ ] Single ready actor; [ ] multiple ready actors; [ ] no actor ready. | [ ] No manual commands; [ ] simple flow. | Blocked |

## Skills

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-SKILL-001 | Implement Skill Config Schema | P0 | MVP-CONFIG-003 | Implement validation for documented Skill Config fields. | Skill config validator. | `docs/DATA_SCHEMA.md`, `docs/COMBAT.md` | Skills validate ID, cooldown, targeting reference, and documented fields. | Medium | 4h | [ ] Valid skill passes; [ ] missing cooldown fails. | [ ] No mana; [ ] schema alignment. | Not Started |
| MVP-SKILL-002 | Implement Cooldown State Model | P0 | MVP-SKILL-001, MVP-COMBAT-002 | Implement server-owned skill cooldown state for combat sessions. | Cooldown state model. | `docs/COMBAT.md`, `docs/SECURITY_GUIDE.md` | Cooldowns are server-controlled and do not use mana. | Medium | 5h | [ ] Skill available; [ ] skill on cooldown; [ ] cooldown advances. | [ ] No client cooldown trust; [ ] no mana. | Blocked |
| MVP-SKILL-003 | Implement Skill Execution Resolver | P0 | MVP-SKILL-002, MVP-COMBAT-004 | Resolve approved skill execution through server-side combat logic. | Skill execution resolver. | `docs/COMBAT.md`, `docs/DATA_SCHEMA.md` | Skills execute only when valid and use documented effects/values. | Medium | 6h | [ ] Valid skill resolves; [ ] invalid skill rejected. | [ ] Data-driven values; [ ] no undocumented effects. | Blocked |

## Evolution

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-EVOLUTION-001 | Finalize Evolution Requirements | P0 | `docs/PROGRESSION.md` update required | Document MVP evolution requirements and eligibility rules before implementation. | Updated evolution documentation. | `docs/GDD_MASTER.md`, `docs/DECISIONS.md`, `docs/DATA_SCHEMA.md` | Evolution requirements are documented and reviewed. | Medium | 3h | [ ] Confirm no branching paths; [ ] unresolved questions logged. | [ ] Decision alignment; [ ] no invented costs. | Blocked |
| MVP-EVOLUTION-002 | Implement Evolution Config Schema | P0 | MVP-EVOLUTION-001, MVP-CONFIG-003 | Implement validation for documented Evolution Config fields. | Evolution config validator. | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md` | Evolution config validates eligible IDs and required fields. | Medium | 4h | [ ] Valid evolution passes; [ ] invalid target rejected. | [ ] No branching evolution; [ ] schema alignment. | Blocked |
| MVP-EVOLUTION-003 | Implement Evolution Transaction Flow | P1 | MVP-EVOLUTION-002, MVP-SAVE-004, MVP-ECO-004 | Implement server-side evolution state change using approved eligibility and costs if documented. | Evolution transaction service. | `docs/PROGRESSION.md`, `docs/SECURITY_GUIDE.md` | Evolution cannot occur unless server eligibility passes. | Medium | 6h | [ ] Eligible evolve succeeds; [ ] ineligible evolve fails; [ ] resources validated if used. | [ ] Server authority; [ ] no hidden mechanics. | Blocked |
| MVP-EVOLUTION-004 | Implement Evolution Level Reset | P1 | MVP-EVOLUTION-003 | Apply approved decision that evolution resets creature level according to documented target behavior. | Level reset update. | `docs/DECISIONS.md`, `docs/GDD_MASTER.md` | Evolved creature level resets exactly as documented. | Medium | 4h | [ ] Reset case; [ ] save update; [ ] UI snapshot updates. | [ ] Decision preserved; [ ] player-facing clarity. | Blocked |

## Gene

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-GENE-001 | Finalize Gene Meaning | P0 | Design decision required | Document what genes mean in MVP before implementation. | Updated gene documentation and decision notes. | `docs/GDD_MASTER.md`, `docs/DATA_SCHEMA.md`, `docs/DECISIONS.md` | Gene purpose is documented without inheritance or mutation rules. | Medium | 3h | [ ] Confirm decision log; [ ] unresolved behavior logged. | [ ] No hidden power spikes; [ ] no mutation rules. | Blocked |
| MVP-GENE-002 | Implement Gene Config Schema | P1 | MVP-GENE-001, MVP-CONFIG-003 | Implement validation for documented Gene Config fields. | Gene config validator. | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md` | Gene config validates approved fields and references. | Medium | 4h | [ ] Valid gene passes; [ ] invalid effect rejected. | [ ] Schema alignment; [ ] behavior approved. | Blocked |
| MVP-GENE-003 | Implement Gene Save State Integration | P1 | MVP-GENE-002, MVP-SAVE-004 | Persist approved gene state using server-owned save state. | Gene save integration. | `docs/SAVE_SYSTEM.md`, `docs/DATA_SCHEMA.md` | Gene state persists only for documented gene behavior. | Medium | 5h | [ ] Load gene state; [ ] save gene state; [ ] invalid state rejected. | [ ] Save compatibility; [ ] no unapproved rules. | Blocked |

## Prestige

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-PRESTIGE-001 | Resolve Prestige MVP Scope | P1 | Project Director decision | Decide whether prestige is implementation scope or documentation foundation only for MVP. | Decision entry and updated progression notes. | `docs/GDD_MASTER.md`, `docs/DECISIONS.md`, `docs/PROGRESSION.md` | Prestige is accepted, rejected, deferred, or documentation-only. | Low | 2h | [ ] Confirm GDD; [ ] record decision. | [ ] No prestige multipliers; [ ] scope clear. | Blocked |
| MVP-PRESTIGE-002 | Implement Prestige Foundation If Approved | P1 | MVP-PRESTIGE-001 accepted, MVP-SAVE-004 | Implement only the approved minimum prestige state foundation if required by MVP progression. | Prestige state foundation. | `docs/DATA_SCHEMA.md`, `docs/SAVE_SYSTEM.md` | Prestige state exists only if approved and has no unapproved rewards. | Medium | 5h | [ ] Load/save state; [ ] invalid state rejected. | [ ] No multipliers; [ ] no hidden reset behavior. | Blocked |

## Quest

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-QUEST-001 | Resolve Quest MVP Scope | P1 | Project Director decision | Decide whether quests are in MVP scope, deferred, or reserved only. Do not implement quest gameplay. | Decision entry or known issue update. | `docs/DATA_SCHEMA.md`, `docs/DECISIONS.md`, `docs/MVP_CHECKLIST.md` | Quest status is accepted, rejected, or deferred. | Low | 2h | [ ] Confirm reserved schema; [ ] record decision. | [ ] No daily quests; [ ] no timed rewards. | Blocked |
| MVP-QUEST-002 | Create Quest Implementation Task Split If Approved | P1 | MVP-QUEST-001 accepted | If quests are approved, create separate implementation-ready tasks for objective data, save state, UI, and rewards. | Follow-up task files only. | `docs/CONTENT_PIPELINE.md`, `docs/DEVELOPMENT_WORKFLOW.md` | Quest work is split into small tasks before implementation. | Low | 2h | [ ] Verify task split; [ ] no implementation included. | [ ] Scope approved; [ ] no hidden quest mechanics. | Blocked |

## World

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-WORLD-001 | Implement World Config Schema | P0 | MVP-CONFIG-003 | Implement validation for documented World Config fields. | World config validator. | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md` | World configs validate required fields and references. | Medium | 4h | [ ] Valid world passes; [ ] invalid boss ref fails. | [ ] Schema alignment; [ ] no power gate. | Not Started |
| MVP-WORLD-002 | Implement World Registry | P0 | MVP-WORLD-001 | Implement registry for active world definitions and encounter references. | World registry. | `docs/DATA_SCHEMA.md`, `docs/CONFIG_STRUCTURE.md` | Active worlds can be fetched by stable ID. | Medium | 4h | [ ] Fetch valid world; [ ] reject disabled world. | [ ] Data-driven; [ ] no hardcoded world list. | Not Started |
| MVP-WORLD-003 | Implement World Progression State | P1 | MVP-WORLD-002, MVP-SAVE-004 | Implement server-owned player world progression state. | World progression state service. | `docs/PROGRESSION.md`, `docs/SAVE_SYSTEM.md` | Player world state is saved and validated server-side. | Medium | 5h | [ ] Load progress; [ ] unlock/update valid state; [ ] reject invalid world. | [ ] Server authority; [ ] no progression skip. | Blocked |
| MVP-WORLD-004 | Implement Recommended Power Display Data | P1 | MVP-WORLD-002, MVP-UI-003 | Provide recommended power display data as guidance only. | World UI snapshot with recommended power. | `docs/COMBAT.md`, `docs/GDD_MASTER.md` | UI shows recommended power without enforcing a power gate. | Low | 3h | [ ] Display guidance; [ ] access not blocked by power. | [ ] No power gate; [ ] UI text clear. | Blocked |

## Boss

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-BOSS-001 | Implement Boss Config Schema | P0 | MVP-CONFIG-003 | Implement validation for documented Boss Config fields. | Boss config validator. | `docs/DATA_SCHEMA.md`, `docs/COMBAT.md` | Boss configs validate phase, skill, reward, and world references. | Medium | 4h | [ ] Valid boss passes; [ ] invalid phase ref fails. | [ ] Schema alignment; [ ] boss rules documented. | Not Started |
| MVP-BOSS-002 | Implement Boss Registry | P0 | MVP-BOSS-001 | Implement server-readable registry for active boss definitions. | Boss registry. | `docs/DATA_SCHEMA.md`, `docs/CONFIG_STRUCTURE.md` | Boss definitions are fetchable by stable ID. | Medium | 4h | [ ] Fetch valid boss; [ ] reject disabled boss. | [ ] Data-driven; [ ] no hardcoded bosses. | Not Started |
| MVP-BOSS-003 | Implement Boss 3v3 Battle Setup | P1 | MVP-BOSS-002, MVP-COMBAT-002 | Implement approved 3v3 boss/challenge battle initialization. | Boss battle setup path. | `docs/COMBAT.md`, `docs/SECURITY_GUIDE.md` | Boss battle starts only with valid player team and boss config. | Medium | 5h | [ ] Valid 3v3 starts; [ ] invalid team rejected. | [ ] 3v3 preserved; [ ] no client authority. | Blocked |
| MVP-BOSS-004 | Implement Boss Phase Resolver | P1 | MVP-BOSS-003 | Implement documented boss phase state changes for one or multiple phases. | Boss phase resolver. | `docs/COMBAT.md`, `docs/BALANCE.md` | Boss phases follow config and documented triggers only. | Medium | 5h | [ ] Single phase; [ ] multiple phases; [ ] invalid phase rejected. | [ ] No undocumented phase mechanics; [ ] config-driven. | Blocked |

## Tower

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-TOWER-001 | Resolve Tower MVP Scope | P1 | Project Director decision | Decide whether Tower is in MVP scope, deferred, or reserved only. Do not implement tower gameplay. | Decision entry or known issue update. | `docs/DATA_SCHEMA.md`, `docs/DECISIONS.md`, `docs/MVP_CHECKLIST.md` | Tower status is accepted, rejected, or deferred. | Low | 2h | [ ] Confirm reserved schema; [ ] record decision. | [ ] No timed resets; [ ] no hidden progression. | Blocked |
| MVP-TOWER-002 | Create Tower Implementation Task Split If Approved | P1 | MVP-TOWER-001 accepted | If Tower is approved, create separate tasks for floor config, progression state, battle references, UI, and rewards. | Follow-up task files only. | `docs/CONTENT_PIPELINE.md`, `docs/DEVELOPMENT_WORKFLOW.md` | Tower work is split before implementation. | Low | 2h | [ ] Verify task split; [ ] no implementation included. | [ ] Scope approved; [ ] no unapproved tower mechanics. | Blocked |

## Economy

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-ECO-001 | Finalize MVP Currency And Resource List | P0 | `docs/ECONOMY.md` update required | Document exact MVP currencies/resources before implementation. | Updated economy documentation. | `docs/ECONOMY.md`, `docs/BALANCE.md`, `docs/DECISIONS.md` | Economy list is approved without premium currency. | Medium | 3h | [ ] Confirm no premium currency; [ ] unresolved questions logged. | [ ] MVP economy only; [ ] no fake numbers. | Blocked |
| MVP-ECO-002 | Implement Economy Config Schema | P0 | MVP-ECO-001, MVP-CONFIG-003 | Implement validation for documented Economy Config fields. | Economy config validator. | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md` | Economy configs validate currency, source, sink, and audit fields. | Medium | 4h | [ ] Valid economy config passes; [ ] invalid currency fails. | [ ] Server-authoritative economy; [ ] schema alignment. | Blocked |
| MVP-ECO-003 | Implement Reward Grant Service | P0 | MVP-ECO-002, MVP-SAVE-004 | Implement server-only reward grant flow for approved reward sources. | Reward grant service. | `docs/SECURITY_GUIDE.md`, `docs/ECONOMY.md` | Rewards are granted only by server-approved systems. | Medium | 5h | [ ] Valid reward grants; [ ] invalid source rejected. | [ ] No client rewards; [ ] audit path clear. | Blocked |
| MVP-ECO-004 | Implement Cost And Spend Validation | P1 | MVP-ECO-002, MVP-SAVE-004 | Implement server-side cost lookup and affordability validation for approved sinks. | Spend validation service. | `docs/SECURITY_GUIDE.md`, `docs/ECONOMY.md` | Spending succeeds only when server-owned state meets approved cost. | Medium | 5h | [ ] Affordable spend; [ ] insufficient funds rejected. | [ ] No client currency trust; [ ] transaction safe. | Blocked |
| MVP-ECO-005 | Implement Drop Table Resolver | P1 | MVP-ECO-003, MVP-CONFIG-004 | Implement data-driven reward pool resolution for approved drop tables only. | Drop table resolver. | `docs/CONFIG_STRUCTURE.md`, `docs/BALANCE.md` | Drop tables resolve approved rewards without hidden reward paths. | Medium | 5h | [ ] Valid table resolves; [ ] missing reward rejected. | [ ] Economy impact reviewed; [ ] no fake weights. | Blocked |

## Settings

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-SETTINGS-001 | Resolve MVP Settings Scope | P2 | Project Director decision | Decide whether MVP requires a settings screen or only default Roblox/client behavior. Do not implement settings in this task. | Decision entry or known issue update. | `docs/UI_GUIDELINES.md`, `docs/DECISIONS.md` | Settings are accepted, rejected, or deferred before implementation. | Low | 2h | [ ] Confirm UI scope; [ ] record decision. | [ ] No gameplay values in settings; [ ] scope clear. | Blocked |

## Audio

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-AUDIO-001 | Define MVP Audio Scope | P2 | Project Director approval | Document required MVP audio categories and confirm audio is presentation-only. | Audio scope notes. | `docs/MVP_CHECKLIST.md`, `docs/ART_BIBLE.md` | Audio scope is documented without gameplay authority. | Low | 2h | [ ] Check scope; [ ] unresolved asset needs logged. | [ ] Presentation-only; [ ] no mechanics implied. | Not Started |
| MVP-AUDIO-002 | Implement Audio Reference Adapter | P2 | MVP-AUDIO-001, MVP-UI-003 | Implement client-side lookup/playback adapter for approved audio references. | Audio adapter. | `docs/TECH_ARCHITECTURE.md`, `docs/UI_GUIDELINES.md` | Audio can play from approved references without affecting gameplay. | Medium | 4h | [ ] Valid audio reference; [ ] missing reference handled. | [ ] Client-only presentation; [ ] no unrelated assets. | Blocked |

## Visual Effects

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-VFX-001 | Define MVP VFX Scope | P2 | Project Director approval | Document required MVP visual feedback categories and confirm VFX are presentation-only. | VFX scope notes. | `docs/MVP_CHECKLIST.md`, `docs/ART_BIBLE.md` | VFX scope is documented without gameplay authority. | Low | 2h | [ ] Check scope; [ ] unresolved asset needs logged. | [ ] Presentation-only; [ ] art bible alignment. | Not Started |
| MVP-VFX-002 | Implement VFX Reference Adapter | P2 | MVP-VFX-001, MVP-UI-003 | Implement client-side VFX reference adapter for approved combat/evolution feedback. | VFX adapter. | `docs/TECH_ARCHITECTURE.md`, `docs/UI_GUIDELINES.md` | VFX can play from approved references without owning gameplay outcomes. | Medium | 4h | [ ] Valid VFX reference; [ ] missing reference handled. | [ ] No gameplay authority; [ ] no mechanics implied. | Blocked |

## Testing

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-TEST-001 | Define Test Strategy | P0 | `docs/MVP_CHECKLIST.md` | Document unit, integration, manual Roblox Studio, and playtest validation expectations. | Test strategy document update. | `docs/DEFINITION_OF_DONE.md`, `docs/MVP_CHECKLIST.md` | Test approach is documented for MVP systems. | Low | 3h | [ ] Coverage mapped; [ ] gaps logged. | [ ] Practical scope; [ ] required checks clear. | Not Started |
| MVP-TEST-002 | Implement Config Validation Tests | P0 | MVP-CONFIG-003 | Add tests or validation checklist for config schema and reference validation. | Config validation tests. | `docs/CONFIG_GUIDE.md`, `docs/DATA_SCHEMA.md` | Invalid config cases are covered. | Medium | 4h | [ ] Required fields; [ ] type failures; [ ] missing references. | [ ] Meaningful coverage; [ ] no fake content. | Blocked |
| MVP-TEST-003 | Implement Save System Tests | P0 | MVP-SAVE-005 | Add tests or checklist for save template, load, validation, mutation, and write behavior. | Save validation tests. | `docs/SAVE_SYSTEM.md`, `docs/SECURITY_GUIDE.md` | Save critical paths are covered. | Medium | 5h | [ ] New save; [ ] existing save; [ ] invalid save; [ ] write failure. | [ ] Server authority; [ ] persistence safety. | Blocked |
| MVP-TEST-004 | Implement Combat Smoke Tests | P1 | MVP-COMBAT-005, MVP-GAUGE-003, MVP-SKILL-003 | Add combat smoke coverage for Story battle, damage, cooldown, gauge, and completion flow. | Combat smoke tests. | `docs/COMBAT.md`, `docs/BALANCE.md` | Approved combat rules have repeatable validation. | Medium | 5h | [ ] 1v1 flow; [ ] cooldown; [ ] gauge; [ ] full heal. | [ ] Approved rules only; [ ] no client authority. | Blocked |

## Polish

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-POLISH-001 | Perform Security Review Pass | P0 | MVP-NET-004, MVP-SAVE-005, MVP-ECO-003, MVP-COMBAT-005 | Review active remotes, economy, save, and combat authority boundaries. | Security review notes. | `docs/SECURITY_GUIDE.md`, `reviews/review_template.md` | Blocking security issues are resolved or tracked. | Medium | 4h | [ ] Remote validation; [ ] server authority; [ ] invalid request cases. | [ ] No client trust; [ ] logging appropriate. | Blocked |
| MVP-POLISH-002 | Perform Performance Review Pass | P1 | Milestone 3 systems integrated | Review startup, config loading, UI responsiveness, save write frequency, and repeated combat actions. | Performance review notes. | `docs/DEFINITION_OF_DONE.md`, `docs/TECH_ARCHITECTURE.md` | Performance risks are resolved or tracked. | Medium | 4h | [ ] Startup check; [ ] repeated action check; [ ] UI responsiveness. | [ ] No unbounded loops; [ ] no excessive saves. | Blocked |
| MVP-POLISH-003 | Perform Documentation Alignment Audit | P0 | Content Complete candidate | Audit docs against implemented MVP behavior. | Documentation audit notes; updated docs. | `docs/README.md`, `docs/DEFINITION_OF_DONE.md` | Docs match current behavior and no contradictions remain. | Medium | 5h | [ ] Check source docs; [ ] check known issues; [ ] check changelog. | [ ] Docs source-of-truth; [ ] no undocumented mechanics. | Blocked |

## Release Candidate

| Task ID | Task Name | Priority | Dependencies | Description | Expected Deliverables | Documentation References | Definition of Done | Estimated Difficulty | Estimated Time | Testing Checklist | Review Checklist | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MVP-RC-001 | Prepare MVP Release Candidate Checklist | P0 | MVP-POLISH-001, MVP-POLISH-002, MVP-POLISH-003 | Create final release candidate checklist from milestone and Definition of Done requirements. | Release candidate checklist. | `docs/MILESTONES.md`, `docs/DEFINITION_OF_DONE.md` | Release checklist is complete and reviewable. | Low | 3h | [ ] All gates listed; [ ] blockers identified. | [ ] Milestone alignment; [ ] no missing exit criteria. | Blocked |
| MVP-RC-002 | Run Final MVP Playtest Pass | P0 | MVP-RC-001 | Complete final human playtest pass through approved MVP flow. | Playtest notes; issue list. | `docs/DEVELOPMENT_WORKFLOW.md`, `docs/MILESTONES.md` | Critical playtest issues are resolved or accepted by owner. | Medium | 4h | [ ] Core loop; [ ] save/load; [ ] combat; [ ] UI. | [ ] Player flow coherent; [ ] issues classified. | Blocked |
| MVP-RC-003 | Finalize MVP Release Notes And Approval | P0 | MVP-RC-002 | Update changelog, known issues, and release notes; collect final human approval. | Release notes; changelog update; approval record. | `docs/CHANGELOG.md`, `docs/KNOWN_ISSUES.md`, `docs/MILESTONES.md` | MVP release is approved or blocked with documented reasons. | Low | 3h | [ ] Changelog current; [ ] known issues current; [ ] approval recorded. | [ ] Accurate release scope; [ ] no undocumented behavior. | Blocked |
