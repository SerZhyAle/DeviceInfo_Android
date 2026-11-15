# S0029_play-owner-prep-keystore-screenshots

**Status:** Implemented
**Created:** 2026-11-13
**Complexity:** light - assessed at the spec pass (2026-11-14, unattended): no source, no build logic and no listing text changes; three owner actions (desk, phone and watch, console) whose checks are file, property and console observations. Not `medium` because nothing is left to decide for the build side; the effort is the owner's hands, plus one fresh debug build for the screenshots.

## 0. Owner request (verbatim)

Owner's answer (2026-11-13, spec-quiz sitting over deviceinfo-mob:S0014 play-first-publication), verbatim:
"Нужен другой тикет - на выполнение всех этих операций - а этот заблокирован новым тикетом"

The operations, as S0014 section 3.3 lists them (pre-implementation owner actions, DO lines):
1. Create the upload keystore in P:\ANDROID\DeviceInfo_credentials, write keystore.properties beside it, keep the app signing key there, and set deviceinfo.signing.dir in %USERPROFILE%\.gradle\gradle.properties. Checked 2026-11-13: the folder does not exist.
2. Take 2 to 8 phone screenshots on a real phone and upload them to the default Google Play listing of com.sza.deviceinfo.
3. Take the Wear OS screenshots for en-US, ru-RU and uk and upload them in the Play Console Wear OS form-factor step 1.

S0014 waits on this ticket (Blocker token in S0014). The first upload, the Wear OS opt-in and the production review stay in S0014 and run only on the owner's order.


## 1. Problem

DeviceInfo cannot be built for Google Play and its listing is incomplete, and three things only the owner can do stand in the way. The upload key does not exist, so every release packaging task stops with a message instead of producing a signed bundle. The default listing has no phone screenshots, so the store-listing task of the Play Console stays open (10 of 11 setup tasks). The Wear OS form factor has no watch screenshots in any of the three listing languages, so its step 1 stays open and the Wear OS opt-in cannot be reached. None of this is source work; the build side can only say exactly what to do, check the result, and keep the record.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat. The ticket is `Verified` only when all of them hold; criteria 1 and 2 are checkable from this repository's side, 3 to 6 are console and device observations that only the owner can make.

1. **Upload key present and readable by the build.** Run, in PowerShell, the check below; expected: five `True` lines (it prints presence and existence only, never a value).

   ```powershell
   $d = 'P:\ANDROID\DeviceInfo_credentials'; $p = @{}
   Get-Content "$d\keystore.properties" | ForEach-Object { if ($_ -match '^\s*([^#=\s]+)\s*=\s*(.*)$') { $p[$matches[1]] = $matches[2].Trim() } }
   'storeFile','storePassword','keyAlias','keyPassword' | ForEach-Object { "$_ present: " + ($p.ContainsKey($_) -and $p[$_] -ne '') }
   'storeFile exists: ' + (Test-Path (Join-Path $d $p['storeFile']))
   ```

   The check assumes `storeFile` is a file name relative to the directory (the form `docs/RELEASE.md` step 1 recommends). Observed 2026-11-14 at this pass: the directory does not exist - open.
