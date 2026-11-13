# S0008 - Independent release preparation

**Ticket:** S0008
**Status:** BlockQuestions
**Status note:** In-repo release preparation done 2026-11-13 (id, version stamp with parity gate, release variant, icons, notices, privacy pages, listing, canon declarations); compiled, not tested: no compile command. Waiting on the owner. DO: create the upload keystore in P:\ANDROID\DeviceInfo_credentials with keystore.properties and set deviceinfo.signing.dir. DO: create the Play Console app, file the IARC questionnaire, import the app signing key. DO: create the remote SerZhyAle/DeviceInfo_Android and deploy site/. DO: take phone and watch screenshots. Q: Should the first Google Play release wait for S0011 and S0013?
**Priority:** 40
**Tier:** 3 - Moderate
**Complexity:** hard - re-assessed 2026-11-13 at the unattended implementation pass, after reading the ticket, `PACKAGE-VERSIONING` 0.6 and the sibling precedents. The work spans both Gradle modules and the build logic (application id, version derivation with a fixed-instant test and a parity gate, a signed and minified release variant that R8 and Gson make provable only on the release build), a new shared-contract amendment that only a catalog session can fold in, a new site tree with three-locale privacy pages, a launcher icon, store listing sources, notices and canon declarations, and it ends in owner-only steps (keystore, Play Console, IARC questionnaire) plus release-tier proof that cannot run between releases.
**Depends on:** S0007

## Goal

Prepare the first independent release packages for phone and Wear OS, configure release automation, and settle release deliverables under owner direction.

## Scope and acceptance

