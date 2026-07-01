# Design Decision Log

## Purpose

This document is the official Design Decision Log for Project Genesis.

It records design decisions approved by the team.

This document is not a design document.

This document is not a GDD.

This document is a permanent decision log.

Every AI assistant must read this file before making implementation decisions.

## Status

- Status: Active Draft
- Owner: Project Leadership
- Last Updated: 2026-06-28
- Review Cadence: Before implementation planning, before major design changes, and before any decision reversal
- Authority Level: Permanent decision record

## Decision Format

Every decision must use this structure:

```text
-------------------------------------

Decision ID

Title

Status
(Accepted / Deprecated / Rejected)

Decision

Reason

Impact

Affected Systems

Date

-------------------------------------
```

## Decision Log

-------------------------------------

Decision ID

DD-001

Title

MVP-First Development

Status

Accepted

Decision

Project Genesis will prioritize the MVP scope before future expansion. MVP systems must prove the core creature progression experience before additional systems are introduced.

Reason

The project needs a stable foundation and clear production focus before expanding into larger content or speculative systems.

Impact

Implementation work must remain tied to MVP-approved systems and task scope.

Affected Systems

GDD, roadmap, tasks, reviews, all implementation planning.

Date

2026-06-28

-------------------------------------

Decision ID

DD-002

Title

No Feature Creep

Status

Accepted

Decision

Unapproved features must not be implemented, scaffolded, balanced, or implied as MVP commitments.

Reason

Project Genesis is AI-assisted and requires strict scope control to prevent accidental expansion by future assistants.

Impact

All new features must be documented, approved, and assigned before implementation.

Affected Systems

GDD, tasks, agents, roadmap, reviews, all feature work.

Date

2026-06-28

-------------------------------------

Decision ID

DD-003

Title

Data-Driven Architecture

Status

Accepted

Decision

Gameplay configuration, combat values, creature definitions, skills, genes, evolution data, economy data, world data, collection data, and save structure must be data-driven.

Reason

Data-driven architecture keeps gameplay values reviewable, scalable, and safe for AI-assisted development.

Impact

Gameplay logic must read approved data instead of hardcoding gameplay values.

Affected Systems

Data schema, combat, economy, progression, creature systems, save system, technical architecture.

Date

2026-06-28

-------------------------------------

Decision ID

DD-004

Title

Server-Authoritative Gameplay

Status

Accepted

Decision

The server owns authoritative gameplay state and outcomes.

Reason

Roblox clients cannot be trusted to determine rewards, combat results, progression, inventory, economy, collection state, evolution, genes, prestige, or save data.

Impact

Clients may request actions and display results, but the server validates and resolves meaningful state changes.

Affected Systems

Combat, economy, progression, collection, creature ownership, save system, networking, UI.

Date

2026-06-28

-------------------------------------

Decision ID

DD-005

Title

Service-Based Backend

Status

Accepted

Decision

Server backend systems will be organized around authoritative services with clear ownership boundaries.

Reason

Service ownership makes responsibilities explicit and reduces hidden coupling between gameplay systems.

Impact

Server systems should expose narrow APIs, validate inputs, and avoid becoming general-purpose managers.

Affected Systems

Technical architecture, server systems, save system, combat, economy, progression.

Date

2026-06-28

-------------------------------------

Decision ID

DD-006

Title

Event-Driven Communication

Status

Accepted

Decision

Project Genesis will use event-driven communication for state changes and notifications where appropriate.

Reason

Event-driven communication supports modular systems and keeps UI updates, gameplay notifications, and service reactions decoupled.

Impact

Events must have documented payloads and must not bypass server validation.

Affected Systems

Technical architecture, networking, server services, client UI, combat state updates.

Date

2026-06-28

-------------------------------------

Decision ID

DD-007

Title

MVC-Inspired Client Architecture

Status

Accepted

Decision

The Roblox client will follow an MVC-inspired architecture.

Reason

Separating client models, views, and controllers keeps presentation logic organized without making the client authoritative.

Impact

Client views display state, controllers coordinate input and requests, and client models represent server-provided state locally.

Affected Systems

Client architecture, UI, networking, presentation systems.

Date

2026-06-28

-------------------------------------

Decision ID

DD-008

Title

Separate Gameplay Logic from UI

Status

Accepted

Decision

Gameplay logic must remain separate from UI logic.

Reason

UI should present and request actions, not own server truth or gameplay rules.

Impact

UI may display combat, economy, progression, collection, gene, evolution, and prestige state, but it must not resolve or mutate authoritative gameplay outcomes.

Affected Systems

UI, client controllers, server services, networking, combat, economy, progression.

Date

2026-06-28

-------------------------------------

Decision ID

DD-009

Title

UI-Only Gameplay Interaction

Status

Accepted

Decision

MVP player interaction is UI-only unless a non-UI interaction model is later documented and approved.

Reason

The MVP focuses on clear creature progression and system validation rather than undocumented movement, action, or world-interaction mechanics.

Impact

Future assistants must not add avatar-action gameplay, manual combat controls, or world interaction mechanics without approval.

