# UI Screen Guide

## Purpose

This document serves as handoff notes and an integration guide for future feature screens (Combat, Creature, World) to plug into the MVP-003 UI framework without redesigning the foundation.

## 1. Screen Registration

Before a screen can be displayed, it must be registered with the `ScreenRouter`.
- Call `ScreenRouter.registerScreen(screenId, screenGui)` during client initialization.
- `screenId` must be a stable, unique string (e.g., `"CombatScreen"`, `"CreatureRoster"`).
- `screenGui` should be the root `ScreenGui` object for that feature.

## 2. Showing a Screen

To navigate to a screen:
- Call `ScreenRouter.switchScreen(screenId)`.
- The router will hide the current screen and show the requested screen.
- Unknown screen IDs will be rejected safely.
- The router will broadcast a screen changed event so other controllers can react.

## 3. Accessing State

Feature screens should read data from `ClientState` instead of storing their own copies of server data.
- `ClientState` is a presentation cache.
- Call `ClientState.get(key)` to retrieve the latest server-approved snapshot.
- Listen for updates if necessary (implementation dependent, usually handled by controllers).

## 4. Using Standard Components

Do not build custom buttons or panels from scratch if a standard component suffices.
Use `UIComponents` for foundational elements:
- `BasePanel`
- `BaseButton`
- `BaseLabel`
- `BaseContainer`
- `BaseModal` (placeholder)

*Note: These components are purely functional layouts without complex themes or animations. Do not add gameplay-specific widgets (like inventory or creature cards) to `UIComponents`.*

## 5. Handling Network States

When waiting for the server or handling failures, use `StatePatterns` to maintain a consistent UX:
- `StatePatterns.Loading(parent)`: Show when a request is in flight.
- `StatePatterns.Empty(parent, message)`: Show when a list or collection has no items.
- `StatePatterns.Error(parent, message)`: Show when an operation fails.
- `StatePatterns.Disconnected(parent)`: Show when the server connection drops.
- `StatePatterns.Retry(parent, callback)`: Show when a failure can be retried.

## 6. Architectural Reminders

- **No Gameplay Logic in UI**: Do not calculate stats, validate resources, or decide outcomes in UI code.
- **No Authority**: The UI must never mutate authoritative gameplay state. It only requests actions from the server and displays the returned/cached results.
