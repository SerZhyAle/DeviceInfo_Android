# S0010 - Extended device info metrics, Sensors, and Media & Audio sections (FastMediaSorter S4543 port)

**Ticket:** S0010
**Status:** Partial
**Status note:** Scope lines 1, 2 and the public sensors part of line 3 are written (no compile command declared: compiled no, tested no, RELEASE items in the audit); ledger carried 2026-11-12 after upstream GatherSystemInfoUseCase drift. The seven noLegal sections of line 3 wait for the owner's build decision in S0009. Blocker: S0009
**Priority:** 55
**Tier:** 3 - Moderate
**Complexity:** medium (confirmed at the plan pass 2026-11-12) - porting extended device info collectors (`PlatformDetailsCollector`, `SensorsDiagnosticsCollector`, `MediaAudioDiagnosticsCollector`), expanded `BatteryDetailsCollector`, `SystemInfoBenchmark` CPU tests, `CameraHardwareDataSource` fields, and 83 localized strings in EN/RU/UK from FastMediaSorter S4543
**Depends on:** S0006

## Goal

Port all new device information metrics and the two new collapsible sections (`Sensors` and `Media & Audio`) implemented in FastMediaSorter ticket S4543 into the standalone `deviceinfo_mob` application.

## Scope and acceptance

1. **New collapsible sections (`SystemInfoGroup` + `SystemInfoGroupIcons`)**:
   - `SENSORS("sensors")` (`R.drawable.ic_compass`, `R.string.sysinfo_section_sensors`): total sensor count, key sensor presence (`Accelerometer`, `Gyroscope`, `Magnetometer`, `Barometer`, `Light`, `Proximity`, `Step counter`, `Hinge angle`), bounded snapshot of ambient light (lx), atmospheric pressure (hPa), and magnetic field (uT), plus hardware sensor list with vendor and mA power draw (`SensorsDiagnosticsCollector`).
   - `MEDIA_AUDIO("media_audio")` (`R.drawable.ic_audio`, `R.string.sysinfo_section_media_audio`): Widevine DRM security level (L1/L3), version and vendor, hardware vs software video codecs (`AVC`, `HEVC`, `VP9`, `AV1`, `Dolby Vision`), active audio outputs, ringer mode, audio capabilities (`Low-latency`, `Pro audio`, `MIDI`, `Spatial audio`), and native output sample rate / buffer size (`MediaAudioDiagnosticsCollector`).
2. **Extended metrics in all 15 existing sections (`PlatformDetailsCollector` + existing collectors)**:
   - `DEVICE`: Brand, Board, Hardware, Baseband/Radio version, SKU / ODM SKU, Form factor (Phone / Tablet / TV / Watch / Automotive / PC).
   - `USER`: System user, Work/managed profile, Storage unlocked.
   - `OS`: Codename, Incremental build, Media performance class, Java VM version, Google Play services version, Vulkan hardware version & level.
   - `APP`: Package name, Target / Min SDK, App standby bucket, Last process exit reason (`ApplicationExitInfo`), App / Data / Cache storage size (`StorageStatsManager`).
   - `HARDWARE`: CPU core frequency ranges (MHz), Thermal status & Thermal headroom, Hardware feature flags (`NFC`, `BLE`, `USB Host`, `Wi-Fi Direct`, `Fingerprint`, `UWB`, `StrongBox`).
   - `CAMERAS` (`CameraHardwareInventory`, `CameraHardwareDataSource`, `GatherCameraDiagnosticsUseCase`): Camera2 hardware level (`LEGACY`/`LIMITED`/`FULL`/`LEVEL_3`/`EXTERNAL`), apertures (`f/..`), flash availability, stabilization (`OIS`/`EIS`), max video resolution & FPS, `RAW` and `10-bit` dynamic range support.
   - `BATTERY` (`BatteryDetailsCollector`): Cycle count (API 34+), Charging mode/policy (API 34+ Normal/Adaptive/Long life), Charge counter (mAh), Average current (mA).
   - `MEMORY`: Used RAM & %, Low-memory threshold & low-memory flag, Swap / ZRAM used & total (`/proc/meminfo`), Java heap (used / max), Native heap allocated, Memory class & large memory class.
   - `STORAGE`: Used storage & %, `/data` partition free & total, Storage volumes summary (Primary / Removable + state), File-based encryption status.
   - `NETWORK`: IPv6 addresses, Link downstream / upstream bandwidth (kbps), Validated & Captive portal flags, DNS servers & Private DNS mode, Wi-Fi link speed / frequency / RSSI, Supported Wi-Fi bands (2.4/5/6 GHz) & standards (Wi-Fi 6 / Wi-Fi 7), Bluetooth & NFC state.
   - `DISPLAY`: Physical diagonal size (inches), Supported refresh rate range (min-max Hz), Named HDR formats & max luminance (nits), Display cutout rect count, Screen brightness & mode (auto/manual), Screen timeout, Navigation mode (3-button / 2-button / Gesture).
   - `LOCALE`: First day of week, Measurement system (Metric / US / Imperial).
   - `TIME`: System uptime, Awake time / Deep sleep time & %, Auto time & Auto timezone status.
   - `SYSTEM`: WebView provider package & version, Accessibility & Touch exploration (TalkBack) status, Window / Transition / Animator duration scales, Developer options & ADB status.
   - `BENCHMARKS` (`SystemInfoBenchmark`): Single-thread and multi-thread CPU throughput benchmark (`~MOPS`) alongside memory and storage throughput.
