# UI size profile and conformance evidence

Read against UI-SIZING 1.2, BUTTONS 2.2, COLLAPSIBLE-GROUP 1.2 and INPUT-PARITY 0.7 on 2026-11-14. COLLAPSIBLE-GROUP was re-read at 1.3 on 2026-11-15 (S0044): section 8 items B and C are clarifications that change no row below (the sections the table cites keep their numbers), and the topic-glyph rule is met in source on both surfaces (phone 24 of 24 groups, watch 10 of 10 headers).
Scope: the phone System information screen, its toolbar, search, report rows and dialogs, and the Wear OS
System information screen. These are source observations, not a claim that either package conforms: the
build, runtime interaction, measured geometry, contrast and captures remain open in S0007. The migration
exceptions are in the catalog registry, section 3, under DeviceInfo Android and S0023.

## Size and layout profile

Both apps use the stable Android touch profile. The ordinary target baseline is 48 by 48 dp; there is no
exposed compact mode or declared smaller floor, and no hybrid input-profile selector is offered (a single supported
touch profile, so there is no profile to switch; UI-SIZING 1.2 section 2 rule 1).

**Interface scale (exception E1, source written 2026-11-14).** Each app offers one shared interface scale of four steps:
100 (the ordinary baseline), 115, 130 and 150 percent. The range only grows from the baseline, so no target ever falls
under 48 dp, and no compact step exists because rule 4 asks for an owner-declared compact floor first. A stored or
requested value that is not one of the four steps reads as 100 percent, so an unknown value cannot produce a zero-size or
shrinking interface. The scale multiplies the density of the app's own resources (phone: a per-app density override
applied in `attachBaseContext` of `SystemInfoActivity` and `HelpActivity`, `InterfaceScale.wrap`; watch: a density
provider, configuration and resources around the theme, `WearInterfaceScaleScope`), so typography, glyphs, padding, gaps
and targets grow together (rule 3). The system font scale is left as the user set it and applies on top, so text
enlargement stays independent and nothing is scaled twice. The choice is stored per app (`InterfaceScale`,
`WearInterfaceScaleStore`); on the phone it is made from **Interface size** in the overflow menu (a radio list) and takes
effect when the screen is re-created, on the watch from one button at the end of the list that steps to the next size.
At 100 percent neither app wraps anything. The measured bounds are not claimed: smallest supported target 48 dp at
100 percent and 72 dp at 150 percent, from the declarations; the largest text, glyph and layout bounds, the survival of
the phone's override through AppCompat and the round-screen layout at 150 percent are S0007 device checks.

Packing is enabled on both surfaces, because the report has many groups and a user usually wants to see most
topics at once (COLLAPSIBLE-GROUP 1.2 section 4 rule 3). The phone lays out collapsed report headers on a grid of
one span per dp of usable width; each collapsed header takes the spans its measured content needs (title,
count, glyph, marker and the 48 dp copy control), so consecutive collapsed headers share a row at their own widths
and wrap when the row is full, and spare width stays empty (`SystemInfoHeaderPacking`, `SystemInfoAdapter`).
Expanded headers, their rows and the empty state occupy a whole row. Narrow example: a 360 dp portrait phone
usually fits one or two short headings per row and a long heading alone; wide example: a 900 dp tablet or a
landscape phone fits several. The watch packs consecutive collapsed headers into a wrapping flow: on a 192 dp
screen a long heading can occupy its own row, while a 240 dp screen can fit more than one short heading. Actual
bounds and line breaks on both widths are unmeasured. Both start with groups collapsed; users can open several
independently.

The phone's two measurement margins (the span grid's one-dp unit and a two-dp slack) mean a header can be up to
about three dp wider than its content; they are not a minimum width and never stretch a header to fill a row.

**Wear OS permanent variant, recorded 2026-11-14:** the toolkit's list item edge scaling on a round screen
follows UI-SIZING 1.2 section 6 and BUTTONS 2.2 section 10; it is an approved toolkit variant, not an exemption
from the 48 dp target, text reflow or accessible state. The product's own two actions, Refresh and Send to phone,
are no longer toolkit chips: `WearActionButton` draws a rectangular control with a 4 dp corner, a 48 dp minimum
target on both axes, a content-sized width and a wrapping caption, and the two sit in one wrapping flow (E2 source
change, 2026-11-14).
The list's safe area is the reading-start boundary of the group's state triangle (COLLAPSIBLE-GROUP 1.2
section 7). The product-drawn group header retains a filled state triangle and a rectangular 4 dp corner.
Review this variant when a contract amendment, Wear toolkit update, or a new non-toolkit component changes
its geometry, and at the next real-device measurement.

## Phone

