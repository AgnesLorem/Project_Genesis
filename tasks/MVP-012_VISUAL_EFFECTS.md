# Task ID

`MVP-012`

# Task Name

Visual Effects Scope

# Owner

Antigravity (Claude Sonnet) — 2026-07-06

# Status

Current Status: Approved

# Priority

Current Priority: P2

# Goal

Define and implement the visual effects scope for combat and evolution feedback without affecting gameplay correctness.

# Scope

- [x] Define MVP VFX scope in guidelines.
- [x] Implement client-side VFX adapters for combat hits and evolution success.
- [x] Verify visual feedback behaves purely as presentation-only overlays.

# Out of Scope

- [ ] VFX modifying server gameplay values.
- [ ] Complex client-predicted visual state loops.

# Required Reading

- [x] `docs/ART_BIBLE.md`
- [x] `docs/TECH_ARCHITECTURE.md`

# Dependencies

- `MVP-003_UI_FOUNDATION.md`

# Deliverables

- [x] Client-side VFX reference adapters.
- [x] Visual trigger events integrated with combat timeline playback.

# Implementation Rules

- Keep VFX logic strictly isolated in client views.
- Do not let visual timing determine server-authoritative combat outcomes.

# Testing Checklist

- [x] Battle result screens and evolution UI show proper feedback.
- [x] Missing assets fail gracefully without throwing errors.

# Review Checklist

- [x] No server state modification.
- [x] UI/VFX separation from gameplay authority preserved.

# Definition of Done

- [x] VFX deliverables complete, tested, and approved.