3. **Permission-gated sensors and deep personal/sideload diagnostics (`NoLegalDiagnosticsCollectors` / S0009 parity)**:
   - Public `SensorsDiagnosticsCollector` (`src/main`) excludes permission-gated health/step sensors (`TYPE_STEP_COUNTER`, `TYPE_STEP_DETECTOR`, `TYPE_HEART_RATE`, `TYPE_HEART_BEAT`, `TYPE_LOW_LATENCY_OFFBODY_DETECT`) so store builds need zero extra permissions.
   - `NoLegalDiagnosticsCollectors` (`src/noLegal` in FastMediaSorter, or personal/extended diagnostics contributor in `deviceinfo_mob` alongside `S0009`) adds:
     - `OS_SECURITY`: Bootloader version, `vbmeta` & `verity` state, OEM ROM/skin (`OneUI`/`MIUI`/`HyperOS`/`EMUI`/`OxygenOS`/`ColorOS`), `ro.crypto.*` encryption state, `ADB Wi-Fi & USB state` (`adb_wifi_enabled`, `sys.usb.state`), `/proc/version`.
     - `PERMISSIONS`: `ACTIVITY_RECOGNITION` state, live `Step counter (since boot)` hardware sample, `Step detector & motion` (`TYPE_STEP_DETECTOR`, `TYPE_SIGNIFICANT_MOTION`), `Body & health sensors` (`TYPE_HEART_RATE`, `TYPE_LOW_LATENCY_OFFBODY_DETECT`), `ACCESS_FINE_LOCATION`, `NEARBY_WIFI_DEVICES`, `BLUETOOTH_CONNECT`, `READ_PHONE_STATE`, `Notification listeners`.
     - `INSTALLER_SIGNATURE`: `InstallSourceInfo` initiating/originating package names, visible launchable packages count (user vs system), default Home launcher & Browser role holders, base & split APK layout, `.so` native library count & size.
     - `RUNTIMES`: `EGL` & `Vulkan` driver properties (`ro.hardware.egl`, `ro.hardware.vulkan`), ART VM heap flags (`dalvik.vm.*`), Widevine DRM security level, TLS security providers, vendor-private & wake-up sensor counts.
     - `MOUNTS`: `/`, `/system`, `/vendor`, `/data` filesystem types & mount flags, `zram0` disk size & compression algorithm, block I/O scheduler (`queue/scheduler`), direct `ExternalStorageDirectory` read/write verification.
     - `NETWORK_DIAGNOSTICS`: active network interfaces & `MTU`, `Wi-Fi SSID & BSSID` (`sensitive = true`), Wi-Fi link speed / frequency / `RSSI` / default route gateway, Bluetooth adapter state & bonded device names (`sensitive = true`), Cellular SIM state / operator / carrier / roaming (`TelephonyManager`).
     - `PROCESS_RESOURCES`: `PID` / `UID` / `64-bit` identity, SELinux process context (`/proc/self/attr/current`), `PSS` & `VmRSS`, CPU scaling governor & live per-core frequencies, `/sys/class/thermal/thermal_zone*` temperatures, `/sys/class/power_supply/battery/*` design/full capacity & cycle count.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** FastMediaSorter S4543 (upstream implementation), S0006 (battery details port), S0007 (parity verification).
