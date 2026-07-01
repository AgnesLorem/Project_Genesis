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
- Current RC Status: Blocked; do not call Release Candidate yet.
- Grand Check: Passed on rerun in Roblox Studio Play Mode. Coverage was split into framework/config/dependency, creature/economy/progression, combat/world/boss/game-mode, client UI, and post-cleanup audit batches covering MVP-001 through MVP-019.
- Dependency Audit: Passed for source/config/test files and Studio Edit-mode DataModel after the `FrameworkSmoke` require path fix. No `*_Clone` modules, no GUID-named modules, no old source require paths, no `restore_generated` requires, and no duplicate ModuleScripts were found in the Studio Edit-mode audit.
- Doc/Task Audit: README, CHANGELOG, KNOWN_ISSUES, and MVP_CHECKLIST were aligned with the release-gate state. MVP-001 through MVP-019 task records remain in `Review`, not `Approved`.
- Deferred/Blocked: `SaveService` remains an in-memory `mockSaves` stub. `DataStoreWrapper` exists, but DataStore-backed save/load integration is not connected to the server lifecycle.
- Scope Guard: No Quest runtime, Tower runtime, reward grant logic, boss phase switching, or gameplay placeholder service is approved by this checklist snapshot.
- Required Before RC: resolve or explicitly accept the save limitation, and record approval or release exception for MVP-001 through MVP-019.

## 1. Project Setup

- [ ] MVP-SETUP-001 - Establish source folder structure
  - Priority: P0
  - Dependency: `docs/TECH_ARCHITECTURE.md`, `docs/STYLE_GUIDE.md`, approval of source folder plan
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Server-only, client-only, shared, data, and test folder responsibilities are documented.
    - [ ] Folder structure does not conflict with existing documentation.
    - [ ] No gameplay implementation is added during setup.
  - Testing Checklist:
    - [ ] Verify folders are present only where approved.
    - [ ] Verify no Lua or Luau gameplay files are created by this task unless separately approved.
  - Review Checklist:
    - [ ] Reviewer confirms architecture alignment.
    - [ ] Reviewer confirms naming follows `docs/STYLE_GUIDE.md`.
    - [ ] Reviewer confirms no unrelated files changed.

- [ ] MVP-SETUP-002 - Create implementation task breakdown
  - Priority: P0
  - Dependency: `docs/GDD_MASTER.md`, `docs/DECISIONS.md`, `docs/CONTENT_PIPELINE.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] MVP tasks are split into reviewable units.
    - [ ] Each task has acceptance criteria.
    - [ ] Each task references required documentation.
  - Testing Checklist:
    - [ ] Verify every task has clear dependencies.
    - [ ] Verify no task implements reserved systems without approval.
  - Review Checklist:
    - [ ] Reviewer confirms task scope is MVP-only.
    - [ ] Reviewer confirms tasks do not introduce feature creep.

## 2. Core Framework

- [ ] MVP-FRAMEWORK-001 - Define service lifecycle pattern
  - Priority: P0
  - Dependency: `docs/TECH_ARCHITECTURE.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Server service startup order is documented.
    - [ ] Service ownership boundaries are documented.
    - [ ] Dependency direction is documented.
  - Testing Checklist:
    - [ ] Verify lifecycle can support save, data, combat, economy, and progression services.
    - [ ] Verify no service depends on client UI.
  - Review Checklist:
    - [ ] Reviewer confirms server authority is preserved.
    - [ ] Reviewer confirms no monolithic manager pattern is introduced.

