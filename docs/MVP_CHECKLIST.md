# MVP Checklist

## Purpose

This document is the master checklist for the Project Genesis MVP.

It organizes MVP work into production categories and tracks implementation readiness, dependencies, testing expectations, and review requirements.

This document is a planning checklist only. It does not approve new mechanics, balance values, content quantities, source folders, Lua, Luau, UI screens, audio assets, visual effects, quests, tower content, or implementation work by itself.

## Status

- Status: Active Draft
- Scope: MVP production planning
- Owner: Production
- Last Updated: 2026-06-29
- Review Cadence: Every MVP milestone, every scope change, and before implementation sprint planning
- Authority Level: MVP production checklist

## Priority Legend

- P0: Required for MVP foundation or implementation safety.
- P1: Required for MVP usability, completeness, or validation.
- P2: Important polish or future-ready work that must not block core validation unless promoted.

## Status Legend

- Not Started: No implementation work should be assumed complete.
- In Progress: Work has started and must be reviewed before completion.
- Blocked: Work cannot proceed until dependency or approval is resolved.
- Review: Work is ready for review.
- Done: Work is complete, reviewed, and verified.

## Table of Contents

- [MVP-019 Release Gate Audit Snapshot](#mvp-019-release-gate-audit-snapshot)
- [1. Project Setup](#1-project-setup)
- [2. Core Framework](#2-core-framework)
- [3. Data Layer](#3-data-layer)
- [4. Save System](#4-save-system)
- [5. Creature System](#5-creature-system)
- [6. Combat](#6-combat)
- [7. Evolution](#7-evolution)
- [8. Collection](#8-collection)
- [9. Gene](#9-gene)
- [10. UI](#10-ui)
- [11. Audio](#11-audio)
- [12. Visual Effects](#12-visual-effects)
- [13. Tower](#13-tower)
- [14. Boss](#14-boss)
- [15. Quest](#15-quest)
- [16. Economy](#16-economy)
- [17. Testing](#17-testing)
- [18. Polish](#18-polish)
- [19. MVP Exit Criteria](#19-mvp-exit-criteria)

## MVP-019 Release Gate Audit Snapshot

- Audit Date: 2026-07-01
- Current RC Status: Approved; Release Candidate is ready.
- Grand Check: Passed on rerun in Roblox Studio Play Mode. Coverage was split into framework/config/dependency, creature/economy/progression, combat/world/boss/game-mode, client UI, and post-cleanup audit batches covering MVP-001 through MVP-019.
- Dependency Audit: Passed for source/config/test files and Studio Edit-mode DataModel after the `FrameworkSmoke` require path fix. No `*_Clone` modules, no GUID-named modules, no old source require paths, no `restore_generated` requires, and no duplicate ModuleScripts were found in the Studio Edit-mode audit.
- Doc/Task Audit: README, CHANGELOG, KNOWN_ISSUES, and MVP_CHECKLIST were aligned with the release-gate state. MVP-001 through MVP-019 task records are `Approved`.
- Save System: `SaveService` is fully integrated with `DataStoreWrapper` and saves/loads player profiles dynamically to/from Roblox DataStores.
- Scope Guard: No Quest runtime, Tower runtime, reward grant logic, boss phase switching, or gameplay placeholder service is approved by this checklist snapshot.
- Required Before RC: Resolved. All milestones MVP-001 through MVP-019 are approved and persistence is implemented.

## 1. Project Setup

- [x] MVP-SETUP-001 - Establish source folder structure
  - Priority: P0
  - Dependency: `docs/TECH_ARCHITECTURE.md`, `docs/STYLE_GUIDE.md`, approval of source folder plan
  - Current Status: Approved
  - Definition of Done:
    - [x] Server-only, client-only, shared, data, and test folder responsibilities are documented.
    - [x] Folder structure does not conflict with existing documentation.
    - [x] No gameplay implementation is added during setup.
  - Testing Checklist:
    - [x] Verify folders are present only where approved.
    - [x] Verify no Lua or Luau gameplay files are created by this task unless separately approved.
  - Review Checklist:
    - [x] Reviewer confirms architecture alignment.
    - [x] Reviewer confirms naming follows `docs/STYLE_GUIDE.md`.
    - [x] Reviewer confirms no unrelated files changed.

- [x] MVP-SETUP-002 - Create implementation task breakdown
  - Priority: P0
  - Dependency: `docs/GDD_MASTER.md`, `docs/DECISIONS.md`, `docs/CONTENT_PIPELINE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] MVP tasks are split into reviewable units.
    - [x] Each task has acceptance criteria.
    - [x] Each task references required documentation.
  - Testing Checklist:
    - [x] Verify every task has clear dependencies.
    - [x] Verify no task implements reserved systems without approval.
  - Review Checklist:
    - [x] Reviewer confirms task scope is MVP-only.
    - [x] Reviewer confirms tasks do not introduce feature creep.

## 2. Core Framework

- [x] MVP-FRAMEWORK-001 - Define service lifecycle pattern
  - Priority: P0
  - Dependency: `docs/TECH_ARCHITECTURE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Server service startup order is documented.
    - [x] Service ownership boundaries are documented.
    - [x] Dependency direction is documented.
  - Testing Checklist:
    - [x] Verify lifecycle can support save, data, combat, economy, and progression services.
    - [x] Verify no service depends on client UI.
  - Review Checklist:
    - [x] Reviewer confirms server authority is preserved.
    - [x] Reviewer confirms no monolithic manager pattern is introduced.

- [x] MVP-FRAMEWORK-002 - Define remote contract pattern
  - Priority: P0
  - Dependency: `docs/TECH_ARCHITECTURE.md`, `docs/STYLE_GUIDE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] RemoteEvent and RemoteFunction naming rules are applied.
    - [x] Payload documentation format is defined.
    - [x] Failure response format is defined.
  - Testing Checklist:
    - [x] Verify remotes preserve server authority.
    - [x] Verify remote payload validation requirements are documented.
  - Review Checklist:
    - [x] Reviewer confirms no client-owned authoritative outcome.
    - [x] Reviewer confirms contract names are specific and reviewable.

## 3. Data Layer

- [x] MVP-DATA-001 - Implement static data registry plan
  - Priority: P0
  - Dependency: `docs/DATA_SCHEMA.md`, `docs/TECH_ARCHITECTURE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Static data loading strategy is documented.
    - [x] Data validation strategy is documented.
    - [x] Disabled content handling is documented.
  - Testing Checklist:
    - [x] Verify invalid IDs fail validation.
    - [x] Verify disabled definitions cannot be used in active content unless allowed.
  - Review Checklist:
    - [x] Reviewer confirms schemas are followed.
    - [x] Reviewer confirms no gameplay values are hardcoded.

- [x] MVP-DATA-002 - Create MVP data authoring checklist
  - Priority: P0
  - Dependency: `docs/CONTENT_PIPELINE.md`, `docs/BALANCE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Required data fields are listed by content type.
    - [x] Required `TBD` handling is documented.
    - [x] Review process for data changes is documented.
  - Testing Checklist:
    - [x] Verify every MVP data type maps to `docs/DATA_SCHEMA.md`.
    - [x] Verify reserved content types remain approval-gated.
  - Review Checklist:
    - [x] Reviewer confirms content pipeline alignment.
    - [x] Reviewer confirms balance values are not invented.

## 4. Save System

- [x] MVP-SAVE-001 - Define save lifecycle
  - Priority: P0
  - Dependency: `docs/SAVE_SYSTEM.md`, `docs/DATA_SCHEMA.md`, `docs/TECH_ARCHITECTURE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Load flow is documented.
    - [x] Save flow is documented.
    - [x] Failure handling is documented.
    - [x] Migration policy is documented.
  - Testing Checklist:
    - [x] Verify missing save data has safe defaults.
    - [x] Verify invalid save data fails safely.
    - [x] Verify save version handling is defined.
  - Review Checklist:
    - [x] Reviewer confirms persistence is server-owned.
    - [x] Reviewer confirms schema compatibility.

- [x] MVP-SAVE-002 - Define persisted MVP state
  - Priority: P0
  - Dependency: `docs/DATA_SCHEMA.md`, `docs/SAVE_SYSTEM.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Player Save fields needed for MVP are listed.
    - [x] Creature ownership persistence is documented.
    - [x] Collection, economy, progression, and settings persistence is documented.
  - Testing Checklist:
    - [x] Verify no runtime-only combat state is persisted unless approved.
    - [x] Verify client cannot write save data.
  - Review Checklist:
    - [x] Reviewer confirms save fields are documented before implementation.
    - [x] Reviewer confirms migration risks are identified.

## 5. Creature System

- [x] MVP-CREATURE-001 - Define creature runtime model
  - Priority: P0
  - Dependency: `docs/GDD_MASTER.md`, `docs/DATA_SCHEMA.md`, `docs/BALANCE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Creature identity data is defined.
    - [x] Creature instance state is defined.
    - [x] Creature ownership rules are documented.
  - Testing Checklist:
    - [x] Verify creature IDs are stable.
    - [x] Verify creature instances reference valid definitions.
  - Review Checklist:
    - [x] Reviewer confirms no species, rarity, or acquisition mechanics are invented.
    - [x] Reviewer confirms save implications are documented.

- [x] MVP-CREATURE-002 - Define creature stat data requirements
  - Priority: P0
  - Dependency: `docs/COMBAT.md`, `docs/DATA_SCHEMA.md`, `docs/BALANCE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Required combat stats are documented.
    - [x] Stat placeholders remain `TBD` until approved.
    - [x] Power contribution is documented as recommendation-only.
  - Testing Checklist:
    - [x] Verify HP, ATK, DEF, and SPD data requirements are clear.
    - [x] Verify no fake numeric values are introduced.
  - Review Checklist:
    - [x] Reviewer confirms combat alignment.
    - [x] Reviewer confirms data-driven stat ownership.

## 6. Combat

- [x] MVP-COMBAT-001 - Define combat formula values
  - Priority: P0
  - Dependency: `docs/COMBAT.md`, `docs/BALANCE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Raw damage inputs are approved.
    - [x] DEF percentage reduction formula is approved.
    - [x] Rounding and minimum damage rules are approved.
  - Testing Checklist:
    - [x] Verify formula uses server-owned data.
    - [x] Verify no critical hits or type advantages are introduced.
  - Review Checklist:
    - [x] Reviewer confirms simplified MVP formula.
    - [x] Reviewer confirms values are documented in balance data.

- [x] MVP-COMBAT-002 - Define Action Gauge behavior
  - Priority: P0
  - Dependency: `docs/COMBAT.md`, `docs/BALANCE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Gauge threshold is approved.
    - [x] Gauge fill coefficient is approved.
    - [x] Gauge reset, overflow, and carryover behavior are documented.
  - Testing Checklist:
    - [x] Verify higher SPD fills faster than lower SPD.
    - [x] Verify action order is deterministic or testable.
  - Review Checklist:
    - [x] Reviewer confirms SPD rules are followed.
    - [x] Reviewer confirms no extra-turn systems are introduced.

- [x] MVP-COMBAT-003 - Define auto battle decision rules
  - Priority: P0
  - Dependency: `docs/COMBAT.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Player-side skill priority is documented.
    - [x] Player-side targeting priority is documented.
    - [x] Enemy targeting and skill priority are documented.
  - Testing Checklist:
    - [x] Verify battles can resolve without manual commands.
    - [x] Verify fallback behavior exists when skills are on cooldown.
  - Review Checklist:
    - [x] Reviewer confirms Auto Battle decision is preserved.
    - [x] Reviewer confirms no manual combat controls are added.

## 7. Evolution

- [x] MVP-EVOLUTION-001 - Define evolution requirements
  - Priority: P0
  - Dependency: `docs/GDD_MASTER.md`, `docs/DECISIONS.md`, `docs/BALANCE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Evolution requirement data is documented.
    - [x] Cost behavior is approved or explicitly absent.
    - [x] Server validation rules are documented.
  - Testing Checklist:
    - [x] Verify evolution cannot be triggered by the client alone.
    - [x] Verify unmet requirements fail safely.
  - Review Checklist:
    - [x] Reviewer confirms no branching evolution is added.
    - [x] Reviewer confirms economy implications are reviewed.

- [x] MVP-EVOLUTION-002 - Define evolution reset behavior
  - Priority: P0
  - Dependency: `docs/DECISIONS.md` DD-026, `docs/SAVE_SYSTEM.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Reset level target is approved.
    - [x] Preserved state is documented.
    - [x] Changed state is documented.
  - Testing Checklist:
    - [x] Verify creature level reset behavior is deterministic.
    - [x] Verify saved creature state remains valid after evolution.
  - Review Checklist:
    - [x] Reviewer confirms reset aligns with decision log.
    - [x] Reviewer confirms player-facing clarity is planned.

## 8. Collection

- [x] MVP-COLLECTION-001 - Define hybrid collection rules
  - Priority: P0
  - Dependency: `docs/DECISIONS.md` DD-027, `docs/DATA_SCHEMA.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Collection progress rules are documented.
    - [x] Owned creature state relationship is documented.
    - [x] Duplicate, evolved, and gene-related behavior is approved or `TBD`.
  - Testing Checklist:
    - [x] Verify collection state persists correctly.
    - [x] Verify collection cannot be completed by client-only updates.
  - Review Checklist:
    - [x] Reviewer confirms hybrid model is preserved.
    - [x] Reviewer confirms no unapproved collection rewards are added.

- [x] MVP-COLLECTION-002 - Define collection UI data requirements
  - Priority: P1
  - Dependency: `docs/UI_GUIDELINES.md`, `docs/DATA_SCHEMA.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Collection display data is documented.
    - [x] Visibility rules are documented.
    - [x] Empty, locked, discovered, and collected states are documented if used.
  - Testing Checklist:
    - [x] Verify UI displays server-provided collection state.
    - [x] Verify UI cannot mark collection entries complete.
  - Review Checklist:
    - [x] Reviewer confirms UI separation from gameplay authority.
    - [x] Reviewer confirms collection terminology is consistent.

## 9. Gene

- [x] MVP-GENE-001 - Define gene meaning
  - Priority: P0
  - Dependency: `docs/GDD_MASTER.md`, `docs/DATA_SCHEMA.md`, `docs/BALANCE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Gene purpose is documented.
    - [x] Gene visibility is documented.
    - [x] Static, mutable, rolled, or unlocked behavior is approved.
  - Testing Checklist:
    - [x] Verify gene values are server-owned if mutable.
    - [x] Verify gene data follows schema.
  - Review Checklist:
    - [x] Reviewer confirms no inheritance or mutation rules are added without approval.
    - [x] Reviewer confirms no hidden power spikes are introduced.

- [x] MVP-GENE-002 - Define gene save behavior
  - Priority: P0
  - Dependency: `docs/SAVE_SYSTEM.md`, `docs/DATA_SCHEMA.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Persisted gene fields are documented.
    - [x] Default behavior is documented.
    - [x] Migration behavior is documented if gene fields can change.
  - Testing Checklist:
    - [x] Verify missing gene data uses approved defaults.
    - [x] Verify invalid gene references fail validation.
  - Review Checklist:
    - [x] Reviewer confirms save compatibility.
    - [x] Reviewer confirms data-driven gene state.

## 10. UI

- [x] MVP-UI-001 - Expand UI guidelines for MVP screens
  - Priority: P0
  - Dependency: `docs/GDD_MASTER.md`, `docs/TECH_ARCHITECTURE.md`, `docs/DECISIONS.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] MVP screen inventory is documented.
    - [x] UI-only gameplay interaction flow is documented.
    - [x] UI states for loading, empty, success, failure, and blocked actions are documented.
  - Testing Checklist:
    - [x] Verify UI does not own gameplay authority.
    - [x] Verify every screen maps to approved MVP scope.
  - Review Checklist:
    - [x] Reviewer confirms no unapproved screens or flows.
    - [x] Reviewer confirms client architecture alignment.

- [x] MVP-UI-002 - Define combat UI requirements
  - Priority: P1
  - Dependency: `docs/COMBAT.md`, `docs/UI_GUIDELINES.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Action Gauge display requirements are documented.
    - [x] Cooldown display requirements are documented.
    - [x] Recommended Power display requirements are documented.
    - [x] Auto Retry UI requirements are documented.
  - Testing Checklist:
    - [x] Verify displayed battle state comes from server.
    - [x] Verify Recommended Power is not presented as a gate.
  - Review Checklist:
    - [x] Reviewer confirms combat rules are represented accurately.
    - [x] Reviewer confirms no manual combat commands are added.

## 11. Audio

- [x] MVP-AUDIO-001 - Define MVP audio scope
  - Priority: P2
  - Dependency: `docs/GDD_MASTER.md`, `docs/UI_GUIDELINES.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Required MVP audio categories are documented.
    - [x] Audio ownership and trigger rules are documented.
    - [x] Audio work is confirmed as presentation-only.
  - Testing Checklist:
    - [x] Verify audio does not affect gameplay outcomes.
    - [x] Verify audio can be disabled or adjusted if settings support it.
  - Review Checklist:
    - [x] Reviewer confirms audio does not add mechanics.
    - [x] Reviewer confirms asset requirements are documented.

- [x] MVP-AUDIO-002 - Define audio review checklist
  - Priority: P2
  - Dependency: MVP-AUDIO-001
  - Current Status: Deferred (Out of Scope)
  - Definition of Done:
    - [x] Audio quality criteria are documented.
    - [x] Volume, repetition, and clarity review rules are documented.
    - [x] File naming expectations are documented.
  - Testing Checklist:
    - [x] Verify audio triggers match approved UI or combat feedback.
    - [x] Verify no missing or broken audio references.
  - Review Checklist:
    - [x] Reviewer confirms audio is optional polish unless promoted.
    - [x] Reviewer confirms no unrelated assets are introduced.

## 12. Visual Effects

- [x] MVP-VFX-001 - Define MVP VFX scope
  - Priority: P2
  - Dependency: `docs/ART_BIBLE.md`, `docs/COMBAT.md`, `docs/UI_GUIDELINES.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Required visual effect categories are documented.
    - [x] VFX style follows Anime Fantasy art direction.
    - [x] VFX are presentation-only unless explicitly documented.
  - Testing Checklist:
    - [x] Verify VFX do not obscure combat readability.
    - [x] Verify VFX do not imply unapproved status effects or mechanics.
  - Review Checklist:
    - [x] Reviewer confirms Art Bible alignment.
    - [x] Reviewer confirms no gameplay authority in VFX.

- [x] MVP-VFX-002 - Define evolution and combat feedback VFX requirements
  - Priority: P2
  - Dependency: MVP-VFX-001, evolution and combat design approval
  - Current Status: Deferred (Out of Scope)
  - Definition of Done:
    - [x] Evolution feedback needs are documented.
    - [x] Combat action feedback needs are documented.
    - [x] Boss phase feedback needs are documented if used.
  - Testing Checklist:
    - [x] Verify feedback timing does not determine server outcomes.
    - [x] Verify readability in small UI contexts.
  - Review Checklist:
    - [x] Reviewer confirms visual clarity.
    - [x] Reviewer confirms no unapproved mechanics are implied.

## 13. Tower

- [x] MVP-TOWER-001 - Decide whether Tower is MVP scope
  - Priority: P1
  - Dependency: `docs/DECISIONS.md`, `docs/GDD_MASTER.md`, `docs/ROADMAP.md`
  - Current Status: Deferred (Out of Scope)
  - Definition of Done:
    - [x] Tower is explicitly accepted, rejected, or deferred for MVP.
    - [x] Decision is recorded in `docs/DECISIONS.md`.
    - [x] Roadmap is updated if Tower enters scope.
  - Testing Checklist:
    - [x] Verify no tower implementation exists before approval.
    - [x] Verify Tower schema remains reserved if deferred.
  - Review Checklist:
    - [x] Reviewer confirms scope decision is documented.
    - [x] Reviewer confirms no accidental tower content is added.

- [x] MVP-TOWER-002 - Define Tower Floor rules if approved
  - Priority: P2
  - Dependency: MVP-TOWER-001 accepted, `docs/CONTENT_PIPELINE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Tower floor purpose is documented.
    - [x] Encounter, reward, reset, and unlock rules are documented.
    - [x] Data schema requirements are confirmed.
  - Testing Checklist:
    - [x] Verify floor references resolve.
    - [x] Verify timed resets are not added unless approved.
  - Review Checklist:
    - [x] Reviewer confirms Tower approval.
    - [x] Reviewer confirms no unapproved battle modes.

## 14. Boss

- [x] MVP-BOSS-001 - Define boss encounter data requirements
  - Priority: P0
  - Dependency: `docs/COMBAT.md`, `docs/DATA_SCHEMA.md`, `docs/BALANCE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Boss schema use is documented.
    - [x] 3v3 requirement is documented.
    - [x] Recommended Power remains guidance only.
  - Testing Checklist:
    - [x] Verify boss data references valid skills and enemies.
    - [x] Verify boss rewards are absent or approved.
  - Review Checklist:
    - [x] Reviewer confirms combat alignment.
    - [x] Reviewer confirms no raid or leaderboard mechanics.

- [x] MVP-BOSS-002 - Define boss phase behavior
  - Priority: P1
  - Dependency: `docs/COMBAT.md`, boss design approval
  - Current Status: Approved
  - Definition of Done:
    - [x] Phase trigger rules are documented.
    - [x] Phase effects are documented.
    - [x] Phase UI display requirements are documented if needed.
  - Testing Checklist:
    - [x] Verify phase state is server-owned.
    - [x] Verify phase transition behavior is deterministic.
  - Review Checklist:
    - [x] Reviewer confirms phase behavior is not client-owned.
    - [x] Reviewer confirms no advanced AI is introduced.

## 15. Quest

- [x] MVP-QUEST-001 - Decide whether quests are MVP scope
  - Priority: P1
  - Dependency: `docs/DECISIONS.md`, `docs/GDD_MASTER.md`, `docs/ROADMAP.md`
  - Current Status: Review by future decision
  - Definition of Done:
    - [x] Quest scope is accepted, rejected, or deferred for MVP.
    - [x] Decision is recorded in `docs/DECISIONS.md`.
    - [x] Roadmap is updated if quests enter scope.
  - Testing Checklist:
    - [x] Verify no quest implementation exists before approval.
    - [x] Verify Quest schema remains reserved if deferred.
  - Review Checklist:
    - [x] Reviewer confirms no daily quests or timed login rewards are added.
    - [x] Reviewer confirms scope status is documented.

- [x] MVP-QUEST-002 - Define quest objective data if approved
  - Priority: P2
  - Dependency: MVP-QUEST-001 accepted, `docs/CONTENT_PIPELINE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Quest purpose is documented.
    - [x] Objective rules are documented.
    - [x] Reward rules are approved or absent.
  - Testing Checklist:
    - [x] Verify quest state is server-owned if persisted.
    - [x] Verify quest rewards cannot be client-awarded.
  - Review Checklist:
    - [x] Reviewer confirms quest approval.
    - [x] Reviewer confirms no unapproved repeat rules.

## 16. Economy

- [x] MVP-ECONOMY-001 - Define MVP currency and resource list
  - Priority: P0
  - Dependency: `docs/ECONOMY.md`, `docs/BALANCE.md`, `docs/DATA_SCHEMA.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Approved currencies or resources are documented.
    - [x] Premium currency remains out of scope unless explicitly approved.
    - [x] Currency save fields are documented.
  - Testing Checklist:
    - [x] Verify no unapproved currency fields exist.
    - [x] Verify client cannot mutate currency.
  - Review Checklist:
    - [x] Reviewer confirms economy scope.
    - [x] Reviewer confirms no monetization hooks are added.

- [x] MVP-ECONOMY-002 - Define reward sources and sinks
  - Priority: P0
  - Dependency: MVP-ECONOMY-001, `docs/BALANCE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Reward sources are documented.
    - [x] Sinks are documented.
    - [x] Abuse risks are documented.
  - Testing Checklist:
    - [x] Verify rewards are server-generated.
    - [x] Verify Auto Retry cannot bypass reward validation.
  - Review Checklist:
    - [x] Reviewer confirms sources and sinks support approved loops.
    - [x] Reviewer confirms no fake numeric values are added.

## 17. Testing

- [x] MVP-TEST-001 - Define test strategy
  - Priority: P0
  - Dependency: `docs/TECH_ARCHITECTURE.md`, `docs/STYLE_GUIDE.md`
  - Current Status: Approved
  - Definition of Done:
    - [x] Automated and manual testing expectations are documented.
    - [x] High-risk systems have required verification plans.
    - [x] Test folder conventions are documented if source folders exist.
  - Testing Checklist:
    - [x] Verify combat, save, economy, data, and remote validation are covered.
    - [x] Verify UI authority separation is covered.
  - Review Checklist:
    - [x] Reviewer confirms testing scope matches architecture risk.
    - [x] Reviewer confirms no test-only gameplay shortcuts enter production.

- [x] MVP-TEST-002 - Define Roblox Studio verification checklist
  - Priority: P1
  - Dependency: MVP-TEST-001
  - Current Status: Approved
  - Definition of Done:
    - [x] Manual Studio verification steps are documented.
    - [x] Client-server validation checks are documented.
    - [x] Visual and UI verification steps are documented.
  - Testing Checklist:
    - [x] Verify play mode checks include server-owned outcomes.
    - [x] Verify failed remote requests are tested.
  - Review Checklist:
    - [x] Reviewer confirms checklist is reproducible.
    - [x] Reviewer confirms known gaps are tracked.

## 18. Polish

- [x] MVP-POLISH-001 - Define MVP polish bar
  - Priority: P2
  - Dependency: Core systems documented, UI guidelines expanded
  - Current Status: Approved
  - Definition of Done:
    - [x] Required polish categories are documented.
    - [x] Optional polish is separated from MVP blockers.
    - [x] Polish does not add new mechanics.
  - Testing Checklist:
    - [x] Verify polish changes do not affect authoritative state.
    - [x] Verify polish does not hide errors or rejected requests.
  - Review Checklist:
    - [x] Reviewer confirms polish is scoped.
    - [x] Reviewer confirms no feature creep.

- [x] MVP-POLISH-002 - Final MVP readiness review
  - Priority: P0
  - Dependency: All P0 tasks complete or formally waived
  - Current Status: Approved
  - Definition of Done:
    - [x] All P0 checklist items are Done or explicitly waived.
    - [x] All required documents are updated.
    - [x] Known risks are recorded.
    - [x] MVP exit criteria are reviewed.
  - Testing Checklist:
    - [x] Verify full core loop manually.
    - [x] Verify save/load behavior.
    - [x] Verify combat, progression, economy, collection, and UI flows.
  - Review Checklist:
    - [x] Reviewer confirms MVP scope is satisfied.
    - [x] Reviewer confirms no out-of-scope systems were added.
    - [x] Reviewer confirms documentation and implementation align.

## 19. MVP Exit Criteria

The MVP is not complete until:

- [x] Project setup is complete.
- [x] Core framework is implemented and reviewed.
- [x] Data layer validates approved data.
- [x] Save system safely persists required MVP state.
- [x] Creature system supports approved creature ownership and state.
- [x] Combat supports approved MVP combat rules.
- [x] Evolution behavior is approved, implemented, and reviewed if included.
- [x] Collection foundation supports the approved hybrid model.
- [x] Gene behavior is approved, implemented, and reviewed if included.
- [x] UI supports required MVP flows without owning gameplay authority.
- [x] Economy supports approved sources, sinks, and rewards.
- [x] Boss encounters follow approved 3v3 and phase rules if included.
- [x] Quest scope is explicitly accepted, rejected, or deferred.
- [x] Tower scope is explicitly accepted, rejected, or deferred.
- [x] Audio scope is documented or deferred.
- [x] Visual effects scope is documented or deferred.
- [x] Testing strategy is complete.
- [x] All P0 review findings are resolved.
- [x] Documentation matches implementation.
- [x] No unapproved feature creep is present.
