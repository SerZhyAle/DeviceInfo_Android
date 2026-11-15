# S0012_product-landing-page

**Status:** Implemented
**Status note:** no compile command (no compiled source edited); landing rendered and statically audited, live-site audit, the SITE-FAMILY-MAP row and the What's new page are release items
**Created:** 2026-11-13
**Complexity:** medium - a three-locale landing of the site family, rendered from one template and three dictionaries, plus a social card, the sitemap and stamp declarations; assessed at the spec pass of 2026-11-13: no contract changes, no device needed for the page itself (scenario cards, not screenshots), the SITE-FAMILY-MAP row is a post-publication step. Read against the plan: the level stands.

## 0. Owner request (verbatim)

Left open by S0008 (2026-11-13). The owner decision of the S0008 quiz asks for a dedicated page of DeviceInfo in the site family (SITE-FAMILY-MAP) and a hosted privacy page in en, ru and uk under site/. S0008 delivered the privacy pages (site/privacy.html, site/privacy-ru.html, site/privacy-uk.html), the vendored family kit and the declarations in .sza-canon.json; the product landing is not authored.

The landing needs what PAGE-CONTENT asks of an app page: the identity block with the application icon and the full name, the proof of the use case (screenshots or scenario cards from a real device, which the on-device checks of S0007 produce), the get-it block with the Google Play link of the application id, the help or documentation link, the family footer, and the three locales in one edit. It also needs a DeviceInfo row in the SITE-FAMILY-MAP tool table, which is a change in the catalog and the hub, not in this repository: file it there with the cross-repo flow and record the Blocker token here when the spec pass finds it is needed. When the page exists, add it to site.pages in .sza-canon.json and to site/sitemap.xml, and run the site audit.


## 1. Problem

DeviceInfo has a hosted privacy policy but no page that says what the product is. A visitor from the Play listing, a search engine or the author's hub finds no identity (icon, name), no statement of the job the product does, no scenarios, no way to get it other than the repository, and no place in the family footer that every other SZA page carries. The page is owed in English, Russian and Ukrainian, built from the family kit, and must satisfy `PAGE-CONTENT` (order and the seven things a landing always carries), `PAGE-STYLE` (kit, per-locale pages of amendment 3.9, checklist of section 11) and `SITE-FAMILY-MAP` (footer grid, one contact), and the canon's SEO instrumentation (`DOCUMENTATION_CONCEPT` section 3).

## 2. Done criteria

Each line is a command or an observation; the evidence is in the Last Audit block.

1. `pwsh -NoProfile -File tools/site/render-landing.ps1 -Check` exits 0: the three pages `site/index.html`, `site/ru/index.html`, `site/uk/index.html` equal what the template and the three dictionaries render, the dictionaries have the same keys, every title is at most 60 characters and every description is 50 to 155.
2. The static structure of each page, read from the files: one `h1`; one canonical equal to its public URL; the four reciprocal `hreflang` alternates (`en`, `ru`, `uk`, `x-default`) with absolute URLs, identical on the three pages; the JSON-LD parses and is one top-level `SoftwareApplication` with `offers` price 0 and the Play `installUrl`; Open Graph and Twitter tags with `twitter:card` `summary_large_image` and a 1200 x 630 `og:image` that exists in `site/assets/`; no `max-width` in the page layer; no emoji, no `...`, no long dash; no readiness hedge or forward look in any visible string.
3. Every relative `href` and `src` of the three pages resolves to a file of `site/`; the kit file is byte-identical to the hash in `site/assets/PROVENANCE.txt`.
4. `site/sitemap.xml` lists the three landing URLs with the reciprocal alternates; `.sza-canon.json` `site.pages` names the three pages; `tools/check-compliance.ps1` of the installed plugin exits 0 (or the exit code and the findings are written in the audit).
5. Run and observe (a headless browser rendering, foreground, one screenshot per size): at 360 and 1280 px the icon and the name `DeviceInfo` are visible without scrolling, the name is read first, the documentation link and the RU EN UA control are in the header, the get-it block is reachable, the footer grid lists the nine family entries.
6. The landing is in the documentation of this repository: `CLAUDE.md` sections 3, 5 and 6, `docs/RELEASE.md` (deploy order and the post-publication steps), `CHANGELOG.md`.

Not claimed (release items, section 3.1): the live-site audit, the live check of every link, the SITE-FAMILY-MAP row, real-device screenshots.

## 3. Approach

### 3.1 Scope

