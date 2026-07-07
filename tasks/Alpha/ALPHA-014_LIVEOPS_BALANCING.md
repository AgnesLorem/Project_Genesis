# Task ID

`ALPHA-014`

# Task Name

LiveOps, Content Pipeline & Balancing Framework

# Owner

Lead Architect / Systems Designer

# Status

Current Status: Not Started

# Priority

Current Priority: P1

# Goal

Build foundations for LiveOps and easy content expansion. This includes architecture support for daily rewards/resets, login streaks, mail, announcements, feature flags, a template content pipeline (adding content via config instead of code), and a balancing framework for economy/progression simulation.

# Scope

- [ ] Design daily reset clock service on the server.
- [ ] Implement daily login reward checklist structure in saves.
- [ ] Design mailbox structure (`MailService.luau`) to receive server announcements or rewards.
- [ ] Implement simple Feature Flag system to toggle upcoming features.
- [ ] Implement template content registries (creature templates, skill templates, tower templates) to add new content solely via configuration.
- [ ] Create a balancing simulation utility (`EconomySimulator.luau` or offline script) to simulate progression speed and output data profiles.

# Out of Scope

- [ ] Complete visual design of mail screens or feature toggle menus (baseline architecture and registries only).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] Config structures must be standardized.

# Deliverables

- [ ] LiveOps services (`src/server/services/MailService.luau`, `DailyResetService.luau`).
- [ ] Configuration templates for easy content additions.
- [ ] Balancing simulation script (`scratch/EconomySimulator.luau`).

# Implementation Rules

- Content templates must use structured validation to prevent crashes from bad configs.
- Follow the clean configuration architecture.

# Testing Checklist

- [ ] Daily reset state updates correctly when system clock rolls over.
- [ ] Adding a new creature to registry template makes it immediately loadable without code changes.
- [ ] Simulation script successfully runs and exports projection tables.

# Review Checklist

- [ ] Architecture easily supports adding content by configuration.
- [ ] Reviewer approval is recorded.

# Definition of Done

- [ ] Scoped services and content pipelines are complete.
- [ ] Balancing simulator tool verified.
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
