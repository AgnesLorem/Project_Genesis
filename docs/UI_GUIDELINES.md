# UI Guidelines

## Purpose

This document defines interface standards, interaction principles, screen ownership, and review criteria for Project Genesis UI.

## Status

- Status: Active Draft
- Scope: MVP UI foundation
- Owner: Technical Direction
- Last Updated: 2026-06-28
- Review Cadence: Before implementing new UI screens or systems

## Table of Contents

- [1. Server Authority Boundary](#1-server-authority-boundary)
- [2. MVC Boundaries](#2-mvc-boundaries)
- [3. Screen Ownership & Routing](#3-screen-ownership--routing)
- [4. Naming Convention](#4-naming-convention)
- [5. Folder Ownership](#5-folder-ownership)
- [6. State Flow & UI Lifecycle](#6-state-flow--ui-lifecycle)

## 1. Server Authority Boundary

UI is for presentation only. It must never become authoritative gameplay state.
- UI only displays server-approved snapshots.
- UI may send requests to the server, but the server resolves outcomes.
- UI must not calculate rewards, stats, or final combat outcomes.
- Any UI module modifying gameplay state is an architectural violation.

## 2. MVC Boundaries

The client architecture is MVC-inspired:
- **Models (State)**: e.g., `ClientState`. A presentation cache only. Mirrors server-approved snapshots. Never authoritative.
- **Views**: e.g., `UIComponents`, `StatePatterns`. Pure rendering. Uses standard Roblox UI instances (ScreenGui, Frame, TextButton) with Luau only. No external frameworks.
- **Controllers**: e.g., `ScreenRouter`. Coordinates input, local state updates, and server requests. Does not own gameplay logic.

## 3. Screen Ownership & Routing

The `ScreenRouter` is strictly for routing.
- Registers screens.
- Switches the active screen.
- Rejects unknown screen IDs.
- Broadcasts screen changed events.
- Contains NO gameplay logic.

## 4. Naming Convention

- Use `PascalCase` for UI modules (e.g., `ScreenRouter`, `ClientState`).
- Prefix base components with `Base` to avoid conflicts and signify foundation (e.g., `BasePanel`, `BaseButton`).
- Standardized presentation states: `Loading`, `Empty`, `Error`, `Disconnected`, `Retry`.

## 5. Folder Ownership

- `src/client/models/`: Presentation state caching (e.g., `ClientState`).
- `src/client/controllers/`: Input coordination and routing (e.g., `ScreenRouter`).
- `src/client/views/`: Visual components, layouts, and rendering logic (e.g., `UIComponents`, `StatePatterns`).

## 6. State Flow & UI Lifecycle

1. Server broadcasts state update or responds to request.
2. Controller receives data and updates `ClientState` (presentation cache).
3. `ClientState` update triggers UI view refresh.
4. Views render the cached state.
5. While waiting for server response, views display standardized states (Loading, Disconnected). If failed, display Error/Retry.
