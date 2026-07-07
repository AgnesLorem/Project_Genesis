# Changelog

## Purpose

This document will record approved documentation, design, production, and technical changes for Project Genesis.

## Status

- Status: Active Draft
- Owner: Production
- Last Updated: 2026-06-29
- Review Cadence: Every MVP milestone, release gate, and approved scope change

## Table of Contents

- [Change Policy](#change-policy)
- [Unreleased](#unreleased)
- [Release Entries](#release-entries)
- [Decision Log](#decision-log)

## Change Policy

Record implementation, documentation, validation, and release-gate changes that affect MVP scope, review status, or contributor expectations.

Do not use this changelog to approve new mechanics. New design decisions still require updates to the owning documentation and, when permanent, `docs/DECISIONS.md`.

## Unreleased

### Added

- MVP foundation modules for MVP-001 through MVP-019 are present in source and have task handoff notes.
- MVP-008 added schema/registry support for world, stage, boss, and challenge lookup without creating empty runtime services.
- MVP-009 added `GameModeContract` and `GameModeService` as the single game-mode orchestrator over existing combat APIs.
- MVP-015 added content validation databases and creature evolution schemas.
- MVP-016 added item and equipment data registries, server-authoritative validations, and offset offline calculations.
- MVP-017 added skill configuration structures, skill cooldown triggers, and skill damage simulation integration.
- MVP-019 added Bio Generator, DNA Generator, and Advanced Bio Generator configuration registries along with `GeneratorService` for passive Biomass/DNA accumulation.
- MVP-020 added Shared `SimulationGuard` utility to prevent server infinite loops during combat, persistence, and progression logic.
- Persistent world stage progression and save migrations from v0 to v3 inside `MigrationManager.luau` and `SaveService.luau`.
- Server-authoritative stage-lock checks and next-stage unlocking on victory inside `RemoteHandlers.luau` (`RequestStoryBattle` / `RequestWorldSnapshot`).
- DNA victory rewards: grants 50 DNA (story), 100 DNA (boss), and 150 DNA (challenge) on player victory, returning reward details in client payloads.

### Changed

- Updated client-side `BattleController.luau` and `WorldController.luau` to thread the active creature ID and clicked stage ID through instead of hardcoded values.
- Updated `world_001_config.luau` to add `mossbit_001` and `thornhorn_001` to `encounterRefs` to align with the progression dictionary.
- Updated release-gate documentation to reflect the current MVP-019 state instead of the earlier MVP-010 state.
- Updated `FrameworkSmoke` to use the canonical Genesis `ReplicatedStorage` path before the dependency audit.

### Fixed

- Bug 1: Wrapped client-side combat timeline steps in safety guards to support instant server-simulated battles.
- Bug 2: Fixed `SaveService` player-added event race condition in Roblox Studio Play Solo mode.
- Bug 4: Corrected `CombatService` player creature config lookup to key off `pInst.creatureId` instead of the instance GUID.
- Bug 5: Set continue button name to `ContinueButton` in `BattleResultModal` to prevent playtest timeout.

### Validation

- Filesystem dependency audit found no source/config/test `*_Clone` modules, GUID-named modules, old require paths, or `restore_generated` requires after the `FrameworkSmoke` path fix.
- Roblox Studio Edit-mode dependency audit passed for duplicate ModuleScripts, `*_Clone` objects, GUID-named objects, old require paths, and `restore_generated` references.
- Roblox Studio Play Mode Grand Check passed on rerun for MVP-001 through MVP-019. The rerun used smaller batches to cover framework/config/dependency, creature/economy/progression, combat/world/boss/game modes, client UI, active generators, and post-cleanup dependency audit.
- Verified and passed Play Mode end-to-end test for stage locking, combat victory rewards, and stage progression unlocks using the client simulator.
- MVP-020 RC-001 verification was attempted in Roblox Studio Play Mode. MVP-016, MVP-017, MVP-019, core progression, restart/load snapshots, and paced Tower security checks passed, but RC-001 remains blocked because `GameplaySimulator.runTowerChallengeFullFlow()` hits the middleware rate limit during its unpaced Tower start validation sequence.

### Resolved

- All milestones MVP-001 through MVP-019 task records are Approved.
- `SaveService` is fully integrated with `DataStoreWrapper` for dynamic persistent DataStore saving/loading.
- `KI-RELEASE-002` is resolved: task files for MVP-001 through MVP-019 now record `Current Status: Approved`.

## Release Entries

No Release Candidate has been cut. RC-001 is documented as blocked pending the Tower simulator pacing fix.

## Decision Log

No permanent gameplay decision is made by this changelog entry.
