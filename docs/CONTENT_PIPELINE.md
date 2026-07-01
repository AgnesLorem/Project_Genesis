# Content Pipeline

## Purpose

This document is the Standard Operating Procedure for adding content to Project Genesis.

Every content addition must be data-driven, documented, validated, reviewed, and aligned with the current MVP scope before implementation.

This document defines production workflow only. It does not approve new mechanics, content quantities, balance values, source folders, Lua, Luau, or final data file paths.

## Status

- Status: Active Draft
- Scope: Content authoring workflow and AI collaboration standards
- Owner: Production and Design
- Last Updated: 2026-06-28
- Review Cadence: Before any content batch, new content type, data schema change, or asset pipeline change
- Authority Level: Content production SOP

## Table of Contents

- [1. Core Pipeline Rules](#1-core-pipeline-rules)
- [2. Required Reading](#2-required-reading)
- [3. Content Approval Gates](#3-content-approval-gates)
- [4. AI Collaboration Model](#4-ai-collaboration-model)
- [5. Adding a Creature](#5-adding-a-creature)
- [6. Adding a Skill](#6-adding-a-skill)
- [7. Adding a Gene](#7-adding-a-gene)
- [8. Adding a Boss](#8-adding-a-boss)
- [9. Adding a World](#9-adding-a-world)
- [10. Adding a Quest](#10-adding-a-quest)
- [11. Adding a Collection Reward](#11-adding-a-collection-reward)
- [12. Adding a Tower Floor](#12-adding-a-tower-floor)
- [13. Adding an Event](#13-adding-an-event)
- [14. Adding AI Artwork](#14-adding-ai-artwork)
- [15. Cross-Content Validation](#15-cross-content-validation)
- [16. Batch Review Process](#16-batch-review-process)
- [17. Open Questions](#17-open-questions)

## 1. Core Pipeline Rules

1. Content must be data-driven.
2. Content must not be hardcoded into gameplay logic.
3. Content must have stable IDs.
4. Content must align with `docs/DATA_SCHEMA.md`.
5. Content must align with `docs/GDD_MASTER.md`.
6. Content must not contradict `docs/DECISIONS.md`.
7. Content must not introduce mechanics that are out of scope.
8. Content must not invent balance values outside approved balance tables.
9. Content must be reviewed before implementation.
10. Content must have documented validation criteria.
11. Content must have clear ownership.
12. Content must preserve server authority.
13. Content must not rely on chat-only approval.
14. Content must not ship with unresolved required references.
15. Content must update relevant documentation when it changes system behavior.

## 2. Required Reading

Every assistant adding content must read:

1. `docs/DECISIONS.md`
2. `docs/GDD_MASTER.md`
3. `docs/DATA_SCHEMA.md`
4. `docs/BALANCE.md`
5. `docs/TECH_ARCHITECTURE.md`
6. `agents/AGENTS.md`

Read additional documents by content type:

| Content Type | Required Additional Documents |
|---|---|
| Creature | `docs/ART_BIBLE.md`, `docs/PROGRESSION.md`, `docs/SAVE_SYSTEM.md` |
| Skill | `docs/COMBAT.md` |
| Gene | `docs/PROGRESSION.md`, `docs/SAVE_SYSTEM.md` |
| Boss | `docs/COMBAT.md`, `docs/PROGRESSION.md`, `docs/ECONOMY.md` |
| World | `docs/PROGRESSION.md`, `docs/ROADMAP.md` |
| Quest | `docs/PROGRESSION.md`, `docs/ROADMAP.md` |
| Collection Reward | `docs/ECONOMY.md`, `docs/SAVE_SYSTEM.md`, `docs/UI_GUIDELINES.md` |
| Tower Floor | `docs/ROADMAP.md`, `docs/PROGRESSION.md`, `docs/COMBAT.md` |
| Event | `docs/ROADMAP.md`, `docs/ECONOMY.md`, `docs/UI_GUIDELINES.md` |
| AI Artwork | `docs/ART_BIBLE.md` |

## 3. Content Approval Gates

Content must pass these gates before implementation:

1. Scope Gate: The content type is approved for MVP or explicitly approved as future work.
2. Design Gate: The content purpose is documented.
3. Data Gate: Required schema fields are documented.
4. Balance Gate: Numeric values are approved or marked `TBD`.
5. Art Gate: Visual requirements follow `docs/ART_BIBLE.md` when artwork is involved.
6. Technical Gate: Server authority and validation requirements are known.
7. Review Gate: A reviewer confirms documentation alignment.

Reserved content types require extra approval before data authoring:

| Content Type | Current Status | Required Approval Before Use |
|---|---|---|
| Quest | Reserved schema only | GDD, roadmap, and task approval |
| Collection Reward | Not approved in detail | Collection, economy, balance, and save approval |
| Tower Floor | Reserved schema only | GDD, roadmap, progression, and combat approval |
| Event | Future expansion only | GDD, roadmap, economy, UI, and task approval |

## 4. AI Collaboration Model

AI assistants must collaborate through files, not memory.

Roles:

1. Design assistant defines purpose, constraints, and acceptance criteria.
2. Data assistant verifies schema alignment and stable IDs.
3. Economy assistant verifies rewards, costs, sources, sinks, and exploit risk.
4. UI assistant verifies player-facing display requirements.
5. Art assistant verifies Art Bible compliance.
6. Reviewer assistant checks scope, consistency, risk, and documentation completeness.
7. Implementation assistant may only implement approved content after the documentation and data are ready.

Collaboration rules:

1. Read the decision log first.
2. Do not overwrite another assistant's unresolved work.
3. Record assumptions in the relevant document.
4. Mark unresolved fields as `TBD`.
5. Do not convert `TBD` into numbers without approval.
6. Use stable IDs consistently across documents.
7. Keep review findings in `reviews/` when substantive.
8. Update `docs/CHANGELOG.md` when a content decision is meaningful.
9. Do not approve your own high-risk content without review.
10. Handoff summaries must list changed files, unresolved questions, and validation status.

## 5. Adding a Creature

### Purpose

Add a new creature definition that can participate in approved Project Genesis systems without hardcoded behavior.

### Required Files

1. Creature data definition file when the data folder structure is approved.
2. Skill reference data if the creature uses existing approved skills.
3. Gene reference data if the creature uses approved gene slots or gene references.
4. Evolution reference data if the creature belongs to an approved evolution line.
5. Collection reference data if the creature is tracked by collection.
6. AI artwork file or artwork request if visual content is required.

### Required Documentation

1. `docs/GDD_MASTER.md` for creature system scope.
2. `docs/DATA_SCHEMA.md` Creature Schema.
3. `docs/BALANCE.md` Creature Scaling.
4. `docs/ART_BIBLE.md` for visual direction.
5. `docs/SAVE_SYSTEM.md` if ownership or persistence is affected.
6. `docs/DECISIONS.md` for approved constraints.

### Validation Checklist

1. Creature has a stable `creatureId`.
2. Creature does not reuse another creature ID.
3. Required schema fields are present.
4. Creature references only approved skills.
5. Creature references only approved genes.
6. Creature references only approved evolution data.
7. Creature has no hardcoded gameplay values.
8. Base stats are approved or marked `TBD`.
9. Creature art follows the Art Bible if artwork exists.
10. Creature does not imply unapproved rarity, acquisition, or mechanics.

### Review Checklist

1. Scope matches MVP or approved content plan.
2. Creature role is documented without inventing mechanics.
3. Data references are valid.
4. Balance placeholders are not fake numbers.
5. Art direction is consistent.
6. Collection implications are documented.
7. Save implications are documented.
8. Reviewer confirms no feature creep.

### Definition of Done

1. Creature data is complete or explicitly marked `TBD`.
2. All references resolve to approved data.
3. Required documentation is updated.
4. Artwork is approved or tracked as pending.
5. Review is complete.
6. Implementation is not started until all required gates pass.

## 6. Adding a Skill

### Purpose

Add a skill definition for use by approved combat systems.

### Required Files

1. Skill data definition file when the data folder structure is approved.
2. Effect reference data if effects are approved.
3. Creature reference updates if the skill is assigned to creatures.
4. Boss or enemy reference updates if the skill is assigned to enemies.

### Required Documentation

1. `docs/COMBAT.md` for skill and cooldown rules.
2. `docs/DATA_SCHEMA.md` Skill Schema.
3. `docs/BALANCE.md` Skill Scaling.
4. `docs/DECISIONS.md` for No Mana, Cooldown Skills, and Auto Battle decisions.

### Validation Checklist

1. Skill has a stable `skillId`.
2. Skill uses cooldown rules.
3. Skill does not use mana.
4. Skill does not introduce stamina, energy, ammo, rage, combo, cards, or manual resources.
5. Cooldown value is approved or marked `TBD`.
6. Target rule is approved or marked `TBD`.
7. Skill priority is approved or marked `TBD`.
8. Skill does not introduce unapproved status effects.
9. Skill is server-validatable.
10. Skill does not require manual player command selection.

### Review Checklist

1. Skill aligns with auto battle.
2. Skill has no unapproved resource cost.
3. Skill data matches schema.
4. Skill balance is documented as approved or `TBD`.
5. Skill does not imply new combat systems.
6. Server authority is preserved.

### Definition of Done

1. Skill data is documented.
2. Cooldown and targeting assumptions are clear.
3. Assigned users of the skill are documented.
4. Balance fields are approved or `TBD`.
5. Review is complete.

## 7. Adding a Gene

### Purpose

Add a gene data definition without inventing gene behavior.

### Required Files

1. Gene data definition file when the data folder structure is approved.
2. Creature reference updates if genes are assigned or allowed.
3. Save schema updates if gene state is persisted.

### Required Documentation

1. `docs/GDD_MASTER.md` Gene System.
2. `docs/DATA_SCHEMA.md` Gene Schema.
3. `docs/BALANCE.md` Gene Scaling.
4. `docs/SAVE_SYSTEM.md` if gene state is persisted.
5. `docs/DECISIONS.md`.

### Validation Checklist

1. Gene has a stable `geneId`.
2. Gene behavior is approved or marked `TBD`.
3. Gene value type is documented.
4. Gene visibility is documented.
5. Gene effect references are approved or empty.
6. Gene does not introduce inheritance, mutation, rarity, or stat modifiers unless approved.
7. Gene data is server-validatable.
8. Gene save behavior is documented if persisted.

### Review Checklist

1. Gene does not exceed approved scope.
2. Gene does not create hidden power.
3. Gene values are approved or `TBD`.
4. UI visibility implications are documented.
5. Save implications are documented.
6. Reviewer confirms no unapproved gene mechanics were added.

### Definition of Done

1. Gene schema fields are complete or `TBD`.
2. Any creature references are documented.
3. Save and UI implications are clear.
4. Review is complete.

## 8. Adding a Boss

### Purpose

Add a boss encounter definition for approved 3v3 Boss or Challenge combat.

### Required Files

1. Boss data definition file when the data folder structure is approved.
2. Boss phase data if phases are used.
3. Enemy data references.
4. Skill references.
5. Reward references if rewards are approved.
6. World or encounter references if the boss belongs to a world.

### Required Documentation

1. `docs/COMBAT.md` Boss and Challenge rules.
2. `docs/DATA_SCHEMA.md` Boss Schema.
3. `docs/BALANCE.md` Boss Scaling.
4. `docs/ECONOMY.md` if rewards are involved.
5. `docs/PROGRESSION.md` if unlocks or progression are involved.

### Validation Checklist

1. Boss has a stable `bossId`.
2. Boss is 3v3 if it is a Boss or Challenge encounter.
3. Recommended Power is guidance only.
4. Boss phase count is approved or `TBD`.
5. Boss phase triggers are approved or `TBD`.
6. Boss skills are approved.
7. Boss rewards are approved or empty.
8. Boss does not introduce raid, multiplayer boss, leaderboard, or timed event mechanics.
9. Boss state is server-owned.
10. Auto Retry behavior is documented if available.

### Review Checklist

1. Boss aligns with combat rules.
2. Boss difficulty is documented without fake numbers.
3. Boss phase behavior is clear or marked `TBD`.
4. Reward risk is reviewed.
5. World placement is documented if applicable.
6. Server authority is preserved.

### Definition of Done

1. Boss definition is complete or marked `TBD`.
2. Encounter references are valid.
3. Rewards are approved or absent.
4. Review is complete.
5. No unapproved boss mechanics are introduced.

## 9. Adding a World

### Purpose

Add world progression content that structures approved MVP gameplay.

### Required Files

1. World data definition file when the data folder structure is approved.
2. Encounter references.
3. Boss references if the world includes approved bosses.
4. Unlock requirement references if progression gates are approved.
5. Artwork references if world presentation art exists.

### Required Documentation

1. `docs/GDD_MASTER.md` World Progression.
2. `docs/DATA_SCHEMA.md` World Schema.
3. `docs/BALANCE.md` World Scaling.
4. `docs/PROGRESSION.md`.
5. `docs/ROADMAP.md`.
6. `docs/ART_BIBLE.md` if artwork is required.

### Validation Checklist

1. World has a stable `worldId`.
2. World has approved purpose in roadmap or task scope.
3. World does not invent zones, biomes, maps, or travel mechanics without approval.
4. Encounters are approved.
5. Recommended Power is guidance only.
6. Unlock requirements are documented and not hidden power gates.
7. Rewards are approved or absent.
8. World progression state is save-compatible if persisted.

### Review Checklist

1. World supports MVP progression.
2. World does not create content sprawl.
3. All references are valid.
4. Balance placeholders are explicit.
5. UI and art implications are documented.
6. Reviewer confirms roadmap alignment.

### Definition of Done

1. World definition is documented.
2. Encounter and boss references are valid.
3. Unlocks are approved or `TBD`.
4. Required docs are updated.
5. Review is complete.

## 10. Adding a Quest

### Purpose

Add a quest or objective only after quests are approved for the current scope.

Quests are currently a reserved schema surface and are not automatically approved for MVP implementation.

### Required Files

1. Quest data definition file when the data folder structure is approved.
2. Objective reference data.
3. Reward references if rewards are approved.
4. World or progression references if the quest belongs to a world.
5. UI copy references if quest presentation is approved.

### Required Documentation

1. `docs/GDD_MASTER.md` if quest scope changes.
2. `docs/DATA_SCHEMA.md` Quest Schema.
3. `docs/PROGRESSION.md`.
4. `docs/BALANCE.md` Reward Philosophy.
5. `docs/ECONOMY.md` if rewards exist.
6. `docs/UI_GUIDELINES.md` if displayed in UI.
7. `docs/DECISIONS.md` if a new decision is required.

### Validation Checklist

1. Quest has explicit approval before data authoring.
2. Quest has a stable `questId`.
3. Quest does not introduce daily quests unless approved.
4. Quest does not introduce timed login rewards unless approved.
5. Quest objectives are documented.
6. Quest repeat rules are approved or `none`.
7. Quest rewards are approved or empty.
8. Quest state is save-compatible if persisted.
9. Quest does not bypass progression validation.

### Review Checklist

1. Scope approval is documented.
2. Quest purpose is clear.
3. Objective data is valid.
4. Rewards are reviewed.
5. UI implications are documented.
6. Reviewer confirms the quest does not create feature creep.

### Definition of Done

1. Quest approval is recorded.
2. Quest data matches schema.
3. Objectives and rewards are documented.
4. Save and UI impacts are documented.
5. Review is complete.

## 11. Adding a Collection Reward

### Purpose

Add a reward tied to collection progress only after collection reward rules are approved.

Collection rewards are not currently approved in detail.

### Required Files

1. Collection data update.
2. Reward data definition when the data folder structure is approved.
3. Economy source reference if the reward grants currency or resources.
4. Save state update if reward claim state is persisted.
5. UI presentation reference if the reward is displayed.

### Required Documentation

1. `docs/GDD_MASTER.md` Collection.
2. `docs/DATA_SCHEMA.md` Collection and Player Save schemas.
3. `docs/BALANCE.md` Collection Bonus Philosophy and Reward Philosophy.
4. `docs/ECONOMY.md`.
5. `docs/SAVE_SYSTEM.md`.
6. `docs/UI_GUIDELINES.md`.

### Validation Checklist

1. Collection reward approval is documented.
2. Reward has a stable ID.
3. Reward trigger is documented.
4. Reward amount is approved or `TBD`.
5. Reward cannot be claimed repeatedly unless repeat behavior is approved.
6. Reward source is server-authoritative.
7. Reward does not create hidden mandatory power.
8. Claim state is save-compatible if required.
9. Duplicate handling is documented if relevant.

### Review Checklist

1. Reward supports collection without forcing completion.
2. Economy impact is reviewed.
3. Save impact is reviewed.
4. UI clarity is reviewed.
5. Abuse risk is reviewed.
6. Reviewer confirms reward values are approved or `TBD`.

### Definition of Done

1. Reward rule is approved.
2. Reward data is documented.
3. Economy and save references are valid.
4. UI requirements are documented.
5. Review is complete.

## 12. Adding a Tower Floor

### Purpose

Add tower-style progression content only after Tower is approved for scope.

Tower is currently a reserved schema surface and is not approved for MVP by default.

### Required Files

1. Tower data definition file when the data folder structure is approved.
2. Tower floor data definition.
3. Encounter or boss references.
4. Reward references if approved.
5. Unlock requirement references if approved.

### Required Documentation

1. `docs/GDD_MASTER.md` if Tower enters scope.
2. `docs/DATA_SCHEMA.md` Tower Schema.
3. `docs/ROADMAP.md`.
4. `docs/PROGRESSION.md`.
5. `docs/COMBAT.md` if combat occurs on the floor.
6. `docs/BALANCE.md` World, Boss, Combat, and Reward sections.

### Validation Checklist

1. Tower scope approval is documented.
2. Tower floor has a stable ID.
3. Floor order is documented.
4. Encounter references are valid.
5. Rewards are approved or empty.
6. Reset rules are approved or `none`.
7. Timed resets are not added unless approved.
8. Recommended Power remains guidance only.
9. Floor does not introduce unapproved battle modes.

### Review Checklist

1. Tower approval is confirmed.
2. Floor supports documented progression.
3. Difficulty and reward placeholders are clear.
4. Combat references align with combat rules.
5. Reset behavior is reviewed.
6. Reviewer confirms no tower feature creep.

### Definition of Done

1. Tower scope is approved.
2. Floor data is documented.
3. Encounter and reward references are valid.
4. Required docs are updated.
5. Review is complete.

## 13. Adding an Event

### Purpose

Add event-driven content only after event content is approved for scope.

This workflow refers to player-facing content events. It does not replace the technical event-driven communication architecture.

Live events and event-driven content are not MVP commitments by default.

### Required Files

1. Event data definition file when the data folder structure is approved.
2. Schedule or availability data if time-based behavior is approved.
3. Reward references if approved.
4. Quest, world, boss, or tower references if the event uses approved content types.
5. UI presentation references.
6. Artwork references if event art is required.

### Required Documentation

1. `docs/GDD_MASTER.md` if event content enters scope.
2. `docs/ROADMAP.md`.
3. `docs/DATA_SCHEMA.md` if event schema is added.
4. `docs/BALANCE.md` Reward Philosophy.
5. `docs/ECONOMY.md` if rewards exist.
6. `docs/UI_GUIDELINES.md`.
7. `docs/ART_BIBLE.md` if artwork exists.
8. `docs/DECISIONS.md` if a new decision is required.

### Validation Checklist

1. Event scope approval is documented.
2. Event has a stable ID.
3. Event availability rules are documented.
4. Event does not introduce live operations complexity without approval.
5. Event rewards are approved or empty.
6. Event does not introduce monetization unless separately approved.
7. Event does not bypass progression, economy, or save validation.
8. Event UI requirements are documented.
9. Event artwork follows the Art Bible if used.

### Review Checklist

1. Event is approved for scope.
2. Schedule and availability rules are clear.
3. Rewards are reviewed.
4. UI and art impact are reviewed.
5. Save and economy risks are reviewed.
6. Reviewer confirms the event is not an undocumented live event system.

### Definition of Done

1. Event approval is recorded.
2. Event data is documented.
3. Rewards, schedule, UI, and art references are valid or absent.
4. Required docs are updated.
5. Review is complete.

## 14. Adding AI Artwork

### Purpose

Add AI-generated artwork that matches the Project Genesis Anime Fantasy style.

### Required Files

1. Approved image asset file.
2. Prompt record.
3. Negative prompt record.
4. Source notes or generation notes.
5. Asset metadata when the asset tracking workflow exists.
6. Related content reference if artwork is tied to a creature, world, boss, event, or UI surface.

### Required Documentation

1. `docs/ART_BIBLE.md`.
2. `docs/DATA_SCHEMA.md` if the asset is referenced by data.
3. Relevant content document if artwork implies content.
4. `docs/UI_GUIDELINES.md` if used in UI.
5. `docs/DECISIONS.md` for AI-generated artwork and Anime Fantasy decisions.

### Validation Checklist

1. Artwork follows Anime Fantasy direction.
2. Artwork uses approved prompt structure.
3. Artwork includes negative prompt rules.
4. Creature or subject is readable.
5. Silhouette is clear.
6. Palette fits Project Genesis.
7. No text, logo, watermark, signature, fake UI, stat number, or rarity label is present.
8. Artwork does not imply unapproved mechanics.
9. Artwork does not imitate another franchise or living artist.
10. Artwork can be cropped for intended UI use.
11. Related content ID is stable if referenced by data.

### Review Checklist

1. Art Bible checklist passes.
2. Style consistency is reviewed against existing approved art.
3. Prompt and negative prompt are saved.
4. Asset use case is documented.
5. Reviewer confirms no unapproved gameplay implications.
6. Rejected variants are noted if useful for future prompt guidance.

### Definition of Done

1. Final artwork is approved.
2. Prompt record is saved.
3. Negative prompt record is saved.
4. Asset reference is documented.
5. Related data references are valid if used.
6. Review is complete.

## 15. Cross-Content Validation

Before any content batch is considered ready:

1. All IDs are stable and unique.
2. All references resolve.
3. No disabled content is referenced by active content unless explicitly allowed.
4. All balance values are approved or `TBD`.
5. No content type bypasses approval gates.
6. No content introduces out-of-scope mechanics.
7. No client-owned value becomes authoritative.
8. All save implications are documented.
9. All UI implications are documented.
10. All art requirements are documented.
11. All rewards are reviewed by economy.
12. All combat content is reviewed against `docs/COMBAT.md`.
13. All progression content is reviewed against `docs/PROGRESSION.md`.
14. All schema changes are reviewed against `docs/DATA_SCHEMA.md`.
15. All meaningful changes are recorded in `docs/CHANGELOG.md` when appropriate.

## 16. Batch Review Process

Content batches should be reviewed as a set when they are related.

Batch review steps:

1. Confirm the batch objective.
2. Confirm the batch is in scope.
3. Confirm all required documents were read.
4. Confirm all required data files are listed.
5. Confirm all references resolve.
6. Confirm all `TBD` fields are intentional.
7. Confirm no fake numeric values were inserted.
8. Confirm all artwork follows the Art Bible.
9. Confirm all rewards are reviewed.
10. Confirm all save implications are reviewed.
11. Confirm all UI implications are reviewed.
12. Confirm implementation can proceed without inventing missing rules.

Batch review outputs:

1. Approved.
2. Approved with documented `TBD` placeholders.
3. Blocked by missing design approval.
4. Blocked by missing schema.
5. Blocked by missing balance approval.
6. Rejected as out of scope.

## 17. Open Questions

1. Final source data folder structure.
2. Final naming convention for data files.
3. Final asset metadata format.
4. Final prompt storage format.
5. Final review file naming convention for content batches.
6. Final approval workflow for reserved content types.
7. Final owner for content batch sign-off.
8. Final toolchain for validating data references.
9. Final process for promoting future content into MVP scope.