- [ ] MVP-FRAMEWORK-002 - Define remote contract pattern
  - Priority: P0
  - Dependency: `docs/TECH_ARCHITECTURE.md`, `docs/STYLE_GUIDE.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] RemoteEvent and RemoteFunction naming rules are applied.
    - [ ] Payload documentation format is defined.
    - [ ] Failure response format is defined.
  - Testing Checklist:
    - [ ] Verify remotes preserve server authority.
    - [ ] Verify remote payload validation requirements are documented.
  - Review Checklist:
    - [ ] Reviewer confirms no client-owned authoritative outcome.
    - [ ] Reviewer confirms contract names are specific and reviewable.

## 3. Data Layer

- [ ] MVP-DATA-001 - Implement static data registry plan
  - Priority: P0
  - Dependency: `docs/DATA_SCHEMA.md`, `docs/TECH_ARCHITECTURE.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Static data loading strategy is documented.
    - [ ] Data validation strategy is documented.
    - [ ] Disabled content handling is documented.
  - Testing Checklist:
    - [ ] Verify invalid IDs fail validation.
    - [ ] Verify disabled definitions cannot be used in active content unless allowed.
  - Review Checklist:
    - [ ] Reviewer confirms schemas are followed.
    - [ ] Reviewer confirms no gameplay values are hardcoded.

- [ ] MVP-DATA-002 - Create MVP data authoring checklist
  - Priority: P0
  - Dependency: `docs/CONTENT_PIPELINE.md`, `docs/BALANCE.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Required data fields are listed by content type.
    - [ ] Required `TBD` handling is documented.
    - [ ] Review process for data changes is documented.
  - Testing Checklist:
    - [ ] Verify every MVP data type maps to `docs/DATA_SCHEMA.md`.
    - [ ] Verify reserved content types remain approval-gated.
  - Review Checklist:
    - [ ] Reviewer confirms content pipeline alignment.
    - [ ] Reviewer confirms balance values are not invented.

## 4. Save System

- [ ] MVP-SAVE-001 - Define save lifecycle
  - Priority: P0
  - Dependency: `docs/SAVE_SYSTEM.md`, `docs/DATA_SCHEMA.md`, `docs/TECH_ARCHITECTURE.md`
  - Current Status: Blocked until `docs/SAVE_SYSTEM.md` is expanded
  - Definition of Done:
    - [ ] Load flow is documented.
    - [ ] Save flow is documented.
    - [ ] Failure handling is documented.
    - [ ] Migration policy is documented.
  - Testing Checklist:
    - [ ] Verify missing save data has safe defaults.
    - [ ] Verify invalid save data fails safely.
    - [ ] Verify save version handling is defined.
  - Review Checklist:
    - [ ] Reviewer confirms persistence is server-owned.
    - [ ] Reviewer confirms schema compatibility.

- [ ] MVP-SAVE-002 - Define persisted MVP state
  - Priority: P0
  - Dependency: `docs/DATA_SCHEMA.md`, `docs/SAVE_SYSTEM.md`
  - Current Status: Blocked until save document is expanded
  - Definition of Done:
    - [ ] Player Save fields needed for MVP are listed.
    - [ ] Creature ownership persistence is documented.
    - [ ] Collection, economy, progression, and settings persistence is documented.
  - Testing Checklist:
    - [ ] Verify no runtime-only combat state is persisted unless approved.
    - [ ] Verify client cannot write save data.
  - Review Checklist:
    - [ ] Reviewer confirms save fields are documented before implementation.
    - [ ] Reviewer confirms migration risks are identified.

## 5. Creature System

- [ ] MVP-CREATURE-001 - Define creature runtime model
  - Priority: P0
  - Dependency: `docs/GDD_MASTER.md`, `docs/DATA_SCHEMA.md`, `docs/BALANCE.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Creature identity data is defined.
    - [ ] Creature instance state is defined.
    - [ ] Creature ownership rules are documented.
  - Testing Checklist:
    - [ ] Verify creature IDs are stable.
    - [ ] Verify creature instances reference valid definitions.
  - Review Checklist:
    - [ ] Reviewer confirms no species, rarity, or acquisition mechanics are invented.
    - [ ] Reviewer confirms save implications are documented.

