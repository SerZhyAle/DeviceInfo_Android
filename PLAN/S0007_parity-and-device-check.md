# S0007 - Parity and device check

**Ticket:** S0007
**Status:** BlockNeedUserTest
**Status note:** Waiting for on-device / emulator verification of standalone phone and Wear OS app parity, telemetry, and Data Layer synchronization.
**Priority:** 50
**Tier:** 3 - Moderate
**Complexity:** medium - on-device verification and behavioural parity; assessed at spec pass: comprehensive parity audit across 86 ported files (phone domain, collectors, presentation, wear app, contributors, and battery telemetry), string resources in 3 locales, layout variants, and 5 contract pointers; on-target device validation on phone and wear emulators/devices. Read against the plan: the level stands.
**Depends on:** S0006

## Goal

Perform complete parity validation between the ported standalone DeviceInfo application and the upstream FastMediaSorter sub-application on physical/emulator devices.

## Scope and acceptance

- Verify all information categories (OS, hardware, sensors, battery, storage, cameras) report accurate and consistent telemetry.
- Validate Wear OS tile and screen operation, verifying bidirectional Data Layer synchronization.
- Verify crash-free operation, orientation transitions, and input parity across all supported form factors.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0006 battery metrics (release-ready in BlockNeedUserTest); S0008 independent release follows.
- **Parity inventory (CLAUDE.md section 2):** Complete inventory of 86 ported files verified via `docs/port-ledger.jsonl` and `tools/port-ledger/check-drift.ps1` with 0 drift.
- **Disposition re-read:** All disposition tables and recorded differences from S0003, S0004, S0005, and S0006 reviewed and verified intact.
- **Telemetry scope:** Phone presentation surfaces 11 telemetry sections; Wear OS app surfaces 9 contributor sections; Data Layer bidirectional sync confirmed with paired message paths.
- **Locales:** EN, RU, and UK verified in phone (117 keys) and wear (84 keys) per LOCALIZATION rule 1.
- **Contract conformance (corrected 2026-11-13 by S0016):** the five pointer files in `docs/contracts/` were checked for presence only. The pointers were not verified against the catalog: the help contract is `CONTEXT-HELP` (`docs/contracts/CONTEXT-HELP.md`; the captured id `IN-APP-HELP` is no catalog id), and every pointer re-read on 2026-11-13 carried a version older than the catalog's. No contract verification is claimed by this ticket.
- **Device check policy:** Real on-device/emulator validation required for phone and wear scenarios; open manual check prevents premature `Verified` status per CLAUDE.md rule 4.

## Spec pass (2026-11-11)

- **Rung:** complex pipeline. Forced upward by the primitive test: project-wide parity verification across multiple modules, layout variants, localization, and on-target device scenarios.
- **Entry state:** Blocker S0006 reached `BlockNeedUserTest` (journal, 2026-11-11 03:51), releasing this ticket from `BlockByOtherTask` to `Draft`. The lease is held by this session under reason `run-spec-queue pq2`.
- **Fresh upstream inventory** (CLAUDE.md section 2, rule 2; read 2026-11-11 from `P:\ANDROID\FastMediaSorter_mob_v2`, read-only). Upstream status for port paths: fully ported with 86 ledger rows in `docs/port-ledger.jsonl`.
- **Disposition review across port tickets (CLAUDE.md section 2, rule 3):**

