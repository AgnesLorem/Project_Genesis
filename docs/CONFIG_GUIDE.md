# Project Genesis Configuration Guide

## Purpose

This document defines how gameplay configuration should be organized for Project Genesis.

Project Genesis is a fully data-driven Roblox game. Gameplay values must come from approved configuration data, not from implementation code.

This guide is mandatory for:

- AI assistants.
- Human programmers.
- Technical designers.
- Data authors.
- Economy designers.
- Balance designers.
- Reviewers.
- Any contributor adding or modifying gameplay values.

This document describes configuration structure, ownership, naming, validation, categories, versioning, and review standards.

This document does not include Lua code.

## Status

- Document Status: Active
- Scope: MVP configuration standards
- Project Type: Roblox
- Architecture: Data-driven, server-authoritative
- Owner: Data Architecture
- Last Updated: 2026-06-28

## Table of Contents

- [Purpose](#purpose)
- [Status](#status)
- [Configuration Philosophy](#configuration-philosophy)
- [Why Gameplay Values Must Come From Configuration](#why-gameplay-values-must-come-from-configuration)
- [Folder Structure](#folder-structure)
- [Naming Rules](#naming-rules)
- [Configuration Categories](#configuration-categories)
- [Creature Config](#creature-config)
- [Skill Config](#skill-config)
- [Gene Config](#gene-config)
- [World Config](#world-config)
- [Boss Config](#boss-config)
- [Tower Config](#tower-config)
- [Economy Config](#economy-config)
- [Balance Config](#balance-config)
- [Drop Table Config](#drop-table-config)
- [Versioning](#versioning)
- [Validation Rules](#validation-rules)
- [Good Config](#good-config)
- [Bad Config](#bad-config)
- [Configuration Review Checklist](#configuration-review-checklist)
- [Professional Conclusion](#professional-conclusion)

## Configuration Philosophy

Configuration defines what the game contains and how approved gameplay values are tuned.

Implementation defines how systems read, validate, and apply that configuration.

These responsibilities must stay separate.

### Core Principles

- Gameplay values must be data-driven.
- Configuration must be the source of gameplay tuning.
- Implementation must not hide gameplay values.
- Configuration must follow documented schemas.
- Configuration must be validated before use.
- Configuration must use stable identifiers.
- Configuration must avoid duplicate definitions.
- Configuration must be readable by humans and AI assistants.
- Configuration must be reviewable in isolation.
- Configuration must support server-authoritative gameplay.

### Configuration Must Control

- Creature definitions.
- Skill definitions.
- Gene definitions.
- World definitions.
- Boss definitions.
- Tower definitions when approved for active use.
- Economy definitions.
- Balance variables.
- Drop tables.
- Reward definitions.
- Cost definitions.
- Scaling values.
- Eligibility requirements.

### Implementation Must Control

- Loading configuration.
- Validating configuration.
- Applying approved rules.
- Enforcing server authority.
- Rejecting invalid data.
- Reporting configuration errors.
- Providing safe defaults only when documented.

Implementation must not become the hidden owner of gameplay tuning.

## Why Gameplay Values Must Come From Configuration

Gameplay values must always come from configuration instead of implementation because Project Genesis is designed for long-term AI-assisted production.

Hardcoded gameplay values create production risk.

They make balance difficult, hide design decisions, increase implementation churn, and make it harder for AI assistants and human reviewers to understand why the game behaves the way it does.

### Configuration Improves Production Quality

Configuration allows:

- Designers to adjust gameplay values without rewriting systems.
- Programmers to keep systems generic.
- Reviewers to inspect tuning directly.
- AI assistants to make scoped data changes.
- Balance passes to happen without architecture changes.
- Content additions to follow repeatable workflows.
- Documentation to remain aligned with implementation.
- The game to add approved content without rewriting core systems.

### Hardcoding Creates Risk

Hardcoded gameplay values create:

- Hidden balance rules.
- Unreviewable tuning.
- Duplicated logic.
- Inconsistent behavior.
- Code changes for simple content updates.
- Increased chance of accidental feature creep.
- Increased chance of AI hallucination.
- Increased chance of breaking unrelated systems.

### Required Rule

If a value affects gameplay, progression, economy, combat, rewards, costs, creature behavior, skill behavior, gene behavior, boss behavior, world behavior, tower behavior, or balance, it must come from approved configuration unless explicitly documented otherwise.

## Folder Structure

The exact implementation folder layout must be approved by technical architecture before code is written.

The intended configuration organization should separate static gameplay data by domain.

### Recommended Documentation-Level Structure

```text
config/
    creatures/
    skills/
    genes/
    worlds/
    bosses/
    towers/
    economy/
    balance/
    drop_tables/
    shared/
```

### Folder Ownership

| Folder | Owner | Purpose |
|---|---|---|
| `config/creatures/` | Data Agent | Creature definitions and creature-facing values |
| `config/skills/` | Gameplay Agent | Skill definitions and skill-facing values |
| `config/genes/` | Data Agent | Gene definitions and gene-facing values |
| `config/worlds/` | Gameplay Agent | World definitions and world progression values |
| `config/bosses/` | Gameplay Agent | Boss definitions and boss-facing values |
| `config/towers/` | Gameplay Agent | Tower definitions when approved for active use |
| `config/economy/` | Economy Agent | Currency, costs, rewards, and economy values |
| `config/balance/` | Economy Agent / Gameplay Agent | Shared balance variables and scaling references |
| `config/drop_tables/` | Economy Agent / Data Agent | Reward pools and drop table definitions |
| `config/shared/` | Technical Architecture | Shared enums, tags, categories, and common references |

### Structure Rules

- Configuration must be grouped by gameplay domain.
- Shared values must live in shared configuration, not duplicated across domains.
- Domain-specific values must stay in their domain folder.
- Config files must not mix unrelated systems.
- Config files must have clear ownership.
- Config file names must identify the domain and purpose.
- Config files must be small enough to review.
- Config files must avoid hidden dependencies.
- Active configuration must match documented schemas.

## Naming Rules

Configuration naming must be stable, readable, and consistent.

Names must support reliable references across data, saves, documentation, UI, and content pipelines.

### Identifier Rules

- Use stable string identifiers.
- Use lowercase snake_case for internal IDs.
- Use descriptive IDs, not temporary names.
- Do not use display names as IDs.
- Do not use numeric-only IDs for authored content.
- Do not rename IDs casually after they appear in saves.
- Do not reuse retired IDs for different content.
- Do not include spaces in IDs.
- Do not include punctuation except underscores.
- Do not encode balance values into IDs.

### Good Identifier Examples

| Type | Good ID | Reason |
|---|---|---|
| Creature | `ember_larva` | Stable, readable creature identifier |
| Skill | `flame_burst` | Describes skill identity without numeric tuning |
| Gene | `swift_gene` | Clear gene identity |
| World | `verdant_lab` | Stable world identifier |
| Boss | `ember_guardian` | Clear boss identity |
| Economy | `soft_currency` | Describes currency category |
| Drop Table | `world_01_basic_rewards` | Clear scope and purpose |

### Bad Identifier Examples

| Type | Bad ID | Reason |
|---|---|---|
| Creature | `Creature1` | Temporary and not descriptive |
| Skill | `big_damage_500` | Encodes tuning in the ID |
| Gene | `gene new` | Contains a space |
| World | `WORLD!!!` | Inconsistent format |
| Boss | `boss_final_maybe` | Unclear and speculative |
| Economy | `money_temp` | Temporary name |
| Drop Table | `rewards` | Too vague |

### Display Name Rules

Display names are player-facing names.

They may use capitalization and spacing.

Display names must not be used as stable references.

### File Naming Rules

- Use lowercase snake_case.
- Use clear domain names.
- Use plural folder names for collections.
- Use singular names for individual authored records when applicable.
- Avoid abbreviations unless approved.
- Avoid temporary suffixes such as `_new`, `_final`, `_test`, or `_v2` in active config.

## Configuration Categories

Project Genesis configuration is divided into gameplay categories.

Each category must have a documented schema in `docs/DATA_SCHEMA.md` before active implementation.

### Category Summary

| Category | Purpose | Primary Owner | Source Document |
|---|---|---|---|
| Creature Config | Defines creature data | Data Agent | `docs/DATA_SCHEMA.md` |
| Skill Config | Defines skill data | Gameplay Agent | `docs/DATA_SCHEMA.md` |
| Gene Config | Defines gene data | Data Agent | `docs/DATA_SCHEMA.md` |
| World Config | Defines world data | Gameplay Agent | `docs/DATA_SCHEMA.md` |
| Boss Config | Defines boss data | Gameplay Agent | `docs/DATA_SCHEMA.md` |
| Tower Config | Defines tower data when approved | Gameplay Agent | `docs/DATA_SCHEMA.md` |
| Economy Config | Defines economy data | Economy Agent | `docs/DATA_SCHEMA.md` |
| Balance Config | Defines shared tuning variables | Economy Agent / Gameplay Agent | `docs/BALANCE.md` |
| Drop Table Config | Defines reward pools | Economy Agent / Data Agent | `docs/DATA_SCHEMA.md` |

### Category Rules

- Each category must have a clear owner.
- Each category must follow its schema.
- Each category must avoid unrelated data.
- Each category must use stable identifiers.
- Each category must be validated before use.
- Each category must be reviewed when changed.

## Creature Config

Creature configuration defines creature identity, classification, base data, progression references, evolution references, skill references, gene references, and collection references.

### Purpose

Creature config ensures creatures can be added, reviewed, balanced, and displayed without changing gameplay systems.

### Required Documentation

- `docs/DATA_SCHEMA.md`
- `docs/GDD_MASTER.md`
- `docs/CONTENT_PIPELINE.md`
- `docs/BALANCE.md`
- `docs/ART_BIBLE.md` when artwork is affected

### Expected Fields

The authoritative field list is defined in `docs/DATA_SCHEMA.md`.

Creature configuration may include fields such as:

- Creature ID.
- Display name.
- Description.
- Role or category.
- Base stat references.
- Skill references.
- Gene references.
- Evolution references.
- Collection references.
- Artwork references.
- Unlock references.

### Rules

- Creature IDs must be stable.
- Creature stats must not be hardcoded in implementation.
- Creature skill references must point to valid Skill Config.
- Creature evolution references must point to valid Evolution Config.
- Creature artwork references must follow the art pipeline.
- Creature config must not define unrelated economy behavior.
- Creature config must not imply unapproved mechanics.

### Review Questions

- Does the creature follow the schema?
- Are all references valid?
- Are all gameplay values data-driven?
- Does the creature fit current MVP scope?
- Does the creature require undocumented mechanics?

## Skill Config

Skill configuration defines combat skills and their approved gameplay values.

### Purpose

Skill config allows combat behavior to be tuned and reviewed without hardcoding skill values into combat systems.

### Required Documentation

- `docs/DATA_SCHEMA.md`
- `docs/COMBAT.md`
- `docs/BALANCE.md`
- `docs/CONTENT_PIPELINE.md`

### Expected Fields

The authoritative field list is defined in `docs/DATA_SCHEMA.md`.

Skill configuration may include fields such as:

- Skill ID.
- Display name.
- Description.
- Skill category.
- Cooldown reference.
- Damage or effect references.
- Targeting reference.
- Visual reference.
- Audio reference.
- Balance tags.

### Rules

- Skill cooldowns must come from configuration.
- Skill damage values must come from configuration.
- Skill target rules must be documented before active use.
- Skill effects must not introduce undocumented systems.
- Skill config must not include client-authoritative outcomes.
- Skill config must not bypass combat rules.

### Review Questions

- Does the skill follow approved combat rules?
- Are cooldowns configured rather than hardcoded?
- Are damage-related values configured rather than hardcoded?
- Are all references valid?
- Does the skill require unapproved combat behavior?

## Gene Config

Gene configuration defines gene identity, effects, categories, references, and tuning values.

### Purpose

Gene config allows the gene system to be expanded through data while keeping implementation generic and reviewable.

### Required Documentation

- `docs/DATA_SCHEMA.md`
- `docs/GDD_MASTER.md`
- `docs/BALANCE.md`
- `docs/CONTENT_PIPELINE.md`

### Expected Fields

The authoritative field list is defined in `docs/DATA_SCHEMA.md`.

Gene configuration may include fields such as:

- Gene ID.
- Display name.
- Description.
- Gene category.
- Effect reference.
- Value reference.
- Eligibility reference.
- Collection reference.
- Balance tags.

### Rules

- Gene effects must be documented before active use.
- Gene values must come from configuration.
- Gene config must not define hidden progression shortcuts.
- Gene config must not create unapproved inheritance or mutation behavior.
- Gene config must not include unrelated economy logic.

### Review Questions

- Does the gene follow the schema?
- Is the effect approved?
- Are values data-driven?
- Are references valid?
- Does the gene create undocumented behavior?

## World Config

World configuration defines world identity, order, unlock references, recommended power references, enemy references, reward references, and presentation metadata.

### Purpose

World config allows world progression and content ordering to be controlled through data.

### Required Documentation

- `docs/DATA_SCHEMA.md`
- `docs/GDD_MASTER.md`
- `docs/BALANCE.md`
- `docs/CONTENT_PIPELINE.md`

### Expected Fields

The authoritative field list is defined in `docs/DATA_SCHEMA.md`.

World configuration may include fields such as:

- World ID.
- Display name.
- Description.
- Order.
- Unlock reference.
- Recommended power reference.
- Enemy references.
- Reward references.
- Background reference.
- UI presentation reference.

### Rules

- World order must come from configuration.
- Recommended power must come from configuration.
- Recommended power must not be treated as a power gate.
- Rewards must reference approved economy or drop table data.
- World config must not create undocumented unlock systems.
- World config must not bypass MVP progression rules.

### Review Questions

- Does the world follow the schema?
- Is recommended power configured?
- Is recommended power treated only as a recommendation?
- Are rewards approved?
- Are unlock assumptions documented?

## Boss Config

Boss configuration defines boss identity, battle mode, phase references, recommended power, skill references, reward references, and presentation metadata.

### Purpose

Boss config allows boss content to be authored and reviewed without hardcoding boss behavior into combat systems.

### Required Documentation

- `docs/DATA_SCHEMA.md`
- `docs/COMBAT.md`
- `docs/BALANCE.md`
- `docs/CONTENT_PIPELINE.md`

### Expected Fields

The authoritative field list is defined in `docs/DATA_SCHEMA.md`.

Boss configuration may include fields such as:

- Boss ID.
- Display name.
- Description.
- Battle mode.
- Phase references.
- Recommended power reference.
- Skill references.
- Reward references.
- Artwork references.
- World reference.

### Rules

- Boss battle size must follow approved combat rules.
- Boss phases must come from configuration.
- Boss phase behavior must be documented before active use.
- Boss rewards must come from approved reward data.
- Boss config must not hardcode combat formulas.
- Boss config must not create unapproved challenge systems.

### Review Questions

- Does the boss follow approved combat rules?
- Are phases configured?
- Are rewards configured?
- Are all references valid?
- Does the boss require undocumented mechanics?

## Tower Config

Tower configuration defines tower floor data when tower content is approved for active use.

### Purpose

Tower config reserves a data-driven structure for tower-related content while preventing implementation assumptions from becoming hidden design.

### Required Documentation

- `docs/DATA_SCHEMA.md`
- `docs/GDD_MASTER.md`
- `docs/CONTENT_PIPELINE.md`
- `docs/DECISIONS.md`

### Expected Fields

The authoritative field list is defined in `docs/DATA_SCHEMA.md`.

Tower configuration may include fields such as:

- Tower ID.
- Floor ID.
- Display name.
- Order.
- Enemy references.
- Boss references.
- Recommended power reference.
- Reward references.
- Unlock reference.

### Rules

- Tower config must not be used as active gameplay until approved.
- Tower fields must remain schema-aligned.
- Tower values must not be hardcoded.
- Tower rewards must reference approved economy or drop table data.
- Tower config must not define undocumented progression rules.

### Review Questions

- Is tower content approved for the current task?
- Does the config follow the schema?
- Are all values data-driven?
- Are rewards approved?
- Does the config imply unapproved mechanics?

## Economy Config

Economy configuration defines currencies, costs, rewards, purchase rules, reward grants, and economy-facing references.

### Purpose

Economy config protects currency and reward behavior from hardcoded implementation and unreviewed tuning changes.

### Required Documentation

- `docs/DATA_SCHEMA.md`
- `docs/ECONOMY.md`
- `docs/BALANCE.md`
- `docs/SECURITY_GUIDE.md`
- `docs/CONTENT_PIPELINE.md`

### Expected Fields

The authoritative field list is defined in `docs/DATA_SCHEMA.md`.

Economy configuration may include fields such as:

- Currency ID.
- Display name.
- Currency category.
- Reward source references.
- Cost references.
- Grant rules.
- Spend rules.
- Display metadata.
- Balance tags.

### Rules

- Currency values must be server-authoritative.
- Costs must come from configuration.
- Rewards must come from configuration.
- Economy config must not trust client values.
- Economy config must not create hidden reward paths.
- Economy config must not introduce unapproved currency types.
- Economy config must not duplicate values across unrelated files.

### Review Questions

- Are costs configured?
- Are rewards configured?
- Are all currency references valid?
- Does the config preserve server authority?
- Does the config create unapproved economy behavior?

## Balance Config

Balance configuration defines shared variables, scaling references, coefficients, thresholds, and tuning values approved for active use.

### Purpose

Balance config keeps tuning visible, reviewable, and adjustable without changing implementation logic.

### Required Documentation

- `docs/BALANCE.md`
- `docs/DATA_SCHEMA.md`
- `docs/COMBAT.md` when combat is affected
- `docs/ECONOMY.md` when economy is affected
- `docs/PROGRESSION.md` when progression is affected

### Expected Fields

The authoritative field list must align with relevant schemas and balance documentation.

Balance configuration may include fields such as:

- Balance ID.
- Category.
- Description.
- Value.
- Value type.
- Applies to.
- Review notes.
- Status.

### Rules

- Balance values must not be hidden in implementation.
- Balance variables must be named clearly.
- Balance values must have documented purpose.
- Unknown values must remain placeholders.
- Fake numbers must not be created.
- Balance config must not mix unrelated systems.
- Balance changes must be reviewed.

### Review Questions

- Is the value approved?
- Is the value documented?
- Is the value in the correct category?
- Does the value affect gameplay?
- Does the value require a balance review?

## Drop Table Config

Drop table configuration defines reward pools, reward references, eligibility references, and selection rules.

### Purpose

Drop table config allows reward distribution to be reviewed, balanced, and adjusted through data.

### Required Documentation

- `docs/DATA_SCHEMA.md`
- `docs/ECONOMY.md`
- `docs/BALANCE.md`
- `docs/CONTENT_PIPELINE.md`
- `docs/SECURITY_GUIDE.md`

### Expected Fields

The authoritative field list must align with relevant schemas and reward documentation.

Drop table configuration may include fields such as:

- Drop table ID.
- Display name.
- Reward pool references.
- Eligibility reference.
- Source reference.
- Weight or selection reference.
- Guaranteed reward reference.
- Review status.

### Rules

- Drop table IDs must be stable.
- Reward references must be valid.
- Selection values must come from configuration.
- Reward grants must be server-authoritative.
- Drop table config must not create hidden reward paths.
- Drop table config must not contain fake reward numbers.
- Drop table config must be reviewed for economy impact.

### Review Questions

- Are reward references valid?
- Is the reward source approved?
- Are selection rules documented?
- Are values data-driven?
- Does the drop table affect economy balance?

## Versioning

Configuration versioning protects save compatibility, review history, and production stability.

### Versioning Principles

- Active configuration must have a clear versioning policy.
- Save-impacting identifiers must be treated as stable.
- Renaming identifiers must be avoided after use in saves.
- Retired identifiers must not be reused for different content.
- Structural changes must be documented.
- Schema changes must be reflected in `docs/DATA_SCHEMA.md`.
- Balance changes must be reflected in `docs/BALANCE.md` when applicable.
- Economy changes must be reflected in economy documentation when applicable.

### Versioning Fields

Configuration may use versioning metadata such as:

| Field | Type | Purpose | Example |
|---|---|---|---|
| `config_version` | String | Identifies config version | `"mvp_001"` |
| `schema_version` | String | Identifies expected schema version | `"creature_schema_mvp"` |
| `status` | String | Indicates authoring status | `"active"` |
| `deprecated_by` | String or Null | Identifies replacement config | `"ember_larva_revised"` |
| `notes` | String | Records review or migration notes | `"Initial MVP entry"` |

### Versioning Rules

- Version metadata must not replace proper documentation.
- Version changes must be reviewed.
- Deprecated content must remain understandable.
- Active save references must not break due to casual renaming.
- Config version changes must not silently change gameplay scope.

## Validation Rules

Configuration must be validated before active use.

Validation protects the project from broken data, invalid references, hardcoded fallback behavior, and inconsistent gameplay.

### General Validation Checklist

- [ ] Required fields exist.
- [ ] Field types are correct.
- [ ] Identifiers are stable.
- [ ] Identifiers follow naming rules.
- [ ] References point to valid records.
- [ ] Optional fields are handled safely.
- [ ] Duplicate identifiers are rejected.
- [ ] Unknown categories are rejected or flagged.
- [ ] Placeholder values are not used as final values.
- [ ] Gameplay values are documented.
- [ ] Balance-sensitive values are reviewed.
- [ ] Economy-sensitive values are reviewed.
- [ ] Combat-sensitive values are reviewed.
- [ ] Save-impacting changes are reviewed.
- [ ] No unapproved mechanics are implied.

### Reference Validation

References must be checked across categories.

Examples:

- Creature skill references must point to valid skills.
- Creature gene references must point to valid genes.
- Evolution references must point to valid creatures or evolution data.
- World enemy references must point to valid enemies or creatures as documented.
- Boss skill references must point to valid skills.
- Economy reward references must point to valid rewards.
- Drop table reward references must point to valid economy entries.

### Server Validation

The server must validate configuration before applying it to authoritative gameplay systems.

The server must not assume that loaded configuration is safe unless it has passed validation.

### Review Validation

Reviewers must check:

- Does the config match the schema?
- Does the config match the GDD?
- Does the config match the decision log?
- Does the config follow naming rules?
- Does the config introduce hidden mechanics?
- Does the config require balance review?
- Does the config require security review?
- Does the config require save compatibility review?

## Good Config

Good configuration is clear, scoped, data-driven, validated, and reviewable.

### Good Config Example

The following is a documentation example only. It is not Lua code.

```json
{
  "id": "flame_burst",
  "display_name": "Flame Burst",
  "category": "damage_skill",
  "cooldown_turns": "TBD_APPROVED_BALANCE_VALUE",
  "damage_formula_ref": "mvp_basic_damage",
  "targeting_ref": "single_enemy",
  "status": "draft",
  "notes": "Uses documented MVP cooldown skill structure."
}
```

### Why This Is Good

- The ID is stable.
- The display name is separate from the ID.
- The category is explicit.
- The cooldown is configurable.
- The damage formula is referenced rather than hidden in implementation.
- The targeting rule is referenced.
- Unknown tuning remains a placeholder.
- The status is visible.
- The notes explain the source of the design.

### Good Creature Config Example

The following is a documentation example only. It is not Lua code.

```json
{
  "id": "ember_larva",
  "display_name": "Ember Larva",
  "creature_category": "starter_candidate",
  "base_stats_ref": "ember_larva_mvp_stats",
  "skill_refs": ["flame_burst"],
  "evolution_ref": "ember_larva_evolution",
  "art_ref": "art_creature_ember_larva_card",
  "status": "draft"
}
```

### Why This Is Good

- Creature identity is stable.
- Stats are referenced, not hardcoded.
- Skills are referenced by stable IDs.
- Evolution data is separated.
- Art is referenced through the pipeline.
- The config can be reviewed independently.

## Bad Config

Bad configuration hides design, mixes systems, uses unstable names, or pushes gameplay logic into implementation.

### Bad Config Example

The following is a documentation example only. It is not Lua code.

```json
{
  "name": "Skill1",
  "damage": 999999,
  "cooldown": 0,
  "doesEverything": true,
  "rewardCoins": 5000
}
```

### Why This Is Bad

- The identifier is temporary.
- The display name and ID are unclear.
- Damage uses an unexplained fake number.
- Cooldown bypasses approved tuning.
- The field `doesEverything` is vague and unreviewable.
- Economy reward behavior is mixed into skill config.
- The config implies unapproved mechanics.
- The config is not tied to documented schemas.

### Bad Hardcoded Value Example

The following is a documentation example only. It is not Lua code.

```text
Implementation checks whether a creature is level 10, spends 500 currency, grants 25 rewards, and applies a 1.5 multiplier directly inside system logic.
```

### Why This Is Bad

- Level requirement is hidden in implementation.
- Currency cost is hidden in implementation.
- Reward amount is hidden in implementation.
- Multiplier is hidden in implementation.
- Designers cannot tune the values safely.
- Reviewers cannot inspect the gameplay configuration directly.
- AI assistants may duplicate or contradict the hidden values.

### Bad Naming Example

```json
{
  "id": "NewBossFinalReal",
  "reward": "lots",
  "power": "big",
  "phaseStuff": "maybe"
}
```

### Why This Is Bad

- ID format is inconsistent.
- Reward value is vague.
- Power value is vague.
- Phase behavior is undefined.
- The config cannot be validated reliably.
- The config is not production-ready.

## Configuration Review Checklist

Every configuration change must be reviewed before it is accepted.

### Required Review Checklist

- [ ] The config belongs to the correct category.
- [ ] The config follows the relevant schema.
- [ ] The config uses stable identifiers.
- [ ] The config follows naming rules.
- [ ] The config avoids temporary names.
- [ ] The config avoids fake numbers.
- [ ] The config avoids hardcoded implementation dependencies.
- [ ] The config avoids unrelated system data.
- [ ] The config references valid records.
- [ ] The config preserves server authority.
- [ ] The config does not trust client values.
- [ ] The config does not introduce undocumented mechanics.
- [ ] The config matches `docs/GDD_MASTER.md`.
- [ ] The config matches `docs/DECISIONS.md`.
- [ ] The config matches `docs/DATA_SCHEMA.md`.
- [ ] Balance-sensitive values are reviewed against `docs/BALANCE.md`.
- [ ] Economy-sensitive values are reviewed against economy documentation.
- [ ] Combat-sensitive values are reviewed against `docs/COMBAT.md`.
- [ ] Save-impacting values are reviewed against save documentation.
- [ ] The config can be understood by another contributor.

### Definition of Done for Configuration Changes

A configuration change is done only when:

- [ ] The config exists in the correct location.
- [ ] The config follows the approved schema.
- [ ] The config uses approved naming.
- [ ] The config has no fake values presented as final.
- [ ] The config has no undocumented mechanics.
- [ ] The config has no invalid references.
- [ ] The config has been validated.
- [ ] The config has been reviewed.
- [ ] Related documentation has been updated.
- [ ] Any unresolved questions are logged.

## Professional Conclusion

Project Genesis depends on configuration as the foundation of scalable, reviewable, AI-assisted development.

Gameplay values belong in configuration because they must be visible, documented, validated, reviewed, and adjustable without rewriting systems.

Implementation should remain generic, modular, and server-authoritative.

Configuration should define approved content and tuning.

Any gameplay value hidden in implementation is a production risk and must be moved into documented configuration unless explicitly approved otherwise.