- [ ] MVP-CREATURE-002 - Define creature stat data requirements
  - Priority: P0
  - Dependency: `docs/COMBAT.md`, `docs/DATA_SCHEMA.md`, `docs/BALANCE.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Required combat stats are documented.
    - [ ] Stat placeholders remain `TBD` until approved.
    - [ ] Power contribution is documented as recommendation-only.
  - Testing Checklist:
    - [ ] Verify HP, ATK, DEF, and SPD data requirements are clear.
    - [ ] Verify no fake numeric values are introduced.
  - Review Checklist:
    - [ ] Reviewer confirms combat alignment.
    - [ ] Reviewer confirms data-driven stat ownership.

## 6. Combat

- [ ] MVP-COMBAT-001 - Define combat formula values
  - Priority: P0
  - Dependency: `docs/COMBAT.md`, `docs/BALANCE.md`
  - Current Status: Blocked by unresolved formula placeholders
  - Definition of Done:
    - [ ] Raw damage inputs are approved.
    - [ ] DEF percentage reduction formula is approved.
    - [ ] Rounding and minimum damage rules are approved.
  - Testing Checklist:
    - [ ] Verify formula uses server-owned data.
    - [ ] Verify no critical hits or type advantages are introduced.
  - Review Checklist:
    - [ ] Reviewer confirms simplified MVP formula.
    - [ ] Reviewer confirms values are documented in balance data.

- [ ] MVP-COMBAT-002 - Define Action Gauge behavior
  - Priority: P0
  - Dependency: `docs/COMBAT.md`, `docs/BALANCE.md`
  - Current Status: Blocked by unresolved gauge placeholders
  - Definition of Done:
    - [ ] Gauge threshold is approved.
    - [ ] Gauge fill coefficient is approved.
    - [ ] Gauge reset, overflow, and carryover behavior are documented.
  - Testing Checklist:
    - [ ] Verify higher SPD fills faster than lower SPD.
    - [ ] Verify action order is deterministic or testable.
  - Review Checklist:
    - [ ] Reviewer confirms SPD rules are followed.
    - [ ] Reviewer confirms no extra-turn systems are introduced.

- [ ] MVP-COMBAT-003 - Define auto battle decision rules
  - Priority: P0
  - Dependency: `docs/COMBAT.md`
  - Current Status: Blocked by targeting and priority placeholders
  - Definition of Done:
    - [ ] Player-side skill priority is documented.
    - [ ] Player-side targeting priority is documented.
    - [ ] Enemy targeting and skill priority are documented.
  - Testing Checklist:
    - [ ] Verify battles can resolve without manual commands.
    - [ ] Verify fallback behavior exists when skills are on cooldown.
  - Review Checklist:
    - [ ] Reviewer confirms Auto Battle decision is preserved.
    - [ ] Reviewer confirms no manual combat controls are added.

## 7. Evolution

- [ ] MVP-EVOLUTION-001 - Define evolution requirements
  - Priority: P0
  - Dependency: `docs/GDD_MASTER.md`, `docs/DECISIONS.md`, `docs/BALANCE.md`
  - Current Status: Blocked by unresolved requirements
  - Definition of Done:
    - [ ] Evolution requirement data is documented.
    - [ ] Cost behavior is approved or explicitly absent.
    - [ ] Server validation rules are documented.
  - Testing Checklist:
    - [ ] Verify evolution cannot be triggered by the client alone.
    - [ ] Verify unmet requirements fail safely.
  - Review Checklist:
    - [ ] Reviewer confirms no branching evolution is added.
    - [ ] Reviewer confirms economy implications are reviewed.

- [ ] MVP-EVOLUTION-002 - Define evolution reset behavior
  - Priority: P0
  - Dependency: `docs/DECISIONS.md` DD-026, `docs/SAVE_SYSTEM.md`
  - Current Status: Blocked by unresolved reset target and preserved state
  - Definition of Done:
    - [ ] Reset level target is approved.
    - [ ] Preserved state is documented.
    - [ ] Changed state is documented.
  - Testing Checklist:
    - [ ] Verify creature level reset behavior is deterministic.
    - [ ] Verify saved creature state remains valid after evolution.
  - Review Checklist:
    - [ ] Reviewer confirms reset aligns with decision log.
    - [ ] Reviewer confirms player-facing clarity is planned.

## 8. Collection

- [ ] MVP-COLLECTION-001 - Define hybrid collection rules
  - Priority: P0
  - Dependency: `docs/DECISIONS.md` DD-027, `docs/DATA_SCHEMA.md`
  - Current Status: Blocked by unresolved collection details
  - Definition of Done:
    - [ ] Collection progress rules are documented.
    - [ ] Owned creature state relationship is documented.
    - [ ] Duplicate, evolved, and gene-related behavior is approved or `TBD`.
  - Testing Checklist:
    - [ ] Verify collection state persists correctly.
    - [ ] Verify collection cannot be completed by client-only updates.
  - Review Checklist:
    - [ ] Reviewer confirms hybrid model is preserved.
    - [ ] Reviewer confirms no unapproved collection rewards are added.

- [ ] MVP-COLLECTION-002 - Define collection UI data requirements
  - Priority: P1
  - Dependency: `docs/UI_GUIDELINES.md`, `docs/DATA_SCHEMA.md`
  - Current Status: Blocked until UI guidelines are expanded
  - Definition of Done:
    - [ ] Collection display data is documented.
    - [ ] Visibility rules are documented.
    - [ ] Empty, locked, discovered, and collected states are documented if used.
  - Testing Checklist:
    - [ ] Verify UI displays server-provided collection state.
    - [ ] Verify UI cannot mark collection entries complete.
  - Review Checklist:
    - [ ] Reviewer confirms UI separation from gameplay authority.
    - [ ] Reviewer confirms collection terminology is consistent.

## 9. Gene

- [ ] MVP-GENE-001 - Define gene meaning
  - Priority: P0
  - Dependency: `docs/GDD_MASTER.md`, `docs/DATA_SCHEMA.md`, `docs/BALANCE.md`
  - Current Status: Blocked by unresolved gene design
  - Definition of Done:
    - [ ] Gene purpose is documented.
    - [ ] Gene visibility is documented.
    - [ ] Static, mutable, rolled, or unlocked behavior is approved.
  - Testing Checklist:
    - [ ] Verify gene values are server-owned if mutable.
    - [ ] Verify gene data follows schema.
  - Review Checklist:
    - [ ] Reviewer confirms no inheritance or mutation rules are added without approval.
    - [ ] Reviewer confirms no hidden power spikes are introduced.

- [ ] MVP-GENE-002 - Define gene save behavior
  - Priority: P0
  - Dependency: `docs/SAVE_SYSTEM.md`, `docs/DATA_SCHEMA.md`
  - Current Status: Blocked until gene meaning and save system are defined
  - Definition of Done:
    - [ ] Persisted gene fields are documented.
    - [ ] Default behavior is documented.
    - [ ] Migration behavior is documented if gene fields can change.
  - Testing Checklist:
    - [ ] Verify missing gene data uses approved defaults.
    - [ ] Verify invalid gene references fail validation.
  - Review Checklist:
    - [ ] Reviewer confirms save compatibility.
    - [ ] Reviewer confirms data-driven gene state.

## 10. UI

- [ ] MVP-UI-001 - Expand UI guidelines for MVP screens
  - Priority: P0
  - Dependency: `docs/GDD_MASTER.md`, `docs/TECH_ARCHITECTURE.md`, `docs/DECISIONS.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] MVP screen inventory is documented.
    - [ ] UI-only gameplay interaction flow is documented.
    - [ ] UI states for loading, empty, success, failure, and blocked actions are documented.
  - Testing Checklist:
    - [ ] Verify UI does not own gameplay authority.
    - [ ] Verify every screen maps to approved MVP scope.
  - Review Checklist:
    - [ ] Reviewer confirms no unapproved screens or flows.
    - [ ] Reviewer confirms client architecture alignment.

