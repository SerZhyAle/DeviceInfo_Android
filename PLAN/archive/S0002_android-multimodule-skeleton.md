# S0002 - Standalone Android multi-module skeleton

**Ticket:** S0002
**Status:** Verified
**Priority:** 70
**Tier:** 3 - Moderate
**Complexity:** medium - assessed at the spec pass: one Gradle root, one version catalog and two small application modules (about fifteen new files, no business logic), with the build itself as the measurable gate; the risks are toolchain resolution on this machine and the one-id rule of the Wear OS Data Layer, not code volume. Read against the plan: the level stands.
**Depends on:** S0001

## Goal

Create a minimal independently buildable multi-module project (phone and wear) under this root, with its own Gradle configuration and entry points ready for the DeviceInfo port. Follow the completed project foundation and current Android overlay rules. Keep `P:/ANDROID/FastMediaSorter_mob_v2` untouched.

## Scope and acceptance

- A local debug build can be built independently with explicit provisional application IDs for phone and wear, sharing a single ID as required for Wear OS Data Layer communication.
- Own dependency versions, tooling, and resources are declared and the independent build does not depend on the FastMediaSorter checkout.
- No release is signed, published or uploaded. Leave signing, final ID, distribution and branding to the release ticket.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0001 foundation (Verified); S0003 through S0008 follow. S0003 ports onto this skeleton, S0008 owns the final application id, signing, license, remote and distribution.
- **Application id:** provisional, one value for phone and wear, declared once in `gradle.properties` as `com.sza.deviceinfo.provisional`. It is not a frozen anchor: the `.provisional` tail guarantees the owner's final choice (S0008) differs and is made explicitly, never inherited. No `applicationIdSuffix` on any build type, because the Data Layer routes by package name and certificate.
- **Platform levels:** compileSdk 37, targetSdk 36, minSdk 26 (phone) and 28 (wear) - the values of the FastMediaSorter `app_v2` and `wear` modules read on 2026-11-10, so the reach of the upstream is not narrowed. Nothing has shipped, so the reach rule has no installed base to protect yet; targetSdk is re-checked at S0008.
- **Toolchain pins:** Gradle 9.4.1 (wrapper), Android Gradle Plugin 9.2.1 with its built-in Kotlin, Kotlin plugin line 2.2.10 for the Compose compiler, JVM target 17, build JDK from the developer's own `%USERPROFILE%\.gradle\gradle.properties`. The same set the sibling products Tourist_mob and StreamsPlayer_mob build with on this machine; the products share no build, so a pin moves here on its own ticket.
- **Versioning:** the Android profile of `PACKAGE-VERSIONING` (the only profile that applies to a Play-bound Android family). Debug builds carry the checked-in non-releasable sentinel for the instant 2611100000 (rules 6 and 7): versionName `2.61.1100.000`, versionCode `261110000` (phone, band 0..5) and `261110006` (watch app, band 6..9). The derivation code, its fixed-instant test, the parity gate and the registry row (which needs the final application id) are carried to S0008.
- **Contract boundary:** touches `PACKAGE-VERSIONING` (Android profile, one id for phone and wear). No catalog amendment is owed before this ticket: the sentinels never leave the developer's devices (rule 6) and the family joins the band table before it ships, which is S0008's step.
- **Local git repository:** n/a for this ticket - no Gradle step needs one. Carried to S0008, whose tag step needs it.

## Spec pass (2026-11-10)

