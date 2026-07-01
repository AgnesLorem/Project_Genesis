# Balance

## Purpose

This document defines the balancing philosophy for Project Genesis.

This is not a spreadsheet.

This document does not approve final numbers, formulas, curves, reward amounts, costs, rates, stat values, or content quantities.

The purpose of this document is to define how balance should be approached once numeric data is ready to be authored in approved data tables.

## Status

- Status: Active Draft
- Scope: MVP balance philosophy and future balance placeholders
- Owner: Design and Balance
- Last Updated: 2026-06-28
- Review Cadence: Before any tuning pass, formula change, reward change, economy change, progression change, or combat balance change
- Authority Level: Balance philosophy reference

## Table of Contents

- [1. Balance Principles](#1-balance-principles)
- [2. Scaling Philosophy](#2-scaling-philosophy)
- [3. Progression Philosophy](#3-progression-philosophy)
- [4. Combat Scaling](#4-combat-scaling)
- [5. Economy Scaling](#5-economy-scaling)
- [6. Creature Scaling](#6-creature-scaling)
- [7. Boss Scaling](#7-boss-scaling)
- [8. World Scaling](#8-world-scaling)
- [9. Skill Scaling](#9-skill-scaling)
- [10. Gene Scaling](#10-gene-scaling)
- [11. Evolution Scaling](#11-evolution-scaling)
- [12. Prestige Scaling](#12-prestige-scaling)
- [13. Collection Bonus Philosophy](#13-collection-bonus-philosophy)
- [14. Reward Philosophy](#14-reward-philosophy)
- [15. Placeholder Balance Tables](#15-placeholder-balance-tables)
- [16. Balance Review Checklist](#16-balance-review-checklist)
- [17. Open Questions](#17-open-questions)

## 1. Balance Principles

Purpose

Define the global rules that all Project Genesis balancing must follow.

Design Goal

Balance should make the MVP progression loop clear, repeatable, and satisfying without creating hidden complexity or unapproved systems.

Known Variables

1. Project Genesis is MVP-first.
2. Gameplay must be data-driven.
3. The server owns authoritative outcomes.
4. Combat is auto battle.
5. Combat uses SPD-driven Action Gauge timing.
6. Skills use cooldowns.
7. There is no mana.
8. There is no stamina.
9. Story Mode is 1v1.
10. Boss and Challenge battles are 3v3.
11. Recommended Power is guidance only.
12. DEF reduces damage by percentage.
13. Creatures fully heal after battle.
14. Evolution resets creature level.
15. Collection uses a hybrid model.

Unknown Variables

1. Exact stat list.
2. Exact damage formula.
3. Exact DEF reduction formula.
4. Exact progression curve.
5. Exact reward values.
6. Exact currency list.
7. Exact evolution requirements.
8. Exact collection bonus behavior.
9. Exact prestige behavior.
10. Exact world content quantities.

Future Balance Notes

All numeric values must be authored in data tables after their formulas, bounds, and review process are approved. Balance changes must not be hidden inside gameplay code.

## 2. Scaling Philosophy

Purpose

Define how power, difficulty, rewards, and progression should grow across the MVP.

Design Goal

Scaling should create clear growth without forcing excessive grinding, runaway stat inflation, or hard progression walls.

Known Variables

1. Recommended Power exists as guidance.
2. Recommended Power is not a hard gate.
3. World progression exists to structure MVP content.
4. Creature growth is central to player investment.
5. Balance values must be data-driven.

Unknown Variables

1. Exact power formula.
2. Exact stat growth curve.
3. Exact enemy scaling curve.
4. Exact world difficulty curve.
5. Exact reward scaling curve.
6. Exact acceptable time-to-progress targets.

Future Balance Notes

Scaling should be tested against under-recommended, on-recommended, and over-recommended player states. Because power is not a gate, content must communicate risk clearly without blocking attempts.

| Scaling Area | Current Rule | Numeric Value | Notes |
|---|---|---|---|
| Player power growth | TBD | TBD | Must be data-driven. |
| Enemy power growth | TBD | TBD | Must align with encounter data. |
| Reward growth | TBD | TBD | Must align with economy rules. |
| World difficulty growth | TBD | TBD | Must remain readable to players. |

## 3. Progression Philosophy

Purpose

Define how player progress should feel and how pacing should be evaluated.

Design Goal

Progression should always give players a visible next goal and a durable reason to repeat the core loop.

Known Variables

1. MVP progression exists to support repeatable play.
2. Players improve player state, creature state, or collection state.
3. Progression must be represented in data and save structure.
4. Exact level curves and unlock thresholds are not approved.

Unknown Variables

1. Level curve.
2. XP sources.
3. XP amounts.
4. Unlock thresholds.
5. Milestone count.
6. MVP endpoint.
7. Expected session length.

Future Balance Notes

Progression should avoid both flat pacing and sudden unexplained spikes. Unlocks should feel earned but not opaque.

| Progression Variable | Current Status | Placeholder Value | Notes |
|---|---|---|---|
| XP curve | Unknown | TBD | Do not implement until approved. |
| Unlock thresholds | Unknown | TBD | Must align with world progression. |
| MVP endpoint | Unknown | TBD | Must be defined in roadmap or progression docs. |
| Expected repeat count | Unknown | TBD | Must be validated through playtesting. |

## 4. Combat Scaling

Purpose

Define how combat difficulty and combat outcomes should scale.

Design Goal

Combat should validate creature growth and progression while remaining simple enough to understand, tune, and test for MVP.

Known Variables

1. Auto Battle is approved.
2. SPD fills the Action Gauge.
3. Skills are cooldown based.
4. Mana is not used.
5. DEF reduces damage by percentage.
6. Damage formula is simplified for MVP.
7. Player creatures fully heal after battle.
8. Enemy AI is intentionally simple.

Unknown Variables

1. Raw damage inputs.
2. Simplified damage formula.
3. DEF reduction formula.
4. Minimum damage rule.
5. Rounding rule.
6. SPD gauge coefficient.
7. Action Gauge threshold.
8. Cooldown unit.
9. Skill fallback behavior.

Future Balance Notes

Combat balance should focus on win rate, time-to-win, clarity of outcomes, and how much creature growth matters. It should not add new resources or manual controls.

| Combat Variable | Current Rule | Placeholder Value | Notes |
|---|---|---|---|
| Damage formula | Simplified MVP formula | TBD | Must include percentage DEF reduction. |
| DEF reduction | Percentage reduction | TBD | No flat-only undocumented rule. |
| Gauge threshold | Action Gauge threshold | TBD | Must align with SPD scaling. |
| Skill cooldown | Cooldown based | TBD | No mana cost. |
| Enemy AI priority | Simple AI | TBD | Must be deterministic or testable. |

## 5. Economy Scaling

Purpose

Define how currencies, sources, sinks, costs, and rewards should scale.

Design Goal

The MVP economy should support progression without becoming the primary source of friction, confusion, or exploit risk.

Known Variables

1. Economy exists to support approved MVP loops.
2. Economy must be server-authoritative.
3. Economy must be data-driven.
4. No premium currency is approved for MVP.
5. No monetization system is approved for MVP.
6. No player-to-player economy is approved for MVP.

Unknown Variables

1. Currency names.
2. Currency count.
3. Reward amounts.
4. Cost amounts.
5. Sources.
6. Sinks.
7. Caps.
8. Inventory limits.

Future Balance Notes

Economy scaling should keep rewards meaningful while preventing runaway accumulation. Every source should have a reason, and every sink should support an approved loop.

| Economy Variable | Current Status | Placeholder Value | Notes |
|---|---|---|---|
| Currency list | Unknown | TBD | Must be approved in economy docs. |
| Reward sources | Unknown | TBD | Must be server-authoritative. |
| Cost sinks | Unknown | TBD | Must not create hidden gates. |
| Caps | Unknown | TBD | Only add if needed for integrity. |

## 6. Creature Scaling

Purpose

Define how creature power and usefulness should grow.

Design Goal

Creature scaling should make player investment feel meaningful while preserving readable differences between creature state, evolution state, skills, and genes.

Known Variables

1. Creatures are central to collection and growth.
2. Creature data includes baseline combat stats.
3. Referenced combat stats currently include HP, ATK, DEF, and SPD.
4. Creature-related gameplay values must be data-driven.
5. Creature species, rarities, and final stats are not approved.

Unknown Variables

1. Final stat list.
2. Base stat ranges.
3. Level-based stat growth.
4. Skill unlock behavior.
5. Gene impact.
6. Evolution stat impact.
7. Power calculation.

Future Balance Notes

Creature scaling should avoid making a single stat dominate all decisions. SPD is important because it affects gauge fill, but it must be balanced against damage and survivability once formulas are approved.

| Creature Variable | Current Status | Placeholder Value | Notes |
|---|---|---|---|
| HP scaling | Unknown | TBD | Must align with combat pacing. |
| ATK scaling | Unknown | TBD | Must align with damage formula. |
| DEF scaling | Unknown | TBD | Must align with percentage reduction. |
| SPD scaling | Known role, unknown values | TBD | Fills Action Gauge. |
| Power contribution | Unknown | TBD | Recommendation only. |

## 7. Boss Scaling

Purpose

Define how boss and challenge difficulty should scale.

Design Goal

Bosses should feel like higher-importance encounters without requiring complex AI, raids, leaderboards, or unapproved systems.

Known Variables

1. Boss and Challenge battles are 3v3.
2. Bosses may have one or multiple phases.
3. Boss phase state is server-owned.
4. Recommended Power is guidance only.
5. Boss AI remains simple unless later documented.

Unknown Variables

1. Boss stat scaling.
2. Boss phase triggers.
3. Boss phase count per boss.
4. Whether phase transitions change stats, skills, targets, or visuals.
5. Boss reward scaling.
6. Boss retry behavior.

Future Balance Notes

Boss scaling should use clearly visible difficulty increases. Multi-phase bosses should remain understandable and should not become hidden puzzle encounters unless later approved.

| Boss Variable | Current Status | Placeholder Value | Notes |
|---|---|---|---|
| Boss HP scaling | Unknown | TBD | Must support 3v3 format. |
| Boss damage scaling | Unknown | TBD | Must use approved damage formula. |
| Phase trigger | Unknown | TBD | Must be server-owned. |
| Phase effect | Unknown | TBD | Must be documented before use. |
| Boss reward | Unknown | TBD | Must align with reward philosophy. |

## 8. World Scaling

Purpose

Define how world progression should scale across MVP content.

Design Goal

World scaling should structure player advancement without becoming a hard power gate or content sprawl system.

Known Variables

1. World progression structures access to MVP content.
2. Recommended Power may guide content difficulty.
3. Recommended Power is not a hard gate.
4. Exact worlds, zones, stages, and content quantities are not approved.

Unknown Variables

1. Number of worlds.
2. Number of encounters per world.
3. World unlock requirements.
4. Difficulty increase per world.
5. Reward increase per world.
6. MVP world endpoint.

Future Balance Notes

World scaling should make each new world feel like a clear step up while still allowing players to attempt content below or above recommendation.

| World Variable | Current Status | Placeholder Value | Notes |
|---|---|---|---|
| World count | Unknown | TBD | Must be roadmap-approved. |
| Encounter count | Unknown | TBD | Must avoid content sprawl. |
| Recommended Power range | Unknown | TBD | Guidance only. |
| Unlock requirement | Unknown | TBD | Must not become undocumented power gate. |

## 9. Skill Scaling

Purpose

Define how skill strength, cooldowns, and utility should scale.

Design Goal

Skill scaling should add meaningful creature identity without adding mana, manual targeting, complex resource systems, or excessive combat complexity.

Known Variables

1. Skills are cooldown based.
2. Skills do not consume mana.
3. Skill cooldown values come from skill data.
4. Skill availability is server-owned.
5. Manual command selection is not approved.

Unknown Variables

1. Skill categories.
2. Skill target rules.
3. Skill priority rules.
4. Cooldown values.
5. Cooldown unit.
6. Damage multipliers.
7. Fallback action.

Future Balance Notes

Skill scaling should balance output and cooldown. Stronger skills should have clear data-driven constraints, but those constraints must not introduce unapproved resources.

| Skill Variable | Current Status | Placeholder Value | Notes |
|---|---|---|---|
| Cooldown value | Known field, unknown values | TBD | No mana cost. |
| Damage value | Unknown | TBD | Must align with formula. |
| Target rule | Unknown | TBD | Must be server-validated. |
| Auto priority | Unknown | TBD | Required for auto battle. |

## 10. Gene Scaling

Purpose

Define how gene-related balance should be approached once gene behavior is approved.

Design Goal

Genes should support creature identity or variation without creating hidden power spikes, unreadable complexity, or unreviewable randomness.

Known Variables

1. Gene system is an MVP system category.
2. Gene behavior is not yet defined.
3. Gene data must be explicit.
4. Gene values, rarity rules, inheritance rules, mutation rules, and stat modifiers are not approved.

Unknown Variables

1. What a gene represents.
2. Whether gene data is static or mutable.
3. Whether genes affect combat.
4. Whether genes affect progression.
5. Whether genes are visible to players.
6. Gene value ranges.
7. Gene acquisition rules.

Future Balance Notes

Gene scaling must be conservative until player comprehension is proven. Any gene power effect must be visible, explainable, and data-driven.

| Gene Variable | Current Status | Placeholder Value | Notes |
|---|---|---|---|
| Gene category | Unknown | TBD | Must be defined before implementation. |
| Gene value range | Unknown | TBD | No hidden unbounded ranges. |
| Gene effect | Unknown | TBD | Must not imply unapproved mechanics. |
| Visibility | Unknown | TBD | Must support player clarity. |

## 11. Evolution Scaling

Purpose

Define how evolution balance should be approached.

Design Goal

Evolution should feel like a meaningful creature growth milestone while remaining understandable and controlled.

Known Variables

1. Evolution is an MVP system category.
2. Evolution resets creature level.
3. Evolution must be server-authoritative.
4. Evolution must be data-driven.
5. Branching evolution paths are out of scope for MVP.

Unknown Variables

1. Reset target level.
2. Evolution requirements.
3. Evolution costs.
4. Preserved state.
5. Changed state.
6. Stat changes.
7. Visual changes.
8. Reward or unlock relationship.

Future Balance Notes

Evolution balance should make the reset feel purposeful rather than punitive. The player should understand what is gained, what resets, and what is preserved before committing.

| Evolution Variable | Current Status | Placeholder Value | Notes |
|---|---|---|---|
| Reset level | Known concept, unknown value | TBD | Exact reset target not approved. |
| Requirement | Unknown | TBD | Must align with progression. |
| Cost | Unknown | TBD | Must align with economy. |
| Stat change | Unknown | TBD | Must be data-driven. |
| Preserved state | Unknown | TBD | Must be explicit before implementation. |

## 12. Prestige Scaling

Purpose

Define how prestige balance should be approached if prestige is enabled.

Design Goal

Prestige should support long-term progression only if it improves the MVP loop without confusing players or creating runaway multipliers.

Known Variables

1. Prestige is acknowledged as a system category.
2. Prestige is conditional and not fully specified.
3. Prestige effects, requirements, rewards, reset rules, and preserved state are not approved.
4. Prestige reward multipliers are out of scope unless later documented.

Unknown Variables

1. Whether prestige is enabled for MVP.
2. Prestige requirement.
3. Prestige reset behavior.
4. Prestige preserved state.
5. Prestige reward.
6. Prestige level cap.
7. Prestige pacing.

Future Balance Notes

Prestige should not be balanced until its purpose is approved. If enabled, it must avoid invalidating early progression or creating unbounded acceleration.

| Prestige Variable | Current Status | Placeholder Value | Notes |
|---|---|---|---|
| Enablement | Unknown | TBD | Future decision required. |
| Requirement | Unknown | TBD | Must align with progression. |
| Reset rule | Unknown | TBD | Must be documented before implementation. |
| Reward | Unknown | TBD | Multipliers are not approved. |
| Cap | Unknown | TBD | Required if levels exist. |

## 13. Collection Bonus Philosophy

Purpose

Define how collection-related bonuses should be approached.

Design Goal

Collection should motivate creature discovery and ownership without creating mandatory hidden power requirements.

Known Variables

1. Collection is a core MVP motivation.
2. Collection uses a hybrid model.
3. Collection state must account for collection progress and owned creature state.
4. Exact collection bonuses are not approved.
5. Collection completion rewards are not approved.

Unknown Variables

1. What counts as collected.
2. Duplicate handling.
3. Evolved form handling.
4. Gene-related collection behavior.
5. Whether collection grants bonuses.
6. Bonus types.
7. Bonus values.

Future Balance Notes

Collection bonuses, if approved, should be modest, readable, and non-mandatory. They should reward engagement without making collection completion a hidden requirement for basic progression.

| Collection Variable | Current Status | Placeholder Value | Notes |
|---|---|---|---|
| Collection rule | Hybrid model approved, details TBD | TBD | Must be defined before implementation. |
| Bonus type | Unknown | TBD | No bonus approved yet. |
| Bonus value | Unknown | TBD | Do not invent numbers. |
| Duplicate value | Unknown | TBD | Must avoid exploit loops. |

## 14. Reward Philosophy

Purpose

Define how rewards should support progression, economy, combat, collection, and repeat play.

Design Goal

Rewards should make repeat play feel worthwhile while preserving economy integrity and server authority.

Known Variables

1. Rewards must be server-authoritative.
2. Rewards may follow combat outcomes only when approved.
3. Auto Retry must not bypass reward validation.
4. Economy sources and sinks must be approved.
5. Reward amounts are not approved.

Unknown Variables

1. Reward types.
2. Reward amounts.
3. Drop rates.
4. First-clear rewards.
5. Repeat rewards.
6. Boss rewards.
7. Challenge rewards.
8. Collection rewards.
9. Evolution-related rewards.

Future Balance Notes

Rewards should be evaluated by how they affect progression pacing, economy accumulation, and player motivation. Rewards should not be added simply to make a system feel complete.

| Reward Variable | Current Status | Placeholder Value | Notes |
|---|---|---|---|
| Combat reward | Unknown | TBD | Must align with economy. |
| Boss reward | Unknown | TBD | Must align with boss difficulty. |
| Challenge reward | Unknown | TBD | Must align with 3v3 format. |
| Collection reward | Not approved | TBD | Requires collection decision. |
| Repeat reward | Unknown | TBD | Must account for Auto Retry. |

## 15. Placeholder Balance Tables

The following tables reserve space for future numeric balance data. All values remain unknown until approved.

### Combat Formula Placeholders

| Variable | Description | Current Value | Approval Source |
|---|---|---|---|
| RawDamage inputs | Inputs used before DEF reduction. | TBD | `docs/COMBAT.md` |
| DEFReductionFormula | Formula converting DEF to percentage reduction. | TBD | `docs/COMBAT.md` |
| MinimumDamage | Minimum final damage rule. | TBD | `docs/COMBAT.md` |
| DamageRounding | Rounding behavior for final damage. | TBD | `docs/COMBAT.md` |

### Progression Placeholders

| Variable | Description | Current Value | Approval Source |
|---|---|---|---|
| LevelCurve | Creature or player level curve. | TBD | `docs/PROGRESSION.md` |
| XPReward | XP awarded by approved sources. | TBD | `docs/PROGRESSION.md` |
| UnlockThreshold | Requirement for progression unlocks. | TBD | `docs/PROGRESSION.md` |
| MVPEndpoint | Final MVP progression target. | TBD | `docs/ROADMAP.md` |

### Economy Placeholders

| Variable | Description | Current Value | Approval Source |
|---|---|---|---|
| CurrencyList | Approved currencies or resources. | TBD | `docs/ECONOMY.md` |
| RewardAmount | Amount granted by sources. | TBD | `docs/ECONOMY.md` |
| CostAmount | Amount required by sinks. | TBD | `docs/ECONOMY.md` |
| EconomyCap | Optional cap for balances. | TBD | `docs/ECONOMY.md` |

### Encounter Placeholders

| Variable | Description | Current Value | Approval Source |
|---|---|---|---|
| StoryRecommendedPower | Recommended Power for Story Mode. | TBD | `docs/COMBAT.md` |
| BossRecommendedPower | Recommended Power for bosses. | TBD | `docs/COMBAT.md` |
| ChallengeRecommendedPower | Recommended Power for challenges. | TBD | `docs/COMBAT.md` |
| WorldDifficultyStep | Difficulty increase between worlds. | TBD | `docs/PROGRESSION.md` |

## 16. Balance Review Checklist

Before any balance values are approved, reviewers must confirm:

1. The value is documented in an approved data source.
2. The value is not hardcoded in gameplay logic.
3. The value supports MVP scope.
4. The value does not introduce feature creep.
5. The value preserves server authority.
6. The value has a clear affected system.
7. The value has a clear reason to exist.
8. The value does not contradict the decision log.
9. The value has a known rollback or adjustment path.
10. The value has been tested or has a documented verification plan.

## 17. Open Questions

1. What is the exact MVP level curve?
2. What are the exact combat formulas?
3. What are the exact economy currencies?
4. What are the exact reward sources and sinks?
5. What is the exact power formula?
6. How is Recommended Power calculated?
7. How does evolution reset level numerically?
8. What state is preserved across evolution?
9. Is prestige enabled in MVP?
10. Are collection bonuses approved?
11. What is the acceptable repeat count for core progression?
12. What is the target battle duration range?
13. What is the target boss difficulty profile?
14. What is the final MVP endpoint?
