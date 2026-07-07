# Task ID

`ALPHA-004`

# Task Name

VFX, Tweens & Audio Feedback Integration

# Owner

VFX Artist / Client Engineer

# Status

Current Status: Not Started

# Priority

Current Priority: P1

# Goal

Add responsive audiovisual feedback to key gameplay events, providing satisfying weight and feedback to actions like attacks, skill activations, generator claims, and evolution.

# Scope

- [ ] Implement attack hit effects (particles/flashes) during battles.
- [ ] Implement unique visual effects for active skill activations.
- [ ] Implement generator claim visual effects (resource flying animation towards balance counter).
- [ ] Implement evolution sequence effect (glow, particles, burst).
- [ ] Implement floating damage and healing numbers during battles.
- [ ] Implement subtle camera shake on heavy attacks or critical hits.
- [ ] Implement UI tween animations (pop, slide, hover scale).
- [ ] Bind sound effects to key actions: attack hit, skill cast, claim, level-up, evolution, button clicks.

# Out of Scope

- [ ] Changes to gameplay stats, combat math, or rewards (audio-visual only).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] Sound assets uploaded or configured in registries.
- [ ] Particle assets configured.

# Deliverables

- [ ] VFX module helper (`src/client/effects/VFXHelper.luau` or similar).
- [ ] Sound triggers hooked into combat and UI events.

# Implementation Rules

- Do not block game threads with yielding tweens. Use asynchronous tweening/task spawns.
- Keep particle counts within performance budget.

# Testing Checklist

- [ ] VFX triggers do not cause FPS drop or memory leaks.
- [ ] Sounds play correctly and do not overlap/distortion.
- [ ] UI tweens complete correctly without getting stuck.

# Review Checklist

- [ ] Audiovisual feedback matches the theme and looks premium.
- [ ] Verification evidence is present.

# Definition of Done

- [ ] All scoped deliverables are complete.
- [ ] All applicable testing checklist items are complete.
- [ ] Reviewer approval is recorded.

# Handoff Notes

- Files changed:
- Folders changed:
- Validation performed:
- Validation not performed:
- Known risks:
- Follow-up tasks:

# Suggested Future Improvements

- None.
