# Known Issues

## Purpose

This document tracks unresolved design and technical issues for Project Genesis.

This document is not a bug tracker.

It stores questions that still require design decisions, technical decisions, production approval, or documentation updates before implementation can safely proceed.

## Status

- Status: Active Draft
- Scope: Unresolved design and technical decision tracking
- Owner: Production
- Last Updated: 2026-06-29
- Review Cadence: Before sprint planning, before implementation of blocked systems, and after major design decisions
- Authority Level: Open issue tracking reference

## Priority Legend

- P0: Blocks MVP foundation or high-risk implementation.
- P1: Blocks important MVP feature definition or review.
- P2: Blocks polish, future scope, or non-critical production clarity.

## Status Legend

- Open: Requires a decision.
- Blocked: Cannot progress until another document, decision, or dependency is resolved.
- In Review: Proposed answer exists and needs approval.
- Resolved: Decision is made and documented in the owning source.

## Table of Contents

- [1. Gameplay](#1-gameplay)
- [2. Combat](#2-combat)
- [3. Economy](#3-economy)
- [4. UI](#4-ui)
- [5. Art](#5-art)
- [6. Technical](#6-technical)
- [7. Balancing](#7-balancing)
- [8. Future Systems](#8-future-systems)
- [9. Release Gate](#9-release-gate)
- [10. Resolution Process](#10-resolution-process)

## 1. Gameplay

### KI-GAMEPLAY-001 - Exact MVP Progression Endpoint

Description

The final MVP progression endpoint is not defined.

Current Status

Open.

Possible Solutions

1. Define a final world milestone.
2. Define a final boss milestone.
3. Define a collection milestone.
4. Define a temporary MVP validation endpoint without final content naming.

Owner

Design / Production.

Priority

P0.

Resolution Notes

Must be resolved in `docs/GDD_MASTER.md`, `docs/PROGRESSION.md`, and `docs/ROADMAP.md` before MVP completion criteria can be final.

### KI-GAMEPLAY-002 - Evolution Reset Details

Description

Evolution is approved to reset creature level, but exact reset target, preserved state, changed state, requirements, and save behavior are unresolved.

Current Status

Open.

Possible Solutions

1. Reset to a documented base level.
2. Reset to a progression-dependent level.
3. Preserve selected non-level state while resetting level only.
4. Defer implementation until evolution requirements are fully defined.

Owner

Design / Data / Save.

Priority

P0.

Resolution Notes

Must align with `docs/DECISIONS.md` DD-026, `docs/BALANCE.md`, `docs/DATA_SCHEMA.md`, and `docs/SAVE_SYSTEM.md`.

### KI-GAMEPLAY-003 - Hybrid Collection Rules

Description

Hybrid Collection is approved, but the exact relationship between collection progress, owned creature state, duplicates, evolved forms, and gene-related collection behavior is unresolved.

Current Status

Open.

Possible Solutions

1. Track discovered creature definitions plus owned instances.
2. Track collected creature forms separately from owned instances.
3. Track evolved forms as collection entries only when approved.
4. Defer duplicate and gene-related collection behavior.

Owner

Design / Data / UI.

Priority

P0.

Resolution Notes

Must be resolved before collection implementation and must not imply unapproved collection rewards.

### KI-GAMEPLAY-004 - Gene System Meaning

Description

Genes are an MVP system category, but what a gene represents and how it affects creature identity or power is unresolved.

Current Status

Open.

Possible Solutions

1. Treat genes as visible descriptive creature traits.
2. Treat genes as hidden or revealed identity data.
3. Treat genes as non-combat metadata for MVP.
4. Defer functional gene effects until after MVP.

Owner

Design / Data / Balance.

Priority

P0.

Resolution Notes

Gene inheritance, mutation, rarity rules, and stat modifiers remain unapproved until explicitly decided.

## 2. Combat

### KI-COMBAT-001 - Damage Formula

Description

MVP damage is simplified and DEF reduces damage by percentage, but exact raw damage inputs, DEF formula, rounding, minimum damage, and variance rules are unresolved.

Current Status

Open.

Possible Solutions

1. Use a minimal ATK-based raw damage formula.
2. Use skill-defined base damage plus attacker stat.
3. Use an approved coefficient table.
4. Keep all formula values `TBD` until a balance pass.

Owner

Combat Design / Balance.

Priority

P0.

Resolution Notes

Must be resolved in `docs/COMBAT.md` and `docs/BALANCE.md` before combat implementation.

### KI-COMBAT-002 - Action Gauge Constants

Description

SPD fills the Action Gauge, but gauge threshold, fill coefficient, simulation step size, overflow, carryover, and reset behavior are unresolved.

Current Status

Open.

Possible Solutions

1. Fixed threshold with full reset after action.
2. Fixed threshold with overflow carryover.
3. Step-based gauge update.
4. Tick-based gauge update.

Owner

Combat Design / Technical.

Priority

P0.

Resolution Notes

Must preserve the approved SPD Action Gauge decision and avoid adding unapproved turn manipulation systems.

### KI-COMBAT-003 - Auto Battle Targeting and Skill Priority

Description

Combat is auto battle, but player-side and enemy-side targeting, skill priority, tie-breaking, and fallback action behavior are unresolved.

Current Status

Open.

Possible Solutions

1. Fixed priority order.
2. Lowest-health target rule.
3. First-valid target rule.
4. Skill priority table per unit.

Owner

Combat Design / Technical.

Priority

P0.

Resolution Notes

Must be simple, deterministic or testable, and server-owned.

### KI-COMBAT-004 - Boss Phase Behavior

Description

Bosses may have one or multiple phases, but phase triggers, phase effects, phase count, cooldown behavior across phases, and UI display requirements are unresolved.

Current Status

Open.

Possible Solutions

1. Trigger phases by boss HP thresholds.
2. Trigger phases by defeated phase units.
3. Use single-phase bosses for MVP.
4. Allow phase data only where explicitly defined.

Owner

Combat Design / Boss Design / UI.

Priority

P1.

Resolution Notes

Must remain server-owned and must not introduce raid, leaderboard, or advanced AI systems.

MVP-008 implementation note: boss `phaseIds` are schema-validated only. Runtime phase switching, phase triggers, phase effects, and phase display remain unimplemented until this issue is resolved.

## 3. Economy

### KI-ECONOMY-001 - Currency List

Description

The MVP economy requires approved currencies or resources, but no final currency list is defined.

Current Status

Blocked until `docs/ECONOMY.md` is expanded.

Possible Solutions

1. Define one MVP soft currency.
2. Define one or more non-premium resources.
3. Defer nonessential currencies until after MVP.
4. Keep all economy entries as `TBD` until reward loops are approved.

Owner

Economy Design.

Priority

P0.

Resolution Notes

Premium currency and monetization remain out of scope.

### KI-ECONOMY-002 - Reward Sources and Sinks

Description

Reward sources, reward amounts, cost sinks, caps, and repeat reward behavior are unresolved.

Current Status

Open.

Possible Solutions

1. Combat-only source for MVP.
2. Boss source plus Story source.
3. Minimal sink tied to approved progression.
4. No sinks until economy purpose is defined.

Owner

Economy Design / Balance.

Priority

P0.

Resolution Notes

Must account for Auto Retry and server-authoritative reward validation.

### KI-ECONOMY-003 - Collection Rewards

Description

Collection rewards are not approved in detail, but collection bonus philosophy is tracked as a future balance area.

Current Status

Open.

Possible Solutions

1. No collection rewards for MVP.
2. Non-power recognition only.
3. Modest economy reward after approval.
4. Defer until collection rules are validated.

Owner

Design / Economy / Collection.

Priority

P1.

Resolution Notes

Must avoid creating hidden mandatory power through collection completion.

## 4. UI

### KI-UI-001 - MVP Screen Inventory

Description

The MVP UI screen inventory is not defined.

Current Status

Blocked until `docs/UI_GUIDELINES.md` is expanded.

Possible Solutions

1. Define screens around core loop only.
2. Define separate screens for creature, combat, collection, and progression.
3. Define a minimal UI flow for MVP validation.
4. Defer non-core screens.

Owner

UI Design / Production.

Priority

P0.

Resolution Notes

Must preserve UI-only gameplay interaction and avoid adding unapproved screens.

### KI-UI-002 - Combat UI Display Rules

Description

Combat UI needs to display Action Gauge, cooldowns, health, Recommended Power, Auto Retry, and boss phases if used, but exact display rules are unresolved.

Current Status

Open.

Possible Solutions

1. Minimal combat status panel.
2. Timeline-style action gauge display.
3. Compact creature card display.
4. Defer advanced display until combat formulas are resolved.

Owner

UI Design / Combat Design.

Priority

P1.

Resolution Notes

UI must display server-provided state and must not resolve combat.

### KI-UI-003 - Scientist Fantasy Expression

Description

Scientist fantasy is accepted, but exact expression in UI copy, onboarding, labels, and presentation is unresolved.

Current Status

Open.

Possible Solutions

1. Use light research terminology in UI labels.
2. Use scientist framing only in onboarding.
3. Use collection analysis language.
4. Keep MVP copy neutral until UI guidelines are expanded.

Owner

UI Design / Narrative Direction.

Priority

P1.

Resolution Notes

Must not imply unapproved lab, crafting, mutation, or experimentation mechanics.

## 5. Art

### KI-ART-001 - Final Asset Aspect Ratios

Description

Final image aspect ratios for UI use cases are unresolved.

Current Status

Open.

Possible Solutions

1. Define portrait ratio for card-style illustrations.
2. Define square ratio for collection icons.
3. Define separate hero image ratio if needed.
4. Delay final ratios until UI screen inventory is defined.

Owner

Art Direction / UI Design.

Priority

P1.

Resolution Notes

Must align with `docs/ART_BIBLE.md` and UI layout decisions.

### KI-ART-002 - Card Frame and Cropping Rules

Description

Card-style illustration rules exist, but final card frame dimensions and safe zones are unresolved.

Current Status

Open.

Possible Solutions

1. Define a standard card-safe zone.
2. Define separate safe zones for portrait and square assets.
3. Keep all generated art frame-free until UI frames are designed.

Owner

Art Direction / UI Design.

Priority

P1.

Resolution Notes

Card illustration rules do not approve a gameplay card system.

### KI-ART-003 - Asset Naming and Storage Workflow

Description

The final asset naming, metadata, prompt storage, and review workflow are unresolved.

Current Status

Open.

Possible Solutions

1. Store approved prompts beside asset metadata.
2. Store prompts in `prompts/`.
3. Store asset review notes in `reviews/`.
4. Define a dedicated asset manifest later.

Owner

Art Direction / Production.

Priority

P2.

Resolution Notes

Must support auditing AI-generated artwork and rejected prompt patterns.

## 6. Technical

### KI-TECH-001 - Source Folder Structure

Description

Final source folder structure is not defined.

Current Status

Open.

Possible Solutions

1. Define server, client, shared, data, and tests folders.
2. Defer source folders until first implementation task.
3. Choose a Roblox project structure after framework decision.

Owner

Technical Direction.

Priority

P0.

Resolution Notes

Must align with `docs/TECH_ARCHITECTURE.md` and `docs/STYLE_GUIDE.md`.

### KI-TECH-002 - Framework or No-Framework Decision

Description

The final Roblox framework or no-framework decision is unresolved.

Current Status

Open.

Possible Solutions

1. Use no framework for MVP.
2. Adopt a lightweight service/controller pattern without external framework.
3. Adopt a Roblox framework after review.
4. Defer until source architecture task.

Owner

Technical Direction.

Priority

P0.

Resolution Notes

Any framework choice must support server authority, modular systems, and AI-assisted maintainability.

### KI-TECH-003 - Save System Design

Description

Save lifecycle, load flow, save flow, failure handling, timestamp format, and migration policy are unresolved.

Current Status

Blocked until `docs/SAVE_SYSTEM.md` is expanded.

Possible Solutions

1. Define conservative MVP save lifecycle.
2. Define versioned save migration policy before implementation.
3. Defer persistence implementation until save doc is complete.

Owner

Technical Direction / Data.

Priority

P0.

Resolution Notes

Client must never write save data directly.

### KI-TECH-004 - Remote Contract Naming and Payload Format

Description

Remote naming guidance exists, but exact remote registry format, payload format, and failure response format are unresolved.

Current Status

Open.

Possible Solutions

1. Define a remote contract table in documentation.
2. Define one contract section per feature document.
3. Define a shared contract registry once source folders exist.

Owner

Technical Direction.

Priority

P1.

Resolution Notes

Must preserve server authority and validation.

## 7. Balancing

### KI-BALANCE-001 - Progression Curve

Description

Level curves, XP values, unlock thresholds, expected repeat count, and pacing targets are unresolved.

Current Status

Open.

Possible Solutions

1. Define placeholder curve for MVP testing only.
2. Define target pacing first, then values.
3. Defer numbers until core loop prototype is reviewable.

Owner

Balance / Progression Design.

Priority

P0.

Resolution Notes

Must be resolved in `docs/BALANCE.md` and `docs/PROGRESSION.md` before final tuning.

### KI-BALANCE-002 - Recommended Power Formula

Description

Recommended Power is approved as guidance only, but the calculation formula and display rules are unresolved.

Current Status

Open.

Possible Solutions

1. Creature-based formula.
2. Team-based formula.
3. Encounter-authored values.
4. Hybrid of authored and calculated values.

Owner

Balance / Combat Design / UI.

Priority

P1.

Resolution Notes

Must never become a hard power gate.

### KI-BALANCE-003 - Boss Difficulty Profile

Description

Target boss difficulty, phase difficulty curve, reward relationship, and retry expectations are unresolved.

Current Status

Open.

Possible Solutions

1. Bosses tuned as clear progression checks.
2. Bosses tuned as optional harder content.
3. Single-phase bosses for early MVP.
4. Multi-phase bosses only after base combat is validated.

Owner

Balance / Combat Design.

Priority

P1.

Resolution Notes

Must account for 3v3 format and Auto Retry.

## 8. Future Systems

### KI-FUTURE-001 - Prestige Enablement

Description

Prestige is acknowledged as a system category, but whether it is enabled in MVP or reserved for future expansion is unresolved.

Current Status

Open.

Possible Solutions

1. Defer prestige entirely.
2. Define prestige only as data-compatible future state.
3. Include a minimal MVP prestige foundation.
4. Reject prestige for MVP and revisit later.

Owner

Design / Production.

Priority

P1.

Resolution Notes

Prestige multipliers remain out of scope unless documented.

### KI-FUTURE-002 - Quest Scope

Description

Quest schema is reserved, but whether quests become MVP objectives or remain future-only is unresolved.

Current Status

Open.

Possible Solutions

1. Defer quests.
2. Use simple non-daily objectives if approved.
3. Keep quests as future schema only.
4. Replace quests with milestone tracking.

Owner

Design / Production.

Priority

P1.

Resolution Notes

Daily quests and timed login rewards are out of scope unless separately approved.

MVP-009 implementation note: Quest remains excluded from approved game mode identifiers and no Quest runtime is implemented.

### KI-FUTURE-003 - Tower Scope

Description

Tower schema is reserved, but Tower content is not approved for MVP by default.

Current Status

Open.

Possible Solutions

1. Defer Tower entirely.
2. Keep Tower as future-compatible data surface only.
3. Approve a minimal Tower only after roadmap review.
4. Reject Tower for MVP and revisit after core loop validation.

Owner

Design / Production.

Priority

P1.

Resolution Notes

Tower must not be implemented before GDD, roadmap, progression, and combat approval.

MVP-009 implementation note: Tower remains excluded from approved game mode identifiers and no Tower runtime is implemented.

### KI-FUTURE-004 - Status Effects Scope

Description

Status Effect schema is reserved, but status effects are not approved for MVP combat.

Current Status

Open.

Possible Solutions

1. Defer status effects.
2. Keep schema disabled for future expansion.
3. Approve limited status effects only after base combat is stable.

Owner

Combat Design / Production.

Priority

P2.

Resolution Notes

Status effects must not be introduced through skill data without combat documentation approval.

### KI-FUTURE-005 - Event Content Scope

Description

Event-driven content is listed as a future expansion idea, but no event content is approved for MVP.

Current Status

Open.

Possible Solutions

1. Defer all events.
2. Keep event support out of MVP implementation.
3. Define future event content only after core loop validation.

Owner

Production.

Priority

P2.

Resolution Notes

This issue concerns player-facing content events, not technical event-driven communication.

### KI-TECH-MVP002-001 - Save Field List Not Finalized

Description

`docs/SAVE_SYSTEM.md` was filled with foundational content during MVP-002, but the exact save field list (which fields make up a player save record) has not been finalized. This blocks the following tasks:

- MVP-SAVE-001: Finalize MVP Save Field List
- MVP-SAVE-002: Default Save Template
- MVP-SAVE-004: Save Mutation API
- MVP-DB-001: Full DataStore integration into server lifecycle

The persistence transport layer (DataStoreWrapper, SaveKeyBuilder, PersistenceReporter) is complete and ready. The integration is blocked on schema, not on infrastructure.

Current Status

Open.

Possible Solutions

1. Define the MVP save field list in `docs/DATA_SCHEMA.md` section 12 (Player Save Schema) and mark MVP-SAVE-001 as In Progress.
2. Accept a minimal save schema for MVP (e.g. only `saveVersion`, `playerId`, `createdAt`, `updatedAt`) and expand incrementally as creature, economy, and progression systems are designed.

Owner

Production / Technical Architecture.

Priority

P0. Blocks all save system integration for MVP.

Resolution Notes

Resolved when `docs/SAVE_SYSTEM.md` save field list is populated and reviewed, and MVP-SAVE-001 is marked Approved.

---

## 9. Release Gate

### KI-RELEASE-001 - MVP-019 Play Mode Grand Check Incomplete

Description

The first MVP-019 Grand Check attempt in Roblox Studio Play Mode timed out after roughly 300 seconds and the Studio session disconnected. The rerun was split into smaller Play Mode batches covering MVP-001 through MVP-019 and passed.

Current Status

Resolved.

Possible Solutions

1. Keep the split-batch Grand Check approach for future release-gate reruns.
2. Promote any future failing check to a specific task or known issue before Release Candidate approval.

Owner

Technical Architecture / QA.

Priority

P0 when open.

Resolution Notes

Resolved on 2026-07-01. The Play Mode Grand Check rerun passed and validation evidence is recorded in the MVP-019 task. This does not approve Release Candidate by itself; MVP-001 through MVP-019 approval and the `SaveService` persistence limitation remain separate release gates.

### KI-RELEASE-002 - MVP-001 Through MVP-019 Review Approval Not Recorded

Description

The MVP-001 through MVP-019 task files currently show `Current Status: Review`. Release Candidate approval requires the dependency tasks to be approved or explicitly accepted by project leadership.

Current Status

Blocked.

Possible Solutions

1. Review and approve each MVP-001 through MVP-019 task.
2. Record leadership acceptance for any task that remains in Review but is permitted for the Release Candidate.
3. Keep MVP-019 blocked until unresolved review concerns are addressed.

Owner

Production / Reviewer.

Priority

P0. Blocks Release Candidate.

Resolution Notes

Resolved when the dependency task approval state is updated or an explicit release exception is recorded.

### KI-RELEASE-003 - SaveService Remains In-Memory Stub

Description

`SaveService` still stores player data in an in-memory `mockSaves` table. `DataStoreWrapper`, `SaveKeyBuilder`, and `PersistenceReporter` exist, but `SaveService` is not integrated with `DataStoreWrapper` or the server save/load lifecycle.

Current Status

Resolved on 2026-07-01.

Possible Solutions

1. Treat in-memory saves as an accepted MVP limitation and record that the Release Candidate has no production persistence.
2. Implement the approved save field list and integrate `SaveService` with `DataStoreWrapper` in a separate save-system task.
3. Block Release Candidate until persistent save/load behavior is implemented and verified.

Owner

Technical Architecture / Production.

Priority

P0 if production persistence is required for Release Candidate; otherwise P1 as an explicit MVP limitation.

Resolution Notes

Resolved on 2026-07-01. SaveService is fully integrated with DataStoreWrapper and successfully saves/loads player profiles dynamically to/from Roblox DataStores.

---

## 10. Resolution Process

To resolve an issue:

1. Identify the owning document.
2. Draft the proposed decision in the owning document.
3. Update `docs/DECISIONS.md` if the decision is permanent.
4. Update `docs/MVP_CHECKLIST.md` if task status changes.
5. Update `docs/BALANCE.md`, `docs/DATA_SCHEMA.md`, or `docs/TECH_ARCHITECTURE.md` if affected.
6. Add review notes in `reviews/` when the issue is substantive.
7. Mark the issue as Resolved only after the decision is documented.

Resolved issues should not be deleted. Keep them for decision history unless project leadership chooses to archive them.
