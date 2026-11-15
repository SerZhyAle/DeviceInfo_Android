# S0014_play-first-publication

**Status:** BlockExternal
**Status note:** Waiting on Google Play review of the first production release (15 changes sent 2026-11-15, managed publishing off); resolved when the listing details?id=com.sza.deviceinfo answers 200, then criterion 9 live checks and the real paired-device Send to phone check run.
**Created:** 2026-11-13
**Complexity:** medium - assessed at the spec pass (2026-11-13, unattended): no source changes; nine ordered steps, three of them the owner's hands (desk, device, console), two one-way store steps, and one release run whose procedure already exists in `docs/RELEASE.md`. The effort is sequencing and proof, not code; it is not `light` because the release tier (R8, Gson, signing, device run) can fail in ways no between-releases check can show.

## 0. Owner request (verbatim)

Owner's words (2026-11-13): "\"Что осталось до публикации\" это должен быть тикет в репозитори проекта, а не мне сюда"

What remains before DeviceInfo is published on Google Play, as of 2026-11-13. Already done the same day on the owner's order: public remote SerZhyAle/DeviceInfo_Android and its Pages site (all 9 addresses answer 200); Play Console app com.sza.deviceinfo (personal account, App, Free) with every App content declaration (privacy URL, no restricted access, no ads, audience 18+, no advertising ID, not a government app, no financial or health features, Data safety "no data collected or shared", fresh IARC rating: ESRB Everyone, ClassInd L), store settings (Tools, sza@ukr.net, landing as website), the default listing draft in en-US, ru-RU and uk with icon and feature graphic, and the Wear OS form factor added. Dashboard: 10 of 11 setup tasks.

