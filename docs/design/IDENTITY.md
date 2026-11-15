# IDENTITY - the look the phone app and the watch app share (S0022)

The owner's position is that the two apps "look more or less the same", develop together and belong to one family.
They are built differently - the phone is View-based, the watch is Compose for Wear OS - so the look is shared as
**tokens**, not as code: one source of values, mapped to the phone resources and to the watch theme, and a check that
holds the three equal.

| What | Where |
| --- | --- |
| The values (colors in day and night, the glyph table, the type roles) | `docs/design/tokens.json` - the one source |
| The rules and the mapping to both apps | this file |
| The check | `pwsh -NoProfile -File tools/design/check-tokens.ps1` and its self-test `tools/design/test-check-tokens.ps1` |

## 1. Basis

The identity follows the **Android family look** (FastMediaSorter Android), by the owner's decision of 2026-11-13: the
accent is the blue of FastMediaSorter Android and of the `accent` hue of `ICON-RENDER`'s `palette.json`, the launcher
plate is its deep blue, and the glyphs come from the shared vocabulary (`docs/contracts/ICONOGRAPHY.md`). The product
site keeps the web family kit of `PAGE-STYLE` (Pine and Gold); that difference between the apps and the site is
deliberate and is recorded here, not removed.

## 2. Color tokens

Every token has a day and a night member in `tokens.json`. The phone carries both; the watch carries the night member
only (section 6).

| Token | Role | Phone resource | Phone theme attributes | Watch constant | Watch role |
| --- | --- | --- | --- | --- | --- |
| `accent` | the product's one hue: marker, group glyph, focus ring | `identity_accent` | `colorPrimary`, `colorSecondary` | `IdentityAccent` | `primary`, `secondary` |
| `onAccent` | content on an accent fill | `identity_on_accent` | `colorOnPrimary`, `colorOnSecondary` | `IdentityOnAccent` | `onPrimary`, `onSecondary` |
| `accentContainer` | a quiet accent fill | `identity_accent_container` | `colorPrimaryContainer`, `colorSecondaryContainer` | `IdentityAccentContainer` | `primaryVariant`, `secondaryVariant` |
| `onAccentContainer` | content on that fill | `identity_on_accent_container` | `colorOnPrimaryContainer`, `colorOnSecondaryContainer` | - | - (no such role in the toolkit) |
| `surface` | the screen | `identity_surface` | `colorSurface`, `android:colorBackground` | - | - (the watch background is not a token, section 6) |
| `onSurface` | title and value text | `identity_on_surface` | `colorOnSurface`, `colorOnBackground` | `IdentityOnSurface` | `onBackground`, `onSurface` |
| `surfaceVariant` | the section header band | `identity_surface_variant` | `colorSurfaceVariant` | `IdentitySurfaceVariant` | `surface` |
| `onSurfaceVariant` | field label and secondary text | `identity_on_surface_variant` | `colorOnSurfaceVariant` | `IdentityOnSurfaceVariant` | `onSurfaceVariant` |
| `error` | a value the report hints at | `identity_error` | `colorError` | `IdentityError` | `error` |
| `onError` | content on an error fill | `identity_on_error` | `colorOnError` | `IdentityOnError` | `onError` |

The phone resources are `phone/src/main/res/values/colors.xml` (day) and `values-night/colors.xml` (night), applied by
`Theme.DeviceInfo` in `themes.xml`; the older `focus_button_stroke` is an alias of `identity_accent`. The watch theme is
`wear/.../ui/theme/DeviceInfoWearTheme.kt`, set in `MainActivity`. The check also holds the contrast pairs of
`tokens.json` (3:1 for a marker or glyph on its surface, 4.5:1 for text) in both themes, and the watch's accent and
text roles on its black background.

## 3. Type roles

Typography is shared as roles; each side names its own style. The check holds every name to code that uses it.