- [ ] MVP-UI-002 - Define combat UI requirements
  - Priority: P1
  - Dependency: `docs/COMBAT.md`, `docs/UI_GUIDELINES.md`
  - Current Status: Blocked until UI guidelines are expanded
  - Definition of Done:
    - [ ] Action Gauge display requirements are documented.
    - [ ] Cooldown display requirements are documented.
    - [ ] Recommended Power display requirements are documented.
    - [ ] Auto Retry UI requirements are documented.
  - Testing Checklist:
    - [ ] Verify displayed battle state comes from server.
    - [ ] Verify Recommended Power is not presented as a gate.
  - Review Checklist:
    - [ ] Reviewer confirms combat rules are represented accurately.
    - [ ] Reviewer confirms no manual combat commands are added.

## 11. Audio

- [ ] MVP-AUDIO-001 - Define MVP audio scope
  - Priority: P2
  - Dependency: `docs/GDD_MASTER.md`, `docs/UI_GUIDELINES.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Required MVP audio categories are documented.
    - [ ] Audio ownership and trigger rules are documented.
    - [ ] Audio work is confirmed as presentation-only.
  - Testing Checklist:
    - [ ] Verify audio does not affect gameplay outcomes.
    - [ ] Verify audio can be disabled or adjusted if settings support it.
  - Review Checklist:
    - [ ] Reviewer confirms audio does not add mechanics.
    - [ ] Reviewer confirms asset requirements are documented.

- [ ] MVP-AUDIO-002 - Define audio review checklist
  - Priority: P2
  - Dependency: MVP-AUDIO-001
  - Current Status: Blocked until audio scope is defined
  - Definition of Done:
    - [ ] Audio quality criteria are documented.
    - [ ] Volume, repetition, and clarity review rules are documented.
    - [ ] File naming expectations are documented.
  - Testing Checklist:
    - [ ] Verify audio triggers match approved UI or combat feedback.
    - [ ] Verify no missing or broken audio references.
  - Review Checklist:
    - [ ] Reviewer confirms audio is optional polish unless promoted.
    - [ ] Reviewer confirms no unrelated assets are introduced.

## 12. Visual Effects

- [ ] MVP-VFX-001 - Define MVP VFX scope
  - Priority: P2
  - Dependency: `docs/ART_BIBLE.md`, `docs/COMBAT.md`, `docs/UI_GUIDELINES.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Required visual effect categories are documented.
    - [ ] VFX style follows Anime Fantasy art direction.
    - [ ] VFX are presentation-only unless explicitly documented.
  - Testing Checklist:
    - [ ] Verify VFX do not obscure combat readability.
    - [ ] Verify VFX do not imply unapproved status effects or mechanics.
  - Review Checklist:
    - [ ] Reviewer confirms Art Bible alignment.
    - [ ] Reviewer confirms no gameplay authority in VFX.

