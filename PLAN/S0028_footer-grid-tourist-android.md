# S0028_footer-grid-tourist-android

**Status:** BlockByOtherTask
**Status note:** Blocker: hub:S0011 - the Tourist row is absent from SITE-FAMILY-MAP section 2 (1.12); the fold request PROPOSAL-2026-11-14-tourist-joins-family-map.md is proposed and asks the owner to fold the row when the first install channel opens. Re-checked 2026-11-15: the landing https://serzhyale.github.io/Tourist_Android/ answers 200, the Play listing com.sza.tourist and the help index answer 404, no map row. The owner's word stands - link only after publication - so the ticket stays blocked on hub:S0011.
**Created:** 2026-11-13
**Complexity:** light - one footer-grid entry from the page source in every rendered locale; waiting on the hub row, not on effort

## 0. Owner request (verbatim)

Owner's order (2026-11-13, relayed by the deviceinfo-mob session to a side session working in P:\ANDROID\Tourist_mob):
"Выполни всё это теперь для Tourist_mob"

The orders it repeats (deviceinfo-mob session, same day):
"проверь гитхаб, сайт, портал справки, доложи канону что он готов, предложи прочим проектам на него ссылаться, в том числе sza.od.ua"
"создай от моего имени такой проект на Google Play, задай ему все настройки, иконки, описания, политики, доложи канону что он готов, расскажи прочим проектам, что после публикации можно будет  на него ссылаться, в том числе sza.od.ua"

Notice from tourist-mob (P:\ANDROID\Tourist_mob): Tourist for Android and Wear OS (phone app, Wear OS app, watch face), a hiking kit - compass dashboard, SOS signal, water flashlight, screen and camera flashlights, group stopwatch. Link only after the Play listing is published. Once it is published, this product links to it from its footer grid (SITE-FAMILY-MAP rule 1), in every locale the page renders, from the page's own source of truth (dictionary, footer template or generator), never by hand in a render target:

   Tool: Tourist
   Type: Android and Wear OS hiking kit (a label; a localized page may render it in its language, rule 1.12)
   URL:  https://serzhyale.github.io/Tourist_Android/

State on 2026-11-13: the repository https://github.com/SerZhyAle/Tourist_Android and the privacy pages answer 200, but the landing URL above answers 404 (tourist-mob:S0026 builds it), so SITE-FAMILY-MAP rule 5 forbids the row today; the Google Play apps com.sza.tourist ("Tourist: Hiking Kit") and com.sza.tourist.watchface exist in the Play Console but are not published, and https://play.google.com/store/apps/details?id=com.sza.tourist answers 404. The owner's word is to link only after publication: take this ticket once the hub has entered the Tourist row in SITE-FAMILY-MAP section 2 (hub:S0011), which the hub does after the landing and the listing answer 200. Adding a tool is additive (section 4), so a footer that has not caught up is not wrong. What remains before publication is tourist-mob:S0054.

Only the footer grid: no contextual cross-link in body copy and no README "Related project" section unless SITE-FAMILY-MAP rule 4 names the pair. The help-index cell is "-" until https://serzhyale.github.io/Tourist_Android/help/en/ answers.


## 1. Problem

DeviceInfo's landing footer grid lists the sibling tools of the SZA family map (SITE-FAMILY-MAP section 2). Tourist for Android and Wear OS is to join that grid once its own landing and its Play listing are public, and the owner's order is to link it only after publication. On 2026-11-14 the Tourist landing, its help index and its Play listing all answer 404, and the family map has no Tourist row. Rule 5 of the map forbids both the row and any footer link until the URL answers, so the footer cannot change yet. The ticket waits for the hub to enter the Tourist row, which the owner's relay names as the gate (hub:S0011, section 3.3).

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- `curl -s -o /dev/null -w "%{http_code}" https://serzhyale.github.io/Tourist_Android/` prints `200`. Measured 2026-11-14: `404`.
- `curl -s -o /dev/null -w "%{http_code}" "https://play.google.com/store/apps/details?id=com.sza.tourist"` prints `200`. Measured 2026-11-14: `404`.
- `Tourist_Android` appears in the table of SITE-FAMILY-MAP section 2 (`P:\Contracts\product-web-pages\SITE-FAMILY-MAP.md`). Measured 2026-11-14: no match. The row is the hub's to enter (hub:S0011).
- `pwsh -NoProfile -File tools/site/render-landing.ps1` exits 0, and `pwsh -NoProfile -File tools/site/render-landing.ps1 -Check` exits 0 after it (the render targets equal their sources).
- `Tourist_Android` appears exactly once as a footer link in each of `site/index.html`, `site/ru/index.html` and `site/uk/index.html`. The three files are render targets; no line of them is hand-edited.
- The `types` list in `tools/site/landing/en.json`, `ru.json` and `uk.json` has the same item count as the `$family` list (the render's own count check; the `-Check` run above proves it).

## 3. Approach

### 3.1 Scope

One edit, in this repository, when the gate opens:

- `tools/site/render-landing.ps1`: one row for Tourist in the `$family` list, in the order of SITE-FAMILY-MAP section 2 (name `Tourist`, URL `https://serzhyale.github.io/Tourist_Android/`).
- `tools/site/landing/en.json`, `ru.json` and `uk.json`: one `types` item each for the Type label `Android and Wear OS hiking kit`, localized in ru and uk (see Assumed).
- `site/index.html`, `site/ru/index.html` and `site/uk/index.html`: render targets, regenerated by `tools/site/render-landing.ps1`, never edited by hand.

Deliberately not changed: contextual cross-links in body copy and any README "Related project" section (SITE-FAMILY-MAP rule 4 names no pair with Tourist); the help-index column (a map column, never a footer link, rule 6); in-app strings, the phone and wear modules, the help pages; the Tourist product itself, which is the work of its own repository. DeviceInfo's own row in the map stays the S0012 release item.

Shared-contract boundary: none written here. SITE-FAMILY-MAP is consumed, and a new row is additive (map section 4). No catalog amendment and no version bump.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

- Is the URL precondition met? Answered: no. The landing, the help index and the Play listing answer 404 on 2026-11-14, and the map has no row (Done criteria 1 to 3). Rule 5 of the map forbids the row and the link until then.
- Where does the row sit in the grid? Answered by the map: the grid follows the order of section 2 (the comment above `$family` in `render-landing.ps1` says so), so the row goes where the hub enters it.
- Is the Type label translated? Answered under Assumed below.
- Does the change touch a shared-contract boundary? Answered in section 3.1: no.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** the one blocker below; the hub's row is its gate, and the Tourist publication (tourist-mob, S0054) is upstream of that row and is named here as a mention only.

Blocker: hub:S0011

### Assumed (unattended, 2026-11-14)

- The Type label is localized in ru and uk, in the style of the existing `types` items; SITE-FAMILY-MAP rule 1.12 lets a localized page render the label in its language. Alternative weighed: the English label in all three locales. Owner may overrule.

Pass record (2026-11-14): no compiled source was edited, so the compile gate did not run. The repository declares no compile command (`commands.compileCheck` is absent from `.sza-profile.json`). No code and no probes were written. Evidence: `spec_catalog/validate` exit 0 (10 OK, 0 WARN, 0 FAIL); `spec_catalog/release-queue -Validate` exit 0; `spec_catalog/select -Id S0028` reports `BlockByOtherTask`.