- Establish release pipeline in accordance with SZA canon release requirements.
- Produce verified release APK/AAB packages under owner-designated signing keys and frozen application IDs.
- Complete release documentation, changelog, and distribution readiness.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0007 parity check; final milestone of initial backlog.
- **Published application id:** Answered 2026-11-13 - `com.sza.deviceinfo`, one id for phone and watch; it becomes a frozen anchor with the first shipped package and replaces `com.sza.deviceinfo.provisional` in `gradle.properties` in one edit.
- **Signing:** Answered 2026-11-13 - key directory `P:\ANDROID\DeviceInfo_credentials` (outside this repository); Play App Signing with the product's own key imported as the app signing key plus a separate upload key. No key material belongs in the ticket.
- **Distribution and identity:** Answered 2026-11-13 - first release on Google Play only (phone and watch in one listing), no sideload channel; public GitHub remote `SerZhyAle/DeviceInfo_Android`; a dedicated page in the site family (SITE-FAMILY-MAP) with a hosted privacy page in en, ru and uk under `site/` of this repository; store name `DeviceInfo`, and a launcher icon is created because neither manifest declares `android:icon`.
- **License:** Answered 2026-11-13 - MIT. The `LICENSE` file is added by the implementation of this ticket, which also closes the `SZA-LAY01` exemption (expires 2027-02-10).
- **Local git repository:** Answered 2026-11-13 - yes, initialized during the implementation of this ticket; commits, tags, the remote creation and every push stay on the owner's order. Done 2026-11-13: `git init -b main`, no commit.
- **DO:** create the upload keystore in `P:\ANDROID\DeviceInfo_credentials` with `keytool`, write `keystore.properties` beside it (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`), keep the app signing key there for the Play import, and set `deviceinfo.signing.dir=P:/ANDROID/DeviceInfo_credentials` in `%USERPROFILE%\.gradle\gradle.properties`. The release variant refuses to package without it, and the signed release build, the R8 run on a device and the Play upload need it.
- **DO:** in the Play Console create the app `com.sza.deviceinfo`, enter the listing from `docs/play/PLAY_LISTING.md`, the Data safety and app content answers from `docs/play/PLAY_DATA_SAFETY.md`, file a fresh IARC questionnaire, opt the app in to the Wear OS form factor, and import the app signing key at the first upload (one-way) with the upload key registered.
- **DO:** create the public remote `SerZhyAle/DeviceInfo_Android`, push the tree, and deploy `site/` to `https://serzhyale.github.io/DeviceInfo_Android/` so the privacy URL answers before the Play submission.
- **DO:** take screenshots of the phone app and the watch app on real devices (the device check of S0007 produces them) and upload them to the listing.
- **Open (scope):** Q: Should the first Google Play release wait for S0011 and S0013? See `### Questions (v1, 2026-11-13)`.

## Spec pass (2026-11-11)

- **Rung:** complex. The work changes multiple modules, release automation and a shared contract, and requires non-deterministic owner decisions.
- **Dependency:** S0007 is in `BlockNeedUserTest`; its static parity work has reached the readiness status that releases a dependent. Its on-device verification remains open and is not a release pass.
- **Settled from existing records:** phone and watch share an application id and Data Layer pair; the current id and version pairs are explicitly non-releasable sentinels. The Android versioning profile and disjoint phone/watch code bands are already chosen.
- **Shared-contract boundary:** `PACKAGE-VERSIONING` is consumed. Its family band-table row needs a MINOR catalog amendment and the chosen application id before the first package ships; catalog changes require a catalog session. Any additional install-trust or web-page contracts depend on the chosen channels. No boundary implementation precedes an amendment that changes that boundary.
- **Required research still open:** determine channel-specific release, signing, privacy and listing requirements after the owner's choices; verify the versioning catalog amendment and conformance obligations before planning the relevant implementation.
- **Documentation context:** no `docs/DOCUMENT_REGISTRY.jsonl` is present. The existing `PACKAGE-VERSIONING` pointer and project rules identify release documentation affected by the eventual choices; no product documentation is changed in this spec pass.
- **Gate:** owner inputs and required research are open, so approval, tactical planning and implementation cannot start. This unattended pass records the missing decisions for a later quiz rather than choosing them.

## Open questions

All five answered in the 2026-11-13 quiz (see `### Quiz decisions (2026-11-13)` below).

1. ~~Which shared published application id is authorized for permanent freeze?~~ resolved: `com.sza.deviceinfo`.
2. ~~Which signing key and external location are authorized, and which Play signing mode applies if Play is selected?~~ resolved: `P:\ANDROID\DeviceInfo_credentials`; own key imported as app signing key plus a separate upload key.
3. ~~Which channels and public remote are authorized; what site, privacy page, store name and branding apply to them?~~ resolved: Google Play only; `SerZhyAle/DeviceInfo_Android`; site-family page with hosted privacy page (en, ru, uk); name `DeviceInfo`, new launcher icon.
4. ~~Which license should the product use?~~ resolved: MIT.
5. ~~Should a local git repository be initialized for the future release tag workflow?~~ resolved: yes, during implementation.

## Carried from S0002

Open questions S0002 handed to this ticket, none answered by assumption:

1. **Application id and its freeze.** S0002 built phone and wear under the provisional `com.sza.deviceinfo.provisional`, declared once as `deviceinfo.applicationId` in `gradle.properties`. The published id replaces it there, in one edit, and is then a frozen anchor.
2. **Package versioning.** The Android profile is chosen; sentinels exist (`deviceinfo.sentinel.*` in `gradle.properties`). Still owed before the first package ships: the derivation code with its fixed-instant test, the parity gate for the sentinels, the pin of the versionName and versionCode pair, and the band-table row for this family in the `PACKAGE-VERSIONING` catalog (a MINOR amendment that needs the final application id).
3. **A local git repository.** No build or ticket step needs one; the tag step does.
4. **The release variant.** S0002 declares no `release` build type (no minify, shrink, proguard file or signing), because it cannot be proven between releases. It is declared and built here, together with the signing decision.

### Quiz decisions (2026-11-13)

All nine rows were put to the owner as one table and accepted with the table (the owner's click: "accept all recommendations"); each row was the researched recommendation, none was applied without that click. Precedent read for the recommendations: the sibling Android products StreamsPlayer_mob and Tourist_mob (owner decisions of 2026-10-02 and 2026-10-10) and the FastMediaSorter upstream license.

- Published application id -> `com.sza.deviceinfo`, shared by phone and watch (same prefix as the provisional id and as `com.sza.streamsplayer` and `com.sza.tourist`; frozen with the first shipped package; also settles item 1 of "Carried from S0002").
- Signing key location -> `P:\ANDROID\DeviceInfo_credentials`, outside the repository (same pattern as `StreamsPlayer_credentials` and `FastMediaSorter_credentials`).
- Play signing mode -> the product's own key imported as the Play app signing key plus a separate upload key (store and sideload builds then carry one signature; the import is only possible at the first release, so the choice is one-way).
- Channels of the first release -> Google Play only, phone and watch in one listing; no sideload or GitHub Releases APK channel, so `INSTALL-TRUST` and `UPDATE-MANIFEST` stay unbound (same shape as StreamsPlayer_mob after its S4203 decision B39).
- Public remote -> GitHub `SerZhyAle/DeviceInfo_Android`, public (named by analogy with `SerZhyAle/StreamsPlayer_Android`); creating it and pushing stay on the owner's order.
- Site and privacy -> a dedicated page joining the site family (SITE-FAMILY-MAP) and a hosted privacy page in en, ru and uk, sources under `site/` of this repository; required because a declared Play channel makes the compliance gate `SZA-SURF01` demand a hosted privacy page, and the page, the permission list and the Data safety answers must say the same thing.
- Store name and branding -> store name `DeviceInfo` (the current `app_name` of both modules); a launcher icon is created by the implementation of this ticket because neither `phone` nor `wear` declares `android:icon` and the Play listing needs a 512 px icon.
- License -> MIT, same as StreamsPlayer_mob and Tourist_mob; the upstream FastMediaSorter is Apache-2.0 under the same copyright holder. The `LICENSE` file is added here and the `SZA-LAY01` exemption in `.sza-canon.json` is closed.
- Local git repository -> yes; `git init` during the implementation of this ticket, because the tag step and the remote need it. Commits, tags and pushes only on the owner's order.

Resolved without asking: none beyond the above. Not asked and still owed by the implementation, not decided here: generating the keystore and its password handling, creating the Play Console app and importing the key, the `PACKAGE-VERSIONING` band-table row (needs a catalog session and now has its application id), the derivation code and parity gate, the `release` build type, the `.sza-canon.json` channel, site and privacy declarations, a fresh IARC questionnaire, `THIRD-PARTY-NOTICES.txt` where third-party binaries are bundled, and a per-permission justification for `POST_NOTIFICATIONS` (phone) and `WAKE_LOCK` (watch).

## Plan pass (2026-11-13, unattended)

- **Rung:** complex, as the spec pass said; the pass carried out the in-repository half of the ticket and parked the rest. **Complexity:** `hard`, re-assessed at this pass (header line); the plan agrees with it.
- **Coverage inventory.** Every goal, owner decision and carried item mapped to a phase or a disposition:

| Line | Phase or disposition |
| --- | --- |
| Published id `com.sza.deviceinfo`, one edit | P1 - `gradle.properties`, comments of both build files |
| Version derivation, fixed-instant test, parity gate, pin, tag shape (Carried 2) | P2 - `buildSrc`, root and module scripts, `tools/release/` |
| Release variant with minify, shrink, signing (Carried 4) | P3 - module scripts, `proguard-rules.pro`, `ReleaseSigning` |
| Signing key location, Play App Signing | P3 - configured by directory only; the keystore is an owner step (DO) |
| Google Play only, no sideload channel | P4 - `.sza-canon.json` `channels: ["play"]`; `INSTALL-TRUST`, `UPDATE-MANIFEST` stay unbound |
| Site, hosted privacy page en, ru, uk, `SZA-SURF01` | P4 - `site/`, vendored kit, declarations; the landing is out-of-scope here, parked as S0012 |
| Store name `DeviceInfo`, launcher icon | P5 - icon resources in both modules, `docs/play/` listing and graphics |
| License MIT, close `SZA-LAY01` | P4 - `LICENSE`, empty `exemptions` |
| Local git repository | P4 - `git init -b main`, no commit |
| `THIRD-PARTY-NOTICES.txt` | P5 - asset in both packages, byte-identical pair declared |
| Per-permission justification, `POST_NOTIFICATIONS`, `WAKE_LOCK` | P5 - `docs/SECURITY_INVENTORY.md`; `WAKE_LOCK` dropped as unused; the missing run-time request is parked as S0011 |
| Fresh IARC questionnaire | P5 - answers written in `docs/play/PLAY_DATA_SAFETY.md`; filing is an owner step (DO) |
| Band-table row in the catalog (Carried 2) | P2 - proposal filed beside the contract; folding it in is the catalog owner's |
| Release documentation, changelog | P5 - `docs/RELEASE.md`, `CHANGELOG.md`, `README.md`, `CLAUDE.md` |
| Verified release packages under the owner's key | out-of-scope between releases: `RELEASE` items below, needs the DO keystore |

- **Produces and consumes.** P1 produces the id that P2 and the proposal quote; P2 produces `VersionStamp` that P3's module scripts consume; P3 produces the signing contract that `docs/RELEASE.md` (P5) describes; P4 declares what P5's pages and files make true. No phase consumes a later one.
- **Self-review:** every inventory line maps to a written step or a disposition; every symbol the scripts consume (`VersionStamp.select`, `PackageFamily`, `ReleaseSigning.load`, `PACKAGING_TASKS`, `BUILD_INSTANT`) is declared in `buildSrc/src/main/kotlin/com/sza/deviceinfo/buildlogic/`.

## Implementation record (2026-11-13)

Files written or changed, by phase:

- **P1:** `gradle.properties` (id `com.sza.deviceinfo`, comments), `phone/build.gradle.kts`, `wear/build.gradle.kts`.
- **P2:** `buildSrc/build.gradle.kts`, `buildSrc/settings.gradle.kts`, `buildSrc/src/main/kotlin/com/sza/deviceinfo/buildlogic/VersionStamp.kt`, `buildSrc/src/test/kotlin/com/sza/deviceinfo/buildlogic/VersionStampTest.kt` (16 tests), root `build.gradle.kts`, `tools/release/VersionStamp.ps1`, `check-version-parity.ps1`, `new-version-pin.ps1`, `read-package-info.ps1`, `docs/contracts/PACKAGE-VERSIONING.md`, and the proposal `PROPOSAL-2026-11-13-deviceinfo-android-bands.md` in the catalog's `package-versioning/` folder.
- **P3:** `buildSrc/.../ReleaseSigning.kt`, `.../ReleaseSigningTest.kt` (7 tests), the `signingConfigs`, `buildTypes.release` and `gradle.taskGraph.whenReady` blocks of both module scripts, `phone/proguard-rules.pro`, `wear/proguard-rules.pro`.
- **P4:** `LICENSE`, `.sza-canon.json`, `.gitignore`, `.gitattributes`, `site/` (three privacy pages, `assets/sza-kit.css`, `policy.css`, `PROVENANCE.txt`, `icon-512.png`, `robots.txt`, `sitemap.xml`, `.nojekyll`), the local `.git`.
- **P5:** icon resources in both modules (`mipmap/`, `mipmap-anydpi-v26/`, `drawable/ic_launcher_foreground.xml`, `values/ic_launcher_background.xml`), both manifests (icon, `allowBackup`, permissions), `app_name` marked not translatable, the two `THIRD-PARTY-NOTICES.txt` assets, `tools/store/render-store-assets.ps1`, `docs/play/` (listing, Data safety, two graphics), `docs/SECURITY_INVENTORY.md`, `docs/RELEASE.md`, `docs/README.md`, `CHANGELOG.md`, `README.md`, `CLAUDE.md`.

### Assumed (unattended, 2026-11-13)

Each was taken as the researched recommendation and is reversible inside the ticket; the owner may overrule any of them.

- **The pin is three properties, passed together.** `deviceinfo.pin.versionName` plus one code per family, because one invocation builds both packages and the codes differ by band. Alternative: one pair per invocation, validated against the module's family (one pinned build per package). Owner may overrule.
- **The release tag is `v` + the versionName** (`^v\d+\.\d+\.\d+\.\d+$`, declared in `.sza-canon.json`), the shape of the sibling Android products. No tag exists yet. Owner may overrule.
- **Debug builds keep the sentinel; a release stamps itself.** An invocation that names a release task stamps from one clock reading unless it pins. Alternative: stamp every build. Owner may overrule.
- **The upload key is found by `deviceinfo.signing.dir` or `DEVICEINFO_SIGNING_DIR`,** not by a path typed into the build file, because the key directory is a machine-specific absolute path. Alternative: default to `P:\ANDROID\DeviceInfo_credentials` in the script. Owner may overrule.
- **The release variant minifies and shrinks resources,** with the two Gson wire classes of each module kept whole. Alternative: no minify for the first release (smaller R8 risk, larger packages). The R8 behaviour is proven only on the release build (`RELEASE` items). Owner may overrule.
- **Two unused watch permissions are dropped:** `WAKE_LOCK` and `ACCESS_NETWORK_STATE` have no consumer in `wear/src/main` (canon invariant 13). Alternative: keep the upstream list. Owner may overrule.
- **`android:allowBackup="false"`** in both packages, so the privacy page's statement that nothing leaves the device is literally true. Alternative: leave the Android default. Owner may overrule.
- **`app_name` is `translatable="false"`** (a brand name; it was the only key missing from `values-ru` and `values-uk`, which lint treats as fatal in a release build).
- **The launcher icon is an information glyph** (ring, dot, stem; white on `#0D47A1`) as an adaptive icon with a monochrome layer and a layer-list default; the Play graphics are rendered from the same geometry. Artwork is replaceable; re-run `tools/store/render-store-assets.ps1`. Owner may overrule.
- **The Pages address is `https://serzhyale.github.io/DeviceInfo_Android/`,** derived from the decided remote name by the sibling pattern; the canonical links of the pages use it. The pages are hand-authored sources, not generated, and use the child-page footer (contact and hub link, no family grid). Owner may overrule.
- **The landing page is split off** as the parked draft S0012: it needs device screenshots and a `SITE-FAMILY-MAP` row, and the privacy pages satisfy the compliance gate on their own.
- **The contact address is `sza@ukr.net`,** the author's contact that the sibling products already publish; no private address is used.
- **Console values:** category Tools, target audience 18 and over, the Website field is the GitHub repository until the landing exists, every IARC answer is none. Owner may overrule in the console.
- **`THIRD-PARTY-NOTICES.txt` is an asset of each package,** listing components and license links without pasted license text, kept as a byte-identical pair declared in `.sza-canon.json`. Alternative: one root file. Owner may overrule.
- **`privacy.sensitiveAccess` is true** in `.sza-canon.json`: the report shows values that identify the device in a network and the app writes the clipboard on request.
- **The band-table row is a proposal, not an edit,** and the registry row is left to the catalog session: the catalog is sealed to repository sessions (`RULES.md`).

## Evidence (2026-11-13)

- `pwsh -NoProfile -File tools/release/check-version-parity.ps1` - exit 0, `PASS (144 checks)`, 0.29 s. Negative case on a copy with the watch sentinel changed to 261110007: exit 1, `FAIL sentinel wear versionCode : expected 261110006 | actual 261110007`.
- `pwsh -NoProfile -File tools/release/new-version-pin.ps1 -Instant 2609262322` - exit 0, `versionName=2.60.9262.322`, codes 260926232 and 260926237 (the contract's own vectors); `-Instant 2613010000` is refused (exit 1, "has no month 13").
- `pwsh -NoProfile -File tools/release/read-package-info.ps1` on the existing debug APK - exit 0, reads package, 261110000, 2.61.1100.000 and the permission list back, 0.35 s. That APK is an old build of the provisional id; it proves the reader, not the release.
- `pwsh -NoProfile -File tools/store/render-store-assets.ps1` - exit 0; `icon-512.png` 512 x 512 and `feature-graphic-1024x500.png` 1024 x 500 opened and inspected.
- All XML files under `phone/src/main` and `wear/src/main` parse (0 malformed). String keys of `values-ru` and `values-uk` equal the base in both modules except `app_name`, now `translatable="false"`.
- `tools/check-compliance.ps1` from the plugin root - exit 0, 0 errors; `SZA-LAY01`, `SZA-VER03`, `SZA-SURF01`, `SZA-SURF02`, `SZA-SURF03`, `SZA-LAY02`, `SZA-LAY06` hold with the new declarations. Warning left: `SZA-CANON03`, the stale canon stamp, which `adopt-canon` handles and S0008 does not touch.
- `spec_catalog/validate` exit 0 (10 OK); `spec_catalog/release-queue -Validate` exit 0.
- `tools/port-ledger/check-drift.ps1` - **exit 1**: three uncarried upstream changes (BatteryDetailsCollector, PlatformDetailsCollector, SensorsDiagnosticsCollector), none from this ticket. Parked as S0013; the check must be at exit 0 at the release start.
- **Compile gate:** `commands.compileCheck` is absent from `.sza-profile.json`: no compile command. The pass edited compiled source (Kotlin build logic, three Gradle scripts, manifests, resources): **compiled, not tested** - nothing was compiled, and no Gradle run happened.

## Parked

- `S0011` phone-notification-permission-request: the phone never requests `POST_NOTIFICATIONS` at run time, so Send to phone from the watch is refused on a fresh Android 13+ install.
- `S0012` product-landing-page: the three-locale landing of the site family.
- `S0013` carry-upstream-drift-of-three-collectors: the release-start drift check is red.

## Release items (RELEASE: not run between releases)

Each names the command the release will run; all need the keystore of the DO above except the first three.

1. `.\gradlew.bat -p buildSrc test` - the 23 JUnit tests of `VersionStampTest` and `ReleaseSigningTest`; the first compilation of `buildSrc` and the root and module scripts.
2. `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug :phone:testDebugUnitTest :wear:testDebugUnitTest` - the debug build with the new scripts, icons and manifests; the unit suites.
3. `.\gradlew.bat :phone:dependencies --configuration releaseRuntimeClasspath` and the same for `:wear` - every group id is named in `THIRD-PARTY-NOTICES.txt`, none is an analytics, advertising or tracking library.
4. `.\gradlew.bat :phone:bundleRelease :wear:bundleRelease` with the pin of `tools/release/new-version-pin.ps1` and `-Pdeviceinfo.signing.dir` - R8, shrunk resources, lint-vital and the signing of the real bundles.
5. `tools/release/read-package-info.ps1` on each produced artifact with `-ExpectedName`, `-ExpectedCode` and `-AllowedPermissions` - the stamp and the merged permission list read back; `INTERNET` refused.
6. The release variant on a phone and a watch: Send to phone end to end and every report section opened (Gson under R8).
7. The privacy pages live at their Pages address, and `site-audit` over them.

## Questions

### Questions (v1, 2026-11-13)

- Q: Should the first Google Play release wait for S0011 and S0013?
  - Wait for both, then release (recommended) - the watch's Send to phone works on a fresh Android 13+ install and the parity check is at exit 0 before anything ships
  - Release now and fix both in the second release - ships sooner, but a fresh Android 13+ install refuses the watch send until the user finds the system notification settings, and the parity check stays red
  - Wait for S0013 only - parity is clean and the notification gap ships
- DO: create the upload keystore in `P:\ANDROID\DeviceInfo_credentials`, write `keystore.properties` beside it, and set `deviceinfo.signing.dir` in `%USERPROFILE%\.gradle\gradle.properties`.
- DO: create the Play Console app `com.sza.deviceinfo`, enter the listing, the Data safety and app content answers, file the IARC questionnaire, opt in to Wear OS and import the app signing key.
- DO: create the remote `SerZhyAle/DeviceInfo_Android`, push, and deploy `site/` to its Pages address.
- DO: take phone and watch screenshots on real devices and upload them to the listing.

## Last Audit

**Date:** 26-11-13 | **Mode:** static | **Outcome:** Partial
**Counts:** PASS 10 | WARN 2 | FAIL 0 | MANUAL 5 | UNCHECKABLE 0 | EXEMPT 1 | RELEASE 7

### Action items
1. Compliance warning `SZA-CANON03` (stale canon stamp) - `.sza-canon.json` - run `adopt-canon`; not part of this ticket, left as it was.
2. The release-start drift check exits 1 - `tools/port-ledger/check-drift.ps1` - S0013 carries or decides the three files; the release cannot start until it is at exit 0. EXEMPT in the counts: the product landing page, parked as S0012.

### Manual / on-target
- [ ] The upload keystore exists and `deviceinfo.signing.dir` points at it; a release packaging task then proceeds instead of stopping with the refusal message.
- [ ] The Play Console app, listing, Data safety, IARC and Wear OS opt-in are filled from `docs/play/`, and the app signing key is imported.
- [ ] The remote exists, the tree is pushed and `https://serzhyale.github.io/DeviceInfo_Android/privacy.html` answers in en, ru and uk.
- [ ] Screenshots of the phone app and the watch app from real devices are in the listing.
- [ ] The release variant runs on a phone and a watch with Send to phone working end to end (counts as passing when a report sent from the watch arrives on the phone and every section of the phone report opens).
