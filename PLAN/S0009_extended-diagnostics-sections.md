# S0009 - Extended diagnostics sections of the System info report

**Ticket:** S0009
**Status:** Implemented
**Status note:** no compile command: compiled no, tested no; RELEASE items and one MANUAL device check in Last Audit
**Created:** 2026-11-10
**Priority:** 55
**Tier:** 3 - Moderate
**Complexity:** medium (rewritten at the spec pass 2026-11-13, confirmed against the plan) - a distribution-flavor dimension in the phone module plus a ported 900-line collector, a contributor, a Hilt binding, resources in three locales and tests; no shared contract, no schema, no new screen
**Depends on:** S0003

## 0. Owner request (verbatim)

Captured by the S0003 unattended pass (not the owner's words): the fresh upstream inventory of S0003 found that FastMediaSorter ships seven extra System info sections in its `noLegal` flavor only, through a contributor that the base report appends after its own sections. S0003 ports the contract (field and section model, the sensitive-value masking, the contributor interface, the empty default) and nothing of the seven sections, because whether and in what form a standalone DeviceInfo carries them is an owner decision that depends on distribution and privacy choices not yet made.

Upstream facts, read 2026-11-10 from `P:\ANDROID\FastMediaSorter_mob_v2\app_v2\src\noLegal\java\com\sza\fastmediasorter\diagnostics\` (read-only): `NoLegalExtendedDiagnosticsContributor` and `NoLegalDiagnosticsCollectors` (386 lines) build seven sections - OS and security (root markers, SELinux, developer options, ADB, Xposed, verified boot, bootloader lock), permissions (storage manager, query-all-packages, install packages, overlay, notifications, battery optimization, accessibility services), installer and signature (installer package, signing certificate SHA-256, alternative stores), runtimes (Python, yt-dlp, ffmpeg, Tesseract and XR rows that only mean something inside FastMediaSorter, plus ABIs and the WebView provider), mounts (mount points, partition sizes, removable volumes), network diagnostics (DNS servers, VPN interfaces, proxy, private DNS) and process resources (native and Java heap, file descriptors, threads, thermal status). Four of the fields (signing certificate hash, mount points, DNS servers, VPN interfaces) are marked sensitive and masked on screen, copy and share until the user reveals them.

## 1. Problem

The owner asked for the full functionality of FastMediaSorter's Device Information. In FastMediaSorter seven of its sections exist only in a restricted flavor, never in a public one, because they read things a store listing, a privacy page and a data-safety form would have to account for: which other apps are installed, the signing certificate, network addresses, mount paths, accessibility services. The standalone product has one build and has not yet chosen its distribution channels, so it cannot yet say whether these sections belong in it, in which build, or at all.

## 2. Done criteria

Written against option 1 below and rewritten when the owner answers; each is a command to run or a file to read.

1. The contributor of the chosen sections exists in the source set of the chosen build only, and `GatherSystemInfoUseCase` appends its sections through the contract ported by S0003 without a change to that contract.
2. Every field of a ported section degrades to `unknown` or `n/a` instead of throwing; a unit test of the contributor with a failing source proves it.
3. The sensitive fields are masked in `maskedText` and revealed only in `fullText`; a unit test proves both strings. (Rewritten 2026-11-13: the fresh upstream inventory marks ten fields sensitive, not four - signature SHA-256, APK and split layout, mount points, DNS servers, VPN interfaces, active interfaces and MTU, Wi-Fi SSID and BSSID, Wi-Fi link and gateway, Bluetooth and bonded devices, cellular and SIM state - and the test covers every one.)
4. The rows that describe FastMediaSorter-only components (Python, yt-dlp, ffmpeg, Tesseract, XR runtime) are absent, recorded as a deliberate difference next to the code.
5. Strings of the new sections exist in EN, RU and UK in one edit.
6. The privacy page, the permission list and the store data-safety form say what the build reads (INVARIANTS 13 and 14); that text is S0008's surface, and this ticket hands it the list.

## 3. Approach

### 3.1 Scope

Port of the seven-section contributor and its collectors into the build the owner names, on top of the contract S0003 ported. Not in scope: the contract itself (S0003), the screen that shows masked and revealed values (S0004), the wear side (S0005).

### 3.2 Open questions

1. **Which of the seven sections does DeviceInfo carry, and in which build?** Status: Answered 2026-11-13 - option (1). The owner call is product and privacy intent, not a code detail. Options, the researched recommendation first: (1) all seven in a restricted build only, the public build carries none, as FastMediaSorter splits them - keeps the full upstream functionality and leaves the public privacy text unchanged, costs a distribution-variant dimension in Gradle that S0008's channel decision has to confirm; (2) all seven in the one build, sensitive values masked - simplest build, but the root-marker and alternative-store rows probe other installed apps, so the build needs package-visibility handling and every public text must say so; (3) only the sections that read nothing about other apps and no network or mount data (process resources, the app's own permission states, the OS and security rows that read system properties) in the one build, the rest dropped - smallest privacy surface, gives up part of the upstream functionality the owner asked for; (4) none - the S0003 contract stays unused.
2. **The FastMediaSorter-only runtime rows (Python, yt-dlp, ffmpeg, Tesseract, XR runtime).** Status: Resolved without asking - DeviceInfo bundles none of those components, so the rows would read `n/a` forever; they are left out of any option above and the difference is recorded next to the code.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0003 ports the contract this ticket fills; S0008 owns distribution channels, the privacy page and the data-safety form, and so confirms the build this ticket lands in; S0007 re-inventories upstream and must list this ticket's outcome as its own parity row; S0010 ported the public Sensors and Media & Audio sections and the extended metrics of the base sections (2026-11-12) and leaves the noLegal sections to this ticket - the upstream `NoLegalDiagnosticsCollectors.kt` is now 901 lines, not 386, and carries the permission-gated step, heart-rate and off-body sensor rows the public build leaves out.

### Quiz decisions (2026-11-13)
- Which of the seven sections does DeviceInfo carry, and in which build? -> Option (1): all seven in a restricted build only, the public build carries none, as FastMediaSorter splits them (keeps the full upstream functionality the standing law asks for; the distribution-variant dimension is S0008's to confirm; owner accepted the recommendation).

## Plan (2026-11-13)

Shared-contract boundary: none touched. The seven sections reach the report through `ExtendedDiagnosticsContributor`, `ExtendedDiagnosticsSection` and the `@Multibinds` set that S0003 ported; none of them changes. The restricted build adds a flavor dimension to the phone module only; the watch module, `DATA-LAYER-PAIR` and `PACKAGE-VERSIONING` (one id, one stamp) are read-only here. Complexity read against the plan and confirmed: medium.

Fresh inventory (2026-11-13, upstream `app_v2/src/noLegal/.../diagnostics/`, read-only): `NoLegalExtendedDiagnosticsContributor` (7 sections), `NoLegalDiagnosticsCollectors` (901 lines, 7 section builders, 10 sensitive fields), `NoLegalExtendedDiagnosticsModule` (`@Binds @IntoSet`), section-title strings `nolegal_diag_section_*` in `noLegal/res/values*/strings.xml`. The upstream has no test for any of them.

Coverage inventory (every goal, constraint and criterion mapped):

| Line | Phase |
| --- | --- |
| Owner decision: option (1), all seven in a restricted build, the public build carries none | A (flavor dimension), B (source set) |
| Done 1: contributor in the restricted source set only, appended through the S0003 contract unchanged | B, D (store-flavor absence test) |
| Done 2: every field degrades to `unknown` / `n/a`, proven by a failing-source test | B (`safe`), D |
| Done 3: sensitive fields masked in `maskedText`, revealed in `fullText`, proven for all ten | D |
| Done 4: Python, yt-dlp, ffmpeg, Tesseract, XR rows absent, difference recorded next to the code | B |
| Done 5: strings in EN, RU, UK in one edit | B |
| Done 6: the list of what the build reads is handed to S0008's surface | E (`docs/SECURITY_INVENTORY.md`, section 3) |
| Open question 2 (runtime rows) | resolved, B |
| S0010 scope line 3, second bullet (permission-gated step, heart-rate, off-body rows) | B (ported with the collector) |
| Build consequence of the flavor: task names, output paths, release guard | A, E |
| Package visibility for the rows that probe other apps | B (`<queries>`, no permission) |

Topology (no phase consumes a later one): A (flavor dimension, release guard) -> B (restricted source set: manifest, strings, collectors, contributor, module) -> C (KDoc of the S0003 contract and the use case, which say "no flavor") -> D (tests of both flavors) -> E (docs, ledger, gates, audit).

- [x] **A. Flavor dimension** - `phone/build.gradle.kts`: dimension `distribution`, flavors `store` and `restricted`, the `restrictedRelease` variant disabled in `androidComponents.beforeVariants`; `buildSrc` `ReleaseSigning.isPackagingTask` (per-variant release task names) used by both module scripts, with a test in `ReleaseSigningTest`.
- [x] **B. Restricted source set** - `phone/src/restricted/`: `AndroidManifest.xml` (`<queries>` only), `res/values{,-ru,-uk}/strings_diagnostics.xml`, `kotlin/.../diagnostics/RestrictedDiagnosticsCollectors.kt`, `RestrictedExtendedDiagnosticsContributor.kt`, `kotlin/.../di/RestrictedExtendedDiagnosticsModule.kt`.
- [x] **C. Contract wording** - `ExtendedDiagnostics.kt`, `ExtendedDiagnosticsModule.kt`, `GatherSystemInfoUseCase.kt` KDoc (no behaviour change).
- [x] **D. Tests** - `phone/src/testRestricted/` (failing-source degradation, section set, sensitive set, masked versus full text), `phone/src/testStore/` (the public flavor carries none of the restricted classes or strings).
- [x] **E. Docs, ledger, gates** - `CLAUDE.md` (build outputs, section 7), `docs/RELEASE.md` (variant-aware commands), `docs/SECURITY_INVENTORY.md` (restricted-build list), `docs/port-ledger.jsonl` (three rows), fast-tier gates, audit.

Self-review: every inventory line maps to a phase; every symbol a later phase consumes (`SystemInfoGroup.OS_SECURITY` to `PROCESS_RESOURCES`, `SystemInfoAccessClassifier`, `getPackageInfoCompat`, `queryIntentActivitiesCompat`, `REDACTED`, `toSystemInfoSections`) is declared in `phone/src/main` today.

## Open questions

None open. Question 1 is answered (Quiz decisions, 2026-11-13); question 2 is resolved without asking.

### Assumed (unattended, 2026-11-13)

Each was taken as a researched, ticket-reversible choice; the owner may overrule any of them.

1. **Flavor names: dimension `distribution`, flavors `store` and `restricted`.** Taken: `store` is the public build (the Play package), `restricted` carries the seven sections. Alternative: the upstream names (`standard`, `noLegal`). The ticket and the owner's decision speak of a "restricted build", and DeviceInfo has no `standard`. Owner may overrule.
2. **The restricted build is a debug-only developer build that shares the frozen application id.** Taken: no `applicationIdSuffix` (the id is one for phone and watch so the Data Layer pairs them), and the `restrictedRelease` variant is disabled, so no restricted release bundle can be packaged, signed or uploaded by the documented release command. S0008 decided "Google Play only, no sideload channel", so the restricted build has no channel. Alternative: allow a signed restricted release for a future sideload channel (S0008's decision to revisit first). Owner may overrule.
3. **Package visibility by `<queries>`, not `QUERY_ALL_PACKAGES`.** Taken: the restricted manifest names the seven packages the rows look for (Magisk, KernelSU, APatch, F-Droid, Aurora Store, Amazon Appstore, Huawei AppGallery) and the launcher, home and browser intents. Alternative: `QUERY_ALL_PACKAGES`, a Google Play restricted permission. The row "QUERY_ALL_PACKAGES" reports the permission state of this app, which is `denied`. Owner may overrule.
4. **No permission is declared by the restricted manifest.** Taken: rows that need a runtime permission (location, Bluetooth connect, phone state, activity recognition) report the state truthfully and degrade, as the upstream rows do when the permission is missing; nothing is requested at run time. Alternative: declare `ACCESS_WIFI_STATE` and request the runtime permissions in the restricted build, which widens what the build reads and what its text must say. Owner may overrule.
5. **The Bluetooth row says when bonded devices are unreadable.** Taken: on API 31 and later without `BLUETOOTH_CONNECT` the row reads "on, bonded devices unreadable (permission denied)" instead of upstream's "0 bonded", which a denied permission produces and which would be false. Alternative: the upstream wording exactly. Owner may overrule.
6. **The Runtimes title is renamed in RU and UK.** Taken: "Среды выполнения" and "Середовища виконання" (EN "Runtimes"), because the "bundled" runtimes of the upstream title are the five rows DeviceInfo does not carry. Alternative: the upstream title. Owner may overrule.
7. **The public text is left unchanged.** Taken: the privacy pages, the Play listing and the changelog keep describing the masked-copy mechanism; the store build reads none of the ten sensitive values, and the owner accepted option (1) because it "leaves the public privacy text unchanged". Alternative: reword those three surfaces so they do not mention values the store build never shows (S0008's surface, three locales plus the listing). Owner may overrule.
8. **`assembleDebug` and `testDebugUnitTest` now cover both flavors.** Taken: the documented release-tier commands keep their names and build and test `store` and `restricted`; only the output paths change. Alternative: scope the commands to `:phone:assembleStoreDebug`; rejected because the restricted flavor would then be built by nobody until a release. Owner may overrule.

## Disposition (what the port left out, and the deliberate differences)

| Upstream | Disposition |
| --- | --- |
| `runtimes()` rows Python (Chaquopy), yt-dlp, ffmpeg/ffprobe, Tesseract data, XR runtime | not ported: DeviceInfo bundles none of those components, the rows would read `n/a` forever (Open question 2); recorded in the KDoc of the collector |
| `XrEnvironmentDetector` constructor parameter of the contributor and the collectors | not ported: its only consumer is the XR runtime row |
| `isClassPresent`, `pythonStatus`, `ytDlpStatus`, `ffmpegStatus`, `tesseractStatus`, `xrRuntime` | not ported with the rows above |
| `nolegal_diag_section_*` string keys | renamed `sysinfo_section_*` after the base keys; the runtimes title differs in RU and UK (Assumed 6) |
| `bluetoothDetails` | differs: says so when bonded devices are unreadable (Assumed 5), KDoc next to the code |
| `vpnInterfaces`, `activeInterfacesAndMtu` | differs in form only: `NetworkInterface.getNetworkInterfaces()` may return null, read through one null-safe helper |
| `resolveActivityCompat` (upstream util) | not ported as a shared helper: its only caller is the default-role row, so a private function in the collector carries the one version branch |
| `NoLegalExtendedDiagnosticsContributor.sections()` | differs: each section builder is guarded, so one builder failing as a whole drops that section instead of every extended section (KDoc next to the code) |
| the rest of `NoLegalDiagnosticsCollectors` | ported with the package renamed; the order of sections and fields is the upstream's |
| upstream `NoLegalExtendedDiagnosticsModule` | ported with the class names renamed |

Park candidates (not filed: no ticket was needed, the symptoms are already owned):
- Port-ledger drift on three files of S0003 / S0010 / S0006 (`BatteryDetailsCollector`, `PlatformDetailsCollector`, `SensorsDiagnosticsCollector`): the upstream files changed on 2026-11-12 after those ports were anchored. `check-drift.ps1` exits 1 on them, none of the three rows is a file of this ticket, and S0007's fresh re-inventory is the standing place that carries or decides them.
- The Play listing, the changelog and the three privacy pages describe the masked-copy mechanism and name the values it hides, which only the restricted build reads (Assumed 7). Left unchanged on the owner's own rationale for option (1); S0008's surface if the owner wants it reworded.

## Last Audit

**Date:** 26-11-13 | **Mode:** static | **Outcome:** Partial
**Counts:** PASS 10 | WARN 0 | FAIL 0 | MANUAL 1 | UNCHECKABLE 0 | EXEMPT 3 | RELEASE 3

Evidence, each run fresh in this pass (expected | actual):

1. Done 1, isolation: `Restricted*` symbols outside `src/restricted`, `src/testRestricted`, `src/testStore` | one hit, `phone/src/main/.../di/ExtendedDiagnosticsModule.kt`, a KDoc mention in backticks, no import and no code reference; the contract files `ExtendedDiagnostics.kt` and `GatherSystemInfoUseCase.kt` changed in KDoc only. PASS.
2. Done 4, rows: `f("..")` rows upstream | 90, port | 85; `diff` of the label lists | exactly `ffmpeg/ffprobe`, `Python (Chaquopy)`, `Tesseract data`, `XR runtime`, `yt-dlp` missing, nothing else. PASS.
3. Done 3, sensitive set: `sensitive = true` upstream | 10, port | 10, and the same ten labels are the test's expected set. PASS (the proof run is item 14).
4. Done 5, strings: `<string name=` in `strings_diagnostics.xml` | 7 each in `values`, `values-ru`, `values-uk`; the seven `R.string.sysinfo_section_*` keys the collectors use are all declared there and none collides with a key of `phone/src/main`. PASS.
5. Done 6, hand-over: `docs/SECURITY_INVENTORY.md` section 3 names the manifest additions (no permission, seven packages and three intents in `<queries>`), each section's reads and the ten sensitive fields. PASS.
6. Flavor structure, against the AGP 9.2.1 API sources (`gradle-api-9.2.1-sources.jar`): `ComponentIdentity.buildType`, `.productFlavors: List<Pair<String, String>>` and `ComponentBuilder.enable` exist, so `beforeVariants { .. variant.enable = false }` and the `distribution` dimension use declared API; `PackageManager.resolveActivity(Intent, ResolveInfoFlags)` and the `int` overload exist in the `android-37.0` stubs. PASS (compilation is item 13).
7. Port ledger: `record-port.ps1` x3 | exit 0 each; `docs/port-ledger.jsonl` 89 -> 92 rows. `check-drift.ps1` | exit 1, "UNCARRIED: 3 of 92": `BatteryDetailsCollector`, `PlatformDetailsCollector`, `SensorsDiagnosticsCollector`, all three anchored 2026-11-12 by S0006 / S0010, upstream changed after; none of them is a row of this ticket and my three rows are in step. Known red, not caused here. PASS for this ticket's rows; the foreign drift is EXEMPT (S0007's re-inventory).
8. Fast tier: `spec_catalog/validate` | exit 0, "Summary: 10 OK, 0 WARN, 0 FAIL"; `spec_catalog/release-queue -Validate` | exit 0, "13 ticket(s), no drift"; canon compliance gate | exit 0, 0 errors, 1 warning (`SZA-CANON03` stale adoption stamp, present before this ticket). PASS.
9. Probe invariant: `check-probe-absent -Id S0009` | exit 0, "No probe of this ticket remains in source"; no `Timber` line carries `S0009`. PASS.
10. Scope purity and coverage: every edit lies in plan phases A to E; no minSdk, ABI, country or age-rating setting changed, the `store` variant keeps `defaultConfig` as it was (the flavor adds no source, resource or manifest entry to it); the watch module changed by one call (`isPackagingTask`). PASS.
11. Contract boundary: no shared contract changed (`PACKAGE-VERSIONING` is read-only: one id, one stamp). EXEMPT.
12. Ship-together surfaces: the shipped packages do not change, the restricted build has no channel, and the owner's option (1) leaves the public text unchanged (Assumed 7). `CHANGELOG.md` not touched for the same reason. EXEMPT.
13. Compile: no `commands.compileCheck` in `.sza-profile.json`, so no compile command is declared; this pass edited compiled source (Kotlin, Gradle scripts, resources, manifest) and ran none. Compiled: no. RELEASE: `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug` under the Build lock (builds `storeDebug` and `restrictedDebug`; KSP and Hilt see the new module only in `restrictedDebug`).
14. Tests: not run. RELEASE: `.\gradlew.bat :phone:testDebugUnitTest :wear:testDebugUnitTest` (new: 6 tests in `testRestricted`, 2 in `testStore`, the shared suite once per flavor) and `.\gradlew.bat -p buildSrc test` (two new `ReleaseSigningTest` cases).
15. Release shape: not built. RELEASE: `.\gradlew.bat :phone:bundleRelease :wear:bundleRelease` with the pin of `docs/RELEASE.md` must package `storeRelease` only (no `restrictedRelease` task exists) and `:phone:dependencies --configuration storeReleaseRuntimeClasspath` must resolve.

### Action items

1. First compile of the flavor dimension and the restricted source set - `phone/build.gradle.kts`, `phone/src/restricted/**`, `phone/src/testRestricted/**`, `phone/src/testStore/**`, `buildSrc/.../ReleaseSigning.kt` - checked by static inspection and API-source lookup only; the release-tier build is its first compile, and a failure there reopens this ticket.
2. Wording of the public surfaces (Assumed 7) - `docs/play/PLAY_LISTING.md`, `CHANGELOG.md`, `site/privacy*.html` - owner call; S0008's surface.
3. S0010 scope line 3, second bullet (the seven sections and the permission-gated step, heart-rate and off-body rows) is carried by this ticket; S0010's next re-audit can close it.

### Manual / on-target

- [ ] On a phone or emulator install `phone-restricted-debug.apk` (`phone/build/outputs/apk/restricted/debug/`) and open System information: seven extra sections appear after Benchmarks - OS and security, Special permissions, Installer and signature, Runtimes, Mounts and storage, Network diagnostics, Process resources - with their icons, collapse and expand, show values or `unknown` / `n/a`, and no section is missing; Copy and Share hide the ten sensitive values behind `[REDACTED]` and the full copy shows them after the confirmation. Install `phone-store-debug.apk` and confirm none of those sections is there. Not covered: Android below API 30 (package visibility), a device without Google Play services, Wear OS, a signed release. Owned by S0007's device check.

