# Project Genesis RC-001 Release Notes

**Status:** READY_FOR_RC
**Version:** v0.1.0-rc1
**Date:** 2026-07-07

## Overview
Release Candidate 1 (RC-001) encapsulates the entirety of MVP-001 through MVP-020. This marks the first fully playable, server-authoritative, and robust vertical slice of Project Genesis. 

The core game loop is complete: Starter Selection -> Story/Boss/Challenge Combat -> Rewards -> Accumulation (Generator) -> Upgrade/Evolution. 

## Key Features
- **Core Progression**: `GameplaySimulator` automation proves a fully integrated end-to-end loop without any manual intervention.
- **Combat System**: Deterministic, server-authoritative combat resolution (`BattleSession`). Includes Action Gauge, Skills (Active/Passive), and Elemental typing.
- **Generators**: Passive Biomass and DNA accumulation with upgrade scaling.
- **Collection & Inventory**: Persistent creature collection and server-normalized inventory/equipment limits.
- **Tower Challenge**: Repeatable challenge floors with progress persistence.
- **Stability & Anti-Exploit**: 
  - `SimulationGuard` protects against all known infinite-loop stalling vectors.
  - `RemoteMiddleware` enforces strict rate-limits and payload validation.
  - Safe session locking (`SaveService`) to prevent Datastore corruption.

## Quality Assurance
- **No Critical/High bugs reproduced during approved RC scope.**
- All 5 primary regression test suites (Progression, MVP016, MVP017, MVP019, Tower) pass successfully in simulated multi-run environments on fresh DataStores.
- Reconnection states are flawlessly restored without data loss or UI clipping.