**Changes**

- A landing in three locale pages, `site/index.html` (en, also `x-default`), `site/ru/index.html`, `site/uk/index.html` (`PAGE-STYLE` 3.9: English at the root, each other locale in its own directory, ISO `uk` in the address, self-canonical in the directory form). They are **render targets**: `tools/site/render-landing.ps1` renders them from `tools/site/landing/template.html` and the dictionaries `en.json`, `ru.json`, `uk.json`, and with `-Check` proves the committed files are current. Nobody edits the three pages by hand (canon invariant 16).
- The page layer `site/assets/landing.css`, linked after the byte-identical kit and the privacy layer's sibling, never an edit of the kit.
- The link-preview image `site/assets/social-card-1200x630.png`, rendered by the existing `tools/store/render-store-assets.ps1` (one new output, same glyph geometry as the listing graphics, locale-neutral: icon and name).
- `site/sitemap.xml` rows and `.sza-canon.json` `site.pages` for the three pages; the stale sentences about the landing in `.sza-canon.json`, `CLAUDE.md` (sections 3, 5, 6) and `docs/RELEASE.md`; a `CHANGELOG.md` line.

**Page content (from `PAGE-CONTENT` order)**: sticky header (brand text, documentation link, RU EN UA, theme, the `#get` command), identity block (the launcher icon `site/assets/icon-512.png`, the name `DeviceInfo`, the kicker), H1 and lead, who it is for, five scenario cards (the proof), the get-it block (the one channel, Google Play, and three steps), feature groups (the phone groups, the watch sections, private by construction), help and support with three `details` groups (questions and troubleshooting, compatibility and technical details, privacy, permissions and licence), footer (author links, the grid of the nine other tools of the family map, privacy link). Every statement is traced to the listing source `docs/play/PLAY_LISTING.md`, the privacy page, `CHANGELOG.md` or a build file.