2. **Gradle is told where the key is.** `Select-String -Path "$env:USERPROFILE\.gradle\gradle.properties" -Pattern '^deviceinfo\.signing\.dir='` prints one line whose value is `P:/ANDROID/DeviceInfo_credentials` (or `$env:DEVICEINFO_SIGNING_DIR` holds that directory). Observed 2026-11-14: property absent, variable unset - open.
3. **The app signing key exists next to the upload key.** The same directory holds a second keystore, for the Play App Signing import at the first upload (`docs/RELEASE.md` owner step 1, S0008 decision). The owner's observation: `keytool -list -keystore <file>` (the build JDK's `keytool`) shows one `PrivateKeyEntry` for each of the two files. Open.
4. **Phone screenshots are in the default listing.** The Play Console store-listing task shows 2 to 8 phone screenshots in the default listing and the dashboard reads 11 of 11 setup tasks. Each file is 16:9 or 9:16 with each side 320 to 3840 px (the console refuses others). They were taken from the `store` flavor, never from `restricted`, on a phone emulator (the owner's decision of 2026-11-14 replaces the real phone; see `### Quiz decisions (2026-11-14)`). Observed 2026-11-15: four 1080x1920 files (9:16, 24-bit PNG, no alpha) from the `store` debug build on the `Pixel_9` emulator are in the default listing (4 of 8, the console's promotion threshold of 4 is met); the dashboard no longer shows the "Set up your app" block, which is how the console reports all setup tasks done (the literal "11 of 11" line was not on screen after the last save). Met.
5. **Wear OS screenshots are in every listing language.** The console's Wear OS form-factor step 1 is complete for en-US, ru-RU and uk. Square (1:1) images, at least 384 px on a side, of the app interface only: no watch frame, no added text or background (Google's Wear OS rules since 2021-10-13, see Sources; the screenshot count limit was not confirmed, the console form states it). Each language set was taken with the watch (or emulator) set to that language, because the watch app is localised in all three. Observed 2026-11-15: three 454x454 files (1:1, 24-bit PNG) per language from the `Wear_OS_Large_Round` emulator are in the Wear OS screenshots slot of the en-US, ru-RU and uk listings, and Advanced settings > Form factors reads Wear OS "1 of 3 complete" with "Upload Wear OS screenshots for all store listings" checked; the opt-in (item 3) was not touched. The language was set per app (`cmd locale set-app-locales`), not as the emulator's system language: the screens are the app's own localisation, the system language only changes system chrome that no screenshot shows. Met.
6. **Nothing private in a public screenshot.** Every screenshot was opened and checked: no Android ID, serial number, IP or MAC address, network name or account name is visible. The device-information screens show many such fields, so a screen that does is cropped out or replaced by one that does not. Observed 2026-11-15: all 13 final files were opened and read; none shows a private value. The shots chosen show only group headers, Battery, Display, Memory (phone) and group headers, Health, Memory (watch); the Device, Hardware, Sensors, Storage and Wi-Fi contents were not used (emulator names such as "ranchu" and "Goldfish", and a network section). Met.

## 3. Approach

### 3.1 Scope

This ticket changes no source, no build logic, no listing text and no site page. It is the owner's three hands-on steps, in order, with the exact commands and checks, and the place where their state is written down. S0014 (first publication) waits on it and resumes when it is done.

