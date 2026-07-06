# Task ID

`MVP-016`

# Task Name

Item & Equipment System

# Owner

Antigravity (Claude Sonnet) — 2026-07-06

# Status

Current Status: Approved

# Priority

Current Priority: P0

# Goal

Implement server-authoritative item and equipment registries, equipment slots, stat bonus calculations, and offline state recovery.

# Scope

- [x] Item and equipment config registries.
- [x] Equipment slots (Weapon, Armor, Accessory) and equip/unequip server validations.
- [x] Stat calculations (applying equipment multipliers to creature stats).
- [x] Offline progression and time calculations.
- [x] Automation checks in `tests/unit/mvp016_item_equipment_validation.py`.

# Out of Scope

- [ ] Unapproved equipment types.
- [ ] Client-authoritative stat changes.

# Required Reading

- [x] `docs/DATA_SCHEMA.md`
- [x] `docs/TECH_ARCHITECTURE.md`

# Dependencies

- `MVP-004_CREATURE_SYSTEM.md`

# Deliverables

- [x] `src/server/services/ItemService.luau`.
- [x] `src/server/services/EquipmentService.luau`.
- [x] `tests/unit/mvp016_item_equipment_validation.py`.

# Testing Checklist

- [x] Equip/unequip operations apply stat modifications correctly.
- [x] Offline accumulation calculation validated.

# Definition of Done

- [x] All tests pass and save file modifications remain compatible.