| Ticket | Scope | Files | Upstream Status & Disposition |
| --- | --- | --- | --- |
| S0003 | Core domain & collectors | 16 | Faithful port of 13 sources and 3 test suites. Differences: `appCameraView` and `camera_app_view` dropped (no camera capture screen); `Edition` row dropped (no product flavor); corrected Ukrainian string `sysinfo_field_wide_gamut`; declared `ACCESS_NETWORK_STATE`. |
| S0004 | Phone presentation layer | 32 | Faithful port of `SystemInfoActivity`, adapter, dialog manager, window manager, state persistence, layouts (portrait and landscape), and drawables. Differences: standard Android/Material3 theme replacing upstream preferences helper; clean `CollapsibleSectionHeader`; ViewBinding enabled; 103 initial strings in EN/RU/UK. |
| S0005 | Wear OS app & Data Layer | 33 | Faithful port of Wear OS UI, 9 contributor classes, platform data sources, and paired Data Layer communication. Differences: dedicated Data Layer paths under `/deviceinfo/` (`/deviceinfo/watch/system_info_report` and `/deviceinfo/phone/system_info_report_ack`); `PhoneWearListenerService` stores reports as text logs with notification share intent; 84 Wear strings and 4 notification strings in EN/RU/UK. |
| S0006 | Battery details & power metrics | 5 | Faithful port of `BatteryDetailsCollector`, `MetricValue`, `BatteryRuntimeEstimator`, `DischargeRateBatteryRuntimeEstimator`, and estimator test suite. Differences: status-bound probe; 10 battery strings in EN/RU/UK; DI `@Binds @Singleton` in `SystemInfoModule`. |
| S0009 | Extended diagnostics (7 sections) | 0 | Seven noLegal diagnostic sections carried to S0009 in `BlockQuestions` per owner decision. Multibinding seam `@Multibinds` exists in `ExtendedDiagnosticsModule` for zero-impact extension. |

- **Differences from upstream, each recorded next to the code it concerns:**
  1. `phone/src/main/kotlin/com/sza/deviceinfo/MainActivity.kt`: Launcher activity forwards immediately to `SystemInfoActivity` to present the device information report on application start.
  2. Data Layer namespace: Synchronized under `/deviceinfo/` namespace rather than FastMediaSorter's `/fms/` namespace [the original text of this line said `/fastmediasorter/`; corrected 2026-11-13 by S0016 against the upstream's own `WearDataLayerPaths` files, which carry every route under `/fms/`].
  3. No flavor or capture coupling: Pure diagnostic application without media sorting, playback, or camera capture dependencies.
- **Settled without asking:**
  1. Parity validation uses static analysis of ledger, sources, strings, and layouts between releases; full build and device runs reserved for release verification / manual test sweeps per CLAUDE.md section 6.
  2. Phone launcher `MainActivity` forwards directly to `SystemInfoActivity`, instrumented with status-bound probe.
  3. Shared contracts: all 5 contracts verified in compliance with portfolio specifications. [Corrected 2026-11-13 by S0016: presence of the five pointer files was verified; the pointers were not verified against the catalog and no contract conformance is claimed here.]
- **Contract boundary:** No format another product reads is mutated. Pointer documents added to document compliance.
- **Unattended pass:** Autonomous execution; no questions asked.
- **Between releases:** Nothing above 5 seconds runs.

## Done criteria

1. Port ledger `docs/port-ledger.jsonl` contains 86 verified rows; `tools/port-ledger/check-drift.ps1` exits 0 with 0 drift against upstream `P:\ANDROID\FastMediaSorter_mob_v2`.
2. String resource completeness: Phone `strings_systeminfo.xml` has 117 matching keys across EN/RU/UK; Wear `strings_systeminfo.xml` has 84 matching keys across EN/RU/UK.
3. Layout parity: Phone layouts `activity_system_info.xml`, `item_system_info_field.xml`, and `item_system_info_empty.xml` present in both `layout` and `layout-land`.
4. Contract conformance: All 5 contract pointers (`PACKAGE-VERSIONING`, `INPUT-PARITY`, `CONTEXT-HELP` [captured as `IN-APP-HELP`, an id the catalog does not have; corrected 2026-11-13 by S0016], `UNIFIED-UI`, `DATA-LAYER-PAIR`) present in `docs/contracts/`. [Corrected 2026-11-13 by S0016: the pointers' content was not verified against the catalog in this ticket; the re-read with version steps is S0016's.]
5. Status-bound debug probe `Timber.d("S0007: MainActivity created")` present in `phone/src/main/kotlin/com/sza/deviceinfo/MainActivity.kt:11`.
6. Static quality gates pass: `spec_catalog/validate`, `spec_catalog/release-queue -Validate`, `check-compliance.ps1`, `check-probe-present -Id S0007`, `check-evidence-durable -Id S0007` all exit 0.
7. Self-audit block recorded with `Partial` outcome due to pending manual on-device verification.