- [ ] MVP-VFX-002 - Define evolution and combat feedback VFX requirements
  - Priority: P2
  - Dependency: MVP-VFX-001, evolution and combat design approval
  - Current Status: Blocked until evolution and combat details are resolved
  - Definition of Done:
    - [ ] Evolution feedback needs are documented.
    - [ ] Combat action feedback needs are documented.
    - [ ] Boss phase feedback needs are documented if used.
  - Testing Checklist:
    - [ ] Verify feedback timing does not determine server outcomes.
    - [ ] Verify readability in small UI contexts.
  - Review Checklist:
    - [ ] Reviewer confirms visual clarity.
    - [ ] Reviewer confirms no unapproved mechanics are implied.

## 13. Tower

- [ ] MVP-TOWER-001 - Decide whether Tower is MVP scope
  - Priority: P1
  - Dependency: `docs/DECISIONS.md`, `docs/GDD_MASTER.md`, `docs/ROADMAP.md`
  - Current Status: Blocked by future decision
  - Definition of Done:
    - [ ] Tower is explicitly accepted, rejected, or deferred for MVP.
    - [ ] Decision is recorded in `docs/DECISIONS.md`.
    - [ ] Roadmap is updated if Tower enters scope.
  - Testing Checklist:
    - [ ] Verify no tower implementation exists before approval.
    - [ ] Verify Tower schema remains reserved if deferred.
  - Review Checklist:
    - [ ] Reviewer confirms scope decision is documented.
    - [ ] Reviewer confirms no accidental tower content is added.

- [ ] MVP-TOWER-002 - Define Tower Floor rules if approved
  - Priority: P2
  - Dependency: MVP-TOWER-001 accepted, `docs/CONTENT_PIPELINE.md`
  - Current Status: Blocked
  - Definition of Done:
    - [ ] Tower floor purpose is documented.
    - [ ] Encounter, reward, reset, and unlock rules are documented.
    - [ ] Data schema requirements are confirmed.
  - Testing Checklist:
    - [ ] Verify floor references resolve.
    - [ ] Verify timed resets are not added unless approved.
  - Review Checklist:
    - [ ] Reviewer confirms Tower approval.
    - [ ] Reviewer confirms no unapproved battle modes.

