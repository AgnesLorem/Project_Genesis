# Style Guide

## Purpose

This document is the repository-wide coding and documentation style guide for Project Genesis.

It defines naming, formatting, documentation, and review standards for all future source files, data files, configuration files, Markdown documents, Roblox modules, remotes, services, and commits.

This document is style guidance only. It does not approve new gameplay systems, source folder scaffolding, Lua implementation, or final framework choices.

## Status

- Status: Active Draft
- Scope: Repository-wide style standards
- Owner: Technical Direction
- Last Updated: 2026-06-28
- Review Cadence: Before source folder creation, before implementation work, and before naming convention changes
- Authority Level: Repository-wide style reference

## Table of Contents

- [1. Global Style Principles](#1-global-style-principles)
- [2. Folder Naming](#2-folder-naming)
- [3. File Naming](#3-file-naming)
- [4. Module Naming](#4-module-naming)
- [5. Lua Naming](#5-lua-naming)
- [6. Variable Naming](#6-variable-naming)
- [7. Service Naming](#7-service-naming)
- [8. RemoteEvent Naming](#8-remoteevent-naming)
- [9. RemoteFunction Naming](#9-remotefunction-naming)
- [10. Comment Standards](#10-comment-standards)
- [11. Markdown Standards](#11-markdown-standards)
- [12. Documentation Formatting](#12-documentation-formatting)
- [13. JSON Formatting](#13-json-formatting)
- [14. Configuration Formatting](#14-configuration-formatting)
- [15. Commit Message Style](#15-commit-message-style)
- [16. Good and Bad Naming Examples](#16-good-and-bad-naming-examples)
- [17. Review Checklist](#17-review-checklist)
- [18. Open Questions](#18-open-questions)

## 1. Global Style Principles

1. Names must describe responsibility.
2. Names must use established Project Genesis terminology.
3. Names must not imply authority where none exists.
4. Style must support server-authoritative architecture.
5. Style must support data-driven gameplay.
6. Style must keep gameplay logic separate from UI.
7. Style must keep files easy for humans and AI assistants to review.
8. Style must avoid clever abbreviations.
9. Style must avoid vague generic names.
10. Style must remain consistent across documentation, data, and code.

When uncertain, prefer the clearest name over the shortest name.

## 2. Folder Naming

Folder names should be stable, descriptive, and responsibility-based.

Current approved top-level documentation folders:

1. `docs/`
2. `agents/`
3. `tasks/`
4. `reviews/`
5. `prompts/`
6. `assets/`

Rules:

1. Use lowercase folder names for repository documentation folders.
2. Use hyphenated names for multi-word non-code folders when needed.
3. Do not rename referenced folders without updating documentation.
4. Do not introduce source folders without architecture approval.
5. Do not mix server-only, client-only, shared, data, and test responsibilities in one folder.
6. Do not create vague folders such as `misc/`, `stuff/`, `new/`, or `temp/`.

Future source folders must clearly separate:

1. Server-only systems.
2. Client-only systems.
3. Shared contracts.
4. Static data definitions.
5. Tests.

## 3. File Naming

File names must communicate purpose and ownership.

Markdown rules:

1. Use `UPPER_SNAKE_CASE.md` for major repository authority documents.
2. Use lowercase hyphenated names for agent role documents.
3. Use stable task IDs for task files.
4. Use descriptive names for review records.

Examples:

| Good | Bad | Reason |
|---|---|---|
| `GDD_MASTER.md` | `game.md` | Clear authority document name. |
| `TECH_ARCHITECTURE.md` | `tech stuff.md` | Professional and specific. |
| `CONTENT_PIPELINE.md` | `pipeline2.md` | Stable and descriptive. |
| `gameplay-agent.md` | `gameplayAgent.md` | Matches existing agent file style. |
| `MVP-001.md` | `first-task.md` | Stable production task ID. |

Future code file rules:

1. Use `PascalCase` for ModuleScript-style modules.
2. Use responsibility-based names.
3. Avoid implementation-detail names unless that detail is the module's responsibility.
4. Avoid version suffixes such as `New`, `Old`, `V2`, or `Final`.

## 4. Module Naming

Module names should identify architectural role.

Preferred suffixes:

| Suffix | Use |
|---|---|
| `Service` | Server-owned authoritative system. |
| `Controller` | Client-owned input or presentation coordination. |
| `View` | Client-owned UI presentation. |
| `Model` | Client-side local representation of server-provided state. |
| `Definition` | Static content data. |
| `Schema` | Data shape description. |
| `State` | Runtime state container. |
| `Gateway` | Network boundary coordination if used. |
| `Adapter` | Boundary translation between systems. |
| `Config` | Technical configuration, not gameplay tuning. |

Rules:

1. Server authority modules may use `Service`.
2. Client modules must not use names implying server authority.
3. UI modules should use `View`, `Controller`, or clear component names.
4. Static data modules should use `Definition`.
5. Schema modules should use `Schema`.
6. Avoid `Manager`, `Handler`, `Helper`, and `Utils` unless there is a documented reason.

## 5. Lua Naming

Future Lua or Luau code must follow these naming conventions unless tooling or framework standards require otherwise.

Rules:

1. ModuleScript names use `PascalCase`.
2. Public module tables use `PascalCase`.
3. Functions use `camelCase` unless a framework dictates otherwise.
4. Local variables use `camelCase`.
5. Function parameters use `camelCase`.
6. Constants use `UPPER_SNAKE_CASE`.
7. Enum-like string keys use documented stable IDs.
8. Private local helpers should still have descriptive `camelCase` names.
9. Boolean names should read like true or false statements.
10. Do not use single-letter names except for trivial loop indexes in narrow scope.

Examples:

| Concept | Good | Bad |
|---|---|---|
| Module | `CombatService` | `combatservice` |
| Function | `calculateFinalDamage` | `calcDmg` |
| Local variable | `selectedCreatureId` | `x` |
| Constant | `ACTION_GAUGE_THRESHOLD` | `actionGaugeThresholdConstantThing` |
| Boolean | `isBattleActive` | `battle` |

## 6. Variable Naming

Variables should describe data ownership and meaning.

Rules:

1. Include `Id` suffix for stable identifiers.
2. Include `Ids` suffix for arrays of IDs.
3. Include `Ref` suffix for references to another data definition when appropriate.
4. Include `Refs` suffix for arrays of references.
5. Use `State` for mutable runtime state.
6. Use `Definition` for static data.
7. Use `Config` only for technical configuration.
8. Use `Count` for whole-number quantities.
9. Use `Amount` for economy or numeric quantities.
10. Use `At` suffix for timestamps.

Examples:

| Good | Bad | Reason |
|---|---|---|
| `creatureId` | `creature` | Distinguishes ID from object. |
| `skillIds` | `skills` | Makes reference type clear. |
| `economyState` | `moneyDataThing` | Uses domain language. |
| `createdAt` | `creationTimeStuff` | Standard timestamp naming. |
| `rewardAmount` | `rewardNum` | Clear quantity meaning. |

Avoid:

1. `data` when a more specific name is available.
2. `info`.
3. `stuff`.
4. `thing`.
5. `temp` in committed code.
6. Abbreviations not already approved.

## 7. Service Naming

Services are server-owned authoritative systems.

Rules:

1. Service names must end in `Service`.
2. Service names must identify owned domain.
3. Services must not be named after UI concerns.
4. Services must not use `Manager` as a fallback.
5. Services must not own unrelated systems.

Good examples:

1. `CombatService`
2. `SaveService`
3. `CreatureService`
4. `EconomyService`
5. `ProgressionService`
6. `CollectionService`
7. `WorldProgressionService`

Bad examples:

1. `GameManager`
2. `DataHandler`
3. `MainService`
4. `EverythingService`
5. `UIService` for client UI presentation
6. `CombatController` for server-owned combat truth

## 8. RemoteEvent Naming

RemoteEvent names must describe event direction and purpose.

Rules:

1. RemoteEvents must have documented purpose and payload shape.
2. RemoteEvents must use `PascalCase`.
3. Server-to-client notifications should describe what happened.
4. Client-to-server request events should use request language only if RemoteEvent is the approved transport.
5. Do not name remotes after implementation details.
6. Do not use generic remote names.
7. Do not expose hidden server internals in remote names.

Recommended patterns:

| Direction | Pattern | Example |
|---|---|---|
| Server to client | `[Domain][Thing]Updated` | `BattleStateUpdated` |
| Server to client | `[Domain][Outcome]Resolved` | `BattleResultResolved` |
| Client to server | `Request[Action]` | `RequestStartBattle` |
| Client to server | `Request[Setting]Change` | `RequestAutoRetryChange` |

Bad examples:

1. `RemoteEvent1`
2. `DoThing`
3. `Update`
4. `ClientEvent`
5. `ServerEvent`
6. `GiveReward`
7. `SetCurrency`

Remote names must never imply that the client controls authoritative outcomes.

## 9. RemoteFunction Naming

RemoteFunction names must describe explicit request and response behavior.

Rules:

1. RemoteFunctions must be used only when request-response behavior is required.
2. RemoteFunctions must have documented input, output, validation, and failure behavior.
3. RemoteFunctions must use `PascalCase`.
4. Names should start with `Get`, `Fetch`, or `Request` depending on behavior.
5. RemoteFunctions must not mutate state unless explicitly documented and approved.
6. RemoteFunctions must not expose server-only internals.

Recommended patterns:

| Purpose | Pattern | Example |
|---|---|---|
| Read-only state | `Get[Domain]State` | `GetBattleState` |
| Read-only definitions | `Get[Domain]Definitions` | `GetCreatureDefinitions` |
| Validated request | `Request[Action]` | `RequestStartBattle` |

Bad examples:

1. `Function1`
2. `GetEverything`
3. `AdminRun`
4. `ForceWin`
5. `GiveCurrency`
6. `SavePlayerNow`

## 10. Comment Standards

Comments should explain why, not narrate what obvious code does.

Rules:

1. Use comments for non-obvious design intent.
2. Use comments for trust boundary warnings.
3. Use comments for migration risks.
4. Use comments for formulas once formulas are approved.
5. Use comments sparingly.
6. Keep comments current when code changes.
7. Do not use comments to hide undocumented behavior.
8. Do not leave commented-out code in committed files.
9. Do not write jokes, emotional commentary, or chat notes in source files.
10. Do not put design decisions only in comments.

Good comment:

```lua
-- Server validates the encounter because Recommended Power is guidance only.
```

Bad comment:

```lua
-- Add 1 to i.
```

## 11. Markdown Standards

Markdown documents must be easy to scan and stable as project references.

Rules:

1. Start every major document with one `#` title.
2. Include `Purpose`.
3. Include `Status`.
4. Include `Table of Contents` for long documents.
5. Use numbered headings for major sections when the document is authoritative.
6. Use concise headings.
7. Use tables for structured repeated data.
8. Use bullet lists for rules and checklists.
9. Use fenced code blocks for examples.
10. Use backticks for file paths, field names, IDs, commands, and literals.
11. Do not use decorative emoji.
12. Do not use chat-style notes as documentation.
13. Do not mix brainstorming with approved rules unless clearly labeled.

Preferred heading style:

```markdown
## 1. Section Name

### Subsection Name
```

## 12. Documentation Formatting

Documentation must distinguish authority, placeholders, and open questions.

Rules:

1. Use `TBD` for unknown values.
2. Use `Open Questions` for unresolved decisions.
3. Use `Future Expansion Notes` for non-MVP ideas.
4. Use `Explicitly Out of Scope` for forbidden or excluded work.
5. Use consistent field labels in repeated workflows.
6. Do not imply implementation exists before it does.
7. Do not present reserved schemas as approved systems.
8. Link or reference the owning document for related details.
9. Keep documents professional and production-focused.
10. Update documentation when implementation changes behavior.

Standard status block:

```markdown
## Status

- Status: Active Draft
- Scope: TBD
- Owner: TBD
- Last Updated: TBD
- Review Cadence: TBD
- Authority Level: TBD
```

## 13. JSON Formatting

JSON data and configuration files must be deterministic and reviewable when introduced.

Rules:

1. Use two-space indentation.
2. Use double quotes for keys and string values.
3. Use stable key ordering within repeated objects.
4. Use `camelCase` for field names unless schema says otherwise.
5. Use arrays for ordered lists.
6. Use objects keyed by stable IDs only when lookup behavior is intended.
7. Do not include comments in strict JSON files.
8. Do not use trailing commas in strict JSON files.
9. Do not store secrets in JSON files.
10. Do not use JSON for gameplay values unless the data pipeline approves it.

Example:

```json
{
  "creatureId": "creature_001",
  "schemaVersion": 1,
  "displayName": "Starter Creature",
  "isEnabled": true
}
```

## 14. Configuration Formatting

Configuration must separate technical settings from gameplay balance.

Rules:

1. Technical configuration may live in `Config` files when source folders exist.
2. Gameplay tuning belongs in approved data definitions, not technical config.
3. Configuration keys use `camelCase`.
4. Constants use `UPPER_SNAKE_CASE` in Lua/Luau.
5. Use stable defaults.
6. Document environment-specific values.
7. Do not store secrets in repository config.
8. Do not use config files to smuggle unapproved mechanics into the project.

Good technical config examples:

1. Logging category names.
2. UI animation timing if approved by UI guidelines.
3. Data registry paths once architecture approves them.

Bad config examples:

1. Hidden combat damage values.
2. Undocumented currency rewards.
3. Secret admin flags.
4. Unapproved monetization toggles.

## 15. Commit Message Style

Commit messages should be clear, scoped, and reviewable.

Preferred format:

```text
type(scope): concise summary
```

Approved types:

| Type | Use |
|---|---|
| `docs` | Documentation-only changes. |
| `data` | Data definition changes. |
| `feat` | Approved feature implementation. |
| `fix` | Bug fix. |
| `test` | Test additions or changes. |
| `refactor` | Behavior-preserving restructuring. |
| `chore` | Tooling or maintenance. |

Examples:

| Good | Bad |
|---|---|
| `docs(combat): define auto battle rules` | `update stuff` |
| `docs(data): add creature schema reference` | `changes` |
| `data(creatures): add starter creature definition` | `new monster` |
| `fix(save): handle missing collection state` | `bug fix maybe` |

Commit rules:

1. Use present tense.
2. Keep the summary concise.
3. Mention the real scope.
4. Do not hide unrelated changes.
5. Do not use vague summaries.

## 16. Good and Bad Naming Examples

### Folder Names

| Good | Bad | Reason |
|---|---|---|
| `docs/` | `documentation-final/` | Stable and simple. |
| `reviews/` | `old-reviews/` | Avoid lifecycle labels in folder names. |
| `assets/` | `pictures-and-stuff/` | Uses production terminology. |

### Module Names

| Good | Bad | Reason |
|---|---|---|
| `CombatService` | `BattleManager` | Service owns server authority. |
| `CreatureDefinition` | `CreatureDataThing` | Clear static data role. |
| `CollectionView` | `CollectionUIStuff` | Clear UI presentation role. |
| `RemoteGateway` | `RemoteHandler` | Boundary role is clearer. |

### Variable Names

| Good | Bad | Reason |
|---|---|---|
| `selectedCreatureId` | `selected` | Identifies exact value. |
| `recommendedPower` | `powerGate` | Power is not a gate. |
| `cooldownValue` | `manaCost` | Skills do not use mana. |
| `isAutoRetryEnabled` | `retry` | Boolean meaning is clear. |

### Remote Names

| Good | Bad | Reason |
|---|---|---|
| `RequestStartBattle` | `StartBattleNow` | Request language preserves server authority. |
| `BattleStateUpdated` | `CombatStuff` | Event describes what changed. |
| `RequestAutoRetryChange` | `SetAutoRetry` | Client requests; server decides. |
| `GetCreatureDefinitions` | `GetAllData` | Narrow and reviewable. |

### Documentation Names

| Good | Bad | Reason |
|---|---|---|
| `DECISIONS.md` | `random-decisions.md` | Permanent authority document. |
| `BALANCE.md` | `numbers.md` | Balance is broader than numbers. |
| `CONTENT_PIPELINE.md` | `how-to-add-things.md` | Professional production naming. |

## 17. Review Checklist

Before approving naming or formatting changes, confirm:

1. Names match established terminology.
2. Names communicate ownership.
3. Names do not imply false authority.
4. Server systems use service naming when appropriate.
5. Client UI systems do not own gameplay naming.
6. Remote names preserve server authority.
7. Markdown uses required structure.
8. JSON or config formatting is deterministic.
9. Comments explain non-obvious intent.
10. Commit messages describe real scope.
11. No unrelated files were renamed or reformatted.
12. Documentation references remain valid.

## 18. Open Questions

1. Final source folder structure.
2. Final Roblox framework or no-framework decision.
3. Final test file naming convention.
4. Final data file extension and storage format.
5. Final remote registry format.
6. Final automated formatter choice.
7. Final linting rules.
8. Final commit enforcement process.
