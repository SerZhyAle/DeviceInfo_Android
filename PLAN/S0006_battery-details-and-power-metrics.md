# S0006 - Advanced battery details and power metrics

**Ticket:** S0006
**Status:** BlockNeedUserTest
**Status note:** Waiting for on-device / emulator verification of battery details and power metrics.
**Priority:** 60
**Tier:** 3 - Moderate
**Complexity:** medium - battery telemetry, power profiling, and runtime estimation; assessed at spec pass: porting 4 upstream classes and 1 test, 10 strings in EN/RU/UK, DI binding in SystemInfoModule, and integration into GatherSystemInfoUseCase; low architectural risk with self-contained calculation and fallback logic. Read against the plan: the level stands.
**Depends on:** S0005

## Goal

Implement extended battery details and power profiling in the DeviceInfo application, addressing FastMediaSorter ticket S4529 requirements.

## Scope and acceptance

- Add battery metrics: Charge Speed (current in mA, wattage), Power profile, Nominal profile.
- Provide dynamic calculations: estimated time to full charge and estimated runtime left until switch-off based on current discharge rate.
- Surface these metrics in both phone UI sections and wear glanceable metrics cards.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** FastMediaSorter S4529 is upstream requirement; S0005 wear port; S0007 follows.
- **Parity inventory (CLAUDE.md section 2):** FastMediaSorter S4529 (`BatteryDetailsCollector`, `MetricValue`, `BatteryRuntimeEstimator`, `DischargeRateBatteryRuntimeEstimator`, test suite, and 10 strings) ported with ledger entries in `docs/port-ledger.jsonl`.
- **UI placement contract:** Existing battery section of System Information; unavailable measurements displayed with clear fallback.
- **Locales:** EN, RU, and UK authored per LOCALIZATION rule 1; remaining locales follow release boundary.
- **Performance budget:** No persistent background sampling; runtime estimator updates only on level changes.

## Spec pass (2026-11-11)

- **Rung:** complex pipeline. Forced upward by the primitive test: multiple new source and test files, new public interfaces and types, DI module wiring, string resources in 3 locales.
- **Entry state:** Blocker S0005 reached `BlockNeedUserTest` (journal, 2026-11-11 03:31), releasing this ticket. The lease is held by this session under reason `run-spec-queue`.
- **Fresh upstream inventory** (CLAUDE.md section 2, rule 2; read 2026-11-11 from `P:\ANDROID\FastMediaSorter_mob_v2`, read-only). Upstream S4529 status is `BlockNeedUserTest`. Disposition:

| Upstream Path (FastMediaSorter_mob_v2) | Target Path (deviceinfo_mob) | Disposition |
| --- | --- | --- |
| `app_v2/.../domain/model/devicestatus/MetricValue.kt` | `phone/.../domain/model/devicestatus/MetricValue.kt` | Faithful port |
| `app_v2/.../domain/repository/BatteryRuntimeEstimator.kt` | `phone/.../domain/repository/BatteryRuntimeEstimator.kt` | Faithful port |
| `app_v2/.../data/repository/DischargeRateBatteryRuntimeEstimator.kt` | `phone/.../data/repository/DischargeRateBatteryRuntimeEstimator.kt` | Faithful port |
| `app_v2/.../core/systeminfo/BatteryDetailsCollector.kt` | `phone/.../core/systeminfo/BatteryDetailsCollector.kt` | Ported with package update and status-bound debug probe |
| `app_v2/.../data/repository/DischargeRateBatteryRuntimeEstimatorTest.kt` | `phone/.../data/repository/DischargeRateBatteryRuntimeEstimatorTest.kt` | Faithful port |

- **Differences from upstream, each recorded next to the code it concerns:**
  1. `BatteryDetailsCollector`: Upstream probe `Timber.d("S4529: battery details read")` replaced by status-bound probe `Timber.d("S0006: battery details read")` per Rule 2 probe invariant.
  2. Wear OS battery scope: FastMediaSorter S4529 touched only phone (`app_v2`). The wear app in `wear/` already possesses full parity with upstream via `HealthInfoContributor` (thermal state, battery temperature, voltage, charge counter, and doze exemption).
  3. String keys: Renamed `sysinfo_field_battery_capacity_estimate` and 9 related keys added to `phone/res/values*/strings_systeminfo.xml` in EN, RU, and UK.
- **Settled without asking:**
  1. DI binding: `BatteryRuntimeEstimator` bound to `DischargeRateBatteryRuntimeEstimator` as `@Singleton` in `SystemInfoModule`.
  2. Fallback strings: When battery intent is unavailable or readings are missing, report rows display localized `Unavailable` (`sysinfo_battery_unavailable`).
  3. Shared contracts: No external wire contract modified; internal device info domain model enhancement.

## Done criteria

1. Port ledger `docs/port-ledger.jsonl` records all 5 ported files; `tools/port-ledger/check-drift.ps1` exits 0 with 0 drift.
2. String resources in `values/strings_systeminfo.xml`, `values-ru/strings_systeminfo.xml`, and `values-uk/strings_systeminfo.xml` contain all 117 matching keys (10 battery keys added with 0 missing keys).
3. `MetricValue.kt`, `BatteryRuntimeEstimator.kt`, and `DischargeRateBatteryRuntimeEstimator.kt` ported to `phone/`.
4. `BatteryDetailsCollector.kt` ported to `phone/` and wired in `GatherSystemInfoUseCase.kt` to present current, power, saver, capacity estimate, charge time, and discharge time.
5. `SystemInfoModule.kt` provides `@Binds @Singleton` for `BatteryRuntimeEstimator`.
6. Unit tests: `DischargeRateBatteryRuntimeEstimatorTest` ported and passing; `GatherSystemInfoUseCaseTest` updated with battery detail assertions.
7. Status-bound debug probe `Timber.d("S0006: battery details read")` present in `phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/BatteryDetailsCollector.kt:22`.
8. Static gates (`tools/port-ledger/check-drift.ps1`, `tools/harness.ps1 spec_catalog/validate`, `tools/harness.ps1 spec_catalog/release-queue -Validate`, `tools/check-compliance.ps1`, `tools/harness.ps1 spec_catalog/check-probe-present -Id S0006`, `tools/harness.ps1 spec_catalog/check-evidence-durable -Id S0006`) all pass with 0 errors and 0 warnings.

