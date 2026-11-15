# S0024_in-app-help-phone-and-wear

**Status:** BlockNeedUserTest
**Status note:** Phone F1 and Help action, help pages in en/ru/uk and the watch Help row are written in source (no compile command declared: not compiled, not tested); needs the owner's device test of F1, the Help action, the viewer and the watch row (S0007 checklist, three S0024 lines).
**Created:** 2026-11-13
**Complexity:** medium - assessed 2026-11-14: one new phone activity with a resolver, a shipped help map and nine generated pages in three locales, one watch row, a generator and a gate in `tools/help/`; no wire change and no shared-contract change (the contract text is consumed, not amended).

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

Further order, 2026-11-13, verbatim (chat, Russian), given after the correction of these specs:
"если тут какие то несогласия - предложи изменения к межпроектному контракту"

Carried out by five proposals filed in the shared contracts catalog the same day (the file names are in the done criteria of ticket register-product-in-contract-catalog, S0025): the Wear OS app surface in CONTEXT-HELP, the Wear OS profile in UI-SIZING, BUTTONS and COLLAPSIBLE-GROUP, and the place of the derived apps in FUNCTION-PARITY. Other projects had filed related proposals the same day (the watch scope question, the port ledger, the family function register); these specs are aligned to them rather than competing with them. Until the owners of those contracts decide, the sealed text applies.
This ticket's problem and done criteria (sections 1 and 2) were written from that message. The acceptance of the whole set is ticket target-state-acceptance (S0027).

Twelve tickets were captured by the two orders: bugfix-contract-pointers-stale (S0016), payload-parity-test (S0017), upstream-new-file-inventory-check (S0018), reverse-port-divergence-ledger (S0019), ship-together-surfaces-manifest (S0020), phone-wear-feature-parity-matrix (S0021), phone-wear-visual-identity (S0022), unified-ui-conformance-evidence (S0023), in-app-help-phone-and-wear (S0024), register-product-in-contract-catalog (S0025), canon-resync-stamp (S0026), target-state-acceptance (S0027).

Agent findings below are not the owner's words. They come from the investigation of 2026-11-13; every fact cites the file it was read from.

Position this ticket serves: "связаны канонами и контрактами" (the in-app help contract) and "пересекаются по документации" (the help is documentation).

Problem: the contract CONTEXT-HELP (catalog in-app-help/README.md, draft 0.3) asks for F1 and a "?" button on every window and an answer in the user's language; the phone has a Help control that does nothing and the watch has no help at all.

