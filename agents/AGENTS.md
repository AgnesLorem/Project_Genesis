# AGENTS.md

## Purpose

This document is the operating constitution for every AI assistant working on Project Genesis.

It defines the rules, constraints, responsibilities, and review standards that govern all AI-assisted design, documentation, implementation, and maintenance work in this repository.

Every assistant must treat this document as mandatory project policy.

No assistant may override these rules without explicit human approval and a documented change.

## Status

- Status: Active Draft
- Owner: Project Leadership
- Last Updated: TBD
- Review Cadence: Every milestone, every major architecture change, and every production phase transition
- Authority Level: Repository-wide policy

## Table of Contents

- [1. Constitutional Priority](#1-constitutional-priority)
- [2. Project Philosophy](#2-project-philosophy)
- [3. Documentation Is the Source of Truth](#3-documentation-is-the-source-of-truth)
- [4. Required Reading Before Work](#4-required-reading-before-work)
- [5. AI Responsibilities](#5-ai-responsibilities)
- [6. General Operating Rules](#6-general-operating-rules)
- [7. Coding Rules](#7-coding-rules)
- [8. Documentation Rules](#8-documentation-rules)
- [9. Scope Control](#9-scope-control)
- [10. Feature Creep Prevention](#10-feature-creep-prevention)
- [11. Naming Conventions](#11-naming-conventions)
- [12. Folder Ownership](#12-folder-ownership)
- [13. Review Process](#13-review-process)
- [14. Pull Request Mindset](#14-pull-request-mindset)
- [15. Data-Driven Architecture](#15-data-driven-architecture)
- [16. Roblox Best Practices](#16-roblox-best-practices)
- [17. Server Authoritative Design](#17-server-authoritative-design)
- [18. Modular Architecture](#18-modular-architecture)
- [19. Gameplay Value Policy](#19-gameplay-value-policy)
- [20. File Modification Discipline](#20-file-modification-discipline)
- [21. Undocumented Feature Policy](#21-undocumented-feature-policy)
- [22. Implementation Workflow](#22-implementation-workflow)
- [23. Agent Role Expectations](#23-agent-role-expectations)
- [24. Quality Gates](#24-quality-gates)
- [25. Conflict Resolution](#25-conflict-resolution)
- [26. Anti-Patterns](#26-anti-patterns)
- [27. Definition of Done](#27-definition-of-done)
- [28. Maintenance of This Document](#28-maintenance-of-this-document)

## 1. Constitutional Priority

1. This file applies to every AI assistant working in Project Genesis.
2. This file applies to documentation, code, assets, task files, reviews, prompts, and automation.
3. This file does not replace human direction.
4. Human project leadership has final authority.
5. Assistants must follow this file unless a human explicitly instructs otherwise.
6. If a human instruction conflicts with this file, the assistant must identify the conflict.
7. If a conflict is identified, the assistant must ask for confirmation before proceeding.
8. If this file conflicts with a more specific task file, this file controls unless the task file has explicit approval.
9. If documentation conflicts with implementation, documentation must be reconciled before new work continues.
10. If requirements are unclear, assistants must clarify or make the smallest reversible assumption.
11. Assistants must not silently reinterpret project policy.
12. Assistants must not create hidden rules outside this document.
13. Assistants must not rely on private memory as project authority.
14. Repository documentation is the durable project memory.
15. Every meaningful decision must be reflected in the appropriate documentation.

## 2. Project Philosophy

1. Project Genesis is an AI-assisted Roblox game built for long-term production.
2. The repository must remain understandable to humans and AI assistants.
3. Documentation comes before implementation whenever design intent is not settled.
4. Implementation must express documented design, not invent design.
5. Systems should be built to evolve deliberately, not accumulate accidental behavior.
6. The project favors clear contracts over clever shortcuts.
7. The project favors modular systems over large monolithic scripts.
8. The project favors data-driven configuration over hardcoded gameplay values.
9. The project favors server authority over client trust.
10. The project favors maintainable Roblox patterns over experimental architecture.
11. The project favors small, reviewable changes over large speculative rewrites.
12. The project favors explicit ownership over ambiguous responsibility.
13. The project favors documented tradeoffs over hidden assumptions.
14. The project favors production discipline over prototype convenience.
15. The project favors consistency across assistants, even when individual assistants prefer different styles.

## 3. Documentation Is the Source of Truth

1. The `docs/` folder is the canonical source for game design, technical design, and production direction.
2. `docs/GDD_MASTER.md` is the primary design index.
3. `docs/TECH_ARCHITECTURE.md` is the primary technical architecture reference.
4. `docs/DATA_SCHEMA.md` is the primary data structure reference.
5. `docs/SAVE_SYSTEM.md` is the primary persistence reference.
6. `docs/COMBAT.md` is the primary combat reference.
7. `docs/PROGRESSION.md` is the primary progression reference.
8. `docs/ECONOMY.md` is the primary economy reference.
9. `docs/UI_GUIDELINES.md` is the primary UI reference.
10. `docs/ART_BIBLE.md` is the primary visual direction reference.
11. `docs/ROADMAP.md` is the primary milestone and sequencing reference.
12. `docs/CHANGELOG.md` is the primary record of meaningful project changes.
13. `agents/`, `tasks/`, `reviews/`, `prompts/`, and `assets/` each hold their named production responsibilities.
14. If a system exists in code, it must have a corresponding documentation reference.
15. If documentation promises a system, implementation must eventually conform or the documentation must be updated.
16. Undocumented implementation behavior is considered project debt.

## 4. Required Reading Before Work

1. **Always run `git pull`** before planning or coding to synchronize your workspace with remote team commits and keep in sync with the official repository at https://github.com/AgnesLorem/Project_Genesis.
2. **Always read `docs/CHANGELOG.md` and `docs/MVP_CHECKLIST.md`** to verify recent implementation changes and prevent duplicate coding work.
3. **Always read `Jarvis_Genesis/.DaoGang/Jarvis.md`** for coding standards, Luau style rules, and Roblox Studio MCP sync workflows.
4. Always read `docs/GDD_MASTER.md` before coding.
5. Always read the relevant domain document before coding.
6. Always read `docs/TECH_ARCHITECTURE.md` before architecture or code structure changes.
7. Always read `docs/DATA_SCHEMA.md` before touching data models, save data, replicated data, or content tables.
8. Always read `docs/SAVE_SYSTEM.md` before touching persistence, loading, saving, migration, or recovery logic.
9. Always read `docs/UI_GUIDELINES.md` before UI implementation or UI redesign.
10. Always read `docs/ECONOMY.md` before changing rewards, prices, currencies, sinks, sources, or monetization-adjacent systems.
11. Always read `docs/PROGRESSION.md` before changing levels, unlocks, XP, milestones, or player growth.
12. Always read `docs/COMBAT.md` before changing combat behavior, damage, targeting, enemies, abilities, or encounters.
13. Always read `docs/ROADMAP.md` before changing milestone scope.
14. Always read the relevant task file in `tasks/` before implementation.
15. Always read related review notes in `reviews/` when revisiting a reviewed area.
16. If required documentation is missing, create or update the documentation before implementation.
17. If required documentation is ambiguous, ask for clarification or document the assumption.
18. Do not begin coding from memory alone.

## 5. AI Responsibilities

1. Assistants are responsible for preserving project intent.
2. Assistants are responsible for reading before editing.
3. Assistants are responsible for making small, coherent changes.
4. Assistants are responsible for respecting existing work.
5. Assistants are responsible for documenting assumptions.
6. Assistants are responsible for updating affected documentation after implementation.
7. Assistants are responsible for identifying scope creep.
8. Assistants are responsible for refusing undocumented feature expansion.
9. Assistants are responsible for protecting data integrity.
10. Assistants are responsible for protecting server authority.
11. Assistants are responsible for protecting maintainability.
12. Assistants are responsible for preserving naming consistency.
13. Assistants are responsible for keeping generated work reviewable.
14. Assistants are responsible for calling out risks before they become hidden defects.
15. Assistants are responsible for leaving the repository easier to understand than they found it.
16. Assistants must surface uncertainty rather than bury it in implementation.
17. Assistants must not present speculative behavior as approved design.
18. Assistants must not create mechanics without documented approval.
19. Assistants must not make production decisions silently.

## 6. General Operating Rules

1. Work from the requested task, not from curiosity.
2. Keep changes tightly scoped.
3. Do not modify unrelated files.
4. Do not reformat unrelated files.
5. Do not rename files without a task requirement.
6. Do not move folders without a documented architecture reason.
7. Do not delete files unless explicitly authorized or clearly obsolete under the task.
8. Do not overwrite human work.
9. Do not assume uncommitted changes are safe to discard.
10. Do not add dependencies without documented justification.
11. Do not introduce new frameworks without approval.
12. Do not add background services, automation, or tooling without approval.
13. Do not add hidden behavior.
14. Do not add debug shortcuts to production paths.
15. Do not leave temporary files in the repository.
16. Do not treat tests as optional when behavior changes.
17. Do not treat documentation as optional when implementation changes.
18. Do not mark work complete until verification has been performed or the verification gap is documented.
19. Do not hide failed commands, failed tests, or incomplete checks.

## 7. Coding Rules

1. Do not write code until the relevant design is documented.
2. Do not write Roblox gameplay code unless the task explicitly requires implementation.
3. Keep code modular.
4. Keep module responsibilities narrow.
5. Prefer clear interfaces between systems.
6. Prefer explicit dependencies over global lookups.
7. Prefer configuration data over embedded gameplay constants.
8. Prefer named constants for technical constants.
9. Keep gameplay values in approved data definitions.
10. Keep server logic separate from client presentation logic.
11. Keep shared contracts separate from server-only behavior.
12. Do not trust client-submitted gameplay outcomes.
13. Do not allow clients to decide rewards, damage, inventory, currency, progression, or save state.
14. Do not duplicate business logic across client and server unless it is a documented prediction or presentation strategy.
15. Avoid circular dependencies.
16. Avoid large modules that own unrelated concerns.
17. Avoid hidden side effects during module loading.
18. Avoid implicit initialization order unless documented.
19. Avoid magic strings when a shared identifier registry is appropriate.
20. Avoid magic numbers for gameplay tuning.
21. Validate external inputs, remote payloads, persisted data, and data crossing trust boundaries.
22. Fail safely when validation fails.
23. Do not swallow critical errors silently.
24. Do not introduce uncontrolled loops, tasks, connections, or lifecycle leaks.
25. Use Roblox services intentionally and consistently.
26. Keep client code responsive, server code authoritative, and persistence code conservative.
27. Keep public APIs stable unless a task requires changing them.
28. Update callers when changing APIs.
29. Add or update tests where the project test structure supports it.
30. If tests cannot be added yet, document the verification gap.

## 8. Documentation Rules

1. Always update documentation after implementation.
2. Documentation updates must be part of the same change as the implementation when practical.
3. Documentation must describe what is true, not what might be true someday.
4. Future ideas must be clearly marked as proposals, placeholders, or open questions.
5. Do not mix approved requirements with brainstorming.
6. Do not bury decisions in chat-only context.
7. Record important decisions in the relevant document.
8. Record architecture, data, persistence, design, roadmap, and changelog decisions in their owning documents.
9. Keep task-specific details in `tasks/`.
10. Keep review findings in `reviews/`.
11. Keep agent operating guidance in `agents/`.
12. Use clear headings, stable terminology, and consistent naming across all documents.
13. Avoid vague claims such as "improved", "better", or "optimized" without context.
14. Include assumptions when they affect implementation.
15. Include acceptance criteria for scoped tasks.
16. Include dependencies when work relies on another system.
17. Include open questions when decisions are unresolved.
18. Remove or update stale placeholders when real information is added.
19. Do not document features as approved unless they are approved.
20. Do not imply implementation exists before it does.
21. Do not leave documentation inconsistent with code.
22. Treat documentation changes as production changes.

## 9. Scope Control

1. Every task must have a defined objective.
2. Every implementation change must map to the objective.
3. Work outside the objective requires explicit approval.
4. If a discovered issue blocks the task, document it and address only what is necessary.
5. If a discovered issue does not block the task, record it as follow-up.
6. Do not combine unrelated fixes into one change.
7. Do not add polish that changes behavior unless requested.
8. Do not expand systems because expansion seems convenient.
9. Do not implement future-proofing that has no documented need.
10. Do not create generic frameworks before there are real project requirements.
11. Do not add optional features while implementing required features.
12. Do not redesign adjacent systems without approval.
13. Do not change balance values while changing architecture unless required.
14. Do not change architecture while changing copy unless required.
15. Do not change UI flow while changing data schema unless required.
16. Keep task boundaries visible in the final summary.
17. Keep out-of-scope discoveries separate from completed work.
18. Ask for approval before broadening scope.
19. Prefer a smaller complete change over a larger partial change.
20. Treat scope control as a quality requirement.

## 10. Feature Creep Prevention

1. Never add undocumented features.
2. Never add mechanics that are not in the GDD or an approved task.
3. Never add currencies that are not in `docs/ECONOMY.md`.
4. Never add progression systems that are not in `docs/PROGRESSION.md`.
5. Never add combat behavior that is not in `docs/COMBAT.md`.
6. Never add save fields that are not in `docs/DATA_SCHEMA.md` and `docs/SAVE_SYSTEM.md`.
7. Never add UI screens that are not in `docs/UI_GUIDELINES.md` or an approved task.
8. Never add monetization hooks without explicit approval.
9. Never add analytics hooks without explicit approval.
10. Never add admin tools without explicit approval.
11. Never add cheat commands without explicit approval.
12. Never add debug-only gameplay paths without a documented removal or gating plan.
13. Never add placeholder mechanics that can be mistaken for approved mechanics.
14. Never add speculative content pipelines.
15. If a feature seems necessary, document the need first.
16. If a feature is requested informally, record it in the appropriate task or design document.
17. If a feature conflicts with current documentation, resolve the documentation first.
18. If a feature is experimental or temporary, label its status and review path.

## 11. Naming Conventions

1. Use names that describe responsibility.
2. Use consistent terminology from the GDD.
3. Do not invent synonyms for established project terms.
4. Use `PascalCase` for Roblox ModuleScript-style module names when the project uses that convention.
5. Use `camelCase` for local variables and function parameters when the project uses that convention.
6. Use `UPPER_SNAKE_CASE` for true constants when the project uses that convention.
7. Use clear suffixes for services, controllers, stores, definitions, and views when those patterns are established.
8. Use `Service` only for server-owned authoritative systems when appropriate.
9. Use `Controller` only for client-owned presentation or input coordination when appropriate.
10. Use `Definition` for static content data when appropriate.
11. Use `Config` for technical configuration when appropriate.
12. Use `Schema` for data shape definitions when appropriate.
13. Use `State` for runtime state containers when appropriate.
14. Use `View` for UI presentation units when appropriate.
15. Use `Adapter` for boundary translation code when appropriate.
16. Do not name modules after implementation details unless that detail is the module's role.
17. Do not use vague names such as `Manager`, `Handler`, or `Helper` unless the project has approved that naming style.
18. Do not use abbreviations unless they are common and documented.
19. Do not use inconsistent capitalization for the same concept.
20. Do not rename public identifiers without updating documentation and callers.
21. Folder names should remain stable once referenced by documentation.
22. Task, review, prompt, and asset names should identify their purpose when created.

## 12. Folder Ownership

1. `docs/` is owned by project documentation and design authority.
2. `agents/` is owned by AI collaboration and workflow authority.
3. `tasks/` is owned by production planning and task tracking.
4. `reviews/` is owned by review, audit, and approval history.
5. `prompts/` is owned by reusable AI workflow prompts.
6. `assets/` is owned by source assets, references, and asset planning materials.
7. Source code folders must not be introduced without architecture documentation.
8. Test folders must follow the project architecture when introduced.
9. Generated output folders must be documented before use.
10. Temporary work must not be committed to permanent folders.
11. Do not put design decisions only in task files.
12. Do not put task execution notes only in design documents.
13. Do not put review findings in changelog entries only.
14. Do not put reusable prompts in chat transcripts only.
15. Do not put source assets in code folders unless the architecture requires it.
16. Do not put code in `docs/` or gameplay implementation in `agents/`.
17. Do not put active task definitions in `reviews/` or final authority documents in `prompts/`.
18. Keep folder responsibilities clean and predictable.

## 13. Review Process

1. Every meaningful implementation change should be reviewed.
2. Every architecture change must be reviewed.
3. Every data schema change must be reviewed.
4. Every save system change must be reviewed.
5. Every economy change must be reviewed.
6. Every combat balance change must be reviewed.
7. Every progression change must be reviewed.
8. Every security-sensitive change must be reviewed.
9. Every server authority boundary must be reviewed.
10. Every RemoteEvent or RemoteFunction contract must be reviewed.
11. Every persistence migration must be reviewed.
12. Reviews must check correctness.
13. Reviews must check scope control.
14. Reviews must check documentation alignment.
15. Reviews must check server trust boundaries.
16. Reviews must check data ownership.
17. Reviews must check naming consistency.
18. Reviews must check maintainability.
19. Reviews must check test or verification coverage.
20. Reviews must identify open risks.
21. Review findings should be recorded in `reviews/` when they are substantive.
22. Review comments should be actionable and reference files or sections when possible.
23. Review comments should distinguish blocking issues from suggestions.
24. Assistants must not mark reviewed work complete while blocking findings remain unresolved.

## 14. Pull Request Mindset

1. Every change should be understandable as a pull request.
2. A change should have a clear title, reason, scope, and verification notes.
3. A change should list documentation updates and known gaps.
4. A change should avoid unrelated cleanup.
5. A change should avoid hidden behavior changes.
6. A change should avoid broad rewrites without approval.
7. A change should be small enough to review.
8. A change should preserve working behavior unless intentionally changing it.
9. A change should explain migrations when data changes.
10. A change should explain compatibility risks when APIs change.
11. A change should explain user-facing effects when UI changes.
12. A change should explain balance implications when gameplay values change.
13. A change should explain security implications when trust boundaries change.
14. A change should not rely on chat context for review.
15. A change should leave durable evidence in files.
16. A change should be ready for another assistant to continue.

## 15. Data-Driven Architecture

1. Gameplay systems should read approved data rather than embed tuning values.
2. Static content should live in structured definitions when the architecture supports it.
3. Runtime state should be separate from static definitions.
4. Save data should be separate from runtime-only state.
5. Client presentation data should be separate from server authority data.
6. Data schemas must have documented ownership.
7. Data schemas must have documented versioning once persistence exists.
8. Data migrations must be documented before implementation.
9. Data validation must occur at system boundaries.
10. Data defaults must be explicit.
11. Data fallbacks must be documented.
12. Data IDs must be stable and must not depend on display names.
13. Display names may change without breaking save data.
14. Balance, economy, progression, and combat tables must be reviewed before use.
15. Do not hardcode gameplay values in procedural logic.
16. Do not duplicate the same gameplay value in multiple modules.
17. Do not allow client-owned data to become authoritative.
18. Do not persist data that can be safely derived unless documented.
19. Treat data shape changes as compatibility risks.

## 16. Roblox Best Practices

1. Respect Roblox client-server boundaries.
2. Use server scripts for authoritative game state.
3. Use client scripts for input, camera, local UI, and presentation.
4. Use shared modules only for safe shared contracts, utilities, and definitions.
5. Avoid placing secret or authoritative logic in client-accessible code.
6. Validate all remote calls on the server.
7. Rate-limit or otherwise guard spam-sensitive remote interactions when needed.
8. Avoid excessive RemoteEvent traffic.
9. Avoid unnecessary replication.
10. Avoid storing large mutable state in replicated locations without reason.
11. Use Roblox services through clear access patterns.
12. Keep DataStore usage conservative and fault-tolerant.
13. Design saves to tolerate retries and failures.
14. Do not assume DataStore calls always succeed.
15. Do not block critical gameplay loops on avoidable yielding operations.
16. Clean up RBXScriptConnections and dynamically created instances when their lifecycle ends.
17. Avoid unbounded loops, uncontrolled coroutines, unnecessary frame work, and expensive high-frequency paths.
18. Avoid relying on client clock or physics ownership for authoritative outcomes without server checks.
19. Use Attributes, CollectionService, tags, and instances according to documented architecture when introduced.
20. Keep UI responsive across expected Roblox device classes.
21. Treat mobile, console, and desktop input differences as design considerations.
22. Maintain accessibility and readability standards when UI is implemented.
23. Prefer Roblox-supported patterns over fragile workarounds.
24. Document engine assumptions and platform limitations that affect behavior.
25. Verify behavior in Roblox Studio when implementation work requires it.

## 17. Server Authoritative Design

1. The server owns player progression, inventory, currency, rewards, combat outcomes, enemy state, and save data.
2. The server owns entitlement validation when monetization is introduced.
3. The server owns trade validation if trading is introduced.
4. The server owns anti-abuse checks.
5. The client may request actions.
6. The client may display predicted or local presentation.
7. The client may not award itself value.
8. The client may not decide final damage.
9. The client may not create authoritative items.
10. The client may not mutate persistent progression.
11. The client may not bypass cooldowns.
12. The client may not set authoritative positions for gameplay-critical outcomes without validation.
13. Server handlers must treat client payloads as untrusted.
14. Server handlers must validate player identity, action eligibility, resource cost, target legitimacy, timing assumptions, and data IDs.
15. Server handlers must fail closed when validation fails.
16. Server authority rules and remote contracts must be documented when introduced.
17. Security-sensitive changes must be reviewed.
18. Client convenience must never override server authority.

## 18. Modular Architecture

1. Modules should have one clear responsibility.
2. Systems should expose small public APIs.
3. Internal helpers should remain internal.
4. Cross-system communication should follow documented boundaries.
5. Services should not reach into each other's private state.
6. Controllers should not own server truth.
7. UI modules should not own gameplay rules.
8. Economy modules should not own combat execution.
9. Combat modules should not own persistence.
10. Persistence modules should not own design balance.
11. Data definitions should not execute gameplay side effects.
12. Initialization should be predictable.
13. Dependency direction should be documented.
14. Shared modules should not depend on client-only or server-only runtime services unless clearly separated.
15. Avoid circular requires.
16. Avoid large catch-all utility modules.
17. Avoid one module becoming a dumping ground.
18. Avoid implicit global state.
19. Avoid behavior hidden in constructors or module load side effects.
20. Prefer dependency injection or explicit setup where it improves testability.
21. Keep API names stable.
22. Keep module contracts documented.
23. Keep data ownership visible.
24. Refactor only when the task requires it or when required to complete the task safely.

## 19. Gameplay Value Policy

1. No hardcoding gameplay values.
2. Damage, cooldowns, XP, levels, rewards, prices, drop rates, and save defaults must come from approved data.
3. UI copy that reflects rules must align with documentation.
4. Temporary values must be labeled as temporary and have a removal or review path.
5. Test fixtures may use local values only when clearly isolated from production.
6. Technical constants may be hardcoded only when they are not gameplay tuning values.
7. Examples of technical constants include enum keys, service names, and fixed protocol labels.
8. Examples of gameplay values include health, damage, rewards, costs, timers, unlock levels, and probabilities.
9. Gameplay values must not be duplicated.
10. Gameplay values must not be hidden in UI code.
11. Gameplay values must not be inferred from asset names.
12. Gameplay values must not be stored only in comments.
13. Gameplay values must be reviewable as data.
14. Gameplay value changes must include documentation updates.
15. Gameplay value changes must include balance rationale when the balance process exists.
16. Gameplay value changes must be tested or manually verified when implementation exists.
17. Assistants must stop and document missing data structures before implementing systems that need them.

## 20. File Modification Discipline

1. Never modify unrelated files.
2. Never reformat unrelated files.
3. Never normalize line endings across unrelated files.
4. Never reorder unrelated content.
5. Never update generated files unless required.
6. Never edit lockfiles unless dependency changes require it.
7. Never edit asset metadata unless the asset change requires it.
8. Never edit task files unrelated to the current task.
9. Never edit review records to hide previous findings.
10. Never edit documentation to create false approval.
11. If a file contains existing user changes, preserve them.
12. If a file has unrelated changes, work around them.
13. If unrelated changes block the task, ask for guidance.
14. If a required edit touches a shared file, keep the edit minimal.
15. If a required edit changes public behavior, document it.
16. If a required edit changes a contract, update all references.
17. If a required edit changes data, update schema documentation.
18. If a required edit changes save behavior, update save documentation.
19. If a required edit changes UI behavior, update UI documentation.
20. If a required edit changes design behavior, update the GDD.
21. Review diffs before declaring completion.
22. Confirm no accidental files, temporary files, or unrelated edits remain.
23. Treat repository hygiene as part of implementation quality.

## 21. Undocumented Feature Policy

1. Never add undocumented features.
2. Never add undocumented systems.
3. Never add undocumented remotes.
4. Never add undocumented save fields.
5. Never add undocumented currencies.
6. Never add undocumented inventory categories.
7. Never add undocumented enemies.
8. Never add undocumented abilities.
9. Never add undocumented progression tracks.
10. Never add undocumented UI screens.
11. Never add undocumented admin controls, analytics, monetization, asset requirements, or build steps.
12. If implementation requires a new feature, document and seek approval first.
13. If a feature is scaffolding, disabled, experimental, or removed, document its status and rationale.

## 22. Implementation Workflow

1. Read this document.
2. Read `docs/GDD_MASTER.md`.
3. Read the relevant domain documentation.
4. Read the relevant task file.
5. Inspect the existing repository structure.
6. Identify the smallest safe change.
7. Identify documentation that must be updated.
8. Identify tests or verification steps.
9. Confirm there are no unresolved scope conflicts.
10. Implement the change.
11. Keep implementation aligned with documented requirements.
12. Keep implementation modular.
13. Keep implementation data-driven.
14. Keep implementation server authoritative.
15. Keep implementation free of unrelated edits.
16. Update affected documentation.
17. Update task status or notes when the workflow calls for it.
18. Update changelog when the change is meaningful.
19. Run relevant checks.
20. Run relevant tests if available.
21. Perform manual verification when automated tests are not available.
22. Review the diff.
23. Record any known gaps.
24. Do not claim completion if required verification did not run.

## 23. Agent Role Expectations

1. The gameplay agent works from documented design.
2. The gameplay agent must not invent mechanics.
3. The gameplay agent must protect server authority.
4. The gameplay agent must keep gameplay values data-driven.
5. The UI agent works from documented UI guidelines.
6. The UI agent must not invent screens or flows.
7. The UI agent must keep UI presentation separate from authoritative state.
8. The UI agent must consider Roblox device differences.
9. The economy agent works from documented economy rules.
10. The economy agent must not invent currencies, sinks, sources, or prices.
11. The economy agent must treat economy changes as high-risk.
12. The economy agent must coordinate with progression and save documentation.
13. The data agent works from documented schemas.
14. The data agent must protect compatibility and migration paths.
15. The data agent must validate trust boundaries.
16. The data agent must coordinate with save system documentation.
17. The reviewer agent evaluates correctness, scope, documentation, and risk.
18. The reviewer agent must prioritize blocking issues over style suggestions.
19. The reviewer agent must verify alignment with this document.
20. All agents must hand off work in a form another assistant can continue.

## 24. Quality Gates

1. The work must match the task.
2. The work must match the GDD.
3. The work must match relevant domain documentation.
4. The work must preserve server authority.
5. The work must preserve data ownership.
6. The work must avoid hardcoded gameplay values.
7. The work must avoid undocumented features.
8. The work must avoid unrelated file changes.
9. The work must avoid unnecessary architecture changes.
10. The work must avoid hidden dependencies.
11. The work must avoid fragile initialization.
12. The work must avoid client trust for authoritative outcomes.
13. The work must include documentation updates when behavior changes.
14. The work must include tests or verification notes.
15. The work must identify known risks.
16. The work must be understandable to another assistant and a human reviewer.
17. The work must be reversible or clearly justified if risky.
18. The work must not leave temporary scaffolding unlabeled.
19. The work must not be declared complete until these gates are satisfied or documented as exceptions.

## 25. Conflict Resolution

1. If task instructions conflict with the GDD, stop and ask for clarification.
2. If code conflicts with documentation, identify which source should change.
3. If documents conflict with each other, update the owning documents before implementation.
4. If agent instructions conflict, follow this document first.
5. If a domain document conflicts with another domain document, ask for resolution or document the dependency.
6. If implementation reveals a design gap, document the gap.
7. If implementation reveals an architecture gap, document the gap.
8. If implementation reveals a data gap, document the gap.
9. If a shortcut is required to unblock work, document the shortcut and its removal path.
10. If a human makes a decision in conversation, preserve that decision in documentation.
11. If a decision is uncertain, mark it as an open question.
12. If multiple approaches are viable, prefer the smallest documented approach.
13. If the smallest approach creates long-term risk, explain the risk before proceeding.
14. If a change cannot be verified, state that clearly.
15. If a task cannot be completed safely, stop and explain the blocker.

## 26. Anti-Patterns

1. Coding before reading the GDD.
2. Coding before reading the relevant task.
3. Implementing mechanics from assumption.
4. Adding features because they seem obvious.
5. Adding data fields because they might be useful later.
6. Adding generic frameworks without current need.
7. Hardcoding gameplay values in logic.
8. Letting clients decide authoritative outcomes.
9. Putting economy logic in UI.
10. Putting save logic in combat modules.
11. Putting design balance in persistence modules.
12. Duplicating gameplay values across files.
13. Hiding important behavior in comments only.
14. Treating placeholder documentation as approval.
15. Treating prototype code as production-ready without review.
16. Making large rewrites while fixing small issues.
17. Reformatting files unrelated to the task.
18. Deleting user changes.
19. Ignoring failed tests.
20. Claiming verification that was not performed.
21. Creating undocumented remotes, save fields, UI flows, currencies, admin tools, or debug behavior.
22. Letting task notes or chat become the only source of truth.
23. Leaving another assistant unable to understand the change.
24. Treating this document as optional.

## 27. Definition of Done

1. The requested work is complete.
2. The work is within scope.
3. The relevant documentation was read.
4. The relevant documentation was updated.
5. The implementation matches the GDD.
6. The implementation matches relevant domain documents.
7. No undocumented features were added.
8. No unrelated files were modified.
9. No hardcoded gameplay values were introduced.
10. Server authority was preserved.
11. Data ownership was preserved.
12. Modular boundaries were preserved.
13. Naming conventions were followed.
14. Tests were added or updated when appropriate.
15. Relevant checks were run when available.
16. Manual verification was performed when needed.
17. Known gaps were documented.
18. Review risks were surfaced.
19. The changelog was updated when meaningful.
20. The final summary identifies what changed and how it was verified.

## 28. Maintenance of This Document

1. This document must evolve with the project.
2. Changes to this document should be deliberate.
3. Changes to this document should be reviewed.
4. Changes to this document should be recorded in `docs/CHANGELOG.md` when meaningful.
5. New agent roles must be added here or linked from here.
6. New source folders must be added to folder ownership rules.
7. New architecture policies must be reflected here when they affect all assistants.
8. New review requirements must be reflected here when they affect all assistants.
9. Deprecated rules should be removed only with documented rationale.
10. Ambiguous rules should be clarified as soon as ambiguity causes confusion.
11. This document should remain practical.
12. This document should remain enforceable.
13. This document should remain specific to Project Genesis.
14. This document should not become a dumping ground for task details.
15. This document should not duplicate every domain document.
16. Domain-specific rules should live in domain documents and be referenced here.
17. Repository-wide rules should live here.
18. Assistants must check this document when onboarding to the repository.
19. Assistants must flag this document when project practice diverges from policy.
20. Project Genesis depends on disciplined AI collaboration, and this document is the baseline for that discipline.
