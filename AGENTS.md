# AGENTS.md

Before starting any planning, coding, or task execution in this repository, all AI agents must follow this sequence:

1. **Synchronize with the Team**: Run `git pull` immediately before writing a plan or starting a task to fetch remote updates from other team members and keep in sync with the official repository at https://github.com/AgnesLorem/Project_Genesis.
2. **Check Project Status**: Read [docs/CHANGELOG.md](file:///f:/Project_Genesis/docs/CHANGELOG.md) and [docs/MVP_CHECKLIST.md](file:///f:/Project_Genesis/docs/MVP_CHECKLIST.md) to inspect what has already been implemented or changed recently, preventing duplicate work.
3. **Follow the Technical Constitution**: Read and follow the guidelines in [Jarvis_Genesis/.DaoGang/Jarvis.md](file:///f:/Project_Genesis/Jarvis_Genesis/.DaoGang/Jarvis.md) as the absolute technical, style, and Rojo sync guide for Project Genesis.
4. **User Review Before Push**: Once coding and local testing are complete, present a summary of the changes and playtest verification results to the user. Do **NOT** push commits to the remote GitHub repository until the user has explicitly reviewed and approved the implementation.

---

## Technical Constitution Summary

### 1. Developer Persona & Strategy (Ponytail style)
- Speak with laconic precision. No conversational filler or explanations of how you will solve a problem. Just execute.
- Always apply the **Ladder of Laziness**:
  1. Elimination (YAGNI).
  2. Reusability (inspect `src/shared/` first).
  3. Standard Library.
  4. Platform/Framework features.
  5. Existing dependencies.
  6. Custom code (only if 1-5 are exhausted).
- Keep changes minimal and scoped. Never edit unrelated files.

### 2. Code style & Architecture Rules
- Rojo client/server boundaries under `src/`:
  - `src/server/`: Server-only authoritative systems.
  - `src/client/`: Local UI views and inputs.
  - `src/shared/`: Shared contracts, formats, schemas, and types.
- **Server Authority**: The server owns all critical state, progression, currency, and combat calculation.
- Metatable constructors `.new(...)` must throw errors (`error("reason")`) instead of returning `nil` when validation fails.
- Standard categories for variables and requirements:
  ```luau
  --// Raw Requirings \\--
  --// Requirings \\--
  --// Variables \\--
  --// Service \\--
  ```
- **Registry Teardown**: Reusable/dynamic instances and helpers must implement the idempotent Registry lifecycle pattern (`Pause()`, `Resume()`, `Destroy()`). Track connection lists (`Connections`) and task lists (`Tasks`) explicitly. Maid/Janitor are banned.

### 3. Verification & Code Quality Pipeline
- Format all code with StyLua: `stylua src/ configs/`
- Lint code with Selene: `selene src/`
- Validate configurations: `python tests/unit/mvp015_content_validation.py`
- Verify gameplay-sensitive code in Roblox Studio Play Solo mode using `start_stop_play` and report verification logs.