Evidence (read 2026-11-13):
- Contract: F1 means Help; windows carry a "?" button in the top-right corner without displacing existing controls; pressing it explains every significant element at once (a layer over the window) or opens an HTML page with a screenshot, numbered markers and a full description in the user's language; a help map proves every window has one; the form per window and the wording are the product's own decision.
- Phone: `phone/.../ui/systeminfo/SystemInfoActivity.kt` line 47-52 swallows F1 and returns true with the comment "Reserved for in-app help viewer"; menu_system_info.xml declares action_help (ic_help_outline, title "Help", translated in ru and uk) and SystemInfoWindowManager.kt line 119 handles R.id.action_help with an empty branch. A visible control that does nothing is a defect for the user, whatever the contract says.
- Wear: no help surface (a search for "help" in wear/src/main finds nothing).
- docs/contracts/CONTEXT-HELP.md [captured 2026-11-13 as `IN-APP-HELP.md` under an id the catalog does not have; renamed and re-read by S0016 the same day] says "Reserved for future ticket when standalone documentation is authored"; this ticket is that future ticket.
- SITE-FAMILY-MAP has a "Help index" column (the address of the product's help index, language en); a published address is permanent (CONTEXT-HELP rule 15), so the address must be decided before the first publication. The site is served from https://serzhyale.github.io/DeviceInfo_Android/ (site/).

Open questions for the owner (decide before the plan pass):
 (a) the form on the phone: an overlay on the report screen, or HTML pages (inside the app as assets, or on the site under a help route, or both);
 (b) the form on the watch: a short on-screen explanation, or a pointer to the phone and the site (a watch screen has little room);
 (c) whether the first release waits for the help; if it does not, the dead control and the F1 swallow are removed from the first release and come back with the help.

Wanted:
1. The answer to (a)-(c) written into the ticket.
2. F1 and the "?" control working on the phone's report window (touch, keyboard, D-pad, mouse per INPUT-PARITY); the watch's equivalent per (b).
3. Help text in en, ru and uk written as shipped, present-tense facts for every significant element, per the surfaces manifest (ticket ship-together-surfaces-manifest).
4. The help map the contract asks for, with its check (every window has an entry), added to the fast tier list.
5. The help-index address and its row for SITE-FAMILY-MAP prepared for the catalog registration (ticket register-product-in-contract-catalog); docs/contracts/CONTEXT-HELP.md corrected to the real id - done 2026-11-13 by ticket bugfix-contract-pointers-stale (the file was `IN-APP-HELP.md`, an id the catalog does not have).

Compiled-not-tested applies until the release tier runs.


## 1. Problem

The Help button on the phone does nothing and F1 is swallowed, and the watch has no help; the shared help rules ask for working help in the user's language on every window. A visible control that does nothing must not reach a user.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- The owner's answers to the question in 3.2 are recorded there.
- A search of the phone sources finds no empty Help branch and no swallowed F1; on the report window F1 and the Help control open the help (a manual device check, open until it is run); the watch has the equivalent chosen in 3.2.
- Help text exists in en, ru and uk for every significant element of each window, written as shipped present-tense facts; `pwsh -NoProfile -File tools/help/check-help-map.ps1` exits 0 (every window has an entry in the help map).
- docs/contracts/ cites the contract by its real id and version; the help-index address is recorded in the register of ticket register-product-in-contract-catalog.

## 3. Approach

### 3.1 Scope

**Scope statement (CLAUDE.md section 4, S0021), against `docs/PARITY_MATRIX.md` row PM-039 (In-app help):** both.
Phone: the Help action and F1 of `SystemInfoActivity` open a help page in `HelpActivity` (a WebView over bundled
assets). Watch: a Help row at the end of the list of `SystemInfoScreen` shows a short text; the phone's help page
`watch-system-info` names every watch screen (CONTEXT-HELP 0.4 item L, reading A). The two sides are not identical in
form and the difference is the contract's, not a gap: the watch has no keyboard and no top app bar (rules 1 and 2 ask
nothing there). PM-039 flips from `planned` to `offered` on both sides in this ticket.

Coverage inventory (every ask of the ticket mapped to a phase):

| Ask | Phase |
| --- | --- |
| 1. answers to (a)-(c) written into the ticket | already in 3.2 (quiz decisions of 2026-11-13); the plan-pass confirmations are under Assumed |
| 2. F1 and "?" on the phone, the watch equivalent | phase 2 (phone), phase 3 (watch) |
| 3. help text en/ru/uk for every significant element | phase 1 (sources and generator), phase 5 (surfaces) |
| 4. help map with its check, in the fast tier | phase 1 (map, `tools/help/check-help-map.ps1`), phase 5 (CLAUDE.md section 6) |
| 5. help-index address and its SITE-FAMILY-MAP row prepared | phase 5 (`docs/contracts/CONTEXT-HELP.md` and the register line of S0025) |
| contract rule 12 (offline, no request), 15 (permanent address), item G (noindex, not in the sitemap) | phase 1 (generator template and gate) |
| contract rule 14 (generated screenshots with markers) | out-of-scope: needs a device or an emulator run; carried as a release item to S0007 and as a parked Draft (see Assumed 6) |

Plan, in producer-before-consumer order; each phase ends in a static check:

1. **Map, sources, generator, gate.** `phone/src/main/assets/help/help-map.json` (the one map, shipped);
   `tools/help/source/*.json` (page sources with en/ru/uk text in one file per page); `tools/help/vendor/help.css`
   (the contract's reference layer, byte for byte) with `site/assets/sza-kit.css` as the kit;
   `tools/help/render-help.ps1` renders `phone/src/main/assets/help/<locale>/<id>.html` and
   `site/help/<locale>/<id>.html` from the same source (identical bytes) and copies the two CSS files beside them;
   `tools/help/check-help-map.ps1` and its self-test `test-check-help-map.ps1`. Static check: `render-help.ps1 -Check`
   and `check-help-map.ps1` exit 0.
2. **Phone.** `ui/help/HelpMap.kt`, `HelpResolver.kt`, `HelpLauncher.kt`, `HelpActivity.kt`, layout, menu, manifest entry;
   `SystemInfoActivity` and `SystemInfoWindowManager` call the launcher; strings en/ru/uk; unit test `HelpResolverTest`
   (reads the shipped map). Static check: every symbol referenced greps at its path; `check-surfaces.ps1` exits 0.
3. **Watch.** `WearHelpEntry` composable, the row at the end of `SystemInfoScreen`'s list, `ic_help_outline` drawable, a
   painter overload of `WearActionButton`, strings en/ru/uk. Static check: as phase 2.
4. **Local divergence.** The four edited ported files are classified (`record-local-decision.ps1`). Static check:
   `check-local-divergence.ps1 -RequireClassified` exits 0.
5. **Surfaces and records.** `docs/DOCS_SURFACES.md` (the window help pages row and the table of kinds of change),
   `docs/PARITY_MATRIX.md` (PM-039), `docs/contracts/CONTEXT-HELP.md`, `docs/UI_CONFORMANCE.md` (E4), `docs/README.md`,
   `CLAUDE.md` (layout, fast tier, help map named), `CHANGELOG.md`, `.github/workflows/pages.yml`, `.gitattributes`,
   `PLAN/S0007` checklist lines, and the landing's link down to the help index (one button in `template.html` and the
   three dictionaries, rendered by `render-landing.ps1`; CONTEXT-HELP rule 11 asks the site to link down to the pages).
   Static check: `check-surfaces.ps1`, `check-matrix.ps1`, `check-pointers.ps1`, `render-landing.ps1 -Check` exit 0.

Not changed and why: the Play listing (it names what the report shows and the way to get the app, and help is an aid
inside the app; no store claim changes, and the console draft is submitted at the release); the landing's feature copy
(only the link to the help index is added); the privacy pages and the permission surfaces (no permission is added:
`HelpActivity` shows bundled assets, the app still has no INTERNET permission, and links that leave for the browser are
ordinary intents). The `Help index` cell of the `SITE-FAMILY-MAP` row is S0025's to file; the address is prepared in
`docs/contracts/CONTEXT-HELP.md`.

### Assumed (unattended, 2026-11-14)

1. **The three dialogs of the phone are `none` in the map, not `inherit`.** The notification explanation, the copy full
   report confirmation and the report text box are each a message box or confirmation whose text is the whole
   explanation (CONTEXT-HELP rule 4); the third (`SystemInfoDialogManager.show`) has no caller since the S0004 port.
   The quiz row said `inherit` and left the plan pass to confirm. `inherit` would owe a help button in each dialog's
   title row (0.2 item A, E), which is a larger change for dialogs whose text already explains them. Alternative:
   `inherit` from `system-info` with a title-row button. Owner may overrule; the cost is three small dialog layouts.
2. **The help viewer and the launcher are `none`.** `HelpActivity` is the answer, not a surface that asks; `MainActivity`
   is a trampoline that finishes at once. Alternative: `inherit` for the viewer, which would open the same page it is
   showing. Owner may overrule.