- **Rung:** complex pipeline. Forced upward by the primitive test: new files (more than three), new screens (one launcher activity per module) and new build wiring.
- **Entry state:** the blocker S0001 is Verified (journal, 2026-11-10), so `BlockByOtherTask` cleared and the ticket went back to `Draft` (no plan, owner inputs unfilled). The lease is held by this session under reason `run-spec-queue pq1`.
- **Settled without asking** (the records answer them): minSdk, targetSdk, compileSdk, the toolchain pins and the module names (FastMediaSorter `libs.versions.toml`, `app_v2/build.gradle.kts`, `wear/build.gradle.kts`, Tourist_mob `gradle/libs.versions.toml`, read 2026-11-10); the Wear manifest carries `android.hardware.type.watch` and the standalone flag as the upstream wear module does; the build JDK is the machine-level setting, not a repository one; the version profile is dictated by the contract; the layout (`phone/`, `wear/`, root Gradle files) is CLAUDE.md section 5.
- **Boundary with later tickets:** no collector, no domain class, no Data Layer, no battery logic (S0003 to S0006); the launcher activities show only the product name, so the skeleton is not mistaken for a ported screen.
- **Unattended pass:** nobody answers questions here. The one real fork (the final application id) is already an owner decision carried to S0008 and does not block a build under a provisional id.
- **Between releases nothing above 5 seconds runs.** The ticket's own acceptance names a local debug build, so the debug build of both modules is the run the owner named; it is run once cold and once warm to record both times. Nothing else above 5 s runs (no lint, no test suite, no release variant).

## Done criteria

Each is a command to run or a file to read.

1. `gradlew.bat :phone:assembleDebug :wear:assembleDebug`, run from this root, exits 0 with `BUILD SUCCESSFUL`, and both debug APKs exist.
2. `aapt2 dump badging` of both APKs: the package name is `com.sza.deviceinfo.provisional` in both; versionName `2.61.1100.000` in both; versionCode `261110000` (phone) and `261110006` (wear), different from each other; the wear APK declares the watch hardware feature.
3. Independence: the build files carry no `FastMediaSorter` reference outside comments (two comments in the version catalog name the source of the pins), no `includeBuild`, no absolute path outside this tree; the build ran with this root as the working directory and no composite with the upstream checkout.
4. No decision by assumption: no `signingConfigs`, no keystore reference, no `applicationIdSuffix`, no `LICENSE`, no remote; the application id is declared in exactly one place.
5. `CLAUDE.md` section 6 records the build command, its cold and warm times measured here, and the fast/release split; sections 3 and 5 match the tree.
6. `docs/contracts/PACKAGE-VERSIONING.md` exists as a pointer that cites the contract by id and section; the carried work is a literal `Carrier: S0008` question in this record and in S0008's record.
7. `spec_catalog/validate` and `spec_catalog/release-queue -Validate` exit 0; the canon compliance gate exits 0 with 0 errors.
8. The upstream checkout was only read: no command of this pass wrote under `P:\ANDROID\FastMediaSorter_mob_v2`.

## Plan

Coverage inventory - Goal (independently buildable phone and wear, own Gradle configuration, entry points) -> phases A, B, C and the build in D; scope bullet 1 (debug build, provisional ids, one shared id) -> A (the one declaration), B and C (applied), D (badging); bullet 2 (own versions, tooling, resources; no dependency on the checkout) -> A (catalog, wrapper), B and C (resources), D (independence grep); bullet 3 (nothing signed, published, uploaded) -> D (grep for signing) and the absence of any release step; constraint "upstream untouched" -> D criterion 8. Spec-pass findings: contract boundary (PACKAGE-VERSIONING) -> phase A (sentinels) and phase E (pointer, carried work); build command and time -> phase E (`CLAUDE.md`); questions 6 and 9 inherited from S0001 -> phase E (carriers). Out-of-scope: any test, lint or release-variant build (no test exists; nothing above 5 s beyond the named debug build), the version derivation code and parity gate (S0008), launcher icon and branding (S0008), every feature (S0003 to S0006).

Produces/consumes - A produces the wrapper, the root files, the version catalog aliases and the properties (id, sentinels); B and C consume A and produce the two modules; D consumes A, B and C and produces the measured times; E consumes D (the times) and the facts of A to C. No phase consumes what a later one produces.