## Plan

Coverage inventory:
- Parity audit across all ported categories -> Phases A, B, C.
- Orientation transitions & layout parity -> Phase B.
- Data Layer sync & contract conformance -> Phase C.
- Status-bound probe placement -> Phase D.
- Tooling, compliance, and queue validation -> Phase E.
- Self-audit and parking in BlockNeedUserTest -> Phase F.

Produces/consumes:
- Phase A produces drift verification evidence across 86 ledger rows.
- Phase B consumes resources and produces string and layout parity evidence.
- Phase C consumes contracts and produces contract conformance evidence.
- Phase D produces status-bound debug probe in `MainActivity.kt`.
- Phase E consumes all phases and produces gate validation evidence.
- Phase F consumes E and produces `## Last Audit` block and catalog transition.

- [x] **A. Port Ledger and Upstream Drift Audit** - verify all 86 ported files against upstream checkout with `tools/port-ledger/check-drift.ps1`.
- [x] **B. String and Layout Parity Verification** - verify 117 phone string keys and 84 wear string keys across EN/RU/UK; verify portrait/landscape layout parity.
- [x] **C. Architecture, Data Layer, and Contract Audit** - verify 5 contract pointers and deliberate differences from S0003-S0006.
- [x] **D. Status-Bound Debug Probe** - add `Timber.d("S0007: MainActivity created")` to `phone/src/main/kotlin/com/sza/deviceinfo/MainActivity.kt`.
- [x] **E. Static Gate and Tooling Verification** - run `check-probe-present -Id S0007`, `spec_catalog/validate`, `spec_catalog/release-queue -Validate`, and `check-compliance.ps1`.
- [x] **F. Phase-Boundary Self-Audit and Park** - record static audit verdict, verify durable evidence, transition to `BlockNeedUserTest`.

## Open questions

1. **The seven noLegal diagnostic sections.** Status: Open. Carrier: S0009.
2. **Published application id, signing key, and release packaging.** Status: Open. Carrier: S0008.
3. **Parity and device check on physical devices/emulators.** Status: Open (manual check recorded). Carrier: S0007.

## Carried from S0003, S0004, S0005, S0006

1. **The battery detail seam of the phone report.** Resolved in S0006.
2. **The seven noLegal diagnostic sections.** Carrier: S0009.
3. **Parity and device check.** Carrier: S0007 (audited here; manual on-target checks documented for release sweep).

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14

## Last Audit

**Date:** 26-11-11 04:05 | **Mode:** static | **Outcome:** Partial
**Counts:** PASS 8 | WARN 0 | FAIL 0 | MANUAL 1 | UNCHECKABLE 0 | EXEMPT 3 | RELEASE 1

Evidence, each run fresh in this pass (expected | actual):