**Deliberately not changed**: the privacy pages and their URLs (a published address is permanent; the Play listing names `privacy.html`), the kit, the shared contracts catalog [the drive path this line named was removed 2026-11-13 by S0016 for SZA-CTR02 - the catalog's location is named once, in CLAUDE.md], the hub and any other repository, the app code. No release version is shown (the product ships on Google Play only and has no release manifest, so the durable store link stands alone, which `PAGE-STYLE` 3.10 item 3 allows). No GitHub Releases link, because the product has no such channel (`PAGE-CONTENT` item 3: no link to a channel the product does not have).

**Release items (owner or release flow, in this order)**

1. After the remote exists and `site/` is deployed, and the Play listing answers: the live checks of `docs/RELEASE.md` (every landing URL answers 200, the Play link answers, `/site-audit` of this repository).
2. After the three landing URLs answer: file the DeviceInfo row to the hub with `spec-draft.ps1 -Project hub`. `SITE-FAMILY-MAP` rule 5 forbids entering a URL before it answers, so no blocker exists today and none is filed now. The row to file: Tool `DeviceInfo`, Type `Android and Wear OS device information`, URL `https://serzhyale.github.io/DeviceInfo_Android/`, Help index `-`; its addition is MINOR (section 4 there) and adds one entry to the footer grid of every other product page.
3. The release flow writes a dated "What's new" page from `CHANGELOG.md` at the first release (`DOCUMENTATION_CONCEPT` section 4); until then the landing links the changelog source on GitHub.
4. Real-device screenshots of the phone and the watch (the S0008 `DO:` item, the S0007 device check) may be added to the page as a strip; the page does not claim them.

### 3.2 Open questions

None open. The choices below are taken and recorded; none is a one-way step, a contract change, scope or money.

### Assumed (unattended, 2026-11-13)

Owner may overrule each; every one is reversible inside this ticket.

1. **Proof of the use case is five scenario cards, not screenshots.** `PAGE-CONTENT` item 4 accepts "one demo strip, screenshot, or three to five scenario cards"; the repository holds no device screenshot and invariant 4 of `CLAUDE.md` section 2 forbids presenting a device scenario as proven without a device. Alternative: wait for S0007's screenshots (it is `BlockNeedUserTest`, the owner's desk); rejected because it would hold the whole page on a manual step the contract does not require. A screenshot strip is added later as one more block.
2. **Per-locale pages in the directory form** (`/`, `/ru/`, `/uk/`) of `PAGE-STYLE` 3.9, not one DOM switched by `data-lang` and not the flat `index-ru.html` of the big-app row. It is the shape the contract names for a product landing and the one the i18n lens of the site audit asks for (one URL per language). Alternative: flat names like the privacy pages; rejected because 3.9 says "directory form" for the self-canonical. The privacy pages keep their flat names (published address, S0008).
3. **A generator, not three hand-authored pages.** 3.9 item 4 allows hand authoring only where the product has a fingerprint gate against the English source; this product has none, so the pages are render targets of one template and three dictionaries and `-Check` is the currency gate. Alternative: hand-author and add a parity script; rejected because a template cannot drift in structure and one fix lands once.
4. **The documentation link is the repository README** (`https://github.com/SerZhyAle/DeviceInfo_Android#readme`), because the product has no portal and `PAGE-CONTENT` item 4 says such a product links the one page that documents it. It is a text link in the header, not a `.btn`, because the kit hides `.site-header .btn` under 481 px and the contract asks for the documentation to be one click away at 360.
5. **`offers` price 0 in the JSON-LD**, because `DOCUMENTATION_CONCEPT` section 3 and the site audit's check 9 require it on a landing. The listing says no ads, no account and no in-app purchase is mentioned anywhere, and the source is MIT-licensed, but the Play price is set in the console by the owner: if it is not free, change `offers` and the sentence of the dictionaries in one edit.
6. **The nine tool types are translated into Russian and Ukrainian here** (`SITE-FAMILY-MAP` 1.12 lets a page render the Type cell in its own language; one translation per language, pinned by the dictionaries `ru.json` and `uk.json`). The tool names and the URLs stay as the map has them. Alternative: English labels on the Russian and Ukrainian pages; rejected because it counts against the language share of those pages.
7. **No `lastmod` in the sitemap rows**: no commit exists to date them from and a hand-typed date goes stale; the audit's check 16 lists a missing `lastmod` as LOW.
8. **The "What's new" link goes to `CHANGELOG.md` on GitHub** until the release flow renders a dated page (release item 3); the only entry is `[Unreleased]`, so a rendered page would be an empty heading.
9. **Compatibility facts** (Android 8.0 and Wear OS on Android 9) are read from `min-sdk-phone = 26` and `min-sdk-wear = 28` in `gradle/libs.versions.toml`; if `minSdk` changes the dictionaries change in the same edit.
10. **No web-font request.** The pages link no Google Fonts stylesheet, as the privacy pages of S0008 do: the kit's font stacks fall back to the system fonts, a visitor's address is not sent to a third host, and the audit's check 20 (third-party hosts) stays clean. `PAGE-STYLE` section 0 step 2 and the checklist line "Outfit + Plus Jakarta Sans loaded" ask for the fonts; alternative: add the `<link>` to the template (one edit, all three pages) and name the host on the privacy page. Owner may overrule.
11. **Both header commands of the get-it kind stay.** The header `Get it` is the kit's `.btn-primary` and the kit hides it under 481 px (the documented overflow policy, since the get-it block repeats it); the documentation link is a text link and stays at 360.

### 3.3 Owner inputs (Approval gate)

None required to author the page. The owner's steps that make it live are the existing ones of `docs/RELEASE.md` (create the remote, deploy `site/`, publish the listing); S0012 adds the post-publication steps to that list.

- **Related tickets:** S0008 (delivered the privacy pages, kit and declarations; carries the remote and listing steps), S0007 (device check; source of real screenshots, not a dependency).

## 4. Plan

**Coverage inventory** (each line maps to a step or is out of scope):

| Line | Step |
| --- | --- |
| Identity block: icon and full name | P2 template, P1 dictionaries |
| Proof of the use case | P1 dictionaries (five cards), assumption 1 |
| Get-it block with the Play link of the application id | P2 template (`com.sza.deviceinfo`) |
| Help or documentation link | P2 header and help section, assumption 4 |
| Family footer | P2 generator (nine entries of the map) |
| Three locales in one edit | P1, P2: one template, three dictionaries, one render |
| DeviceInfo row in SITE-FAMILY-MAP | out-of-scope today: release item 2, rule 5 of the map |
| Add to `site.pages` and the sitemap | P4 |
| Run the site audit | partly P5 (static equivalents of the prepublish checks); the live audit is release item 1 |
| Social card (check 15 of the audit) | P3 |
| Contract rules (PAGE-CONTENT, PAGE-STYLE, SITE-FAMILY-MAP) | P1 to P2, checked in P5 |

