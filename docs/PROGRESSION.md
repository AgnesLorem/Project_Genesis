# Progression, Collection, and Evolution

## Purpose

This document defines player-facing creature leveling progression, collection systems, and evolution transactions for the Project Genesis MVP.

## Status

- Status: Active Draft (MVP-007)
- Owner: Technical Architecture
- Last Updated: 2026-06-29
- Review Cadence: Before any progression, collection, or evolution changes

## Table of Contents

- [Creature Progression](#creature-progression)
- [Collection System](#collection-system)
- [Evolution System](#evolution-system)
- [Genes and Prestige Boundaries](#genes-and-prestige-boundaries)

---

## Creature Progression

For the MVP, progression is focused strictly on creature development. There is no player account level or PlayerXP system.

### Experience Curve
- Baseline requirement: `CreatureXPNeeded = CreatureLevel * 100`
- Example:
  - Level 1 -> Level 2: Requires 100 XP
  - Level 2 -> Level 3: Requires 200 XP
- Excess/overflow XP gained carries over to the next level during level-up.

### Persistence
Creature levels and XP are tracked inside `creatureInstances` in player save data:
```luau
creatureInstances = {
	["instance_guid"] = {
		instanceId = "instance_guid",
		creatureId = "creature_starter",
		level = 1,
		xp = 0,
		acquiredAt = 1782660472
	}
}
```

---

## Collection System

The collection system implements a server-authoritative discovery checklist for active creatures.

### Discovery Rule
- Discovering a creature updates the `collectionState.discoveredCreatureIds` map in player save data.
- Whenever a player is granted a creature (via `CreatureService.tryGrantCreature` or successful `EvolutionService.tryEvolve`), the creature species ID is added to their discovered list.
- Invalid or disabled creature IDs cannot be discovered.

### Save Structure
```luau
collectionState = {
	discoveredCreatureIds = {
		["creature_001"] = true,
		["creature_002"] = true,
	}
}
```

---

## Evolution System

Evolution is a server-authoritative transaction that upgrades a creature to a stronger form.

### Rules & Costs
- **Level Requirement**: Creature level must be >= the config's `requiredLevel`.
- **Biomass Cost**: Player must pay the config's `biomassCost` (deducted via `CurrencyService.trySpend` with sinkRef `"evolution"`).
- **Reset Behavior**: Successful evolution resets the creature's level back to **1** and XP back to **0**.
- **Collection**: Evolved form is automatically added to the player's collection.
- **Rollback**: If any verification step fails (including level mismatch, insufficient biomass, or registry error), the transaction is immediately aborted. Biomass is not spent, and the collection is not modified.

## World Stage Progression

World progression in Project Genesis is tracked on the server via unlocked stages.

### Stage Locks & Validation
- **Save Profile State**: Unlocked stages are tracked in the player's save profile:
  ```luau
  worldProgression = {
      unlockedStages = { "story_stage_1" } -- Default unlocked stage
  }
  ```
- **Access Verification**: Before entering combat, the server validates if the requested `stageId` is present in the player's `unlockedStages` list. Locked stage requests are rejected.
- **Victory Progression**: On player victory, the server finds the index of the completed stage in the sequence (defined in `RemoteHandlers`). If a subsequent stage exists and is not yet unlocked, it is appended to the player's `unlockedStages` list and marked dirty for saving.

---

## Genes and Prestige Boundaries

To maintain MVP focus, Genes and Prestige are strictly limited to foundational schemas.

### Genes
- **GeneSchema**: Used for potential validation.
- **Rules**:
  - No active gene configs.
  - No gene rolling, inheritance, mutation, or equipped effects.

### Prestige
- **PrestigeSchema**: Reserved.
- **Rules**:
  - Excluded from player saves (`prestigeState` is uninitialized).
  - No active prestige rewards, multipliers, or level cap increases.