| Role | Phone | Watch |
| --- | --- | --- |
| screen title | the toolbar's `textAppearanceTitleMedium` | `title2` |
| section header (open) | `csh_title`, 16 sp bold | `title3`, bold |
| section header (collapsed) | the same header | `caption2` |
| field label | `TextAppearance.DeviceInfo.Item.Subtitle`, in `onSurfaceVariant` | `caption2`, in `onSurfaceVariant` |
| field value | `TextAppearance.DeviceInfo.Item.Title`, in `onSurface` | `body2` |
| note or empty reason | `TextAppearance.DeviceInfo.Dialog.Body` | `caption2`, in `onSurfaceVariant` |

## 4. Section header treatment

One treatment on both sides: a header band in `surfaceVariant`; the disclosure marker (a solid triangle, pointing down
open and to the reading-start side collapsed) and the group glyph in `accent`; the title in `onSurface`. The phone's
band, marker and glyph are `CollapsibleSectionHeader` (`view_collapsible_section_header.xml`); the watch's are
`SectionDisclosure` in `SystemInfoScreen.kt`. The marker is the one of `COLLAPSIBLE-GROUP`; the touch targets and the
remembered expansion are `UNIFIED-UI` matters and are not repeated here.

## 5. Group glyphs

One meaning has one glyph and one drawable name on both sides. The table is `tokens.json` (`glyphs`): each phone group
with its drawable and its `ICON-SET` meaning, the watch sections that carry the same glyph, and the watch headers that
have no phone group (`watchOnly`). The watch headers - the nine report sections and the Help row of the same list - are
one sibling set, so every one has a glyph (`ICON-RENDER` 0.25 section 25 rule 1, S0035): Device draws `ic_watch`
(`device.watch`, proposed), Health a pulse trace (`ic_sysinfo_health`, `system.health`, proposed), Environment a leaf
(`ic_sysinfo_environment`, `system.environment`, proposed) and the Help row the question mark of `app.help`
(`ic_help_outline`, the phone's drawing). `check-tokens.ps1` fails when a title string the watch draws as a header has
no glyph. Two phone glyphs (`ic_sysinfo_hardware`, `ic_sysinfo_memory`) are provisional meanings filed by proposal;
three belong to the restricted build only. Adoption of the contract, the proposal and what is not yet measured:
`docs/contracts/ICONOGRAPHY.md`.

## 6. The watch's one dark palette

Compose for Wear has no light palette and the display is black glass, so the watch carries the night member of every
token and nothing else; the day member is a phone-only value. The watch background role is pure black (`#000000`, in
`tokens.json` under `watchOverrides`) and is deliberately not a token, because the phone's night surface is a dark grey,
lighter than the black glass the watch is built for. Upstream FastMediaSorter records the same ruling for its watch app.

## 7. The launcher glyph

An information mark - a ring, a dot and a stem - inside the 66 dp safe zone of the adaptive icon, on the deep-blue
plate (`launcherPlate` in `tokens.json`, `ic_launcher_background` in both modules), with a monochrome layer for themed
icons. The Play listing icon and graphic and the landing's social card are render targets of the same geometry
(`tools/store/render-store-assets.ps1`); they move on a brand change only.

## 8. Changing the identity

Change a value in `tokens.json`, then in the phone colors (day and night) and in `DeviceInfoWearTheme.kt`, in one edit,
and run the check (0.2 s). Changing a glyph means changing the drawable in both modules and the row in `tokens.json`.
A new glyph picks an existing meaning of the vocabulary or is proposed first (`docs/contracts/ICONOGRAPHY.md`).
Both apps change in the same ticket; a one-sided change records why in `docs/PARITY_MATRIX.md` (rows PM-040 and PM-041).

## 9. Evidence still owed

The same three screens (the report, a collapsed group, an expanded group) on the phone in light and dark and on the
watch in dark, from a device or an emulator, do not exist yet. They are an open manual check of S0007's device run, not
a pass; the check above proves the values and the drawings are the same, not that the rendered screens look the same.