**Produces and consumes.** P1 (dictionaries, page layer) and P3 (social card) consume nothing new; P2 (template and generator) consumes P1's keys and P3's file name; P4 consumes the rendered pages; P5 consumes everything; P6 (docs) consumes the generator and the files. No phase consumes a later one.

| Phase | Work | Static check |
| --- | --- | --- |
| P1 | `tools/site/landing/en.json`, `ru.json`, `uk.json`; `site/assets/landing.css` | the three dictionaries have the same keys (the generator checks it) |
| P2 | `tools/site/landing/template.html`, `tools/site/render-landing.ps1`; render the three pages | `-Check` exits 0 |
| P3 | extend `tools/store/render-store-assets.ps1` with the 1200 x 630 social card; run it | the PNG exists, header reads 1200 x 630 |
| P4 | `site/sitemap.xml`, `.sza-canon.json` | the three URLs in the sitemap; compliance gate exit code |
| P5 | static checks of the pages; headless screenshots at 360 and 1280 | outputs in the audit |
| P6 | `CLAUDE.md`, `docs/RELEASE.md`, `CHANGELOG.md` | grep for the new sentences |

**Self-review** (2026-11-13): every inventory line maps to a phase or a release item; every file a step consumes is produced earlier (`social-card-1200x630.png` in P3 is consumed by the template of P2 only as a URL, so the file name is fixed in P2 and the file exists after P3 before P5 reads it).

## Spec pass (2026-11-13)

- **Rung:** complex (more than three files, new files, a new tool). Forced upward by the primitive test: new files and new public artifacts.
- **Entry state:** `Draft`, a parked stub of S0008. Lease held by this runner (`run-spec-queue pq1`).
- **Contract boundary:** the page reads the `SITE-FAMILY-MAP` table and declares no new format; no catalog amendment is needed. The row for this product is a later, additive catalog change owned by the hub.
- **Between releases:** nothing above 5 seconds runs; the compile check does not apply (no compiled source is edited, and `commands.compileCheck` is absent from `.sza-profile.json`).
- **Not asked:** nothing in the ticket is a one-way or outward step; the Play link is derived from the frozen application id and is published by the owner's own step.

## Implementation record (2026-11-13)

**Files touched (all inside section 3.1):** new `tools/site/render-landing.ps1`, `tools/site/landing/template.html`, `tools/site/landing/en.json`, `ru.json`, `uk.json`, `site/assets/landing.css`, `site/assets/social-card-1200x630.png` (render target), `site/index.html`, `site/ru/index.html`, `site/uk/index.html` (render targets); edited `tools/store/render-store-assets.ps1` (one more output), `site/sitemap.xml` (three rows, `x-default` added), `.sza-canon.json` (`site.pages`, the stale comment sentence), `CLAUDE.md` (sections 3, 5, 6), `docs/RELEASE.md` (deploy step 4, new section "After the site and the listing are live"), `CHANGELOG.md`. Untouched: the privacy pages, the kit, every other repository, the app code. No compiled source was edited, so the compile gate does not apply (`commands.compileCheck` is absent from `.sza-profile.json`: "no compile command").

