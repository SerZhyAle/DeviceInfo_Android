# Release procedure - DeviceInfo for Android and Wear OS

The first release goes to Google Play only, phone and watch in one listing, under the application id `com.sza.deviceinfo`.
No sideload channel exists, so `INSTALL-TRUST` and `UPDATE-MANIFEST` stay unbound. **A release is run only on the owner's
order**: nothing here tags, pushes, uploads or publishes by itself, and the build side never does either.

## Owner decisions this procedure carries out (S0008, 2026-11-13)

- Application id `com.sza.deviceinfo`, shared by phone and watch, frozen since the Play Console app was created with it
  (2026-11-13).
- Signing: the key directory `P:\ANDROID\DeviceInfo_credentials` is outside this repository. Play App Signing: the
  product's own key is imported as the app signing key (possible only at the first release, so it is one-way) and a separate
  upload key signs the bundles. No key material, password or `keystore.properties` ever enters this tree.
- Public remote `SerZhyAle/DeviceInfo_Android`; the hosted privacy pages under `site/` are published from there.
- License MIT; store name `DeviceInfo`.

## Owner-only steps

These need the owner's hands, a console account or a physical device; the build side cannot do them.

1. **Create the upload key.** Done on 2026-11-14 by S0029: `P:\ANDROID\DeviceInfo_credentials` holds `upload-keystore.p12`
   (alias `upload`) with `keystore.properties` beside it, and the app signing key `app-signing-keystore.p12` (alias
   `appsigning`) with `app-signing.properties`; both are PKCS12, RSA 2048, valid 10000 days, and their passwords are only
   in those two properties files. The `keystore.properties` format: `storeFile` (a file name relative to that directory,
   or an absolute path), `storePassword`, `keyAlias`, `keyPassword`. The off-machine copy of the whole directory is still
   the owner's step: it is the only copy of both keys.
2. **Tell Gradle where the key is.** Done on 2026-11-14 by S0029: `deviceinfo.signing.dir=P:/ANDROID/DeviceInfo_credentials`
   is in `%USERPROFILE%\.gradle\gradle.properties`. The same line, or the environment variable `DEVICEINFO_SIGNING_DIR`,
   is how another machine is set, the way the build JDK is set. Without it every release packaging task stops with a
   message that says exactly this.
3. **The Play Console app** `com.sza.deviceinfo` was created on 2026-11-13 on the owner's order (personal account, App,
   Free; the package name is bound to the account from that day). Done there: every App content declaration from
   `docs/play/PLAY_DATA_SAFETY.md` (privacy URL, no restricted access, no ads, audience 18 and over, no advertising ID, not a
   government app, no financial or health features, Data safety "no data collected or shared", a fresh IARC questionnaire:
   ESRB Everyone, ClassInd L), store settings (Tools, `sza@ukr.net`, the landing as website), the default listing saved as
   a draft in en-US, ru-RU and uk from `docs/play/PLAY_LISTING.md` with the icon and the feature graphic, and the Wear OS
   form factor added. On 2026-11-15 (S0029) four phone screenshots and three watch screenshots per listing language were
   uploaded from the `Pixel_9` and `Wear_OS_Large_Round` emulators and the listing saved, so all setup tasks are done and the
   Wear OS form reads "1 of 3 complete". On 2026-11-15 (S0014) the Google-generated app signing key that the console
   created with the app was replaced by the product's own key (SHA-256 `25:2C:D1..`) through App signing > Change key,
   the upload key was registered, both bundles went to internal testing, the Wear OS opt-in was accepted and the first
   production release was sent for review. `pepk.jar` does not run on an Oracle JDK (its JCE refuses the unsigned
   BouncyCastle inside the jar: `NoSuchAlgorithmException: RSA/NONE/OAEPWithSHA1AndMGF1Padding`); put a signed
   `bcprov-jdk18on` jar (the Gradle cache holds one) first on the classpath and run the main class
   `com.google.wireless.android.vending.developer.signing.tools.extern.export.ExportEncryptedPrivateKeyTool`, or use an
   OpenJDK.
4. **The remote** `SerZhyAle/DeviceInfo_Android` (public, created 2026-11-13, branch `main`) deploys `site/` to its Pages
   address (`https://serzhyale.github.io/DeviceInfo_Android/`) through `.github/workflows/pages.yml` on every push to `main`
   that touches `site/` or `tools/site/`, so the privacy URL answers before the Play submission. The same deploy publishes
   the landing in three locales (S0012); the workflow runs `pwsh -NoProfile -File tools/site/render-landing.ps1 -Check`
   first and refuses to deploy unless it exits 0 - run it locally before the push too. The landing's Google Play button names the listing of the application id, so it answers only once
   the listing is published (see "After the site and the listing are live").
