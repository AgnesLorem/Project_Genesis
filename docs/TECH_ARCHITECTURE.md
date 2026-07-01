# Technical Architecture

## Purpose

This document defines the technical architecture for Project Genesis.

Project Genesis is a Roblox game using server-authoritative architecture, data-driven gameplay, modular systems, event-driven communication, a service-based backend, and an MVC-inspired client architecture.

This document describes architecture only. It does not provide implementation code, folder scaffolding, Lua, Luau, exact APIs, concrete class definitions, or final module names.

## Status

- Status: Active Draft
- Scope: MVP technical architecture
- Owner: Technical Direction
- Last Updated: 2026-07-01
- Review Cadence: Before implementation of any gameplay, networking, persistence, UI, or data system
- Authority Level: Primary technical architecture source of truth

## Table of Contents

- [1. Architecture Goals](#1-architecture-goals)
- [2. Core Architecture Principles](#2-core-architecture-principles)
- [3. Roblox Runtime Boundaries](#3-roblox-runtime-boundaries)
- [4. Server-Authoritative Architecture](#4-server-authoritative-architecture)
- [5. Data-Driven Gameplay](#5-data-driven-gameplay)
- [6. Modular Systems](#6-modular-systems)
- [7. Event-Driven Communication](#7-event-driven-communication)
- [8. Service-Based Backend](#8-service-based-backend)
- [9. MVC-Inspired Client Architecture](#9-mvc-inspired-client-architecture)
- [10. Gameplay and UI Separation](#10-gameplay-and-ui-separation)
- [11. Shared Contracts](#11-shared-contracts)
- [12. Networking Model](#12-networking-model)
- [13. Persistence Boundary](#13-persistence-boundary)
- [14. Combat Architecture Boundary](#14-combat-architecture-boundary)
- [15. Economy and Progression Boundary](#15-economy-and-progression-boundary)
- [16. Folder Architecture Guidance](#16-folder-architecture-guidance)
- [17. Naming Guidance](#17-naming-guidance)
- [18. Validation and Security](#18-validation-and-security)
- [19. Testing and Verification Architecture](#19-testing-and-verification-architecture)
- [20. Explicitly Not Defined Here](#20-explicitly-not-defined-here)
- [21. Open Questions](#21-open-questions)

## 1. Architecture Goals

The architecture must support:

1. Server-authoritative gameplay.
2. Data-driven configuration.
3. Modular system ownership.
4. Event-driven communication.
5. Service-based backend systems.
6. MVC-inspired client organization.
7. Clear separation between gameplay logic and UI.
8. Safe persistence boundaries.
9. Reviewable networking contracts.
10. Long-term AI-assisted development.

The MVP architecture should be practical and restrained. It should support the documented MVP without creating speculative frameworks for unapproved future features.

## 2. Core Architecture Principles

1. The server owns truth.
2. The client owns presentation.
3. Static gameplay definitions come from data.
4. Player state changes are validated by server services.
5. UI displays state; UI does not own game rules.
6. Modules have narrow responsibilities.
7. Systems communicate through explicit contracts.
8. Remote communication is request-and-response or event-based, never trust-based.
9. Persistence is isolated behind a save boundary.
10. Shared code must not leak server-only authority to the client.

Every implementation task must preserve these principles.

## 3. Roblox Runtime Boundaries

Project Genesis must respect Roblox client-server boundaries.

### Server Runtime

The server is responsible for:

1. Authoritative gameplay decisions.
2. Combat simulation and battle outcomes.
3. Creature ownership and progression state.
4. Economy changes.
5. Collection state.
6. Evolution and gene state changes when approved.
7. Prestige state changes when approved.
8. Save loading and save writing.
9. Remote validation.
10. Reward issuance.

### Client Runtime

The client is responsible for:

1. UI rendering.
2. Local presentation.
3. Input collection.
4. Camera and visual feedback when needed.
5. Displaying server-provided state.
6. Requesting valid player actions.
7. Showing combat, progression, collection, and economy feedback.

### Shared Runtime

Shared code may contain:

1. Data definitions safe for replication.
2. Type-like contracts or schema references.
3. Enum-like identifiers.
4. Pure utility functions that do not own state.
5. Client-safe presentation helpers.

Shared code must not contain server-only authority, secrets, reward logic, save mutation logic, or final gameplay outcome decisions.

## 4. Server-Authoritative Architecture

Server authority is mandatory.

The server must own:

1. Battle start validation.
2. Combat action timing.
3. Combat damage and defense calculations.
4. Battle victory and defeat.
5. Reward eligibility.
6. Currency and inventory mutation.
7. Creature ownership.
8. Creature progression.
9. Evolution results.
10. Gene results or gene state changes.
11. Prestige state.
12. World progression.
13. Collection progress.
14. Save data.

The client may request actions, but the server must validate and resolve them.

The client must never be trusted to:

1. Award rewards.
2. Set currency.
3. Set inventory.
4. Set progression.
5. Set collection completion.
6. Set combat results.
7. Set boss phase state.
8. Set save data directly.

Server authority must be preserved even when the client predicts, animates, or previews outcomes.

## 5. Data-Driven Gameplay

Project Genesis gameplay must be driven by documented data structures.

Data-driven gameplay means:

1. Combat stats come from approved data.
2. Skill definitions come from approved data.
3. Cooldown values come from approved data.
4. Recommended Power values or formulas come from approved data.
5. Creature definitions come from approved data.
6. Evolution definitions come from approved data.
7. Gene definitions come from approved data.
8. Economy currencies, sources, and sinks come from approved data.
9. World and encounter definitions come from approved data.
10. Save structure follows approved schema.

Implementation must not hardcode gameplay tuning values.

Data ownership rules:

1. Static definitions are read-only at runtime unless a documented content pipeline says otherwise.
2. Player save state is mutable only through server-owned services.
3. Runtime state is temporary and must not be confused with persisted state.
4. Client state is a presentation copy only.
5. Schema changes must be documented before implementation.

## 6. Modular Systems

Systems must be modular and responsibility-driven.

A module or service should have one clear purpose.

Approved module responsibility categories include:

1. Data access.
2. Save orchestration.
3. Combat orchestration.
4. Creature ownership.
5. Progression state.
6. Economy state.
7. Collection state.
8. World progression.
9. Remote contract handling.
10. UI view logic.
11. Client-side controllers.

Modular systems must avoid:

1. Circular dependencies.
2. Hidden global state.
3. Cross-system private state access.
4. UI-owned gameplay rules.
5. Data definitions with side effects.
6. Monolithic scripts that own unrelated concerns.
7. Utility modules that become dumping grounds.

Dependency direction should be explicit and documented when a system depends on another system.

## 7. Event-Driven Communication

Project Genesis uses event-driven communication where systems need to react to state changes.

Event-driven communication should be used for:

1. Server system notifications.
2. Client UI updates from state changes.
3. Battle state updates.
4. Progression changes.
5. Collection updates.
6. Economy changes.
7. Save lifecycle notifications.

Event rules:

1. Events should describe something that happened.
2. Events should have documented payload shape.
3. Events should not carry hidden authority.
4. Events should not bypass service validation.
5. Events should not create circular command chains.
6. Events should be named consistently.
7. Events crossing the network boundary must be treated as remote contracts.

Command-like requests and event-like notifications must remain distinct.

## 8. Service-Based Backend

The backend should be organized around server services.

Server services are authoritative owners of system behavior and state changes.

Expected service categories include:

1. Player session service.
2. Save service.
3. Data registry service.
4. Combat service.
5. Creature service.
6. Progression service.
7. Economy service.
8. Collection service.
9. World progression service.
10. Remote gateway or networking service.

This list defines architectural categories, not required implementation names.

Service rules:

1. Services expose narrow public APIs.
2. Services validate inputs before mutating state.
3. Services do not expose private state directly.
4. Services coordinate through explicit calls or events.
5. Services own server-side business rules.
6. Services must not depend on client UI.
7. Services must not rely on client trust.
8. Services must keep persistence writes behind the save boundary.

No service should become a general-purpose manager for unrelated systems.

## 9. MVC-Inspired Client Architecture

The client follows an MVC-inspired structure.

The pattern is inspired by Model-View-Controller, not a requirement to implement a strict framework.

### Client Model

Client models are local representations of server-provided state.

Client models may store:

1. Current visible player state.
2. Current visible creature state.
3. Current visible battle state.
4. Current visible economy state.
5. Current visible collection state.
6. UI-specific derived display state.

Client models must not be authoritative.

### Client View

Views render UI and visual presentation.

Views may:

1. Display state.
2. Display buttons and controls.
3. Play local presentation effects.
4. Show feedback for server results.

Views must not:

1. Own gameplay rules.
2. Mutate server state directly.
3. Calculate authoritative rewards.
4. Calculate final combat outcomes.

### Client Controller

Controllers coordinate input, local state updates, and server requests.

Controllers may:

1. Listen to player input.
2. Request server actions.
3. Update client models from server responses.
4. Tell views when to refresh.
5. Coordinate screen flow.

Controllers must not become server-authoritative systems.

## 10. Gameplay and UI Separation

Gameplay logic and UI must remain separate.

Gameplay logic belongs in server services or approved shared pure modules.

UI logic belongs in client views and controllers.

Separation rules:

1. UI may display combat state but must not resolve combat.
2. UI may display currency but must not award currency.
3. UI may display collection progress but must not mark collection complete.
4. UI may display evolution options but must not perform evolution.
5. UI may display gene data but must not roll or mutate genes.
6. UI may display prestige state but must not apply prestige.
7. UI may send requests only through documented remote contracts.
8. UI must handle rejected requests gracefully.

Any implementation that places gameplay authority in UI violates the architecture.

## 11. Shared Contracts

Shared contracts define the language used between systems.

Shared contracts may include:

1. Stable IDs.
2. Schema names.
3. Enum-like values.
4. Remote request names.
5. Remote response names.
6. Event payload shapes.
7. Error code categories.

Shared contracts must be:

1. Stable.
2. Documented.
3. Versioned when persistence or network compatibility is affected.
4. Safe for client visibility.
5. Free of server-only secrets.

Shared contracts must not contain final reward authority, save mutation authority, or hidden gameplay outcomes.

## 12. Networking Model

Networking must be explicit and reviewable.

Network communication categories:

1. Client request to server.
2. Server response to client.
3. Server event notification to client.
4. Server state snapshot to client.

Remote contract rules:

1. Every remote must have a documented purpose.
2. Every remote must have a documented payload shape.
3. Every remote must have documented validation rules.
4. Every remote must have documented failure behavior.
5. Every remote must be owned by a server service or remote gateway.
6. Every remote must preserve server authority.
7. Remote calls must not expose unnecessary server internals.
8. Remote events must not become unbounded spam channels.

The client may request an action. The server decides whether the action is valid and what result occurs.

## 13. Persistence Boundary

Persistence must be isolated behind a save boundary.

Persistence rules:

1. Save loading is server-owned.
2. Save writing is server-owned.
3. Save mutation occurs through server services.
4. Save data must follow `docs/DATA_SCHEMA.md`.
5. Save lifecycle and migration rules must follow `docs/SAVE_SYSTEM.md`.
6. Client code must not write save data.
7. Runtime combat state must not be persisted unless explicitly documented.
8. Failed save operations must be handled conservatively.
9. Data migrations must be documented before implementation.

No gameplay system should write raw persistence data directly unless it is the approved save service.

## 14. Combat Architecture Boundary

Combat architecture must follow `docs/COMBAT.md`.

Combat authority belongs on the server.

Combat architecture must support:

1. Auto battle.
2. Action Time Bar state.
3. SPD-driven gauge fill.
4. Cooldown-based skills.
5. No mana.
6. 1v1 Story Mode.
7. 3v3 Boss and Challenge modes.
8. Recommended Power as guidance only.
9. DEF percentage reduction.
10. Simplified MVP damage formulas.
11. Full creature healing after battle.
12. Simple enemy AI.
13. Boss phases.
14. Auto Retry.

The combat system must not depend on UI to resolve outcomes.

The client may display combat state, but the server must own battle truth.

## 15. Economy and Progression Boundary

Economy and progression are server-owned.

Economy architecture must ensure:

1. Currency changes are generated by approved server-side sources.
2. Costs are validated before spending.
3. Rewards are issued only after server-approved outcomes.
4. Economy data follows `docs/ECONOMY.md` and `docs/DATA_SCHEMA.md`.

Progression architecture must ensure:

1. Progress changes are server-validated.
2. Unlocks are not client-awarded.
3. World progression is not client-owned.
4. Creature progression follows documented data.
5. Progression saves follow the save boundary.

Economy and progression must not be implemented inside UI modules.

## 16. Folder Architecture Guidance

Source code folders have not been created yet.

When source folders are introduced, they must preserve these architectural categories:

1. Server-only systems.
2. Client-only systems.
3. Shared definitions and contracts.
4. Static data definitions.
5. Tests, if the project test structure is introduced.

Folder guidance:

1. Server services belong in a server-only location.
2. Client controllers and views belong in a client-only location.
3. Shared contracts belong in a shared location.
4. Static data definitions must be clearly separated from runtime logic.
5. UI modules must be clearly separated from gameplay services.
6. Test files must not be mixed into production runtime folders unless the project tooling requires it.

No source folder structure is approved by this document until an implementation task creates it intentionally.

## 17. Naming Guidance

Naming should communicate architectural ownership.

Preferred naming concepts:

1. `Service` for server-owned authoritative systems.
2. `Controller` for client-owned coordination.
3. `View` for client-owned UI presentation.
4. `Model` for client-side local state representation.
5. `Definition` for static content data.
6. `Schema` for data structure descriptions.
7. `State` for runtime state containers.
8. `Gateway` for network boundary coordination if used.

Names must not imply authority where none exists.

For example, a client-side module should not be named as though it owns combat truth, economy truth, or save truth.

Final naming conventions must remain consistent with `agents/AGENTS.md`.

## 18. Validation and Security

Validation is part of architecture, not an optional detail.

Server validation must cover:

1. Player identity.
2. Request eligibility.
3. Ownership of referenced creatures or resources.
4. Encounter availability.
5. Combat action validity.
6. Economy source and sink validity.
7. Progression unlock validity.
8. Save data compatibility.
9. Remote payload types.
10. Remote payload size and frequency where relevant.

Failure behavior:

1. Invalid requests fail closed.
2. Invalid requests must not mutate authoritative state.
3. Repeated invalid requests may be rate-limited or handled according to future security policy.
4. Client UI should receive safe failure information when appropriate.
5. Internal validation details should not expose exploitable server information.

## 19. Testing and Verification Architecture

Testing architecture must prioritize high-risk server-owned behavior.

Highest-priority verification areas:

1. Data validation.
2. Remote validation.
3. Save migration and compatibility.
4. Combat outcome authority.
5. Economy mutation.
6. Progression unlocks.
7. Collection state.
8. Client UI separation from gameplay authority.

Testing strategy may include:

1. Unit tests for pure logic.
2. Integration tests for service interactions.
3. Manual Roblox Studio verification for runtime behavior.
4. Review checklists for remote contracts and save changes.

If automated tests are not yet available, implementation tasks must document manual verification steps.

## 20. Explicitly Not Defined Here

This document does not define:

1. Lua or Luau implementation.
2. Concrete ModuleScript contents.
3. Exact folder names.
4. Exact remote names.
5. Exact service APIs.
6. Exact UI screens.
7. Exact combat formulas.
8. Exact economy values.
9. Exact save implementation.
10. Exact test framework.
11. Build tooling.
12. Deployment workflow.

Those details require future approved implementation tasks and must remain aligned with this architecture.

## 21. Open Questions

The following architecture details remain unresolved:

1. Final source folder structure.
2. Final framework or no-framework decision.
3. Final service lifecycle pattern.
4. Final remote contract naming convention.
5. Final event naming convention.
6. Final data registry loading strategy.
7. Final save service architecture.
8. Final UI state management approach.
9. Final test framework.
10. Final Roblox Studio verification workflow.
