# Roadmap

## Purpose

This document tracks production phases, milestones, dependencies, and delivery sequencing for Project Genesis.

## Status

- Status: Active Draft
- Owner: Production / Technical Architecture
- Last Updated: 2026-07-01
- Review Cadence: At the start of each production phase and milestone gate audit

## Table of Contents

- [Milestone Overview](#milestone-overview)
- [MVP Scope](#mvp-scope)
- [Production Phases](#production-phases)
- [Dependencies](#dependencies)
- [Risks](#risks)

## Milestone Overview

| Milestone | Target | Description | Status |
|---|---|---|---|
| Milestone 0 | Foundation | Establish guidelines (`Jarvis.md`), standards, folder paths, and configuration rules. | Complete |
| Milestone 1 | First Playable | Service lifecycle pattern, loading/screen routing, and mock save files. | Complete |
| Milestone 2 | Combat Prototype | Isolated 1v1 battle simulator, basic damage and defense formulas. | Complete |
| Milestone 3 | Vertical Slice | 3v3 combat, world progression registry, boss config, and `GameModeService`. | Complete |
| Milestone 4 | Content Complete | 12 creature configs, 6 evolution configs, equipment slots, and item registry. | Complete |
| Milestone 5 | Alpha Release Gate | System sweep, leveling stat growth integration, generator claiming, and polish. | In Progress |

## MVP Scope

*   **Core Systems**: Client-Server networking, DataStore-backed save profiles, creature registries.
*   **Gameplay Loops**: Automatic turn-based combat using Speed-driven Action Gauges, basic skills, and target selections.
*   **Progression & Economy**: Biomass and DNA soft currencies, Bio/DNA generators for passive accumulation, creature leveling/evolution, and equipment stat caching.
*   **UI/UX**: World selection screen, inventory slots, equipment layouts, combat timeline visualization, and error/loading overlays.

## Production Phases

1.  **Phase 1: Foundation & Prototype (Milestones 0 - 2)**: Complete. Validated core engine, network framework, and isolated combat math.
2.  **Phase 2: Feature Expansion & Content (Milestones 3 - 4)**: Complete. Implemented items, equipment, skills, evolution, and biomass generators.
3.  **Phase 3: Integration, Polish & Alpha (Milestone 5)**: Active. Integrating leveling formulas, equipment bonuses to combat, and running final playtest/security suites.
4.  **Phase 4: Release Candidate & Feedback**: Upcoming. Launching public Alpha candidate for player progression feedback.

## Dependencies

*   **Roblox API**: DataStoreService availability for persistent profiles.
*   **Rojo tooling**: Accurate local filesystem mapping into Roblox Studio.

## Risks

*   **DataStore Throttling**: Heavy saving loads during rapid reconnects. (Controlled by autosave interval caching and load-failure save protections).
*   **Combat Infinite Loops**: Large HP values vs. low damage. (Controlled by `maxTurnSafeguard` limit).

