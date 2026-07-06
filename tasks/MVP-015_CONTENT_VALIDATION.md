# Task ID

`MVP-015`

# Task Name

Content Schema Validation

# Owner

Antigravity (Claude Sonnet) — 2026-07-06

# Status

Current Status: Approved

# Priority

Current Priority: P0

# Goal

Establish complete validation for creature configurations, evolution schemas, rarity rules, and structural fields.

# Scope

- [x] Implement schemas for creature configs.
- [x] Implement creature evolution checks.
- [x] Build automated test suite for content validation in `tests/unit/mvp015_content_validation.py`.

# Out of Scope

- [ ] Adding new creatures.
- [ ] Changing gameplay logic.

# Required Reading

- [x] `docs/DATA_SCHEMA.md`
- [x] `docs/CONFIG_GUIDE.md`

# Dependencies

- `MVP-004_CREATURE_SYSTEM.md`

# Deliverables

- [x] `tests/unit/mvp015_content_validation.py`.
- [x] Clean creature configs (12 configs).

# Testing Checklist

- [x] Run python content validation test.
- [x] Invalid IDs fail validation checks.

# Definition of Done

- [x] Automated checks pass without errors.
