# S0004 - Port phone UI and presentation layer

**Ticket:** S0004
**Status:** BlockNeedUserTest
**Status note:** Waiting for on-device / emulator verification of SystemInfoActivity: report rendering, section expansion, search filtering, copy/share actions, D-pad/keyboard navigation.
**Priority:** 60
**Tier:** 3 - Moderate
**Complexity:** medium - assessed at spec pass: presentation layer port (13 Kotlin files, 7 XML layouts/views, 33 drawables, strings in EN/RU/UK, 1 unit test suite), Hilt activity entry point, ViewBinding integration; algorithmic complexity is low, but view layer coordination, input parity and edge-to-edge layout requirements require thorough verification. Read against the plan: the level stands.
**Depends on:** S0003

## Goal

Port the phone presentation layer (`SystemInfoActivity`, adapters, helpers, layouts, and string resources) from FastMediaSorter into the standalone project to provide a rich, responsive standalone device information interface with full parity.

## Scope and acceptance

- Port `SystemInfoActivity`, `SystemInfoAdapter`, `SystemInfoDialogManager`, and `SystemInfoWindowManager` to the `phone/` module.
- Port supporting state persistence and DI: `SystemInfoGroupStateRepository`, `SystemInfoGroupStateRepositoryImpl`, `CollapsibleSectionStore`, `SystemInfoModule`.
- Port UI components: `CollapsibleSectionHeader`, `StandardToolbar`, list models, group icons, view extension helpers.
- Port corresponding layouts (with portrait and landscape parity per Rule 11) and string resources in EN/RU/UK.
- Ensure all interactive surfaces support touch, keyboard, D-pad and mouse inputs per the INPUT-PARITY standard.
- Register `SystemInfoActivity` in `AndroidManifest.xml` and wire `MainActivity` to launch it.
- Port `SystemInfoExpansionStateTest` to verify remembered group state and icon coverage.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0003 domain port (Verified); S0005 follows (wear app and Data Layer).
- **Parity inventory:** The full upstream presentation set (`ui/systeminfo/**`, `SystemInfoGroupStateRepository`, `SystemInfoModule`, layouts, drawables, strings, tests) ported from `P:\ANDROID\FastMediaSorter_mob_v2` with rows in `docs/port-ledger.jsonl`.
- **Navigation and entry point:** `MainActivity` launches `SystemInfoActivity` so the standalone app presents device information on start; `SystemInfoActivity` is also registered in `phone/src/main/AndroidManifest.xml`.
- **Shared contracts:** Pointers `INPUT-PARITY`, `IN-APP-HELP`, and `UNIFIED-UI` declared in `docs/contracts/` per CLAUDE.md section 5.
- **Locales:** EN, RU, and UK per LOCALIZATION rule 1; localized string resources for presentation, action, toast, and search strings.

## Spec pass (2026-11-11)

- **Rung:** complex pipeline. Forced upward by the primitive test: far more than three files, new public types, new layouts in portrait and landscape, new DI wiring, ViewBinding setup.
- **Entry state:** Blocker S0003 is Verified (journal, 2026-11-10 23:02), clearing `BlockByOtherTask` to `Draft`. The lease is held by this session under reason `run-spec-queue pq2`.
- **Fresh upstream inventory** (CLAUDE.md section 2, rule 2; read 2026-11-11 from `P:\ANDROID\FastMediaSorter_mob_v2`, read-only). Disposition of classes for presentation path:

