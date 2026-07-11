# Project Genesis Documentation Guide

## Purpose

This document explains the documentation structure for Project Genesis.

Every AI assistant must read this file before reading any other documentation in the repository.

This guide explains:

- Why documentation is the single source of truth.
- Which documents exist.
- Which documents should be read first.
- Who owns each document.
- How document status is managed.
- How documentation changes are approved.
- Which rules prevent contradiction, duplication, and feature creep.

This document is part of the Project Genesis production process. It does not define gameplay mechanics.

## Status

- Document Status: Active
- Scope: Documentation structure and governance
- Project Phase: Alpha Release
- Owner: Project Director
- Last Updated: 2026-07-09

## Table of Contents

- [Purpose](#purpose)
- [Status](#status)
- [Documentation Philosophy](#documentation-philosophy)
- [Documentation Categories](#documentation-categories)
- [Reading Order](#reading-order)
- [Document Ownership](#document-ownership)
- [Locked Documents](#locked-documents)
- [Updating Documentation](#updating-documentation)
- [Documentation Rules](#documentation-rules)
- [Professional Conclusion](#professional-conclusion)

## Documentation Philosophy

Project Genesis is a documentation-first project.

Documentation is the single source of truth for design, architecture, production workflow, AI behavior, security, configuration, balance, and review standards.

Implementation must follow documentation.

Tasks must follow documentation.

Reviews must verify documentation alignment.

AI assistants must not invent missing design.

Human contributors must not treat undocumented assumptions as approved scope.

### Why Documentation Is The Source Of Truth

Project Genesis is intended for long-term AI-assisted production. Multiple AI assistants and human contributors may work in the same repository over time.

Without a single source of truth, the project would be vulnerable to:

- Conflicting design assumptions.
- Undocumented gameplay mechanics.
- Hidden feature creep.
- Hardcoded gameplay values.
- Inconsistent terminology.
- Unreviewable AI-generated changes.
- Architecture drift.
- Balance drift.
- Data schema drift.
- Repeated decisions being re-litigated.

Documentation prevents those risks by making approved decisions visible, reviewable, and enforceable.

### Documentation Authority

If implementation conflicts with documentation, the implementation is wrong unless the documentation has been formally updated and reviewed.

If two documents conflict, work must stop until the conflict is resolved.

If a mechanic is not documented, it is not approved.

If a decision is not recorded in `docs/DECISIONS.md`, it must not be treated as permanent project direction.

## Documentation Categories

Project Genesis documentation is organized into five categories:

- Vision
- Gameplay
- Technical
- Production
- Reference

Each category has a different purpose and review responsibility.

## Vision

Vision documents define the project identity, guiding principles, and approved design direction.

These documents answer why the project exists and what it is trying to become.

### Vision Documents

| Document | Purpose |
|---|---|
| `docs/PROJECT_PRINCIPLES.md` | Non-negotiable project principles |
| `docs/GDD_MASTER.md` | Master Game Design Document and MVP design source of truth |
| `docs/DECISIONS.md` | Permanent log of approved, rejected, and deprecated decisions |
| `docs/MILESTONES.md` | MVP production milestone structure |
| `README.md` | Repository entry point and high-level onboarding |

## Gameplay

Gameplay documents define approved player-facing systems, combat behavior, progression, economy, collection, balance philosophy, and content rules.

These documents answer what the game does.

### Gameplay Documents

| Document | Purpose |
|---|---|
| `docs/COMBAT.md` | Approved combat rules |
| `docs/BALANCE.md` | Balance philosophy and known/unknown variables |
| `docs/ECONOMY.md` | Economy design surface |
| `docs/PROGRESSION.md` | Progression design surface |
| `docs/SAVE_SYSTEM.md` | Save system design surface |
| `docs/UI_GUIDELINES.md` | UI standards and player-facing presentation guidance |
| `docs/ART_BIBLE.md` | Visual style and AI art consistency rules |
| `docs/CONTENT_PIPELINE.md` | SOP for adding approved content |

## Technical

Technical documents define architecture, schemas, configuration, security, naming, validation, and implementation rules.

These documents answer how the game should be built.

### Technical Documents

| Document | Purpose |
|---|---|
| `docs/TECH_ARCHITECTURE.md` | Roblox architecture, server authority, modular systems, and client structure |
| `docs/DATA_SCHEMA.md` | Data structure definitions |
| `docs/CONFIG_GUIDE.md` | Configuration organization and data-driven value rules |
| `docs/CONFIG_STRUCTURE.md` | Configuration hierarchy, ownership, and dependency rules |
| `docs/SECURITY_GUIDE.md` | Roblox security principles and authority rules |
| `docs/STYLE_GUIDE.md` | Coding, naming, formatting, and documentation style |

## Production

Production documents define workflow, milestones, sprints, completion criteria, task planning, and review processes.

These documents answer how work moves from idea to release.

### Production Documents

| Document | Purpose |
|---|---|
| `docs/DEVELOPMENT_WORKFLOW.md` | Full lifecycle from idea to release |
| `docs/DEFINITION_OF_DONE.md` | Mandatory completion standard |
| `docs/SPRINT_GUIDE.md` | Sprint planning and agile process |
| `docs/MVP_CHECKLIST.md` | Master MVP task checklist |
| `docs/ROADMAP.md` | Roadmap placeholder and milestone planning surface |
| `docs/CHANGELOG.md` | Change history |
| `docs/KNOWN_ISSUES.md` | Unresolved design and technical questions |
| `reviews/review_template.md` | Standard review template |

## Reference

Reference documents define AI roles, task files, prompts, reviews, and supporting production context.

These documents answer who is responsible and where supporting production material lives.

### Reference Documents

| Document Or Folder | Purpose |
|---|---|
| `agents/AGENTS.md` | Global rules for every AI assistant |
| `agents/director-agent.md` | Project Director AI role |
| `agents/gameplay-agent.md` | Gameplay AI role |
| `agents/data-agent.md` | Data AI role |
| `agents/economy-agent.md` | Economy AI role |
| `agents/ui-agent.md` | UI AI role |
| `agents/reviewer-agent.md` | Reviewer AI role |
| `tasks/` | Task planning and task records |
| `reviews/` | Review templates and completed reviews |
| `prompts/` | Reusable AI prompts and prompt templates |

## Reading Order

Every AI assistant must read `docs/README.md` first.

This document comes first because it explains how all other documents are organized, which documents have authority, and how to avoid contradictions before reading detailed project material.

Required reading order:

```text
docs/README.md
  ↓
docs/PROJECT_PRINCIPLES.md
  ↓
agents/AGENTS.md
  ↓
Relevant agent role file
  ↓
docs/GDD_MASTER.md
  ↓
docs/DECISIONS.md
  ↓
docs/DEVELOPMENT_WORKFLOW.md
  ↓
docs/DEFINITION_OF_DONE.md
  ↓
docs/TECH_ARCHITECTURE.md
  ↓
docs/DATA_SCHEMA.md
  ↓
docs/CONFIG_GUIDE.md
  ↓
docs/CONFIG_STRUCTURE.md
  ↓
docs/SECURITY_GUIDE.md
  ↓
docs/COMBAT.md
  ↓
docs/BALANCE.md
  ↓
docs/ECONOMY.md
  ↓
Remaining documents relevant to the task
```

### Why This Order Exists

`docs/README.md` comes first because it defines documentation governance.

`docs/PROJECT_PRINCIPLES.md` comes next because it defines the project constitution.

`agents/AGENTS.md` comes next because every AI assistant must understand collaboration rules before making decisions.

The relevant agent role file comes next because each AI role has specific authority and limits.

`docs/GDD_MASTER.md` comes next because it defines the MVP design source of truth.

`docs/DECISIONS.md` comes next because it records approved design decisions and prevents re-inventing settled direction.

Workflow and Definition of Done documents come next because they define how work is allowed to proceed.

Technical, schema, configuration, security, combat, balance, and economy documents come next because implementation and content work must follow them.

Remaining documents should be read based on the task domain.

### Domain-Specific Reading

After the required core reading order, contributors must read the documents relevant to their task.

Examples:

- Combat work requires `docs/COMBAT.md`, `docs/BALANCE.md`, `docs/DATA_SCHEMA.md`, and `docs/SECURITY_GUIDE.md`.
- Economy work requires `docs/ECONOMY.md`, `docs/BALANCE.md`, `docs/DATA_SCHEMA.md`, and `docs/SECURITY_GUIDE.md`.
- UI work requires `docs/UI_GUIDELINES.md`, `docs/TECH_ARCHITECTURE.md`, and relevant gameplay documents.
- Content work requires `docs/CONTENT_PIPELINE.md`, `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md`, and `docs/CONFIG_STRUCTURE.md`.
- Review work requires `docs/DEFINITION_OF_DONE.md`, `docs/DEVELOPMENT_WORKFLOW.md`, and `reviews/review_template.md`.

## Document Ownership

Every document must have a clear owner.

Ownership means responsibility for accuracy, consistency, review readiness, and alignment with source-of-truth documents.

Ownership does not allow bypassing review.

### Ownership Table

| Document | Primary Owner | Required Reviewers |
|---|---|---|
| `docs/README.md` | Project Director | Human Team, Reviewer Agent |
| `docs/PROJECT_PRINCIPLES.md` | Project Director | Human Team |
| `docs/GDD_MASTER.md` | Project Director | Human Team, Gameplay Agent |
| `docs/DECISIONS.md` | Project Director | Human Team |
| `docs/COMBAT.md` | Gameplay Agent | Project Director, Reviewer Agent |
| `docs/PROGRESSION.md` | Gameplay Agent | Project Director, Reviewer Agent |
| `docs/ECONOMY.md` | Economy Agent | Project Director, Reviewer Agent |
| `docs/BALANCE.md` | Economy Agent / Gameplay Agent | Project Director, Reviewer Agent |
| `docs/DATA_SCHEMA.md` | Data Agent | Project Director, Reviewer Agent |
| `docs/CONFIG_GUIDE.md` | Data Agent | Technical Owner, Reviewer Agent |
| `docs/CONFIG_STRUCTURE.md` | Data Agent | Technical Owner, Reviewer Agent |
| `docs/TECH_ARCHITECTURE.md` | Technical Owner | Project Director, Reviewer Agent |
| `docs/SECURITY_GUIDE.md` | Technical Owner | Project Director, Reviewer Agent |
| `docs/SAVE_SYSTEM.md` | Data Agent / Technical Owner | Project Director, Reviewer Agent |
| `docs/UI_GUIDELINES.md` | UI Agent | Project Director, Reviewer Agent |
| `docs/ART_BIBLE.md` | Art Owner | Project Director, Reviewer Agent |
| `docs/CONTENT_PIPELINE.md` | Project Director | Data Agent, Reviewer Agent |
| `docs/DEVELOPMENT_WORKFLOW.md` | Project Director | Human Team, Reviewer Agent |
| `docs/DEFINITION_OF_DONE.md` | Project Director | Human Team, Reviewer Agent |
| `docs/MILESTONES.md` | Project Director | Human Team, Reviewer Agent |
| `docs/SPRINT_GUIDE.md` | Project Director | Human Team, Reviewer Agent |
| `docs/MVP_CHECKLIST.md` | Project Director | Human Team, Reviewer Agent |
| `docs/KNOWN_ISSUES.md` | Project Director | All Domain Owners |
| `docs/ROADMAP.md` | Human Team | Project Director |
| `docs/CHANGELOG.md` | Human Team | Project Director |
| `agents/AGENTS.md` | Project Director | Human Team |
| `agents/director-agent.md` | Project Director | Human Team |
| `agents/gameplay-agent.md` | Gameplay Agent | Project Director |
| `agents/data-agent.md` | Data Agent | Project Director |
| `agents/economy-agent.md` | Economy Agent | Project Director |
| `agents/ui-agent.md` | UI Agent | Project Director |
| `agents/reviewer-agent.md` | Reviewer Agent | Project Director |
| `reviews/review_template.md` | Reviewer Agent | Project Director |

## Locked Documents

Project Genesis uses a documentation status model to control changes.

Document status must be visible near the top of major documents whenever possible.

### Draft

Draft documents are incomplete, exploratory, or awaiting approval.

Draft documents may contain placeholders, open questions, and structure that is not ready for implementation.

Rules:

- Draft content must not be treated as approved gameplay.
- Draft content must not be implemented unless the task explicitly allows documentation scaffolding only.
- Draft content must identify unresolved questions where applicable.

### Review

Review documents are ready for inspection but not yet locked.

Review status means the content is believed to be complete enough for approval, but reviewers must still check consistency, scope, and accuracy.

Rules:

- Review documents must be checked against source-of-truth documents.
- Review documents must not contradict locked documents.
- Review feedback must be resolved before locking.

### Locked

Locked documents are approved source-of-truth documents.

Locked content may guide implementation, review, configuration, and task creation.

Rules:

- Locked documents may not be changed casually.
- Locked documents require a documented reason before modification.
- Gameplay changes to locked documents require an approved decision in `docs/DECISIONS.md`.
- Changes to locked documents must be reviewed.

### Deprecated

Deprecated documents or sections are no longer authoritative.

Deprecated material must remain understandable for history, but contributors must not use it as current guidance.

Rules:

- Deprecated content must identify the replacement document or decision where possible.
- Deprecated content must not be deleted if it is needed for decision history.
- Deprecated content must not be used to justify new work.

## Documentation Freeze Policy

Documentation Freeze protects locked documents during milestone review, release preparation, or major implementation review.

During a documentation freeze:

- Locked documents must not change without Project Director approval.
- Design changes must stop unless they resolve a blocker.
- New mechanics must not be added.
- Documentation edits must be limited to corrections, review findings, approved decisions, or release-critical updates.
- Any change during freeze must include a clear reason and reviewer.

Documentation Freeze may be used before:

- Milestone approval.
- Release candidate review.
- Major implementation review.
- Final MVP release approval.

## Updating Documentation

Documentation changes must follow the approved workflow.

Standard documentation update flow:

```text
Decision
  ↓
Documentation
  ↓
Review
  ↓
Lock
```

### Update Process

1. Identify the need for a documentation change.
2. Check whether the change affects gameplay, architecture, data, security, economy, balance, UI, or production workflow.
3. If the change affects gameplay, update `docs/DECISIONS.md` before changing gameplay documentation.
4. Update only the relevant document sections.
5. Avoid duplicating content from other documents.
6. Link or reference the source document instead of copying large sections.
7. Check for contradictions with existing documentation.
8. Submit the documentation change for review.
9. Resolve blocking review issues.
10. Mark the document status appropriately.

### When DECISIONS Must Be Updated First

`docs/DECISIONS.md` must be updated before changing gameplay direction.

Examples:

- Adding a new gameplay rule.
- Changing an existing combat rule.
- Changing economy behavior.
- Changing progression requirements.
- Changing evolution behavior.
- Changing gene behavior.
- Changing collection behavior.
- Activating a reserved schema surface.
- Changing MVP scope.
- Deprecating a previously accepted decision.

### When DECISIONS May Not Be Required

`docs/DECISIONS.md` may not be required for:

- Typo fixes.
- Formatting cleanup.
- Clarifying language without changing meaning.
- Adding table of contents entries.
- Updating ownership metadata.
- Adding review notes that do not change design direction.

If there is uncertainty, treat the change as decision-sensitive and ask for review.

## Documentation Rules

All documentation must follow these rules.

### Core Rules

- Never duplicate information unnecessarily.
- Never contradict another document.
- Never invent undocumented mechanics.
- Always update `docs/DECISIONS.md` before changing gameplay direction.
- Always distinguish approved decisions from open questions.
- Always keep MVP scope clear.
- Always identify reserved systems as reserved.
- Always use consistent terminology.
- Always update affected documentation after implementation.
- Always record unresolved questions in `docs/KNOWN_ISSUES.md`.

### Duplication Rules

Do not copy large sections between documents.

Instead:

- Keep the authoritative explanation in one document.
- Reference that document from related documents.
- Summarize only what is needed for context.
- Avoid maintaining the same rule in multiple places unless the duplication is deliberate and review-approved.

### Contradiction Rules

If two documents disagree:

1. Stop implementation.
2. Identify the conflicting documents.
3. Check `docs/DECISIONS.md`.
4. Ask the Project Director or Human Team for resolution.
5. Update the affected documents after the decision.
6. Do not proceed until the contradiction is resolved.

### Mechanics Rules

Documentation must not introduce mechanics accidentally.

Forbidden patterns:

- Adding a new gameplay behavior as an example.
- Treating placeholders as approved values.
- Writing speculative systems as current scope.
- Activating reserved systems through wording.
- Adding implementation assumptions to design documents.
- Adding design assumptions to technical documents without approval.

### Review Rules

Documentation changes must be reviewed when they affect:

- Gameplay.
- Architecture.
- Data schemas.
- Security.
- Economy.
- Balance.
- Save data.
- UI flows.
- Production process.
- AI responsibilities.
- MVP scope.

## Professional Conclusion

Project Genesis documentation exists to keep AI-assisted production coherent, reviewable, and safe.

Every contributor must understand the documentation structure before reading or changing domain-specific documents.

Every AI assistant must start with this file, then follow the required reading order.

The project succeeds when design, implementation, review, and production planning all point back to the same documented truth.