- **Parity inventory:**
  - `app_v2/src/main/java/com/sza/fastmediasorter/core/systeminfo/SystemInfoGroup.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/SystemInfoGroup.kt`
  - `app_v2/src/main/java/com/sza/fastmediasorter/ui/systeminfo/helpers/SystemInfoGroupIcons.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/helpers/SystemInfoGroupIcons.kt`
  - `app_v2/src/main/java/com/sza/fastmediasorter/core/systeminfo/PlatformDetailsCollector.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/PlatformDetailsCollector.kt`
  - `app_v2/src/main/java/com/sza/fastmediasorter/core/systeminfo/SensorsDiagnosticsCollector.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/SensorsDiagnosticsCollector.kt`
  - `app_v2/src/main/java/com/sza/fastmediasorter/core/systeminfo/MediaAudioDiagnosticsCollector.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/MediaAudioDiagnosticsCollector.kt`
  - `app_v2/src/main/java/com/sza/fastmediasorter/core/systeminfo/BatteryDetailsCollector.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/BatteryDetailsCollector.kt`
  - `app_v2/src/main/java/com/sza/fastmediasorter/core/systeminfo/SystemInfoBenchmark.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/SystemInfoBenchmark.kt`
  - `app_v2/src/main/java/com/sza/fastmediasorter/domain/model/CameraHardwareInventory.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/domain/model/CameraHardwareInventory.kt`
  - `app_v2/src/main/java/com/sza/fastmediasorter/data/capture/CameraHardwareDataSource.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/data/camera/CameraHardwareDataSource.kt` (the package S0003 ported it into; the ledger row is the authority)
  - `app_v2/src/main/java/com/sza/fastmediasorter/domain/usecase/GatherCameraDiagnosticsUseCase.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/domain/usecase/GatherCameraDiagnosticsUseCase.kt`
  - `app_v2/src/main/java/com/sza/fastmediasorter/domain/usecase/GatherSystemInfoUseCase.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/domain/usecase/GatherSystemInfoUseCase.kt`
  - `app_v2/src/noLegal/java/com/sza/fastmediasorter/diagnostics/NoLegalDiagnosticsCollectors.kt` -> `phone/src/main/kotlin/com/sza/deviceinfo/diagnostics/NoLegalDiagnosticsCollectors.kt` (or `S0009` extended diagnostics contributor)
  - 83 string keys in `values/strings_systeminfo.xml`, `values-ru/strings_systeminfo.xml`, and `values-uk/strings_systeminfo.xml`
- **UI placement contract:** 15 existing sections expanded + 2 new collapsible sections (`Sensors`, `Media & Audio`) in `SystemInfoActivity`.
- **Locales:** EN, RU, and UK authored; remaining locales follow release boundary.
- **Performance budget:** On-demand collection off the main thread with bounded sensor sample timeout (80 ms) and CPU benchmark cap (120 ms).
- **Owner sign-off:** Approved by owner in FastMediaSorter S4543 Q&A (2026-11-11).

<!-- auto-approved by S4543 handoff - 2026-11-11 -->

## Plan (2026-11-12)

Shared-contract boundary: none touched. The new sections go through the existing `SystemInfoSection` / `SystemInfoGroup` model and the collapsible adapter; `ExtendedDiagnosticsContributor`, `DATA-LAYER-PAIR`, `INPUT-PARITY`, `IN-APP-HELP` and `UNIFIED-UI` are read-only here. Complexity read against the plan and confirmed: medium (about 20 files, no schema, no new screen, no new DI wiring beyond constructor injection).

Coverage inventory (every goal and acceptance line mapped):

| Scope line | Phase |
| --- | --- |
| 1. `SENSORS` and `MEDIA_AUDIO` groups, icons, collectors | A, B, C |
| 2. extended metrics of the base sections (device, user, os, app, hardware, memory, storage, network, display, locale, time, system) | B, C |
| 2. `CAMERAS` hardware level, apertures, flash, stabilization, max video, RAW / 10-bit | B |
| 2. `BATTERY` cycle count, charging mode, charge counter, average current | B (collector, estimator) |
| 2. `BENCHMARKS` CPU single / multi thread | B |
| 3. public `SensorsDiagnosticsCollector` without permission-gated sensors | B |
| 3. `NoLegalDiagnosticsCollectors` seven sections | out-of-scope here: owned by S0009, which waits on the owner's build decision (Carrier: S0009) |
| UI placement, 83 string keys EN / RU / UK, performance budget (80 ms sensor sample, 120 ms CPU cap) | A, B |

