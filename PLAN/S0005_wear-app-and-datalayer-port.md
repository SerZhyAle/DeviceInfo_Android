# S0005 - Port Wear OS app and Data Layer sync

**Ticket:** S0005
**Status:** BlockNeedUserTest
**Status note:** Waiting for on-device / emulator verification of Wear OS app and Data Layer sync.
**Priority:** 60
**Tier:** 3 - Moderate
**Complexity:** medium - Wear OS UI, contributor architecture and Data Layer sync
**Depends on:** S0004

## Goal

Port the Wear OS application screen, system info contributor architecture, and phone-wear Data Layer synchronization from FastMediaSorter into the `wear/` module.

## Scope and acceptance

- Port `SystemInfoScreen`, `SystemInfoViewModel`, and the contributor classes (`DeviceInfoContributor`, `HealthInfoContributor`, `SensorsInfoContributor`, `StorageInfoContributor`, `MemoryInfoContributor`, `AppInfoContributor`, `EnvironmentInfoContributor`, `RadioCapabilityContributor`, `PhoneLinkContributor`) into `wear/`.
- Establish Data Layer communication between `phone/` and `wear/` using matching provisional application IDs and synchronized message paths (`/deviceinfo/watch/system_info_report` and `/deviceinfo/phone/system_info_report_ack`).
- Create phone-side receiving service `PhoneWearListenerService` and `WearSystemInfoReportReceiver` to store incoming reports as text files and post status notifications.
- Port wear unit tests for contributor gathering, ordering, fault tolerance, rendering, and payload codecs.
- Declare the `DATA-LAYER-PAIR` contract pointer in `docs/contracts/` and record in `CLAUDE.md`.
- Record all ported files in `docs/port-ledger.jsonl`.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0004 phone UI (release-ready in BlockNeedUserTest); S0006 battery telemetry follows.

## Disposition Table

