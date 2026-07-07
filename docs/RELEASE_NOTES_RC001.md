# Project Genesis RC-001 Release Notes

## Status

- Version candidate: `v0.1.0-rc1`
- Git tag: not created
- Final status: `BLOCKED`
- Verification date: 2026-07-07
- Commit under verification: `92f0652`
- Working tree note: RC verification used the current local workspace, which includes uncommitted release-fix files plus this documentation update.

## Release Summary

RC-001 is not ready to cut. Core MVP regression passed for the active MVP-016, MVP-017, MVP-019, and core progression simulator paths, but the full Tower simulator flow fails because the simulator sends semantic validation requests faster than production middleware allows.

## Completed MVP Coverage

- MVP-001 through MVP-019 task files are approved.
- MVP-012 Visual Effects remains presentation-only and was covered through combat/evolution visual trigger flows.
- MVP-013 Tower and MVP-014 Boss remain approved scope/schema work; registry smoke checks passed.
- MVP-015 content validation passed offline.
- MVP-016 item/equipment suite passed twice.
- MVP-017 skill suite passed twice.
- MVP-019 generator suite passed twice.

## Major Systems

- Save/load and DataStore wrapper integration.
- Starter selection, collection, active creature, progression, inventory, equipment, skills, generator, battle, reward, and evolution flows.
- Server-authoritative remote handlers with middleware validation and rate limiting.
- Tower and Boss config registries for approved/deferred scope.

## Regression Summary

- `mvp015_content_validation.py`: PASS.
- `mvp016_item_equipment_validation.py`: PASS.
- `mvp017_skill_validation.py`: PASS.
- `mvp019_generator_validation.py`: PASS.
- `GameplaySimulator.runMVP016()`: PASS 2/2.
- `GameplaySimulator.runMVP017()`: PASS 2/2.
- `GameplaySimulator.runMVP019()`: PASS 2/2.
- `GameplaySimulator.runProgressionLoop()`: PASS 2/2.
- `GameplaySimulator.runTowerChallengeFullFlow()`: BLOCKED by `RequestTowerChallengeStart` rate limit during unpaced simulator validation.

## DataStore And Migration Notes

- Restart/load snapshot check passed after stopping and restarting Play Solo.
- Inventory snapshot restored with `migrationVersion = 3` and `itemCount = 3`.
- Active creature, skills, generator, inventory, and profile snapshots loaded after restart.
- Corrupted-save recovery and multi-server session-lock contention were not destructively tested during this RC pass.

## Security Summary

- MVP-016 semantic validation and spam validation passed through the simulator.
- MVP-017 semantic validation and cooldown/rate-limit behavior passed through the simulator.
- MVP-019 generator validation and persistence passed through the simulator.
- Paced Tower security check passed: invalid starts rejected, duplicate completion rejected, rapid Tower start spam safely rejected four of five attempts.

## Performance Summary

- Runtime remote count: 22 `RemoteFunction` instances, 0 `RemoteEvent` instances.
- Duplicate remote names: none observed.
- Duplicate main UI: none observed; exactly one `GenesisMainUI`.
- Static scan found no gameplay `Heartbeat`, `RenderStepped`, or `Stepped` loops.
- SceneAnalysisService was disabled in Studio, so deep scene memory/triangle/unparented-instance queries were not available.

## Known Limitations

- RC-001 is blocked by Tower simulator pacing.
- `SceneAnalysisService` was disabled, limiting performance evidence.
- Corrupted save recovery and multi-server session-lock contention require a safe dedicated harness before they can be treated as fully verified.

## Rollback Instructions

No RC tag was created. To return to the pre-RC verification commit, use commit `92f0652` as the rollback target and do not publish `v0.1.0-rc1` until `KI-RELEASE-004` is resolved.
