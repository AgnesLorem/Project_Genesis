# Combat System

## Purpose

This document defines the combat principles, formulas, automation rules, and boundaries for Project Genesis.

## Status

- Status: Active Draft (MVP-006)
- Owner: Antigravity (Gemini 3.1 Pro)
- Last Updated: 2026-06-29
- Review Cadence: Before any combat system change

## Table of Contents

- [Combat Goals](#combat-goals)
- [Combat Flow](#combat-flow)
- [Action Gauge & Turn Order](#action-gauge--turn-order)
- [Damage & Defense](#damage--defense)
- [Skills & Cooldowns](#skills--cooldowns)
- [Battle Modes](#battle-modes)
- [Post-Battle](#post-battle)
- [Open Questions](#open-questions)

## Combat Goals

1. **Server Authority**: The server completely owns battle states, logic, and results. Client never computes damage or results.
2. **Auto Battle**: Combat is entirely automatic. Players do not provide input during battle.
3. **Instant Simulation**: The server calculates the entire battle timeline instantly and returns it. The client plays back this timeline.
4. **No Mana/Stamina**: Skill usage is governed strictly by cooldowns.
5. **No PvP**: Only PvE combat (e.g., Story 1v1) is supported in MVP.
6. **No Undocumented Status Effects**: Simple damage and healing only unless explicitly approved.

## Combat Flow

1. **Initialization**: Server builds a completely isolated `BattleSession`.
2. **Deep Copy**: Persistent creature stats (HP, ATK, DEF, SPD, skills) are deep-copied into the session.
3. **Simulation**: Server runs the turn loop (Action Gauge fills -> Actions trigger) instantly.
4. **Completion**: Simulation ends when one side reaches 0 HP, or when the `maxTurnSafeguard` is hit (preventing infinite loops).
5. **Resolution**: Server returns `{ isVictory, timeline, summary }`.
6. **Persistence**: Current MVP combat returns the battle result only. Any approved persistence updates happen *after* resolution, and the `BattleSession` is destroyed.

## Action Gauge & Turn Order

Combat uses a Speed (SPD) based Action Time Bar (ATB).

- **Threshold**: Units act when their gauge reaches `actionGaugeThreshold` (default 1000).
- **Fill Rate**: Each tick, gauge increases by `SPD * gaugeFillCoefficient`.
- **Tie-Breaking**: If multiple units reach the threshold simultaneously, ties are broken deterministically:
  1. Highest Gauge
  2. Highest SPD
  3. Player Team > Enemy Team
  4. Internal ID

## Damage & Defense

Formulas are maintained in `CombatFormulas` logic modules, while constants are provided by configuration (`combat_config`).

- **Base Damage**: `ATK * SkillMultiplier`
- **Defense Reduction**: `DEF / (DEF + defReductionConstant)`
- **Final Damage**: `floor(BaseDamage * (1 - DefenseReduction))`
- **Minimum Damage Clamp**: If a skill has a positive multiplier (raw damage > 0), the final damage is clamped to a minimum of 1. Zero multiplier or non-damage effects are not forced to deal 1 damage.

## Skills & Cooldowns

- **Basic Attack**: The default fallback skill (`basic_attack_config`). 0 cooldown, 1.0x multiplier.
- **Cooldowns**: Tracked per unit. Reduced by 1 every time the unit takes a turn.
- **Targeting (MVP)**: `first_living_enemy` (Front-to-back targeting).
- **Selection**: The AI uses the highest-priority skill that is off cooldown. If none are available, it falls back to a basic attack.

## Battle Modes

- **Mode IDs**: Approved MVP identifiers are `story`, `boss`, and `challenge`.
- **Routing**: `GameModeService` is the only game mode orchestrator. It validates approved mode IDs and routes to `CombatService`; it does not own combat flow.
- **Story**: Server-authoritative 1v1 battle setup routed to the existing Story combat API.
- **Boss**: Server-authoritative 3v3 setup from enabled Boss Config routed to the Boss combat API.
- **Challenge**: Server-authoritative 3v3 setup from enabled Boss Config with `battleMode = challenge`, routed to the Challenge combat API.
- **Auto Retry**: Auto Retry calls the same server route with the same request shape. It must not bypass validation or introduce a separate combat branch.
- **Recommended Power**: Display guidance only. It must not block battle entry.
- **Boss Phases**: `phaseIds` are schema-validated only. Runtime phase switching and phase display remain blocked by `KI-COMBAT-004`.
- **Rewards**: Boss/challenge battle APIs return the battle result only. Reward mapping and distribution are not implemented until reward sources are approved in documentation.

## Post-Battle

- **Full Heal**: All player creatures are fully restored to their maximum HP immediately after battle resolution. No persistent injuries are tracked.

## Open Questions

1. Reward distribution mapping (handled in MVP-007 Progression System).
2. Advanced AI targeting rules for future boss phases.