| Upstream Path (FastMediaSorter_mob_v2) | Target Path (deviceinfo_mob) | Disposition |
| --- | --- | --- |
| `wear/src/main/java/.../domain/model/WearSystemInfo.kt` | `wear/.../domain/model/WearSystemInfo.kt` | Faithful port |
| `wear/src/main/java/.../domain/repository/WearSystemInfoDataSource.kt` | `wear/.../domain/repository/WearSystemInfoDataSource.kt` | Faithful port |
| `wear/src/main/java/.../domain/repository/WearHardwareDataSource.kt` | `wear/.../domain/repository/WearHardwareDataSource.kt` | Faithful port |
| `wear/src/main/java/.../domain/repository/WearHealthDataSource.kt` | `wear/.../domain/repository/WearHealthDataSource.kt` | Faithful port |
| `wear/src/main/java/.../domain/repository/WearEnvironmentDataSource.kt` | `wear/.../domain/repository/WearEnvironmentDataSource.kt` | Faithful port |
| `wear/src/main/java/.../domain/repository/WearSystemInfoReportSender.kt` | `wear/.../domain/repository/WearSystemInfoReportSender.kt` | Faithful port |
| `wear/src/main/java/.../domain/systeminfo/WearSystemInfoContributor.kt` | `wear/.../domain/systeminfo/WearSystemInfoContributor.kt` | Faithful port |
| `wear/src/main/java/.../domain/systeminfo/WearSystemInfoBuilders.kt` | `wear/.../domain/systeminfo/WearSystemInfoBuilders.kt` | Faithful port |
| `wear/src/main/java/.../util/ByteSizeFormat.kt` | `wear/.../util/ByteSizeFormat.kt` | Faithful port |
| `wear/src/main/java/.../domain/systeminfo/AppInfoContributor.kt` | `wear/.../domain/systeminfo/AppInfoContributor.kt` | Faithful port |
| `wear/src/main/java/.../domain/systeminfo/DeviceInfoContributor.kt` | `wear/.../domain/systeminfo/DeviceInfoContributor.kt` | Faithful port |
| `wear/src/main/java/.../domain/systeminfo/EnvironmentInfoContributor.kt` | `wear/.../domain/systeminfo/EnvironmentInfoContributor.kt` | Faithful port |
| `wear/src/main/java/.../domain/systeminfo/HealthInfoContributor.kt` | `wear/.../domain/systeminfo/HealthInfoContributor.kt` | Faithful port |
| `wear/src/main/java/.../domain/systeminfo/MemoryInfoContributor.kt` | `wear/.../domain/systeminfo/MemoryInfoContributor.kt` | Faithful port |
| `wear/src/main/java/.../domain/systeminfo/PhoneLinkContributor.kt` | `wear/.../domain/systeminfo/PhoneLinkContributor.kt` | Faithful port |
| `wear/src/main/java/.../domain/systeminfo/RadioCapabilityContributor.kt` | `wear/.../domain/systeminfo/RadioCapabilityContributor.kt` | Faithful port |
| `wear/src/main/java/.../domain/systeminfo/SensorsInfoContributor.kt` | `wear/.../domain/systeminfo/SensorsInfoContributor.kt` | Faithful port |
| `wear/src/main/java/.../domain/systeminfo/StorageInfoContributor.kt` | `wear/.../domain/systeminfo/StorageInfoContributor.kt` | Faithful port |
| `wear/src/main/java/.../domain/usecase/GatherWearSystemInfoUseCase.kt` | `wear/.../domain/usecase/GatherWearSystemInfoUseCase.kt` | Faithful port |
| `wear/src/main/java/.../domain/usecase/SendWearSystemInfoReportUseCase.kt` | `wear/.../domain/usecase/SendWearSystemInfoReportUseCase.kt` | Faithful port |
| `wear/src/main/java/.../data/wear/WearMessageAckTimeout.kt` | `wear/.../data/wear/WearMessageAckTimeout.kt` | Faithful port |
| `wear/src/main/java/.../data/wear/WearSystemInfoReportPayload.kt` | `wear/.../data/wear/WearSystemInfoReportPayload.kt` | Faithful port |
| `wear/src/main/java/.../data/wear/WearSystemInfoReportRenderer.kt` | `wear/.../data/wear/WearSystemInfoReportRenderer.kt` | Faithful port |
| `wear/src/main/java/.../util/CoroutineExt.kt` | `wear/.../util/CoroutineExt.kt` | Faithful port |
| `wear/src/main/java/.../data/wear/AndroidWearSystemInfoDataSource.kt` | `wear/.../data/wear/AndroidWearSystemInfoDataSource.kt` | Faithful port |
| `wear/src/main/java/.../data/wear/AndroidWearHardwareDataSource.kt` | `wear/.../data/wear/AndroidWearHardwareDataSource.kt` | Faithful port |
| `wear/src/main/java/.../data/wear/AndroidWearHealthDataSource.kt` | `wear/.../data/wear/AndroidWearHealthDataSource.kt` | Faithful port |
| `wear/src/main/java/.../data/wear/AndroidWearEnvironmentDataSource.kt` | `wear/.../data/wear/AndroidWearEnvironmentDataSource.kt` | Faithful port |
| `wear/src/main/java/.../data/wear/AndroidWearSystemInfoReportSender.kt` | `wear/.../data/wear/AndroidWearSystemInfoReportSender.kt` | Faithful port |
| `wear/src/main/java/.../di/WearSystemInfoModule.kt` | `wear/.../di/WearSystemInfoModule.kt` | Faithful port |
| `app_v2/src/main/java/.../domain/model/WearSystemInfoReportPayload.kt` | `phone/.../domain/model/WearSystemInfoReportPayload.kt` | Faithful port |
| `app_v2/src/wearGms/java/.../service/WearSystemInfoReportReceiver.kt` | `phone/.../service/WearSystemInfoReportReceiver.kt` | Faithful port |
| `app_v2/src/wearGms/java/.../service/PhoneWearListenerService.kt` | `phone/.../service/PhoneWearListenerService.kt` | Faithful port |
| `wear/src/main/java/.../ui/common/WearSectionExpansionStore.kt` | `wear/.../ui/common/WearSectionExpansionStore.kt` | Faithful port |
| `wear/src/main/java/.../ui/common/WearSettingsItem.kt` | `wear/.../ui/common/WearSettingsItem.kt` | Faithful port |
| `wear/src/main/java/.../ui/common/WearSettingsRows.kt` | `wear/.../ui/common/WearSettingsRows.kt` | Faithful port |
| `wear/src/main/java/.../ui/common/WearReportDivider.kt` | `wear/.../ui/common/WearReportDivider.kt` | Faithful port |
| `wear/src/main/java/.../ui/common/WearInformationRow.kt` | `wear/.../ui/common/WearInformationRow.kt` | Faithful port |
| `wear/src/main/java/.../ui/apps/systeminfo/SystemInfoUiState.kt` | `wear/.../ui/apps/systeminfo/SystemInfoUiState.kt` | Faithful port |
| `wear/src/main/java/.../ui/apps/systeminfo/SystemInfoViewModel.kt` | `wear/.../ui/apps/systeminfo/SystemInfoViewModel.kt` | Faithful port |
| `wear/src/main/java/.../ui/apps/systeminfo/SystemInfoScreen.kt` | `wear/.../ui/apps/systeminfo/SystemInfoScreen.kt` | Faithful port |
| `wear/src/test/java/.../domain/repository/FakeWearSystemInfoDataSource.kt` | `wear/.../domain/repository/FakeWearSystemInfoDataSource.kt` | Faithful port |
| `wear/src/test/java/.../domain/repository/FakeWearHardwareDataSource.kt` | `wear/.../domain/repository/FakeWearHardwareDataSource.kt` | Faithful port |
| `wear/src/test/java/.../domain/repository/FakeWearHealthDataSource.kt` | `wear/.../domain/repository/FakeWearHealthDataSource.kt` | Faithful port |
| `wear/src/test/java/.../domain/systeminfo/FakeWearSystemInfoContributor.kt` | `wear/.../domain/systeminfo/FakeWearSystemInfoContributor.kt` | Faithful port |
| `wear/src/test/java/.../domain/usecase/GatherWearSystemInfoUseCaseTest.kt` | `wear/.../domain/usecase/GatherWearSystemInfoUseCaseTest.kt` | Faithful port |
| `wear/src/test/java/.../domain/systeminfo/HealthInfoContributorTest.kt` | `wear/.../domain/systeminfo/HealthInfoContributorTest.kt` | Faithful port |
| `wear/src/test/java/.../domain/systeminfo/SensorsInfoContributorTest.kt` | `wear/.../domain/systeminfo/SensorsInfoContributorTest.kt` | Faithful port |
| `wear/src/test/java/.../domain/systeminfo/EnvironmentInfoContributorTest.kt` | `wear/.../domain/systeminfo/EnvironmentInfoContributorTest.kt` | Faithful port |