- [x] **A. Toolchain and root** - files: `settings.gradle.kts`, `build.gradle.kts`, `gradle.properties`, `gradle/libs.versions.toml`, the wrapper (`gradlew`, `gradlew.bat`, `gradle/wrapper/*`, generated by the cached Gradle 9.4.1, not copied from a sibling), `local.properties` (machine-specific, ignored). Check: each file exists; `gradle.properties` declares the id once and the three sentinels; the wrapper task ran under the Build lock and exited 0.
- [x] **B. Phone module** - files: `phone/build.gradle.kts`, `phone/src/main/AndroidManifest.xml`, one launcher activity, one layout, `values/strings.xml`, `values/themes.xml`. Check: each file exists; the manifest names the launcher activity; the build file reads the id and the phone code from properties and sets no suffix. The release variant (minify, shrink, proguard file) is not declared: it cannot be proven between releases, so S0008 declares and builds it together.
- [x] **C. Wear module** - files: `wear/build.gradle.kts`, `wear/src/main/AndroidManifest.xml` (watch feature, standalone flag), one Compose launcher activity, `values/strings.xml`. Check: as B, with the wear code and the watch feature.
- [x] **D. Build and evidence** - run, in order: the build under the Build lock (cold), the same build again (warm), `aapt2 dump badging` of both APKs, the independence and no-signing greps. Phase-boundary audit of A to C before this step (static). Check: criteria 1 to 4.
- [x] **E. Records** - files: `README.md` (one sentence, found stale), `CLAUDE.md` (sections 3, 5, 6), `docs/contracts/PACKAGE-VERSIONING.md`, `PLAN/S0008_independent-release.md` (the carried questions). Check: criteria 5 to 7.

Read against the plan: the level stands, no decision is hidden in it.

## Open questions

1. **Application id (one id shared by phone and wear) and its freeze.** Status: Open. S0002 builds under `com.sza.deviceinfo.provisional`, which is not an anchor. Carrier: S0008
2. **Package versioning: derivation code, fixed-instant test, parity gate and the band-table row for the family.** Status: Open. The profile is chosen (Android, answered here); the sentinels are written; the rest needs the final application id and is the first step before a release. Carrier: S0008
3. **A local git repository for this tree.** Status: Open. No step of this ticket needs it; the owner decides whether and when. Carrier: S0008
4. **Is a launcher icon and a product label beyond the working name needed for a debug build?** Status: Resolved - no. A debug skeleton runs with the default icon; branding is an owner decision in S0008.
5. **Which platform levels and toolchain pins?** Status: Resolved - the upstream values and the sibling products' working set (see Owner inputs).

## Last Audit

**Date:** 26-11-10 22:36 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 12 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 4 | RELEASE 0

Evidence, each run fresh in this pass (expected | actual):

