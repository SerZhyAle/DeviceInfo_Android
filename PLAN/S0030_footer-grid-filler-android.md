# S0030_footer-grid-filler-android

**Status:** BlockByOtherTask
**Status note:** Blocker: hub:S0012 - SITE-FAMILY-MAP 1.12 has no Filler row; rule 5 admits it only after https://serzhyale.github.io/Filler_Android/ answers (404 on 2026-11-14; help index and Play app page 404 too)
**Created:** 2026-11-13
**Complexity:** light - one footer-grid entry from the page source in every rendered locale; waiting on the hub row, not on effort

## 0. Owner request (verbatim)

Owner's order (2026-11-13, relayed by the deviceinfo-mob session to a side session working in P:\ANDROID\filler_mob):
"Сейчас то же делаем по Tourist_mob, а затем для Filler_mob !"

The orders it repeats (deviceinfo-mob session, same day):
"проверь гитхаб, сайт, портал справки, доложи канону что он готов, предложи прочим проектам на него ссылаться, в том числе sza.od.ua"
"создай от моего имени такой проект на Google Play, задай ему все настройки, иконки, описания, политики, доложи канону что он готов, расскажи прочим проектам, что после публикации можно будет  на него ссылаться, в том числе sza.od.ua"

Notice from filler-mob (P:\ANDROID\filler_mob): Filler for Android and Wear OS, a storage utility - it fills the free space of a storage device (built-in storage or a memory card) with temporary files and then deletes them again, with progress, speed and time left, and deletes only the files it wrote. Link only after the Play listing is published. Once it is published, this product links to it from its footer grid (SITE-FAMILY-MAP rule 1), in every locale the page renders, from the page's own source of truth (dictionary, footer template or generator), never by hand in a render target:

   Tool: Filler
   Type: Android and Wear OS storage filler (a label; a localized page may render it in its language, rule 1.12)
   URL:  https://serzhyale.github.io/Filler_Android/

State on 2026-11-13: the repository https://github.com/SerZhyAle/Filler_Android and the privacy pages answer 200, but the landing URL above answers 404 (filler-mob has no landing yet; filler-mob:S0022 item 6), so SITE-FAMILY-MAP rule 5 forbids the row today; the Google Play app com.sza.filler ("Filler: Fill Storage Space") exists in the Play Console but is not published, and https://play.google.com/store/apps/details?id=com.sza.filler answers 404. The owner's word is to link only after publication: take this ticket once the hub has entered the Filler row in SITE-FAMILY-MAP section 2 (hub:S0012), which the hub does after the landing and the listing answer 200. Adding a tool is additive (section 4), so a footer that has not caught up is not wrong. What remains before publication is filler-mob:S0022.

Only the footer grid: no contextual cross-link in body copy and no README "Related project" section unless SITE-FAMILY-MAP rule 4 names the pair. The help-index cell is "-" until https://serzhyale.github.io/Filler_Android/help/en/ answers.


## 1. Problem

The landing of this product ends with the footer grid of the SZA family: one link to every sibling tool of SITE-FAMILY-MAP section 2 (rule 1). Filler, the Android and Wear OS storage filler, is not a row of that map yet, so this landing does not link it. Its landing and its Play listing are not published: on 2026-11-14 the landing, its help index and the Play app page all answer 404. The owner's word is to link only after publication, and rule 5 of the map admits a URL only once it answers. The entry therefore waits for the hub to enter the row. When the row exists, the grid gets one entry in all three locales, rendered from the page source and never by hand.

## 2. Done criteria

Each line is a command to run or an observation to repeat. Criterion 1 is the gate that opens the ticket; criteria 2 to 7 are checked in the implementation pass that follows it.

1. Precondition, read on the day of the edit: `curl -s -o /dev/null -w "%{http_code}" https://serzhyale.github.io/Filler_Android/` prints `200`, and SITE-FAMILY-MAP section 2 carries a `Filler` row with that URL. Expected: `200` and the row present. Any other result keeps the ticket blocked, because rule 5 forbids the link before it answers.
2. `tools/site/render-landing.ps1`: the `$family` list holds ten entries, and the Filler entry has `Name = 'Filler'` and `Url = 'https://serzhyale.github.io/Filler_Android/'` at the index the map row takes. Observation: the list order equals the order of SITE-FAMILY-MAP section 2.
3. `tools/site/landing/en.json`, `ru.json` and `uk.json`: each `types` list has ten items, and the Filler type sits at the same index in all three.
4. `pwsh -NoProfile -File tools/site/render-landing.ps1` exits 0 and writes `site/index.html`, `site/ru/index.html` and `site/uk/index.html`.
5. `pwsh -NoProfile -File tools/site/render-landing.ps1 -Check` exits 0 after step 4.
6. `grep -c "Filler_Android" site/index.html site/ru/index.html site/uk/index.html` prints `1` for each file, and `grep -rn "Filler_Android" phone wear README.md` prints nothing. SITE-FAMILY-MAP rule 4 (no body-copy or README cross-link) and rule 6 (no help link in the grid) are held by that second grep.
7. `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` exits 0 after the status move.

## 3. Approach

### 3.1 Scope

- **In scope:** the footer grid of the product landing and the page source it renders from: the `$family` list of `tools/site/render-landing.ps1`, and the `types` lists of `tools/site/landing/en.json`, `ru.json` and `uk.json`. The three pages under `site/` are render targets and are not edited by hand.
- **Scope of the change (S0021):** site only. Neither module (phone, wear) gets it. A landing footer is not an app surface, and `docs/PARITY_MATRIX.md` carries no row for the landing or its footer, so no matrix row changes.
- **Out of scope:** the map row and the hub's own footer (owned by the hub); the Filler landing and the Play listing (filler-mob's ticket and the owner's console step); a help-index cell for Filler (SITE-FAMILY-MAP rule 6: the cell belongs to the hub and stays `-` until the help index answers); any body-copy or README cross-link (rule 4).
- **Shared-contract boundary:** yes, as a consumer. The row comes from `SITE-FAMILY-MAP` (1.12, rules 1 and 5). The grid layout follows `PAGE-CONTENT` and `PAGE-STYLE` through the render. This ticket changes no contract and needs no catalog amendment.

### 3.2 Open questions

- **Position of the entry in the grid.** Answered by the map: the grid follows the order of SITE-FAMILY-MAP section 2, so the entry takes the index the hub's row takes. Read at the implementation pass; not a question for the owner.
- **Type label in ru and uk.** Taken as an assumption below.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:**
Blocker: hub:S0012
- Mention only, not a claim: filler-mob:S0022 (the Filler landing and the Play listing, which the hub's row waits for).

### Assumed (unattended, 2026-11-14)

- **Type label in ru and uk.** Taken: a translated label in each dictionary, as rule 1.12 lets a localized page render the Type cell in its language. ru: "Утилита для заполнения памяти на Android и Wear OS"; uk: "Утиліта для заповнення пам'яті на Android та Wear OS". Alternative: the English label in all three locales. Owner may overrule.

### Blocked (2026-11-14)

- The ticket cannot pass the plan stage. Its one entry depends on the hub's row, and the row depends on a URL that does not answer (landing, help index and Play app page all 404 on 2026-11-14). The plan pass (Stage 2) waits for the blocker, so no plan is written and no file under `site/` or `tools/site/` is edited.
