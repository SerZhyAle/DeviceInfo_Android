# Ship-together surfaces manifest

One user-facing change, every surface, every authored locale, one edit. This is the manifest the canon requires
(`DOCUMENTATION_CONCEPT` section 5, invariant 17) and the file the canon's feature-to-site skill reads: its step 1
looks for an existing manifest and extends it instead of writing a second one, and its step 10 prints and persists
exactly the table below. A surface missing from this list is the one that silently goes stale.

The machine half is `tools/docs/check-surfaces.ps1`: it enforces the locale column (string-key parity en/ru/uk per
module) and the permission column (one permission statement across the manifests, the security inventory, the
privacy pages and the Data safety answers). Exit 0 clean, 1 mismatch, 2 could not run. A check that reports nothing
passes as quietly as a clean one, so `tools/docs/test-check-surfaces.ps1` proves on a throw-away tree that it can
fail; run the self-test after editing the check.

The tables speak of the surfaces as shipped facts (invariant 17). The manifest itself is an internal record and
keeps the honest register where a row names work not landed yet.

## 1. The surfaces

| Surface | Files | Role | Locales | Enforced by |
| --- | --- | --- | --- | --- |
| In-app strings, phone | `phone/src/main/res/values*/strings*.xml`, `phone/src/restricted/res/values*/strings_diagnostics.xml` | source | en, ru, uk | `check-surfaces.ps1`, string-key parity per module; a key marked `translatable="false"` in the base locale is exempt from the translated locales |
| In-app strings, wear | `wear/src/main/res/values*/strings*.xml` | source | en, ru, uk | `check-surfaces.ps1`, string-key parity per module |
| Permission declarations | `phone/src/main/AndroidManifest.xml`, `phone/src/restricted/AndroidManifest.xml`, `wear/src/main/AndroidManifest.xml` | source | - (code) | `check-surfaces.ps1`, permission parity; read back from the built packages at the release by `tools/release/read-package-info.ps1` |
| Security inventory | `docs/SECURITY_INVENTORY.md` | source | en | `check-surfaces.ps1`, permission parity |
| Privacy pages | `site/privacy.html`, `site/privacy-ru.html`, `site/privacy-uk.html` | source | en, ru, uk | `check-surfaces.ps1`, permission parity |
| Data safety answers | `docs/play/PLAY_DATA_SAFETY.md` | source | en | `check-surfaces.ps1`, permission parity |
| Play listing text | `docs/play/PLAY_LISTING.md` | source | en, ru, uk | one file, three sections in one edit; the console draft is its render, submitted at release |
| Changelog | `CHANGELOG.md` | source | en | the release notes are trimmed from it at release (`docs/RELEASE.md` step 9) and published verbatim as the release body |
| README | `README.md` | source | en | single locale by design: the site carries the ru and uk text |
| Landing copy deck | `tools/site/landing/en.json`, `ru.json`, `uk.json` | source | en, ru, uk | a copy change lands in all three dictionaries in one edit |
| Landing pages | `site/index.html`, `site/ru/index.html`, `site/uk/index.html` | render target | en, ru, uk | never hand-edited; `tools/site/render-landing.ps1` renders them, `-Check` proves currency |
| Landing social card | `site/assets/social-card-1200x630.png` | render target | - | `tools/store/render-store-assets.ps1` |
| Store listing graphics | `docs/play/icon-512.png`, `docs/play/feature-graphic-1024x500.png` | render target | - | `tools/store/render-store-assets.ps1`; they move on a brand change, not per feature |
| Help map | `phone/src/main/assets/help/help-map.json` | source | - (names come from the UI strings) | `tools/help/check-help-map.ps1`: every surface has a row and every row a surface, every `none` and `inherit` row a reason; the one shipped file that `HelpResolver` and the gate both read |
| Help page sources | `tools/help/source/common.json`, `system-info.json`, `watch-system-info.json` | source | en, ru, uk | one file per page holds the three locales, so they change in one edit; `render-help.ps1` refuses a missing locale, an element without its five texts, more than seven order steps, an unresolved UI string or a long dash. An element named by `nameRef` takes its name from the UI strings of its module, so a renamed button is renamed in its help by the same edit |
| Help pages | `phone/src/main/assets/help/<locale>/*.html` and `site/help/<locale>/*.html`, with `help.css` and `sza-kit.css` and the page pictures `<page>-<theme>.png` beside them | render target | en, ru, uk | never hand-edited; `tools/help/render-help.ps1` renders them (the same bytes in the app and on the site; a page with a capture record gets its figure, pins and version footer), `-Check` proves currency, `check-help-map.ps1` holds the rest of CONTEXT-HELP rule 19 |
| Help capture recipes | `tools/help/capture-recipes.json` | source | - | how each page is captured and which files its screenshot could show; `capture-help.ps1 -DryRun` proves it holds together, and `check-help-captures.ps1` counts it as an input of every capture |
| Help screenshots | `tools/help/captures/captures.json`, `tools/help/captures/<page>/<locale>-<theme>.png`, `tools/help/captures/absent-baseline.json` | render target (of a device run) | en, ru, uk | never hand-edited; `tools/help/capture-help.ps1` writes them on a device or emulator at the release start, `check-help-captures.ps1` is the rung 2 gate in its static form (`-Require` at the release start), `render-help.ps1` carries the pictures into the pages |
| Watch help row | `system_info_help_title` and `system_info_help_text` in the wear strings | source | en, ru, uk | part of In-app strings, wear (`check-surfaces.ps1`); `check-help-map.ps1` holds that the watch screen shows the row |

