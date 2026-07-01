# Project Genesis

## Project Overview

Project Genesis is an AI-assisted Roblox game project focused on creature progression, collection, evolution, data-driven systems, and server-authoritative gameplay.

The repository is being prepared for long-term collaboration between human developers and AI assistants. Documentation is the source of truth for design, architecture, production workflow, security, configuration, and review standards.

Current work is focused on the MVP only.

No contributor should implement gameplay, add systems, or create content that is not already approved in the project documentation.

## Vision

Project Genesis aims to deliver a focused creature progression experience where players collect, improve, evolve, and progress through approved MVP content using clear systems that are maintainable, extensible, and data-driven.

The MVP exists to prove the core experience before expanding scope.

The project prioritizes:

- Evolution as the core player experience.
- Gameplay clarity before visual polish.
- MVP delivery before complexity.
- Documentation as the source of truth.
- Data-driven configuration.
- Server-authoritative Roblox architecture.
- Modular systems.
- Reviewable work.
- AI-safe production processes.

## Current Development Phase

- Current Project Phase: MVP Release Gate Audit
- Current Milestone: MVP-019 - Generator Biomass & Expansion Gate
- Current Sprint: MVP validation and release readiness
- Current Repository State: MVP-001 through MVP-019 implementation modules and task records are present and in Review
- Implementation Status: Foundation gameplay systems exist, but the project is not a Release Candidate

MVP-019 is the current release gate. It must validate the existing MVP work without adding new gameplay scope. The Play Mode Grand Check has passed, but Release Candidate status remains blocked until MVP-001 through MVP-019 receive required approval and documented deferred items such as the in-memory `SaveService` state are accepted or resolved.

## Repository Structure

### `docs/`

Primary project documentation.

This folder contains the source-of-truth documents for design, architecture, combat, balance, data schemas, configuration, security, milestones, sprint process, workflow, known issues, and production standards.

All contributors must read the relevant documents before implementation or review.

### `agents/`

AI assistant role definitions.

This folder defines how each AI agent should behave, what it owns, what it must review, and what it must never do. The global AI rules live in `agents/AGENTS.md`.

### `tasks/`

Task planning files.

This folder stores MVP task definitions and may later contain active, review, blocked, or completed task records depending on the production workflow.

### `configs/`

Data-driven gameplay configuration foundation.

This folder contains approved MVP configuration records and reserved configuration surfaces. Gameplay values must come from configuration rather than hardcoded implementation values.

### `database/`

Persistence planning foundation.

This folder is reserved for persistence-related support files such as approved schema notes, migration notes, or validation artifacts. It currently contains folder placeholders only. Save behavior must remain server-authoritative.

### `src/`

Roblox source foundation.

This folder separates server-only systems, client-only presentation, and shared contracts. It contains the reviewed MVP foundation modules through MVP-009. New gameplay code must not be added until the relevant design, architecture, data, security, and task documents are ready.

### `assets/`

Asset planning and source asset folder.

This folder is intended for approved project assets, references, generated artwork, or asset pipeline outputs. Art direction must follow `docs/ART_BIBLE.md`.

### `reviews/`

Review records and templates.

Completed work must be reviewed using the project review standards. The current review template is `reviews/review_template.md`.

### `prompts/`

Prompt storage and AI workflow references.

This folder is reserved for reusable prompts, AI task instructions, and production prompt templates.

## Documentation Reading Order

Every AI assistant must read documentation before making implementation decisions.

Required reading order:

1. `docs/README.md`
2. `docs/PROJECT_PRINCIPLES.md`
3. `agents/AGENTS.md`
4. Relevant role file in `agents/`
5. `docs/GDD_MASTER.md`
6. `docs/DECISIONS.md`
7. `docs/DEVELOPMENT_WORKFLOW.md`
8. `docs/DEFINITION_OF_DONE.md`
9. `docs/MILESTONES.md`
10. `docs/SPRINT_GUIDE.md`
11. `docs/MVP_CHECKLIST.md`
12. `docs/TECH_ARCHITECTURE.md`
13. `docs/DATA_SCHEMA.md`
14. `docs/CONFIG_GUIDE.md`
15. `docs/CONFIG_STRUCTURE.md`
16. `docs/SECURITY_GUIDE.md`
17. `docs/COMBAT.md`
18. `docs/BALANCE.md`
19. `docs/ECONOMY.md`
20. `docs/SAVE_SYSTEM.md`
21. `docs/PROGRESSION.md`
22. `docs/UI_GUIDELINES.md`
23. `docs/ART_BIBLE.md`
24. `docs/CONTENT_PIPELINE.md`
25. `docs/KNOWN_ISSUES.md`
26. `reviews/review_template.md`