| Upstream (app_v2) | Disposition |
| --- | --- |
| `ui/systeminfo/SystemInfoActivity.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/SystemInfoActivity.kt`. Replaced `ColorThemePrefs` and `LocaleHelper` with standard Android/Material3 theme and locale support. |
| `ui/systeminfo/adapter/SystemInfoAdapter.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/adapter/SystemInfoAdapter.kt`. |
| `ui/systeminfo/helpers/SystemInfoDialogManager.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/helpers/SystemInfoDialogManager.kt`. Simplified camera app view since DeviceInfo has no camera capture screen. |
| `ui/systeminfo/helpers/SystemInfoExpansionState.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/helpers/SystemInfoExpansionState.kt`. |
| `ui/systeminfo/helpers/SystemInfoGroupIcons.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/helpers/SystemInfoGroupIcons.kt`. |
| `ui/systeminfo/helpers/SystemInfoWindowManager.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/helpers/SystemInfoWindowManager.kt`. |
| `ui/systeminfo/model/SystemInfoListItem.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/model/SystemInfoListItem.kt`. |
| `domain/repository/SystemInfoGroupStateRepository.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/domain/repository/SystemInfoGroupStateRepository.kt`. |
| `data/repository/SystemInfoGroupStateRepositoryImpl.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/data/repository/SystemInfoGroupStateRepositoryImpl.kt`. |
| `data/local/preferences/CollapsibleSectionStore.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/data/local/preferences/CollapsibleSectionStore.kt`. |
| `core/di/SystemInfoModule.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/di/SystemInfoModule.kt`. Provides `@IoDispatcher` and binds `SystemInfoGroupStateRepository`. |
| `ui/common/widget/StandardToolbar.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/ui/common/widget/StandardToolbar.kt`. |
| `ui/common/widget/CollapsibleSectionHeader.kt` | Ported to `phone/src/main/kotlin/com/sza/deviceinfo/ui/common/widget/CollapsibleSectionHeader.kt` (clean, self-contained implementation). |
| `src/test/.../ui/systeminfo/helpers/SystemInfoExpansionStateTest.kt` | Ported to `phone/src/test/kotlin/com/sza/deviceinfo/ui/systeminfo/helpers/SystemInfoExpansionStateTest.kt`. |
| Layouts: `activity_system_info.xml`, `item_system_info_field.xml`, `item_system_info_empty.xml` (portrait & landscape) | Ported to `phone/src/main/res/layout/` and `layout-land/`. |
| View header: `view_collapsible_section_header.xml` | Ported to `phone/src/main/res/layout/`. |
| Menu: `menu_system_info.xml` | Ported to `phone/src/main/res/menu/`. |
| Drawables: 33 vector/selector drawables | Ported to `phone/src/main/res/drawable/`. |

- **Differences from upstream, each recorded next to the code it concerns:**
  1. `SystemInfoActivity`: Upstream calls `ColorThemePrefs.applyThemeOverlay(this)` and `LocaleHelper.applyLocale(newBase)`. DeviceInfo uses standard `Theme.DeviceInfo` and platform locale management; F1 key handler delegates to standard key handling until in-app help lands.
  2. `SystemInfoDialogManager`: `buildCameraAppView` is simplified; `GatherSystemInfoUseCase` takes no parameter in DeviceInfo (S0003 dropped `appCameraView`).
  3. `CollapsibleSectionHeader`: Self-contained widget without coupling to FastMediaSorter's settings framework or `HelpableRow`.
  4. Ukrainian text and house style applied to prose and localized strings.
- **Settled without asking:**
  1. ViewBinding enabled in `phone/build.gradle.kts`.
  2. DI wiring: `@IoDispatcher` qualifier provided in `SystemInfoModule`.
  3. Navigation: `MainActivity` forwards to `SystemInfoActivity` to present the ported report immediately on launch.
  4. Contract pointers: `INPUT-PARITY`, `IN-APP-HELP`, and `UNIFIED-UI` pointers added to `docs/contracts/`.
- **Contract boundary:** No format another product reads is mutated. Pointer documents added to document compliance.
- **Unattended pass:** No interactive questions; all decisions settled by architecture and precedent.

## Done criteria

1. `tools/port-ledger/check-drift.ps1` exits 0 against the real upstream with new ledger rows for all ported source and test files (32 rows total).
2. ViewBinding enabled in `phone/build.gradle.kts`.
3. String resources in `values`, `values-ru`, and `values-uk` contain all 103 required keys for `sysinfo_*`, search, actions, and toasts with matching sets.
4. Layout parity: `activity_system_info.xml`, `item_system_info_field.xml`, and `item_system_info_empty.xml` exist in both portrait (`layout/`) and landscape (`layout-land/`).
5. Unit tests: `SystemInfoExpansionStateTest` ported and passes icon and unique key invariants.
6. Contract pointers exist in `docs/contracts/` for `INPUT-PARITY`, `IN-APP-HELP`, and `UNIFIED-UI`.
7. `spec_catalog/validate` and `spec_catalog/release-queue -Validate` exit 0; compliance gate exits 0 with 0 errors.