| Contract and rule | Source evidence and limits |
| --- | --- |
| UI-SIZING 1.2 sections 2, 4 | `phone/src/main/res/values/dimens.xml` declares 48 dp for report rows and the section-copy width; `layout/` and `layout-land/item_system_info_field.xml` wire the row minimum. `PhoneUiSizingResources` checks declarations, wiring and non-truncation. The interface scale (E1) is `InterfaceScale` plus `InterfaceScalePicker`; `InterfaceScaleTest` holds the steps, the fallback of an unsupported value, that the density grows with the step, that the font scale is untouched and that a 48 dp declaration grows and never shrinks. Actual targets, screen size, scaling and overlap are manual. |
| BUTTONS 2.2 sections 2-4 | `menu/menu_system_info.xml` names toolbar actions; `SystemInfoAdapter` gives the separate copy control a localized name, tooltip, focus background and 48 dp dimensions. The toolkit draws the toolbar and dialogs. All states, geometry, naming, contrast, wrapping and real focus need captures and interaction checks; remaining geometry gaps are E2; the Help action is now wired to the help (S0024, unrun) and the help pages keep the one recorded gap of `help.css` (CONTEXT-HELP 0.2 item I): its entries draw a trailing state chevron, where COLLAPSIBLE-GROUP 1.1 puts a leading triangle; the catalog owes the revision of the file, which is vendored unedited. |
| COLLAPSIBLE-GROUP 1.2 sections 3-4 | `view_collapsible_section_header.xml` places the toggle and copy target as siblings; `CollapsibleSectionHeader` renders a state triangle, RTL direction and accessible state; `SystemInfoWindowManager` inserts only expanded fields and uses stable group keys through `SystemInfoGroupStateRepository`. Section 4 rules 3-4: collapsed headers pack at content-sized widths and an expanded header takes a whole row at its place in order (`SystemInfoHeaderPacking`, `SystemInfoAdapter.collapsedHeaderCellWidthPx`; `SystemInfoHeaderPackingTest` covers the arithmetic). Rule 2: a header activated during search closes or reopens its group for that search only and leaves the remembered state alone (`SystemInfoWindowManager.onToggleSection`), and after any activation the header is put back at its previous height. Rule 7: the viewport is saved on pause as an item identity plus offset and restored once after the first list is shown, a missing identity restoring nothing (`SystemInfoViewportStore`, `indexOfAnchor`). The source change for E3 on the phone is written and unrun; focus, drag cancellation, actual spacing, line breaks, reflow behavior and rendered contrast remain manual. |
| INPUT-PARITY 0.7 sections 3-4 | `SystemInfoActivity`, `SystemInfoWindowManager`, `SystemInfoAdapter` and the focusable layouts show touch, native focusable controls and a shared click path; the activity routes Ctrl+F to search and Ctrl+S to the toolbar's save command. They do not prove the shortcut, keyboard, D-pad or mouse behavior. F1 and the Help action are wired in source to the in-app help (`HelpLauncher`, S0024, 2026-11-14: written, not compiled or run; the action is named "Help (F1)", F1 on a focused element opens that element's entry, held keys do not repeat the open); the E4 help half stays open until the S0007 walk (touch, hardware keyboard, D-pad, mouse) runs it. |

## Wear OS