3. **Back always returns to the report screen.** The WebView keeps its own page history for links between help pages,
   but the system Back closes `HelpActivity` at once, which is the literal wording of quiz decision (a). Alternative:
   Back steps through the followed pages first. Owner may overrule.
4. **The watch map row has form `page` with an extra member `entry`.** The short text on the watch is the watch's own
   entry (reading A, "a row at the end of the list"); the page it complements is `watch-system-info`, which the phone
   and the site carry. The contract's map reader ignores unknown members, so `entry` is safe. Alternative: a new form
   value. Rejected: it would be a contract change.
5. **Help pages carry a revision date, not a captured-against version.** Rule 8 item 7 asks for the product version
   and the capture date of the screenshot; there is no screenshot yet and no release version exists before the
   pin (S0008). The footer says "Revised <date>". The version arrives with the screenshot generator.
6. **Pages ship without a screenshot with markers.** Rule 8 item 3 and rule 14 need a device or an emulator run.
   Everything a screenshot would show is also in the text (rule 8's own wording), the entries keep their numbered
   markers, and the screenshot generator is parked as a Draft ticket with its rung of CONTEXT-HELP section 4 (rung 2)
   and the S0007 walk (rung 3). Alternative: hold the whole feature until a device is available. Rejected: decision (c)
   makes the first release wait for the help, and the pages are complete without the image.
7. **`help.css` is vendored unedited, with its trailing state chevron.** CONTEXT-HELP 0.2 item I owes a revision of
   `help.css` from the catalog (leading triangle, COLLAPSIBLE-GROUP 1.1); it is not hand-edited here unrendered. The
   gap is recorded in `docs/UI_CONFORMANCE.md`.
8. **Element focus mapping on the phone uses view resource names.** F1 with the focus inside the search field, on a
   toolbar action, a group header, its copy button or a field row opens that element's anchor; anywhere else the top
   of the page (rule 3). The help action itself is not in the map, so F1 on it opens the top (item K). Alternative:
   F1 always opens the top. Rejected: rule 3 asks for the anchor.
9. **"Open on the site" is a text entry in the viewer's overflow menu, with no glyph.** The icon vocabulary has no
   external-link meaning, and the globe drawable of the product belongs to another meaning (the network group).
   Alternative: an always-visible toolbar action with the globe. Rejected: one glyph, one meaning. Owner may overrule
   once the vocabulary has the meaning.
10. **The landing gets one link down to the help index, nothing else.** CONTEXT-HELP rule 11 asks the site to link down
    to the pages; the button sits in the landing's existing "Help and support" row and is rendered from the template and
    the three dictionaries. Alternative: no landing change until the help is published. Rejected: the link is a relative
    path and costs nothing before the pages deploy, and the gate holds it. Owner may overrule.
11. **The help gate and its self-test run in-process and read the repository as it is.** The self-test breaks 27 defects
    in a throw-away copy under `temp/S0024` and runs the gate once on them; it takes 5.8 s, a little over the 5 s tier,
    so it is run after editing either script only. Alternative: a smaller copy of the tree. Not worth a second
    mechanism today. Owner may overrule.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

Q: In what form should the help appear - on the phone an overlay on the report screen or HTML pages (in the app, on the site, or both), on the watch a short on-screen explanation or a pointer to the phone and the site - and does the first release wait for it, or ship without the Help control until it exists?

For the watch half of that question the catalog is asked too: the proposal of 2026-11-13 in the in-app-help folder (what a Wear OS app screen owes CONTEXT-HELP) offers reading A, the watch inherits the help of the companion phone surface of the same application id and the phone's help page names each watch screen, and reading B, a Wear OS app screen owes no help like a watch face. Reading A is the recommended one and matches the owner's wish that the two apps overlap in documentation; the answer to (b) is taken together with the catalog's decision, and until it lands the sealed text applies and the plan follows reading A.

Answered 2026-11-13 in the owner's quiz sitting; the answers to (a), (b), (c) and the help-index address are in the block below. The watch half (b) is taken together with the catalog's decision on the 2026-11-13 proposal; the chosen form stays valid under either of its readings (see the decisions block).

### Quiz decisions (2026-11-13)

The owner accepted the table of recommendations as a whole ("Принять все рекомендации"), so each row below is `accepted with the table`.

- (a) Form on the phone -> an HTML help page per locale, bundled in the app as assets (`assets/help/<locale>/`) and shown in an in-app WebView with JavaScript off, Back returning to the report screen; the same files are published on the site from one generated source, and the app prefers its own copy. No layer with markers in this ticket (CONTEXT-HELP rules 5, 7, 12 and the Android guidance of 2.5). Reason: the phone has one real surface (`SystemInfoActivity`), a layer over a dynamic list of sections is the costlier form, and the page works offline.
- (b) Form on the watch -> a short on-screen entry: a "Help" row at the end of the screen's scrolling list showing a short text in en, ru and uk, plus the phone's help page naming every watch screen. Reason: the watch app declares `com.google.android.wearable.standalone=true`, so a watch can run without the phone, and pure inheritance from the phone would leave that user with no help. This form is allowed under reading A of the catalog proposal (a watch app with no companion carries its own entry reached from a row at the end of the list) and under reading B (nothing owed, anything beyond is the product's choice), so it does not wait for the catalog's decision.
- (c) Does the first release wait for the help -> it waits. The Help control and F1 reach a user only working, together with the help text in en, ru and uk; the dead control and the swallowed F1 are not removed as a stopgap. Reason: the first release is gated by the owner's own steps of S0014 anyway (upload key, screenshots), and the ordered state of S0027 T4 needs the help in three languages.
- Help-index address -> `https://serzhyale.github.io/DeviceInfo_Android/help/en/`, with `help/ru/` and `help/uk/` beside it (CONTEXT-HELP 0.2 amendment item F). Permanent once a build or the site has published it (rule 15); the `Help index` cell of this product's SITE-FAMILY-MAP row is prepared from it for ticket S0025.

Resolved without asking:
- Phone surfaces in the help map -> `MainActivity` is a trampoline (`startActivity` then `finish()`), so `none` with that reason; `SystemInfoActivity` carries its own entry; the dialogs of `SystemInfoDialogManager` are `inherit` (CONTEXT-HELP rule 4: a confirmation whose text is the whole explanation is `none`, a dialog opened from a surface with help may `inherit`). Settled by `AndroidManifest.xml`, `MainActivity.kt` and the contract. The plan pass confirms the dialog rows.
- Where the control stands and what it is called -> the existing `action_help` item of the top app bar (`menu_system_info.xml`, `app:showAsAction="always"`, title already translated in ru and uk), the `app.help` glyph with the accessible name and tooltip "Help (F1)" per rule 2, and F1 and the button through one resolver (rules 1, 3 and 17). Settled by the contract and the existing menu resource.
- Watch input -> no F1 and no button on the watch (rule 1 asks nothing where there is no keyboard). Settled by the proposal's finding A and rule 1.

### 3.3 Owner inputs (Approval gate)

None required before implementation: the owner's answers are in 3.2, and the plan-pass confirmations are under
Assumed in 3.1 (the owner may overrule any of them).

- **Related tickets:** S0007 (carries the device walk of the help, rung 3 of CONTEXT-HELP), S0025 (files the registry
  row and the `Help index` cell from the address prepared in `docs/contracts/CONTEXT-HELP.md`), S0032 (the
  screenshot generator this ticket parked), S0023 (rechecks the input route; E4 closes at the S0007 walk). None blocks
  this ticket.

## 4. Implementation and verification record

Written 2026-11-14, unattended pass. **Not compiled, not tested:** `.sza-profile.json` declares no
`commands.compileCheck`, so no compile command ran; every Kotlin, resource and manifest change below is compiled-by-nobody
until the release tier.

Files added:

- Phone: `ui/help/HelpMap.kt`, `HelpResolver.kt`, `HelpPages.kt`, `HelpLauncher.kt`, `HelpActivity.kt`;
  `res/layout/activity_help.xml`, `res/menu/menu_help.xml`; `src/test/.../ui/help/HelpResolverTest.kt` (13 tests, not run);
  `assets/help/help-map.json` and the generated `assets/help/<locale>/*.html`, `help.css`, `sza-kit.css`.
- Tools: `tools/help/_help.ps1`, `render-help.ps1`, `check-help-map.ps1`, `test-check-help-map.ps1`, `source/common.json`,
  `source/system-info.json`, `source/watch-system-info.json`, `vendor/help.css`, `vendor/PROVENANCE.txt`.
- Site: the generated `site/help/<locale>/*.html`, `help.css`, `sza-kit.css`.

Files edited: phone `SystemInfoActivity` (F1), `SystemInfoWindowManager` (Help action, "Help (F1)" name and tooltip),
`AndroidManifest.xml` (`HelpActivity`, no permission), three `strings_systeminfo.xml`; wear `SystemInfoScreen`
(`WearHelpEntry`, the row at the end of the list), three `strings_systeminfo.xml`; `tools/site/landing/` (one help button,
three dictionaries) and the three re-rendered landing pages; `.github/workflows/pages.yml`, `.gitattributes`; `CLAUDE.md`,
`CHANGELOG.md`, `docs/README.md`, `docs/DOCS_SURFACES.md`, `docs/PARITY_MATRIX.md` (PM-039 `offered` on both sides),
`docs/UI_CONFORMANCE.md`, `docs/contracts/CONTEXT-HELP.md`, `PLAN/S0007` (three help checklist lines);
`docs/local-divergence-decisions.jsonl` (three classifications, notice RP-0005).

Evidence of this pass (each run in this pass; exit code and verdict line):

- `pwsh -NoProfile -File tools/help/render-help.ps1` exit 0 `render-help: PASS (22 files written)`; `-Check` exit 0
  `render-help: PASS (22 files current)` (1.9 s).
- `pwsh -NoProfile -File tools/help/check-help-map.ps1` exit 0 `help-map: PASS (7 surfaces, 2 help pages, 18 page files,
  9 read)` (1.5 s). Before the phone and watch code existed the same gate exited 1 with exactly the five expected
  findings (the empty Help branch, the swallowed F1, its placeholder comment, the missing watch row, the missing
  `HelpActivity` declaration), and nothing else.
- `pwsh -NoProfile -File tools/help/test-check-help-map.ps1` exit 0 `PASS (30 expectations held)` (5.8 s): 27 defects
  broken at once in a throw-away copy, one run of the gate names each; one run with the render check names a source
  edited without a regeneration. The first version of the self-test, which ran the gate once per defect, took 32.5 s and
  was run once at creation, before it had a recorded time: that run was above the between-releases limit and is
  reported here as such; it was rewritten into the batched form above.
- `tools/docs/check-surfaces.ps1` exit 0 (string keys agree en/ru/uk per module; phone and watch permissions unchanged);
  `tools/parity/check-matrix.ps1` exit 0 (41 rows, no planned cell left); `tools/design/check-tokens.ps1 -SkipCatalog`
  exit 0 (123 checks); `tools/site/render-landing.ps1 -Check` exit 0 (3 of 3 current);
  `tools/port-ledger/check-local-divergence.ps1 -RequireClassified` exit 0 (it exited 1 with three unclassified edits
  before the classifications); `check-scope.ps1` exit 0; `check-drift.ps1` exit 0; `check-version-parity.ps1` exit 0;
  `tools/harness.ps1 spec_catalog/validate` exit 0 (10 OK); `release-queue -Validate` exit 0; `check-probe-present -Id S0024`
  exit 0 (3 probes, each alone on its line); `check-compliance.ps1` exit 0 (0 errors, 2 warnings that predate this
  pass: the canon stamp, S0026, and an archived catalog path).
- `tools/contracts/check-pointers.ps1` exit **1**: the CONTEXT-HELP row is `OK` (0.4 equals the catalog); the two failures
  are `ICONOGRAPHY.md` (ICON-SET 0.39 against 0.40, ICON-RENDER 0.24 against 0.25), a drift this pass did not cause and did
  not touch; ticket S0031 (bugfix-iconography-pointers-stale) owns it.

Known open and honest limits:

- No screenshot with markers on any page (CONTEXT-HELP rule 8 item 3, rule 14): parked as S0032; the footer carries a
  revision date instead of a captured-against version (Assumed 5, 6).
- `help.css` is vendored unedited and draws a trailing chevron (Assumed 7, `docs/UI_CONFORMANCE.md`).
- Hand-over to S0025: the register does not exist yet; the help-index address
  `https://serzhyale.github.io/DeviceInfo_Android/help/en/` (with `ru/` and `uk/`) and the `Help index` cell are
  prepared in `docs/contracts/CONTEXT-HELP.md`, and S0025 files them. The address becomes permanent when a build or the
  site first publishes it (rule 15); nothing was published, pushed, tagged or uploaded in this pass.
- Documentation context: affected and changed - `CLAUDE.md`, `CHANGELOG.md`, `docs/README.md`, `docs/DOCS_SURFACES.md`,
  `docs/PARITY_MATRIX.md`, `docs/UI_CONFORMANCE.md`, `docs/contracts/CONTEXT-HELP.md`, the landing deck and pages, the S0007
  checklist; unchanged - the Play listing, the privacy pages, `docs/SECURITY_INVENTORY.md` and `docs/play/PLAY_DATA_SAFETY.md`
  (no permission, no data), `README.md`.
- RELEASE (nothing above 5 s ran): under the Build lock, `.\gradlew.bat :phone:testDebugUnitTest :wear:testDebugUnitTest`
  (runs `HelpResolverTest` and the earlier suites) and `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug`; the
  S0007 walk of the help on a phone and a watch (the three lines added there).

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14

## Last Audit

**Date:** 26-11-14 | **Mode:** static | **Outcome:** Partial
**Counts:** PASS 17 | WARN 0 | FAIL 0 | MANUAL 3 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 2

Static audit against the done criteria and the five wanted items; every PASS is a gate run in this pass (section 4). No
FAIL and no WARN; the outcome is Partial only because three manual checks are open and nothing was compiled or run on a
device. Nothing here claims that F1, the Help action or the watch row works on a device.

### Action items
1. None to fix. Carried: the screenshot generator (S0032), the registry row and `Help index` cell (S0025), the
   ICONOGRAPHY pointer versions (S0031, not this ticket's).

### Manual / on-target
- [ ] Phone: the S0007 help walk - the Help (F1) action opens the page at its top in the app's viewer with the network off,
  in en, ru and uk and both themes; F1 with a hardware keyboard on the search field, a section title, a row and the Help
  action itself (top, never the Help entry); a held F1 opens once; Back returns to the report window in one press; Open
  on the site leaves for the browser; rotation keeps the page; TalkBack reads "Help (F1)". Passing means every item
  observed on a device or emulator and recorded with build, device, theme and locale.
- [ ] Watch: the Help row at the end of the System information list opens and hides its text in en, ru and uk, fits a
  round 192 dp screen without clipping, and shows with no phone paired.
- [ ] The look: whether the WebView follows the app theme with JavaScript off, and how `help.css` (trailing chevron)
  reads in both themes and both directions.

Not covered by this audit: the screenshot rung (CONTEXT-HELP rung 2, S0032), the build and unit tests (RELEASE), any
rendered geometry.
