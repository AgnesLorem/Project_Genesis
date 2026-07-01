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

### Changed

- Updated release-gate documentation to reflect the current MVP-019 state instead of the earlier MVP-010 state.
- Updated `FrameworkSmoke` to use the canonical Genesis `ReplicatedStorage` path before the dependency audit.

### Validation

- Filesystem dependency audit found no source/config/test `*_Clone` modules, GUID-named modules, old require paths, or `restore_generated` requires after the `FrameworkSmoke` path fix.
- Roblox Studio Edit-mode dependency audit passed for duplicate ModuleScripts, `*_Clone` objects, GUID-named objects, old require paths, and `restore_generated` references.
- Roblox Studio Play Mode Grand Check passed on rerun for MVP-001 through MVP-019. The rerun used smaller batches to cover framework/config/dependency, creature/economy/progression, combat/world/boss/game modes, client UI, active generators, and post-cleanup dependency audit.

### Blocked

- MVP-001 through MVP-019 task records remain in `Review`, not `Approved`.
- `SaveService` remains an in-memory stub using `mockSaves`; `DataStoreWrapper` exists but is not integrated into the server save lifecycle.

## Release Entries

No Release Candidate has been cut.

## Decision Log

No permanent gameplay decision is made by this changelog entry.
