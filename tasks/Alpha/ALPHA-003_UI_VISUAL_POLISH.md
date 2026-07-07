# Task ID

`ALPHA-003`

# Task Name

Core UI/UX Visual Polish & Screen Transitions

# Owner

UI/UX Artist / Frontend Developer

# Status

Current Status: Not Started

# Priority

Current Priority: P1

# Goal

Elevate the UI from a functional/debug level to a polished, premium aesthetic. This includes updating layout designs, monster cards, progress bars, loading states, error states, and implementing smooth transition animations between screens.

# Scope

- [ ] Complete the Monster Card visual design with rarity borders, stat displays, and clean typography.
- [ ] Polish Collection UI layout, showing unlocked/locked state of creatures.
- [ ] Upgrade Generator UI with level bars, production rates, and lock overlays.
- [ ] Polish Battle Result screen with star rating, level-up bars, and reward previews.
- [ ] Polish Evolution UI screen showcasing before/after forms and requirement checklists.
- [ ] Polish Inventory and Equipment screens (clean grid spacing, tooltips, selection outlines).
- [ ] Implement responsive UI elements supporting multiple aspect ratios and device scales.
- [ ] Implement loading overlays and user-friendly error message banners.
- [ ] Implement screen transition animations (e.g. fade, slide, or zoom) on routing.

# Out of Scope

- [ ] 3D models or particle VFX (handled in ALPHA-004).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] UI controllers and views from core MVP modules must be functional.

# Deliverables

- [ ] Updated UI View scripts under `src/client/views/`.
- [ ] UI stylesheet/theme configuration updates.

# Implementation Rules

- Do not use TailwindCSS unless explicitly confirmed.
- Avoid browser defaults; use modern, premium typography and color palettes.
- Keep layout logic responsive.

# Testing Checklist

- [ ] Verify UI layouts on phone, tablet, and PC screen ratios.
- [ ] Verify transition animations do not cause script delay or yield errors.
- [ ] Verify error states and loading overlays block interaction when active.

# Review Checklist

- [ ] Visual design meets high-fidelity production standard.
- [ ] No layout clipping or text overlap.

# Definition of Done

- [ ] All scoped deliverables are complete.
- [ ] Mobile/PC layout responsive checks pass.
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