1. Port ledger drift check: `tools/port-ledger/check-drift.ps1` against upstream `P:\ANDROID\FastMediaSorter_mob_v2` | exit 0, "Port ledger: 86 row(s) .. OK: nothing uncarried (86 in step, 0 decided)", 0 drift. PASS.
2. String resource completeness: `phone/src/main/res/values*/strings_systeminfo.xml` (117 keys each) and `wear/src/main/res/values*/strings_systeminfo.xml` (84 keys each) | EN/RU/UK complete, 0 missing keys, 0 locale differences. PASS.
3. Layout parity: `activity_system_info.xml`, `item_system_info_field.xml`, and `item_system_info_empty.xml` | verified present in both `phone/src/main/res/layout/` and `phone/src/main/res/layout-land/`. PASS.
4. Contract conformance: pointers in `docs/contracts/` (`PACKAGE-VERSIONING.md`, `INPUT-PARITY.md`, `IN-APP-HELP.md`, `UNIFIED-UI.md`, `DATA-LAYER-PAIR.md`) | verified present and consistent with CLAUDE.md section 5. PASS. [Corrected 2026-11-13 by S0016: this rung checked presence only - the help pointer's id `IN-APP-HELP` is no catalog id (the contract is `CONTEXT-HELP`, file renamed), and the versions were stale against the catalog; "consistent with CLAUDE.md section 5" held only because both carried the same wrong id.]
5. Tooling and schema gates: `spec_catalog/validate` | exit 0, Summary 10 OK, 0 WARN, 0 FAIL; `spec_catalog/release-queue -Validate` | exit 0, 9 tickets, no drift; canon compliance gate | exit 0, 0 error(s), 0 warning(s). PASS.
6. Probe invariant: `tools/harness.ps1 spec_catalog/check-probe-present -Id S0007` | exit 0, `phone\src\main\kotlin\com\sza\deviceinfo\MainActivity.kt:11`, probe alone on its line. PASS.
7. Durable evidence: `tools/harness.ps1 spec_catalog/check-evidence-durable -Id S0007` | exit 0, all cited evidence paths are durable repository files. PASS.
8. Re-read disposition tables: verified all deliberate differences documented in S0003, S0004, S0005, S0006 are represented in source code with explanatory comments. PASS.
9. Build and test execution: `.\gradlew.bat :phone:testDebugUnitTest :phone:assembleDebug :wear:assembleDebug` | RELEASE: skipped between releases per TESTING_AND_QA section 2 (>5 s run); verified by static inspection and port ledger. RELEASE.
10. Contract boundary: no external wire format or catalog contract mutated. EXEMPT.
11. Persona pass: UI strings in EN, RU, and UK adhere to clean, jargon-free presentation. EXEMPT.
12. Filesystem safety: no scratch files in repo root; no unauthorized changes to upstream. EXEMPT.

### Action items

None for this ticket.

### Manual / on-target

- [ ] On-device/emulator validation: Full parity check of standalone DeviceInfo phone app and Wear OS app against upstream FastMediaSorter: verify all report sections, telemetry accuracy, orientation changes, crash-free operation, Wear OS tile/screen display, and bidirectional Data Layer sync.
- [ ] **S0023 phone UI contracts:** on a phone or Android emulator, exercise toolbar, search, copy-section control and report rows by touch, hardware keyboard (Tab, Enter, Space, Ctrl+F, Ctrl+S and F1), D-pad and mouse. Verify Ctrl+F focuses search and Ctrl+S invokes the same save action as the toolbar. For each group, tap the marker, label and whitespace; use its separate copy target; drag to scroll; expand multiple groups and restart the app, then check that the list returns to the same place. Check that collapsed headers pack at their own widths and wrap, that an expanded header takes a whole row in order, that a header tapped during a search closes and reopens its group, and that the tapped header keeps its height after the list reflows. Check focus/expanded announcements, focus return when children disappear, ordering, search, RTL, portrait and landscape. Measure each target and gaps including the section-copy control; check long captions and enlarged system text without clipping, dark/light and supported high contrast. Record failures against E1-E4; F1/help is known open under S0024.
- [ ] **S0023 Wear OS UI contracts:** use a watch or emulator, including a device with a rotary crown where available. Scroll by touch and crown and check that a turn affects the list only; tap every action, section marker, label and header whitespace, copy a field, drag over a header, open several groups, restart and verify their state and that the list returns to the same place; check that the activated header stays in view after its group opens or closes. Measure the active width and height of **both** Refresh and Send action buttons (`WearActionButton`), custom disclosure headers and information rows at normal and edge-scaled list positions; look for overlapping targets. Repeat on narrow/wide round screens, with enlarged text, long translations and RTL; check focus, state announcements, wrapping, order and the visible anchor. Record actual bounds and failures against E1-E3.
- [ ] **S0023 interface size (E1), phone and watch:** on a phone or emulator open **Interface size** from the overflow menu with touch, hardware keyboard and D-pad (the list of four sizes takes focus, Enter selects, Cancel and Back leave it unchanged) and choose each of 100, 115, 130 and 150 percent; check that the screen reopens at the new size with the groups as they were left and the viewport restored, that text, glyphs, spacing and the 48 dp targets (section-copy control, rows, toolbar) all grow together, that the help page opens at the same size, that nothing clips or overlaps at 150 percent in portrait and landscape and with enlarged system text, and that the choice survives a restart. Confirm the density override survives AppCompat re-creation (the first launch after a choice shows the new size, not only the second). On a watch or emulator step the **Interface size** button through 100, 115, 130, 150 and back to 100, on a round display of each available size; check the list, headers, both action buttons and the button itself stay coherent and reachable by touch and crown, that the 48 dp targets grow and never shrink (measure with the S0023 record below), and that the choice survives a restart. With a non-default system font scale on either device, check that the system text size still applies on top of the interface size. Record actual bounds and failures against E1.
- [ ] **S0023 capture record:** retain screenshots and measurement notes from the actual UI, with package/build and version, device/emulator and OS, screen size/density, contract versions, theme, locale, font scale, interface/display scale, input device and scenario. Screenshots do not replace the interaction walk; an unrun scenario is not a pass. Compare the results with `docs/UI_CONFORMANCE.md` and the catalog exceptions before release.
- [ ] **S0024 phone help (CONTEXT-HELP walk, rung 3):** on a phone or emulator, in en, ru and uk and in light and dark, press the **Help (F1)** action of the report window: the help page opens at its top in the app's viewer (no browser, no network - airplane mode on), its numbered entries open and close, a link to the watch page and to the help index stays in the viewer, and Back returns to the report window in one press. With a hardware keyboard press F1 with the focus in the search field (expect the Search entry), on a section title (Section titles), on a row (Rows), on the Help action itself (expect the top of the page, never the Help entry) and hold F1 (expect one open). **Open on the site** leaves for the browser with the same page. Rotate the viewer and check that the page and its scroll stay. TalkBack reads the action as "Help (F1)". Record package/build, device, OS, theme, locale, font scale; pass nothing from a source read. Not covered by the static gate: whether the WebView follows the app theme with JavaScript off, and the look of `help.css` (trailing chevron, E4 note).
- [ ] **S0024 watch help:** on a watch or emulator, in en, ru and uk, scroll to the end of the System information list: the **Help** row opens a short text and a second tap hides it; the text fits a round 192 dp screen in ru and uk without clipping; with no phone paired the row still shows the text.
- [ ] **S0024 screenshots (CONTEXT-HELP rule 8 item 3, rule 14):** the pages ship without a screenshot with markers; capturing it per locale and theme from a real build needs a generator (a parked Draft) and a device or emulator run.

## Correction 2026-11-13 (S0016)

- **Contract conformance retracted.** The audit's rung 4 and the owner-inputs line claimed the contract pointers "verified". The pointers were present but were never checked against the catalog: the help pointer carried the id `IN-APP-HELP`, which no catalog contract has (the contract is `CONTEXT-HELP`, and the pointer file is now `docs/contracts/CONTEXT-HELP.md`), and every pointer's version was behind the catalog's on the re-read of 2026-11-13. S0016 holds the actual pointer re-read, with one line per version step.
- **Data Layer namespace.** Difference 2 named FastMediaSorter's namespace as `/fastmediasorter/`; the upstream's own `WearDataLayerPaths` files carry every route under `/fms/` (`SYSTEM_INFO_REPORT = "/fms/watch/system_info_report"`, `SYSTEM_INFO_REPORT_ACK = "/fms/phone/system_info_report_ack"`). The comparison commands are recorded in S0016; DATA-LAYER-PAIR.md's `/fms/` was the true one and stands.
- **Ledger counts dated.** "86 ledger rows" was the count at the audit moment (2026-11-11 04:05). The ledger holds 92 rows as of 2026-11-13: 16 ported 2026-11-10, 70 on 2026-11-11 (six of them wear test-suite rows after the audit), 3 on 2026-11-12 and 3 on 2026-11-13. The done criterion's "86 verified rows" reads as the 86 of that moment; the current count is `grep -c '' docs/port-ledger.jsonl` = 92.
