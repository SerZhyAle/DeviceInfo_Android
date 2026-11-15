# S0023_unified-ui-conformance-evidence

**Status:** BlockNeedUserTest
**Status note:** Device run needed: install phone-store-debug.apk, phone-restricted-debug.apk and wear-debug.apk (built 2026-11-14) on a phone or emulator and a watch or emulator and run the S0023 lines of the S0007 checklist for E1, E2 and E3; build compiled, wear suite 54/0, phone 1 known-red battery test (S0037).
**Created:** 2026-11-13
**Complexity:** medium - assessed 2026-11-14: phone and watch presentation, localized resources, a watch preference store, fast resource checks, catalog exceptions and a device matrix; no wire or shared-contract shape change.

## 0. Owner request (verbatim)

Owner's positions and order, 2026-11-13, verbatim (chat, Russian):

Positions:
"Так.
Идея этого приложения была чтобы весь функционал по суб-программы Device Infoна телефоне (любом андроид устройстве), часах , который реализован в FMS_A был представлен в виде самостоятельных приложений android,  которые могут заинтересовать пользователя, которому не интересен весь остальной функционал FMS_A
Но при этом эти приложения не только выглядят более-менее одинаково, но и развиваются вместеи новый/исправленный функционал обновляется/исправляется в них паралельно, они пересекаются по документации, принадлежат общему семейству программ и связаны канонами и контрактами.
Исследуй всё ли верно в моих мположениях?"

Order:
"Создай такие спецификации в рамках этого продукта, которые приведут его к вышеописанному заказанному состоянию"

Correction order, 2026-11-13, verbatim (chat, Russian), given after these tickets were captured:
"правильно ли я понял, что по производству всех заказаных задач
это приложение будет иметь весь функционал по соответствующей суб-программы телефона (любом андроид устройстве), часах , который реализован в FMS_A был представлен в виде самостоятельных приложений android,  которые могут заинтересовать пользователя, которому не интересен весь остальной функционал FMS_A
Но при этом эти приложения будут выглядеть более-менее одинаково, развиваться вместе и новый/исправленный функционал обновляется/исправляется в них паралельно, они пересекаются по документации, принадлежат общему семейству программ и связаны канонами и контрактами.
Поправь спецификации чтобы было именно так"

Further order, 2026-11-13, verbatim (chat, Russian), given after the correction of these specs:
"если тут какие то несогласия - предложи изменения к межпроектному контракту"

Carried out by five proposals filed in the shared contracts catalog the same day (the file names are in the done criteria of ticket register-product-in-contract-catalog, S0025): the Wear OS app surface in CONTEXT-HELP, the Wear OS profile in UI-SIZING, BUTTONS and COLLAPSIBLE-GROUP, and the place of the derived apps in FUNCTION-PARITY. Other projects had filed related proposals the same day (the watch scope question, the port ledger, the family function register); these specs are aligned to them rather than competing with them. Until the owners of those contracts decide, the sealed text applies.
This ticket's problem and done criteria (sections 1 and 2) were written from that message. The acceptance of the whole set is ticket target-state-acceptance (S0027).

Twelve tickets were captured by the two orders: bugfix-contract-pointers-stale (S0016), payload-parity-test (S0017), upstream-new-file-inventory-check (S0018), reverse-port-divergence-ledger (S0019), ship-together-surfaces-manifest (S0020), phone-wear-feature-parity-matrix (S0021), phone-wear-visual-identity (S0022), unified-ui-conformance-evidence (S0023), in-app-help-phone-and-wear (S0024), register-product-in-contract-catalog (S0025), canon-resync-stamp (S0026), target-state-acceptance (S0027).

Agent findings below are not the owner's words. They come from the investigation of 2026-11-13; every fact cites the file it was read from.

Position this ticket serves: "связаны канонами и контрактами" and "выглядят более-менее одинаково" - the declared UI contracts have to be met and shown to be met.

Problem: docs/contracts/UNIFIED-UI.md and INPUT-PARITY.md declare the product a consumer of UI-SIZING, BUTTONS, COLLAPSIBLE-GROUP and INPUT-PARITY on phone and watch, but no conformance evidence is recorded and the watch side shows no sign of it in code.

