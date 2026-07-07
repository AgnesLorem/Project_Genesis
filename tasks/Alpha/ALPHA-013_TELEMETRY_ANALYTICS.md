# Task ID

`ALPHA-013`

# Task Name

Internal Telemetry and Player Analytics

# Owner

Server Engineer / Data Analyst

# Status

Current Status: Not Started

# Priority

Current Priority: P0

# Goal

Establish an internal telemetry log system on the server to record player behaviors, progression steps, economy claims, combat results, and connection stability. This provides visibility into player retention and drop-off points without needing external analytics services.

# Scope

- [ ] Create server telemetry service (`TelemetryService.luau`).
- [ ] Log event: Player join / leave (calculating session length).
- [ ] Log event: Starter Selection choice.
- [ ] Log event: Battle results (stageId, victory/defeat status, turns elapsed).
- [ ] Log event: Generator claims (generatorId, amount claimed).
- [ ] Log event: Evolution triggers (creatureId, target form).
- [ ] Log event: Tower and Challenge clearances.
- [ ] Log event: Disconnect reasons (clean exit, error kick, network loss).
- [ ] Write logged events to internal diagnostics or a secure local logging file/DataStore.

# Out of Scope

- [ ] Integration with Google Analytics, GameAnalytics, or other external HTTP APIs (internal logging only).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] Save and player session services must be integrated.

# Deliverables

- [ ] Telemetry Service module (`src/server/services/TelemetryService.luau`).
- [ ] Analytics documentation detailing event structures.

# Implementation Rules

- Do not block gameplay threads with telemetry writes. Use asynchronous tasks.
- Keep event payloads compact to avoid performance/memory overhead.

# Testing Checklist

- [ ] Verify that every key player event prints correct telemetry data.
- [ ] Verify that session length is calculated correctly.
- [ ] Verify no memory leak occurs under heavy telemetry spam.

# Review Checklist

- [ ] Telemetry events are correctly formatted and cover player drop-off metrics.
- [ ] Reviewer approval is recorded.

# Definition of Done

- [ ] Scoped telemetry events are fully integrated.
- [ ] Offline test verification passes.
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