| Step | Who | Where |
| --- | --- | --- |
| 1. Upload key, app signing key, `keystore.properties`, `deviceinfo.signing.dir` | owner, desk | `P:\ANDROID\DeviceInfo_credentials`, `%USERPROFILE%\.gradle\gradle.properties` |
| 2. Fresh `store` debug build for phone and watch | owner (or the build side on the owner's order) | repository root, Build lock |
| 3. Phone screenshots, upload | owner, real phone, console | default listing |
| 4. Wear OS screenshots (en-US, ru-RU, uk), upload | owner, watch or emulator, console | Wear OS form-factor step 1 |

What does not change and is not done here: the first upload, the Play App Signing key import with Google's `pepk` tool, the registration of the upload key, the Wear OS opt-in (step 3 of the form) and the production review stay in S0014 and run only on the owner's order, one at a time. The build side creates no key material and never holds a password. (Superseded 2026-11-14: the owner ordered the pass to create the keys itself, with generated passwords that only ever reach two properties files; see `### Quiz decisions (2026-11-14)`.)

Scope of user-visible behaviour (CLAUDE.md section 4, S0021): none - no phone or watch behaviour changes, so `docs/PARITY_MATRIX.md` has no row to update. Both sides get screenshots because the listing is one listing for both packages.

### 3.2 Open questions

None left without an answer. The two choices this pass took are recorded under `### Assumed (unattended, 2026-11-14)` below; the owner may overrule either. No question is carried to another ticket.

### Assumed (unattended, 2026-11-14)

- **The listing screenshots come from a debug build of the `store` flavor, not from the signed release variant.** The release variant is built and run in S0014 (criterion 4 there), which is blocked by this ticket, so waiting for it would be circular. The `store` debug build shows the same screens as the release build (the release variant only adds R8 and signing), and the `restricted` flavor must not be used because it carries the seven extended diagnostics sections that the public build does not have. This supersedes the clause "the screenshots of steps 2 and 3 come from the same sitting" in S0014's second assumed entry; S0014 re-reads it when it resumes. Alternative weighed: take the screenshots after the release run, in S0014's device sitting - rejected as circular. Reversible inside the ticket; owner may overrule. If the UI changes before the first release, the screenshots are retaken.
- **keytool parameters: PKCS12, RSA 2048, validity 10000 days, one file per key, passwords typed at the prompt.** PKCS12 is the build JDK's default; it has one password for store and key, so `keyPassword` in `keystore.properties` repeats `storePassword` (keytool ignores a separate key password for PKCS12). Passwords are typed at keytool's own prompt so they never enter a command line or a shell history. Alternative weighed: JKS with a separate key password - rejected as the legacy format with no gain here. Reversible until the first upload (the key is imported once, and nothing has been uploaded); owner may overrule. **Overruled 2026-11-14 (partly):** the owner ordered the pass to create the keys ("выполнить всё необходимое в рамках этого тикета"), so the passwords are not typed at a prompt; the pass generates them inside the script and writes them only to the properties files (see `### Quiz decisions (2026-11-14)`). PKCS12, RSA 2048 and 10000 days stand.
- **Password form (2026-11-14, S0029 pass).** The generated passwords are 32 characters from the 62 ASCII letters and digits, drawn from `RandomNumberGenerator` bytes with rejection (byte values 248 and above are skipped, so no character is favoured) and written only to the two properties files. No symbol is used, so no `:`, `=`, `#` or backslash needs escaping in a properties file. Alternative weighed: a symbol set with escaping - rejected, because one missed escape would break the release signing only at the first release. Reversible until the first upload: `keytool -storepasswd` and `-keypasswd` re-key both files in place. Owner may overrule.
- **AVD choice for the owner's emulator run (2026-11-14, S0029 pass).** The DO lines name `Pixel_9` for the phone set and `Wear_OS_Large_Round` for the Wear OS sets, the AVDs present on this machine. Alternative weighed: any other installed AVD of the same class - the listing does not depend on which one. Reversible; owner may overrule.

### 3.3 Owner inputs (Approval gate)

- **DO:** create the two keystores and tell Gradle where they are (`docs/RELEASE.md` owner steps 1 and 2). In PowerShell: create the directory (`New-Item -ItemType Directory P:\ANDROID\DeviceInfo_credentials`, keytool does not create it); then, with the build JDK's keytool (`C:\Program Files\Java\latest\jdk-21\bin\keytool.exe`, the `org.gradle.java.home` of your Gradle properties), run twice, once per key, answering the prompts for the password and the name fields:
  `keytool -genkeypair -v -storetype PKCS12 -keystore P:\ANDROID\DeviceInfo_credentials\upload-keystore.p12 -alias upload -keyalg RSA -keysize 2048 -validity 10000` and
  `keytool -genkeypair -v -storetype PKCS12 -keystore P:\ANDROID\DeviceInfo_credentials\app-signing-keystore.p12 -alias appsigning -keyalg RSA -keysize 2048 -validity 10000`.
  Write `P:\ANDROID\DeviceInfo_credentials\keystore.properties` with four lines for the upload key: `storeFile=upload-keystore.p12`, `storePassword=<its password>`, `keyAlias=upload`, `keyPassword=<the same password>`. Add `deviceinfo.signing.dir=P:/ANDROID/DeviceInfo_credentials` to `%USERPROFILE%\.gradle\gradle.properties`. Keep an off-machine copy of the whole directory: it is the only copy of both keys and their passwords. The directory is outside this repository and the `.gitignore` leak globs (`*.jks`, `*.keystore`, `*.p12`, `*.pem`, `keystore.properties`) cover a stray copy. Then run the check of criterion 1 and the line of criterion 2.
  - **Owner answer, DO 1:** "выполнить всё необходимое в рамках этого тикета" (2026-11-14) - the implementation pass carries it out, with the password handling and the certificate name of `### Quiz decisions (2026-11-14)`.
  - **Result (2026-11-14, S0029 pass):** done. `upload-keystore.p12` and `app-signing-keystore.p12` exist in `P:\ANDROID\DeviceInfo_credentials` with `keystore.properties` and `app-signing.properties` beside them; `deviceinfo.signing.dir` is in the user Gradle properties. Criteria 1 to 3 observed (see `## Last Audit`). The off-machine copy of the directory is still the owner's step.
- **DO:** build the two debug packages from the repository root under the Build lock - `.\gradlew.bat :phone:assembleStoreDebug :wear:assembleDebug` (a release-tier run, about two minutes; the phone APKs are absent and `wear-debug.apk` dates from 2026-11-10, before the later edits, so the existing file is stale) - install `phone/build/outputs/apk/store/debug/phone-store-debug.apk` on a real phone and `wear/build/outputs/apk/debug/wear-debug.apk` on the watch or emulator, then take 2 to 8 phone screenshots (16:9 or 9:16, each side 320 to 3840 px) of the information groups worth showing, check them as in criterion 6, and upload them to the default listing in the Play Console; this closes the 11th setup task. Keep a copy of the files in the ignored scratch directory for a retake or for the landing (`docs/RELEASE.md`, "After the site and the listing are live").
  - **Owner answer, DO 2:** "Снять на эмуляторе" (2026-11-14) - a phone emulator instead of the real phone; the owner names this build run, so the pass runs it under the Build lock.
  - **Result (2026-11-14, S0029 pass):** the build ran and succeeded (`BUILD SUCCESSFUL`, exit 0; both APKs read back as `com.sza.deviceinfo`). No screenshot is taken: no emulator runs (`adb devices` lists none) and the headless pass does not start one. Open: the first DO line of `### Questions (v1, 2026-11-14)`.
  - **Result (2026-11-15, owner-ordered pass, emulators started):** done. `wear-debug.apk` was stale (wear sources changed after 2026-11-10), so `.\gradlew.bat :phone:assembleStoreDebug :wear:assembleDebug` ran again under the Build lock: `BUILD SUCCESSFUL in 1m 23s`, exit 0, 89 tasks (86 executed). Installed on `Pixel_9` (API 35) and `Wear_OS_Large_Round` (API 37). Phone screen set to 1080x1920 (`wm size`) because the stock 1080x2424 is 2.24:1 and the console accepts 16:9 to 9:16 only; the override was reset afterwards (`Physical size: 1080x2424`). Battery state was faked on both emulators (`dumpsys battery`: 74 percent, AC on the phone) and reset. Four phone files uploaded to the default listing and saved; the Review step's AI asset declaration was answered "Don't label assets" (the assets are app screen captures and graphics drawn by `tools/store/render-store-assets.ps1`, none generated by an image model) and the listing saved. The files (names, sizes, SHA-256) are in `PLAN/S0029_play-owner-prep-keystore-screenshots/attachments/screenshots.manifest.json`.
- **DO:** take the Wear OS screenshots for en-US, ru-RU and uk (1:1, at least 384 px, app interface only; set the watch or emulator to each language in turn) and upload them in the Play Console's Wear OS form-factor step 1. Keep a copy in the ignored scratch directory, one folder per locale. Do not accept the Wear OS opt-in (step 3 of the form): it needs the first upload and is S0014's one-way step.
  - **Owner answer, DO 3:** "выполнить всё необходимое в рамках этого тикета" (2026-11-14) - the implementation pass takes the three language sets on a Wear OS emulator and uploads them; the opt-in stays out.
  - **Result (2026-11-14, S0029 pass):** not done. No Wear OS emulator runs, and the console upload needs the owner's sign-in. Open: the second DO line of `### Questions (v1, 2026-11-14)`.
  - **Result (2026-11-15, owner-ordered pass, emulators started):** done. Three screens per language on `Wear_OS_Large_Round` (group overview, Health, Memory), uploaded one by one into the Wear OS screenshots slot of each listing language (en-US first; ru-RU and uk replace the inherited default set) and saved. The files (names, sizes, SHA-256) are in the same manifest. The opt-in stays untouched for S0014. Observed in the shots: on the round 454 px screen the Russian title "Сведения о системе" is clipped at both edges, so the first shot of every language is the group overview without the title; the clipping is a UI defect for a follow-up ticket, not changed here (no source edits in this ticket).
- **Sources for the Wear OS screenshot rules:** Google's Android Developers Blog post "Wear OS 3 update" (2021-09, `https://android-developers.googleblog.com/2021/09/wear-os-3-update.html`) states the 384 x 384 px minimum, the 1:1 ratio and the no-frame, no-added-text rules; the live Play Console Help page was not reached by the search, so the console's own form is the authority on the count.
- **Related tickets:** S0014 (first publication; waits on this ticket and holds the one-way steps), S0008 (release preparation; the signing decisions and `docs/RELEASE.md` owner steps), S0007 (device check, the source of the phone and watch scenarios), S0012 (landing, may later reuse the screenshots).

## Questions

### Questions (v1, 2026-11-14) - answered 2026-11-14

- DO: create the upload keystore and the app signing keystore in `P:\ANDROID\DeviceInfo_credentials` with keytool, write `keystore.properties` beside them, set `deviceinfo.signing.dir` in `%USERPROFILE%\.gradle\gradle.properties`, and run the check of criteria 1 to 3.
- DO: build `:phone:assembleStoreDebug :wear:assembleDebug`, take 2 to 8 phone screenshots on a real phone from the `store` build, check them for private data, and upload them to the default listing of `com.sza.deviceinfo`.
- DO: take the Wear OS screenshots for en-US, ru-RU and uk and upload them in the Play Console's Wear OS form-factor step 1 (no opt-in).

### Quiz decisions (2026-11-14)

- DO 1, the two keystores, `keystore.properties`, `deviceinfo.signing.dir` -> "выполнить всё необходимое в рамках этого тикета" (the owner's typed answer): the pass carries it out; it is no longer the owner's hands-on step.
- Password handling (collision shown once: section 3.1 "never holds a password" and the S0008 decision "creating the keystore is the owner's step") -> a script generates random passwords inside itself and writes them only to `keystore.properties` (upload key; `keyPassword` repeats `storePassword`, PKCS12) and `app-signing.properties` (app signing key) in `P:\ANDROID\DeviceInfo_credentials`; they never appear in command output, a command line, the shell history or the chat (recommended answer chosen: the passwords stay machine-local and the keys stay outside the repository). The owner reads them from those two files. The off-machine copy of the whole directory stays the owner's step, because the pass cannot make it; the pass says so in its report.
- Certificate name -> `CN=DeviceInfo, O=SZA` for both keys, the CN carrying the suffix `upload` or `app signing` so the two certificates differ; no country, no personal name (recommended answer chosen: the app signing certificate is public in every installed APK).
- DO 2, phone screenshots -> "Снять на эмуляторе" (the owner's choice instead of the real phone): the pass builds `.\gradlew.bat :phone:assembleStoreDebug :wear:assembleDebug` under the Build lock (a release-tier run that the owner names here), installs the `store` build on a phone emulator, takes 2 to 8 screenshots, checks them for private data and uploads them to the default listing. Criteria 4 and 6 read "phone emulator". Checked at this sitting: `adb devices` lists no running device; the AVDs exist (for example `Pixel_9`, `Wear_OS_Large_Round`).
- DO 3, Wear OS screenshots -> "выполнить всё необходимое в рамках этого тикета" (the owner's typed answer): the pass takes the en-US, ru-RU and uk sets on a Wear OS emulator and uploads them in step 1 of the Wear OS form factor. The Wear OS opt-in (step 3), the first upload, the Play App Signing key import and the production review stay in S0014 and are not part of this order.
- A console step that cannot be reached or needs the owner's hands (a sign-in, a confirmation) stays open and is returned to the owner as a `DO:` line; it is never claimed as passed.
- Records to refresh when the keys exist: `CLAUDE.md` section 3 and `docs/RELEASE.md` owner steps 1 and 2 still say "creating the keystore is the owner's step and has not happened".

### Questions (v1, 2026-11-14) - answered 2026-11-15

- DO: take 2 to 8 phone screenshots (16:9 or 9:16, each side 320 to 3840 px) on the emulator `Pixel_9` from the `store` debug build (`phone/build/outputs/apk/store/debug/phone-store-debug.apk`, built and read back on 2026-11-14), check every one for private data as criterion 6 says, and upload them to the default listing of `com.sza.deviceinfo` in the Play Console.
- DO: take the Wear OS screenshots for en-US, ru-RU and uk (1:1, at least 384 px, app interface only) on the emulator `Wear_OS_Large_Round` with `wear/build/outputs/apk/debug/wear-debug.apk` installed, one set per language with the watch set to that language, and upload them in step 1 of the Wear OS form factor in the Play Console; do not accept the Wear OS opt-in.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0014 | since: 2026-11-13 | released: 2026-11-15 -> Draft
## Last Audit

**Date:** 26-11-15 | **Mode:** manual (emulators and Play Console, run by the agent on the owner's order) | **Outcome:** Pass
**Counts:** PASS 8 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 0 | RELEASE 2

Criteria 1 to 3 were observed on 2026-11-14 (unchanged, see Evidence). Criteria 4 to 6 were observed on 2026-11-15 on the `Pixel_9` and `Wear_OS_Large_Round` emulators and in the Play Console of the owner's signed-in Chrome. No source, build logic, listing text or site page was edited, so no compile gate applies.

### Action items
1. Owner step outside the criteria: an off-machine copy of `P:\ANDROID\DeviceInfo_credentials`, the only copy of both keys.
2. Follow-up ticket candidate: the Russian title "Сведения о системе" of the watch's main screen is clipped at both edges on a round 454 px display (seen in the emulator shots; not changed here).
3. S0014 owns what remains of the Wear OS form: item 2 (a Wear bundle on a testing track) and item 3 (the opt-in), plus the first upload, the app signing key import and the production review.

### Evidence (2026-11-14, criteria 1 to 3 and the build)
- PASS - criterion 1: `keystore.properties` names `storeFile`, `storePassword`, `keyAlias` and `keyPassword`, and `upload-keystore.p12` exists beside it (five True lines). No value is printed.
- PASS - criterion 2: `Select-String` on `%USERPROFILE%\.gradle\gradle.properties` prints `deviceinfo.signing.dir=P:/ANDROID/DeviceInfo_credentials`.
- PASS - criterion 3: `keytool -list` with the JDK 21 of `org.gradle.java.home` exits 0 for `upload-keystore.p12` (alias `upload`) and for `app-signing-keystore.p12` (alias `appsigning`); each shows one `PrivateKeyEntry`.

### Evidence (2026-11-15, criteria 4 to 6)
- PASS - build: `.\gradlew.bat :phone:assembleStoreDebug :wear:assembleDebug` under the Build lock, exit 0, `BUILD SUCCESSFUL in 1m 23s`, 89 actionable tasks (86 executed). The previous `wear-debug.apk` pre-dated later wear edits, which is why it was rebuilt.
- PASS - criterion 4: four phone files (group overview, Battery, Display, Memory), each 1080x1920, ratio 1.778, `Format24bppRgb`, taken from `phone-store-debug.apk` on `Pixel_9`; the default listing shows "4 / 8" phone screenshots and the changes were saved; the dashboard no longer shows the "Set up your app" block. The literal "11 of 11" line was not on screen after the last save, so this is read from the block's disappearance.
- PASS - criterion 5: nine files, 454x454, `Format24bppRgb`, three per language, in the Wear OS slot of the en-US, ru-RU and uk listings; Advanced settings > Form factors: Wear OS "1 of 3 complete", "Upload Wear OS screenshots for all store listings" checked. The language was set per app, not as the emulator's system language (recorded under criterion 5). The en-US set sits in the order groups, memory, health; the console's drag reorder did not take a second move, and the order is cosmetic.
- PASS - criterion 6: every one of the 13 final files was opened and read; no Android ID, serial number, IP or MAC address, network name or account name is visible.
- PASS - declaration: the Review step's AI asset declaration was answered "Don't label assets" and the listing saved; the assets are app screen captures and graphics drawn by `tools/store/render-store-assets.ps1`. The owner may overrule the answer in the console.
- PASS - emulator hygiene: `wm size reset` (`Physical size: 1080x2424` after the reset), `dumpsys battery reset` and the watch's app locale reset; both emulators stopped. Both emulators lost `system_server` during the session and were restarted cold; the phone's 1080x1920 override had persisted in the AVD data and was reset after that restart.

### Manual / on-target
- [x] Criterion 4: phone screenshots in the default listing (above).
- [x] Criterion 5: Wear OS screenshots in en-US, ru-RU and uk (above).
- [x] Criterion 6: privacy check of every file (above).

Outside the criteria, an owner step: an off-machine copy of `P:\ANDROID\DeviceInfo_credentials`, which is the only copy of both keys.

### RELEASE items
- `.\gradlew.bat :phone:bundleRelease :wear:bundleRelease -Pdeviceinfo.pin.versionName=.. -Pdeviceinfo.pin.versionCode.phone=.. -Pdeviceinfo.pin.versionCode.wear=..` (`docs/RELEASE.md`) - proves that the release variant reads the upload key through `ReleaseSigning`. Not run: release tier, and a packaging task waits for the owner's order.
- `.\gradlew.bat -p buildSrc test` (`VersionStampTest`, `ReleaseSigningTest`) - not run in this pass.