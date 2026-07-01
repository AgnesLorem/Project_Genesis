# Source Folder

Purpose: Roblox runtime source root.

This folder separates server-only systems, client-only presentation, and shared contracts.

Current status: foundation placeholder only.

Do not add gameplay systems here unless an implementation task is approved and the relevant documentation has been read.

## Ownership

- Server source: authoritative backend systems.
- Client source: presentation and input coordination only.
- Shared source: client-safe contracts, schemas, enums, and utilities.

## Rules

- Server owns gameplay truth.
- Client owns presentation.
- Shared code must not contain server-only authority.
- Gameplay values must come from `configs/`, not source code.
- No combat, creature, economy, save, or UI screen implementation belongs in this foundation task.