## Plan

Coverage inventory:
- Add battery metrics (current, power, saver, capacity estimate) -> Phases A, B, C, D.
- Dynamic calculations (charge time, discharge runtime estimation) -> Phases B, C, D.
- Surface metrics in phone UI and maintain wear parity -> Phases A, D.
- Unit tests and test updates -> Phases B, D.
- Verification and gates -> Phase E.

Produces/consumes:
- Phase A produces string resources in EN, RU, and UK.
- Phase B consumes upstream and produces domain and data estimator classes.
- Phase C consumes B and produces `BatteryDetailsCollector` and DI bindings in `SystemInfoModule`.
- Phase D consumes A, B, C and produces updated `GatherSystemInfoUseCase`, updated use case tests, and ported estimator tests.
- Phase E consumes all and produces port ledger records, static gate passes, and audit verdict.

- [x] **A. Strings and Localization** - `phone/src/main/res/values/strings_systeminfo.xml`, `values-ru/strings_systeminfo.xml`, `values-uk/strings_systeminfo.xml` (10 keys each across EN/RU/UK).
- [x] **B. Domain Models and Repository Estimator** - `MetricValue.kt`, `BatteryRuntimeEstimator.kt`, `DischargeRateBatteryRuntimeEstimator.kt`, port ledger records.
- [x] **C. Collector and DI Wiring** - `BatteryDetailsCollector.kt`, `SystemInfoModule.kt` (`bindBatteryRuntimeEstimator`), port ledger records.
- [x] **D. Use Case Integration and Unit Tests** - `GatherSystemInfoUseCase.kt`, `GatherSystemInfoUseCaseTest.kt`, `SystemInfoReportContractTest.kt`, `DischargeRateBatteryRuntimeEstimatorTest.kt`, port ledger records.
- [x] **E. Probes, Port Ledger, and Gate Verification** - status-bound probe in `BatteryDetailsCollector.kt`, `check-drift.ps1` (86 rows), catalog validation, queue check, compliance check.

## Open questions

1. **The battery detail seam of the phone report.** Status: Resolved in this ticket (`BatteryDetailsCollector` ported, 6 fields surfaced in battery section with fallbacks).
2. **The seven noLegal diagnostic sections.** Status: Open. Carrier: S0009.
3. **Parity and device check.** Status: Open. Carrier: S0007.

## Carried from S0003

1. **The battery detail seam of the phone report.** Carrier: S0006 (resolved here).

## Last Audit

**Date:** 26-11-11 03:50 | **Mode:** static | **Outcome:** Partial
**Counts:** PASS 7 | WARN 0 | FAIL 0 | MANUAL 1 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 1

Evidence, each run fresh in this pass (expected | actual):

1. Port ledger: `tools/port-ledger/check-drift.ps1` against upstream | exit 0, "Port ledger: 86 row(s) .. OK: nothing uncarried (86 in step, 0 decided)", 5 new rows added for battery metrics and tests, 0 drift. PASS.
2. Tooling and schema gates: `spec_catalog/validate` | exit 0, Summary 10 OK, 0 WARN, 0 FAIL; `spec_catalog/release-queue -Validate` | exit 0, 9 tickets, no drift; canon compliance gate | exit 0, 0 error(s), 0 warning(s). PASS.
3. Strings completeness: `phone/src/main/res/values*/strings_systeminfo.xml` (117 keys each) | EN/RU/UK complete, 0 missing keys, 0 locale differences. PASS.
4. Multibinding & Hilt setup: `phone/src/main/kotlin/com/sza/deviceinfo/di/SystemInfoModule.kt` binds `BatteryRuntimeEstimator` to `DischargeRateBatteryRuntimeEstimator`. PASS.
5. Probe invariant: `tools/harness.ps1 spec_catalog/check-probe-present -Id S0006` | exit 0, `phone\src\main\kotlin\com\sza\deviceinfo\core\systeminfo\BatteryDetailsCollector.kt:22`, probe alone on its line. PASS.
6. Durable evidence: `tools/harness.ps1 spec_catalog/check-evidence-durable -Id S0006` | exit 0, all evidence paths are durable repository files. PASS.
7. Use case integration: `GatherSystemInfoUseCase.kt` injects `BatteryDetailsCollector` and formats 6 battery detail fields (current, power, saver, capacity estimate, charge time, discharge time) with safe fallbacks; tests updated. PASS.
8. Build and test execution: `gradlew.bat :phone:testDebugUnitTest :phone:assembleDebug` | RELEASE: skipped between releases per TESTING_AND_QA section 2 (>5 s run); verified by static inspection and port ledger. RELEASE.
9. Contract boundary: no external wire format or catalog contract mutated. EXEMPT.
10. Persona pass: battery detail strings in EN, RU and UK adhere to clean, jargon-free presentation. EXEMPT.

### Action items

None for this ticket.

### Manual / on-target

- [ ] On-device/emulator validation: Check battery details on phone device/emulator in System Information (current in mA, power in W, battery saver state, estimated capacity in mAh, time to full charge while charging, estimated time remaining while discharging, and unavailable fallbacks).