Topology (no phase consumes a later one): A (group enum, icons, drawables, strings) -> B (collectors, camera, battery, benchmark) -> C (`GatherSystemInfoUseCase` wiring) -> D (tests) -> E (port ledger, gates, audit).

- [x] **A. Groups, icons, resources** - `SystemInfoGroup.kt` (`SENSORS`, `MEDIA_AUDIO`), `SystemInfoGroupIcons.kt`, `ic_compass.xml`, `ic_audio.xml`, `strings_systeminfo.xml` in `values`, `values-ru`, `values-uk` (84 keys each, 201 strings per file).
- [x] **B. Collectors** - `PlatformDetailsCollector.kt`, `SensorsDiagnosticsCollector.kt`, `MediaAudioDiagnosticsCollector.kt` (new); `SystemInfoBenchmark.kt` (CPU); `CameraHardwareInventory.kt`, `CameraHardwareDataSource.kt`, `GatherCameraDiagnosticsUseCase.kt` (8 camera fields); `BatteryDetailsCollector.kt`, `BatteryRuntimeEstimator.kt`, `DischargeRateBatteryRuntimeEstimator.kt` (battery fields and the estimator interface the collector needs).
- [x] **C. Use case wiring** - `GatherSystemInfoUseCase.kt` (three collectors injected, 12 `extra*Fields()` appended, `Sensors` and `Media & Audio` sections in report order, CPU benchmark rows, "on external power" runtime text), `AndroidManifest.xml` (`<queries>` for Google Play services).
- [x] **D. Tests** - `GatherSystemInfoUseCaseTest.kt`, `SystemInfoReportContractTest.kt` (constructors), `SystemInfoBenchmarkTest.kt` (CPU), `DischargeRateBatteryRuntimeEstimatorTest.kt` (ported upstream version).
- [x] **E. Ledger and gates** - 13 rows carried and 3 added in `docs/port-ledger.jsonl` (89 rows).

## Open questions

1. **The seven noLegal diagnostic sections (scope line 3, second bullet).** Status: Open, owner call. Which sections DeviceInfo carries and in which build is S0009's question 1; this ticket does not answer it and ports none of the `OS_SECURITY`, `PERMISSIONS`, `INSTALLER_SIGNATURE`, `RUNTIMES`, `MOUNTS`, `NETWORK_DIAGNOSTICS`, `PROCESS_RESOURCES` rows. Fact for that sitting: upstream `NoLegalDiagnosticsCollectors.kt` grew from 386 lines (S0009's reading of 2026-11-10) to 901 lines, and now also carries the permission-gated step, heart-rate and off-body sensor rows that the public collector here leaves out.

Carrier: S0009
Blocker: S0009

### Assumed (unattended, 2026-11-12)

Each was taken as a researched, ticket-reversible choice; the owner may overrule any of them.

1. **Key-sensors row names the step counter.** Taken: `SensorsDiagnosticsCollector` adds "Step counter" to the presence list through `SensorManager.getDefaultSensor`, a presence check that registers nothing and needs no permission. Alternative: the upstream list exactly (no step counter), which contradicts scope line 1 that names it. Owner may overrule.
2. **No `ACCESS_WIFI_STATE`.** Taken: the Wi-Fi link row reads speed, frequency and RSSI from `NetworkCapabilities.transportInfo` (API 29+, covered by `ACCESS_NETWORK_STATE`); on API 26 to 28 the fallback `WifiManager.connectionInfo` is refused and the row reads `n/a`. Alternative: declare `ACCESS_WIFI_STATE` (a normal permission) and have S0008's permission list and privacy text say so. Scope line 3 asks that the public build need zero extra permissions. Owner may overrule.
3. **Package visibility for Google Play services.** Taken: `<queries><package android:name="com.google.android.gms" /></queries>`, because without it `getPackageInfo` fails on API 30+ and the field always reads "not installed". Alternative: no entry (the upstream behaviour). It is a visibility declaration for one package, not a permission. Owner may overrule.
4. **The battery estimator interface is carried in full.** Taken: `BatteryRuntimeEstimator`, its implementation and its test move to the current upstream version (charge counter and current in, `isOnExternalPower` instead of `isCharging`), because the upstream `BatteryDetailsCollector` that scope line 2 names calls that signature. Alternative: keep the older estimator and port only the four new battery fields; rejected because the collector would then diverge from upstream in its core call. This touches the code S0006 is waiting on a device check for; S0006's manual check stays valid and now also covers "On external power" in the runtime row. Owner may overrule.

