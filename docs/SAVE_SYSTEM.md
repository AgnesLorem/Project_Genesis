# Save System

## Purpose

This document defines persistence requirements, save data ownership, key strategy, failure handling, and migration policy for Project Genesis.

## Status

- Status: Active Draft
- Owner: Technical Architecture
- Last Updated: 2026-06-28
- Review Cadence: Before any system that reads, writes, or migrates player save data
- Authority Level: Primary persistence reference

## Table of Contents

- [Persistence Goals](#persistence-goals)
- [Persistence Backend](#persistence-backend)
- [Save Key Strategy](#save-key-strategy)
- [Saved Data Structure](#saved-data-structure)
- [Load Flow](#load-flow)
- [Save Flow](#save-flow)
- [Failure Handling](#failure-handling)
- [Migration Policy](#migration-policy)
- [Open Questions](#open-questions)

## Persistence Goals

1. Player save data must be owned and written exclusively by the server.
2. Save data must survive server restarts, place updates, and normal player sessions.
3. Save loading must be resilient to missing data, new players, and schema version differences.
4. Save failures must be reported safely without exposing raw data payloads.
5. Save data must follow the field structure documented in `docs/DATA_SCHEMA.md`.
6. Save data must support schema versioning for future migrations.
7. Client code must never write save data directly.
8. Save mutation must occur only through approved server-owned services.

## Persistence Backend

Project Genesis uses **Roblox DataStoreService (DataStore v1)**.

- DataStore name: `PlayerSaveData` (primary player save store)
- API used: `DataStoreService:GetDataStore(name)` → `GetAsync`, `SetAsync`, `UpdateAsync`
- All DataStore calls must be wrapped in `pcall` to handle service failures safely
- DataStore calls must only occur on the server runtime

### Roblox DataStore Constraints

- DataStore is available in Live game servers and Studio with Studio Access to API Services enabled.
- DataStore is not available during offline Studio testing without this setting.
- DataStore request budget is shared; excessive calls must be avoided.
- Maximum data size per key: 4MB (Roblox platform limit).
- Keys must be deterministic, stable, and server-constructed.

## Save Key Strategy

Save keys must be deterministic, server-constructed, and stable across sessions.

### Player Save Key Format

```
player_{userId}
```

Where `userId` is the Roblox `Player.UserId` (an integer assigned by Roblox).

### Rules

- Keys must be constructed server-side only.
- Keys must use the player UserId, not the player Username (usernames can change).
- Keys must not include display names, session IDs, or timestamps.
- Invalid or nil UserId must be rejected before key construction.
- Key format must not change after player data has been saved, as this would orphan existing saves.

### Example

| Player UserId | Save Key |
|---|---|
| `123456` | `player_123456` |
| `987654` | `player_987654` |

## Saved Data Structure

The player save structure follows `docs/DATA_SCHEMA.md` section 12 (Player Save Schema).

Current save fields for MVP:

| Field | Type | Description | Blocker |
|---|---|---|---|
| `saveVersion` | Version | Schema version for migration support | Required |
| `playerId` | ID | Server-owned Roblox UserId | Required |
| `createdAt` | Timestamp | Server-owned save creation time | TBD format |
| `updatedAt` | Timestamp | Server-owned last save time | TBD format |
| `selectedCreatureId` | ID | Currently selected creature instance | Requires creature system |
| `creatureInstances` | Map | Player-owned creature save data | Requires creature system |
| `inventory` | Object | Persisted inventory state | Requires economy system |
| `collectionState` | Object | Persisted collection progress | Requires collection system |
| `progressionState` | Object | World and milestone data | Requires world system |
| `economyState` | Object | Currency and economy state | Requires economy system |
| `prestigeState` | Object | Prestige state if enabled | Blocked: prestige TBD |
| `settings` | Object | Player preference data | Safe to add |

> [!WARNING]
> **MVP-SAVE-001 is BLOCKED.** The exact save field list must be finalized and reviewed before a default save template (MVP-SAVE-002) or save mutation API (MVP-SAVE-004) can be implemented. Systems depending on unfinalized fields must remain Blocked.

## Load Flow

The server load flow for a player joining:

1. Player joins → server receives `Players.PlayerAdded` event.
2. Server constructs save key using `SaveKeyBuilder.buildPlayerKey(userId)`.
3. Server calls `DataStoreWrapper.load("PlayerSaveData", key)`.
4. On success with data: validate `saveVersion`, apply migration if needed, store in session state.
5. On success with nil data (new player): initialize default save template (Blocked until MVP-SAVE-001 done).
6. On failure: call `PersistenceReporter.reportLoadFailure(userId, error)`, do not initialize session.
7. Session state is server-owned and never sent raw to the client.

## Save Flow

The server save flow for a player leaving or periodic save:

1. Server receives `Players.PlayerRemoving` event (or periodic trigger).
2. Server validates that session state exists for this player.
3. Server sets `updatedAt` timestamp (server-owned).
4. Server calls `DataStoreWrapper.save("PlayerSaveData", key, data)`.
5. On failure: call `PersistenceReporter.reportSaveFailure(userId, error)`.
6. Server must not write raw client-provided data.

> [!IMPORTANT]
> Save write flow (MVP-SAVE-005) is Blocked pending MVP-SAVE-001 and MVP-SAVE-004 completion.

## Failure Handling

Failure handling must be conservative and safe.

### Load Failures

- Log the failure using `PersistenceReporter.reportLoadFailure(userId, errorCategory)`.
- Do not initialize player session on load failure (fail closed).
- Do not expose raw DataStore error messages to the client.
- Document the failure. Investigate if repeated.

### Save Failures

- Log the failure using `PersistenceReporter.reportSaveFailure(userId, errorCategory)`.
- Do not retry excessively (respect DataStore request budget).
- Do not mutate session state after a save failure.
- Do not expose save payload contents in logs.

### Error Categories

Safe error categories for logging (no raw data exposure):

| Category | Meaning |
|---|---|
| `datastore_unavailable` | DataStore service is not accessible |
| `request_budget_exceeded` | Too many DataStore calls |
| `serialization_failed` | Data could not be serialized |
| `key_invalid` | Save key construction failed |
| `unknown_error` | Uncategorized DataStore error |

## Migration Policy

Schema migrations are required when the `saveVersion` changes.

### Current Version

- `saveVersion = 1` (initial MVP schema)

### Migration Rules

1. Every persisted save must include `saveVersion`.
2. Load flow must check `saveVersion` before use.
3. If `saveVersion` is lower than current, apply documented migration steps.
4. Migration steps must be documented in this file before implementation.
5. Breaking schema changes must be reviewed by project leadership.
6. Non-breaking additions must define default values.
7. Field removals must document how old saves are handled.

> [!NOTE]
> No migrations exist yet. The first migration entry will appear when `saveVersion` is incremented from `1`.

## Open Questions

1. Exact `createdAt` and `updatedAt` timestamp format (Unix seconds vs ISO string).
2. Exact MVP save fields once MVP-SAVE-001 is completed.
3. Whether periodic auto-save is required during a session or only on `PlayerRemoving`.
4. Maximum save data size estimate once creature and economy fields are finalized.
5. Whether failed-load players should be kicked or allowed to play with a fallback empty state.
6. Studio testing strategy for DataStore (offline test mode or live Studio API access required).
