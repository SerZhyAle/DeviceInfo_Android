# S0027_target-state-acceptance

**Status:** BlockNeedUserTest
**Status note:** Static audit of 2026-11-14 16:40 is Verified (PASS 17, FAIL 0); S0039, S0040 and S0041 released and their commands exit 0. Open manual checks: S0007 device run (owner, at the device), footer-grid rows S0015, S0028 and S0030 (hub session and owner), post-publication 200 answers and catalog rows (owner, after the Play listing), release-tier run. No compiled source edited, no compile command needed.
**Created:** 2026-11-13
**Complexity:** medium - assessed at the spec pass 2026-11-14 and re-confirmed at the re-audit of the same day: no source, resource or tool edit; 26 checks over the owner's six statements, each a fast-tier command or a static grep; the first pass found two reds (S0039, S0040, both carried), the second run found a third (S0041, carried), the third run found none
**Depends on:** S0007, S0016, S0017, S0018, S0019, S0020, S0021, S0022, S0023, S0024, S0025, S0026, S0039, S0040, S0041

## 0. Owner request (verbatim)

Owner's correction order, 2026-11-13, verbatim (chat, Russian), given after ten tickets (S0016-S0025) had been captured from the first order recorded in S0016 section 0:

"правильно ли я понял, что по производству всех заказаных задач
это приложение будет иметь весь функционал по соответствующей суб-программы телефона (любом андроид устройстве), часах , который реализован в FMS_A был представлен в виде самостоятельных приложений android,  которые могут заинтересовать пользователя, которому не интересен весь остальной функционал FMS_A
Но при этом эти приложения будут выглядеть более-менее одинаково, развиваться вместе и новый/исправленный функционал обновляется/исправляется в них паралельно, они пересекаются по документации, принадлежат общему семейству программ и связаны канонами и контрактами.
Поправь спецификации чтобы было именно так"

Agent findings below are not the owner's words.

Position this ticket serves: all six statements of the owner's description of the finished product.

Finding: the first ten tickets each close one gap, but no ticket states the owner's description as one acceptance, so the product could pass every ticket and still not be what was ordered. This ticket is that acceptance; it does no feature work of its own.

Facts the acceptance rests on (read 2026-11-13):
- FastMediaSorter_mob_v2/app_v2/build.gradle.kts creates a product flavor noLegal (comments around lines 690-720: sideload-only build, own proguard file, versionNameSuffix -NoLegal) and a store-clean flavor "no noLegal source set" (comment near line 993). The seven extended diagnostics sections live in the noLegal source set upstream. Here they live in the restricted flavor (S0009), which is never shipped because the first release is Google Play only (S0008 owner decisions). So the standalone store apps match the store edition of FMS_A, and the seven sections are carried but not distributed; this is an owner-decided exception that the acceptance records openly instead of hiding.
- Open manual checks cannot be closed by an agent: device and emulator runs (S0007), the Play listing and landing answering 200, the catalog accepting the family-map and version-table rows.
- The set that feeds this acceptance: S0016, S0017, S0018, S0019, S0020, S0021, S0022, S0023, S0024, S0025, S0026 and the existing S0007 (device check), S0008, S0014, S0015.


## 1. Problem

The owner's description of the finished product has six statements, and no ticket states them as one acceptance, so the product could pass every ticket and still not be what was ordered. This ticket is that acceptance; it does no feature work of its own.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

Each statement is checked by the evidence named; a statement that rests on a device, a store or the catalog stays an open manual check until it is run, never a pass.
- T1 Standalone phone and watch apps with all the Device Information functions of FMS_A: `tools/port-ledger/check-drift.ps1` and the scope check of S0018 exit 0; the S0007 device checks have run; a search for com.sza.fastmediasorter in phone/src, wear/src and the Gradle files finds no code or dependency hit (KDoc and ledger mentions are history). Recorded exception, owner-decided in S0008 and S0009: the seven extended diagnostics sections exist upstream only in the noLegal sideload flavor and here only in the restricted flavor, which is never shipped; the store apps match FMS_A's store edition.
- T2 The two apps look more or less alike: S0022 token check exits 0 and its screenshots exist; the S0023 conformance tables hold.
- T3 They develop together and a new or fixed function lands in both in parallel: the S0017 payload test passes; the S0021 matrix check exits 0 and the scope rule is in CLAUDE.md; S0018 and S0019 cover the FMS_A side as the owner answered.
- T4 Their documentation overlaps: the S0020 surfaces check exits 0; the help of S0024 exists in three languages; one landing, one listing and one privacy text describe both packages.
- T5 They belong to one family: the S0025 register is complete and its post-publication checks are listed as open; the footer-grid work of S0015 is in step with the family map.
- T6 They are bound by the canon and the contracts: `check-compliance.ps1` exits 0 with no warning; `tools/contracts/check-pointers.ps1` exits 0 (S0016); the S0023 tables and the S0025 register hold.
- Every fast tier command of CLAUDE.md section 6 has been run in the session that closes this ticket, with exit code and output cited.
- The open manual and post-release checks are listed once, each with who runs it; the ticket parks in BlockNeedUserTest until they run, like S0007.