Evidence (read 2026-11-13):
- docs/contracts/INPUT-PARITY.md: "Every interactive surface support touch, keyboard, D-pad and mouse inputs .. on phone and on watch" and "all actions in the toolbar and list rows are reachable by touch, D-pad navigation, keyboard focus, and mouse clicks".
- Wear: the only mention of the touch-target rule in wear/src/main is a comment (ui/common/WearSettingsItem.kt line 8). A search for onKeyEvent, onPreviewKeyEvent, focusable, rotary and D-pad in wear/src/main found nothing. Compose for Wear lists may give rotary scrolling by default; that is to be verified, not assumed.
- Phone: a focus ring exists (focus_button_background, focus_button_stroke) and the search view takes focus; no recorded walk-through of toolbar and rows by keyboard and D-pad.
- The catalog contracts define what counts as evidence: BUTTONS asks that captures identify the contract version, build, platform, theme, scale, locale and scenario; the other pages have their own conformance sections. The pointer versions are being corrected by ticket bugfix-contract-pointers-stale, so this ticket works against the current versions.

Wanted:
1. For each contract and each package, a short conformance table: rule, how it is met, evidence (code reference, test, capture).
2. The gaps the table shows, fixed or recorded as exceptions in the catalog's form (a dated exception, never silent): wear touch targets, wear keyboard / D-pad / rotary reachability, button geometry and focus on both, group header behavior on both.
3. The cheap static tests that the contracts allow (for example dimension minimums read from resources), added to the unit suites.
4. The device and emulator scenarios listed as open manual checks (CLAUDE.md section 2 rule 4) and handed to S0007's checklist, not claimed.

Compiled-not-tested applies until the release tier runs.


## 1. Problem

