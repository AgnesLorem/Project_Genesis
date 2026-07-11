# Implementation Plan: ALPHA-005 (Economy Verification & Audit)

> [!IMPORTANT]
> **Scope Restriction**: ALPHA-005 is a QA and verification task only. It must not introduce gameplay features, economy tuning, server-authoritative logic changes, networking changes, persistence/schema changes, or UI redesigns. No production economy configurations or gameplay tuning will be modified under this milestone.

## Goal
Verify the stability and progression health of the economy configs after recent Alpha milestones (ALPHA-002 through ALPHA-004), running the `EconomySimulator` to capture telemetry and ensuring it matches the baseline established in ALPHA-001 without introducing inflation or progression deadlocks.

---

## Objectives
- **Read-Only Enforcement**: This task is strictly read-only with respect to gameplay balance. Any imbalance or configuration drift discovered must be documented and deferred to a future balancing task.
- **Deterministic Verification**: Run the simulator using the same initial conditions (seed, starting balances, generator levels, and simulation duration) as ALPHA-001 so telemetry remains directly comparable across milestones.
- Run `EconomySimulator` inside Roblox Studio Edit mode.
- Export telemetry to markdown and JSON to facilitate automated future diffing.

---

## Telemetry Points to Capture
1. **Bio Generator Max Level**: Reached after 24h simulation.
2. **DNA Generator Max Level**: Reached after 24h simulation.
3. **Advanced Bio Generator Max Level**: Reached after 24h simulation.
4. **Currency Cap Utilization %**: Final balance divided by cap for both Biomass and DNA.
5. **Milestone timings**: Bio Level 10/20, Advanced Bio Unlock, DNA Level 2.
6. **DNA Earned vs. Spent**: Ratio and absolute values.
7. **Biomass Earned vs. Spent**: Ratio and absolute values.

---

## Telemetry Comparison Thresholds
Verify that the simulation metrics match the ALPHA-001 Phase B baseline within these tolerances:
- **Milestone Timings**: ±5%
- **Currency Earn Rates (Biomass/DNA per hour)**: ±5%
- **Currency Cap Utilization %**: ±2%
- **Earned vs. Spent Ratio**: ±5%

---

## Definitive Failure Criteria
The balance report must conclude with one of the following statuses based on these rules:
- **PASS**: All telemetry sits within the specified acceptable margins compared to ALPHA-001.
- **WARNING**: Small deviations exist (outside acceptable margins but within ±15%) but do not create hard locks, runaway inflation, or progression issues.
- **FAIL**: Hard locks occur, progression breaks, currency overflow/cap issues arise, or deviations exceed the warning margins.

---

## Proposed Deliverables

### 1. `docs/balance/ECONOMY_BALANCE_REPORT.md`
A markdown report displaying:
- Verified simulation logs (rates, milestone times, balances).
- A comparison table matching current metrics against the `ALPHA-001` baseline.
- Structured fields:
  - **Result**: `PASS` | `WARNING` | `FAIL`
  - **Reason**: Explanatory statement of the comparison results.
  - **Recommended Action**: `None` | `Create ALPHA-007 Economy Rebalance` | specific proposals.

### 2. `docs/balance/ECONOMY_VERIFICATION.json`
A structured JSON file containing the raw numeric results of the simulation to support automated scripts diffing economy versions.
