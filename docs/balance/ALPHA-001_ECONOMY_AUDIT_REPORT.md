# Economy Audit Report — Project Genesis (Task ALPHA-001 Phase A)

This audit report presents the empirical telemetry and progression pacing analysis of the current Project Genesis economy. The findings are based on offline mathematical simulations and live runtime integration tests.

---

## 1. Pacing & Progression Metrics

Based on the simulated player progression loops, here is the time taken to achieve key milestones:

### Active Play Scenario
*   **Time to reach Bio Generator Level 10**: **33 seconds**
*   **Time to reach Bio Generator Level 20**: **51 seconds**
*   **Time to reach Bio Generator Max Level (999)**: **~1,200 seconds (~20 minutes)**
*   **Time to unlock Advanced Bio Generator (requires Level 1000)**: **Stuck / Impossible**
*   **Time to reach DNA Generator Level 2 (requires 1,000,000 DNA)**: **Stuck / Impossible**

### Idle Play Scenario (AFK)
*   **Time to reach Bio Generator Level 10**: **540 seconds (9 minutes)**
*   **Time to reach Bio Generator Level 20**: **1,140 seconds (19 minutes)**
*   **Time to reach Bio Generator Max Level (999)**: **~8 hours**
*   **Time to unlock Advanced Bio Generator (requires Level 1000)**: **Stuck / Impossible**
*   **Time to reach DNA Generator Level 2**: **Stuck / Impossible**

---

## 2. Telemetry Analysis

| Metric | Active Play (Measured) | Idle Play (Measured) | Status |
| :--- | :--- | :--- | :--- |
| **Biomass Earn Rate** | ~1,498,083 / hour | ~999,999 / day | **Severe Inflation** |
| **DNA Earn Rate** | ~15,595 / hour | 0 (No combat) | **Balanced** |
| **Biomass Cap Hit** | Yes (within 40 mins) | Yes (within 1 day) | **Overflow Alert** |
| **DNA Cap Hit** | No (Stalls at 2,910) | No (Stalls at 0) | **Progression Lock** |

---

## 3. Economy Issues & Diagnostics

### 1. Unreachable Content Dead Zone (Advanced Bio Generator)
*   **Diagnostic**: The Advanced Bio Generator requires a Bio Generator level of `1000` to unlock (`configs/generators/advanced_bio_generator_config.luau`). However, the Bio Generator config has a `maxLevel` hard cap of `999`. 
*   **Result**: The player can never reach level 1000, rendering the Advanced Bio Generator **permanently locked**.

### 2. Hard Progression Lock (DNA Generator Level 2)
*   **Diagnostic**: The DNA Generator upgrade cost to level 2 is set to `1,000,000` DNA (`configs/generators/dna_generator_config.luau`). However, the DNA currency config (`configs/economy/dna_config.luau`) has a maximum storage capacity `cap` of `999,999`.
*   **Result**: Any attempt to grant DNA beyond `999,999` is rejected by `CurrencyService`, making it mathematically **impossible** to ever afford the Level 2 upgrade.

### 3. Runaway Biomass Inflation (Upgrade Cost Scaling)
*   **Diagnostic**: The Bio Generator rate increases by `baseRate * level` (linear, $+1$/sec per level). The upgrade cost increases by `cost.amount * level` (linear, $+1$ Biomass cost per level).
*   **Result**: The time to acquire the next upgrade remains constant at exactly **1 second** regardless of level. This permits instantaneous level-ups from level 20 to 999, trivializing progression and immediately flooding the player's inventory to the hard cap.

---

## 4. Phase B Rebalancing Recommendations

To resolve these progression locks and balance the economy, the following changes are recommended for Phase B:

1.  **Exponential Cost Scaling**: Update `GeneratorService.luau` to support exponential cost scaling (e.g. `upgradeCostMultiplier = 1.15`). This prevents players from instantly upgrading generators to max levels.
2.  **Align Unlock Requirements**: Lower the Advanced Bio Generator unlock requirement to **Level 50** Bio Generator, and adjust max levels to reasonable progression caps (e.g., `100`).
3.  **DNA Upgrade Alignment**: Lower the DNA Generator level 2 cost to `100` DNA with a multiplier of `1.35`, so it is aligned with DNA earned from combat victories (~50 DNA per win).
4.  **Increase Currency Caps**: Raise both Biomass and DNA storage caps to `9,999,999` to accommodate late-game balances safely.
