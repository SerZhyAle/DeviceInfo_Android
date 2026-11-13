# S0003 - Port core domain models and info collectors

**Ticket:** S0003
**Status:** Verified
**Priority:** 65
**Tier:** 3 - Moderate
**Complexity:** medium - assessed at the spec pass: thirteen mechanical source ports (about 1 400 lines of upstream Kotlin), three ported tests, one string set in three locales and the port-ledger tooling that CLAUDE.md section 2 asks this ticket to decide; the risks are the new build rig (Hilt, KSP, Robolectric on this machine) and a clean seam to the battery work, not algorithmic difficulty. Read against the plan: the level stands.
**Depends on:** S0002

## Goal

Port the core device information domain models, collectors, and report generators from FastMediaSorter into the standalone project with full behavioural parity and test coverage.

## Scope and acceptance

- Port `SystemInfoReport`, `SystemInfoGroup`, `ExtendedDiagnostics`, and `GatherSystemInfoUseCase` from FastMediaSorter into `phone/`.
- Ensure clean package re-rooting (`com.sza.fastmediasorter` -> `com.sza.deviceinfo`) with all FastMediaSorter-specific dependencies removed.
- Port accompanying unit tests to guarantee verified parity.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0002 skeleton (Verified); S0004 follows. Carried out of this ticket, each by a literal token below: S0006 (battery detail fields), S0009 (the seven noLegal diagnostic sections), S0004 (every screen, helper and string of the presentation), S0005 (the wear payload and the wear module).
- **Parity inventory form (CLAUDE.md section 2, rule 3):** a committed port ledger, `docs/port-ledger.jsonl`, one row per ported file (upstream path, upstream SHA-256 at port time, destination, port date, optional carry date and pinned decision), and a drift check that re-hashes every upstream source and exits non-zero on an uncarried change. The shape is the one StreamsPlayer_mob and Tourist_mob keep; the scripts are written here, not copied. The ledger holds only files that were ported; what was left out, and why, lives in the disposition table below, which S0007 re-reads.
- **Dependency injection:** Hilt, as upstream. The ported classes keep their `@Inject` constructors and `@ApplicationContext` parameters; the toolchain pins (Hilt 2.59, KSP 2.3.8, Timber 5.0.1, JUnit 4.13.2, Robolectric 4.16.1) and the two Windows workarounds (`android.disallowKotlinSourceSets=false`, `ksp.incremental=false`) are the working set Tourist_mob builds with on this toolchain and this machine.
- **Locales:** EN, RU and UK, the strict set of LOCALIZATION section 1; the upstream RU and UK texts are ported, the further languages of upstream fan out at the release boundary.

## Spec pass (2026-11-10)

- **Rung:** complex pipeline. Forced upward by the primitive test: far more than three files, new public types, new DI wiring, a new Application class.
- **Entry state:** the blocker S0002 is Verified (journal, 2026-11-10 22:35), so `BlockByOtherTask` cleared and the ticket went back to `Draft` (no plan, owner inputs unfilled). The lease is held by this session under reason `run-spec-queue pq1`.
- **Fresh upstream inventory** (CLAUDE.md section 2, rule 2; read 2026-11-10 from `P:\ANDROID\FastMediaSorter_mob_v2`, read-only). Disposition of every class found on the System info path:

| Upstream (app_v2 unless noted) | Disposition |
| --- | --- |
| `core/systeminfo/SystemInfoGroup`, `SystemInfoSection` (with `renderSystemInfo`), `SystemInfoReport`, `ExtendedDiagnostics` (field, section, contributor, `REDACTED`, `toSystemInfoSections`), `SystemInfoAccessClassifier`, `SystemInfoBenchmark`, `CameraActiveArrayText` | ported here (7 files) |
| `domain/model/CameraHardwareInventory` (entry and inventory), `data/capture/CameraHardwareDataSource`, `domain/usecase/GatherCameraDiagnosticsUseCase` | ported here (3 files); the data source keeps `read()` only, `hasAnyCamera` and `isCameraPermissionGranted` serve the capture screen and have no caller on this path; package `data/camera` instead of `data/capture`, because DeviceInfo has no capture |
| `domain/usecase/GatherSystemInfoUseCase` | ported here with three recorded differences (below) |
| `util/PackageManagerCompat` | ported here, `getPackageInfoCompat` only; the other two helpers have no caller on this path |
| `di/ExtendedDiagnosticsModule` (the `@Multibinds` declaration that makes the empty set injectable) | ported here |
| tests `GatherSystemInfoUseCaseTest` (5), `CameraActiveArrayTextTest` (3), `SystemInfoBenchmarkTest` (2) | ported here (10 tests) |
| `core/systeminfo/BatteryDetailsCollector` and its data class, `domain/model/devicestatus/MetricValue`, `domain/repository/BatteryRuntimeEstimator`, `data/repository/DischargeRateBatteryRuntimeEstimator`, the ten battery detail strings | left for S0006 (Carrier below) |
| `noLegal/diagnostics/NoLegalExtendedDiagnosticsContributor`, `NoLegalDiagnosticsCollectors`, `noLegal/di/NoLegalExtendedDiagnosticsModule`, `core/xr/XrEnvironmentDetector`, the seven `nolegal_diag_section_*` strings | left for S0009 (owner decision; Carrier below) |
| `ui/systeminfo/**` (`SystemInfoActivity`, `SystemInfoAdapter`, `SystemInfoListItem`, `SystemInfoGroupIcons`, `SystemInfoExpansionState` and its test, `SystemInfoDialogManager`, `SystemInfoWindowManager`), `domain/repository/SystemInfoGroupStateRepository` and its implementation, `core/di/SystemInfoModule`, the search, action and toast strings | S0004 (presentation; its scope names the activity, adapter and dialog manager, the rest of the group is for its own fresh inventory) |
| `domain/model/WearSystemInfoReportPayload` (with codec and ack), `wearGms/service/WearSystemInfoReportReceiver`, every class of the `wear` module | S0005 |

- **Differences from upstream, each recorded next to the code it concerns:** (1) `GatherSystemInfoUseCase` loses its `BatteryDetailsCollector` constructor argument and the battery fields that read it, so its battery section carries the seven fields read from the sticky battery broadcast (level, status, power source, health, temperature, voltage, technology); S0006 gives the collector, its estimator and the six detail fields back, in one edit with their strings. (2) The `appCameraView` parameter and its `camera_app_view` row are dropped: they carry the capture screen's own reading of the camera tree and DeviceInfo has no capture screen. (3) The `Edition` row (`BuildConfig.FLAVOR`) is dropped: DeviceInfo declares no product flavor, so the row would be blank. (4) The Ukrainian text of `sysinfo_field_wide_gamut` is corrected from the ungrammatical `Широкий колірний охоплення` to `Широке колірне охоплення`. (5) The ledger records no row for a string file: strings are ported by key selection from two upstream files that change for unrelated keys, so a file hash would be noise.
- **Settled without asking** (the records answer them): the DI framework and every pin (Tourist_mob, same toolchain; upstream uses Hilt); the package re-root (the task says so); the module the code lands in (`phone/`, the task says so); the locale set (LOCALIZATION section 1); the permission surface - the code reads the connectivity state, which needs `ACCESS_NETWORK_STATE` (upstream declares it), and nothing else needs a permission (own-package queries, Camera2 characteristics, system settings reads and the sticky battery broadcast are open; the owner-only reads throw `SecurityException`, which the ported classifier turns into `unknown`); the test rig (the upstream tests run under Robolectric on API 34, whose android-all jar is already in the local cache); no flavor dimension.
- **Boundary with later tickets:** no screen, no adapter, no Data Layer, no battery detail, no seven-section contributor. The launcher activity keeps showing the product name, so nothing here claims a ported screen; the report is proven by tests, not by a screen (S0004 shows it, S0007 runs it on devices).
- **Contract boundary:** none. The report text is read by no other product and the catalog has no row for it; the Data Layer payload that carries it to the watch is S0005's boundary question.
- **Unattended pass:** nobody answers questions here. The one real owner fork found (the seven sections) is a ticket of its own, S0009, in `BlockQuestions`; it does not block this port.
- **Between releases nothing above 5 seconds runs.** CLAUDE.md section 6 orders this ticket to declare the first test's fast filter and its measured time, so one measuring run of the unit tests and the debug build (cold, then warm) is the run the owner named; nothing else above 5 s runs (no lint, no release variant, no repeated suites).

## Done criteria

Each is a command to run or a file to read.