Affected Systems

UI, client architecture, combat, world progression, onboarding.

Date

2026-06-28

-------------------------------------

Decision ID

DD-010

Title

Scientist Fantasy

Status

Accepted

Decision

Project Genesis uses a scientist fantasy as an approved thematic framing for the player experience.

Reason

The scientist fantasy supports creature discovery, analysis, collection, progression, and experimentation themes without requiring undocumented mechanics.

Impact

Copy, UI presentation, art direction, and future feature language should stay compatible with this fantasy. This decision does not approve new gameplay systems by itself.

Affected Systems

GDD, UI guidelines, art bible, creature presentation, collection presentation.

Date

2026-06-28

-------------------------------------

Decision ID

DD-011

Title

Anime Fantasy Art Style

Status

Accepted

Decision

Project Genesis uses an Anime Fantasy visual style.

Reason

Anime Fantasy supports collectible creatures, readable silhouettes, magical progression, and a polished Roblox presentation.

Impact

Future art must follow the Art Bible and avoid forbidden styles that break the shared game identity.

Affected Systems

Art Bible, creature art, evolution art, UI presentation, card-style illustrations.

Date

2026-06-28

-------------------------------------

Decision ID

DD-012

Title

AI-Generated Artwork

Status

Accepted

Decision

Project Genesis uses AI-generated illustrations.

Reason

AI-generated artwork enables scalable visual exploration while requiring strict style rules to maintain consistency.

Impact

All generated artwork must follow prompt, negative prompt, consistency, and quality checklist rules in the Art Bible.

Affected Systems

Art Bible, assets, creature visuals, card illustrations, review process.

Date

2026-06-28

-------------------------------------

Decision ID

DD-013

Title

Auto Battle

Status

Accepted

Decision

MVP combat uses auto battle.

Reason

Auto battle keeps MVP combat simple, testable, and aligned with progression-focused play.

Impact

Players do not manually select each combat action during battle. The server resolves combat behavior.

Affected Systems

Combat, UI, server simulation, skill system, enemy AI.

Date

2026-06-28

-------------------------------------

Decision ID

DD-014

Title

SPD Action Gauge

Status

Accepted

Decision

Combat uses an Action Time Bar where SPD fills the action gauge.

Reason

SPD-based gauge fill provides a simple timing model while keeping combat automatic.

Impact

SPD must be represented in combat data. Gauge constants remain placeholders until combat tuning is approved.

Affected Systems

Combat, creature data, enemy data, data schema, UI combat display.

Date

2026-06-28

-------------------------------------

Decision ID

DD-015

Title

Cooldown Skills

Status

Accepted

Decision

MVP combat skills are cooldown based.

Reason

Cooldowns provide simple skill pacing without adding resource complexity.

Impact

Skill data must include cooldown fields. The server owns cooldown validation and skill availability.

Affected Systems

Combat, skills, data schema, server simulation, UI combat display.

Date

2026-06-28

-------------------------------------

Decision ID

DD-016

Title

No Mana

Status

Accepted

Decision

MVP combat has no mana system.

Reason

Mana would add an additional resource layer that is not required for MVP combat validation.

Impact

Skills must not consume mana, UI must not show mana, and data schema must not add mana fields for MVP combat.

Affected Systems

Combat, skills, UI, data schema.

Date

2026-06-28

-------------------------------------

Decision ID

DD-017

Title

No Stamina

Status

Accepted

Decision

MVP combat and MVP progression do not use stamina as a limiting resource.

Reason

Stamina would add time-gated friction and additional economy complexity outside the current MVP focus.

Impact

No stamina fields, stamina costs, stamina UI, or stamina gates should be added unless a future decision changes this.

Affected Systems

Combat, progression, economy, UI, data schema.

Date

2026-06-28

-------------------------------------

Decision ID

DD-018

Title

Story Mode Is 1v1

Status

Accepted

Decision

Story Mode battles are 1v1.

Reason

1v1 Story Mode keeps the core progression path simple and readable for MVP.

Impact

Story Mode encounter data and combat UI must support one player-side active combat unit and one enemy-side active combat unit.

Affected Systems

Combat, encounter data, world progression, UI.

Date

2026-06-28

-------------------------------------

Decision ID

DD-019

Title

Boss and Challenge Battles Are 3v3

Status

Accepted

Decision

Boss and Challenge battles are 3v3.

Reason

3v3 gives higher-importance encounters more team structure while keeping MVP battle formats limited.

Impact

Boss and Challenge encounter data must support up to three player-side units and up to three enemy-side units.

Affected Systems

Combat, boss data, challenge data, UI, encounter data.

Date

2026-06-28

-------------------------------------

Decision ID

DD-020

Title

Recommended Power Only

Status

Accepted

Decision

Power is a recommendation only and must not be used as a hard gate.

Reason

Players should be allowed to attempt content above or below the recommendation while still receiving clear guidance.

Impact

Recommended Power may be displayed, but it must not prevent battle entry.

Affected Systems

Combat, world progression, UI, data schema, encounter data.

Date

2026-06-28

-------------------------------------

