# Task ID

`ALPHA-012`

# Task Name

Accessibility and UX Polish

# Owner

UI/UX Engineer

# Status

Current Status: Not Started

# Priority

Current Priority: P0

# Goal

Improve game accessibility and general UX comfort. This includes implementing tooltips for all icons, confirmations for resource spending, toast notifications, loading indicators, request fail retries, button disabling during active remote requests, and responsive layout optimizations.

# Scope

- [ ] Implement tooltip utility showing item/icon metadata on hover or long-press.
- [ ] Create Confirmation Modal pops for large resource spending (e.g. expensive generator upgrades).
- [ ] Implement toast notification manager (sliding message banners on screen edge).
- [ ] Add loading indicators (spinners) on elements processing remote requests.
- [ ] Implement automatic retry logic (up to 3 times) for network/database requests.
- [ ] Ensure buttons are disabled during active remote requests to prevent double-click spams.
- [ ] Optimize UI layouts to scale dynamically across mobile, tablet, and widescreen PC ratios.

# Out of Scope

- [ ] Screen readers or text-to-speech features.

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] UI screen controllers must be operational.

# Deliverables

- [ ] Tooltip UI component (`src/client/views/Tooltip.luau`).
- [ ] Toast notification manager (`src/client/controllers/ToastManager.luau`).
- [ ] Confirmation and loading views.

# Implementation Rules

- Do not implement custom UI packages; build clean, vanilla Roblox components.
- Do not let retry logics lock up UI interactions forever (provide a cancel/timeout).

# Testing Checklist

- [ ] Verify buttons disable immediately during remote requests.
- [ ] Verify toast notifications display correct info when rewards are earned.
- [ ] Verify tooltips render in correct positions on various screen boundaries.

# Review Checklist

- [ ] Buttons are successfully blocked from duplicate click spam.
- [ ] Reviewer approval is recorded.

# Definition of Done

- [ ] Scoped deliverables are completed.
- [ ] UI spam blocking verification passes.
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