1. `tools/port-ledger/test-port-ledger.ps1` exits 0 and its output shows each state the check can report (in step, decided, DRIFT, SOURCE GONE, NO DEST) detected on a throw-away tree; `tools/port-ledger/check-drift.ps1` exits 0 against the real upstream with one ledger row per ported file (16: 13 sources and 3 tests) and every destination present.
2. `gradlew.bat :phone:testDebugUnitTest :phone:assembleDebug :wear:assembleDebug` from the root exits 0 with `BUILD SUCCESSFUL`; the test result files of the phone module show the 10 ported tests and the added contract tests passing, 0 failures, 0 skipped.
3. Independence: no `fastmediasorter` or `FastMediaSorter` reference in `phone/` outside comments, no `includeBuild`, the build ran from this root; the only upstream-path text in the tree is the ledger and the ticket records.
4. Every `R.string.sysinfo_*` the ported code reads exists in `values`, `values-ru` and `values-uk`, and the three files carry the same key set (a script or a count, run fresh).
5. The manifest declares exactly one new permission, `ACCESS_NETWORK_STATE`, with its one-sentence justification recorded in this record; no signing configuration, no `applicationIdSuffix`, the application id still declared in one place.
6. The phone debug APK still starts on a device or an emulator under the Hilt application class (the change touches startup), or the missing device is recorded as an open check of S0007, never a pass.
7. `CLAUDE.md` section 5 names `docs/port-ledger.jsonl` and `tools/port-ledger/`; section 6 records the test command, its cold and warm times measured here and the fast/release split; `PLAN/S0006_battery-details-and-power-metrics.md` carries the battery seam.
8. `spec_catalog/validate` and `spec_catalog/release-queue -Validate` exit 0; the canon compliance gate exits 0 with 0 errors; no command of this pass wrote under `P:\ANDROID\FastMediaSorter_mob_v2`.

## Plan

Coverage inventory - Goal (domain models, collectors, report generators ported with parity and tests) -> phases C to F and G; scope bullet 1 (`SystemInfoReport`, `SystemInfoGroup`, `ExtendedDiagnostics`, `GatherSystemInfoUseCase`) -> C and F; bullet 2 (re-root, FastMediaSorter-specific dependencies removed) -> C to F and criterion 3; bullet 3 (tests) -> G; constraint "port, do not rewrite, record a deliberate difference next to the code" -> the differences list above and a comment at each place; constraint "re-inventory before any parity claim" -> the spec-pass table; constraint "decide the form of the parity inventory" -> owner inputs and phase A; constraint "no device claim without a device" -> H criterion 6; constraint "upstream is read-only" -> criterion 8. Out-of-scope: every screen and string of the presentation (S0004), the wear module and payload (S0005), battery details (S0006), the seven noLegal sections (S0009), any release variant, minification or lint run (S0008, nothing above 5 s between releases), the parity claim itself (S0007).

Produces/consumes - A produces the ledger tooling; B produces the toolchain and the Hilt application; C consumes B and produces the model and helper files; D consumes C and produces the camera collectors; E produces the strings; F consumes C, D and E and produces the use case; G consumes C to F and produces the tests; H consumes all of them and produces the measured times; I consumes H. No phase consumes what a later one produces; A is first because a ported file is recorded the moment it exists.

- [x] **A. Port ledger tooling** - files: `tools/port-ledger/_ledger.ps1`, `record-port.ps1`, `check-drift.ps1`, `test-port-ledger.ps1`, `README.md`. Check: each script parses and exits per its header; `test-port-ledger.ps1` exits 0 with the five states shown.
- [x] **B. Toolchain and Hilt application** - files: `gradle/libs.versions.toml`, `build.gradle.kts`, `gradle.properties` (the two workarounds), `phone/build.gradle.kts`, `phone/src/main/AndroidManifest.xml`, `phone/src/main/kotlin/com/sza/deviceinfo/DeviceInfoApplication.kt`, `phone/src/main/kotlin/com/sza/deviceinfo/di/ExtendedDiagnosticsModule.kt`. Check: each file exists; every new catalog alias has a use line in a build file; the wear module is untouched.
- [x] **C. Core model and helpers** - files: `core/systeminfo/` `SystemInfoGroup.kt`, `SystemInfoSection.kt`, `SystemInfoReport.kt`, `ExtendedDiagnostics.kt`, `SystemInfoAccessClassifier.kt`, `SystemInfoBenchmark.kt`, `CameraActiveArrayText.kt`, and `util/PackageManagerCompat.kt`, all under `phone/src/main/kotlin/com/sza/deviceinfo/`; one ledger row each right after the file exists. Check: each file exists with the re-rooted package; no `fastmediasorter` reference; the ledger has the row.
- [x] **D. Camera collectors** - files: `domain/model/CameraHardwareInventory.kt`, `data/camera/CameraHardwareDataSource.kt`, `domain/usecase/GatherCameraDiagnosticsUseCase.kt`; ledger rows. Check: as C.
- [x] **E. Strings** - files: `phone/src/main/res/values/strings_systeminfo.xml`, `values-ru/strings_systeminfo.xml`, `values-uk/strings_systeminfo.xml`, carrying the keys the code of C to F reads and no other. Check: the three files hold the same key set, and every `R.string.sysinfo_*` of the code is in it.
- [x] **F. The use case** - files: `domain/usecase/GatherSystemInfoUseCase.kt`; ledger row. Check: as C; the three recorded differences are each a comment at their place.
- [x] **G. Tests** - files: under `phone/src/test/kotlin/com/sza/deviceinfo/`: `domain/usecase/GatherSystemInfoUseCaseTest.kt`, `core/systeminfo/CameraActiveArrayTextTest.kt`, `core/systeminfo/SystemInfoBenchmarkTest.kt` (ported, ledger rows), and `core/systeminfo/SystemInfoReportContractTest.kt` (added: masked against full text, `hasSensitive`, the empty-section skip and the access classifier, with a fake contributor, because the upstream tests never reach the extended path). Check: each file exists; 10 ported tests plus the added ones are counted by a grep of the test annotations.
- [x] **H. Build, tests and evidence** - run under the Build lock, in order: the unit tests with the debug builds (cold), the same again (warm), the drift check, the independence and permission greps, the strings key-set check, the launch check on a device or emulator if one is available. Phase-boundary audit of A to G before this step (static). Check: criteria 1 to 6 and 8.
- [x] **I. Records** - files: `CLAUDE.md` (sections 5 and 6), `PLAN/S0006_battery-details-and-power-metrics.md` (carried battery seam). Check: criteria 7 and 8.

