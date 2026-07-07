# Task ID

`ALPHA-007`

# Task Name

End-to-End Player Journey & Long-Session Testing

# Owner

QA Lead

# Status

Current Status: Not Started

# Priority

Current Priority: P1

# Goal

Design and execute end-to-end (E2E) automated player journey playtests. This simulates a player progressing from early-game (newbie) through mid-game and up to end-game content, verifying stability during long sessions (30-60 minutes), AFK/Idle periods, and network disruptions.

# Scope

- [ ] Create E2E journey flow in GameplaySimulator covering newbie onboarding, generator loops, battles, evolution, and tower runs.
- [ ] Implement a long-session simulation running for at least 30-60 minutes continuously, monitoring performance.
- [ ] Implement an AFK/Idle testing scenario, letting generators run offline or online for simulated periods.
- [ ] Implement disconnect/reconnect tests during active battle, generator claim, and progression phases to verify save/reconnect robustness.
- [ ] Document game client memory usage, CPU usage, and network latency over long sessions.

# Out of Scope

- [ ] Security exploitation audits (handled in ALPHA-008).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] Save, progression, and battle systems must be stable.

# Deliverables

- [ ] E2E playtest scripts within `GameplaySimulator.luau`.
- [ ] Playtest logs and telemetry results from a 30+ minute run.

# Implementation Rules

- Do not bypass server validations during disconnect/reconnect tests.
- Maintain telemetry checks.

# Testing Checklist

- [ ] Simulator completes a 30-minute progression loop successfully.
- [ ] Disconnect/reconnect does not corrupt player profile data.
- [ ] No major memory leaks detected during long sessions.

# Review Checklist

- [ ] Test report is complete and verified by team.
- [ ] Reviewer approval is recorded.

# Definition of Done

- [ ] All scoped deliverables are complete.
- [ ] Long session test successfully run.
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
