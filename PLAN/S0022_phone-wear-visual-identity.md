# S0022_phone-wear-visual-identity

**Status:** Implemented
**Created:** 2026-11-13
**Complexity:** medium (assessed against the plan 2026-11-14) - one token source with a check and its self-test, a phone theme and a watch Compose theme, six watch glyph resources and a section-to-glyph table, an iconography pointer and a catalog proposal; no wire, data or shared-contract shape change.

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

This ticket's problem and done criteria (sections 1 and 2) were written from that message. The acceptance of the whole set is ticket target-state-acceptance (S0027).

Twelve tickets were captured by the two orders: bugfix-contract-pointers-stale (S0016), payload-parity-test (S0017), upstream-new-file-inventory-check (S0018), reverse-port-divergence-ledger (S0019), ship-together-surfaces-manifest (S0020), phone-wear-feature-parity-matrix (S0021), phone-wear-visual-identity (S0022), unified-ui-conformance-evidence (S0023), in-app-help-phone-and-wear (S0024), register-product-in-contract-catalog (S0025), canon-resync-stamp (S0026), target-state-acceptance (S0027).

Agent findings below are not the owner's words. They come from the investigation of 2026-11-13; every fact cites the file it was read from.

Position this ticket serves: "эти приложения .. выглядят более-менее одинаково".

Problem: the phone and the watch app match in structure (the same sections, collapsible groups and fields, three locales) but share no visual identity: neither has a palette of its own, and nothing ties their look to each other or to the family.