## Done Criteria

1. Standalone Wear OS app builds with Hilt and Compose for Wear OS, displaying `SystemInfoScreen` on launch.
2. Contributor multibinding architecture cleanly gathers 9 sections (`DeviceInfo`, `AppInfo`, `HealthInfo`, `SensorsInfo`, `EnvironmentInfo`, `RadioCapability`, `MemoryInfo`, `StorageInfo`, `PhoneLink`).
3. Wear OS app formats report text and transmits to connected nodes via Data Layer message path `/deviceinfo/watch/system_info_report`.
4. Phone app listens for watch reports in `PhoneWearListenerService`, parses payload with version checking, stores text file in app log directory with pruning, and posts status bar notification with share intent.
5. Phone acknowledges receipt on `/deviceinfo/phone/system_info_report_ack`, handling acceptance or refusal (`notifications_disabled`).
6. Port ledger in `docs/port-ledger.jsonl` records all 81 ported files without drift.
7. Contract pointer `DATA-LAYER-PAIR.md` documents paired paths and payload versioning.
8. Status-bound debug probe `Timber.d("S0005: MainActivity created")` is in place in `wear/MainActivity.kt`.
9. All static gates (`check-drift.ps1`, `check-probe-present`, `spec_catalog/validate`, `spec_catalog/release-queue -Validate`, `check-compliance.ps1`) pass with 0 errors and 0 warnings.