If a task touches a specific domain, the contributor must also read the relevant domain document before work begins.

## Development Workflow

Project Genesis follows a documentation-first workflow:

```text
Discussion
  ↓
Decision
  ↓
Documentation
  ↓
Task
  ↓
Implementation
  ↓
Review
  ↓
Playtest
  ↓
Merge
```

All work must follow `docs/DEVELOPMENT_WORKFLOW.md`.

Tasks must satisfy Definition of Ready before implementation and Definition of Done before completion.

No task may be marked complete without review, validation evidence, and required documentation updates.

## AI Collaboration

Project Genesis is designed for collaboration between multiple AI assistants and human contributors.

### Director Agent

Protects the project vision, prevents feature creep, enforces MVP scope, reviews design consistency, and rejects undocumented mechanics. The Director Agent does not write gameplay code.

### Gameplay Agent

Works on approved gameplay systems only after the relevant GDD, decision log, combat, progression, balance, and task documentation is ready.

### Data Agent

Owns data schemas, configuration structure, validation expectations, save-facing data shape, and data-driven content consistency.

### Economy Agent

Owns economy rules, rewards, costs, balance implications, currency integrity, and economy-related validation.

### UI Agent

Owns player-facing interface documentation and UI implementation guidance while keeping gameplay authority on the server.

### Reviewer Agent

Reviews completed work for requirements, scope, documentation quality, architecture consistency, testing evidence, and AI hallucination risk.

## MVP Scope

The MVP is limited to proving the core Project Genesis experience.

Approved MVP system categories include:

- Core gameplay loop.
- Progression loop.
- Creature foundation.
- Combat foundation.
- Evolution foundation.
- Gene foundation.
- Collection foundation.
- Economy foundation.
- World progression foundation.
- Boss and challenge combat support.
- Data schema required for MVP systems.
- Save system required for MVP systems.
- UI required to understand and operate MVP systems.
- Technical architecture required for server-authoritative, maintainable gameplay.

MVP scope does not approve full-scale content production. Content quantity must be defined through roadmap, milestone, sprint, and task documents before work begins.

## Out of Scope

The following are intentionally excluded from MVP unless project leadership explicitly moves them into scope through documentation:

- PvP.
- Trading.
- Guilds or clans.
- Live events.
- Seasonal systems.
- Battle pass systems.
- Premium currency.
- Monetization systems.
- Daily quests.
- Timed login rewards.
- Procedural open world.
- Complex rarity systems.
- Branching evolution.
- Gene inheritance or mutation.
- Prestige multipliers.
- Full social hub features.
- Advanced enemy AI beyond MVP combat needs.
- Unapproved tower systems.
- Unapproved quest systems.
- Undocumented status effect systems.
- Any undocumented mechanic.

Out-of-scope ideas may be discussed, but they must not be implemented, scaffolded, balanced, or implied as MVP commitments.

## Contributing

Contributors must work from documentation, not assumptions.

Before starting work:

- Read the required documentation in order.
- Confirm the task is within MVP scope.
- Confirm the task satisfies Definition of Ready.
- Confirm required decisions are recorded.
- Confirm required schemas, architecture, and security rules are documented.
- Confirm acceptance criteria are clear.

While working:

- Modify only files related to the task.
- Do not add undocumented mechanics.
- Do not hardcode gameplay values.
- Preserve server authority.
- Keep gameplay logic separate from UI.
- Update documentation after implementation.
- Record validation evidence.

Before marking work complete:

- Confirm Definition of Done is satisfied.
- Run or perform required validation.
- Update relevant docs.
- Submit work for review.
- Resolve blocking review issues.
- Additionally, scan [docs/MVP_CHECKLIST.md](file:///c:/Codes/Project_Genesis/docs/MVP_CHECKLIST.md) and check off (`[x]`) the specific task checkboxes that have been fully validated by this implementation.

## License Placeholder

License terms have not yet been selected.

Until a license is added, this repository should be treated as private project material. Do not reuse, redistribute, or publish project content without explicit permission from the project owner.

## Final Notes

Project Genesis is documentation-first, MVP-first, and server-authoritative.

The project depends on disciplined collaboration between human contributors and AI assistants.

When in doubt, read the documentation, protect the MVP, avoid invention, and ask for a documented decision before implementation.
