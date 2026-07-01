# Project Principles

## Purpose

This document defines the non-negotiable principles that guide every design and engineering decision throughout Project Genesis.

This is not a GDD.

This is not a roadmap.

This is not a design document.

This is the project's constitution.

The current scope is MVP only. These principles must protect the MVP while still supporting a long-term production mindset.

## Core Philosophy

Project Genesis is a creature-focused Roblox progression game built for long-term, AI-assisted development.

The project exists to deliver a clear loop of growth, collection, combat, evolution, and meaningful progression. Every system must make that loop easier to understand, easier to maintain, or more valuable to the player.

The project must never become a collection of disconnected ideas. It must remain disciplined, documented, data-driven, and focused on the smallest complete MVP that proves the core experience.

Visual quality matters, but gameplay clarity matters first. Technical flexibility matters, but maintainability matters more. Future expansion matters, but the MVP comes first.

## The 10 Project Principles

### 1. Evolution Is the Core Experience

Evolution is the emotional and progression center of Project Genesis.

Every major system should support the feeling that creatures can grow, change, and become more meaningful over time. Evolution must remain clear, documented, server-authoritative, and connected to progression.

This principle does not approve new evolution mechanics by itself. Exact requirements, reset behavior, preserved state, costs, and effects must be documented before implementation.

### 2. Gameplay Before Visuals

Visuals should support gameplay clarity, not replace it.

AI-generated art, effects, UI polish, and presentation should make the core loop easier to understand and more compelling. They must not hide missing design decisions or imply unapproved mechanics.

### 3. MVP Before Complexity

The MVP must prove the smallest complete version of the core experience before the project expands.

Complexity is allowed only when it directly supports MVP validation. Systems that are interesting but not required for MVP should remain future ideas until promoted through documentation and approval.

### 4. Documentation Is the Source of Truth

Repository documentation is the durable project memory.

Design intent, architecture, data structures, balance philosophy, content process, decisions, known issues, and review outcomes must live in files, not chat history or private assumptions.

### 5. Everything Is Data-Driven

Gameplay values and content definitions must come from documented data.

Creatures, skills, genes, evolution, bosses, worlds, economy, collection, saves, rewards, and balance values must not be hidden in procedural code or one-off implementation.

### 6. No Feature Creep

Unapproved features must not enter the MVP.

Every feature must have a documented reason, scope, owner, and acceptance criteria. Future systems must remain future systems until they are explicitly approved.

### 7. No Undocumented Mechanics

If a mechanic is not documented, it does not exist for implementation purposes.

AI assistants and human contributors must not infer mechanics from genre expectations, art, naming, placeholder schemas, or personal preference.

### 8. Every Feature Must Improve Progression

Every MVP feature must help players understand, pursue, or benefit from progression.

Features that do not improve player goals, creature growth, collection clarity, combat purpose, economy integrity, or world advancement should be rejected or deferred.

### 9. Players Should Always Have Meaningful Goals

Players should always understand what they are working toward.

Goals should be visible, achievable, and connected to the core loop. The player should not be forced to guess why an action matters or what progress means.

### 10. Updates Should Add Content Before Rewriting Systems

Long-term updates should primarily add approved content on top of stable systems rather than repeatedly rewriting foundations.

System rewrites should happen only when required for correctness, maintainability, scalability, or a documented design shift. The preferred long-term production model is stable systems plus data-driven content expansion.

## Design Principles

1. Design must serve the core progression loop.
2. Design must be understandable before it is deep.
3. Design must be documented before implementation.
4. Design must avoid hidden rules.
5. Design must avoid unnecessary systems.
6. Design must support creature growth and collection.
7. Design must preserve player clarity.
8. Design must avoid hard gates unless explicitly approved.
9. Design must avoid adding friction without purpose.
10. Design must distinguish MVP commitments from future ideas.

Design decisions should be evaluated by asking:

1. Does this improve the MVP?
2. Does this improve progression?
3. Does this make the game clearer?
4. Does this preserve the core fantasy?
5. Does this add avoidable complexity?
6. Is this documented?

## Engineering Principles