## Disposition (what the port left out, and the deliberate differences)

| Upstream | Disposition |
| --- | --- |
| `sysinfo_field_flavor` string and the `BuildConfig.FLAVOR` row | not ported: DeviceInfo has no product flavor (already recorded in `GatherSystemInfoUseCase`) |
| `GatherSystemInfoUseCase(appCameraView)`, `sysinfo_field_camera_app_view` | not ported: no capture screen (already recorded, S0003) |
| `CameraHardwareDataSource.hasAnyCamera`, `isCameraPermissionGranted` | not ported: no capture screen, no camera permission (recorded in the class KDoc) |
| `Timber.d("S4543: ..")` probe in `GatherSystemInfoUseCase` | not ported: a probe carries its own ticket's id, and only while that ticket awaits a device test |
| `NoLegalDiagnosticsCollectors`, `NoLegalExtendedDiagnosticsContributor` | not ported: S0009 (Open question 1) |
| `PlatformDetailsCollector.fileEncryptionStatus` | differs: upstream calls a static `StorageManager.isFileEncrypted()` that the public SDK lacks and would not compile; this port asks the instance `isEncrypted(File)` about the data directory (KDoc next to the code) |
| `SensorsDiagnosticsCollector.sampleEnvironmentSensor` | differs: upstream's two overloads share one JVM signature; the scalar form is `sampleEnvironmentScalar` (KDoc next to the code) |
| `PlatformDetailsCollector.playServicesVersion` | differs in form only: `runCatching` instead of `catch (_: Exception)`, which no compiled file of this repository uses yet |
| `MediaAudioDiagnosticsCollector.widevineInfo` | differs in form only: a non-null `val drm`, no smart cast over a captured `var` |
| `BatteryDetailsCollector` probe | kept as `S0006` (not upstream's `S4529`): S0006 is still at `BlockNeedUserTest` |

Park candidates for the FastMediaSorter project (not filed from here: the pass may not write another repository's ticket): the two upstream compile defects and the missing package-visibility entry above, found by checking every platform API of the port against the SDK stub sources (`platforms/android-37.0/android-stubs-src.jar`). Upstream was not compiled in this pass either.

## Last Audit

**Date:** 26-11-12 | **Mode:** static | **Outcome:** Partial
**Counts:** PASS 9 | WARN 0 | FAIL 0 | MANUAL 1 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 2

Evidence, each run fresh in this pass (expected | actual):

1. Port ledger: `pwsh -NoProfile -File tools/port-ledger/check-drift.ps1` | exit 0, "OK: nothing uncarried (89 in step, 0 decided)"; 13 drifted rows carried with `-Refresh`, 3 rows added (`PlatformDetailsCollector`, `SensorsDiagnosticsCollector`, `MediaAudioDiagnosticsCollector`). PASS.
2. Diffs against upstream, `diff` of each ported file after the package rename | only the differences listed in the disposition table remain (`GatherSystemInfoUseCase`, `GatherCameraDiagnosticsUseCase`, `CameraHardwareDataSource`, `SystemInfoGroupIcons`, `BatteryDetailsCollector`, estimator files and tests). PASS.
3. String completeness: every `R.string.*` referenced under `core/systeminfo` and `domain/usecase` (178 keys) | 0 missing in `values`, `values-ru`, `values-uk`; 0 duplicate names per file. PASS.
4. Platform API existence: every Android API used by the three new collectors, the camera and battery changes (about 130 symbols) checked against the SDK stub sources | all present except `StorageManager.isFileEncrypted()`, replaced as recorded. PASS after the fix.
5. Group model: `SystemInfoGroup.entries` gains `SENSORS`, `MEDIA_AUDIO`; `SystemInfoGroupIcons` maps both; `ic_compass.xml` and `ic_audio.xml` exist in `phone/src/main/res/drawable`; `SystemInfoExpansionStateTest` asserts an icon for every entry. PASS.
6. Permissions: no `uses-permission` added; the permission-gated sensor types are filtered from the list and never sampled; `<queries>` names one package. PASS.
7. Fast tier: `spec_catalog/validate` | exit 0, "Summary: 10 OK, 0 WARN, 0 FAIL"; `spec_catalog/release-queue -Validate` | exit 0, "10 ticket(s), no drift"; canon compliance gate | exit 0, 0 error(s), 1 warning (`SZA-CANON03` stale adoption stamp, present before this ticket). PASS.
8. Probe invariant: no `S0010` string in `phone/src` or `wear/src`; the `S0006` probe line is untouched and S0006 is still `BlockNeedUserTest`. PASS.
9. Scope purity: every edit is inside the plan's phases A to E; the upstream defects are recorded as park candidates, not fixed upstream. PASS.
10. Contract boundary and persona pass: no shared contract changed; the new rows are technical values like the existing ones. EXEMPT.
11. Scope line 3, noLegal sections: waits for S0009's owner decision. EXEMPT (Carrier: S0009).
12. Build: no `commands.compileCheck` in `.sza-profile.json`, so no compile command is declared; the pass edited compiled source and ran none. Compiled: no. RELEASE: `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug` under the Build lock.
13. Tests: not run. RELEASE: `.\gradlew.bat :phone:testDebugUnitTest` under the Build lock (the suite grows by the CPU benchmark test, two use-case tests and the replaced estimator test).

Re-check (2026-11-12, unattended resume, no source edited, so no compile gate applies): the tree matches the tracking. `check-drift.ps1` | exit 0, "OK: nothing uncarried (89 in step, 0 decided)"; `spec_catalog/validate` | "Summary: 10 OK, 0 WARN, 0 FAIL"; `release-queue -Validate` | "10 ticket(s), no drift"; on disk: `SENSORS` and `MEDIA_AUDIO` in `SystemInfoGroup.kt` and `SystemInfoGroupIcons.kt`, `ic_compass.xml` and `ic_audio.xml` present, 201 strings in each of `values`, `values-ru`, `values-uk`, the three new collectors, `SystemInfoBenchmark`, camera and battery files present, one `<queries>` package and no added `uses-permission`, no `S0010` string in `phone/src` or `wear/src`. The parity inventory line for `CameraHardwareDataSource` named a planned destination (`data/capture`); corrected to the ledger's `data/camera`. S0009 is still `BlockQuestions` (owner decision), so nothing in scope line 3's second bullet can move.

Re-check (2026-11-12, second unattended resume, no source edited, so no compile gate applies): upstream `GatherSystemInfoUseCase.kt` changed after the carry above (upstream file time 03:04, the port's 02:23), so `check-drift.ps1` | exit 1, "UNCARRIED: 1 of 89" on that one row. Re-inventory: `diff` of the current upstream (package renamed) against the port | only the differences already in the disposition table remain (flavor row, `appCameraView` and `sysinfo_field_camera_app_view`, ticket-id references in comments, KDoc wording); no upstream behaviour is missing from the port. Carried with `record-port.ps1 -Refresh` | exit 0; `check-drift.ps1` | exit 0, "OK: nothing uncarried (89 in step, 0 decided)". No upstream `core/systeminfo`, `ui/systeminfo` or `ui/systeminfo/helpers` file is absent from the ledger. `spec_catalog/validate` | exit 0, "Summary: 10 OK, 0 WARN, 0 FAIL"; `release-queue -Validate` | exit 0, "10 ticket(s), no drift". S0009 is still `BlockQuestions` (updated 2026-11-10), S0009 does not depend on this ticket (no cycle). Status stays `Partial`, not `BlockNeedUserTest`: the port has never been compiled (no `commands.compileCheck` is declared) and scope line 3's second bullet is not ported, so inviting a device test now would test code nobody has built.

### Action items

1. Scope line 3, second bullet (the seven noLegal sections) - S0009 - clear S0009's question 1 with `/sq`, then port the chosen sections on the contract S0003 ported.
2. First compile of this port - `phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/{PlatformDetailsCollector,SensorsDiagnosticsCollector,MediaAudioDiagnosticsCollector}.kt` - the three files and the camera and battery edits were checked by static inspection only; the release build is their first compile.

### Manual / on-target

- [ ] On a phone or emulator, open System information: the `Sensors` and `Media & Audio` sections appear with their icons, expand and collapse, and show values (sensor count, key sensors, light / pressure / magnetic snapshot or "supported", Widevine level, codecs, audio outputs); the 12 base sections show the new rows; Cameras shows hardware level, apertures, flash, stabilization, max video, RAW / 10-bit; Battery shows cycle count, charging mode, charge counter, average current; Benchmarks shows CPU single and multi thread. Not covered: Wear OS, API 26 to 28 behaviour of the Wi-Fi row, a device without Google Play services.
