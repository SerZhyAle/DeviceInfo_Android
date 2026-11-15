# CONTEXT-HELP - pointer

| Field | Value |
| --- | --- |
| **Id** | `CONTEXT-HELP` |
| **Version** | 0.4, draft (shared contracts catalog, `in-app-help/`, read 2026-11-13) |
| **Home** | shared contracts catalog, `in-app-help/` |
| **Owner** | shared |
| **Role here** | consumer - the help key, the help button, the help map and the help pages on phone and watch surfaces |

History of the id: this pointer was captured on 2026-11-11 under the id `IN-APP-HELP`, version "0.8, draft" - an id the catalog does not have and never had. The contract's id is `CONTEXT-HELP`; the file was renamed and the pointer re-read on 2026-11-13 (S0016).

What this repository owes (the contract's own asks):

- A help button on every surface it owes help for: the `app.help` glyph of `ICON-SET`, an action of the top app bar before the overflow, in the top-right corner, adding to what is there (section 2.1 rule 2); F1 where a hardware keyboard is attached (section 2.1 rule 1).
- The button, and F1 pressed while it has the focus, open the beginning of the surface's help and never the anchor of the button's own entry (0.3, section 8 item K).
- A help map listing every surface and what its help is, and answers in the contract's two forms (a layer over the live window or a page) with the page anatomy of sections 7 and 8.
- A Wear OS app screen is a surface: no button and no key by default - its row inherits the companion phone surface of the same application id, or it carries its own entry from a row at the end of the list (0.4, section 9 items L to O).

Version steps since the pointer was last read (2026-11-11):

- 0.3 (2026-11-12, clarification): the help button opens the page top, never the button's own anchor.
- 0.4 (2026-11-13, clarification): a Wear OS app screen is a surface with an inherited row by default; DeviceInfo Android (phone and watch) joins the consumers; the contract's id is `CONTEXT-HELP`.

Build and conformance: ticket S0024 (in-app-help-phone-and-wear), against 0.4, written 2026-11-14 and not compiled or run (no compile command is declared; the release tier builds it). The screenshot, its pins and the footer version are ticket S0032 (help-page-screenshots-generator), written 2026-11-14: the generator and the gate are in place and proved on a throw-away tree, and the device run that produces the first capture is a release item (`docs/RELEASE.md` step 3a).

| Rule or item | How it is met | Rung |
| --- | --- | --- |
| 1, 2, 3, 17 (key, button, one resolver, the map) | the Help action of the report window and F1 both call `HelpLauncher.open`, which asks `HelpResolver`; the Help action is named "Help (F1)" and stands before the overflow; F1 on an element with its own entry opens that entry, F1 on the Help action opens the top (0.3 item K); the map is `phone/src/main/assets/help/help-map.json` | 1 static (`tools/help/check-help-map.ps1`); the behavior is an open device check (S0007) |
| 4 (every surface has help or a reason) | seven rows: the report window (page), the watch screen (page, with its own Help row at the end of the list) and five `none` rows with a reason (the launcher trampoline, the help viewer, three dialogs whose text is the whole explanation) | 1 static |
| 5, 7, 12 (form, delivery) | form `page`: bundled assets in a WebView with JavaScript off, Back returns to the report window, links to other shipped pages stay in the viewer, every other address and the "Open on the site" action leave for the system browser; no page makes a request and the app has no INTERNET permission | 1 static; device check open |
| 8 (anatomy) | title, what it is for, the order, the elements with their facts and shortcuts, related, footer; the screenshot with numbered pins (item 3) and the captured-against version and date in the footer (item 7) are rendered from the capture records by `render-help.ps1` for every page and locale that has a record, one image per theme where the app has two (the watch has one); **no record exists yet**, so the committed pages still carry the revision date and no picture until the device run of `tools/help/capture-help.ps1` (S0032, `docs/RELEASE.md` step 3a) | partial, recorded: the generator is built, the first capture is a release item |
| 14 (screenshots generated and honest) | `capture-help.ps1` takes the real build per locale and theme on demo content (the clean state of a stock emulator image, the app's data cleared, no account), proves the language (the title text of the locale is on the screen) and the theme (the image's brightness) before it keeps a capture, takes every pin from the node bounds of the UI dump (the ids of the map's element rows on the phone, the recipe's locators on the watch), and records a part with no visible node as absent; the images are render targets of the generator and `render-help.ps1 -Check` refuses a stray one | script written and proved on fixtures (`tools/help/test-help-captures.ps1`); the device run and the look at the pins are open (S0007 walk) |
| 9, 10, 16 (entries, kit, voice) | `<details>` entries, `sza-kit.css` and `help.css` byte for byte; `help.css` keeps its trailing chevron (0.2 item I, owed by the catalog) | static; gap recorded in `docs/UI_CONFORMANCE.md` |
| 13 (language, one source) | en, ru, uk in one source file per page; names of controls come from the UI strings (`nameRef`); the page is chosen by the app language and falls back to en | 1 static |
| 15, 0.2 items F and G (address, noindex) | the index of each locale is `https://serzhyale.github.io/DeviceInfo_Android/help/<locale>/`; pages carry `noindex`, are not in `sitemap.xml`, and `robots.txt` does not block them; the landing links down to the index | 1 static |
| 0.4 items L to O (Wear OS) | a watch screen carries no button and no key; the watch app can run without a phone, so it carries its own entry (reading A), a Help row at the end of the list, and the phone page `watch-system-info` names the watch screen | 1 static; device check open |

Conformance rungs held (section 4): rung 1 (static) by `tools/help/check-help-map.ps1` and `tools/help/render-help.ps1 -Check`; rung 2 (freshness) in the **static form of 0.2 item D**, chosen by S0032: every capture record stores a hash of what its screenshot could show and `tools/help/check-help-captures.ps1` fails a record older than any input (its verdict line says `NOT HELD` while no record is committed, and `-Require` at the release start turns that into a failure); regeneration from the build, `tools/help/capture-help.ps1` on a device, is how a stale record is cleared; rung 3 (the walk on every surface, locale and theme) open, listed in S0007.

Registry row: `CONTEXT-HELP | DeviceInfo Android`, role C, reads 0.4, declared 2026-11-14 (ticket S0025), verification `pending` until the help is compiled and walked on a device (S0024, S0007); the adoption row is the product's own (0.4, item N), and the proposal that moved the catalog to 0.4 is `PROPOSAL-2026-11-13-deviceinfo-wear-os-app-surface.md`, accepted 2026-11-13. Exception E4 (until 2026-12-31) stays until S0023 rechecks the delivered Help action. The help-index address, permanent once published (rule 15), is `https://serzhyale.github.io/DeviceInfo_Android/help/en/`, with `help/ru/` and `help/uk/` beside it, and the `Help index` cell of this product's `SITE-FAMILY-MAP` row is that address (language en).