Read against the plan: the level stands, no decision is hidden in it.

## Open questions

1. **Battery detail fields of the report (current, power, saver, estimated capacity, time to full charge, time remaining) and the collector, estimator and strings behind them.** Status: Open. Left out of this port on purpose, so S0006 owns the S4529 inventory in one piece and no half of it lands here. Carrier: S0006
2. **The seven noLegal diagnostic sections (OS and security, permissions, installer and signature, runtimes, mounts, network diagnostics, process resources).** Status: Open. Owner decision on whether, where and in what form; the contract they plug into is ported here and unused until then. Carrier: S0009
3. **Presentation of the report: screen, adapter, expanded-state memory, copy and share, masked-value reveal.** Status: Open. Not this ticket's scope. Carrier: S0004
4. **The phone-to-watch payload that carries the report.** Status: Open. Not this ticket's scope. Carrier: S0005
5. **Which DI framework, which test rig, which locale set, which permissions?** Status: Resolved without asking - see Settled without asking above.

## Last Audit

**Date:** 26-11-10 23:05 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 11 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 1 | EXEMPT 4 | RELEASE 0

Evidence, each run fresh in this pass (expected | actual):

1. Port ledger tooling: `tools/port-ledger/test-port-ledger.ps1` walks one row through in step, DRIFT, decided, DRIFT again, carried, SOURCE GONE and NO DEST and checks exits 0, 1 and 2 | exit 0, 16 expectations held, 4.97 s wall; `tools/port-ledger/check-drift.ps1` against the real upstream | exit 0, "16 row(s) .. OK: nothing uncarried (16 in step, 0 decided)", 0.37 s, 13 sources and 3 tests, every destination present. PASS.
2. Build and tests, `gradlew.bat :phone:testDebugUnitTest :phone:assembleDebug :wear:assembleDebug` from the root under the Build lock: exit 0, `BUILD SUCCESSFUL`, 0 failures | exit 0, "BUILD SUCCESSFUL in 46s", 90 tasks executed, 46.6 s wall, 0 compiler warnings; result reports of the phone module: `CameraActiveArrayTextTest` 3, `SystemInfoBenchmarkTest` 2, `GatherSystemInfoUseCaseTest` 5, `SystemInfoReportContractTest` 7 = 17 tests (10 ported, 7 added), 0 failures, 0 errors, 0 skipped. Re-run with nothing changed | "BUILD SUCCESSFUL in 1s", 90 up-to-date, 2.0 s wall; filtered `--tests` on one class | 2.3 s wall, 1 task executed. This is the one measuring run CLAUDE.md section 6 orders; no lint and no release variant ran. PASS.
3. Badging of both debug APKs (`aapt2 dump badging`): one package name, the sentinel pair, the watch feature in the wear APK only, one new permission in the phone APK | package `com.sza.deviceinfo.provisional` in both, versionName `2.61.1100.000`, versionCode `261110000` (phone) and `261110006` (wear), `android.hardware.type.watch` in the wear APK only, `ACCESS_NETWORK_STATE` in the phone APK; the only other entry is the `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` signature permission that AndroidX adds to every app (the wear APK carries it too). The justification of the one declared permission, for the permission list S0008 owns: it lets the Network section of the report say whether the device is online, on Wi-Fi or mobile data, metered or behind a VPN. PASS.
4. Independence: no `fastmediasorter` reference outside comments, no `includeBuild`, no signing configuration, keystore or `applicationIdSuffix` in code, no `LICENSE`, no `.git`, the application id declared once | the search over `phone/` found two hits, both comments naming the original; no hit for the other terms; the id literal appears once (`gradle.properties`); no long dash or ellipsis character in the code and scripts written; no upstream path in the tree outside the ledger, its scripts and the ticket records. PASS.
5. Strings: the three locale files carry the same key set and the code reads exactly it | 84 keys in `values`, `values-ru` and `values-uk`, 0 keys differ between locales, 84 distinct `R.string.sysinfo_*` referenced by the code, 0 referenced and undefined, 0 defined and unreferenced. PASS.
6. Launch on a device, phone, under the new Hilt application class (the change touches startup): install, start, observe | emulator API 33: `Success`, `Status: ok`, `LaunchState: COLD`, resumed activity `com.sza.deviceinfo.MainActivity`, on-screen text "DeviceInfo", process alive, 0 lines in the crash buffer, 0 fatal entries; app uninstalled afterwards, 0 `com.sza` packages left on that device. A second running emulator held a sibling product in the foreground and was not touched. PASS. Not covered, and not claimed: real hardware, other API levels, the report shown on a screen (S0004 builds it), the report values on a device (S0007).
7. Records: `CLAUDE.md` sections 2, 5 and 6 | section 2 states the ledger form decided here, section 5 names the ledger, the tools and the Hilt application, section 6 carries the test command, the three measured times, the 17 tests and the fast filter with its validity limit; `PLAN/S0006_battery-details-and-power-metrics.md` carries the battery seam, `PLAN/S0004_phone-ui-presentation-port.md` three carried items, `PLAN/S0009_extended-diagnostics-sections.md` the owner question. PASS.
8. Gates: `spec_catalog/validate` | exit 0, Summary 10 OK, 0 WARN, 0 FAIL; `release-queue -Validate` | exit 0, "OK - 9 ticket(s), no drift"; compliance gate from the installed plugin | exit 0, 0 error(s), 1 warning(s); durable-evidence check | exit 0, no load-bearing evidence under the scratch folder. PASS.
9. Probe invariant | `check-probe-absent` exit 0, "No probe of this ticket remains in source"; the ticket is not in the needs-manual-test status. PASS.
10. Scope purity: every file written is in the plan: the ledger tools and `docs/port-ledger.jsonl`, the root Gradle files and `gradle.properties`, `gradle/libs.versions.toml`, `phone/` (build file, manifest, the Application class, the ported sources, strings, tests), `CLAUDE.md`, this record and the carried-items sections of S0004 and S0006; one finding parked as `parked: S0009` (the seven noLegal diagnostic sections, owner decision, `BlockQuestions`); the active ticket never switched; scratch stayed in the ignored scratch folder; the upstream checkout was only read (the ledger tools hash it, nothing writes there). Deviations from the plan: none. PASS.
11. Hygiene on the diff: comments state reasons and the five recorded differences, none restates a line; the broad catches are the upstream's `safe` and `safeList`, each with a safe default and a correctly levelled Timber log; logging goes only through Timber; no colour literal, no stub, no ticket id in a log line; unused imports 0 (no compiler warning). PASS.
12. Hilt graph resolution of `GatherSystemInfoUseCase`. UNCHECKABLE: nothing requests the use case yet, so Dagger validates the annotated classes and the `@Multibinds` module (KSP and Hilt compile steps green in item 2) but not the graph; the first entry point is S0004's activity (Carrier below, item 2 of its carried list).
13. Contract boundary. EXEMPT: the report text is read by no other product and the catalog has no row for it; the Data Layer payload is S0005's boundary question.
14. Release variant, minification and lint. EXEMPT: out-of-scope, none is declared; S0008 declares and builds the release variant, and R8 over the Hilt and reflection paths is proven there. No release command is named because none exists.
15. Persona pass. EXEMPT: the only user-visible text is the product name on the launcher; the report has no screen until S0004.
16. Installed-plugin warning `SZA-CANON06` (the contrib record resolves from the canon checkout, not from the installed plugin). EXEMPT: carried unchanged from S0001, closed by the canon repository publishing the record.

### Action items

None for this ticket. Carried, each with its carrier in the open questions: battery detail fields (S0006), the seven noLegal sections (S0009, owner decision), presentation, the first Hilt entry point and the off-main-thread call of the use case (S0004), the phone-to-watch payload (S0005), the report on real devices (S0007).

### Manual / on-target

None open.