| Contract and rule | Source evidence and limits |
| --- | --- |
| UI-SIZING 1.2 sections 2, 4, 6 | `wear/src/main/res/values/dimens.xml` declares 48 dp; `WearInformationRow` and `SectionDisclosure` use it for both target dimensions. `WearUiSizingResources` checks the declaration. The two actions are `WearActionButton`s with a 48 dp minimum on both axes read from the same dimension (the toolkit `CompactChip` calls of the earlier source are gone). This is a source read, not a measurement of the clickable bounds, of enlarged-text growth or of the scaled edge; both buttons need the S0007 48-by-48 measurement. The interface scale (E1) is `WearInterfaceScale`, `WearInterfaceScaleStore` and `WearInterfaceScaleScope`, with the same four steps and fallback as the phone; the scope provides the density, the configuration and the resources together so that `dimensionResource` grows too, and `WearInterfaceScaleTest` holds the steps, the stepping, the store, the scaled configuration and a growing 48 dp declaration. E2 and E1 are changed in source and not yet reviewed on a device. |
| BUTTONS 2.2 sections 2-4, 10 | `SystemInfoScreen` gives the Refresh and Send actions localized captions and one handler each, drawn by `WearActionButton`: a rectangular control with a 4 dp corner, content-sized width, a wrapping caption and a visible disabled state, the two in one wrapping flow, with the send outcome text below. It replaces the toolkit `CompactChip`, which fixes a 48 dp layout height for one line (E2, source change 2026-11-14). The disabled state is the surface at 38 percent opacity and its contrast is unmeasured. State, contrast, focus, wrapping under enlarged text and target geometry remain manual. |
| COLLAPSIBLE-GROUP 1.2 sections 3-4, 7 | `SectionDisclosure` draws a reading-start filled triangle, supports RTL, exposes state, wraps text and uses one whole-header tap target. `reportItems` packs collapsed groups in order and inserts each open body immediately after its full-width header. `WearSectionExpansionStore` writes independent choices under screen key plus resource entry name. Section 4 rule 2: after a header is activated the row that holds it is brought to the middle of the list (a deliberate approximation: it does not preserve the header's previous height, which the toolkit's center-relative offsets do not let the source state without a device). Rule 7: list rows carry stable keys derived from resource entry names, and `WearViewportStore` remembers the center row's key plus offset once scrolling settles and restores it once the report is loaded (`WearViewportStoreTest` covers the store and the lookup, written and unrun). Real focus, drag, size behavior and the actual restored position remain manual. |
| INPUT-PARITY 0.7 sections 3-4 | `WearListColumn` uses `ScalingLazyColumn`; Wear Compose Foundation 1.4.1 source sets `RotaryScrollableDefaults.behavior(state)` by default and requests active hierarchy focus. `WearScreenScaffold` supplies `HierarchicalFocusCoordinator`; touch scrolling remains available. Crown scrolling and focus recovery need a real watch/emulator (S0007). Keyboard, mouse and D-pad are not imposed on watch by this contract. |

## Verification and release migration

- Source checks, run from the repository root after changing target resources and at release start:
  `java phone/src/test/java/com/sza/deviceinfo/ui/PhoneUiSizingResources.java` and
  `java wear/src/test/java/com/sza/deviceinfo/wear/ui/WearUiSizingResources.java`. Both are also called
  from their module's JUnit suite. These inspect declarations, not final Android hit bounds. The JUnit suites
  also hold `SystemInfoHeaderPackingTest` (phone) and `WearViewportStoreTest` (watch); they are RELEASE items.
- Release tier, run 2026-11-14 under the Build lock (S0023 fourth pass): `.\gradlew.bat :phone:assembleDebug
  :wear:assembleDebug --continue` exit 0, `BUILD SUCCESSFUL in 1m 7s` (before E1; E1 compiled in the next run of the
  same pass); `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest
  --continue`: wear 47 tests, 0 failures (`WearViewportStoreTest` and `WearUiSizingResourcesTest` among them), phone 80
  (store) and 84 (restricted) tests with one failure each, the battery header test of `GatherSystemInfoUseCaseTest`,
  which is not part of this conformance work (parked). `SystemInfoHeaderPackingTest` and `PhoneUiSizingResourcesTest`
  passed. The phone task is `testStoreDebugUnitTest` and `testRestrictedDebugUnitTest`: `:phone:testDebugUnitTest` is
  ambiguous because of the flavors and Gradle refuses it.
- RELEASE: acquire the Build lock, run `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest
  :wear:testDebugUnitTest` and `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug`. Run the S0007 phone and watch matrix,
  recording package/build, device, platform, theme, locale, font and display scale, contract version,
  scenario, actual measured bounds and results with screenshots. Do not mark a device scenario as passed
  from a source check or a screenshot alone.
- Migration deadline: 2026-12-31 for E1-E4. S0023 owns E1-E3; S0024 owns the in-app-help half of E4 (source written 2026-11-14, unrun; closes at the S0007 walk),
  while S0023 rechecks the input route. Review each entry on its fix, the device run, a relevant contract
  or toolkit change, and by the deadline. A release verdict must name every still-open exception and impact.
- State on 2026-11-14, after the fourth S0023 pass: E1, E2 and E3 are all changed in source (sections above), compiled,
  and covered by passing unit tests; none has run on a device or an emulator. The catalog registry rows for E1, E2 and E3
  still quote the evidence of the earlier source (no scale, full-width chips, equal columns, search forcing groups open,
  the ignored watch position key); they are refreshed at their review after the device run, because an unrun source
  change retires no exception. What the device run must still prove for E1: the phone's per-app density override
  survives AppCompat's configuration handling and re-creating the screen, the watch's density provider keeps the
  scaled list, headers and buttons coherent on a round display at 150 percent, 48 dp targets grow and never shrink,
  the choice survives a relaunch, and the system font scale still applies on top. No compact step exists, because
  UI-SIZING 1.2 section 2 rule 4 asks for an owner-declared compact floor before a product exposes one. S0023 stays
  open until that run.