1. The server owns authority.
2. The client owns presentation.
3. Gameplay logic must be separate from UI.
4. Systems must be modular.
5. Data must drive gameplay configuration.
6. Static definitions must be separate from player save state.
7. Runtime state must be separate from persistent state.
8. Remote contracts must be explicit and validated.
9. Save data must be versioned and migration-aware.
10. Implementation must be reviewable by another assistant or engineer.
11. Code must not introduce undocumented gameplay.
12. Architecture must prefer maintainability over cleverness.

Engineering decisions should be evaluated by asking:

1. Does this preserve server authority?
2. Does this keep gameplay data-driven?
3. Does this reduce or increase long-term maintenance risk?
4. Does this create hidden coupling?
5. Does this make future content easier to add safely?

## AI Collaboration Principles

1. AI assistants must read the relevant documents before acting.
2. AI assistants must not rely on private memory.
3. AI assistants must not invent mechanics.
4. AI assistants must not silently expand scope.
5. AI assistants must document assumptions.
6. AI assistants must preserve existing work.
7. AI assistants must keep changes reviewable.
8. AI assistants must update documentation when implementation changes behavior.
9. AI assistants must flag conflicts rather than resolve them silently.
10. AI assistants must treat `docs/DECISIONS.md` as a permanent decision record.

AI collaboration succeeds when another assistant can continue the work from repository files alone.

## Content Creation Principles

1. Content must use stable IDs.
2. Content must be data-driven.
3. Content must follow the content pipeline.
4. Content must not introduce mechanics by implication.
5. Content must not include fake balance values.
6. Content must be reviewed before implementation.
7. Content must align with the Art Bible when visuals are involved.
8. Content must align with balance philosophy when values are involved.
9. Content must preserve server authority when rewards or progression are involved.
10. Content must support meaningful player goals.

Future content should add value through approved data and assets, not through undocumented system rewrites.

## Long-Term Vision

Project Genesis should become a maintainable, expandable creature progression game where new content can be added safely because the core systems are stable, documented, and data-driven.

The long-term vision is not to build every possible system. The long-term vision is to build a strong foundation that allows approved content and systems to grow without collapsing under complexity.

The MVP is the first proof of that foundation.

Future expansion may include deeper systems only after the MVP proves:

1. The core loop is understandable.
2. Creature growth is compelling.
3. Evolution is meaningful.
4. Collection motivates continued play.
5. Combat supports progression.
6. Economy and rewards are stable.
7. The architecture can support more content.

## Decision Priority Order

When priorities conflict, use this order:

1. Human project leadership.
2. Project principles.
3. `docs/DECISIONS.md`.
4. `docs/GDD_MASTER.md`.
5. Relevant domain document.
6. `docs/TECH_ARCHITECTURE.md`.
7. `docs/DATA_SCHEMA.md`.
8. `docs/BALANCE.md`.
9. `docs/CONTENT_PIPELINE.md`.
10. `docs/MVP_CHECKLIST.md`.
11. Task files.
12. Review notes.
13. Chat context.

Chat context does not become authority until it is written into the appropriate repository document.

## What Should Never Change

The following should not change without explicit project leadership approval and documentation updates:

1. Documentation is the source of truth.
2. MVP-first development.
3. No feature creep.
4. No undocumented mechanics.
5. Data-driven gameplay.
6. Server-authoritative design.
7. Gameplay logic remains separate from UI.
8. Evolution remains central to the experience.
9. Every feature must support progression.
10. AI assistants must follow repository documentation.
11. Future systems require approval before implementation.
12. Maintainability is more important than cleverness.

## What May Change

The following may change through documented decisions and proper review:

1. Exact balance values.
2. Exact combat formulas.
3. Exact progression curves.
4. Exact economy values.
5. Exact creature content.
6. Exact skill content.
7. Exact gene behavior.
8. Exact evolution requirements.
9. Exact UI layouts.
10. Exact art prompts and asset workflow.
11. Exact source folder structure.
12. Exact implementation framework.
13. Exact content quantities.
14. Future system scope after MVP validation.

Changes must be documented before implementation and must not contradict the non-negotiable principles without leadership approval.

## Professional Conclusion

Project Genesis must be built with discipline.

The project should grow through clear decisions, stable systems, documented data, and purposeful content. Every contributor, human or AI, is responsible for protecting the core vision and resisting the temptation to expand before the foundation is proven.

The MVP is the current scope. The principles in this document exist to make sure the MVP can be finished, reviewed, maintained, and expanded without losing the identity of Project Genesis.
