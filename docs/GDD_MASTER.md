# Project Genesis Game Design Document

## Purpose

This document is the master Game Design Document for Project Genesis.

It is the single source of truth for the current MVP design direction. All feature work, task planning, implementation, review, and documentation updates must align with this document unless project leadership explicitly approves a change.

This version defines the MVP at a high level only. It does not approve detailed combat formulas, creature stats, gene rules, economy values, evolution requirements, prestige rewards, content lists, UI flows, or world layouts. Those details must be documented in the relevant domain documents before implementation.

## Status

- Status: Active Draft
- Scope: MVP only
- Owner: Project Leadership
- Last Updated: 2026-07-01
- Review Cadence: Every MVP milestone and before implementation of any major system
- Authority Level: Primary game design source of truth

## Table of Contents

- [1. Vision](#1-vision)
- [2. Design Philosophy](#2-design-philosophy)
- [3. Core Pillars](#3-core-pillars)
- [4. Target Audience](#4-target-audience)
- [5. Gameplay Loop](#5-gameplay-loop)
- [6. Progression Loop](#6-progression-loop)
- [7. Combat Overview](#7-combat-overview)
- [8. Creature System](#8-creature-system)
- [9. Evolution System](#9-evolution-system)
- [10. Gene System](#10-gene-system)
- [11. Prestige](#11-prestige)
- [12. Collection](#12-collection)
- [13. Economy](#13-economy)
- [14. World Progression](#14-world-progression)
- [15. MVP Scope](#15-mvp-scope)
- [16. Explicitly Out of Scope](#16-explicitly-out-of-scope)
- [17. Future Expansion Notes](#17-future-expansion-notes)

## 1. Vision

Project Genesis is a Roblox creature-focused progression game built around clear growth, collection, combat, and long-term player investment.

The MVP should prove the core promise of the game:

1. Players engage with creatures.
2. Players progress through repeatable play.
3. Players improve their collection over time.
4. Players make meaningful choices about growth.
5. Players unlock access to additional MVP content through documented progression.

The MVP is not expected to deliver the full long-term game. Its purpose is to establish the foundation for the core experience and validate that the central loops are understandable, stable, extensible, and worth expanding.

The game should feel structured, legible, and progression-driven. Players should understand what they are doing, why it matters, and what they are working toward.

## 2. Design Philosophy

Project Genesis is designed as a long-term systems game rather than a one-off prototype.

The design philosophy is:

1. Build the smallest complete version of the core experience first.
2. Prioritize clarity over system quantity.
3. Prioritize repeatable progression over one-time novelty.
4. Make every MVP system serve the core loop.
5. Keep gameplay rules documented before implementation.
6. Keep balance values data-driven and reviewable.
7. Keep server authority over all meaningful player progress.
8. Avoid hidden complexity in the MVP.
9. Avoid adding systems that do not directly support MVP validation.
10. Leave room for future expansion without implementing future expansion now.

The MVP should not depend on speculative future systems to feel coherent. If a system is required for the MVP to function, it belongs in MVP scope. If a system only improves a future version, it belongs in future expansion notes.

## 3. Core Pillars

### Clear Progress

Players should always understand their current objective, their next achievable goal, and how their actions move them forward.

### Creature-Centered Growth

Creatures are the primary focus of player investment. MVP systems should support owning, improving, comparing, and progressing creatures without requiring unnecessary complexity.

### Data-Driven Depth

The game should support depth through documented data and system rules rather than hardcoded one-off behavior.

### Server-Authoritative Trust

The server must own rewards, combat outcomes, progression, collection state, economy changes, evolution results, gene state, prestige state, and saved data.

### MVP Discipline

The MVP must prove the core loop before expanding into additional systems. Each feature must have a clear reason to exist in the MVP.

## 4. Target Audience

The target audience is Roblox players who enjoy:

1. Creature collection.
2. Incremental progression.
3. Combat-driven advancement.
4. Unlocking stronger or more developed versions of owned creatures.
5. Long-term goals that can be pursued across sessions.
6. Clear systems that are easy to start and deep enough to revisit.

The MVP should be approachable for new players while leaving enough structure for committed players to care about improvement.

The MVP should not assume players will read external documentation. Core goals and progress should be understandable through the game experience once UI and onboarding are designed.

## 5. Gameplay Loop

The approved MVP gameplay loop is intentionally high level until domain documents define exact rules.

The MVP loop is:

1. Player enters the game.
2. Player views current creature and progression state.
3. Player engages with available combat or challenge content.
4. Server resolves the outcome.
5. Player receives approved rewards or progress.
6. Player uses progress to improve creature growth, collection state, or world access.
7. Player repeats the loop to reach the next documented goal.

The loop must be understandable without requiring hidden mechanics.

The loop must not depend on unapproved systems such as trading, live events, crafting, clans, PvP, seasonal content, or monetization.

## 6. Progression Loop

Progression in the MVP exists to give players a durable reason to repeat the gameplay loop.

The MVP progression loop is:

1. Play approved content.
2. Earn approved progress.
3. Improve player state, creature state, or collection state.
4. Unlock access to the next approved goal.
5. Continue until the MVP progression endpoint is reached.

Progression must be:

1. Documented in `docs/PROGRESSION.md`.
2. Represented in `docs/DATA_SCHEMA.md` before implementation.
3. Persisted according to `docs/SAVE_SYSTEM.md` when persistence is introduced.
4. Balanced through approved data rather than hardcoded values.

This GDD does not approve exact level curves, XP values, unlock thresholds, rank names, reward rates, or pacing targets.

## 7. Combat Overview

Combat is an MVP support system for progression, creature growth, and reward delivery.

The role of combat in the MVP is:

1. Provide repeatable gameplay activity.
2. Create a context where creature growth matters.
3. Produce server-authoritative outcomes.
4. Feed progression and economy systems through approved rewards.
5. Support world progression through documented gates or milestones if approved.

Combat must remain consistent with `docs/COMBAT.md` once detailed combat rules are defined.

Combat must not be implemented from assumptions. Before implementation, the project must define:

1. What actions are available.
2. How outcomes are resolved.
3. What data is required.
4. What the server validates.
5. What the client is allowed to display or request.
6. What rewards or progress combat can produce.

This GDD does not approve specific attacks, abilities, damage formulas, enemy types, targeting rules, cooldowns, status effects, encounter formats, or balance values.

## 8. Creature System

Creatures are the central objects of player collection and growth in Project Genesis.

For the MVP, the creature system must support the minimum structure required for:

1. Player ownership or access to creatures.
2. Creature identity.
3. Creature state that can be displayed to the player.
4. Creature state that can support progression.
5. Creature data that can interact with combat, evolution, genes, collection, and persistence.

Creature data must be defined in `docs/DATA_SCHEMA.md` before implementation.

Creature persistence must be defined in `docs/SAVE_SYSTEM.md` before implementation.

Creature-related gameplay values must be data-driven.

This GDD does not approve creature species, rarities, stats, moves, roles, acquisition methods, inventory limits, visual styles, or sorting rules.

## 9. Evolution System

Evolution is an MVP system category for creature growth and transformation.

For the MVP, evolution must be treated as a documented progression system connected to creature state. It must not be implemented as a hidden reward, hardcoded upgrade, or client-driven change.

Before implementation, the project must define:

1. What evolution means in the MVP.
2. Which creature data changes during evolution.
3. What requirements must be met.
4. What the server validates.
5. What is saved.
6. What is shown to the player.

Evolution must align with `docs/PROGRESSION.md`, `docs/DATA_SCHEMA.md`, and `docs/SAVE_SYSTEM.md`.

This GDD does not approve evolution stages, requirements, costs, visual changes, stat changes, odds, branching paths, or reset behavior.

## 10. Gene System

Genes are an MVP system category for creature-specific identity, variation, or growth data.

For the MVP, genes must be handled as explicit data, not as hidden logic. Any gene-related behavior must be documented before implementation.

Before implementation, the project must define:

1. What a gene represents.
2. Where gene data is stored.
3. Whether gene data is static, mutable, inherited, rolled, unlocked, or otherwise changed.
4. How gene data affects other systems, if it does.
5. What values are visible to players.
6. What the server validates.

Genes must align with `docs/DATA_SCHEMA.md` before any code or content is created.

This GDD does not approve gene types, gene values, rarity rules, inheritance rules, mutation rules, stat modifiers, visuals, or acquisition logic.

## 11. Prestige

Prestige is an MVP system category for long-term progression reset, milestone recognition, or advanced progression state.

For the MVP, prestige is acknowledged as part of the intended design surface, but it must remain tightly scoped. It cannot be implemented until its purpose, requirements, effects, persistence, and relationship to progression are documented.

Before implementation, the project must define:

1. Why prestige exists in the MVP.
2. What player or creature state prestige affects.
3. What state, if any, prestige resets.
4. What state, if any, prestige preserves.
5. What reward or recognition prestige provides.
6. What risks prestige creates for player clarity and balance.

Prestige must align with `docs/PROGRESSION.md`, `docs/ECONOMY.md`, `docs/DATA_SCHEMA.md`, and `docs/SAVE_SYSTEM.md`.

This GDD does not approve prestige levels, prestige currencies, reset rules, multipliers, rewards, requirements, or UI flows.

## 12. Collection

Collection is a core MVP motivation.

For the MVP, collection must support the player's ability to understand what creatures they have and how that collection relates to progression.

The collection system must eventually define:

1. What counts as collected.
2. How collection state is represented.
3. How duplicate, variant, evolved, or gene-related creature states are handled if included.
4. How collection state is displayed.
5. How collection state is saved.
6. How collection progress interacts with rewards or progression if approved.

Collection must align with `docs/DATA_SCHEMA.md`, `docs/SAVE_SYSTEM.md`, and `docs/UI_GUIDELINES.md`.

This GDD does not approve collection completion rewards, indexes, rarity tiers, duplicate handling, collection bonuses, or collection UI layout.

## 13. Economy

The MVP economy exists only to support the approved progression, creature, combat, evolution, gene, prestige, and collection loops.

The economy must be conservative, server-authoritative, and documented before implementation.

Before implementation, the project must define:

1. Approved currencies or resources.
2. Approved sources.
3. Approved sinks.
4. Approved reward rules.
5. Approved cost rules.
6. Abuse risks and validation requirements.

Economy rules must align with `docs/ECONOMY.md`.

Economy data must align with `docs/DATA_SCHEMA.md`.

Economy persistence must align with `docs/SAVE_SYSTEM.md`.

This GDD does not approve currency names, prices, reward amounts, drop rates, shop systems, trading, monetization, premium currency, timed rewards, or dynamic pricing.

## 14. World Progression

World progression is the player's movement through MVP content.

For the MVP, world progression should provide structure for unlocking or accessing additional approved content. It must not become a content sprawl system.

Before implementation, the project must define:

1. What content is available at the start.
2. What content can be unlocked.
3. What requirements control access.
4. How access is validated by the server.
5. How progress is communicated to the player.
6. What world progression state is saved.

World progression must align with `docs/PROGRESSION.md`, `docs/DATA_SCHEMA.md`, `docs/SAVE_SYSTEM.md`, and `docs/ROADMAP.md`.

This GDD does not approve world names, maps, zones, biomes, portals, travel systems, stage counts, level requirements, or content quantities.

## 15. MVP Scope

The MVP scope is limited to proving the core Project Genesis experience.

Approved MVP system categories are:

1. Core gameplay loop.
2. Progression loop.
3. Combat support for progression.
4. Creature system foundation.
5. Evolution system foundation.
6. Gene system foundation.
7. Prestige system definition or foundation only if required by MVP progression.
8. Collection foundation.
9. Economy foundation.
10. World progression foundation.
11. Data schema required to support MVP systems.
12. Save system required to support MVP systems.
13. UI required to understand and operate MVP systems.
14. Technical architecture required to make the MVP server-authoritative and maintainable.

MVP implementation must proceed only after the relevant system details are documented in their domain files.

MVP scope does not approve full-scale content production. Content quantity must be defined through roadmap and task documents before work begins.

## 16. Explicitly Out of Scope

The following are out of scope for the MVP unless project leadership explicitly moves them into scope through documentation:

1. PvP.
2. Trading.
3. Clans, guilds, teams, or alliances.
4. Live events.
5. Seasonal systems.
6. Battle passes.
7. Monetization systems.
8. Premium currency.
9. Player-to-player economy.
10. Crafting.
11. Housing.
12. Social hubs beyond what MVP navigation requires.
13. Leaderboards.
14. Achievements unrelated to MVP validation.
15. Daily quests.
16. Timed login rewards.
17. Procedural world generation.
18. Large-scale open world content.
19. Advanced AI behaviors beyond MVP combat needs.
20. Full content collection beyond MVP validation needs.
21. Cosmetic systems.
22. Complex rarity systems.
23. Branching evolution paths.
24. Gene inheritance or mutation rules.
25. Prestige reward multipliers.
26. Admin tools.
27. Analytics systems.
28. Localization.
29. Console-specific or mobile-specific feature variants beyond basic Roblox compatibility.
30. Any feature not documented in this GDD or an approved domain document.

Out-of-scope items may be discussed as future ideas, but they must not be implemented, scaffolded, balanced, or implied as MVP commitments.

## 17. Future Expansion Notes

Future expansion notes are not MVP commitments.

The following areas may be considered after the MVP proves the core loop:

1. Additional creature content.
2. Additional world content.
3. Deeper combat rules.
4. Deeper collection goals.
5. Expanded evolution rules.
6. Expanded gene rules.
7. Expanded prestige systems.
8. Social features.
9. Event-driven content.
10. Monetization, only after economy and progression integrity are established.
11. Analytics, only after project leadership defines what decisions analytics should support.
12. Additional platform-specific UI polish.

Future expansion must follow the same documentation-first process as the MVP.

No future idea is approved for implementation until it is moved into scope through the roadmap, the relevant design document, and an approved task.