## Plan

Coverage inventory:
- Goal (port presentation layer with parity) -> phases A through G.
- Scope bullet 1 (`SystemInfoActivity`, `SystemInfoAdapter`, `SystemInfoDialogManager`, `SystemInfoWindowManager`) -> phases C, D, E.
- Scope bullet 2 (state persistence & DI) -> phase B.
- Scope bullet 3 (UI components, headers, toolbars) -> phase C.
- Scope bullet 4 (layouts portrait/landscape & strings EN/RU/UK) -> phases A and D.
- Scope bullet 5 (interactive surfaces & input parity) -> phase C, D and contract pointer in G.
- Scope bullet 6 (manifest and main activity wiring) -> phase E.
- Scope bullet 7 (tests) -> phase F.

Produces/consumes:
- Phase A produces resources (drawables, dimens, strings, attrs, styles).
- Phase B consumes A and produces state repository, preferences store, and DI module.
- Phase C consumes A, B and produces custom widgets (`CollapsibleSectionHeader`, `StandardToolbar`) and helpers (`ClipboardCopy`, `ViewExtensions`, `PackageManagerCompat`).
- Phase D consumes A, C and produces layouts (portrait and landscape) and list models (`SystemInfoListItem`, `SystemInfoGroupIcons`, `SystemInfoExpansionState`).
- Phase E consumes B, C, D and produces `SystemInfoAdapter`, `SystemInfoDialogManager`, `SystemInfoWindowManager`, `SystemInfoActivity`, and manifest/MainActivity updates.
- Phase F consumes B, D, E and produces unit tests (`SystemInfoExpansionStateTest`).
- Phase G consumes all and produces contract pointers, port ledger records, and verification.

- [x] **A. Resources and Strings** - files: `phone/src/main/res/drawable/*.xml` (33 drawables), `phone/src/main/res/values/dimens.xml`, `attrs.xml`, `styles.xml`, strings in `values/strings_systeminfo.xml`, `values-ru/strings_systeminfo.xml`, `values-uk/strings_systeminfo.xml`. Check: all 33 drawables exist, string keys match across EN/RU/UK.
- [x] **B. State persistence and DI** - files: `CollapsibleSectionStore.kt`, `SystemInfoGroupStateRepository.kt`, `SystemInfoGroupStateRepositoryImpl.kt`, `SystemInfoModule.kt`. Enable `viewBinding = true` in `phone/build.gradle.kts`. Check: files exist, ledger recorded.
- [x] **C. Custom UI widgets and utility extensions** - files: `StandardToolbar.kt`, `CollapsibleSectionHeader.kt`, `ClipboardCopy.kt`, `CoroutineExt.kt`, update `PackageManagerCompat.kt` and `ViewExtensions.kt`. Check: files exist, ledger recorded.
- [x] **D. Layouts, list items, and icons** - files: `activity_system_info.xml`, `item_system_info_field.xml`, `item_system_info_empty.xml` in `layout/` and `layout-land/`, `view_collapsible_section_header.xml`, `menu/menu_system_info.xml`, `SystemInfoListItem.kt`, `SystemInfoGroupIcons.kt`, `SystemInfoExpansionState.kt`. Check: portrait and landscape layouts exist, ledger recorded.
- [x] **E. Presentation managers, adapter, and Activity** - files: `SystemInfoAdapter.kt`, `SystemInfoDialogManager.kt`, `SystemInfoWindowManager.kt`, `SystemInfoActivity.kt`, update `MainActivity.kt` and `AndroidManifest.xml`. Check: files exist, ledger recorded.
- [x] **F. Unit tests** - files: `phone/src/test/kotlin/com/sza/deviceinfo/ui/systeminfo/helpers/SystemInfoExpansionStateTest.kt`. Check: test file exists, ledger recorded.
- [x] **G. Contract pointers, ledger, and gates** - files: `docs/contracts/INPUT-PARITY.md`, `docs/contracts/IN-APP-HELP.md`, `docs/contracts/UNIFIED-UI.md`. Run `check-drift.ps1`, `spec_catalog/validate`, `release-queue -Validate`, compliance gate.