5. **Screenshots** of the phone app and the watch app from real devices, uploaded to the listing.

## The release run

Take the Build lock first (`Enter-BuildLockOrExit` of the canon's `locks/agent-lock.ps1`); another session may build at the
same moment.

1. **Fast gates**, all must exit 0:
   `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate`,
   `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/release-queue -Validate`,
   `pwsh -NoProfile -File tools/port-ledger/check-drift.ps1`,
   `pwsh -NoProfile -File tools/port-ledger/check-scope.ps1`,
   `pwsh -NoProfile -File tools/port-ledger/check-local-divergence.ps1 -RequireClassified`,
   `pwsh -NoProfile -File tools/docs/check-surfaces.ps1`,
   `pwsh -NoProfile -File tools/docs/check-docs.ps1` (exit 0; a `PASS WITH ADVISORIES` verdict is read, not skipped: each advisory is a rule 4 gap the release notes),
   `pwsh -NoProfile -File tools/store/render-store-assets.ps1 -Check` (exit 0: the listing graphics and the landing's social card equal their render, S0036),
   `pwsh -NoProfile -File tools/parity/check-matrix.ps1`,
   `pwsh -NoProfile -File tools/design/check-tokens.ps1`,
   `pwsh -NoProfile -File tools/contracts/check-pointers.ps1`,
   `java phone/src/test/java/com/sza/deviceinfo/ui/PhoneUiSizingResources.java`,
   `java wear/src/test/java/com/sza/deviceinfo/wear/ui/WearUiSizingResources.java`,
   `pwsh -NoProfile -File tools/release/check-version-parity.ps1`,
   `java phone/src/test/java/com/sza/deviceinfo/service/WearPayloadParity.java phone/src/main/kotlin/com/sza/deviceinfo/domain/model/WearSystemInfoReportPayload.kt wear/src/main/kotlin/com/sza/deviceinfo/wear/data/wear/WearSystemInfoReportPayload.kt`,
   and the canon compliance gate `tools/check-compliance.ps1`
   from the installed plugin root. The **contract gate** (RELEASE_AND_DISTRIBUTION section 2) reads the registry rows that
   `docs/contracts/README.md` lists: run `contract-lag.ps1 -Product DeviceInfo` from the plugin root's `tools/` folder (it
   lists the 13 rows), write a `Verified` date into each of them from the evidence of this run (S0007, S0023, S0024 and the
   checks above), and see that the canon-layer rows the register names as owned by S0026 exist. A row that stays `pending`
   is reported in the verdict, not passed.
2. **Tests.** `.\gradlew.bat -p buildSrc test` (the fixed-instant vectors of `VersionStampTest` and `ReleaseSigningTest`),
   `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest` (the bare `:phone:testDebugUnitTest` is ambiguous under the `distribution` flavors).
3. **Pin the version.** `pwsh -NoProfile -File tools/release/new-version-pin.ps1` prints the three Gradle properties and the
   tag name for the instant of the run: `-Pdeviceinfo.pin.versionName=.. -Pdeviceinfo.pin.versionCode.phone=..
   -Pdeviceinfo.pin.versionCode.wear=..` and `tag v<versionName>`. The versionName is byte-identical in both packages, the
   codes sit in the disjoint bands of the two families, and buildSrc stops a pin that is not one instant of each partition.
3a. **Help screenshots (S0032, CONTEXT-HELP rung 2).** The help pages carry a picture of the real screen per locale and
   theme, captured against the pinned version, so this step needs the pin of step 3 and a device. Build the debug
   packages with the pin (`.\gradlew.bat :phone:assembleDebug :wear:assembleDebug` with the three pin properties); start a
   phone or emulator on API 33 or newer (the per-app language) and a Wear OS device or emulator; run
   `pwsh -NoProfile -File tools/help/capture-help.ps1 -PhoneSerial <serial> -WearSerial <serial> -ProductVersion <versionName>`
   (it refuses to record the build sentinel, and stops without writing when a capture fails its own proof of language or theme),
   then `pwsh -NoProfile -File tools/help/render-help.ps1`. On the first adoption read what the capture recorded as absent
   (parts the screen does not show: overflow entries, the watch's Help row at the end of the list), then
   `pwsh -NoProfile -File tools/help/check-help-captures.ps1 -WriteBaseline` once. Then
   `pwsh -NoProfile -File tools/help/check-help-captures.ps1 -Require -ExpectVersion <versionName>` and
   `pwsh -NoProfile -File tools/help/check-help-map.ps1` exit 0, and a person looks at the rendered pages: every pin on the
   part it names, in en, ru and uk, in both themes, demo content only. The pictures, the records and the pages are committed
   with the release commit.
4. **Notices and telemetry claim.** Run `.\gradlew.bat :phone:dependencies --configuration storeReleaseRuntimeClasspath`
   (the phone module has the flavors `store` and `restricted`, S0009; only `store` has a release variant and ships) and
   `.\gradlew.bat :wear:dependencies --configuration releaseRuntimeClasspath`; every group id they list is named in `phone/src/main/assets/THIRD-PARTY-NOTICES.txt` and none is an
   analytics, advertising or tracking library.
5. **Build both bundles with the pin:**
   `.\gradlew.bat :phone:bundleRelease :wear:bundleRelease -Pdeviceinfo.pin.versionName=.. -Pdeviceinfo.pin.versionCode.phone=..
   -Pdeviceinfo.pin.versionCode.wear=..`. The release variant minifies and shrinks resources; lint-vital runs inside it. `:phone:bundleRelease` covers the `store`
   flavor alone: the `restricted` flavor (S0009) has no release variant, so it cannot be packaged, signed or uploaded by this
   command.
6. **Read the packages back** (P5): `pwsh -NoProfile -File tools/release/read-package-info.ps1 <bundle or apk>
   -ExpectedName <versionName> -ExpectedCode <that family's code> -AllowedPermissions ..` for each of the two artifacts
   (an `.aab` needs `-BundletoolJar`). The allowed lists are `ACCESS_NETWORK_STATE,POST_NOTIFICATIONS` for the phone and
   `ACCESS_WIFI_STATE` for the watch; the check refuses `INTERNET`.
7. **Run the release variant on a device.** R8 and Gson are proven only on the release build: install the signed release
   packages on a phone and a watch (a universal APK from `:phone:assembleRelease` and `:wear:assembleRelease` with the same pin) and run
   **Send to phone** end to end, then open every report section of the phone app. A crash or an empty report stops the release.
8. **Update over a prior install.** The first package has no prior install; the proof is recorded as not applicable for the
   first version and becomes mandatory from the second one (canon invariant 6).
9. **The ship step, on the owner's order only.** Upload the two bundles to the Play Console (internal testing first),
   write the release notes from `docs/play/PLAY_LISTING.md` and `CHANGELOG.md`, move `[Unreleased]` of the changelog under
   the new version, tag `v<versionName>` and push.

## After the site and the listing are live (S0012)

Owner or release flow, in this order; none of it runs between releases, and none of it blocks the build side.

1. **Live checks.** `curl -s -o /dev/null -w "%{http_code} %{url_effective}\n" -L <url>` answers 200 for the landing
   (`https://serzhyale.github.io/DeviceInfo_Android/`, `.../ru/`, `.../uk/`), the three privacy pages, `sitemap.xml`, and the
   Google Play listing `https://play.google.com/store/apps/details?id=com.sza.deviceinfo`. Then run `/site-audit` for this
   repository (the live lenses: robot, ux, structured data, i18n, docs); its `prepublish` form judges the source tree.
2. **The `SITE-FAMILY-MAP` row.** Only after the three landing URLs answer (rule 5 of that map: a URL enters the table once
   it answers), file the row to the hub with `spec-draft.ps1 -Project hub`: Tool `DeviceInfo`, Type `Android and Wear OS
   device information`, URL `https://serzhyale.github.io/DeviceInfo_Android/`, Help index `-`. Adding a tool is additive
   (MINOR, section 4 of the map) and adds one entry to the footer grid of every other product page. The nine entries that this
   landing carries are held in `tools/site/render-landing.ps1`; a row added to the map is added there and in the three
   dictionaries' `types` list in one edit.
3. **What's new.** At the first release the release flow renders a dated "What's new" page from `CHANGELOG.md`
   (`DOCUMENTATION_CONCEPT` section 4); until then the landing links the changelog source on GitHub. The landing shows no
   version: the product ships on Google Play only, so the store page is its durable link (`PAGE-STYLE` 3.10 item 3).
4. **Screenshots.** The real-device screenshots of the phone and the watch (owner step 5) may be added to the landing as one
   more block of the template; the page does not claim them until they exist.
5. **The Play price.** The landing's structured data says price 0 (`offers`); if the console price is not zero, change it in
   `tools/site/render-landing.ps1` and render again.