Evidence (read 2026-11-13):
- phone/src/main/res/values/themes.xml: Theme.DeviceInfo has parent Theme.Material3.DayNight.NoActionBar and no overrides. colors.xml holds three entries only (system_info_row_shade, focus_button_stroke #FF1976D2, text_color_secondary).
- `wear/src/main/kotlin/.../MainActivity.kt` wraps the app in the default androidx.wear.compose.material.MaterialTheme; there is no theme or color file in wear/src/main.
- The phone is View-based (ViewBinding, Material components), the watch is Compose for Wear OS, so a shared look has to be shared as tokens, not as code.
- Phone has its own group icon set (ic_sysinfo_*, ic_battery, ic_display and others under phone/src/main/res/drawable); whether the watch uses the same glyphs for the same meanings was not checked. The catalog has an iconography contract (one glyph and one name per meaning) that the repository does not list among its pointers.
- The launcher icon is created for both modules (S0008); the site uses the vendored family kit (site/assets/PROVENANCE.txt) and docs/play holds the listing graphics.
- No screenshot of either app exists in the repository; S0007 (device check) is BlockNeedUserTest.

Open question for the owner (decide before the plan pass): the identity is the product's own accent and tokens, or it follows the look of the family (the site kit, FastMediaSorter Android)?

Wanted:
1. The identity written once (docs/design or the like): accent and surface colors in light and dark, typography roles, the section-header treatment, the group icon vocabulary, the launcher glyph - with the mapping to phone resources and to the wear theme.
2. Implemented on both sides from that one source: the phone theme overrides and the wear Compose theme carry the same tokens; the same meaning uses the same glyph on both.
3. Whether the catalog's iconography contract is adopted: if yes, a pointer in docs/contracts/ and the check against its vocabulary; if no, the reason recorded.
4. Evidence: the same screen (device report, a collapsed group, an expanded group) on the phone and on the watch, light and dark - from a device or emulator; until it exists, an open manual check in the ticket, not a pass.

Compiled-not-tested applies until the release tier runs.


## 1. Problem

The owner wants the phone app and the watch app to look more or less alike. They already share structure (the same sections, groups and fields), but each wears the stock look of its platform, so nothing makes them look like one product.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- The identity (colors in light and dark, type roles, section header treatment, group glyphs, launcher glyph) is written once and mapped to the phone resources and to the watch theme.
- `pwsh -NoProfile -File tools/design/check-tokens.ps1` exits 0: it reads the token values from the phone resources and from the watch theme and shows them equal; the same meaning uses the same glyph on both sides.
- The question in 3.2 is answered and recorded.
- Screenshots of the same three screens (report, collapsed group, expanded group) from the phone in light and in dark and from the watch in dark (its one palette, `### Quiz decisions (2026-11-13)`, amended at the plan pass 2026-11-14), exist from a device or an emulator; until they do this is an open manual check in the ticket, not a pass (CLAUDE.md section 2 rule 4).

## 3. Approach

### 3.1 Scope

**Scope: both - phone and watch** (CLAUDE.md section 4, S0021). The matrix rows are PM-040 (identity: color tokens and
section header treatment) and PM-041 (group glyphs), both `offered` on both sides. The one place the watch does not get
the phone's feature is a glyph for its Device, Health and Environment sections; the reason is recorded in
`docs/PARITY_MATRIX.md` section 3 and `docs/design/IDENTITY.md` section 5.

What changes (2026-11-14):

- `docs/design/tokens.json` (the one source: 10 color tokens in day and night, contrast pairs, the launcher plate, the
  watch background override, six type roles, the group-glyph table) and `docs/design/IDENTITY.md` (the rules and the
  mapping to both apps).
- Phone: `values/colors.xml` and `values-night/colors.xml` carry the `identity_*` tokens, `Theme.DeviceInfo` maps them to
  the Material attributes, `view_collapsible_section_header.xml` tints the marker and glyph with the accent and sets the
  title color (the header treatment of IDENTITY section 4).
- Watch: `ui/theme/DeviceInfoWearTheme.kt` (the night palette as `Colors`, set in `MainActivity`), six group glyph
  vectors in `wear/src/main/res/drawable` with the phone's path data, `WearSectionIcons`, and the glyph and title color
  in `SectionDisclosure` of `SystemInfoScreen.kt` (classified `deliberate` in the local-divergence record).
- `tools/design/check-tokens.ps1` and `test-check-tokens.ps1`; `docs/contracts/ICONOGRAPHY.md` (the ICON-SET and
  ICON-RENDER pointers); the catalog proposal `PROPOSAL-2026-11-14-deviceinfo-system-info-meanings.md`; PM-040 and
  PM-041 and a section 3 bullet in the parity matrix; the index, CLAUDE.md sections 5 and 6, `docs/RELEASE.md` step 1
  and the CHANGELOG bullet.

What deliberately does not change:

- The launcher glyph and plate, the Play listing graphics and the social card: the identity records them
  (IDENTITY section 7) and the check holds the plate equal in both modules.
- The site keeps the `PAGE-STYLE` kit (Pine and Gold); the difference is recorded in IDENTITY section 1.
- No new string and no landing, listing or privacy copy: neither surface makes a claim about the look
  (`docs/DOCS_SURFACES.md` section 2; the CHANGELOG bullet is the one user-facing surface of this change).
- `ICON-EXTERNAL` is not adopted (no third-party pictures); the typography is not changed, only named as roles.
- The wire format, the Data Layer pair and every collector.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

Q: Should the common look of the phone and watch apps be this product's own accent and tokens, or follow the look of the rest of the family (the site kit, FastMediaSorter Android)? [answered 2026-11-13]

A: Follow the Android family look: the accent is the FastMediaSorter Android blue (day #1976D2, night #64B5F6, launcher plate #0D47A1), with the tokens written once in this repository and mapped to the phone resources and the watch theme. The site keeps the PAGE-STYLE kit (Pine + Gold); that difference is recorded, not removed. See `### Quiz decisions (2026-11-13)`.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0007 (the device run that carries the screenshots), S0021 (the parity matrix this ticket
  updates), S0023 (the UI conformance record whose header and size changes this ticket builds on), S0025 (the registry
  rows for the iconography adoption), S0027 (the acceptance of the whole set).

### Quiz decisions (2026-11-13)

Owner accepted the whole table of recommendations ("accepted with the table").

- Identity basis (product's own accent or the family look) -> the Android family look, FastMediaSorter Android blue (day #1976D2, night #64B5F6, launcher plate #0D47A1), with the tokens written once in this repository (accepted with the table). Reason: the phone already carries that blue by port lineage (`focus_button_stroke`, `ic_launcher_background`), it equals the `accent` hue of ICON-RENDER's `palette.json`, and the launcher, the Play listing graphics and the social card stay as they are. The web family kit (Pine + Gold) is deliberately not followed in the apps; the site stays on it, and this difference is to be recorded next to the tokens.
- Iconography contract (ICON-SET, ICON-RENDER) -> adopted as a consumer: a pointer in `docs/contracts/` and a check against its vocabulary (accepted with the table). Reason: the phone glyphs are ported from FastMediaSorter Android and their names are in the vocabulary, and the owner's position is that the apps are "связаны канонами и контрактами". The contract is `draft` and owned by FastMediaSorter Android; the version read is fixed at the plan pass.
- Group glyphs on the watch -> the watch group headers carry glyphs from the same vocabulary, same meaning and same name as on the phone (accepted with the table). Reason: it serves "выглядят более-менее одинаково"; the watch has no group glyphs today (`wear/src/main/res/drawable` holds only the launcher foreground; the code uses two Material vectors, Refresh and Send). Cost: a Compose change and vector resources for the watch, to be sized at the plan pass.

Resolved without asking:
- The watch carries one dark palette -> the dark member of each token pair only (Compose for Wear has no `isLight`; upstream FastMediaSorter `wear/src/main/res/values/colors.xml` records the same ruling as S2003 ADR-6). The light/dark screenshot criterion of section 2 therefore applies to the phone in both themes and to the watch in dark only; the plan pass amends the wording of that criterion.
- Typography roles and the section-header treatment -> not an owner decision; they are written into the identity document at the plan pass.

### Assumed (unattended, 2026-11-14)

Each is reversible inside this ticket (a value in `tokens.json`, the two color resource files and `DeviceInfoWearTheme.kt`,
or one table row); the owner may overrule any of them.

1. **The values of the non-fixed color roles** (surface, on-surface, the variants, the containers, error and the night
   on-accent) -> blue-tinted neutral tones in the Material 3 tonal style, each pair verified against its contrast
   minimum by the check (3:1 for marker and glyph, 4.5:1 for text). The owner fixed only the accent (day, night) and the
   launcher plate. Alternative: read the corresponding resources of FastMediaSorter Android and copy them; not done in
   this pass, so the surfaces may differ in shade from the family app. Owner may overrule.
2. **The header treatment** -> band `surfaceVariant`, marker and glyph in `accent`, title in `onSurface`, on both sides.
   Alternatives: keep the phone's marker in the neutral on-surface-variant, or keep the watch's accent title. The choice
   makes the two apps agree where they disagreed (the phone drew the marker neutral, the watch drew the title in the
   accent). Owner may overrule.
3. **Watch glyphs only where the phone shares the group** -> App, Sensors, Memory, Storage, Wi-Fi (the phone's Network
   glyph) and the paired Phone; Device, Health and Environment show none, as a phone section without a group shows none.
   Alternatives: give Device the phone glyph (it would repeat the glyph of the Phone section for another meaning, which
   `ICON-SET` forbids), or draw a private watch glyph (forbidden without a proposal). Owner may overrule.
4. **The watch background is pure black and not a token** -> the phone's night surface is a dark grey. Alternative: make
   the night surface black on both sides. Owner may overrule.
5. **The catalog proposal is filed by this pass**, beside the contract, as `ICON-SET` section 15 item 4 asks and as the
   repository's earlier proposals were (`PACKAGE-VERSIONING`, `FUNCTION-PARITY`). It changes no contract text; deleting
   the file undoes it, and the check then reports the missing proposal. Alternative: leave the filing to the owner.
   Owner may overrule.
6. **Three glyphs of the restricted build are `notShipped`, not proposed** -> that build has no release channel, so the
   proposal waits for the build that ships them. Owner may overrule.
7. **`ic_audio` stands for `content.audio`, `ic_speed` for `feature.speedometer`, `ic_settings` for `app.settings`,
   `ic_compass` for `feature.compass`** where the Android reference is shared by several records or the record's name
   fits the group loosely; the proposal names the two loosest rows for the owner. Owner may overrule.

## 4. Plan and implementation record (2026-11-14)

Coverage inventory - every wanted item and done criterion, the step that carries it, the static check that closes it:

| Item | Step | Closing check |
| --- | --- | --- |
| Wanted 1 / criterion 1: the identity written once, mapped to both apps | `docs/design/tokens.json`, `docs/design/IDENTITY.md` (colors, type roles, header treatment, glyph table, launcher plate, watch override, mapping tables) | file exists; `check-tokens.ps1` reads the source |
| Wanted 2 / criterion 2: implemented on both sides from the source, same glyph for the same meaning | phone `identity_*` colors and `Theme.DeviceInfo`, header layout; `DeviceInfoWearTheme`, six watch drawables, `WearSectionIcons`, `SectionDisclosure` | `check-tokens.ps1` exit 0, 146 checks |
| Wanted 3: the iconography contract, adopted | `docs/contracts/ICONOGRAPHY.md` (ICON-SET 0.39, ICON-RENDER 0.24, consumer), the vocabulary check inside `check-tokens.ps1`, the catalog proposal | `check-pointers.ps1` exit 0; the vocabulary section of the check |
| Criterion 3: the open question answered | 3.2 (answered 2026-11-13) | read |
| Wanted 4 / criterion 4: screenshots | owner step on a device or emulator | MANUAL, below |
| Parity, scope and surfaces (S0021, S0020) | PM-040, PM-041, section 3 bullet; CHANGELOG bullet; no copy surface makes a look claim | `check-matrix.ps1` exit 0; `check-surfaces.ps1` exit 0 |
| Port divergence (S0019) | `SystemInfoScreen.kt` classified `deliberate` with its KDoc excerpt | `check-local-divergence.ps1 -RequireClassified` exit 0 |

Produces and consumes: the token source is produced first and consumed by both resource sets and the check; the drawables
are consumed by `WearSectionIcons`; the proposal is consumed by the vocabulary section. No step consumes a later one.

Results (all run in this pass, 2026-11-14, from the repository root):

- `pwsh -NoProfile -File tools/design/check-tokens.ps1` -> exit 0, `OK - 146 check(s) equal, 0 mismatch(es)`, 224 ms.
- `pwsh -NoProfile -File tools/design/test-check-tokens.ps1` -> exit 0, 6 expectations (the real tokens exit 0; a night
  accent, a glyph drawable, a contrast value, a meaning id and the launcher plate each corrupted exit 1 with the
  expected finding), 3.2 s. The first manual negative run proved the check can fail before the self-test was written.
- `pwsh -NoProfile -File tools/contracts/check-pointers.ps1` -> exit 0, 8 pointers, `ICON-SET 0.39` and `ICON-RENDER
  0.24` equal to the catalog.
- `pwsh -NoProfile -File tools/parity/check-matrix.ps1` -> exit 0, 41 rows.
- `pwsh -NoProfile -File tools/docs/check-surfaces.ps1` -> exit 0.
- `pwsh -NoProfile -File tools/port-ledger/check-local-divergence.ps1 -RequireClassified` -> exit 0, 8 local edits, 0
  unclassified.
- `java phone/src/test/java/com/sza/deviceinfo/ui/PhoneUiSizingResources.java` and the watch twin -> exit 0 both.
- `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/check-probe-absent -Id S0022` -> exit 0 (no ticket probe in source).
- Static checks of the Kotlin edits against the toolkit sources in the local Gradle cache (`compose-material` 1.4.1):
  `Colors` takes the 13 named parameters used, `MaterialTheme(colors, typography, shapes, content)` and
  `Icon(painter, contentDescription, modifier, tint)` exist with those names.
- **Compile: no compile command.** `commands.compileCheck` is absent from `.sza-profile.json`, so the Kotlin and resource
  edits are not built; they are inspected statically and stay unbuilt and untested until the release tier.

Release items (RELEASE): `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug` (resources, themes, the vector
drawables, the Compose theme and the section header compile and link), then `.\gradlew.bat :phone:testDebugUnitTest
:wear:testDebugUnitTest`; both are over 5 s and are not run between releases.

Manual checks (MANUAL, owner, with S0007's device run - none is claimed as passed):

- [ ] Phone, light: the report, one collapsed and one expanded group. Passing: the header band is the light blue-grey, the
  triangle and the group glyph are the accent blue, the title is near black, field labels are the muted grey.
- [ ] Phone, dark: the same three screens; band dark blue-grey, accent the light blue, no purple tint anywhere.
- [ ] Watch, dark: the report, one collapsed chip cloud and one expanded section. Passing: the accent blue marker and
  glyph, an on-surface title, the chips readable, the glyph chips wrap inside the display, Device, Health and
  Environment show no glyph.
- [ ] Not covered by any check above: ICON-RENDER rule 3 on the rendered screens, the focus ring color on a D-pad walk,
  and large-text clipping of the wider watch chips.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14

## Last Audit

**Date:** 26-11-14 | **Mode:** static | **Outcome:** Partial
**Counts:** PASS 13 | WARN 0 | FAIL 0 | MANUAL 1 | UNCHECKABLE 1 | EXEMPT 3 | RELEASE 2

The identity is written once and held equal by a check; nothing failed. The ticket stays below Verified because the
same-screen evidence needs a device or an emulator and the Kotlin and resource edits are not built (the repository
declares no compile command).

### Action items
1. None open in this ticket. The catalog owner decides `PROPOSAL-2026-11-14-deviceinfo-system-info-meanings.md`; when
   it is folded in, `tools/design/check-tokens.ps1` reports the provisional ids and the watch Device section gets its
   glyph in a follow-up edit of the source table.

### Manual / on-target
- [ ] The three screens of section 4 on the phone (light, dark) and the watch (dark), run with S0007's device walk; the
  passing criteria and the not-covered list are in section 4.

### Other
- RELEASE: `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug`, then `.\gradlew.bat :phone:testDebugUnitTest :wear:testDebugUnitTest`.
- UNCHECKABLE: ICON-RENDER section 3 rule 3 (3:1 of every glyph against every theme surface) on the rendered screens;
  the check proves the token pairs from their values only.
- EXEMPT: `ICON-EXTERNAL` (no outside pictures); a light watch palette (Compose for Wear has none); the launcher artwork
  and the listing graphics (unchanged, recorded in IDENTITY section 7).