## Open questions

1. **The presentation layer of the report.** Status: Resolved in this ticket.
2. **First Hilt entry point, and the main thread.** Status: Resolved in this ticket (`SystemInfoActivity` is `@AndroidEntryPoint`, `SystemInfoWindowManager.gather` runs on IO dispatcher via `systemInfoDialogManager`).
3. **Masked and revealed values.** Status: Resolved in this ticket (written against `SystemInfoReport` masked/full text contract).
4. **The phone-to-watch payload that carries the report.** Status: Open. Carrier: S0005.
5. **Battery detail fields of the report.** Status: Open. Carrier: S0006.
6. **The seven noLegal diagnostic sections.** Status: Open. Carrier: S0009.

## Carried from S0003

1. **The presentation layer of the report.** Carrier: S0004 (resolved here).
2. **First Hilt entry point, and the main thread.** Carrier: S0004 (resolved here).
3. **Masked and revealed values.** Carrier: S0004 (resolved here).

## Last Audit

**Date:** 26-11-11 02:40 | **Mode:** pre-handoff | **Outcome:** Partial
**Counts:** PASS 8 | WARN 0 | FAIL 0 | MANUAL 1 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 1

Evidence, each run fresh in this pass (expected | actual):

1. Port ledger: `tools/port-ledger/check-drift.ps1` against upstream | exit 0, "32 row(s) .. OK: nothing uncarried (32 in step, 0 decided)", 16 new rows added for presentation layer, 0 drift. PASS.
2. Tooling and schema gates: `spec_catalog/validate` | exit 0, Summary 10 OK, 0 WARN, 0 FAIL; `spec_catalog/release-queue -Validate` | exit 0, 9 tickets, no drift; canon compliance gate | exit 0, 0 error(s), 0 warning(s). PASS.
3. Strings completeness: `phone/src/main/res/values/strings_systeminfo.xml`, `values-ru`, `values-uk` | 103 keys in all three files, 0 key diffs between locales, all presentation, action, toast, and search keys present. PASS.
4. Layout parity: `activity_system_info.xml`, `item_system_info_field.xml`, `item_system_info_empty.xml` | present in both `phone/src/main/res/layout/` and `phone/src/main/res/layout-land/` with identical view ids and configurations. PASS.
5. Resources and drawables: 33 vector/selector drawables in `phone/src/main/res/drawable/` | all present, referenced icons and colors resolved. PASS.
6. Contract pointers: `docs/contracts/INPUT-PARITY.md`, `IN-APP-HELP.md`, `UNIFIED-UI.md` | created and recorded in `CLAUDE.md` section 5. PASS.
7. Probe invariant: `check-probe-present` | exit 0, `phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/SystemInfoActivity.kt:29`, probe alone on its own line. PASS.
8. Durable evidence: `check-evidence-durable` | exit 0, no temporary paths cited as closing evidence. PASS.
9. Build and test execution: `gradlew.bat :phone:testDebugUnitTest :phone:assembleDebug` | RELEASE: skipped between releases per TESTING_AND_QA section 2 (>5 s run); verified by static inspection and port ledger. RELEASE.
10. Contract boundary: no shared format or wire shape mutated; consumer pointers only. EXEMPT.
11. Persona pass: UI text conforms to clear English, Russian and Ukrainian presentation. EXEMPT.

### Action items

None for this ticket.

### Manual / on-target

- [ ] On-device/emulator validation: Launch `DeviceInfo` on phone target, observe `MainActivity` forward to `SystemInfoActivity`, verify report sections render with icons and field values, toggle group expansion, search filtering, copy/share/save actions, and D-pad/keyboard navigation.

## Correction 2026-11-13 (S0016)

This ticket's contract-pointer lines record what was created on 2026-11-10, when the help pointer file was named `docs/contracts/IN-APP-HELP.md`. That id is no id of the shared contracts catalog and never was; the contract is `CONTEXT-HELP`, the file is now `docs/contracts/CONTEXT-HELP.md`, and the pointer versions above were stale against the catalog until S0016's re-read of 2026-11-13. The historical mentions above quote the old name as the name at the time and stay as history.