## 14. Boss

- [ ] MVP-BOSS-001 - Define boss encounter data requirements
  - Priority: P0
  - Dependency: `docs/COMBAT.md`, `docs/DATA_SCHEMA.md`, `docs/BALANCE.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Boss schema use is documented.
    - [ ] 3v3 requirement is documented.
    - [ ] Recommended Power remains guidance only.
  - Testing Checklist:
    - [ ] Verify boss data references valid skills and enemies.
    - [ ] Verify boss rewards are absent or approved.
  - Review Checklist:
    - [ ] Reviewer confirms combat alignment.
    - [ ] Reviewer confirms no raid or leaderboard mechanics.

- [ ] MVP-BOSS-002 - Define boss phase behavior
  - Priority: P1
  - Dependency: `docs/COMBAT.md`, boss design approval
  - Current Status: Blocked by unresolved phase placeholders
  - Definition of Done:
    - [ ] Phase trigger rules are documented.
    - [ ] Phase effects are documented.
    - [ ] Phase UI display requirements are documented if needed.
  - Testing Checklist:
    - [ ] Verify phase state is server-owned.
    - [ ] Verify phase transition behavior is deterministic.
  - Review Checklist:
    - [ ] Reviewer confirms phase behavior is not client-owned.
    - [ ] Reviewer confirms no advanced AI is introduced.

## 15. Quest

- [ ] MVP-QUEST-001 - Decide whether quests are MVP scope
  - Priority: P1
  - Dependency: `docs/DECISIONS.md`, `docs/GDD_MASTER.md`, `docs/ROADMAP.md`
  - Current Status: Blocked by future decision
  - Definition of Done:
    - [ ] Quest scope is accepted, rejected, or deferred for MVP.
    - [ ] Decision is recorded in `docs/DECISIONS.md`.
    - [ ] Roadmap is updated if quests enter scope.
  - Testing Checklist:
    - [ ] Verify no quest implementation exists before approval.
    - [ ] Verify Quest schema remains reserved if deferred.
  - Review Checklist:
    - [ ] Reviewer confirms no daily quests or timed login rewards are added.
    - [ ] Reviewer confirms scope status is documented.

- [ ] MVP-QUEST-002 - Define quest objective data if approved
  - Priority: P2
  - Dependency: MVP-QUEST-001 accepted, `docs/CONTENT_PIPELINE.md`
  - Current Status: Blocked
  - Definition of Done:
    - [ ] Quest purpose is documented.
    - [ ] Objective rules are documented.
    - [ ] Reward rules are approved or absent.
  - Testing Checklist:
    - [ ] Verify quest state is server-owned if persisted.
    - [ ] Verify quest rewards cannot be client-awarded.
  - Review Checklist:
    - [ ] Reviewer confirms quest approval.
    - [ ] Reviewer confirms no unapproved repeat rules.

## 16. Economy

- [ ] MVP-ECONOMY-001 - Define MVP currency and resource list
  - Priority: P0
  - Dependency: `docs/ECONOMY.md`, `docs/BALANCE.md`, `docs/DATA_SCHEMA.md`
  - Current Status: Blocked until `docs/ECONOMY.md` is expanded
  - Definition of Done:
    - [ ] Approved currencies or resources are documented.
    - [ ] Premium currency remains out of scope unless explicitly approved.
    - [ ] Currency save fields are documented.
  - Testing Checklist:
    - [ ] Verify no unapproved currency fields exist.
    - [ ] Verify client cannot mutate currency.
  - Review Checklist:
    - [ ] Reviewer confirms economy scope.
    - [ ] Reviewer confirms no monetization hooks are added.

- [ ] MVP-ECONOMY-002 - Define reward sources and sinks
  - Priority: P0
  - Dependency: MVP-ECONOMY-001, `docs/BALANCE.md`
  - Current Status: Blocked
  - Definition of Done:
    - [ ] Reward sources are documented.
    - [ ] Sinks are documented.
    - [ ] Abuse risks are documented.
  - Testing Checklist:
    - [ ] Verify rewards are server-generated.
    - [ ] Verify Auto Retry cannot bypass reward validation.
  - Review Checklist:
    - [ ] Reviewer confirms sources and sinks support approved loops.
    - [ ] Reviewer confirms no fake numeric values are added.

## 17. Testing

- [ ] MVP-TEST-001 - Define test strategy
  - Priority: P0
  - Dependency: `docs/TECH_ARCHITECTURE.md`, `docs/STYLE_GUIDE.md`
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Automated and manual testing expectations are documented.
    - [ ] High-risk systems have required verification plans.
    - [ ] Test folder conventions are documented if source folders exist.
  - Testing Checklist:
    - [ ] Verify combat, save, economy, data, and remote validation are covered.
    - [ ] Verify UI authority separation is covered.
  - Review Checklist:
    - [ ] Reviewer confirms testing scope matches architecture risk.
    - [ ] Reviewer confirms no test-only gameplay shortcuts enter production.

- [ ] MVP-TEST-002 - Define Roblox Studio verification checklist
  - Priority: P1
  - Dependency: MVP-TEST-001
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Manual Studio verification steps are documented.
    - [ ] Client-server validation checks are documented.
    - [ ] Visual and UI verification steps are documented.
  - Testing Checklist:
    - [ ] Verify play mode checks include server-owned outcomes.
    - [ ] Verify failed remote requests are tested.
  - Review Checklist:
    - [ ] Reviewer confirms checklist is reproducible.
    - [ ] Reviewer confirms known gaps are tracked.

## 18. Polish

- [ ] MVP-POLISH-001 - Define MVP polish bar
  - Priority: P2
  - Dependency: Core systems documented, UI guidelines expanded
  - Current Status: Not Started
  - Definition of Done:
    - [ ] Required polish categories are documented.
    - [ ] Optional polish is separated from MVP blockers.
    - [ ] Polish does not add new mechanics.
  - Testing Checklist:
    - [ ] Verify polish changes do not affect authoritative state.
    - [ ] Verify polish does not hide errors or rejected requests.
  - Review Checklist:
    - [ ] Reviewer confirms polish is scoped.
    - [ ] Reviewer confirms no feature creep.

- [ ] MVP-POLISH-002 - Final MVP readiness review
  - Priority: P0
  - Dependency: All P0 tasks complete or formally waived
  - Current Status: Blocked
  - Definition of Done:
    - [ ] All P0 checklist items are Done or explicitly waived.
    - [ ] All required documents are updated.
    - [ ] Known risks are recorded.
    - [ ] MVP exit criteria are reviewed.
  - Testing Checklist:
    - [ ] Verify full core loop manually.
    - [ ] Verify save/load behavior.
    - [ ] Verify combat, progression, economy, collection, and UI flows.
  - Review Checklist:
    - [ ] Reviewer confirms MVP scope is satisfied.
    - [ ] Reviewer confirms no out-of-scope systems were added.
    - [ ] Reviewer confirms documentation and implementation align.

## 19. MVP Exit Criteria

The MVP is not complete until:

- [ ] Project setup is complete.
- [ ] Core framework is implemented and reviewed.
- [ ] Data layer validates approved data.
- [ ] Save system safely persists required MVP state.
- [ ] Creature system supports approved creature ownership and state.
- [ ] Combat supports approved MVP combat rules.
- [ ] Evolution behavior is approved, implemented, and reviewed if included.
- [ ] Collection foundation supports the approved hybrid model.
- [ ] Gene behavior is approved, implemented, and reviewed if included.
- [ ] UI supports required MVP flows without owning gameplay authority.
- [ ] Economy supports approved sources, sinks, and rewards.
- [ ] Boss encounters follow approved 3v3 and phase rules if included.
- [ ] Quest scope is explicitly accepted, rejected, or deferred.
- [ ] Tower scope is explicitly accepted, rejected, or deferred.
- [ ] Audio scope is documented or deferred.
- [ ] Visual effects scope is documented or deferred.
- [ ] Testing strategy is complete.
- [ ] All P0 review findings are resolved.
- [ ] Documentation matches implementation.
- [ ] No unapproved feature creep is present.