## 3. Approach

### 3.1 Scope

What changes: this spec file only (its sections, the evidence table and the audit block). No source, resource, build file, tool script or document outside this ticket is edited, so there is no compiled source, no compile gate (`commands.compileCheck` is absent from `.sza-profile.json`), no probe and no user-visible behavior. Scope for the S0021 matrix rule: n/a - the ticket changes no behavior on either side, so no matrix row is touched.

What deliberately does not change: any finding the pass makes. A red found here is captured as its own Draft and the ticket waits on it; the acceptance does no feature work (section 1).

The recorded exception of T1 stays as the owner decided it in S0008 and S0009: the seven extended diagnostics sections exist upstream only in the `noLegal` sideload flavor and here only in the `restricted` flavor, which is never shipped (first release is Google Play only), so the store apps match FMS_A's store edition.

### 3.2 Open questions

None open. The manual and post-release checks of the audit are not questions: each names its owner and the ticket that carries it.

### Assumed (unattended, 2026-11-14)

- T6 reads "`check-compliance.ps1` exits 0 with no warning". It exits 0 with 0 errors and one warning, `SZA-CTR02` on the archived `PLAN/archive/S0001_canon-and-foundation.md` (names the catalog by a drive path). Taken: the warning is EXEMPT, because S0016 decided on 2026-11-13 that the archived ticket stays as written (a correction would rewrite what the archived record read on the day, and the gate's allowed-file list cannot include archive files), and a canon rule that looks wrong for this repository is reported to the canon session, never patched here. Alternative weighed: hand-edit the archived S0001 so the gate is silent. Owner may overrule.
- The two reds of the first pass (T1 drift, the help-capture tooling) were not fixed inside this ticket. Taken: each was captured as its own Draft (S0039, S0040) and this ticket waited on both, so the acceptance is re-run on a tree where the fast tier is green. Alternative weighed: fix both inline - rejected, the carry is port work on compiled Kotlin and the recipe needs the watch UI read, both outside "does no feature work of its own". Owner may overrule. Outcome: both reached Implemented, and the re-audit below confirms their commands exit 0.

### Assumed (unattended, 2026-11-14, re-audit)

- The third red, `check-local-divergence.ps1 -RequireClassified` exit 1 on the unclassified local edit of `GatherSystemInfoUseCaseTest.kt`, is already its own Draft (S0041, captured by the S0039 pass). Taken: not fixed inside this ticket; S0041 joins the `**Depends on:**` line and this ticket parks in `BlockByOtherTask` until S0041 reaches `Implemented` or later, then the table is re-run once more. Alternative weighed: classify the edit inline with `record-local-decision.ps1` - rejected: it writes a tracked decision record outside this ticket's declared scope (section 3.1 says this spec file only), the classification needs a review of the whole file change against the upstream test, and a `candidate` outcome needs a reverse-port notice, which is owner-facing (section 2 rule 5 of `CLAUDE.md`). Owner may overrule. Outcome: S0041 reached Verified on 2026-11-14 and the third run (section 5) confirms `check-local-divergence.ps1 -RequireClassified` exit 0.
- The T1 search for FastMediaSorter code or dependency hits is read as the criterion states it: `com.sza.fastmediasorter` in `phone/src` and `wear/src` and any dependency in the Gradle files. A case-insensitive search for `fastmediasorter` also finds comments and KDoc (7 hits in 5 phone files, 5 hits in 3 Gradle-set files: `gradle/libs.versions.toml`, `phone/build.gradle.kts`, `gradle.properties`); the criterion itself names KDoc as history. Taken: those are history, not hits. Alternative weighed: treat any mention as a hit - rejected, it would forbid the recorded port provenance that CLAUDE.md section 7 asks for. Owner may overrule.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0007 (device check), S0008, S0014, S0015, S0016 to S0026 (the set the acceptance rests on), S0039 (carry of the upstream drift), S0040 (help capture recipe), S0041 (classify the local edit of `GatherSystemInfoUseCaseTest.kt`), S0028 and S0030 (sibling footer-grid rows)
- **Owner inputs before implementation:** n/a - the evidence is collected without the owner; the checks that need the owner are listed in the audit block

## 4. Blockers

No open blocker. The three blockers found by the earlier passes are released: S0039 (the upstream drift behind the T1 command) and S0040 (the capture-tooling regression behind two fast-tier commands) reached Implemented on 2026-11-14, and S0041 (the unclassified local edit behind the T3 FMS_A-side command) reached Verified on 2026-11-14; the table below confirms the command of each exits 0. The `Blocker: S0041` token and the S0041 entry of the `**Depends on:**` line stay as the record of the dependency; S0041 is released (TASK-FLOW rule 69).

## 5. Evidence, third run of 2026-11-14 (16:33 to 16:38)

The first pass of the same day (15:22) found two reds, S0039 (T1 drift) and S0040 (help-capture tooling); the second run (16:20 to 16:30) confirmed both closed and found a third, S0041 (T3 local divergence); this third run is the re-run the second run's audit block asked for, after S0041 reached Verified. Every command run fresh in this pass from the repository root, `pwsh -NoProfile -File <script>` (the Java checks with `java <file>`); times are this pass's wall clock. Format: expected | actual. Where a line below still names an earlier figure of the second run, the third run's figure is the one in the line's command column.

Third-run result, one line per red of the earlier runs: T1 drift `check-drift.ps1` exit 0, `OK: nothing uncarried (105 in step, 0 decided).`, 0.37 s; help-capture tooling `capture-help.ps1 -DryRun` exit 0, 0.76 s; T3 local divergence `check-local-divergence.ps1 -RequireClassified` exit 0, `Local edits: 9; unclassified: 0; missing: 0; unanchored: 0.` / `OK: every local edit is classified.`, 0.37 s (the second run: exit 1, one unclassified edit). Every other command below re-ran in this pass with the same exit code and the same verdict line as in the second run; the timings in those lines are the second run's and the third run's differ from them by under 0.1 s, except `test-check-tokens` (4.51 s in the third run) and the T4 word counts, which the line itself gives for the third run. The two commands above the 5 s tier were not re-run (see the end of this section).

T1 - standalone phone and watch apps with the FMS_A Device Information functions
- `tools/port-ledger/check-drift.ps1`: exit 0 | exit 0, `OK: nothing uncarried (105 in step, 0 decided).`, 0.40 s. PASS (the S0039 carry holds; first pass: exit 1).
- `tools/port-ledger/check-scope.ps1`: exit 0 | exit 0, `OK: every in-scope upstream item is ported or decided (376 ported, 19 decided)`, 2.1 s. PASS.
- search `com.sza.fastmediasorter` in `phone/src` and `wear/src`, and any dependency in the root Gradle files, `buildSrc`, `gradle/`, `gradle.properties`: no code or dependency hit | `com.sza.fastmediasorter`: 0 hits in both source trees; the Gradle set has no dependency on it. A case-insensitive search for `fastmediasorter` finds only comments and KDoc: 7 hits in 5 phone files (the restricted collectors, their test, `WearDataLayerPaths`, `GatherSystemInfoUseCase`, `SensorsDiagnosticsCollector`), 0 in wear, 5 in `gradle/libs.versions.toml`, `phone/build.gradle.kts` and `gradle.properties` (provenance comments). PASS under the last assumption of section 3.2 (the first pass recorded 0 for the case-insensitive form; the Gradle comments and the phone KDoc are the difference, both history).
- the S0007 device checks have run | not run: S0007 is `BlockNeedUserTest`. MANUAL.
- exception, seven extended sections upstream `noLegal` only, here `restricted` only and never shipped | recorded in section 3.1 as the S0008 and S0009 owner decision. EXEMPT.

T2 - the two apps look more or less alike
- `tools/design/check-tokens.ps1`: exit 0 | exit 0, `check-tokens: OK - 163 check(s) equal, 0 mismatch(es)`, 0.43 s. PASS.
- the S0023 conformance tables hold | `java phone/src/test/java/com/sza/deviceinfo/ui/PhoneUiSizingResources.java` exit 0 `Phone UI sizing resources: OK`; `java wear/src/test/java/com/sza/deviceinfo/wear/ui/WearUiSizingResources.java` exit 0 `Wear UI sizing resource: OK`; `docs/UI_CONFORMANCE.md` and `docs/design/IDENTITY.md` exist (`Test-Path` True for both, this pass). PASS.
- S0022 screenshots exist (same-screen evidence) | a device or emulator run (S0007), none committed. MANUAL.

T3 - they develop together
- payload parity, `java phone/src/test/java/com/sza/deviceinfo/service/WearPayloadParity.java <phone payload> <wear payload>`: exit 0 | exit 0, `PASS: report and ack fields and format version match`, 0.57 s. PASS.
- `tools/parity/check-matrix.ps1`: exit 0 | exit 0, 42 rows, every row carries a phone and a watch cell, 0.30 s; the scope rule is in `CLAUDE.md` section 4 (line 43, "Scope of a behavior-changing ticket (S0021)"). PASS.
- the FMS_A side as the owner answered (S0018, S0019): `check-scope.ps1` as above, exit 0; `tools/port-ledger/check-local-divergence.ps1 -RequireClassified`: exit 0 | exit 0, `Local edits: 9; unclassified: 0; missing: 0; unanchored: 0.`, `OK: every local edit is classified.`, 0.37 s. PASS (the second run: exit 1 with one unclassified edit, `GatherSystemInfoUseCaseTest.kt`, captured as S0041 and closed there; the first pass recorded exit 0 for 10 edits before the S0037 edit existed).

T4 - the documentation overlaps
- `tools/docs/check-surfaces.ps1`: exit 0 | exit 0, string keys agree across en/ru/uk per module (phone 225/224/224 with one `translatable="false"` exempt), permissions agree across the manifests, the inventory, the privacy pages and the Data safety answers, 0.37 s. PASS.
- `tools/docs/check-docs.ps1`: exit 0 | exit 0, `docs-check: PASS (30 records, 92 corpus files, 75 Markdown, 7 links, 18 asset citations, 0 baselined)`, 1.45 s. PASS.
- help in three languages: `tools/help/check-help-map.ps1` exit 0 `help-map: PASS (8 surfaces, 2 help pages, 18 page files, 9 read)`, 1.28 s; `tools/help/render-help.ps1 -Check` exit 0 `render-help: PASS (22 files current)`, 0.74 s; the en, ru and uk page directories exist in the app assets `phone/src/main/assets/help/` and under `site/help/`, 3 files each (this pass). PASS.
- one landing, one listing and one privacy text describe both packages | `docs/play/PLAY_LISTING.md`, `site/privacy.html`, `site/index.html`, `site/ru/index.html` and `site/uk/index.html` each name phone and watch (case-insensitive counts of the phone words and the watch words, English and the locale's own, phone/watch, third run: 27/30, 17/23, 33/35, 32/29, 32/35, in the order listing, privacy, landing en, ru, uk; every file names both packages); `tools/site/render-landing.ps1 -Check` exit 0 `landing pages are current: 3 of 3`, 0.40 s. PASS (static grep, not a read of the rendered pages).
- help screenshots: `tools/help/check-help-captures.ps1` exit 0 | exit 0 but `NOT HELD (no capture record; 9 image(s) are owed by the device run)`; rung 2 is not claimed. RELEASE: `tools/help/capture-help.ps1 -PhoneSerial <serial> -WearSerial <serial> -ProductVersion <versionName>` (`docs/RELEASE.md` step 3a).

T5 - one family
- the S0025 register: `docs/contracts/README.md` lists the 20 consumer rows with the open item and owner of each; `tools/contracts/check-pointers.ps1` exit 0 | exit 0, `OK - 20 pointer(s) checked, 2 skipped, 0 mismatch(es)`, 0.37 s. PASS.
- the footer-grid work in step with the family map | S0015, S0028 and S0030 are all still `BlockByOtherTask` (read from the release queue this pass) on hub rows that SITE-FAMILY-MAP rule 5 forbids until the sibling landing and listing answer 200. Not in step yet. MANUAL (hub session and owner).
- the post-publication checks are listed as open | this audit block lists them; they cannot run before the Play listing and the landing exist. MANUAL.

T6 - bound by the canon and the contracts
- `check-compliance.ps1` from the plugin root (`2026.1113.8`): exit 0, no warning | exit 0, `0 error(s), 1 warning(s)`, the warning `SZA-CTR02` on the archived S0001, 0.78 s. EXEMPT under the first assumption of section 3.2.
- `tools/contracts/check-pointers.ps1` exit 0, as under T5. PASS.

Other fast-tier commands of `CLAUDE.md` section 6, all exit 0 | actual:
- `spec_catalog/validate`: `Summary: 10 OK, 0 WARN, 0 FAIL`, 0.80 s; `spec_catalog/release-queue -Validate`: `OK - 41 ticket(s), no drift`, 0.77 s; `tools/release/check-version-parity.ps1`: `PASS (144 checks; sentinel 2.61.1100.000 / phone 261110000 / watch 261110006)`, 0.29 s; `tools/store/render-store-assets.ps1 -Check`: `PASS (4 targets, pixels equal to the render)`, 0.41 s. PASS.
- self-tests `test-port-ledger`, `test-port-scope`, `test-local-divergence`, `test-check-surfaces`, `test-check-docs`, `test-check-matrix`, `test-check-tokens`, `test-render-store-assets`: all exit 0 (third run: 0.59 s to 4.51 s). PASS.
- `tools/help/capture-help.ps1 -DryRun`: exit 0 | exit 0, `capture-help: DRY RUN ok (2 page(s), 3 locale(s); no device touched)`, 0.69 s, the element `interface-size` is now located by `textRefFormat system_info_interface_scale`; `tools/help/test-help-captures.ps1`: exit 0 | exit 0, `test-help-captures: PASS (64 expectations)`, 6.13 s. PASS (the S0040 carry holds; first pass: exit 1 and 5 of 62). That self-test is above the 5 s tier by its recorded time; it was run here only because it is the command whose red this re-audit confirms closed, and it is not repeated.
- `tools/help/test-check-help-map.ps1` (5.8 s recorded, above the 5 s tier): not run. RELEASE.

Not run, release tier: `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug`, `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest`, `.\gradlew.bat -p buildSrc test`. Not built, not tested until the release. No compiled source was edited by this pass, so the declared compile check was not run.

## Last Audit

**Date:** 26-11-14 16:40 | **Mode:** re-audit | **Outcome:** Verified
**Counts:** PASS 17 | WARN 0 | FAIL 0 | MANUAL 4 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 3

This is the static verdict of the table in section 5 (zero WARN, zero FAIL). The ticket is not closed by it: four MANUAL items are open, so the status is `BlockNeedUserTest` and stays there until the owner closes them and a re-audit confirms it (the S0007 precedent). The three reds of the earlier runs are closed: the T1 drift (S0039, `check-drift.ps1` exit 0, 105 in step), the help-capture tooling (S0040, `capture-help.ps1 -DryRun` exit 0, `test-help-captures.ps1` 64 expectations in the second run) and the T3 local divergence (S0041, `check-local-divergence.ps1 -RequireClassified` exit 0, 9 edits, 0 unclassified).

### Action items
1. None for the agent. Added `PLAN/probe-baseline.txt` row for S0027 (the ticket changes no code, so it has no probe to carry; S0032 is the precedent). No compiled source was edited by this pass, so the declared compile check was not run and nothing is "compiled, not tested".
2. Recorded owner-facing assumptions stay as in section 3.2: the T6 `SZA-CTR02` warning on the archived S0001 is EXEMPT, and the case-insensitive `fastmediasorter` hits (comments and KDoc) are history. Owner may overrule both.

### Manual / on-target
- [ ] S0007 device or emulator run (owner, at the device): the phone and watch scenarios, Data Layer sync, the same-screen evidence of S0022 and S0023 (screenshots, the four interface sizes, the keyboard and crown walk), the help walk. Passing: each scenario recorded with a date and a not-covered list.
- [ ] Footer-grid rows of the family map (hub session and owner): S0015, S0028 and S0030 resume when the hub enters the StreamsPlayer, Tourist and Filler rows. Passing: the three footers equal the family map.
- [ ] Post-publication checks (owner, after the Play listing and the landing exist): the landing, the help index and the Play listing answer 200; the catalog accepts the DeviceInfo family-map and version-table rows (`docs/RELEASE.md`, S0014).
- [ ] Release tier (the release run): the Gradle build and unit tests above, `tools/help/capture-help.ps1` with both device serials, `tools/help/test-check-help-map.ps1`.