**Deliberate differences and findings recorded next to the code:** the generator refuses a dictionary set that cannot give three equivalent pages (keys, list lengths, title and description limits, three dots, long dashes, unused keys, tag sequence); two keys reach the page only through built-ins and are marked used in the script. The headless `--screenshot` of Edge enforces a minimum window width of about 500 px, so the 360 px view was taken inside an `iframe` of 360 px (a true 360 px viewport for the page's media queries); the screenshots are scratch and are not kept; the reproducing command is `msedge --headless=new --disable-gpu --hide-scrollbars --window-size=1280,2600 --screenshot=<png> file:///<repo>/site/index.html` (expected: a PNG whose first screen shows the icon, `DeviceInfo`, the H1 and the header controls), and for 360 px the same page inside an `iframe` of width 360 px in a local wrapper page.

**Parked / deduplicated:** the `SZA-CANON03` stale-stamp warning and the three-file port drift are pre-existing and already recorded (S0008 action item 1; S0013), so no new draft was filed.

## Last Audit

**Date:** 26-11-13 08:05 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 12 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 3

Evidence, each run in this pass (command | exit | expected -> actual):

1. `pwsh -NoProfile -File tools/site/render-landing.ps1` | 0 | writes 3 pages -> `site/index.html: 17501 bytes`, `site/ru/index.html: 22786 bytes`, `site/uk/index.html: 22634 bytes` (0.41 s); then `... -Check` | 0 | current -> "landing pages are current: 3 of 3".
2. `pwsh -NoProfile -File PLAN/S0012_product-landing-page/attachments/static-check.ps1` | 0 | 0 failures -> "failures: 0", 109 PASS lines: per page one `h1`, canonical equal to the public URL, four reciprocal absolute `hreflang` alternates identical on the three pages, `html lang`, one JSON-LD `SoftwareApplication` with price 0 and the Play `installUrl` and no version and no rating, Open Graph and `twitter:card` `summary_large_image`, title 49 to 55 characters and description 50..155, Cyrillic share 0 % (en), 89.3 % (ru), 89.1 % (uk), no three dots, no long dash, no emoji, no readiness hedge or forward look, no `target="_blank"`, no external script or iframe, tags balanced, `img` with width and height; social card 1200 x 630; icon 11.0 KB; `landing.css` without `max-width` or a centred margin; kit SHA-256 `d490abf3..` equals `PROVENANCE.txt`; every relative `href` and `src` resolves to a file of `site/`.
3. Sitemap and stamp (same script) | 0 | the three landing URLs listed with reciprocal alternates, each row maps to a file; `.sza-canon.json` `site.pages` names the six pages and all exist.
4. `tools/check-compliance.ps1` of the installed plugin (canon 2026.11.12.9) | 0 | 0 errors -> "0 error(s), 1 warning(s)": the warning is `SZA-CANON03` (stale stamp), EXEMPT below.
5. Run and observe, headless Edge in the foreground, one screenshot per size (each under 1 s): 1280 px (en), 360 px true viewport via `iframe` (en), 1920 px (uk), 1280 px (ru, `#technical` opens its group). Observed: the icon and `DeviceInfo` open the hero and are read before the H1; the header holds the brand, the documentation link, `RU EN UA` with the page's language pressed and the theme control (the kit hides the header `Get it` under 481 px by its own policy); the get-it block with the single Google Play button and three steps; five scenario cards; the footer grid of nine entries with the Type labels in the page's language; at 1920 px the content spans the viewport less the gutter; no horizontal overflow at 360 px.
6. Doc sync: `grep` of `render-landing` | `CLAUDE.md` 3, `docs/RELEASE.md` 3; `grep -c "parked draft S0012" CLAUDE.md` | 0 (stale sentences removed); `CHANGELOG.md` carries the product-page line.
7. Fast tier of the repository: `spec_catalog/validate` | 0 | "Summary: 10 OK, 0 WARN, 0 FAIL"; `spec_catalog/release-queue -Validate` | 0 | "13 ticket(s), no drift".
8. Probe invariant: `grep -rn "S0012" phone/src wear/src` | 0 hits | the ticket is not in the needs-manual-test status and carries no probe.
9. Contract boundary: the page reads the `SITE-FAMILY-MAP` table and declares no format; no catalog amendment exists or is needed.
10. Scope purity: every changed file is in "Files touched"; nothing outside the repository was written.

Known-red, named so it cannot mask a regression: `tools/port-ledger/check-drift.ps1` | 1 | "UNCARRIED: 3 of 92" (three phone collectors) - EXEMPT, carried by S0013, no file of this ticket is in the ledger.

### Action items
None.

### Manual / on-target
- None for this ticket's own acceptance. The device scenarios the cards describe are proven by S0007 (`BlockNeedUserTest`), not here; the page states them as shipped facts (canon invariant 17).

### Release items (RELEASE, with the command the release or the owner runs)
1. After the remote exists, `site/` is deployed and the Play listing answers: `curl -s -o /dev/null -w "%{http_code} %{url_effective}\n" -L <url>` for the three landing URLs, the privacy pages, `sitemap.xml` and the Play listing, then `/site-audit` for this repository (the live lenses cannot run before the site is public) - `docs/RELEASE.md`, "After the site and the listing are live" item 1.
2. After the three landing URLs answer 200: `spec-draft.ps1 -Project hub` with the `SITE-FAMILY-MAP` row (Tool `DeviceInfo`, Type `Android and Wear OS device information`, URL `https://serzhyale.github.io/DeviceInfo_Android/`, Help index `-`) - item 2 of the same section; rule 5 of the map forbids entering it earlier, so no `Blocker:` token exists.
3. At the first release: the dated "What's new" page rendered from `CHANGELOG.md` by the release flow - item 3 of the same section; `/site-audit prepublish` lists its absence as MED until then.
