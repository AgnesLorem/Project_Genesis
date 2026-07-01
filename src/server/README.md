# Server Source

Purpose: Server-only Roblox systems.

This folder is reserved for authoritative services, persistence boundaries, network validation, data access, and runtime orchestration.

Current status: foundation placeholder only.

## Rules

- Server code owns authoritative gameplay state.
- Server code must validate all client requests.
- Server services must keep narrow responsibilities.
- No gameplay service is implemented in this task.