Not surfaces of this repository: the Play Console (the owner submits the listing sources there), the hub card on
sza.od.ua (touched only when the one-sentence answer to "what is this product" changes, on the owner's order), and
every other product's pages. The upstream FastMediaSorter checkout is read-only and never a surface.

## 2. What moves together, by kind of change

| Kind of user-facing change | Surfaces touched, in one edit |
| --- | --- |
| New or changed behaviour or metric of the phone app | phone strings (en, ru, uk), CHANGELOG bullet, landing copy deck (en, ru, uk) and re-render, PLAY_LISTING (all three sections), the help page source of the touched screen (`tools/help/source/<id>.json`, en, ru, uk in one edit) and `render-help.ps1`; a change to what the screen looks like makes its help screenshot stale (`check-help-captures.ps1`) until the device run of `capture-help.ps1` is repeated. The watch surfaces move only if the watch app changes too - otherwise record why not beside the claim. |
| New or changed behaviour or metric of the watch app | wear strings (en, ru, uk), CHANGELOG bullet, landing copy deck (en, ru, uk) and re-render, PLAY_LISTING (all three sections), the help page source of the touched screen (`tools/help/source/<id>.json`, en, ru, uk in one edit) and `render-help.ps1`; the watch row text is part of the wear strings. |
| New, changed or dropped permission | the three manifests, SECURITY_INVENTORY, privacy pages (en, ru, uk), PLAY_DATA_SAFETY, and the allowed list of `tools/release/read-package-info.ps1` (`docs/RELEASE.md` step 6). A limitation the user notices goes next to the affected action on the landing, not in a footnote. |
| New or lifted honest limitation | PLAY_LISTING, landing copy deck and re-render, privacy pages when data is involved. Lifting a limitation deletes its sentence from every surface in the same edit. |
| A release | CHANGELOG `[Unreleased]` moves under the new version (the release flow, `docs/RELEASE.md` step 9); the release notes are trimmed from it for the console. No landing edit: the landing shows no version, the store page is its durable link. |
| A new platform, edition or channel (a positioning change) | README, landing copy deck (en, ru, uk) and re-render, PLAY_LISTING (all three sections), the hub card and the `SITE-FAMILY-MAP` row on the owner's order, and the family kit cross-links. |
| An icon or brand change | the launcher mipmaps of both modules, the `tools/store/render-store-assets.ps1` sources, and the re-render of the two listing graphics and the social card. |

## 3. The procedure

1. **Classify.** An internal refactor with no user-visible delta stops here; this product's ledger records user-facing
   changes only, so it takes no bullet.
2. **Take the row** of section 2 for the kind of change. The surfaces are never decided from memory.
3. **Write the one sentence first** - task-first, in the product's voice, in English, then every authored locale of
   every surface of the row in the same edit. Present tense, a shipped fact: no "soon", "planned", "not yet", no
   readiness hedge (invariant 17). The owner's order is the only input; the state of the code is none.
4. **Edit sources, regenerate render targets.** The landing pages and the listing graphics are never hand-edited:
   `tools/site/render-landing.ps1` and `tools/store/render-store-assets.ps1` run in the same edit.
5. **Run the gates:** `pwsh -NoProfile -File tools/docs/check-surfaces.ps1` and
   `pwsh -NoProfile -File tools/site/render-landing.ps1 -Check`. Both exit 0.
6. **Print the surface table** - Surface | Source of truth or render target | Locales | Changed / N/A + reason.
   An unexplained N/A is a failure, not a pass.

## 4. Worked example: the battery charge speed metric (S0010, FastMediaSorter S4529)

The phone app's Battery section reports the charge speed in mA and watts, the power profile, the nominal profile,
the estimated time to a full charge and the estimated runtime left, and says plainly when the device does not expose
a value (`BatteryDetailsCollector`). The change kind is row 1 of section 2, and the row 1 surfaces it moves:

| Surface | Locales | What moves |
| --- | --- | --- |
| In-app strings, phone | en, ru, uk | the field labels of the battery rows and the wording that reports a value the device does not expose |
| Changelog | en | the bullet leads with the user-visible win: the charge speed and the estimated runtime, then the mechanism |
| Landing copy deck and pages | en, ru, uk | the feature statement names the charge speed and the estimated time to a full charge |
| Play listing text | en, ru, uk | the description of the phone app names the charge speed |

Surfaces that do not move, with the reason recorded:

| Surface | Reason |
| --- | --- |
| In-app strings, wear | the metric has no watch surface: `BatteryDetailsCollector` is phone-only, the watch Health section reports sensor facts and not charging, and the watch report reaches the phone as the text of the watch's own sections |
| Manifests, SECURITY_INVENTORY, privacy pages, PLAY_DATA_SAFETY | no permission is declared, nothing leaves the device: the metric is read from the phone's own battery service |
| README, help pages | no claim of the README changes; the help pages describe the window controls and no report value, so none changes |

## 5. Maintaining the manifest

- A surface joins this table the day its first file exists, before anything links to it, together with its row in
  section 2 if it introduces a new kind of change.
- A surface that becomes generated flips to render target in the same edit that adds its generator, and its check
  moves into that generator.
- A new authored locale or a new permission-bearing surface extends `tools/docs/check-surfaces.ps1` in the same
  edit.
- The parity check is fast tier: it stays under 5 seconds, and a run of it is cited, not assumed.
