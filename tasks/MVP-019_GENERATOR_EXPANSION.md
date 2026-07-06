# Task ID

`MVP-019`

# Task Name

Generator Expansion & Save System Release Gate

# Owner

Antigravity (Claude Sonnet) — 2026-07-06

# Status

Current Status: Approved

# Priority

Current Priority: P0

# Goal

Implement Bio Generator, DNA Generator, and Advanced Bio Generator passive resources, dynamic DataStore-backed SaveService, and clean cardMetadata.

# Scope

- [x] Bio Generator, DNA Generator, and Advanced Bio Generator configuration registries.
- [x] GeneratorService for passive Biomass and DNA accumulation.
- [x] Dynamic SaveService integrated with DataStoreWrapper for Roblox DataStores.
- [x] Clean creature config metadata (cardMetadata removed).
- [x] Automated tests in `tests/unit/mvp019_generator_validation.py`.

# Out of Scope

- [ ] Client-side clock manipulation.
- [ ] Speculative generators.

# Required Reading

- [x] `docs/SAVE_SYSTEM.md`
- [x] `docs/ECONOMY.md`

# Dependencies

- `MVP-002_SAVE_CONFIG_DATABASE.md`
- `MVP-005_GENERATOR_ECONOMY.md`

# Deliverables

- [x] `src/server/services/GeneratorService.luau`.
- [x] `src/shared/data/GeneratorSchema.luau`.
- [x] DataStore-backed `src/server/services/SaveService.luau` and `src/server/persistence/DataStoreWrapper.luau`.
- [x] Clean creature configs.
- [x] `tests/unit/mvp019_generator_validation.py`.

# Testing Checklist

- [x] Accumulation rate matches configured values.
- [x] Claiming grants Biomass/DNA to player save correctly.
- [x] Session locking and data migrations validated on join/quit.

# Definition of Done

- [x] All automated and manual playtests pass.