Decision ID

DD-021

Title

Simplified MVP Damage

Status

Accepted

Decision

MVP combat uses a simplified damage model where DEF reduces damage by percentage.

Reason

A simplified formula supports faster MVP balancing and keeps combat implementation understandable.

Impact

Exact damage and DEF formulas remain placeholders until documented, but DEF must not be implemented as an undocumented flat subtraction rule.

Affected Systems

Combat, data schema, creature stats, enemy stats, skill data.

Date

2026-06-28

-------------------------------------

Decision ID

DD-022

Title

Full Heal After Battle

Status

Accepted

Decision

Player creatures fully heal after battle.

Reason

Full healing keeps MVP combat focused on encounter outcomes rather than persistent injury or recovery systems.

Impact

No persistent injury, wound, durability, or post-battle health management system is approved for MVP.

Affected Systems

Combat, save system, UI, auto retry.

Date

2026-06-28

-------------------------------------

Decision ID

DD-023

Title

Simple Enemy AI

Status

Accepted

Decision

Enemy AI is intentionally simple for MVP.

Reason

Simple AI keeps combat testable and avoids overbuilding enemy behavior before the core loop is validated.

Impact

Enemy targeting and skill priority rules must be documented before implementation, but advanced AI is not approved for MVP.

Affected Systems

Combat, enemies, boss encounters, challenge encounters.

Date

2026-06-28

-------------------------------------

Decision ID

DD-024

Title

Boss Phases Supported

Status

Accepted

Decision

Bosses may have one phase or multiple phases.

Reason

Boss phases allow higher-importance encounters to have structure while remaining within the documented boss system.

Impact

Phase state must be server-owned. Exact phase triggers and effects remain TBD until documented.

Affected Systems

Combat, boss data, server simulation, UI.

Date

2026-06-28

-------------------------------------

Decision ID

DD-025

Title

Auto Retry Supported

Status

Accepted

Decision

Auto Retry is supported for MVP combat.

Reason

Auto Retry supports repeatable progression play without creating a separate reward system.

Impact

Auto Retry must obey normal battle validation, healing, reward, and stop-condition rules.

Affected Systems

Combat, UI, server validation, reward flow.

Date

2026-06-28

-------------------------------------

Decision ID

DD-026

Title

Evolution Resets Creature Level

Status

Accepted

Decision

Evolution resets the creature level.

Reason

Level reset creates a clear progression consequence for evolution while preserving evolution as a meaningful growth milestone.

Impact

Exact reset target, preserved state, requirements, and save behavior must be documented before implementation.

Affected Systems

Evolution, progression, creature data, save system, UI.

Date

2026-06-28

-------------------------------------

Decision ID

DD-027

Title

Hybrid Collection

Status

Accepted

Decision

Collection uses a hybrid model that must account for both collection progress and owned creature state.

Reason

Project Genesis needs collection tracking that supports creature-focused progression without reducing all ownership to a single flat checklist.

Impact

Exact collection rules, duplicate handling, evolved forms, gene-related collection behavior, and rewards remain TBD until documented.

Affected Systems

Collection, creature ownership, save system, UI, data schema.

Date

2026-06-28

-------------------------------------

Decision ID

DD-028

Title

Documentation-First Implementation

Status

Accepted

Decision

Implementation must follow approved documentation and decisions.

Reason

Multiple AI assistants will work on the same repository, so durable documentation must remain the coordination mechanism.

Impact

Assistants must read the GDD, relevant domain documents, and this decision log before making implementation decisions.

Affected Systems

Agents, tasks, reviews, all implementation work.

Date

2026-06-28

-------------------------------------

## Open Questions

1. Exact combat formulas and tuning values.
2. Exact SPD gauge constants.
3. Exact cooldown units and tick behavior.
4. Exact enemy targeting and skill priority rules.
5. Exact boss phase triggers and phase effects.
6. Exact evolution reset target and preserved state.
7. Exact hybrid collection rules.
8. Exact scientist fantasy expression in UI copy, art, and onboarding.
9. Exact UI-only interaction flows.
10. Exact economy currencies, sources, sinks, costs, and rewards.
11. Exact progression pacing, level curves, and unlock thresholds.
12. Exact save migration policy.
13. Exact source folder structure and implementation framework choices.

## Future Decisions

1. Whether prestige is enabled in MVP or only reserved as a future-compatible system.
2. Whether quests become MVP objectives or remain future-only.
3. Whether tower content remains future-only.
4. Whether status effects remain future-only.
5. Whether any non-UI gameplay interaction is approved after MVP validation.
6. Whether monetization is considered after economy and progression integrity are established.
7. Whether analytics are introduced after leadership defines what decisions analytics should support.
8. Whether advanced collection rewards are approved after collection foundations are validated.
9. Whether expanded evolution or gene rules are approved after MVP.
10. Whether additional battle modes are approved after MVP.

## Decision History

| Date | Change | Notes |
|---|---|---|
| 2026-06-28 | Created `docs/DECISIONS.md`. | Initial permanent decision log populated from current MVP discussions and approved documentation. |