Remaining, in order:
1. DO (owner): create the upload keystore in P:\ANDROID\DeviceInfo_credentials with keystore.properties, and set deviceinfo.signing.dir in %USERPROFILE%\.gradle\gradle.properties (docs/RELEASE.md owner steps 1-2).
2. Phone screenshots (2-8, 16:9 or 9:16, 320-3840 px) from a real phone, uploaded to the default listing; this closes the 11th dashboard task (store listing). Source: the device check of S0007.
3. Wear OS screenshots for every listing language (the console's Wear OS form-factor step 1).
4. Release run of docs/RELEASE.md: fast gates, tests, version pin, notices check, :phone:bundleRelease :wear:bundleRelease with the pin; package read-back.
5. First upload: phone bundle and wear bundle to a testing track (internal first); at this first upload import the app signing key with Google's pepk tool and register the upload key (Play App Signing, one-way).
6. Wear OS opt-in and agreement to the Wear OS review policy (the console's Wear OS step 3; allowed only after steps 3 and 5; one-way - owner's yes).
7. Release notes from docs/play/PLAY_LISTING.md in en, ru, uk; promote to production and send for review (one-way, owner's order only); the canon's release flow rules apply (pre-flight PASS, update over a prior install for later releases).
8. After the listing answers 200: hub:S0009 (SITE-FAMILY-MAP row and hub card) and the eight footer-grid tickets (fms-a:S4561, fms-lite:L0309, cyrflip:S0101, epub2html:E0138, filedo:SP-0211, uak:S0011, streams-win:SP-0265, oneclickrunner:T0045) become workable; this repo's S0012 live checks run then.
9. Account-level, not this app: "Declare your trader status" in the Play Console, due February 2027 (owner).

Open question carried from S0008: should the first Google Play release wait for S0011 and S0013?


## 1. Problem

DeviceInfo has a finished listing draft, a live product site and a built-in release procedure, but nothing is on Google Play: the upload key does not exist, the listing has no screenshots, no release package has been built or signed, and the two store steps that cannot be undone (importing the app signing key, sending the app to review) are still ahead. Until the owner has taken the three hands-on steps and ordered the one-way ones, the product cannot reach a user, and the owner has no single place that says what is next and in what order.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat. The ticket is `Verified` only when all of them hold; the one-way steps (criteria 6 to 8) run on the owner's order and never earlier.

1. **Upload key present.** `Test-Path P:\ANDROID\DeviceInfo_credentials\keystore.properties` is `True`, and `deviceinfo.signing.dir` is a key in `%USERPROFILE%\.gradle\gradle.properties` (or `DEVICEINFO_SIGNING_DIR` is set). Observed 2026-11-13 at this pass: directory absent, property absent, variable unset - open. **Met, observed 2026-11-15 at the resume pass:** `Test-Path` on `keystore.properties`, `upload-keystore.p12` and `app-signing-keystore.p12` is `True` for all three, the four keys `storeFile`, `storePassword`, `keyAlias`, `keyPassword` are present (presence only, no value printed) and `storeFile` exists, and `deviceinfo.signing.dir=P:/ANDROID/DeviceInfo_credentials` is in the user Gradle properties. Created by S0029 on 2026-11-14.
2. **Phone screenshots in the listing.** The Play Console store-listing task shows 2 to 8 phone screenshots in the default listing and the dashboard reads 11 of 11 setup tasks. Open at 2026-11-13. **Met, by S0029 (Implemented) on 2026-11-15:** four 1080x1920 screenshots from the `store` debug build on the `Pixel_9` emulator (the owner chose the emulator over the real phone, S0029 quiz of 2026-11-14), "4 / 8" in the default listing, the dashboard no longer shows the "Set up your app" block. This is S0029's console observation; this pass has no console access and did not re-observe it.
3. **Wear OS screenshots in every listing language.** The console's Wear OS form-factor step 1 is complete for en-US, ru-RU and uk. Open at 2026-11-13. **Met, by S0029 on 2026-11-15:** three 454x454 files per language from the `Wear_OS_Large_Round` emulator, Advanced settings > Form factors reads Wear OS "1 of 3 complete" (S0029's console observation, not re-observed here). The first shot of every language omits the title because the Russian title is clipped on the round screen; that defect is parked as S0043 and does not gate the release.
4. **Release run green** (`docs/RELEASE.md`, "The release run", steps 1 to 8, under the Build lock): every fast gate exits 0 (S0042 landed on 2026-11-15 and `check-drift.ps1` and `check-scope.ps1` exit 0 again; S0044 landed the same day and `check-pointers.ps1` exits 0 again; S0046 landed on 2026-11-15 and `check-local-divergence.ps1 -RequireClassified` exits 0 again; at the fourth resume pass every fast gate listed below exits 0 except `check-scope.ps1`, which is a release-start run), `.\gradlew.bat -p buildSrc test` and `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest` exit 0 (the flavored phone tasks since S0038; the bare `:phone:testDebugUnitTest` is ambiguous), `new-version-pin.ps1` printed the pin, the dependency check names every group id in `THIRD-PARTY-NOTICES.txt` and finds no analytics, advertising or tracking library, `.\gradlew.bat :phone:bundleRelease :wear:bundleRelease` with the pin exits 0, `read-package-info.ps1` reads back the expected name, code and permission list for both bundles, and the signed release variant ran on a phone and a watch with **Send to phone** end to end and every phone report section opened. Open (RELEASE).
5. **Notification permission verified on a device.** The S0011 device check (fresh Android 13+ install: explanation, system prompt, refusal snackbar, **Turn on notifications** menu entry) is closed as part of the device run of criterion 4, and S0011 and S0007 move past `BlockNeedUserTest` through their own re-audits. Open.
6. **First upload.** Phone bundle and wear bundle are on a testing track (internal first); the app signing key is imported with Google's `pepk` tool and the upload key is registered. One-way, owner's order.
7. **Wear OS opt-in.** The console's Wear OS step 3 is accepted (allowed only after criteria 3 and 6). One-way, owner's yes.
8. **Production and review.** Release notes from `docs/play/PLAY_LISTING.md` (en, ru, uk, each within 500 characters) are entered, the release is promoted to production and sent for review, `CHANGELOG.md` `[Unreleased]` is moved under the new version and the tag `v<versionName>` is pushed. One-way, owner's order; the canon's release flow rules apply.
9. **Listing live, downstream released.** `curl -s -o /dev/null -w "%{http_code}" -L "https://play.google.com/store/apps/details?id=com.sza.deviceinfo"` prints `200`; then the live checks of `docs/RELEASE.md` ("After the site and the listing are live") run, `hub:S0009` and the eight footer-grid tickets of section 3.1 step 8 are workable, and this repository's S0012 live checks run.
10. **Trader status declared** (account level, February 2027): the owner's own console step; recorded here so it is not forgotten, not a gate of the first release.

## 3. Approach

### 3.1 Scope

This ticket changes no source. It is the order of steps from "listing draft saved" to "listing live", and the place where each step's state is written down. Work is split by who can do it:

| Step | Who | State at 2026-11-15 |
| --- | --- | --- |
| 1. Upload keystore and `deviceinfo.signing.dir` | owner, desk | done by S0029, 2026-11-14 (criterion 1 observed 2026-11-15) |
| 2. Phone screenshots | owner, real phone | done by S0029, 2026-11-15, from the emulator (owner's choice) |
| 3. Wear OS screenshots, three languages | owner, real watch or emulator | done by S0029, 2026-11-15, from the emulator |
| 4. Release run | build side, on the owner's order, needs step 1 | open (RELEASE); S0042, S0044 and S0046 brought the port gates, the pointer check and the local-divergence check back to exit 0 (2026-11-15); no red gate is left between releases and the run waits only for the owner's order |
| 5. First upload, app signing key import | owner, console, one-way | owner's order only |
| 6. Wear OS opt-in | owner, console, one-way | owner's yes only, after steps 3 and 5 |
| 7. Release notes, production, review | owner, console, one-way | owner's order only |
| 8. Downstream tickets | other repositories | wait for the listing to answer 200 |
| 9. Trader status | owner, console | due February 2027, account level |

What does not change: the application id, the signing decisions of S0008, the listing text in `docs/play/PLAY_LISTING.md`, the three landing pages. Step 8's tickets belong to other repositories and are not read or changed from here; they become workable on their own once the listing answers 200 and the hub row is filed through the process of `docs/RELEASE.md`.

Everything the build side can prove without the key was proved at this pass (see "Pre-release state, 2026-11-13"); everything else is a release item.

### 3.2 Open questions

- The question carried from S0008, "should the first Google Play release wait for S0011 and S0013?", is settled by the state of those tickets and is recorded under `### Assumed (unattended, 2026-11-13)`. S0008 still holds the question block it was asked from; the owner answers it there, and S0014 follows that answer. No question of this ticket is left without an answer or a carrier.

### Assumed (unattended, 2026-11-13)

- **The first release includes S0011 and S0013; it does not go out ahead of them.** Taken from the researched recommendation in S0008's question block ("wait for both, then release"). The facts that make it free: S0013 is `Implemented` and the drift check exits 0 (`OK: nothing uncarried (92 in step, 0 decided)`, run at this pass), and S0011 is `BlockNeedUserTest` - its code is in the tree, only its device check is open, and that check folds into the device run of `docs/RELEASE.md` step 7 (criterion 5). Waiting therefore delays nothing: there is no separate work to wait for. Alternative weighed: release now and carry both into a second release - rejected because both are already in the first package, so the alternative would mean removing finished work, and a fresh Android 13+ install would refuse the watch's Send to phone. Reversible inside the ticket (nothing has shipped); owner may overrule, and S0008's question block stays open for that answer.
- **The device run of the release variant is the single device sitting.** The S0007 parity check, the S0011 notification check and the release-variant run of `docs/RELEASE.md` step 7 use the same phone and watch, and the screenshots of steps 2 and 3 come from the same sitting. Alternative weighed: separate sittings per ticket - rejected as the same install flow repeated four times. Reversible; owner may overrule.

### Assumed (unattended, 2026-11-15)

- **The ticket parks on S0042 (`BlockByOtherTask`), not on a question to the owner.** The next build-side step is the release run, whose first line is "every fast gate exits 0", and two gates exit 1 until the upstream drift is carried, so the blocker is a precise, mechanical fact and the carry is a build-side job, not an owner decision. Alternative weighed: `BlockQuestions` with "order the release run?" - rejected: a slow run is recorded as a release item, never asked about, and the owner's order for each one-way step is already recorded below as "not asked". Reversible inside the ticket; owner may overrule by ordering the release run and the upload directly, in which case S0042 still has to land first.
- **S0043 (the clipped Russian watch title) does not gate the release.** The first Wear OS screenshot of each language omits the title, so the listing is truthful; the fix is its own ticket and a retake of the screenshots only if the title then belongs in them. Alternative weighed: hold the release for it - rejected: no criterion of this ticket names it, and a UI fix after the first release is a normal update. Reversible; owner may overrule.

### Assumed (unattended, 2026-11-15, second resume pass)

- **The ticket parks on S0044 (`BlockByOtherTask`) and does not carry the pointer re-read itself.** S0042 landed (`Implemented`, both port gates exit 0), which released this ticket to `Draft`; the fresh gate run then found a new red, `check-pointers.ps1` exit 1 (`ICON-SET` 0.40 against catalog 0.41, `COLLAPSIBLE-GROUP` 1.2 against catalog 1.3, both catalog decisions of 2026-11-15). Re-reading a contract at a new version is contract-sync work with its own checks (registry rows, whether the 0.41 and 1.3 wording touches the group headings), the same shape as the closed S0016 and S0031, and this ticket changes no document or source. Alternatives weighed: re-read the two pointers inside this ticket - rejected, scope purity and the 1.3 items may need a design check; record `check-pointers.ps1` as a known-red and go on - rejected, `docs/RELEASE.md` step 1 asks for every fast gate at exit 0 and 0.41 accepts this product's own proposal, so the repository would ship reading its own accepted meanings at the old version. Reversible inside the ticket; owner may overrule by ordering the release run with the red named, in which case S0044 still stands as a Draft.
- **The release run is still not started in this pass.** It is release tier (Gradle, the pinned `bundleRelease`) and no owner order naming it is in the pass; recorded as release items, not asked about. Reversible; owner may overrule by ordering it.

### Assumed (unattended, 2026-11-15, third resume pass)

- **The ticket parks on S0046 (`BlockByOtherTask`) and does not classify the divergence itself.** S0044 is `Verified`, which released this ticket to `Draft`, and the fresh gate run shows `check-pointers.ps1` at exit 0 (20 pointers, 0 mismatches). It also shows a new red: `check-local-divergence.ps1 -RequireClassified` exits 1 (`Local edits: 9; unclassified: 1`), the one unclassified edit being `wear/.../ui/apps/systeminfo/SystemInfoScreen.kt`, carried by S0042 on 2026-11-15 and edited again by S0043 at 01:29 the same day (the clipped Russian title, `BlockNeedUserTest`). Classifying the current bytes is a decision about another ticket's edit (candidate for the reverse port, or a recorded local difference) and writes the ledger side, which this ticket (no source, no document) does not own. Alternatives weighed: classify it inside this ticket with `record-local-decision.ps1` - rejected, scope purity and the choice between "reverse-port candidate" and "local difference" belongs with S0043's author; run the release with the gate named as a known red - rejected, `docs/RELEASE.md` step 1 and `CLAUDE.md` section 6 ask for exit 0 at every release start. Reversible inside the ticket; owner may overrule by ordering the release run with the red named, in which case S0046 still stands as a Draft.
- **`check-scope.ps1` was not run in this pass.** Its measured time is 6.9 s (2026-11-15, previous pass), over the 5 s ceiling, so it is a release-start run; it exited 0 at the previous pass (`OK: every in-scope upstream item is ported or decided (376 ported, 19 decided)`) and no upstream or ledger file was touched by this ticket since. Reversible; owner may overrule.
- **The release run is still not started in this pass.** It is release tier (Gradle, the pinned `bundleRelease`) and no owner order naming it is in the pass; recorded as release items, not asked about. Reversible; owner may overrule by ordering it.

### Assumed (unattended, 2026-11-15, fourth resume pass)

- **The ticket parks in `BlockQuestions` on the owner's order for the first publication, not in `Partial` or `Draft`.** S0046 is `Verified`, which released this ticket to `Draft`; the fresh gate run found no red (every fast gate exit 0, see "Pre-release state, 2026-11-15 (fourth resume pass, after S0046)"), so no blocking ticket is left and nothing build-side remains between releases. What remains is the release run (release tier), the device sitting, and the one-way steps of criteria 6 to 8 (app signing key import, Wear OS opt-in, production and review), each of which the ticket itself reserves for the owner's explicit order. Left in `Draft` or `Partial` the queue would hand the same ticket to the next unattended pass, which could only repeat this audit. The one-way, outward nature of the remainder is exactly what `BlockQuestions` is for, so the question block `### Questions (v1, 2026-11-15)` asks for the order once, with the researched recommendation first. Alternatives weighed: `Partial` with the remainder as action items - rejected, the queue would keep re-selecting a ticket that has no unattended work; run the release run in this pass - rejected, release tier and no owner order naming it (a slow run is recorded as a release item, never asked about; the question is about the order for the one-way publication, not about the slow run). Reversible inside the ticket; owner may overrule by ordering the release run directly.
- **`check-scope.ps1` was not run in this pass.** Its measured time is 6.9 s (2026-11-15), over the 5 s ceiling, so it is a release-start run; it exited 0 at the second resume pass (`OK: every in-scope upstream item is ported or decided (376 ported, 19 decided)`), and `check-drift.ps1` (104 in step, 1 decided) and `check-local-divergence.ps1 -RequireClassified` exit 0 now, so the ledger side did not move. Reversible; owner may overrule.
- **No source or document other than this ticket was edited in this pass**, so the compile gate does not apply (`commands.compileCheck` was not run: nothing to compile; the last compile was S0043's, `BUILD SUCCESSFUL in 11s`, per its status note).

### 3.3 Owner inputs (Approval gate)

The three `DO:` lines below were carried by S0029 (Carrier: S0029, owner, 2026-11-13: "Нужен другой тикет - на выполнение всех этих операций - а этот заблокирован новым тикетом") and are done; S0029 is `Implemented`, which released this ticket on 2026-11-15. Each line keeps its original wording and gains its result.

- **DO:** create the upload keystore in `P:\ANDROID\DeviceInfo_credentials` with `keytool`, write `keystore.properties` beside it (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`), keep the app signing key there for the later `pepk` import, and set `deviceinfo.signing.dir=P:/ANDROID/DeviceInfo_credentials` in `%USERPROFILE%\.gradle\gradle.properties` (`docs/RELEASE.md` owner steps 1 and 2). Without it every release packaging task stops, so the release run cannot start.
  - **Result (2026-11-15):** done by S0029 on 2026-11-14 and re-observed in this pass (criterion 1). Still the owner's own step, outside this ticket's criteria: an off-machine copy of the whole key directory, the only copy of both keys.
- **DO:** take 2 to 8 phone screenshots (16:9 or 9:16, 320 to 3840 px) from a real phone and upload them to the default listing in the Play Console; this closes the 11th setup task.
  - **Result (2026-11-15):** done by S0029 from the `Pixel_9` emulator, per the owner's choice (criterion 2). The screenshots come from the `store` debug build, not the signed release variant; if the UI changes before the first release they are retaken.
- **DO:** take the Wear OS screenshots for en-US, ru-RU and uk and upload them in the console's Wear OS form-factor step 1.
  - **Result (2026-11-15):** done by S0029 from the `Wear_OS_Large_Round` emulator (criterion 3).
- Ended 2026-11-15: the earlier blocker S0042 (the upstream drift behind `check-drift.ps1` and `check-scope.ps1`) is `Implemented` and both gates exit 0, so its hold on this ticket is released.
- Ended 2026-11-15 (third resume pass): the earlier blocker S0044 (the stale `ICON-SET` and `COLLAPSIBLE-GROUP` pointers) is `Verified` and `check-pointers.ps1` exits 0 (20 pointers checked, 0 mismatches), so its hold on this ticket is released.
- Ended 2026-11-15 (fourth resume pass): the earlier blocker S0046 (the unclassified local edit of the watch `SystemInfoScreen.kt`) is `Verified` and `check-local-divergence.ps1 -RequireClassified` exits 0 (`OK: every local edit is classified`), so its hold on this ticket is released. No blocking ticket is left; the ticket now waits for the owner's order to start the first publication (see `### Questions (v1, 2026-11-15)`). Parked beside it: S0043 (the clipped Russian watch title), a defect, not a release gate.
- **DO:** make the off-machine copy of the whole `P:\ANDROID\DeviceInfo_credentials` directory (upload keystore, app signing keystore and both properties files) before the app signing key import of the first upload. Both keys exist only on this machine, and the app signing key, once imported into Play App Signing, cannot be regenerated.
- **Order for the one-way steps** (not asked, recorded): the first upload, the app signing key import, the Wear OS opt-in, the production promotion and the review submission each run only on the owner's explicit order, one at a time.
- **Related tickets:** S0008 (release preparation, holds the question block and the owner steps), S0007, S0011 (device checks folded into the release device run), S0012 (live checks after the listing answers 200), S0013 (done, drift check at exit 0), S0042 (the port-gate carry, `Implemented` 2026-11-15, released this ticket once), S0044 (the stale contract pointers, `Verified` 2026-11-15, released this ticket a second time), S0046 (the unclassified watch local divergence, `Verified` 2026-11-15, released this ticket a third time), S0043 (the clipped Russian watch title, `BlockNeedUserTest`; its edit is what S0046 classifies), other repositories as listed in 3.1 step 8 (cited by repository name in the owner request above).
- **Catalog-side registration (S0025, 2026-11-14):** the registry rows that the release's contract gate reads are written and listed in `docs/contracts/README.md`; its section 6 states what blocks this release (the six canon-layer rows owned by S0026, the `Verified` dates written at release start) and what does not (the family-map row, which hub:S0009 files after the listing answers 200).

## Release run, 2026-11-15 (owner's order, version 2.61.1151.340)

Run on the owner's order of 2026-11-15 (section "Quiz decisions (2026-11-15)"), `DEVICEINFO_TIER=Release`, every Gradle call under the Build lock through `tools/build/run-gradle.ps1` or `a.ps1`.

- **Key copy (DO line):** `P:\ANDROID\DeviceInfo_credentials` copied to the owner's Google Drive folder `c:\GD\Private\DeviceInfo_credentials` (the folder where the owner already keeps a keystore); four files, SHA-256 of each copy equal to its source (0 mismatches).
- **Step 1, fast gates:** the first run of `tools/check-fast.ps1` found one red, `check-pointers.ps1` exit 1 (`TASK-FLOW version 0.26 != catalog 0.27`). TASK-FLOW 0.27 is additive (rule 70, the spec-home move, is done by the harness tools this repository runs unmodified); the pointer, `docs/contracts/README.md` and this product's registry row were moved to 0.27. Then `check-fast.ps1` exit 0, `PASS - 20 of 20 gates passed` (`check-scope.ps1` 3.7 s among them), and again after every later edit of this run. Canon compliance `0 error(s), 8 warning(s)` (all `SZA-CTR02`, catalog named by path in tickets). Contract gate: `contract-lag.ps1 -Product "DeviceInfo Android"` - `rows: 20 (current 4, behind 0, partial 0, pending 16, ahead 0)`: no row behind; the 16 `pending` rows are reported here, not passed (their first rule-by-rule verification is S0047's).
- **Step 2, tests:** `a.ps1 fb` exit 0 (`BUILD SUCCESSFUL in 14s`); `a.ps1 fu` exit 0 (35 s; `testStoreDebugUnitTest` 15 classes 88 tests, `testRestrictedDebugUnitTest` 15 classes 92 tests, 0 failures, 0 errors, 0 skipped); `a.ps1 fwu` exit 0 (10 s; 9 classes 54 tests, 0 failures).
- **Step 3, pin:** `new-version-pin.ps1` - `-Pdeviceinfo.pin.versionName=2.61.1151.340 -Pdeviceinfo.pin.versionCode.phone=261115134 -Pdeviceinfo.pin.versionCode.wear=261115138`, `tag v2.61.1151.340`.
- **Step 3a, help screenshots:** pinned `:phone:assembleStoreDebug :wear:assembleDebug`; `capture-help.ps1 -PhoneSerial emulator-5556 -WearSerial emulator-5554 -ProductVersion 2.61.1151.340` (Pixel_9 API 35, Wear_OS_Large_Round API 37) failed twice on tooling the later tickets had outgrown, fixed in this run: `pm clear` revokes the notification grant and the S0011 explanation then covered the screen (`capture-help.ps1` now grants `POST_NOTIFICATIONS` after the clear), and the phone toolbar no longer shows its title (`capture-recipes.json` proves the language by `sysinfo_search_hint` too), and the watch group header carries its count, "Device (7)" (`_capture.ps1` matches `<title> (N)`). Third run `PASS (6 record(s))`: 9 images, phone en/ru/uk x dark/light, watch en/ru/uk dark. `render-help.ps1` PASS (40 files), `check-help-captures.ps1 -WriteBaseline` (2 pages with absent parts: the overflow entries and the parts below the fold), `check-help-captures.ps1 -Require -ExpectVersion 2.61.1151.340` PASS (rung 2 held), `check-help-map.ps1` PASS, `test-help-captures.ps1` PASS (64 expectations). Looked at: phone ru dark and watch uk dark show demo content in the asked language.
- **Step 4, notices:** `:phone:dependencies --configuration storeReleaseRuntimeClasspath` and `:wear:dependencies --configuration releaseRuntimeClasspath` exit 0, 56 group ids, none an analytics, advertising or tracking library. The notices named products, not group ids, and missed the transitive annotation libraries (Guava, Error Prone annotations, JSR 305, javax.inject, jakarta.inject, JSpecify, JetBrains annotations, all Apache 2.0): both `THIRD-PARTY-NOTICES.txt` gained that row, their upstream links and the list of the 56 group ids; 0 group ids missing, the pair byte-identical.
- **Step 5, bundles:** `:phone:bundleRelease :wear:bundleRelease :phone:assembleRelease :wear:assembleRelease` with the pin, exit 0; rebuilt after step 3a put the help pictures into the phone assets (`BUILD SUCCESSFUL in 14s`). `phone-store-release.aab` 3 205 173 bytes, SHA-256 `578B3318..20BFD`; `wear-release.aab` 2 701 701 bytes, SHA-256 `3A9C68B7..17DE3`. The APK signer is the upload key (`apksigner` SHA-256 `8dce52e0..136c5` equals the `upload` alias).
- **Step 6, read-back:** `read-package-info.ps1` with `bundletool-all-1.18.3.jar` (the GitHub release; the Maven jar in the Gradle cache has no dependencies): both `.aab` and both APKs `PASS` - `com.sza.deviceinfo`, `2.61.1151.340`, phone `261115134` with `ACCESS_NETWORK_STATE, POST_NOTIFICATIONS`, watch `261115138` with `ACCESS_WIFI_STATE`.
- **Step 7, device run (emulators):** the signed release APKs on Pixel_9 (API 35) and Wear_OS_Large_Round (API 37), not debuggable. Phone: fresh install showed the S0011 explanation, **Continue** led to the system prompt, **Don't allow** to the refusal snackbar, the overflow menu holds **Turn on notifications**; **Expand all** opened all 18 groups, every one with values (Device to Benchmarks, `App` reads `2.61.1151.340` / `261115134`); Help (F1) opens the page with its picture. Watch: all 9 sections opened with values (`App` reads `2.61.1151.340` / `261115138`), **Send to phone** answers "Phone not connected. Bring it closer". No crash in either crash buffer. **Not proven:** Send to phone end to end - the phone emulator has no Wear OS companion and no Google account, so the pair cannot form here. Statically proven instead: the release dex of both packages keeps `WearSystemInfoReportPayload` and `WearSystemInfoReportAck` whole, every wire field under its own name (`requestId`, `formatVersion`, `appVersionName`, `appVersionCode`, `deviceModel`, `androidRelease`, `capturedAtEpochMillis`, `reportText`; `requestId`, `accepted`, `reason`). The end-to-end send stays a check on a real paired phone and watch from the internal testing track.
- **Step 8:** not applicable to the first version (no prior install).

## Store steps, 2026-11-15 (owner's order, Play Console in the owner's Chrome)

- **App signing key (criterion 6).** The console already held a Google-generated app signing key from the app's creation (SHA-256 `E2:34:A4:D1..`, install base 0, nothing uploaded), against the S0008 decision of the product's own key. Replaced through App signing > Change key > "Export and upload a key from Java keystore": Google's `pepk.jar` and encryption public key were downloaded from the console into `temp/S0014/pepk/` (gitignored). `pepk` fails on the Oracle JDKs of this machine (`NoSuchAlgorithmException: RSA/NONE/OAEPWithSHA1AndMGF1Padding`: Oracle's JCE refuses the unsigned BouncyCastle repackaged in the jar); it ran with the signed `bcprov-jdk18on-1.81.jar` from the Gradle cache first on the classpath, main class `...export.ExportEncryptedPrivateKeyTool`, `--rsa-aes-encryption --include-cert`, passwords read from `app-signing.properties` inside the script and never printed. The upload certificate `temp/S0014/upload_certificate.pem` was attached by the owner (the browser tool does not upload `.pem` files on the agent's word). After Save the console reads app signing key SHA-256 `25:2C:D1:B6..D8:78` (equals `app-signing-keystore.p12`) and a separate upload key; the Digital Asset Links snippet names `25:2C:D1..`.
- **Internal testing (criterion 6).** Testers: the "License testers" list (the owner's own address) on both tracks. Phone track: `phone-store-release.aab` accepted as `261115134 (2.61.1151.340)`, API 26+, target 36; watch track ("Wear OS only"): `wear-release.aab` accepted as `261115138 (2.61.1151.340)`, API 28+. Both signed by the registered upload key (no signature error). Release notes en-US, ru-RU, uk from `docs/play/PLAY_LISTING.md`, "3 of 3 languages". The console's "version code significantly higher than your previous version code" error was overridden with **Proceed anyway**: the PACKAGE-VERSIONING band scheme starts at 2.6e8 and stays under the 2.1e9 ceiling for decades, so the warning is expected. Watch warning, not blocking: native code without debug symbols (from libraries). Both releases published to internal testers ("Available to internal testers"); opt-in link `https://play.google.com/apps/internaltest/4701021673790733948`.
- **Wear OS opt-in (criterion 7).** Advanced settings > Form factors > Wear OS read "2 of 3 complete" (screenshots, a testing-track release); step 3 accepted, "Form factor Wear OS by Google set to opted-in".
- **Production and review (criterion 8).** Production countries: all 177 plus "rest of world" (no country decision is recorded anywhere; a free tool that collects no data has no reason to exclude one; the watch track inherits the phone's list). Production releases from the library: phone `261115134` and watch `261115138`, full rollout, the same release notes. Publishing overview: 15 changes (both production releases, countries, the three listings, App content, the Wear OS opt-in, the category) sent with **Send changes for review**; state "Changes in review", managed publishing off, so the app goes live by itself once approved ("typically within 7 days").
- **Ledger and tag (criterion 8).** `CHANGELOG.md` gains `## [2.61.1151.340] - 2026-11-15` under an empty `[Unreleased]`; release commit and tag `v2.61.1151.340` pushed to `origin`.

## Pre-release state, 2026-11-15 (fourth resume pass, after S0046)

Fresh runs at the fast tier, each gate on its own, each verdict line read; no Gradle task, no device, no console in this pass. This pass edited this ticket's spec only, so the compile gate does not apply.

- Green, expected exit 0 | actual exit 0: `check-drift.ps1` (`OK: nothing uncarried (104 in step, 1 decided)`), `check-local-divergence.ps1 -RequireClassified` (`OK: every local edit is classified` - the third pass's one red is gone), `check-pointers.ps1` (`OK - 20 pointer(s) checked, 2 skipped, 0 mismatch(es)`), `check-surfaces.ps1`, `check-matrix.ps1`, `check-tokens.ps1` (163 checks, 0 mismatches), `check-version-parity.ps1` (`PASS`, 144 checks), `check-docs.ps1` (`PASS`, 30 records, 98 corpus files, 0 baselined, 2.9 s), `check-help-map.ps1` (`PASS`, 8 surfaces), `render-help.ps1 -Check` (`PASS`, 22 files current), `render-landing.ps1 -Check` (3 of 3 current), `render-store-assets.ps1 -Check` (`PASS`, 4 targets), `WearPayloadParity.java` (`PASS`), `PhoneUiSizingResources.java` and `WearUiSizingResources.java` (`OK`), `check-help-captures.ps1` (`NOT HELD`, exit 0: no capture record, the device run owes 9 images), `spec_catalog/validate` (`10 OK, 0 WARN, 0 FAIL`), `release-queue -Validate` (`46 ticket(s), no drift`) and the canon compliance gate (`0 error(s), 1 warning(s)`, overlay B, canon 2026.11.15.1; the one warning is the `SZA-CTR02` of the archived `PLAN/archive/S0001_canon-and-foundation.md`, not this ticket's).
- Red: none.
- Criterion 1 re-observed: `Test-Path` on `keystore.properties`, `upload-keystore.p12` and `app-signing-keystore.p12` expected True | actual True, True, True; `deviceinfo.signing.dir=` is a key in the user Gradle properties (presence only, no value read).
- Live, `curl -s -o /dev/null -m 15 -w "%{http_code}" -L`: the landing at the root, `ru/` and `uk/` answer 200; the Play listing answers 404, as expected before publication (criterion 9).
- Not run, by the 5 s ceiling or the owner's order: `check-scope.ps1` (6.9 s, a release-start run), every Gradle task, the pin, the package read-back, the device run, the self-tests over 5 s.
- Still parked: S0043 (the clipped Russian watch title, `BlockNeedUserTest`, not a release gate).

## Pre-release state, 2026-11-15 (third resume pass, after S0044)

Fresh runs at the fast tier, each gate on its own, each verdict line read; no Gradle task, no device, no console in this pass. No compiled source was edited by this ticket, so the compile gate does not apply (`commands.compileCheck` was not run here: nothing to compile; the last compile was S0043's, `.\a.ps1 fc` exit 0, `BUILD SUCCESSFUL in 11s`, per its status note).

- Green, expected exit 0 | actual exit 0: `check-pointers.ps1` (`OK - 20 pointer(s) checked, 2 skipped, 0 mismatch(es)`; the S0044 red is gone, `ICON-SET` 0.41 and `COLLAPSIBLE-GROUP` 1.3 now equal the catalog), `check-drift.ps1` (`OK: nothing uncarried (104 in step, 1 decided)`), `check-surfaces.ps1`, `check-matrix.ps1`, `check-tokens.ps1` (163 checks, 0 mismatches), `check-version-parity.ps1` (`PASS`, 144 checks), `check-docs.ps1` (`PASS`, 30 records, 97 corpus files, 0 baselined, 4.4 s), `check-help-map.ps1` (`PASS`, 8 surfaces), `render-help.ps1 -Check` (`PASS`, 22 files current), `render-landing.ps1 -Check` (3 of 3 current), `render-store-assets.ps1 -Check` (`PASS`, 4 targets), `WearPayloadParity.java` (`PASS`), `PhoneUiSizingResources.java` and `WearUiSizingResources.java` (`OK`), `check-help-captures.ps1` (`NOT HELD`, exit 0: no capture record, the device run owes 9 images), `spec_catalog/validate` (`10 OK, 0 WARN, 0 FAIL`), `release-queue -Validate` (`46 ticket(s), no drift`) and the canon compliance gate (`0 error(s), 1 warning(s)`: `SZA-CTR02` on the archived `PLAN/archive/S0001_canon-and-foundation.md`, not this ticket's).
- **Red, expected exit 0 | actual exit 1** (named so it cannot mask anything, parked as S0046): `check-local-divergence.ps1 -RequireClassified` - `Local edits: 9; unclassified: 1; missing: 0; unanchored: 0`; the unclassified edit is the watch `SystemInfoScreen.kt` (ledger row carried by S0042 on 2026-11-15, file written again at 01:29 by S0043); the other eight are classified as reverse-port candidates (RP-0003, RP-0005, RP-0006, RP-0007). It was 8 edits and 0 unclassified at the previous pass.
- Criterion 1 re-observed: `Test-Path` on `keystore.properties`, `upload-keystore.p12` and `app-signing-keystore.p12` expected True | actual True, True, True; `deviceinfo.signing.dir` present in the user Gradle properties (no value printed).
- Live, `curl -s -o NUL -m 15 -w "%{http_code}" -L`: the landing at the root, `ru/` and `uk/` answer 200; the Play listing answers 404, as expected before publication (criterion 9).
- Not run, by the 5 s ceiling or the owner's order: `check-scope.ps1` (6.9 s measured at the previous pass, exit 0 then; a release-start run), every Gradle task, the pin, the package read-back, the device run, the self-tests over 5 s.
- Parked: S0046 (the unclassified watch local divergence, new in this pass), S0043 (the clipped Russian watch title, `BlockNeedUserTest`).

## Pre-release state, 2026-11-15 (second resume pass, after S0042)

Fresh runs at the fast tier, each gate on its own, each verdict line read; no Gradle task, no device, no console in this pass. No compiled source was edited by this ticket, so the compile gate does not apply (`commands.compileCheck` was not run here; S0042 ran it for its own source edits: `BUILD SUCCESSFUL`, compiled, not tested).

- Green, expected exit 0 | actual exit 0: `check-drift.ps1` (`OK: nothing uncarried (104 in step, 1 decided)`), `check-scope.ps1` (`OK: every in-scope upstream item is ported or decided (376 ported, 19 decided)`, 6.9 s measured against 2.2 s recorded - the run is over the 5 s ceiling now and its recorded time in `CLAUDE.md` section 6 is stale), `check-local-divergence.ps1 -RequireClassified` (8 edits, 0 unclassified), `spec_catalog/validate` (`10 OK, 0 WARN, 0 FAIL`), `release-queue -Validate` (`43 ticket(s), no drift`), `check-surfaces.ps1`, `check-matrix.ps1` (42 rows), `check-tokens.ps1` (163 checks, 0 mismatches), `check-version-parity.ps1` (`PASS`, 144 checks), `check-docs.ps1` (`PASS`, 30 records, 96 corpus files, 0 baselined, 3.1 s), `check-help-map.ps1` (`PASS`, 8 surfaces), `render-help.ps1 -Check` (`PASS`, 22 files current), `render-landing.ps1 -Check` (3 of 3 current), `render-store-assets.ps1 -Check` (`PASS`, 4 targets), `WearPayloadParity.java` (`PASS`), `PhoneUiSizingResources.java` and `WearUiSizingResources.java` (`OK`), `check-help-captures.ps1` (`NOT HELD`, exit 0: no capture record, the device run owes 9 images), and the canon compliance gate (`0 error(s), 1 warning(s)`).
- **Red, expected exit 0 | actual exit 1** (named so it cannot mask anything, parked as S0044): `check-pointers.ps1` - `FAIL ICONOGRAPHY.md: ICON-SET version 0.40 != catalog 0.41 (read 2026-11-14)` and `FAIL UNIFIED-UI.md: COLLAPSIBLE-GROUP version 1.2 != catalog 1.3 (read 2026-11-13)`; `18 pointer(s) checked, 2 skipped, 2 mismatch(es)`. Both bumps are catalog decisions of 2026-11-15, not edits of this repository.
- Not run, by the 5 s ceiling or the owner's order: every Gradle task, the pin, the package read-back, the device run, the self-tests over 5 s. The previous pass's 404 of the Play listing stands as the expected state before publication (not re-curled: nothing published since).
- Parked: S0044 (the two stale pointers), S0043 (the clipped Russian watch title, from the previous pass).

## Pre-release state, 2026-11-15 (resume pass, before S0042)

Fresh runs at the fast tier, each gate on its own (the batch `a.ps1 fg` is 22.5 s, over the 5 s ceiling, so it was not used); each verdict line read, not the wrapper exit code. No compiled source was edited, so the compile gate does not apply (`commands.compileCheck` is declared by S0038 and was not run: nothing to compile).

- Criterion 1: `Test-Path` on `keystore.properties`, `upload-keystore.p12`, `app-signing-keystore.p12` - expected: True | actual: True, True, True; four required keys present, `storeFile` exists, `deviceinfo.signing.dir=P:/ANDROID/DeviceInfo_credentials` present (no value read).
- Green, expected exit 0 | actual exit 0: `spec_catalog/validate` (`Summary: 10 OK, 0 WARN, 0 FAIL`), `spec_catalog/release-queue -Validate` (`41 ticket(s), no drift`, run before S0042 and S0043 were filed), `check-local-divergence.ps1 -RequireClassified` (`OK: every local edit is classified`), `check-surfaces.ps1` (string keys and permissions agree), `check-docs.ps1` (`PASS`, 30 records, 93 corpus files, 0 baselined), `render-store-assets.ps1 -Check` (`PASS`, 4 targets), `check-matrix.ps1`, `check-tokens.ps1` (163 checks, 0 mismatches), `check-pointers.ps1` (20 pointers, 0 mismatches), `PhoneUiSizingResources.java`, `WearUiSizingResources.java`, `WearPayloadParity.java` (`PASS`), `check-version-parity.ps1` (`PASS`, 144 checks), `check-help-map.ps1` (`PASS`, 8 surfaces), `render-landing.ps1 -Check` (3 of 3 current), and the canon compliance gate (`0 error(s), 1 warning(s)`: `SZA-CTR02` on `PLAN/archive/S0001_canon-and-foundation.md`, an archived ticket, not this one's).
- **Red, expected exit 0 | actual exit 1** (known-red, named so it cannot mask anything, parked as S0042):
  - `check-drift.ps1`: `UNCARRIED: 2 of 105 row(s)` - upstream `CollapsibleSectionHeader.kt` (carried by S0039 on 2026-11-14, upstream edited again) and the wear `SystemInfoScreen.kt` (upstream commit `09d4972c8`, 2026-11-15).
  - `check-scope.ps1`: `OPEN: 3 in-scope upstream item(s)`, all `STALE DECISION` - the upstream `system-info.html` help pages in en, ru and uk changed after the not-port decision.
- Live: `curl -s -o /dev/null -m 15 -w "%{http_code}" -L` - the landing at the root, `ru/` and `uk/` answer 200; the Play listing `https://play.google.com/store/apps/details?id=com.sza.deviceinfo` answers 404, as expected before publication (criterion 9).
- Not run, by the 5 s ceiling or the owner's order: every Gradle task (build-logic tests, unit suites, dependencies, bundles), the pin, the package read-back, the device run. They are the release items below.
- Parked: S0042 (the two port gates), S0043 (the clipped Russian watch title, from S0029's action items).

## Pre-release state, 2026-11-13 (first pass, kept as the record)

Fresh runs at the fast tier; each verdict line read, not the wrapper exit code.

- `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` - expected: 0 FAIL | actual: `Summary: 10 OK, 0 WARN, 0 FAIL`.
- `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/release-queue -Validate` - expected: no drift | actual: `release-queue: OK - 14 ticket(s), no drift`, exit 0.
- `pwsh -NoProfile -File tools/port-ledger/check-drift.ps1` - expected: exit 0 | actual: exit 0, `OK: nothing uncarried (92 in step, 0 decided)`.
- `pwsh -NoProfile -File tools/release/check-version-parity.ps1` - expected: PASS | actual: exit 0, `PASS (144 checks; sentinel 2.61.1100.000 / phone 261110000 / watch 261110006)`.
- `pwsh -NoProfile -File tools/site/render-landing.ps1 -Check` - expected: current | actual: exit 0, `landing pages are current: 3 of 3`.
- `tools/check-compliance.ps1` from the plugin root - expected: 0 errors | actual: exit 0, `0 error(s), 3 warning(s)`. Warnings: `SZA-CANON03` (stale canon stamp, `adopt-canon` territory) and two `SZA-CTR02` (`PLAN/archive/S0001_canon-and-foundation.md` and `PLAN/S0012_product-landing-page.md` name the catalog by path). None is from this ticket; none blocks the release.
- Live site, `curl -s -o /dev/null -m 15 -w "%{http_code}" -L`: expected: 200 | actual: 200 for the landing at the root, `ru/` and `uk/`, `privacy.html`, `privacy-ru.html`, `privacy-uk.html`, `sitemap.xml`, `robots.txt` and `assets/social-card-1200x630.png` (nine addresses, all under `https://serzhyale.github.io/DeviceInfo_Android/`). The Play listing `https://play.google.com/store/apps/details?id=com.sza.deviceinfo` answers 404, as expected before publication (criterion 9).
- Keystore state (criterion 1): `P:\ANDROID\DeviceInfo_credentials` does not exist, `deviceinfo.signing.dir` is not in `%USERPROFILE%\.gradle\gradle.properties`, `DEVICEINFO_SIGNING_DIR` is unset.
- Release notes: `docs/play/PLAY_LISTING.md` holds a first-release notes line in each of en, ru and uk; measured length 224, 248 and 253 characters, limit 500.
- Compile gate: `commands.compileCheck` is absent from `.sza-profile.json` and this pass edited no compiled source: no compile command, nothing to compile.

## Release items (RELEASE: not run between releases)

Each names the command the release will run; items 4 to 8 need the keystore, which exists since 2026-11-14 (S0029). Before item 1 the whole fast list of `docs/RELEASE.md` step 1 is re-run, `check-scope.ps1` included (6.9 s, a release-start run); at the fourth resume pass every other gate of that list exited 0 (S0042, S0044 and S0046 are all landed).

1. `.\gradlew.bat -p buildSrc test` - the build-logic tests.
2. `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest` - the unit suites (flavored phone tasks, S0038), including the S0011 and S0013 edits that were never compiled.
3. `.\gradlew.bat :phone:dependencies --configuration storeReleaseRuntimeClasspath` and `.\gradlew.bat :wear:dependencies --configuration releaseRuntimeClasspath` - notices and the telemetry claim.
4. `pwsh -NoProfile -File tools/release/new-version-pin.ps1`, then `.\gradlew.bat :phone:bundleRelease :wear:bundleRelease` with the printed pin - R8, shrunk resources, lint-vital and the signing of the real bundles.
5. `pwsh -NoProfile -File tools/release/read-package-info.ps1 <bundle> -ExpectedName .. -ExpectedCode .. -AllowedPermissions ..` for both bundles.
6. The signed release variant on a phone and a watch: Send to phone end to end, every report section opened, and the S0011 notification check on a fresh Android 13+ install.
7. The one-way store steps of criteria 6 to 8, each on the owner's order.
8. After the listing answers 200: `/site-audit` over this repository and the `docs/RELEASE.md` live checks.

## Questions

### Questions (v1, 2026-11-13) - answered 2026-11-13

- DO: create the upload keystore in `P:\ANDROID\DeviceInfo_credentials`, write `keystore.properties` beside it, keep the app signing key there, and set `deviceinfo.signing.dir` in `%USERPROFILE%\.gradle\gradle.properties`.
- DO: take 2 to 8 phone screenshots on a real phone and upload them to the default listing.
- DO: take the Wear OS screenshots for en-US, ru-RU and uk and upload them in the console's Wear OS form-factor step 1.

### Quiz decisions (2026-11-13)

The sitting presented the three `DO:` actions one by one (each with the options "not done yet", "done, verify", "not an entry gate but a release step"). State observed at the sitting: `P:\ANDROID\DeviceInfo_credentials` absent, `deviceinfo.signing.dir` not in `%USERPROFILE%\.gradle\gradle.properties`, `DEVICEINFO_SIGNING_DIR` unset.

- DO 1, upload keystore, `keystore.properties` and `deviceinfo.signing.dir` -> not done yet (the owner's answer "Ещё не сделано"; the observed state above agrees; the input stays unfilled).
- DO 2, 2 to 8 phone screenshots uploaded to the default listing -> not done yet (the owner's answer "Ещё не сделано"; they come from the single device sitting of the release run, which has not happened).
- DO 3, Wear OS screenshots for en-US, ru-RU and uk -> not done yet (the owner's answer "Ещё не сделано"; same device sitting).
- Nothing else was asked: the carried S0008 question stays under `### Assumed (unattended, 2026-11-13)` (the sitting did not list assumptions), and the one-way steps stay on the owner's explicit order.

Outcome: no input was filled, so the ticket stays in `BlockQuestions` and the `### Questions (v1, 2026-11-13)` block above is not stamped answered - its three actions are all still open.

### Quiz decisions (2026-11-13, second sitting)

- DO 1 to 3 (upload keystore, phone screenshots, Wear OS screenshots) -> still not done (checked again: `P:\ANDROID\DeviceInfo_credentials` does not exist); the owner ordered a separate ticket for all three operations, with this one blocked by it: "Нужен другой тикет - на выполнение всех этих операций - а этот заблокирован новым тикетом". Filed as S0029 (Carrier: S0029); this ticket moves to BlockByOtherTask with Blocker: S0029 and the `### Questions (v1, 2026-11-13)` block is stamped answered - its three actions now live in S0029.

### Questions (v1, 2026-11-15) - answered 2026-11-15

- Q: Do you order the first Google Play publication now - the release run of docs/RELEASE.md (signed bundles, package read-back, device sitting) and then the first upload to the internal track?
  - Yes, order the release run now (recommended) - the build side runs the release tier of docs/RELEASE.md with DEVICEINFO_TIER=Release up to the signed bundles and the read-back; the upload, the app signing key import, the Wear OS opt-in and the production review each still wait for their own separate order.
  - Close S0043's device check first - the watch title is checked and, if it clips, fixed and the Wear OS screenshots retaken before the release run; costs one more device sitting and moves the first publication later, although S0043 gates no criterion of this ticket.
  - Hold the publication - the ticket stays parked, nothing runs and nothing is uploaded until the owner orders it.
- DO: make the off-machine copy of the whole P:\ANDROID\DeviceInfo_credentials directory before the app signing key import of the first upload.

### Quiz decisions (2026-11-15)

- Owner's order in chat: "made everything we need for S0014_play-first-publication".
- Q: order the first Google Play publication now? -> yes, the whole ticket, not only the release run: "выполни всё сам для решения этой задачи" (asked where to stop after the release run; the owner named no stop, so the order covers the release run, the device run on emulators, the first upload with the app signing key import, the Wear OS opt-in, the production promotion and review, the changelog move and the tag, criteria 4 to 8).
- DO: the off-machine copy of `P:\ANDROID\DeviceInfo_credentials` -> the build side makes it: "выполни всё сам в рамках этой задачи".

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: hub:S0009 | since: 2026-11-13

## Last Audit

**Date:** 26-11-15 18:45 | **Mode:** release audit (owner's order) | **Outcome:** BlockExternal (Google review)
**Counts:** PASS 8 | WARN 0 | FAIL 0 | MANUAL 1 | UNCHECKABLE 0 | EXEMPT 1 | RELEASE 1

Replaces the audit of 26-11-15 02:20. Every step the build side and the console can take is done; the ticket waits on Google's review (external), after which criterion 9 runs.

PASS: criterion 1 (keys present, copied off-machine with matching hashes); criteria 2 and 3 (S0029's screenshots, re-observed in the console this run: Wear OS form "2 of 3", then opted in); criterion 4 (release run: 20 of 20 fast gates, buildSrc, 88 + 92 + 54 tests with 0 failures, pin, notices, pinned bundles, read-back PASS on both `.aab` and both APKs, help rung 2 held - see "Release run, 2026-11-15"), except the end-to-end Send to phone, held as MANUAL below; criterion 5 (S0011 flow observed on the Pixel_9 emulator with the signed release APK: explanation, system prompt, refusal snackbar, menu entry); criterion 6 (app signing key `25:2C:D1..` imported, upload key registered, both bundles on internal testing); criterion 7 (Wear OS opted in); criterion 8 (production releases of both packages sent for review with notes in three languages, CHANGELOG moved, tag pushed).
MANUAL: Send to phone end to end on a real paired phone and watch, installed from the internal testing link. The emulators cannot pair (no companion, no account); the wire fields are proven kept in the release dex.
RELEASE: criterion 9 - the listing answers 200 only after the review approves; then the live checks of `docs/RELEASE.md` and the downstream tickets (hub:S0009 and the footer-grid tickets).
EXEMPT: criterion 10 - trader status, February 2027, the owner's own console step.

### Action items
1. Google: the review of the 15 changes ("typically within 7 days"); managed publishing is off, so approval publishes the app by itself.
2. After approval: `curl ... details?id=com.sza.deviceinfo` expects 200, then the live checks of `docs/RELEASE.md` ("After the site and the listing are live"), the S0012 live checks and the hub row (hub:S0009).
3. Owner, with a real phone and watch: join the internal test (`https://play.google.com/apps/internaltest/4701021673790733948`), install both, run **Send to phone** - closes the MANUAL item and the device checks of S0007 and S0011.
4. S0043 - parked, not a gate: the clipped Russian watch title.
5. New after the submission, not this release's (`check-fast.ps1` at 18:50: 18 of 20): `check-scope.ps1` reports 3 `STALE DECISION` (the upstream `app_v2/src/main/assets/help/{en,ru,uk}/system-info.html` changed after their decisions were recorded), and `check-tokens.ps1` reports 5 meanings (`system.hardware`, `system.memory`, `device.watch`, `system.health`, `system.environment`) now in the ICON-SET vocabulary, so the source rows move from `provisional` to `meaning`. Both are outside changes after the release run passed 20 of 20; neither touches the submitted packages. Each needs its own ticket before the next release start.

### Manual / on-target
- Send to phone end to end on a real paired phone and watch (action item 3).
