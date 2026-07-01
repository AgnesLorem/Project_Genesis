# Data Schema

## Purpose

This document defines the canonical data structure for Project Genesis.

Project Genesis is data-driven. Gameplay systems, combat tuning, creature identity, progression state, collection state, economy state, and save data must be represented through documented data structures rather than hardcoded behavior.

This document defines schema shapes only. It does not approve final content, balance values, formulas, quest mechanics, tower mechanics, status effect behavior, or implementation code.

## Status

- Status: Active Draft
- Scope: MVP data structure and reserved future-compatible schema surfaces
- Owner: Project Leadership
- Last Updated: TBD
- Review Cadence: Before implementation of any system that reads, writes, saves, migrates, or replicates data
- Authority Level: Primary data structure source of truth

## Table of Contents

- [1. Schema Principles](#1-schema-principles)
- [2. Type Conventions](#2-type-conventions)
- [3. Schema Approval Notes](#3-schema-approval-notes)
- [4. Creature Schema](#4-creature-schema)
- [5. Skill Schema](#5-skill-schema)
- [6. Gene Schema](#6-gene-schema)
- [7. Evolution Schema](#7-evolution-schema)
- [8. Boss Schema](#8-boss-schema)
- [9. World Schema](#9-world-schema)
- [10. Quest Schema](#10-quest-schema)
- [11. Collection Schema](#11-collection-schema)
- [12. Player Save Schema](#12-player-save-schema)
- [13. Inventory Schema](#13-inventory-schema)
- [14. Prestige Schema](#14-prestige-schema)
- [15. Economy Schema](#15-economy-schema)
- [16. Status Effect Schema](#16-status-effect-schema)
- [17. Tower Schema](#17-tower-schema)
- [18. Validation Requirements](#18-validation-requirements)
- [19. Versioning Requirements](#19-versioning-requirements)
- [20. Open Questions](#20-open-questions)

## 1. Schema Principles

1. Data must be the source of gameplay configuration.
2. Code must read approved data instead of embedding gameplay values.
3. Static definitions must be separate from player save state.
4. Runtime combat state must be separate from persisted save state unless explicitly documented.
5. IDs must be stable and must not depend on display names.
6. Display names may change without breaking saves.
7. All server-authoritative values must be validated on the server.
8. Client-visible data must not become client-authoritative data.
9. Unknown or future fields must not be silently trusted.
10. Every schema change that affects persistence must include a migration plan in `docs/SAVE_SYSTEM.md`.

## 2. Type Conventions

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| ID | String | Stable machine-readable identifier. | `creature_001` | May be namespaced by content pack if future content requires it. |
| DisplayText | String | Player-facing text. | `Starter Creature` | May support localization keys later. |
| Integer | Number | Whole-number value. | `1` | May define min and max bounds per field. |
| Number | Number | Numeric value that may support decimals. | `1.25` | May define precision rules per field. |
| Boolean | Boolean | True or false value. | `true` | No extension expected. |
| Enum | String | Value selected from an approved list. | `story` | Enum lists must be documented before implementation. |
| Array | List | Ordered list of values or objects. | `[skill_basic]` | May gain max length or sort rules. |
| Map | Key-Value Object | Object keyed by stable IDs. | `creature_001 -> owned` | May support sparse save formats. |
| Object | Structured Object | Nested group of named fields. | `stats` | Nested schemas must remain documented. |
| Timestamp | Number or String | Server-owned time value. | `TBD_SERVER_TIME` | Exact representation must be defined by save architecture. |
| Version | Integer | Schema or content version. | `1` | Required for migrations. |

All examples in this document are illustrative data-shape examples only. They do not approve final IDs, values, content, balance, or gameplay behavior.

## 3. Schema Approval Notes

Some requested schemas represent systems that are not yet approved for MVP implementation in `docs/GDD_MASTER.md` or `docs/COMBAT.md`.

The existence of a schema section means the project has reserved a data structure surface. It does not mean the feature is approved for implementation.

Status by schema:

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| Creature | Schema Status | MVP foundation schema. | `Approved data surface` | May expand with additional creature content. |
| Skill | Schema Status | MVP combat support schema. | `Approved data surface` | May expand if deeper combat is approved. |
| Gene | Schema Status | MVP foundation schema; exact behavior TBD. | `Approved data surface` | May expand if gene rules are approved. |
| Evolution | Schema Status | MVP foundation schema; exact requirements TBD. | `Approved data surface` | May expand if evolution rules are approved. |
| Boss | Schema Status | MVP combat schema for boss/challenge data. | `Approved data surface` | May expand with future boss mechanics. |
| World | Schema Status | MVP world progression schema. | `Approved data surface` | May expand with additional worlds. |
| Quest | Schema Status | Reserved schema; not an MVP system unless approved separately. | `Reserved only` | May support future task or objective systems. |
| Collection | Schema Status | MVP foundation schema. | `Approved data surface` | May expand with collection rewards if approved. |
| Player Save | Schema Status | Required persistence schema. | `Approved data surface` | Must version all changes. |
| Inventory | Schema Status | Required only for approved item/resource storage. | `Conditional data surface` | May expand if item systems are approved. |
| Prestige | Schema Status | MVP foundation or reserved schema depending on progression approval. | `Conditional data surface` | May expand with prestige rules. |
| Economy | Schema Status | MVP foundation schema. | `Approved data surface` | May expand only with approved economy design. |
| Status Effect | Schema Status | Reserved schema; not MVP-approved combat behavior. | `Reserved only` | May support future combat depth. |
| Tower | Schema Status | Reserved schema; not an MVP system unless approved separately. | `Reserved only` | May support future progression content. |

## 4. Creature Schema

Defines static creature identity and baseline data.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| creatureId | ID | Stable identifier for the creature definition. | `creature_001` | May be namespaced by world or content pack. |
| schemaVersion | Version | Version of this creature definition shape. | `1` | Used for migrations and content validation. |
| displayName | DisplayText | Player-facing creature name. | `Starter Creature` | May become a localization key. |
| description | DisplayText | Player-facing creature description. | `Intro creature description` | May support lore or collection text later. |
| baseStats | Object | Baseline combat stats used by approved formulas. | `hp, atk, def, spd` | May add approved stats only after combat documentation changes. |
| skillIds | Array<ID> | Skills available to this creature by definition or loadout rule. | `[skill_basic]` | May support unlockable or slot-based rules later. |
| geneSlots | Array<ID> | Gene slots or allowed gene references if gene rules use slots. | `[gene_slot_1]` | May support more complex gene structures if approved. |
| evolutionLineId | ID | Identifier linking the creature to an evolution structure. | `evolution_line_001` | May support alternate lines only if approved. |
| collectionCategory | Enum | Category used by collection tracking. | `creature` | May support future collection groupings. |
| visualRef | ID | Reference to visual asset or art definition. | `visual_creature_001` | May link to variants or skins if approved. |
| sortOrder | Integer | Stable ordering for UI lists. | `1` | May support category-specific ordering. |
| isEnabled | Boolean | Whether this definition is active in current content. | `true` | May support content rollout flags. |

## 5. Skill Schema

Defines static skill data used by combat.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| skillId | ID | Stable identifier for the skill definition. | `skill_basic` | May be namespaced by creature or content pack. |
| schemaVersion | Version | Version of this skill definition shape. | `1` | Used for validation when formulas change. |
| displayName | DisplayText | Player-facing skill name. | `Basic Strike` | May become a localization key. |
| description | DisplayText | Player-facing description of the skill. | `Deals simple damage` | May include generated text from formula data later. |
| cooldownValue | Number | Cooldown amount used by the approved cooldown rule. | `TBD_NUMBER` | May support mode-specific cooldowns if approved. |
| cooldownUnit | Enum | Unit used to interpret cooldown. | `TBD_UNIT` | Must align with `docs/COMBAT.md` once resolved. |
| targetRule | Enum | Server-used target selection category. | `TBD_TARGET_RULE` | May expand only with approved targeting rules. |
| effectRefs | Array<ID> | References to approved effect data applied by this skill. | `[effect_damage_basic]` | May include future status effects only if approved. |
| priority | Integer | Optional auto-battle selection ordering. | `1` | May support conditional priorities later. |
| tags | Array<Enum> | Data tags for filtering or validation. | `[damage]` | May support UI or AI rules later. |
| isEnabled | Boolean | Whether this skill is available in current content. | `true` | May support staged content rollout. |

## 6. Gene Schema

Defines gene data shape. Exact gene behavior remains TBD.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| geneId | ID | Stable identifier for the gene definition. | `gene_001` | May be namespaced by gene family. |
| schemaVersion | Version | Version of this gene definition shape. | `1` | Required if gene behavior changes. |
| displayName | DisplayText | Player-facing gene name if visible. | `Gene Alpha` | May become hidden or localized depending on design. |
| description | DisplayText | Player-facing or internal description. | `Gene description TBD` | May support generated descriptions. |
| geneCategory | Enum | High-level grouping for validation. | `TBD_CATEGORY` | May support approved gene classes later. |
| valueType | Enum | Type of value stored by the gene. | `number` | May support boolean, enum, or structured values. |
| defaultValue | Any | Default value when a gene exists without a rolled value. | `TBD_VALUE` | May be replaced by roll tables if approved. |
| allowedValues | Array | Optional whitelist or range descriptor. | `[TBD]` | May support constraints, ranges, or weighted pools. |
| visibility | Enum | Whether players can see this gene. | `TBD_VISIBILITY` | May support hidden, partial, or revealed states. |
| effectRefs | Array<ID> | References to effects if genes affect systems. | `[]` | May link to combat or progression effects only if approved. |
| isEnabled | Boolean | Whether this gene definition is active. | `false` | May become true only after gene rules are approved. |

## 7. Evolution Schema

Defines creature evolution data shape. Exact evolution requirements remain TBD.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| evolutionId | ID | Stable identifier for an evolution definition. | `evolution_001` | May be namespaced by creature line. |
| schemaVersion | Version | Version of this evolution definition shape. | `1` | Required for migration of evolution data. |
| evolutionLineId | ID | Identifier for the related evolution line. | `evolution_line_001` | May support alternate lines only if approved. |
| fromCreatureId | ID | Creature definition before evolution. | `creature_001` | May support multiple sources only if approved. |
| toCreatureId | ID | Creature definition after evolution. | `creature_002` | May support branching only if approved. |
| requirementRefs | Array<ID> | References to approved requirement definitions. | `[requirement_level_tbd]` | May support cost or milestone requirements later. |
| costRefs | Array<ID> | References to approved economy costs, if any. | `[]` | May remain empty if no cost is approved. |
| resultRules | Object | Data describing what changes after evolution. | `TBD_RESULT_RULES` | Must be expanded before implementation. |
| displayRef | ID | UI or presentation reference for evolution. | `evolution_display_001` | May link to animations if approved. |
| isEnabled | Boolean | Whether this evolution definition is active. | `false` | Must be enabled only after requirements are approved. |

## 8. Boss Schema

Defines boss and challenge encounter data shape.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| id | ID | Config record identifier. Must match `bossId`. | `boss_001` | Kept for generic config registry compatibility. |
| bossId | ID | Stable identifier for the boss encounter. | `boss_001` | May be namespaced by world or mode. |
| schemaVersion | Version | Version of this boss definition shape. | `1` | Required if phase schema changes. |
| displayName | DisplayText | Player-facing boss name. | `Boss Encounter` | May become a localization key. |
| battleMode | Enum | Encounter category for validation. Allowed values: `boss`, `challenge`. | `boss` | May expand only after game mode docs approve it. |
| teamSize | Integer | Expected player-side and enemy-side team size. | `3` | Must remain aligned with combat rules. |
| recommendedPower | Number | Guidance value only; not an entry gate. | `TBD_NUMBER` | May be derived by formula later. |
| phaseIds | Array<ID> | Ordered list of boss phase definitions. | `[boss_phase_001]` | May support multiple phases. |
| enemyRefs | Array<ID> | Enemy definitions used by the encounter. | `[enemy_001]` | May support phase-specific enemies later. |
| rewardRefs | Array<ID> | Approved reward references. | `[reward_tbd]` | Must align with economy and progression docs. |
| retryPolicyRef | ID | Auto Retry behavior reference. | `retry_policy_default` | May vary by mode if approved. |
| isEnabled | Boolean | Whether this boss encounter is active. | `true` | May support content rollout flags. |

## 9. World Schema

Defines world progression data shape.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| id | ID | Config record identifier. Must match `worldId`. | `world_001` | Kept for generic config registry compatibility. |
| worldId | ID | Stable identifier for world content. | `world_001` | May be namespaced by content pack. |
| schemaVersion | Version | Version of this world definition shape. | `1` | Required if unlock rules change. |
| displayName | DisplayText | Player-facing world name. | `World 1` | May become a localization key. |
| description | DisplayText | Player-facing world description. | `Intro world description` | May support story text later. |
| unlockRequirementRefs | Array<ID> | References to approved unlock requirements. | `[requirement_world_tbd]` | May support multiple requirements if approved. |
| encounterRefs | Array<ID> | Encounters available in this world. | `[encounter_001]` | May include story, boss, or challenge references. |
| bossRefs | Array<ID> | Bosses associated with this world. | `[boss_001]` | May support world-end or optional bosses. |
| recommendedPowerRange | Object | Display guidance for expected power range. | `min TBD, max TBD` | May be computed later. |
| sortOrder | Integer | Stable order for world progression UI. | `1` | May support branching maps if approved. |
| isEnabled | Boolean | Whether this world is active. | `true` | May support content rollout flags. |

## 10. Quest Schema

Reserved data shape for future or approved objective systems. This schema does not approve daily quests or any quest feature for MVP.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| questId | ID | Stable identifier for quest or objective data. | `quest_001` | May be namespaced by world or event if approved. |
| schemaVersion | Version | Version of this quest definition shape. | `1` | Required if objective format changes. |
| displayName | DisplayText | Player-facing quest name. | `Objective 1` | May become a localization key. |
| description | DisplayText | Player-facing objective description. | `Objective description TBD` | May support generated progress text. |
| questType | Enum | Approved category of quest or objective. | `TBD_TYPE` | Must be documented before implementation. |
| objectiveRefs | Array<ID> | References to objective definitions. | `[objective_tbd]` | May support multiple objectives if approved. |
| unlockRequirementRefs | Array<ID> | Requirements before the quest is visible or active. | `[]` | May connect to world progression later. |
| rewardRefs | Array<ID> | Reward references if rewards are approved. | `[]` | Must align with economy and progression docs. |
| repeatRule | Enum | Whether the quest can repeat. | `none` | Daily or timed repeats are out of scope unless approved. |
| isEnabled | Boolean | Whether this quest definition is active. | `false` | Must remain false until quest rules are approved. |

## 11. Collection Schema

Defines collection tracking and collection display data shape.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| collectionId | ID | Stable identifier for a collection definition. | `collection_creatures` | May support multiple collection books. |
| schemaVersion | Version | Version of this collection definition shape. | `1` | Required if collection rules change. |
| displayName | DisplayText | Player-facing collection name. | `Creature Collection` | May become a localization key. |
| description | DisplayText | Player-facing collection description. | `Track discovered creatures` | May support category descriptions later. |
| trackedEntityType | Enum | Type of entity tracked by the collection. | `creature` | May support genes or worlds if approved. |
| trackedIds | Array<ID> | IDs included in this collection. | `[creature_001]` | May support dynamic filters later. |
| completionRule | Enum | Rule for determining collection completion. | `all_tracked` | Rewards require separate approval. |
| visibilityRule | Enum | Rule for showing hidden or undiscovered entries. | `TBD_VISIBILITY` | May support silhouette or reveal states. |
| sortOrder | Integer | Stable UI ordering. | `1` | May support player sorting later. |
| isEnabled | Boolean | Whether this collection is active. | `true` | May support staged content rollout. |

## 12. Player Save Schema

Defines persisted player state. Exact save mechanics must align with `docs/SAVE_SYSTEM.md`.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| saveVersion | Version | Version of the persisted save format. | `1` | Required for migrations. |
| playerId | ID | Stable Roblox player identifier owned by the server. | `roblox_user_id` | May support platform metadata separately. |
| createdAt | Timestamp | Server-owned save creation time. | `TBD_SERVER_TIME` | Exact timestamp format TBD. |
| updatedAt | Timestamp | Server-owned last successful save time. | `TBD_SERVER_TIME` | May support audit or recovery metadata. |
| selectedCreatureId | ID | Player's currently selected creature instance. | `player_creature_001` | May support multiple loadouts later. |
| creatureInstances | Map<ID,Object> | Player-owned creature instance save data. | `player_creature_001 -> data` | May support archival or storage rules. |
| inventory | Object | Persisted inventory state. | `Inventory schema` | Must align with Inventory Schema. |
| collectionState | Object | Persisted collection progress. | `Collection save object` | May support multiple collections. |
| progressionState | Object | Persisted progression state. | `world and milestone data` | Must align with progression docs. |
| economyState | Object | Persisted currency and economy state. | `Economy save object` | Must align with Economy Schema. |
| prestigeState | Object | Persisted prestige state if enabled. | `Prestige save object` | May remain empty until prestige is approved. |
| settings | Object | Player preference data that is safe to persist. | `autoRetry preference` | Must not store authoritative gameplay outcomes. |

## 13. Inventory Schema

Defines inventory save and item stack structure. Inventory is only for approved resources or items.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| inventoryId | ID | Stable identifier for an inventory container. | `main_inventory` | May support separate storage if approved. |
| schemaVersion | Version | Version of this inventory structure. | `1` | Required if stack rules change. |
| slots | Map<ID,Object> | Stored item or resource entries keyed by stable ID. | `item_001 -> stack data` | May support slot-based inventory later. |
| itemId | ID | Stable identifier for an item or resource entry. | `resource_001` | Must be approved in economy or item docs. |
| quantity | Integer | Server-owned amount of the item or resource. | `TBD_QUANTITY` | May support caps or stack limits. |
| acquiredAt | Timestamp | Server-owned acquisition time if needed. | `TBD_SERVER_TIME` | May support sorting or audits. |
| sourceRef | ID | Optional reference to acquisition source. | `reward_001` | May support fraud review or analytics later. |
| isLocked | Boolean | Whether an entry is protected from removal if such rules exist. | `false` | Locking rules require approval. |

## 14. Prestige Schema

Defines prestige data shape. Prestige behavior must be approved in progression and economy documents before implementation.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| prestigeId | ID | Stable identifier for prestige definition or state. | `prestige_default` | May support multiple prestige tracks if approved. |
| schemaVersion | Version | Version of this prestige structure. | `1` | Required if reset or preserve rules change. |
| prestigeLevel | Integer | Server-owned prestige level or count. | `0` | Exact max and meaning TBD. |
| requirementRefs | Array<ID> | Requirements needed to prestige. | `[requirement_prestige_tbd]` | Must be approved before use. |
| resetRuleRefs | Array<ID> | Data references describing what resets. | `[reset_rule_tbd]` | Must be explicit before implementation. |
| preserveRuleRefs | Array<ID> | Data references describing what persists. | `[preserve_rule_tbd]` | Must be explicit before implementation. |
| rewardRefs | Array<ID> | Rewards or recognition from prestige if approved. | `[]` | Prestige multipliers are not approved unless documented. |
| lastPrestigedAt | Timestamp | Server-owned time of last prestige action. | `TBD_SERVER_TIME` | May support history or audits. |
| isEnabled | Boolean | Whether prestige is active. | `false` | Must be enabled only after rules are approved. |

## 15. Economy Schema

Defines currency, resource, cost, and reward data shape.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| economyId | ID | Stable identifier for economy definition. | `economy_mvp` | May support mode-specific economies if approved. |
| schemaVersion | Version | Version of this economy definition shape. | `1` | Required if currency or reward rules change. |
| currencyId | ID | Stable identifier for an approved currency or resource. | `currency_001` | Currency names require economy approval. |
| displayName | DisplayText | Player-facing currency or resource name. | `Currency 1` | May become a localization key. |
| currencyType | Enum | Category of currency or resource. | `soft` | Premium currency is not approved for MVP. |
| balance | Number | Server-owned amount in player save state. | `TBD_AMOUNT` | May support integer-only constraints. |
| sourceRefs | Array<ID> | Approved sources that can grant this currency. | `[reward_source_combat]` | Must align with progression and combat docs. |
| sinkRefs | Array<ID> | Approved places this currency can be spent. | `[sink_tbd]` | Must be approved before use. |
| cap | Number | Optional maximum balance. | `TBD_CAP` | May remain undefined if no cap is approved. |
| auditCategory | Enum | Category used for server validation or review. | `progression_reward` | May support future audit tools. |

## 16. Status Effect Schema

Reserved data shape for future combat effects. Status effects are not approved for MVP combat unless later documented in `docs/COMBAT.md`.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| statusEffectId | ID | Stable identifier for a status effect definition. | `status_effect_001` | May be namespaced by combat system. |
| schemaVersion | Version | Version of this status effect structure. | `1` | Required if effect timing changes. |
| displayName | DisplayText | Player-facing status effect name. | `Effect 1` | May become a localization key. |
| description | DisplayText | Player-facing or internal description. | `Effect description TBD` | May support generated descriptions. |
| effectCategory | Enum | Category of effect. | `TBD_CATEGORY` | Must be approved before implementation. |
| durationType | Enum | How duration would be interpreted if approved. | `TBD_DURATION` | Must align with combat timing rules. |
| durationValue | Number | Duration amount if approved. | `TBD_NUMBER` | May support stack or refresh rules later. |
| modifierRefs | Array<ID> | References to approved modifiers. | `[]` | No modifiers are approved until documented. |
| stackRule | Enum | How stacking would work if approved. | `none` | Stacking is not approved unless documented. |
| isEnabled | Boolean | Whether this status effect is active. | `false` | Must remain false until combat rules approve it. |

## 17. Tower Schema

Reserved data shape for future tower-style progression content. Tower is not approved for MVP unless added to scope through the GDD and roadmap.

| Name | Type | Description | Example | Future Extension |
|---|---|---|---|---|
| towerId | ID | Stable identifier for tower content. | `tower_001` | May be namespaced by world or season if approved. |
| schemaVersion | Version | Version of this tower definition shape. | `1` | Required if floor structure changes. |
| displayName | DisplayText | Player-facing tower name. | `Tower 1` | May become a localization key. |
| description | DisplayText | Player-facing tower description. | `Tower description TBD` | May support story or challenge text. |
| floorRefs | Array<ID> | Ordered floor or encounter references. | `[tower_floor_001]` | May support generated or branching floors if approved. |
| unlockRequirementRefs | Array<ID> | Requirements before tower access. | `[requirement_tower_tbd]` | Must not become a power gate unless approved. |
| rewardRefs | Array<ID> | Rewards associated with tower progress. | `[]` | Must align with economy and progression docs. |
| resetRule | Enum | Whether tower progress resets. | `none` | Timed resets are not approved unless documented. |
| recommendedPowerRange | Object | Guidance values for tower difficulty. | `min TBD, max TBD` | Guidance only unless gating is approved. |
| isEnabled | Boolean | Whether this tower is active. | `false` | Must remain false until tower content is approved. |

## 18. Validation Requirements

All systems that consume these schemas must validate:

1. Required fields exist.
2. Field types match this document.
3. IDs reference existing approved definitions.
4. Disabled definitions are not used in active content unless explicitly allowed.
5. Client-submitted IDs are permitted for the requesting player and context.
6. Server-owned values are never accepted from the client as authority.
7. Economy and reward changes are generated by server-approved sources.
8. Save data is compatible with the current `saveVersion`.
9. Unknown fields are handled according to the migration policy.
10. Reserved schemas remain disabled until approved by GDD, roadmap, and task documentation.

## 19. Versioning Requirements

Every persisted schema must support versioning.

Versioning rules:

1. Static definitions use `schemaVersion`.
2. Player save data uses `saveVersion`.
3. Breaking changes require migration notes in `docs/SAVE_SYSTEM.md`.
4. Non-breaking additions must define defaults.
5. Removed fields must define how old saves are handled.
6. Renamed fields must be treated as migrations.
7. ID changes are high risk and require explicit review.
8. Content disabling must not corrupt existing saves.

## 20. Open Questions

The following schema details remain unresolved:

1. Exact creature stat list beyond currently referenced combat stats.
2. Exact combat formula constants.
3. Exact skill targeting enums.
4. Exact cooldown unit.
5. Exact gene behavior.
6. Exact evolution requirements and results.
7. Exact collection visibility rules.
8. Exact player save timestamp format.
9. Exact economy currency list.
10. Whether quests become MVP objectives or remain future-only.
11. Whether status effects remain future-only.
12. Whether tower content remains future-only.
13. Inventory limits, stack rules, and approved item categories.
14. Prestige enablement and reset or preserve rules.
