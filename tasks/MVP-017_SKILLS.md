# Task ID

`MVP-017`

# Task Name

Skills Foundation

# Owner

Antigravity (Claude Sonnet) — 2026-07-06

# Status

Current Status: Approved

# Priority

Current Priority: P0

# Goal

Implement skill configurations, active and passive skill types, damage multipliers, cooldown triggers, and simulation checks.

# Scope

- [x] Skill configuration schemas and registry lookups.
- [x] Cooldown triggers and active/passive skill triggers in combat.
- [x] Skill damage simulation integration.
- [x] Unit tests in `tests/unit/mvp017_skill_validation.py`.

# Out of Scope

- [ ] Status effect application (remains TBD).
- [ ] Client-side animation triggers.

# Required Reading

- [x] `docs/COMBAT.md`
- [x] `docs/CONFIG_GUIDE.md`

# Dependencies

- `MVP-006_COMBAT_SYSTEM.md`

# Deliverables

- [x] `src/server/services/SkillService.luau`.
- [x] `tests/unit/mvp017_skill_validation.py`.

# Testing Checklist

- [x] Skill damage simulation calculations verify correct outputs.
- [x] Cooldowns prevent active reuse during the locked turns.

# Definition of Done

- [x] Validated without critical/high bugs.