The product states that it follows the shared rules for touch sizes, buttons, collapsible groups and input methods on the phone and on the watch, but nothing shows it, and on the watch nothing in the code suggests it. "Связаны контрактами" needs evidence, not a declaration.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- For each of UI-SIZING, BUTTONS, COLLAPSIBLE-GROUP and INPUT-PARITY and for each package a conformance table exists (rule, how it is met, evidence: code reference, test or capture), against the versions read in the catalog that day.
- Every gap is fixed or recorded as a dated exception in the catalog's form; none is silent.
- The static checks the contracts allow are tests in the unit suites; their commands and times are recorded; anything above 5 seconds is a RELEASE item.
- Device and emulator scenarios are open manual checks in S0007's list, not passes: on the phone touch, hardware keyboard, D-pad, mouse and enlarged text; on the watch touch, the rotary crown where the watch has one (INPUT-PARITY 0.6, amendment items I and J) and enlarged text. The pointer's promise of keyboard, D-pad and mouse on the watch goes beyond the contract and is corrected by ticket bugfix-contract-pointers-stale.
- The Wear OS readings the contracts leave open (the toolkit's pill-shaped chips against BUTTONS section 3 rule 2, UI-SIZING section 2 rule 5; the group header on a round display) are put to the catalog by the proposals of 2026-11-13 in the ui-sizing, buttons and collapsible-group folders (and by the scope question of Filler Android filed in the ui-sizing folder the same day, which asks whether these contracts bind a watch at all). Until the owners decide, the sealed text applies: the product records the watch's chips and group headers in its own size profile as a permanent-variant candidate with a review condition, follows the catalog's decision when it lands, and measures the CompactChip uses (SystemInfoScreen.kt) against the 48 by 48 baseline.

## 3. Approach

### 3.1 Scope

Source implementation and evidence (2026-11-14):

- `docs/UI_CONFORMANCE.md` holds the size profile, the approved Wear toolkit variant and a rule/evidence
  table for each of the four current contracts on each package. It names known deviations E1-E4 and the
  distinction between source observations, unrun JUnit tests and required device evidence.
- On the phone the section-copy target is 48 dp wide, a sibling of the disclosure target; group triangles
  show the current state in LTR and RTL, long titles wrap, and the accessibility state is localized. Ctrl+F
  focuses report search and Ctrl+S invokes the toolbar's save path; shortcut hints use all three locales.
- On the watch custom disclosure and information rows use a 48 dp minimum, group headings have a state
  triangle and accessible state, and expansion choices are saved by screen and resource entry name. A
  hierarchy focus coordinator supplies the focus context for Wear Compose 1.4.1's built-in rotary handler.
  The two `CompactChip` uses are recorded from the toolkit source, with actual target measurements open.
- Both module unit suites contain resource checks. The watch suite additionally contains a Robolectric
  persistence/isolation test and a `CompactChipHeight` assertion; these tests are RELEASE items. The
  standalone Java forms provide fast resource checks. `PLAN/S0007_parity-and-device-check.md` holds the
  unrun device matrix, including touch, keyboard, D-pad, mouse, rotary, enlarged text and captures.
- E1-E4 are dated exceptions in the catalog registry section 3, until 2026-12-31. E1-E3 remain this
  ticket's migration work; E4's help implementation belongs to S0024. An exception is not conformance.
  Reverse-port candidates RP-0003 and RP-0004 remain open locally until the owner orders FMS_A capture.

No build, emulator, physical device, measured click bounds or screenshot was used in this pass.

Second pass, 2026-11-14 (unattended; E2 and E3 changed in source, E1 not started):

- **Scope statement (CLAUDE.md section 4, S0021), against `docs/PARITY_MATRIX.md` row PM-038 (collapsible
  sections, offered on both sides; the row is unchanged because the function is unchanged on both):**
  - E3 viewport memory and the activated-header anchor: phone and wear, because both have collapsible groups.
  - E3 content-sized packing: phone only; the watch already flowed collapsed headings at their own widths.
  - E3 search disclosure: phone only; the watch has no search.
  - E2 action buttons: wear only; the phone's actions are toolbar items drawn by the toolkit app bar, not chips.
- E2: `WearActionButton` (new) replaces the two toolkit `CompactChip` calls; the actions sit in one wrapping flow
  with the send outcome text below (`SystemInfoScreen.ActionButtons`). `WearUiSizingResourcesTest` no longer asserts
  the toolkit chip height.
- E3 phone: `SystemInfoHeaderPacking` and a one-span-per-dp grid in `SystemInfoWindowManager` with the header's
  natural width measured by `SystemInfoAdapter.collapsedHeaderCellWidthPx`; header activation during search closes or
  reopens that group for the search only; the activated header is restored to its previous height after the
  list is committed; `SystemInfoViewportStore` plus `SystemInfoActivity.onPause` remember the viewport as item identity
  plus offset and restore it once.
- E3 wear: list rows carry stable keys (`WearSettingsItem.keys`), `WearViewportStore` remembers the center row key
  plus offset, `SystemInfoScreen` restores it once the report is loaded and re-centres the activated header's row.
- The two S0023 disclosure probes were deleted: the ticket is `Partial`, and a ticket-id probe exists only while a
  ticket is in `BlockNeedUserTest`. They are inserted again when the ticket enters that status.
- Local divergence: the five edited ported files are classified `candidate` under the new notice RP-0005 in
  `docs/reverse-port-notices.jsonl` (state open; the owner orders any FMS_A capture).
- E1 is not started; the reason and the recommended design are under Assumed below.

Third pass, 2026-11-14 (unattended; no source, resource or string edited):

- Re-read the ticket, `docs/UI_CONFORMANCE.md`, the catalog registry rows for UI-SIZING, BUTTONS, COLLAPSIBLE-GROUP and
  INPUT-PARITY and the exception E1 entry (registry section 3), and UI-SIZING 1.2 sections 2, 3 and 6. Nothing moved:
  the contract is still 1.2, the exception still reads "implement and measure the shared range and profile changes, or
  explicitly renew this entry with fresh evidence", deadline 2026-12-31, and no renewal is due before that date.
- Five done criteria read against the record: the conformance tables exist (`docs/UI_CONFORMANCE.md`), every gap is
  fixed in source or a dated exception (E1-E4, none silent), the static checks are in the unit suites with their
  commands and times, the device scenarios are open lines in S0007, and the Wear OS readings are recorded as the
  permanent variant. What remains is E1 and everything that needs a compiler or a device.
- E1 was not built in this pass. Reasons, all new facts of this pass: the repository declares no compile command and the
  session has no `adb` and no attached device, so a scale mechanism cannot be checked; E1 edits exactly the files the
  second pass already changed unseen by a compiler (`SystemInfoActivity`, `SystemInfoWindowManager`, wear
  `SystemInfoScreen`), so building it now would stack a second blind layer on the first; and it is a new user-visible
  control on two packages, which by the ship-together rules drags a help-map row and page source in three locales, a
  parity-matrix row, string keys in six resource files and a glyph for the phone overflow item beside the
  ICON-RENDER sibling-set gap already parked as S0035 - about two dozen files whose only check would be `check-*`
  scripts that read declarations, not behavior. The earlier pass's deferral therefore stands.
- The ticket cannot move unattended from here, so it leaves `Partial` for `BlockQuestions` with one owner action
  (section 3.3 and the question block below): the release-tier compile and test run plus the S0007 E2/E3 device lines.
  The status is not `BlockNeedUserTest`: E1 is unbuilt, so the entry precondition (the headline behavior works end to
  end, no open work of this ticket's own) does not hold.

Fourth pass, 2026-11-14 (unattended; the owner delegated the run to this pass: "выполнить всё необходимое в рамках
этого тикета", see `### Quiz decisions (2026-11-14)`; first the release-tier run, then E1 on the compiled base):

- **Release-tier verdict, under the Build lock.** The committed tree did not compile: `.\gradlew.bat :phone:assembleDebug
  :wear:assembleDebug --continue` failed with three groups of errors that were already in HEAD and belong to no S0023
  change - `kotlinx.coroutines.tasks.await` unresolved in three files (no `kotlinx-coroutines-play-services`),
  `androidx.compose.material.icons` unresolved in wear `SystemInfoScreen` (no `material-icons-core`), and `@color/white` and
  `@color/black` missing for 20 phone vector drawables. They were fixed in this pass by the minimum that lets the tree build
  (two catalog entries, three dependency lines, two colors; see Assumed) and the build then passed: `BUILD SUCCESSFUL in 1m 7s`,
  so the E2 and E3 source of the second pass met a compiler for the first time. The documented test command
  `:phone:testDebugUnitTest` is refused by Gradle (ambiguous because of the flavors); the working form is
  `:phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest`.
- **Unit suites, after E1:** wear 54 tests, 0 failures (`WearViewportStoreTest`, `WearUiSizingResourcesTest` and the new
  `WearInterfaceScaleTest` among them); phone store 88 tests and restricted 92 tests, one failure each, the same test:
  `GatherSystemInfoUseCaseTest > invoke contains localized battery detail field headers`. It is red since the initial import
  (no sticky battery broadcast under Robolectric), is not a conformance test and is parked as S0037. The new phone
  `SystemInfoHeaderPackingTest`, `PhoneUiSizingResourcesTest` and `InterfaceScaleTest` pass.
- **E1 built (scope: phone and wear, both, PM-042 in `docs/PARITY_MATRIX.md`).** One interface scale of 100, 115, 130 and
  150 percent on each side, no compact step, an unsupported value reads as 100 percent, the system font scale untouched.
  Phone: `InterfaceScale` (steps, fallback, density arithmetic, store, `wrap` applied from `attachBaseContext` of
  `SystemInfoActivity` and `HelpActivity`) and `InterfaceScalePicker` (radio list from the overflow menu item
  `action_system_info_interface_size`, re-creates the screen). Watch: `WearInterfaceScale`, `WearInterfaceScaleStore` and
  `WearInterfaceScaleScope` (density, configuration and resources provided together around the theme in `MainActivity`),
  a text button at the end of the list (`WearActionButton` with an optional icon) that steps to the next size. Strings in
  three locales on both modules, help pages (element `interface-size` on both pages and a `none` row for the dialog in the
  help map), parity-matrix row, CHANGELOG bullet, Play listing bullets and landing copy deck in en, ru and uk, S0007
  checklist line, `docs/UI_CONFORMANCE.md`, reverse-port notice RP-0006 (open) and the four classifications.
- Parked: S0037 (the red battery test) and S0038 (declare a compile-only command and correct the phone test command in
  CLAUDE.md section 6, which this pass did not edit).
- Not done, and why: no device or emulator was used. `adb devices` lists nothing; Android Virtual Devices exist on the
  machine, but starting one is a long-running background process, which a headless pass does not start. The S0023 lines of
  the S0007 checklist, including the new E1 line, therefore stay open manual checks, and E1, E2 and E3 stay open
  exceptions in the catalog registry (its rows quote the earlier source and are refreshed at the review after the device
  run). The release variant, `bundleRelease`, was not built (it needs the upload key).
- The six `S0023:` probes are inserted again because the ticket enters `BlockNeedUserTest` (the last code edits before the
  final build): phone `InterfaceScale.wrap`, `InterfaceScalePicker.show`, `SystemInfoViewportStore.load`; wear
  `WearInterfaceScaleStore.select`, `WearActionButton` click and `WearViewportStore.load`. None is in a ported file, so
  no divergence classification changed by them.

### Assumed (unattended, 2026-11-14)

- **E2 draws its own button instead of using the toolkit `Chip`.** Taken because the toolkit `Chip` label container
  may fill the available width, which would leave the actions in separate rows exactly as before, and the source
  cannot be run here to check. Alternative: `Chip` with a wrapping label. A product-drawn rectangular button also
  matches UI-SIZING 1.2 section 2 rule 5 (modest corners, not pills) and the product-drawn group header. Owner may
  overrule; the cost is a different look from the other Wear toolkit controls, to be judged on the S0007 captures.
- **E3 packing uses a fine span grid on the existing `GridLayoutManager`.** Alternative: add a flexbox layout
  library or write a layout manager. Taken because it adds no dependency to the build or to the third-party notices
  and keeps the change local. Owner may overrule if the rendered result needs exact content width.
- **E3 on the watch brings the activated header's row to the middle of the list** instead of preserving its previous
  height, because the list's center-relative offsets cannot be stated without a device. Owner may overrule after
  the S0007 focus and scroll walk.
- **E1 is deferred to a device-checked design, not asked.** Recommended design, not built: one interface scale with
  steps 100, 115, 130 and 150 percent and no compact step (UI-SIZING 1.2 section 2 rule 4 requires an owner-declared
  floor before a product exposes compact mode), a single supported touch profile so no profile switch is offered,
  applied on the phone as a per-app density override and on the watch as a density provider around the theme, with a
  picker and a stored choice on both. Alternative: renew E1 with fresh evidence until the contract's reading of
  platform display size is decided. Owner may overrule either way.
- **E1 stays deferred in the third pass, and is sequenced after a compile (2026-11-14).** Taken: build E1 only on top
  of source a compiler has seen, so the owner action in section 3.3 comes first. Alternative: build E1 now, blind, in
  one pass with its help pages, strings, matrix row and menu glyph. Owner may overrule: answer the quiz with "build E1
  now" and the next pass builds it, at the cost of one more unrun layer over the E2 and E3 files.

### Assumed (unattended, 2026-11-14, fourth pass)

- **The three pre-existing build blockers are fixed here, not only parked.** Taken because the owner delegated the
  release-tier verdict of this ticket and a tree that does not compile gives none. Alternative: park all three and stop
  with a red build. Owner may overrule; the cost is reverting five lines (`gradle/libs.versions.toml`, the two module
  `build.gradle.kts` files, phone `values/colors.xml`). The values follow the upstream FastMediaSorter: the coroutines
  library at the already pinned `kotlinx-coroutines` 1.7.3, `material-icons-core` managed by the Compose BOM, `black`
  and `white` as `#FF000000` and `#FFFFFFFF`. `THIRD-PARTY-NOTICES.txt` is unchanged, because it already names
  kotlinx.coroutines and Jetpack Compose for both packages and the pair stays byte-identical.
- **The watch scale provides density, configuration and resources together.** Alternative: `LocalDensity` only.
  Rejected because `dimensionResource` reads pixels from the unscaled resources and divides by the scaled density, so the
  48 dp targets would not grow and would stay 48 real dp. Owner may overrule after the S0007 round-display walk.
- **The watch choice is a button that steps through the sizes** (100, 115, 130, 150, back to 100), the phone choice a
  radio dialog. Alternative: a list on the watch as well. Taken because the watch has no menu, a list needs a second
  screen, and one 48 dp button keeps the Help row and the viewport keys where they were. Owner may overrule.
- **The interface scale also scales text** (the density multiplies dp and sp), with the system font scale applied on top.
  That is UI-SIZING 1.2 section 2 rule 3 (typography scales with the interface scale; text-only enlargement stays
  independent). Alternative: scale only dp. Rejected as it would break the coherence the rule asks for.
- **E1's catalog registry row is not rewritten in this pass.** An unrun source change retires no exception; the row is
  refreshed at the review after the S0007 device run. Owner may overrule.

### 3.2 Open questions

- Profile range (E1): built in source in the fourth pass, compiled and unit-tested, not run on a device; Carrier: S0007.
- Device interaction for the E2 and E3 source changes (header widths and wrapping, search toggle, anchor, restored
  viewport, button growth under enlarged text): Carrier: S0007.
- In-app help via F1 and the toolbar: Carrier: S0024. S0023 rechecks input equivalence.
- Device interaction, action-button target measurements, font scaling, contrast and screenshots: Carrier:
  S0007. The Wear contract amendments are already accepted in UI-SIZING 1.2, BUTTONS 2.2 and
  COLLAPSIBLE-GROUP 1.2; the documented toolkit shape is a permanent variant, not a pending proposal.

### 3.3 Owner inputs (Approval gate)

- **DO:** under the Build lock run `.\gradlew.bat :phone:testDebugUnitTest :wear:testDebugUnitTest :phone:assembleDebug :wear:assembleDebug`
  from the repository root and write the verdict (and any failing test or compile error) into this ticket; then install
  both debug builds on an emulator or device and run the S0023 lines of the S0007 checklist for the E2 and E3 source
  changes (wear action buttons; phone header packing, search disclosure and viewport restore; wear viewport restore).
  The second-pass source and its two new unit tests have never met a compiler, and E1 edits the same files.
- **Owner answer (DO, 2026-11-14):** "выполнить всё необходимое в рамках этого тикета" - the run is delegated to the
  pass that works this ticket; no verdict exists yet (see `### Quiz decisions (2026-11-14)`).
- **Carried out 2026-11-14 (fourth pass):** the build and unit-suite half of the DO above, with the corrected task names;
  verdict in section 4. **Still open, now the owner's test of this ticket:** install the three debug APKs
  (`phone/build/outputs/apk/store/debug/phone-store-debug.apk`, `phone/build/outputs/apk/restricted/debug/phone-restricted-debug.apk`,
  `wear/build/outputs/apk/debug/wear-debug.apk`) on a phone or emulator and a watch or emulator and run the S0023 lines of
  `PLAN/S0007_parity-and-device-check.md` (E1, E2 and E3); a line that cannot run stays open, never a pass.
- **Related tickets:** none

### Questions (v1, 2026-11-14) - answered 2026-11-14

- DO: under the Build lock run `.\gradlew.bat :phone:testDebugUnitTest :wear:testDebugUnitTest :phone:assembleDebug :wear:assembleDebug` from the repository root, record the verdict in S0023, then run the S0023 lines of the S0007 checklist for E2 and E3 on an emulator or device.

### Quiz decisions (2026-11-14)

- DO: release-tier build, unit suites and the S0007 E2/E3 device lines -> the owner delegated the run to this ticket's
  own pass, in their words: "выполнить всё необходимое в рамках этого тикета" (the owner chose none of the four
  offered results - not run / build green / all passed / errors - and typed this instead; so there is no verdict,
  no output and no device observation to record, and none is invented; the fourth pass later ran the build and the suites,
  see section 4). Reading of the answer, the agent's and not the
  owner's: the next pass of this ticket runs `.\gradlew.bat :phone:testDebugUnitTest :wear:testDebugUnitTest
  :phone:assembleDebug :wear:assembleDebug` under the Build lock (the owner names the release-tier run for this
  ticket by this answer), records the verdict here, then does the E2/E3 device lines as far as an emulator or
  device is available (a line that cannot run stays an open S0007 check, never a pass), and builds E1 on the
  compiled base as the third-pass assumption sequences it. If the owner meant less (for example the build only),
  the correction is one line to the next pass.
- Not raised in this sitting (no `--assumed`): the `### Assumed (unattended, 2026-11-14)` entries stand unchanged.

## 4. Implementation and verification record

- Phone target and header resources: `java phone/src/test/java/com/sza/deviceinfo/ui/PhoneUiSizingResources.java`
  exited 0 with `Phone UI sizing resources: OK` (0.79 s). Wear target declaration:
  `java wear/src/test/java/com/sza/deviceinfo/wear/ui/WearUiSizingResources.java` exited 0 with
  `Wear UI sizing resource: OK` (0.73 s). A throw-away negative-control run changed each target to 40 dp:
  each source check exited 1 with its target-specific error; the driver exited 0 (1.03 s).
- `pwsh -NoProfile -File tools/docs/check-surfaces.ps1` exited 0: phone 219 translated keys and watch 86,
  with one non-translatable key per module; all en/ru/uk keys and declared permission surfaces agree.
  `pwsh -NoProfile -File tools/site/render-landing.ps1 -Check` exited 0, three pages current.
- `pwsh -NoProfile -File tools/contracts/check-pointers.ps1` exited 0, six checked and one local declaration
  skipped. The three UI versions and INPUT-PARITY version match the tables in `docs/UI_CONFORMANCE.md`.
- The local-divergence gate first exited 1 for the changed phone menu; it was added to RP-0004 and classified
  by its current hash. A subsequent run is recorded in the audit below.
- The canon compliance gate exited 0 with zero errors and two warnings: the canon adoption stamp and an
  archived catalog-path reference. The stamp has its own carrier S0026. Neither warning establishes UI proof.
- RELEASE: under the Build lock run `.\gradlew.bat :phone:testDebugUnitTest :wear:testDebugUnitTest` and
  `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug`; run the S0007 device matrix with recorded
  bounds and screenshots. The new Kotlin, resources and Gradle changes have not been compiled or tested.
- Second pass, 2026-11-14: files added `wear/.../ui/common/WearActionButton.kt`, `WearViewportStore.kt`,
  `phone/.../ui/systeminfo/helpers/SystemInfoHeaderPacking.kt`, `SystemInfoViewportStore.kt` and the two unit tests
  `SystemInfoHeaderPackingTest` and `WearViewportStoreTest`; edited `SystemInfoWindowManager`, `SystemInfoAdapter`,
  `SystemInfoActivity`, wear `SystemInfoScreen`, `WearSettingsItem`, `WearUiSizingResourcesTest`, the two probe sites
  and `docs/UI_CONFORMANCE.md`; added RP-0005 to `docs/reverse-port-notices.jsonl` and updated the S0007 checklist
  lines for the new behavior. Gate results are in the audit below.
- Documentation context (second pass): affected - `docs/UI_CONFORMANCE.md`, `CHANGELOG.md` (one `Changed` bullet,
  English source), the S0007 checklist, `docs/reverse-port-notices.jsonl`. Unchanged - the landing deck, the Play
  listing and the parity matrix: their only claim in this area, that the watch remembers which groups you leave open,
  stays true, and no phone or watch string, permission or metric changed (`check-surfaces` exit 0).
- Fourth pass, 2026-11-14 (release tier, owner-delegated; every Gradle run was started in the foreground from the repository
  root after taking the Build lock with `Enter-BuildLockOrExit` of the canon's `locks/agent-lock.ps1`; the verdict lines
  quoted here are the evidence, and each command below reproduces its result):
  - `:phone:assembleDebug :wear:assembleDebug --continue`, first run: exit 1 in 41 s with three groups of errors that were
    already in HEAD. After the five-line fix: exit 0, `BUILD SUCCESSFUL in 1m 7s`, 132 actionable tasks, three APKs
    written.
  - `:phone:testDebugUnitTest :wear:testDebugUnitTest`: refused by Gradle, the phone task is ambiguous because of the
    flavors. `:phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest --continue`, first run
    (before E1): exit 1, wear 47 tests 0 failures, phone 80 tests 1 failure and 84 tests 1 failure (the battery test).
  - E1 compile and its two new classes, filtered: exit 0 in 13 s; phone `InterfaceScaleTest` 8 tests and wear
    `WearInterfaceScaleTest` 7 tests, 0 failures.
  - Final run, after the probes: `:phone:assembleDebug :wear:assembleDebug :phone:testStoreDebugUnitTest
    :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest --continue`: no `e:` line, three APKs
    written at 12:40 and 12:41, wear 54 tests 0 failures, phone store 88 tests 1 failure, phone restricted 92 tests 1
    failure; `BUILD FAILED in 38s` for the one red test only, `GatherSystemInfoUseCaseTest` battery headers (S0037).
  - Fast gates after the edits, all exit 0: `render-help.ps1` (22 files written) and `-Check` (22 current),
    `check-help-map.ps1` (8 surfaces, 2 help pages, 18 page files), `check-surfaces.ps1` (phone 225 keys, wear 90 keys, en/ru/uk
    equal), `check-matrix.ps1` (42 rows), `check-tokens.ps1 -SkipCatalog` (123 checks), `render-landing.ps1 -Check` (3 of 3
    current), `check-docs.ps1` (30 records, 86 corpus files), `check-local-divergence.ps1 -RequireClassified` (nine local
    edits, none unclassified), `spec_catalog/validate` (10 OK) and `release-queue -Validate` (38 tickets, no drift).
    `check-help-captures.ps1` reads `NOT HELD`, as before: no capture record exists, so rung 2 is not claimed.
- Documentation context (fourth pass): affected and updated - `docs/UI_CONFORMANCE.md`, `docs/PARITY_MATRIX.md` (PM-042 and
  the S0023 scope note), `CHANGELOG.md`, `docs/play/PLAY_LISTING.md` (en, ru, uk), the landing copy deck (en, ru, uk) and its
  three renders, the help sources, the help map and the rendered pages, `docs/reverse-port-notices.jsonl` (RP-0006), the S0007
  checklist. Unchanged: README (it names no setting of this kind), the privacy pages, the security inventory and the Data
  safety answers (no permission, data flow or permission string changed), `THIRD-PARTY-NOTICES.txt`. CLAUDE.md section 6 names
  a phone test task that Gradle refuses; its correction belongs to S0038 and is not edited here.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14

## Last Audit

**Date:** 2026-11-14 12:50 | **Mode:** static | **Outcome:** Partial
**Counts:** PASS 18 | WARN 1 | FAIL 0 | MANUAL 3 | UNCHECKABLE 1 | EXEMPT 0 | RELEASE 2

Fourth pass. The release-tier run the owner delegated was carried out: the tree builds, the unit suites pass except one
test that is not this ticket's, E1 is built, and the ticket moves to `BlockNeedUserTest` because every remaining check
needs a device. Expected | actual for each claim below is in section 4.

PASS: (1) conformance tables exist for the four contracts on both packages (`docs/UI_CONFORMANCE.md`); (2) every gap is
fixed in source or a dated exception, E1-E4, none silent; (3) the static checks are in the unit suites with their commands
and times; (4) the device scenarios are open lines in S0007, E1 line added; (5) the Wear OS readings are recorded as the
permanent variant; (6) `assembleDebug` of phone store, phone restricted and wear exits 0 after the fix; (7) wear suite 54
tests, 0 failures; (8) phone `SystemInfoHeaderPackingTest`, `PhoneUiSizingResourcesTest`, `InterfaceScaleTest` pass;
(9) wear `WearViewportStoreTest`, `WearUiSizingResourcesTest`, `WearInterfaceScaleTest` pass; (10) probe invariant: six
`S0023:` probes in non-ported files, ticket in `BlockNeedUserTest`; (11) local divergence gate; (12) string and permission
parity; (13) help map and rendered pages; (14) parity matrix; (15) design tokens; (16) landing renders current; (17) internal
documentation gate; (18) catalog validate and release queue.

### Action items
1. WARN - `phone/src/test/kotlin/com/sza/deviceinfo/domain/usecase/GatherSystemInfoUseCaseTest.kt:104` - the battery header test
   is red in both phone flavors since the initial import (no sticky battery broadcast under Robolectric). Not this ticket's;
   parked as S0037. Named here so it cannot mask a regression.

### Manual / on-target
- [ ] S0007, S0023 phone UI contracts and Wear OS UI contracts lines: touch, hardware keyboard, D-pad, mouse, rotary crown,
  enlarged text, header packing and wrapping, search disclosure, activated-header anchor, viewport restore, action-button
  bounds. Passing means the observation is recorded with device, build, locale, font scale and measured bounds.
- [ ] S0007, S0023 interface size (E1) line: the four sizes on both devices, targets grow and never shrink, the phone
  override survives AppCompat re-creation, the watch stays coherent on a round display at 150 percent, the choice survives a
  restart and the system font scale still applies on top.
- [ ] After the device run: refresh the catalog registry rows for E1, E2 and E3, whose evidence still describes the earlier
  source, and decide each exception on the recorded bounds.

UNCHECKABLE: rendered geometry, contrast and round-display layout at 150 percent have no mechanical check at this rung.

RELEASE: `.\gradlew.bat :phone:bundleRelease :wear:bundleRelease` with the pin of `docs/RELEASE.md` (needs the upload key);
the device run of `tools/help/capture-help.ps1` (`docs/RELEASE.md` step 3a). The probes are deleted when the ticket leaves
`BlockNeedUserTest`: `grep -rn "S0023:" phone/src wear/src` must then find none.
