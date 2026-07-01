# Project Genesis Configuration Structure

## Purpose

This document defines the complete configuration hierarchy for Project Genesis.

Project Genesis is fully data-driven. Gameplay systems must read approved configuration data instead of hiding gameplay values inside implementation.

This document explains how configuration categories relate to one another, which systems own each category, how dependencies should flow, and how configuration updates must be reviewed.

This is a technical documentation document only.

It does not define implementation code.

## Status

- Document Status: Active
- Scope: MVP configuration hierarchy
- Project Type: Roblox
- Architecture: Data-driven, server-authoritative
- Owner: Data Architecture
- Last Updated: 2026-06-28

## Table of Contents

- [Purpose](#purpose)
- [Status](#status)
- [Configuration Structure Philosophy](#configuration-structure-philosophy)
- [Configuration Hierarchy Overview](#configuration-hierarchy-overview)
- [Configuration Layers](#configuration-layers)
- [Recommended Folder Hierarchy](#recommended-folder-hierarchy)
- [Relationship Map](#relationship-map)
- [Dependency Rules](#dependency-rules)
- [Ownership Model](#ownership-model)
- [Creature Config](#creature-config)
- [Skill Config](#skill-config)
- [World Config](#world-config)
- [Boss Config](#boss-config)
- [Quest Config](#quest-config)
- [Tower Config](#tower-config)
- [Status Effect Config](#status-effect-config)
- [Economy Config](#economy-config)
- [Balance Config](#balance-config)
- [Drop Table Config](#drop-table-config)
- [Localization](#localization)
- [Cross-Config Dependencies](#cross-config-dependencies)
- [Update Process](#update-process)
- [Validation Gates](#validation-gates)
- [Review Checklist](#review-checklist)
- [Professional Conclusion](#professional-conclusion)

## Configuration Structure Philosophy

Configuration structure must make the game easy to expand, review, validate, balance, and protect from feature creep.

The configuration hierarchy exists to ensure that:

- Gameplay values are visible.
- Data ownership is clear.
- References are stable.
- Dependencies are intentional.
- Reviewers can inspect content without reading implementation.
- AI assistants can modify scoped data without inventing systems.
- Server-authoritative systems can validate all config before use.
- Reserved schemas do not become active gameplay without approval.

Configuration should describe approved content and approved tuning.

Implementation should load, validate, and apply configuration according to documented rules.

Configuration must never be used to secretly approve undocumented mechanics.

## Configuration Hierarchy Overview

Project Genesis configuration is organized by domain and dependency level.

Some configuration categories are active MVP data surfaces. Other categories are reserved schema surfaces and must remain inactive unless separately approved through the design process.

### Active Or Conditional MVP Data Surfaces

| Config Category | Current Status | Primary Purpose |
|---|---|---|
| Creature Config | Active MVP foundation | Defines creature identity, references, baseline data, and collection links |
| Skill Config | Active MVP combat support | Defines skill identity, cooldown references, and combat value references |
| World Config | Active MVP foundation | Defines world progression ordering and world content references |
| Boss Config | Active MVP combat support | Defines boss identity, combat references, phase references, and rewards |
| Economy Config | Active MVP foundation | Defines currencies, reward sources, costs, and sinks |
| Balance Config | Active MVP foundation | Defines shared tuning variables and scaling references |
| Drop Table Config | Conditional MVP surface | Defines reward pools only for approved reward flows |
| Localization | Support surface | Defines player-facing text references when localization is externalized |

### Reserved Schema Surfaces

| Config Category | Current Status | Requirement Before Active Use |
|---|---|---|
| Quest Config | Reserved schema | Explicit approval in GDD, decision log, roadmap, and task scope |
| Tower Config | Reserved schema | Explicit approval in GDD, decision log, roadmap, and task scope |
| Status Effect Config | Reserved schema | Explicit approval in combat documentation and decision log |

Reserved schema surfaces may be documented for structure, validation, and dependency planning.

They must not be implemented as active gameplay unless approved.

## Configuration Layers

Configuration should flow from foundational shared data toward higher-level content definitions.

Higher layers may reference lower layers.

Lower layers should not depend on higher layers.

### Layer 0: Shared References

Layer 0 contains references used across multiple config categories.

Examples:

- Stable enums.
- Shared tags.
- Common categories.
- Localization keys.
- Shared requirement references.
- Shared reward references.
- Shared visual or audio references.

Layer 0 must not contain gameplay behavior by itself.

### Layer 1: Balance And Economy Foundations

Layer 1 contains global tuning and economic definitions.

Examples:

- Balance variables.
- Scaling references.
- Currency definitions.
- Cost references.
- Reward source references.
- Economy sink references.

Layer 1 data is referenced by gameplay content but should not depend on specific creature, boss, tower, or quest definitions unless explicitly documented.

### Layer 2: Atomic Gameplay Definitions

Layer 2 contains individual gameplay building blocks.

Examples:

- Skill definitions.
- Gene definitions.
- Status effect definitions when approved.
- Drop table definitions.

Layer 2 objects may reference balance, economy, shared enums, and localization.

Layer 2 objects should not depend on world, boss, quest, or tower definitions unless explicitly approved.

### Layer 3: Creature Definitions

Layer 3 contains creature configuration.

Creature config may reference:

- Skills.
- Genes.
- Evolution lines.
- Collection categories.
- Balance references.
- Localization keys.
- Visual references.

Creature config should not own economy transactions, world unlocks, boss rules, quest rules, or tower rules.

### Layer 4: Encounter And Progression Definitions

Layer 4 contains world and boss configuration.

World and boss config may reference:

- Creatures.
- Skills.
- Balance values.
- Economy rewards.
- Drop tables.
- Localization keys.
- Visual references.

World config may reference boss config.

Boss config may reference skills and reward data.

### Layer 5: Reserved Progression Surfaces

Layer 5 contains reserved configuration categories that are documented but not active by default.

Examples:

- Quest config.
- Tower config.

These may reference lower-layer data only after approval.

They must not become active through config alone.

### Layer 6: Presentation References

Layer 6 contains non-authoritative presentation references.

Examples:

- Localization text.
- UI labels.
- Visual asset references.
- Audio references.

Presentation references may support gameplay display but must not control gameplay outcomes.

## Recommended Folder Hierarchy

The exact implementation folder layout must be approved by technical architecture before code is written.

This hierarchy documents the intended organization for configuration ownership and review.

```text
config/
    shared/
        enums/
        tags/
        requirements/
        rewards/
    localization/
    balance/
    economy/
    drop_tables/
    creatures/
    skills/
    genes/
    worlds/
    bosses/
    quests/
    towers/
    status_effects/
```

### Folder Purpose

| Folder | Purpose |
|---|---|
| `config/shared/` | Shared identifiers, enums, tags, requirement references, and reward references |
| `config/localization/` | Player-facing text keys and approved display text |
| `config/balance/` | Shared tuning variables and scaling references |
| `config/economy/` | Currency, costs, rewards, sources, and sinks |
| `config/drop_tables/` | Reward pools and reward selection references |
| `config/creatures/` | Creature definitions and creature-facing references |
| `config/skills/` | Skill definitions and combat-facing values |
| `config/genes/` | Gene definitions and gene-facing values |
| `config/worlds/` | World progression definitions and encounter references |
| `config/bosses/` | Boss definitions and boss-facing combat references |
| `config/quests/` | Reserved quest definitions; inactive unless approved |
| `config/towers/` | Reserved tower definitions; inactive unless approved |
| `config/status_effects/` | Reserved status effect definitions; inactive unless approved |

### Folder Rules

- Each folder must have one primary domain owner.
- Each folder must contain only its own domain data.
- Shared references must not be duplicated in domain folders.
- Reserved folders must not imply active gameplay approval.
- Config file names must follow `docs/STYLE_GUIDE.md`.
- Config categories must follow `docs/CONFIG_GUIDE.md`.
- Config schemas must follow `docs/DATA_SCHEMA.md`.

## Relationship Map

The following map describes intended config relationships.

```text
Localization
    ↑
Shared References
    ↑
Balance Config
    ↑
Economy Config
    ↑
Drop Table Config
    ↑
Skill Config
    ↑
Gene Config
    ↑
Creature Config
    ↑
Boss Config
    ↑
World Config
    ↑
Quest Config
    ↑
Tower Config
```

This vertical map is conceptual, not a strict load order.

Actual validation should use dependency-aware ordering.

### Key Relationship Rules

- Creature Config may reference Skill Config.
- Creature Config may reference Gene Config.
- Creature Config may reference Balance Config.
- Skill Config may reference Balance Config.
- Skill Config may reference Status Effect Config only if status effects are approved.
- World Config may reference Boss Config.
- World Config may reference Drop Table Config.
- Boss Config may reference Skill Config.
- Boss Config may reference Drop Table Config.
- Quest Config may reference World, Creature, Economy, and Drop Table Config only when quests are approved.
- Tower Config may reference Boss, World, Drop Table, and Balance Config only when tower content is approved.
- Drop Table Config may reference Economy Config.
- Economy Config may reference Balance Config.
- Localization may be referenced by any player-facing config.

## Dependency Rules

Dependencies must be explicit, stable, and validated.

### Required Dependency Rules

- Use stable IDs for all cross-config references.
- Do not use display names as references.
- Do not use file paths as gameplay identifiers.
- Do not create circular dependencies.
- Do not reference reserved config from active MVP config unless approved.
- Do not allow config dependencies to create hidden gameplay systems.
- Do not allow client-owned state to satisfy config requirements.
- Do not duplicate the same gameplay value across unrelated config files.
- Do not define a reward in one config and override it silently in another.
- Do not define balance values in implementation.

### Dependency Direction

Preferred dependency direction:

```text
Shared → Balance → Economy → Drop Tables → Skills / Genes → Creatures → Bosses → Worlds → Reserved Progression Surfaces
```

Reverse dependencies should be avoided.

For example:

- A skill may reference a balance value.
- A balance value should not reference a specific skill unless explicitly documented.
- A world may reference a boss.
- A boss should not own world progression rules.
- A drop table may reference economy rewards.
- Economy config should not depend on a specific drop table unless explicitly documented.

### Circular Dependency Policy

Circular dependencies are not allowed.

Examples of prohibited circular dependencies:

- Creature requires World, and World requires that same Creature for unlock validation.
- Skill requires Status Effect, and Status Effect requires that same Skill for activation.
- Drop Table requires Economy Reward, and Economy Reward requires that same Drop Table for definition.

If a circular dependency appears necessary, the structure is wrong and must return to design review.

## Ownership Model

Each config category must have a clear owner and reviewer.

Ownership does not mean one contributor can bypass review.

Ownership means one role is accountable for correctness, consistency, and documentation alignment.

### Ownership Table

| Config Category | Primary Owner | Required Reviewers | Source Documents |
|---|---|---|---|
| Creature Config | Data Agent | Gameplay Agent, Reviewer Agent | `docs/DATA_SCHEMA.md`, `docs/GDD_MASTER.md` |
| Skill Config | Gameplay Agent | Data Agent, Reviewer Agent | `docs/DATA_SCHEMA.md`, `docs/COMBAT.md` |
| World Config | Gameplay Agent | Data Agent, Reviewer Agent | `docs/DATA_SCHEMA.md`, `docs/GDD_MASTER.md` |
| Boss Config | Gameplay Agent | Data Agent, Economy Agent, Reviewer Agent | `docs/DATA_SCHEMA.md`, `docs/COMBAT.md` |
| Quest Config | Project Director | Gameplay Agent, Reviewer Agent | `docs/DATA_SCHEMA.md`, `docs/DECISIONS.md` |
| Tower Config | Project Director | Gameplay Agent, Reviewer Agent | `docs/DATA_SCHEMA.md`, `docs/DECISIONS.md` |
| Status Effect Config | Project Director | Gameplay Agent, Reviewer Agent | `docs/DATA_SCHEMA.md`, `docs/COMBAT.md` |
| Economy Config | Economy Agent | Data Agent, Reviewer Agent | `docs/DATA_SCHEMA.md`, `docs/BALANCE.md` |
| Balance Config | Economy Agent / Gameplay Agent | Project Director, Reviewer Agent | `docs/BALANCE.md`, `docs/DECISIONS.md` |
| Drop Table Config | Economy Agent | Data Agent, Gameplay Agent, Reviewer Agent | `docs/DATA_SCHEMA.md`, `docs/BALANCE.md` |
| Localization | UI Agent | Data Agent, Reviewer Agent | `docs/UI_GUIDELINES.md`, `docs/STYLE_GUIDE.md` |

### Ownership Rules

- Owners must verify schema alignment.
- Owners must verify source-of-truth alignment.
- Owners must verify dependency correctness.
- Owners must identify required reviewers.
- Owners must update relevant documentation after approved changes.
- Owners must not approve their own scope expansion.

## Creature Config

Creature Config defines creature identity and creature-facing references.

### Relationships

Creature Config may reference:

- Skill Config for approved skills.
- Gene Config for approved gene relationships.
- Balance Config for stat or progression tuning references.
- Localization for display text.
- Shared references for categories and tags.
- Collection data as documented in `docs/DATA_SCHEMA.md`.

Creature Config must not own:

- Currency transactions.
- Reward grants.
- World progression rules.
- Boss phase rules.
- Quest objectives.
- Tower floor rules.
- Client-authoritative state.

### Dependencies

| Dependency | Direction | Rule |
|---|---|---|
| Skill Config | Creature references Skill | Skill ID must exist and be active |
| Gene Config | Creature references Gene | Gene reference must match approved gene schema |
| Balance Config | Creature references Balance | Values must be reviewed for balance impact |
| Localization | Creature references Localization | Text keys must resolve if localization is used |

### Ownership

Primary owner: Data Agent.

Required reviewers: Gameplay Agent and Reviewer Agent.

### Update Process

1. Confirm the creature is approved for MVP scope.
2. Confirm required creature fields in `docs/DATA_SCHEMA.md`.
3. Confirm referenced skills, genes, balance values, and text keys exist.
4. Update creature config.
5. Validate references.
6. Review balance impact.
7. Update documentation if behavior, schema, or content pipeline changes.

## Skill Config

Skill Config defines approved skill data used by combat systems.

### Relationships

Skill Config may reference:

- Balance Config for cooldowns, damage references, and tuning values.
- Status Effect Config only if status effects are approved.
- Localization for display text.
- Shared references for categories, targeting references, and tags.

Skill Config must not own:

- Combat outcome authority.
- Reward grants.
- Creature ownership.
- Economy balances.
- Save mutation rules.
- Unapproved status behavior.

### Dependencies

| Dependency | Direction | Rule |
|---|---|---|
| Balance Config | Skill references Balance | Skill values must be data-driven |
| Status Effect Config | Skill references Status Effect | Allowed only after combat approval |
| Localization | Skill references Localization | Text keys must resolve if localization is used |
| Shared References | Skill references Shared | Categories and enums must be approved |

### Ownership

Primary owner: Gameplay Agent.

Required reviewers: Data Agent and Reviewer Agent.

### Update Process

1. Confirm the skill follows `docs/COMBAT.md`.
2. Confirm all skill fields match `docs/DATA_SCHEMA.md`.
3. Confirm cooldown and combat values come from config.
4. Confirm status effects are not referenced unless approved.
5. Validate all references.
6. Review combat and balance impact.
7. Update relevant documentation.

## World Config

World Config defines world progression data and world-level content references.

### Relationships

World Config may reference:

- Boss Config for world-associated bosses.
- Drop Table Config for approved rewards.
- Economy Config through reward references.
- Balance Config for recommended power guidance.
- Localization for display text.
- Shared references for unlock requirements and categories.

World Config must not own:

- Power gates unless explicitly approved.
- Currency balances.
- Combat formulas.
- Boss internal behavior.
- Quest systems.
- Tower systems.

### Dependencies

| Dependency | Direction | Rule |
|---|---|---|
| Boss Config | World references Boss | Boss ID must exist and be active |
| Drop Table Config | World references Drop Table | Rewards must be approved |
| Balance Config | World references Balance | Recommended power remains guidance only |
| Localization | World references Localization | Text keys must resolve if localization is used |

### Ownership

Primary owner: Gameplay Agent.

Required reviewers: Data Agent and Reviewer Agent.

### Update Process

1. Confirm world progression scope in `docs/GDD_MASTER.md`.
2. Confirm world fields in `docs/DATA_SCHEMA.md`.
3. Confirm boss, reward, balance, and localization references.
4. Validate recommended power as guidance only.
5. Review progression and reward impact.
6. Update documentation where needed.

## Boss Config

Boss Config defines boss identity, battle references, phase references, recommended power, and approved rewards.

### Relationships

Boss Config may reference:

- Skill Config for boss skill behavior.
- Balance Config for combat tuning references.
- Drop Table Config for rewards.
- Economy Config through reward references.
- Localization for display text.
- World Config only as a reference relationship, not as ownership of world progression.

Boss Config must not own:

- World unlock rules.
- Player progression state.
- Economy balances.
- Client damage.
- Client victory claims.
- Unapproved combat systems.

### Dependencies

| Dependency | Direction | Rule |
|---|---|---|
| Skill Config | Boss references Skill | Skill IDs must exist and follow combat rules |
| Balance Config | Boss references Balance | Difficulty values must be documented |
| Drop Table Config | Boss references Drop Table | Rewards must be approved |
| Localization | Boss references Localization | Text keys must resolve if localization is used |

### Ownership

Primary owner: Gameplay Agent.

Required reviewers: Data Agent, Economy Agent, and Reviewer Agent.

### Update Process

1. Confirm boss content is approved.
2. Confirm battle size follows `docs/COMBAT.md`.
3. Confirm phase rules are documented.
4. Confirm skill and reward references.
5. Validate recommended power as guidance only.
6. Review combat, economy, and balance impact.
7. Update relevant documentation.

## Quest Config

Quest Config is a reserved schema surface.

The existence of Quest Config documentation does not approve quest gameplay for MVP.

### Relationships

If approved, Quest Config may reference:

- World Config for progression context.
- Creature Config for creature-related objectives.
- Economy Config for approved rewards.
- Drop Table Config for approved reward pools.
- Balance Config for tuning references.
- Localization for display text.
- Shared references for objective categories.

Quest Config must not own:

- Daily quest behavior unless explicitly approved.
- Timed login rewards unless explicitly approved.
- Undocumented objectives.
- Hidden reward paths.
- Progression bypasses.

### Dependencies

| Dependency | Direction | Rule |
|---|---|---|
| World Config | Quest references World | Allowed only when quest scope is approved |
| Economy Config | Quest references Economy | Rewards must be approved |
| Drop Table Config | Quest references Drop Table | Reward pools must be approved |
| Localization | Quest references Localization | Text keys must resolve if localization is used |

### Ownership

Primary owner: Project Director until quest systems are approved.

Required reviewers: Gameplay Agent and Reviewer Agent.

### Update Process

1. Confirm quest scope approval in `docs/DECISIONS.md`.
2. Confirm quest scope approval in source-of-truth design documents.
3. Confirm task scope explicitly includes Quest Config.
4. Confirm quest fields in `docs/DATA_SCHEMA.md`.
5. Validate that quest data does not imply unapproved systems.
6. Review rewards, progression impact, and save impact.
7. Keep inactive entries disabled unless approved for active use.

## Tower Config

Tower Config is a reserved schema surface.

The existence of Tower Config documentation does not approve tower gameplay for MVP.

### Relationships

If approved, Tower Config may reference:

- World Config for progression context.
- Boss Config for floor or milestone encounters.
- Drop Table Config for rewards.
- Economy Config through reward references.
- Balance Config for recommended power guidance.
- Localization for display text.
- Shared references for unlock requirements.

Tower Config must not own:

- Timed resets unless explicitly approved.
- Power gates unless explicitly approved.
- Undocumented floor rules.
- Hidden reward paths.
- Progression bypasses.

### Dependencies

| Dependency | Direction | Rule |
|---|---|---|
| World Config | Tower references World | Allowed only when tower scope is approved |
| Boss Config | Tower references Boss | Boss references must be valid |
| Drop Table Config | Tower references Drop Table | Reward pools must be approved |
| Balance Config | Tower references Balance | Recommended power remains guidance only unless approved otherwise |

### Ownership

Primary owner: Project Director until tower systems are approved.

Required reviewers: Gameplay Agent and Reviewer Agent.

### Update Process

1. Confirm tower scope approval in `docs/DECISIONS.md`.
2. Confirm tower scope approval in source-of-truth design documents.
3. Confirm task scope explicitly includes Tower Config.
4. Confirm tower fields in `docs/DATA_SCHEMA.md`.
5. Validate that tower data does not imply unapproved systems.
6. Review reward, progression, combat, and save impact.
7. Keep inactive entries disabled unless approved for active use.

## Status Effect Config

Status Effect Config is a reserved schema surface.

The existence of Status Effect Config documentation does not approve status effect gameplay for MVP combat.

### Relationships

If approved, Status Effect Config may reference:

- Skill Config as a source of application.
- Balance Config for duration and effect tuning.
- Localization for display text.
- Shared references for effect categories.

Status Effect Config must not own:

- Skill activation rules.
- Combat turn rules.
- Damage formulas.
- Stacking behavior unless explicitly documented.
- Refresh behavior unless explicitly documented.
- Boss-specific exceptions unless explicitly documented.

### Dependencies

| Dependency | Direction | Rule |
|---|---|---|
| Skill Config | Skill references Status Effect | Allowed only after combat approval |
| Balance Config | Status Effect references Balance | Durations and values must be documented |
| Localization | Status Effect references Localization | Text keys must resolve if localization is used |
| Shared References | Status Effect references Shared | Categories and enums must be approved |

### Ownership

Primary owner: Project Director until status effect combat rules are approved.

Required reviewers: Gameplay Agent and Reviewer Agent.

### Update Process

1. Confirm status effect approval in `docs/COMBAT.md`.
2. Confirm decision approval in `docs/DECISIONS.md`.
3. Confirm task scope explicitly includes Status Effect Config.
4. Confirm status effect fields in `docs/DATA_SCHEMA.md`.
5. Validate that entries remain inactive unless approved.
6. Review combat, balance, and UI impact.
7. Update combat documentation before active use.

## Economy Config

Economy Config defines currency, cost, reward, source, sink, and audit-facing data.

### Relationships

Economy Config may reference:

- Balance Config for economy scaling values.
- Drop Table Config as a consumer of reward definitions.
- Shared references for currency categories and audit categories.
- Localization for display text.

Economy Config must not own:

- Combat victory rules.
- World completion rules.
- Quest objective rules.
- Tower floor rules.
- Client-authoritative balances.

### Dependencies

| Dependency | Direction | Rule |
|---|---|---|
| Balance Config | Economy references Balance | Costs and rewards must be reviewed |
| Drop Table Config | Drop Table references Economy | Rewards must be defined before use |
| Localization | Economy references Localization | Text keys must resolve if localization is used |
| Shared References | Economy references Shared | Currency categories must be approved |

### Ownership

Primary owner: Economy Agent.

Required reviewers: Data Agent and Reviewer Agent.

### Update Process

1. Confirm economy behavior is approved.
2. Confirm fields match `docs/DATA_SCHEMA.md`.
3. Confirm costs and rewards are data-driven.
4. Confirm server authority rules from `docs/SECURITY_GUIDE.md`.
5. Validate reward and sink references.
6. Review balance impact.
7. Update economy and balance documentation when applicable.

## Balance Config

Balance Config defines shared tuning values and scaling references.

### Relationships

Balance Config may be referenced by:

- Creature Config.
- Skill Config.
- World Config.
- Boss Config.
- Economy Config.
- Drop Table Config.
- Quest Config if approved.
- Tower Config if approved.
- Status Effect Config if approved.

Balance Config must not own:

- Content identity.
- Reward grants.
- Save mutation rules.
- Client authority.
- Undocumented mechanics.

### Dependencies

Balance Config should depend only on:

- Approved balance philosophy.
- Documented variable categories.
- Shared enums or tags when needed.

Balance Config should not depend on high-level content unless explicitly documented.

### Ownership

Primary owner: Economy Agent and Gameplay Agent.

Required reviewers: Project Director and Reviewer Agent.

### Update Process

1. Confirm the balance variable is approved or marked as placeholder.
2. Confirm the variable belongs in Balance Config.
3. Confirm affected systems.
4. Update Balance Config.
5. Update `docs/BALANCE.md` if philosophy, category, or variable meaning changes.
6. Review affected configs.
7. Validate no fake numbers were introduced.

## Drop Table Config

Drop Table Config defines reward pools and reward selection references.

### Relationships

Drop Table Config may reference:

- Economy Config for reward definitions.
- Balance Config for selection weights or scaling references.
- World Config as a reward source.
- Boss Config as a reward source.
- Quest Config only if approved.
- Tower Config only if approved.

Drop Table Config must not own:

- Currency definitions.
- Combat outcomes.
- Progression completion.
- Client reward claims.
- Undocumented reward paths.

### Dependencies

| Dependency | Direction | Rule |
|---|---|---|
| Economy Config | Drop Table references Economy | Rewards must exist before use |
| Balance Config | Drop Table references Balance | Selection values must be reviewed |
| World Config | World references Drop Table | Source must be approved |
| Boss Config | Boss references Drop Table | Source must be approved |

### Ownership

Primary owner: Economy Agent.

Required reviewers: Data Agent, Gameplay Agent, and Reviewer Agent.

### Update Process

1. Confirm reward source is approved.
2. Confirm reward entries exist in Economy Config.
3. Confirm selection values come from config.
4. Confirm no fake numbers are introduced.
5. Validate references.
6. Review economy and balance impact.
7. Update relevant documentation.

## Localization

Localization defines player-facing text references and display strings when text is externalized from gameplay config.

Localization is not gameplay configuration.

Localization must not contain gameplay values, reward values, combat values, economy values, or progression requirements.

### Relationships

Localization may be referenced by:

- Creature Config.
- Skill Config.
- World Config.
- Boss Config.
- Quest Config if approved.
- Tower Config if approved.
- Status Effect Config if approved.
- Economy Config.
- UI configuration or UI documentation.

Localization must not reference:

- Gameplay state.
- Save state.
- Economy balances.
- Combat results.
- Player-specific progression.

### Dependencies

| Dependency | Direction | Rule |
|---|---|---|
| Domain Config | Domain config references Localization | Text keys must exist |
| UI | UI references Localization | Text keys must resolve for display |
| Localization | Localization references no gameplay config | Text must not control behavior |

### Ownership

Primary owner: UI Agent.

Required reviewers: Data Agent and Reviewer Agent.

### Update Process

1. Confirm the text is player-facing.
2. Confirm the text does not encode gameplay values unless explicitly approved for display.
3. Confirm localization key naming follows `docs/STYLE_GUIDE.md`.
4. Add or update the text reference.
5. Validate key uniqueness.
6. Review UI clarity.
7. Update documentation if text ownership or naming changes.

## Cross-Config Dependencies

This section summarizes major cross-config dependencies.

### Dependency Matrix

| Source Config | May Reference | Must Not Reference |
|---|---|---|
| Creature Config | Skill, Gene, Balance, Localization, Shared | Economy transactions, World unlocks, Quest rules, Tower rules |
| Skill Config | Balance, Localization, Shared, Status Effect if approved | Rewards, Currency balances, Save mutation |
| World Config | Boss, Drop Table, Balance, Localization, Shared | Combat formulas, Economy balances, Quest systems |
| Boss Config | Skill, Drop Table, Balance, Localization, Shared | World unlock authority, Player progression mutation |
| Quest Config | World, Creature, Economy, Drop Table, Balance, Localization if approved | Daily/timed systems unless approved |
| Tower Config | World, Boss, Drop Table, Balance, Localization if approved | Timed resets or power gates unless approved |
| Status Effect Config | Balance, Localization, Shared if approved | Skill activation authority, Combat turn ownership |
| Economy Config | Balance, Localization, Shared | Combat results, World completion, Client balances |
| Balance Config | Shared | Content ownership, Rewards, Save mutation |
| Drop Table Config | Economy, Balance, Shared | Currency definitions, Combat outcomes |
| Localization | None or shared text metadata | Gameplay values, Save state, Player state |

### Required Validation Order

Recommended validation order:

1. Shared references.
2. Localization.
3. Balance Config.
4. Economy Config.
5. Drop Table Config.
6. Skill Config.
7. Gene Config.
8. Creature Config.
9. Boss Config.
10. World Config.
11. Reserved Quest Config when approved.
12. Reserved Tower Config when approved.
13. Reserved Status Effect Config when approved.

This order may be adjusted by technical architecture if dependency validation remains equivalent.

## Update Process

Every configuration update must follow a controlled process.

### Standard Update Workflow

1. Read the relevant source-of-truth documents.
2. Confirm the config category is active or explicitly approved for the task.
3. Confirm the schema in `docs/DATA_SCHEMA.md`.
4. Confirm naming rules in `docs/CONFIG_GUIDE.md` and `docs/STYLE_GUIDE.md`.
5. Confirm affected dependencies.
6. Confirm balance impact.
7. Confirm economy impact.
8. Confirm security impact when server authority is involved.
9. Update the scoped config only.
10. Validate required fields.
11. Validate reference integrity.
12. Validate no circular dependencies were introduced.
13. Validate no reserved config became active without approval.
14. Update documentation if behavior, schema, ownership, or workflow changed.
15. Submit for review.

### Required Documents By Change Type

| Change Type | Required Documents |
|---|---|
| Creature config change | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md`, `docs/GDD_MASTER.md` |
| Skill config change | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md`, `docs/COMBAT.md` |
| World config change | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md`, `docs/GDD_MASTER.md` |
| Boss config change | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md`, `docs/COMBAT.md`, `docs/BALANCE.md` |
| Quest config change | `docs/DATA_SCHEMA.md`, `docs/DECISIONS.md`, `docs/GDD_MASTER.md` |
| Tower config change | `docs/DATA_SCHEMA.md`, `docs/DECISIONS.md`, `docs/GDD_MASTER.md` |
| Status effect config change | `docs/DATA_SCHEMA.md`, `docs/DECISIONS.md`, `docs/COMBAT.md` |
| Economy config change | `docs/DATA_SCHEMA.md`, `docs/CONFIG_GUIDE.md`, `docs/BALANCE.md`, `docs/SECURITY_GUIDE.md` |
| Balance config change | `docs/BALANCE.md`, `docs/DECISIONS.md`, `docs/CONFIG_GUIDE.md` |
| Drop table config change | `docs/DATA_SCHEMA.md`, `docs/BALANCE.md`, `docs/SECURITY_GUIDE.md` |
| Localization change | `docs/UI_GUIDELINES.md`, `docs/STYLE_GUIDE.md` |

### Update Output Requirements

Every config update must produce:

- Clear changed config category.
- Clear reason for change.
- List of affected dependencies.
- Validation notes.
- Balance notes when applicable.
- Economy notes when applicable.
- Security notes when applicable.
- Documentation updates when applicable.
- Review status.

## Validation Gates

Configuration must pass validation before active use.

### Gate 1: Category Gate

- [ ] The config belongs to the correct category.
- [ ] The config category is approved for the task.
- [ ] Reserved config remains inactive unless approved.

### Gate 2: Schema Gate

- [ ] Required fields exist.
- [ ] Field types are correct.
- [ ] IDs follow naming rules.
- [ ] Version fields follow schema expectations.
- [ ] Optional fields are handled according to policy.

### Gate 3: Reference Gate

- [ ] All referenced IDs exist.
- [ ] References point to the correct config category.
- [ ] No circular dependencies exist.
- [ ] No display names are used as IDs.
- [ ] No retired IDs are reused incorrectly.

### Gate 4: Scope Gate

- [ ] Config does not introduce undocumented mechanics.
- [ ] Config does not activate reserved systems without approval.
- [ ] Config does not add unapproved reward paths.
- [ ] Config does not add unapproved progression rules.
- [ ] Config does not add unapproved combat rules.

### Gate 5: Balance Gate

- [ ] Tuning values are approved or marked as placeholders.
- [ ] No fake numbers are introduced.
- [ ] Balance-sensitive values are reviewed.
- [ ] Recommended power remains guidance only unless otherwise approved.

### Gate 6: Security Gate

- [ ] Config does not trust client-provided values.
- [ ] Economy values remain server-authoritative.
- [ ] Combat outcomes remain server-authoritative.
- [ ] Save-impacting references are reviewed.
- [ ] Reward grants remain server-controlled.

### Gate 7: Documentation Gate

- [ ] Source-of-truth documentation remains accurate.
- [ ] Schema documentation is updated when needed.
- [ ] Balance documentation is updated when needed.
- [ ] Decision log is updated when needed.
- [ ] Known issues are updated when unresolved questions remain.

## Review Checklist

Every configuration structure change must be reviewed against this checklist.

### Required Checklist

- [ ] The hierarchy remains data-driven.
- [ ] Ownership is clear.
- [ ] Dependencies are explicit.
- [ ] Dependency direction is appropriate.
- [ ] Reserved schema surfaces remain protected.
- [ ] No gameplay values are hardcoded.
- [ ] No display names are used as stable IDs.
- [ ] No circular dependencies are introduced.
- [ ] No config category owns unrelated behavior.
- [ ] Localization does not control gameplay.
- [ ] Economy values remain server-authoritative.
- [ ] Combat values remain server-authoritative.
- [ ] Balance values are documented.
- [ ] Drop tables reference approved rewards.
- [ ] World and boss references are valid.
- [ ] Quest, Tower, and Status Effect entries remain inactive unless approved.
- [ ] Documentation has been updated where needed.
- [ ] The change can be reviewed independently.

## Professional Conclusion

Project Genesis relies on a clear configuration hierarchy so data-driven development remains scalable, reviewable, and safe.

Each configuration category must have a defined purpose, owner, dependency direction, validation path, and update process.

Active MVP configuration must remain aligned with the GDD, decision log, data schema, balance philosophy, security guide, and content pipeline.

Reserved schema surfaces must remain protected until explicitly approved.

No configuration change is complete unless its dependencies are valid, its ownership is clear, and its documentation remains accurate.