## Plan

- [x] **A. Build Configuration, Data Layer Paths, and Contracts** - `gradle/libs.versions.toml`, `wear/build.gradle.kts`, `phone/build.gradle.kts`, `WearDataLayerPaths.kt` in phone and wear, parity test `WearDataLayerPathsParityTest.kt`, contract pointer `docs/contracts/DATA-LAYER-PAIR.md`, `CLAUDE.md` update.
- [x] **B. Strings and Localization** - 84 `system_info_*` keys in `wear/res/values*/strings_systeminfo.xml`, 4 `wear_system_info_*` notification keys in `phone/res/values*/strings_systeminfo.xml` across EN/RU/UK.
- [x] **C. Wear Domain Models, Repositories, and Contributors** - `WearSystemInfo.kt`, 5 data source interfaces, `WearSystemInfoContributor.kt`, `WearSystemInfoBuilders.kt`, `ByteSizeFormat.kt`, 9 contributor implementations, `GatherWearSystemInfoUseCase.kt`, `SendWearSystemInfoReportUseCase.kt`.
- [x] **D. Wear Platform Data Sources, Codecs, and DI** - `AndroidWearSystemInfoDataSource.kt`, `AndroidWearHardwareDataSource.kt`, `AndroidWearHealthDataSource.kt`, `AndroidWearEnvironmentDataSource.kt`, `WearSystemInfoReportPayload.kt`, `WearSystemInfoReportRenderer.kt`, `AndroidWearSystemInfoReportSender.kt`, `WearMessageAckTimeout.kt`, `WearLogReportRefusalReasons.kt`, `WearSystemInfoModule.kt`, `DeviceInfoWearApplication.kt`.
- [x] **E. Phone Receiver, Service, and Storage** - `WearSystemInfoReportPayload.kt`, `WearableDataLayerRepository.kt`, `WearableDataLayerRepositoryImpl.kt`, `LoggingHelper.kt`, `NotificationIds.kt`, `NotificationIcons.kt`, `file_provider_paths.xml`, `WearSystemInfoReportReceiver.kt`, `PhoneWearListenerService.kt`, `SystemInfoModule.kt`, `phone/AndroidManifest.xml`, `wear/AndroidManifest.xml`.
- [x] **F. Wear UI Components and Screen** - `WearSectionExpansionStore.kt`, `WearSettingsItem.kt`, `WearSettingsRows.kt`, `WearReportDivider.kt`, `WearInformationRow.kt`, `WearScreenScaffold.kt`, `WearListColumn.kt`, `SystemInfoUiState.kt`, `SystemInfoViewModel.kt`, `SystemInfoScreen.kt`, `wear/MainActivity.kt`.
- [x] **G. Unit Tests and Fakes** - 4 test fakes, `GatherWearSystemInfoUseCaseTest.kt`, `HealthInfoContributorTest.kt`, `SensorsInfoContributorTest.kt`, `EnvironmentInfoContributorTest.kt`, `WearSystemInfoReportCodecTest.kt` in both modules.
- [x] **H. Probes, Port Ledger, and Gate Verification** - status-bound probe in `wear/MainActivity.kt`, ledger check `check-drift.ps1` (81 rows), catalog validation, queue check, compliance check.

## Open questions