1. Build, `gradlew.bat :phone:assembleDebug :wear:assembleDebug` from the root, under the Build lock: exit 0 and `BUILD SUCCESSFUL` | exit 0, "BUILD SUCCESSFUL in 2m 10s", 70 tasks executed, 130.9 s wall; the same command after the last edit: exit 0, "BUILD SUCCESSFUL in 3s", 70 up-to-date, 3.9 s wall; `phone-debug.apk` 6 764 694 bytes and `wear-debug.apk` 20 429 409 bytes exist. PASS. This is the debug build the ticket's own acceptance names, the one run above 5 s; no test, lint or release variant ran.
2. `aapt2 dump badging` of both APKs: one package name, the sentinel pair, the watch feature in the wear APK | package `com.sza.deviceinfo.provisional` in both; versionName `2.61.1100.000` in both; versionCode `261110000` (phone) and `261110006` (wear); minSdk 26 and 28, targetSdk 36 and compileSdk 37 in both; `android.hardware.type.watch` in the wear APK only. PASS.
3. Independence: no `FastMediaSorter` reference outside comments, no `includeBuild`, no path outside the tree | the search over the six build files found two hits, both comments naming where the pins come from (hits inside comments are not evidence); no `includeBuild`, no drive path; the build ran from this root. PASS.
4. No decision by assumption: no signing configuration, keystore reference or `applicationIdSuffix` in code, no `LICENSE`, no `.git`, the id declared once | the search over the build files hit three comment lines that say "no applicationIdSuffix" and no code line; `LICENSE` and `.git` absent; `com.sza.deviceinfo.provisional` appears once, `gradle.properties` line 23, and both modules read it as a property. PASS.
5. `CLAUDE.md` sections 3, 5 and 6 match the tree | section 6 carries the command, 130.9 s and 4.4 s (the first no-op re-run; the later one measured 3.9 s) and the split between the fast tier and the release tier; sections 3 and 5 name the provisional id, the root files and the PACKAGE-VERSIONING declaration; `README.md` sentence corrected (it said the project does not build). PASS.
6. Pointer and carried work | `docs/contracts/PACKAGE-VERSIONING.md` exists and cites the contract by id and section; `PLAN/S0008_independent-release.md` carries the four inherited items; open questions 1 to 3 here end in `Carrier: S0008`. PASS.
7. `spec_catalog/validate` | exit 0, Summary 10 OK, 0 WARN, 0 FAIL. `release-queue -Validate` | exit 0, "OK - 8 ticket(s), no drift". Compliance gate from the installed plugin | exit 0, 0 error(s), 1 warning(s). Durable-evidence check | exit 0, no load-bearing evidence under the scratch folder. PASS.
8. Launch on a device, phone: install, start, observe | emulator API 33: `Success`, `Status: ok`, resumed activity `com.sza.deviceinfo.MainActivity`, on-screen text "DeviceInfo", 0 lines in the crash buffer; app uninstalled afterwards, 0 `com.sza` packages left. PASS.
9. Launch on a device, watch: install, start, observe | Wear OS 2 emulator, API 28 (the minSdk floor of the wear module), characteristics `watch`: `Success`, `Status: ok`, resumed activity `com.sza.deviceinfo.wear.MainActivity`, on-screen text "DeviceInfo", 0 lines in the crash buffer; emulator process stopped. PASS. Not covered, and not claimed: real hardware, a round Wear OS 3 or newer image, rotation, process death, the Data Layer (does not exist yet), the release variant; the device scenarios of the port are S0007's.
10. Probe invariant | `check-probe-absent` exit 0, "No probe of this ticket remains in source"; the ticket is not in the needs-manual-test status. PASS.
11. Scope purity | every file written is in the plan: the root Gradle files, the wrapper, the catalog, `local.properties`, `phone/`, `wear/`, `CLAUDE.md`, `README.md`, the pointer, this record and the carried-items section of S0008's record (its journal row untouched); two deviations, both recorded in the plan (no release variant, and no root `clean` task, removed as dead weight); scratch stayed in the ignored scratch folder, nothing at the root; nothing parked; the active ticket never switched; the upstream checkout was only read. PASS.
12. House style and hygiene on the diff | no `...`, ellipsis or long dash in the prose and config written; every catalog entry has a use line in a module build file; comments state reasons (one id for two packages, sentinel rules), none restate the line; no catch, colour literal, logging or runtime stub. PASS.
13. Contract boundary: `PACKAGE-VERSIONING`. EXEMPT: the debug builds carry only the non-releasable sentinels of rules 6 and 7 and never reach a channel, so no catalog amendment is owed yet; the family joins the band table before it ships, the first step of S0008 (Carrier: S0008).
14. Release variant, unit tests and lint. EXEMPT: out-of-scope, none exists; S0008 declares and builds the release variant, S0003 adds the first test. No release command is named because none is declared.
15. Persona pass. EXEMPT: the only user-visible text is the product name on a debug skeleton; no flow, no failure state, no configuration.
16. Installed-plugin warning `SZA-CANON06` (the contrib record resolves from the canon checkout, not from the installed plugin). EXEMPT: carried unchanged from S0001, closed by the canon repository publishing the record, which a project session does not do.

### Action items

None for this ticket. Carried, each with its carrier in the open questions: the final application id, the version derivation and band-table row, the local git repository and the release variant (S0008).

### Manual / on-target

None open.
