# Task ID

`ALPHA-009`

# Task Name

Automated Regression Testing Suite

# Owner

Senior QA Automation Engineer

# Status

Current Status: Not Started

# Priority

Current Priority: P1

# Goal

Develop an automated regression testing suite that runs before every release build. This suite must automatically execute all individual task validations (MVP-001 through MVP-019), check boundaries, verify data integrity, and output a clean status report.

# Scope

- [ ] Combine all individual test suites into a master regression script.
- [ ] Implement an automated verification checklist that executes upon starting Play Solo or via CLI build tool.
- [ ] Verify that all game registries (creatures, skills, items, towers) load correctly and match configuration specifications.
- [ ] Implement data corruption recovery tests (loading malformed save structures and verifying migration fallback).
- [ ] Design clear console output/logging formats for easy review.

# Out of Scope

- [ ] Continuous Integration (CI) server configuration (testing within Studio Environment only).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] All previous MVP simulator scripts must be functional.

# Deliverables

- [ ] Master regression runner script (`src/client/controllers/RegressionRunner.luau` or additions in `GameplaySimulator.luau`).
- [ ] Automation run results and verification reports.

# Implementation Rules

- The suite must run offline within Roblox Studio environment.
- Maintain regression test coverage on every modified script.

# Testing Checklist

- [ ] Run regression suite successfully 5 times without any false failures.
- [ ] Verify output clearly flags failures and their causes.

# Review Checklist

- [ ] Master regression script is integrated and accessible.
- [ ] Reviewer approval is recorded.

# Definition of Done

- [ ] Scoped regression runner is fully complete.
- [ ] 5x successful consecutive runs executed.
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
