# S0015_footer-grid-streamsplayer-android

**Status:** BlockByOtherTask
**Status note:** Waits on the hub row: SITE-FAMILY-MAP (1.12) section 2 has no StreamsPlayer (Android) row and rule 5 forbids one while the landing and the Play listing answer 404 (re-checked 2026-11-13); the hub enters the row (hub:S0010) once both answer 200 and is itself in BlockByOtherTask on streams-mob:S0045 and streams-mob:S0047. Blocker: hub:S0010
**Created:** 2026-11-13
**Complexity:** light - one footer entry from the page source in every rendered locale; waiting on the hub row, not on effort

## 0. Owner request (verbatim)

Owner's order (2026-11-13, relayed by the deviceinfo-mob session to a side session working in P:\ANDROID\StreamsPlayer_mob):
"Повтори всё выполненное для новго Streams_mob"

The orders it repeats (deviceinfo-mob session, same day):
"проверь гитхаб, сайт, портал справки, доложи канону что он готов, предложи прочим проектам на него ссылаться, в том числе sza.od.ua"
"создай от моего имени такой проект на Google Play, задай ему все настройки, иконки, описания, политики, доложи канону что он готов, расскажи прочим проектам, что после публикации можно будет  на него ссылаться, в том числе sza.od.ua"

Notice from streams-mob (P:\ANDROID\StreamsPlayer_mob): StreamsPlayer for Android and Wear OS (phone app, Wear OS app, watch face), the Android sibling of STREAMS Player for Windows. Once it is published, this product links to it from its footer grid (SITE-FAMILY-MAP rule 1), in every locale the page renders, from the page's own source of truth (dictionary, footer template or generator), never by hand in a render target:

   Tool: StreamsPlayer
   Type: Android and Wear OS stream player (a label; a localized page may render it in its language, rule 1.12; it tells this row apart from "STREAMS Player - Windows stream player")
   URL:  https://serzhyale.github.io/StreamsPlayer_Android/

State on 2026-11-13: the repository https://github.com/SerZhyAle/StreamsPlayer_Android and the privacy pages answer 200, but the landing URL above answers 404 (streams-mob:S0045 builds it), so SITE-FAMILY-MAP rule 5 forbids the row today; the Google Play listing (https://play.google.com/store/apps/details?id=com.sza.streamsplayer) is created in the Play Console but not published and answers 404. The owner's word is to link only after publication: take this ticket once the hub has entered the StreamsPlayer (Android) row in SITE-FAMILY-MAP section 2 (hub:S0010), which the hub does after the landing and the listing answer 200. Adding a tool is additive (section 4), so a footer that has not caught up is not wrong. What remains before publication is streams-mob:S0072.

Only the footer grid: no contextual cross-link in body copy and no README "Related project" section unless SITE-FAMILY-MAP rule 4 names the pair. The help-index cell is "-" until https://serzhyale.github.io/StreamsPlayer_Android/help/en/ answers.
This landing already renders the map's rows in its footer grid from tools/site/landing/ dictionaries (en.json, ru.json, uk.json) and template.html, then tools/site/render-landing.ps1; the StreamsPlayer (Android) row is added there, in all three dictionaries in one edit, and the render -Check stays green.

Re-check of 2026-11-13 (this ticket's preparation pass): the landing and the Play listing still answer 404, help/en/ answers 404, the repository answers 200, and SITE-FAMILY-MAP (1.12) section 2 has no StreamsPlayer (Android) row; hub:S0010 is itself in BlockByOtherTask on streams-mob:S0045 and streams-mob:S0047. The gate is closed exactly as section 0 states; the ticket waits.

## 1. Problem

Since 2026-11-13 the portfolio has a tenth sibling: StreamsPlayer for Android and Wear OS, the Android side of STREAMS Player. This landing states the family in its footer grid - one entry per sibling row of SITE-FAMILY-MAP section 2 - so the grid will have to grow the tenth entry like every other page of the family. It cannot happen yet: rule 5 of the map keeps a URL out of the table until its page answers, the new tool's landing and its Google Play listing both answer 404, and the map (1.12) has no row for the tool - the hub enters the row (hub:S0010) only after both answer 200, and the publication itself is streams-mob's work. Until then this grid is correct exactly as it is, and the work of this ticket is to be ready: everything decided, so the edit is one pass the day the hub row lands.

## 2. Done criteria

- The gate is open - observation: SITE-FAMILY-MAP section 2 carries the StreamsPlayer (Android) row entered by hub:S0010, and by the map's own section 5 check `curl -s -o /dev/null -w "%{http_code}" -L` the row's URL answers 200 (on 2026-11-13 the landing and the listing answer 404, so the ticket waits in BlockByOtherTask on hub:S0010).
- The rendered landing of every locale carries the tenth entry: `grep -c "serzhyale.github.io/StreamsPlayer_Android/" site/index.html site/ru/index.html site/uk/index.html` returns 1 per file, each entry shows the Tool cell StreamsPlayer and the Type label in the page's language (amendment 1.12), and the entry sits after the STREAMS Player entry, in the map's order.
- The entry comes from the page source, never a render target: the generator's family table (`$family` of tools/site/render-landing.ps1) carries the row after the STREAMS Player row, and the `types` arrays of all three dictionaries carry the localized label in the matching position, index-aligned with the family table.
- `pwsh -NoProfile -File tools/site/render-landing.ps1 -Check` exits 0 - the three pages are current.
- Nothing beyond the grid: no contextual cross-link in body copy and no README "Related project" section (rule 4), the help-index cell of the map stays "-" while `https://serzhyale.github.io/StreamsPlayer_Android/help/en/` answers non-200, and the render diff touches the footer only.

## 3. Approach

### 3.1 Scope

In: one footer entry, from the page source - the generator's `$family` table (one row, after the STREAMS Player row) and the `types` arrays of `tools/site/landing/en.json`, `ru.json` and `uk.json` in one edit - then the render and `-Check`. Out: the hub row and the hub card (hub:S0010), the publication of the landing and the listing (streams-mob:S0045 and streams-mob:S0047; what remains before publication is streams-mob:S0072), a help-index cell for the new tool (rule 5 for that column - the cell stays "-" until help/en/ answers), any body cross-link or README section (rule 4), and this product's own map row (a release item, `docs/RELEASE.md`).

### 3.2 Open questions

None. The row's wording is fixed by the hub (hub:S0010, the owner's decision recorded there as streams-mob:S0048 D2): Tool StreamsPlayer, Type Android and Wear OS stream player, URL https://serzhyale.github.io/StreamsPlayer_Android/, help index "-". The localized Type labels follow amendment 1.12: one short type with the meaning of the English one, the product's own translation (### Assumed).

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** hub:S0010 (the blocker - it enters the map row that releases this edit), streams-mob:S0045 (the landing), streams-mob:S0047 (the Play listing)
- The owner's word of 2026-11-13 stands: link only after publication. The edit is taken the day hub:S0010 lands the row, not before; on 2026-11-13 the gate is closed and the ticket waits in BlockByOtherTask.

### Assumed (2026-11-13)

- The localized Type labels planned for the edit: ru "Проигрыватель потоков для Android и Wear OS", uk "Програвач потоків для Android і Wear OS" - the same wording the grid already uses for the Windows stream player row, per amendment 1.12 point 3 (one translation per language in a product). The owner may overrule the wording at the edit; the en label is the map's own cell and is not a choice.