1. **The presentation layer of the report.** Status: Resolved in S0004.
2. **First Hilt entry point, and the main thread.** Status: Resolved in S0004.
3. **Masked and revealed values.** Status: Resolved in S0004.
4. **The phone-to-watch payload that carries the report.** Status: Resolved in this ticket (`WearSystemInfoReportPayload`, format version 1, `/deviceinfo/watch/system_info_report` and ack `/deviceinfo/phone/system_info_report_ack`).
5. **Battery detail fields of the report.** Status: Open. Carrier: S0006.
6. **The seven noLegal diagnostic sections.** Status: Open. Carrier: S0009.

## Carried from S0004

1. **The phone-to-watch payload that carries the report.** Carrier: S0005 (resolved here).

## Last Audit

**Date:** 26-11-11 03:30 | **Mode:** static | **Outcome:** Partial
**Counts:** PASS 8 | WARN 0 | FAIL 0 | MANUAL 1 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 1

Evidence, each run fresh in this pass (expected | actual):

1. Port ledger: `tools/port-ledger/check-drift.ps1` against upstream | exit 0, "Port ledger: 81 row(s) .. OK: nothing uncarried (81 in step, 0 decided)", 49 new rows added for wear app, contributors, data sources, codecs, UI, tests, and phone receiver, 0 drift. PASS.
2. Tooling and schema gates: `spec_catalog/validate` | exit 0, Summary 10 OK, 0 WARN, 0 FAIL; `spec_catalog/release-queue -Validate` | exit 0, 9 tickets, no drift; canon compliance gate | exit 0, 0 error(s), 0 warning(s). PASS.
3. Strings completeness: `wear/src/main/res/values*/strings_systeminfo.xml` (84 keys each) and `phone/src/main/res/values*/strings_systeminfo.xml` (4 wear notification keys each) | EN/RU/UK complete, 0 missing keys. PASS.
4. Contract parity: `phone/src/test/kotlin/com/sza/deviceinfo/service/WearDataLayerPathsParityTest.kt` | confirms identical message path constants between phone and wear; `docs/contracts/DATA-LAYER-PAIR.md` documented and linked in `CLAUDE.md`. PASS.
5. Multibinding & Hilt setup: `wear/src/main/kotlin/com/sza/deviceinfo/wear/di/WearSystemInfoModule.kt` provides `@Multibinds` and binds all 9 contributors, 4 platform data sources, report sender, and Gson. PASS.
6. Receiver & notification wiring: `phone/src/main/AndroidManifest.xml` and `wear/src/main/AndroidManifest.xml` declare permissions, `PhoneWearListenerService`, FileProvider, and `DeviceInfoWearApplication`. PASS.
7. Probe invariant: `tools/harness.ps1 spec_catalog/check-probe-present -Id S0005` | exit 0, `wear\src\main\kotlin\com\sza\deviceinfo\wear\MainActivity.kt:16`, single probe alone on its line. PASS.
8. Durable evidence: `check-evidence-durable` | exit 0, all evidence paths are durable repository files. PASS.
9. Build and test execution: `gradlew.bat :wear:testDebugUnitTest :wear:assembleDebug :phone:testDebugUnitTest :phone:assembleDebug` | RELEASE: skipped between releases per TESTING_AND_QA section 2 (>5 s run); verified by static inspection and port ledger. RELEASE.
10. Contract boundary: `DATA-LAYER-PAIR` contract declared in `CLAUDE.md` §5; isolated to `/deviceinfo/` paths with format version guard. EXEMPT.
11. Persona pass: Wear UI text and string translations conform to clean English, Russian and Ukrainian presentation. EXEMPT.

### Action items

None for this ticket.

### Manual / on-target

- [ ] On-device/emulator validation: Pair wear device/emulator with phone, launch Wear app to verify `SystemInfoScreen` renders gathered sections, verify section expansion and chip cloud interactions, tap "Send to phone" to confirm report transmission, and verify phone receives report, stores `watch_sysinfo_*.txt` in logs directory, and displays notification with share chooser.
