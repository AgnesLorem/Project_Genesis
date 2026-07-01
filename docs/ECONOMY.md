# Economy

## Purpose

This document defines economy principles, resource ownership, reward constraints, sinks, sources, and validation requirements for Project Genesis.

## Status

- Status: Active Draft (MVP-005)
- Owner: Antigravity (Claude Opus 4.6)
- Last Updated: 2026-06-29
- Review Cadence: Before any economy system change

## Table of Contents

- [Economy Goals](#economy-goals)
- [Currencies](#currencies)
- [Sources](#sources)
- [Sinks](#sinks)
- [Risk Controls](#risk-controls)
- [Open Questions](#open-questions)

## Economy Goals

1. Support approved progression, creature, combat, and collection loops.
2. All currency values are server-authoritative.
3. All economy data is data-driven from config files.
4. No premium currency for MVP.
5. No monetization system for MVP.
6. No player-to-player economy for MVP.

## Currencies

| Currency | ID | Type | Cap | Config File |
|---|---|---|---|---|
| Biomass | `biomass` | `soft` | `999999` | `configs/economy/biomass_config.luau` |
| DNA | `dna` | `soft` | `999999` | `configs/economy/dna_config.luau` |

All currency amounts are **integer-only**. No fractional currency values.

## Sources

| Source ID | Currency | Description | MVP Status |
|---|---|---|---|
| `bio_generator_claim` | Biomass | Bio Generator passive accumulation and claim | Active (MVP-005) |
| `reward_combat` | Biomass, DNA | Combat victory rewards | Active (MVP-019). Grants 50 Biomass and 50 DNA upon victory. |
| `reward_milestone` | DNA | Milestone/progression rewards | Foundation only — amounts defined in future progression MVP |

## Sinks

| Sink ID | Currency | Description | MVP Status |
|---|---|---|---|
| `spend_generic` | Biomass, DNA | Generic spend validation | Foundation only — specific costs defined in future MVPs |

## Bio Generator

The Bio Generator is the primary Biomass source for MVP.

| Parameter | Value | Source |
|---|---|---|
| Generator ID | `bio_generator_01` | `configs/generators/bio_generator_config.luau` |
| Rate | 1 Biomass / second | Config-driven |
| Max Accumulated | 3600 (1 hour) | Config-driven |
| Accumulation Formula | `floor(elapsed_seconds * ratePerSecond)` | Server-calculated |
| Claim | Server-authoritative, resets timer | CurrencyService validates source and cap |

## Risk Controls

1. **Server Authority**: Server owns ALL currency balances, grants, spending, and validation.
2. **Config-Driven**: All rates, caps, costs, and rewards come from config files.
3. **Source/Sink Validation**: Every grant requires an approved `sourceRef`; every spend requires an approved `sinkRef`.
4. **Cap Enforcement**: Grants never exceed cap. Near-cap grants are reduced to remaining capacity.
5. **Integer Enforcement**: All currency amounts are integers. Fractional values are rejected.
6. **Client Distrust**: Client-provided amounts, times, or currency values are never trusted.
7. **First-Use Init**: New generator state initializes `lastClaimedAt` to server time, preventing retroactive claims.

## Open Questions

1. Exact spend costs for Biomass and DNA (depends on future creature/combat MVPs).
2. DNA/Biomass reward amounts for milestones (defined by future MVP configs).
3. Additional currencies beyond Biomass and DNA (not approved for MVP).
