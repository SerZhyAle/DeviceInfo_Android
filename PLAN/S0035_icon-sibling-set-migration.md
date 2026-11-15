# S0035_icon-sibling-set-migration

**Status:** Implemented
**Created:** 2026-11-14
**Complexity:** medium (rewritten at the spec pass 2026-11-14, confirmed at the build pass of the same day) - the phone half needed no code (one menu comment and three records); the watch half, branch A, added two vocabulary proposals, four vector drawables, one table, one check extension and a Compose map change

## 0. Owner request (verbatim)

Symptom (agent finding, found by S0031 on 2026-11-14): two sibling sets do not draw a glyph on every member or on none. ICON-RENDER 0.25 rule 1 forbids that (catalog iconography README section 25, rule 1); migration rule 6 makes the registry row read `partial 0.25` until both sets conform.

1. Watch System information, section headers (wear/src/main/kotlin/com/sza/deviceinfo/wear/ui/apps/systeminfo/WearSectionIcons.kt and SystemInfoScreen.kt, SectionDisclosure): App, Memory, Storage, Wi-Fi, Phone and Sensors show a glyph; Device, Health and Environment show none. Options: (a) draw a glyph for all nine - needs meanings for Device (device.watch is only proposed), Health and Environment, filed under ICON-SET section 15; (b) remove the six glyphs - ICON-RENDER 0.25 rule 4 calls that equally conformant. Which one the product keeps is the owner's choice; PARITY_MATRIX PM-041 currently says the watch carries the glyphs of the groups it shares with the phone.

2. Phone System information overflow menu (phone/src/main/res/menu/menu_system_info.xml): the item action_system_info_notifications ("Turn on notifications", visible only while notifications are off) has no android:icon, while its sibling action_system_info_expand_collapse (showAsAction ifRoom) has one. When both fall into the overflow menu the set is mixed. Recommended: a vocabulary meaning for the item if one fits (system.notification-shade exists and is not checked for fit yet), otherwise a proposal under ICON-SET section 15.

Evidence (S0031 pass, 2026-11-14): WearSectionIcons maps six sections; phone SystemInfoGroupIcons maps all 24 groups and GatherSystemInfoUseCase gives every phone section a group (no gap on the phone group headers); menu_system_info.xml read as written.

Scope note: the audit covered the phone System information screen with its menu and the watch System information screen only. Every other surface (settings, dialogs, pickers, help pages) has not been inventoried against ICON-RENDER 0.25 rule 1; that inventory is the first step of this ticket.


## 1. Problem

The family's icon rule says a menu, a list or a row of group headers shows a picture on every member or on none. On
the watch, the System information screen breaks it: six section headers have a picture and the rest do not - and so
does the Help row at the end of the same list, which the first audit did not count. On the phone, the one menu item
that turns notifications on has no picture beside a sibling that has one; the pass found that the phone item is not
a defect, because the menu it lives in never draws pictures. What remains is the watch, where the owner decides
between a picture on every header and no picture on any, and a first look at the other screens of the product.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

Settled in the pass of 2026-11-14 (phone, inventory):

- The inventory of section 3.1 lists every surface of both apps that shows pictures, and says for each whether its
  sibling set conforms. Observation: re-read the table against `menu_system_info.xml`, `menu_help.xml`,
  `SystemInfoScreen.kt` and the layouts named there.
- No phone code forces the overflow popup to draw item icons: `Grep` of `setOptionalIconsVisible|MenuBuilder|forceShowIcon`
  over `phone/src` finds nothing (0 matches, 2026-11-14), and the toolbar is a plain `MaterialToolbar` subclass
  (`StandardToolbar`), so the overflow popup is a set without pictures (ICON-RENDER 0.25 section 25 rule 2).
- `menu_system_info.xml` names that reason beside the notifications item: `Grep` of `ICON-RENDER` over the file finds
  one match.

The owner answered the question of section 3.2 on 2026-11-14: branch A. Its criteria (met in the pass of 2026-11-14,
second pass, section 4):

- Branch A, a picture on every header (chosen): every title string drawn by `SectionDisclosure` - the nine
  sections and the Help row - is a key of `WearSectionIcons` (`Grep` of the nine `system_info_section_*` keys and
  `system_info_help_title` in that file); each new watch glyph is a row of `docs/design/tokens.json` and
  `pwsh -NoProfile -File tools/design/check-tokens.ps1` exits 0; the two meanings the vocabulary lacks (Health,
  Environment) are filed as `proposed` records in the catalog's `PROPOSAL-2026-11-14-deviceinfo-system-info-meanings.md`
  in the same change, and `device.watch` ships under its proposed id.
- Branch B, no picture on any header: void (the owner chose A).
- `pwsh -NoProfile -File tools/parity/check-matrix.ps1`, `tools/contracts/check-pointers.ps1` and
  `tools/docs/check-docs.ps1` exit 0; the registry row of ICON-RENDER and the pointer read the same state (no longer
  `partial 0.25`); the device observation of the headers is an open manual check (S0007), never a pass.

## 3. Approach

### 3.1 Scope

Changes in the pass of 2026-11-14: this ticket, one comment in `phone/src/main/res/menu/menu_system_info.xml`, the
third bullet of the ICON-RENDER finding in `docs/contracts/ICONOGRAPHY.md`, the ICON-RENDER row of
`docs/contracts/README.md`, and the product's own ICON-RENDER row in the catalog registry (the registry rules let a
product write its own rows; S0031 did the same).

Changes after the owner's answer (watch only): branch A touches `WearSectionIcons.kt`, up to four vector drawables in
`wear/src/main/res/drawable` (`ic_watch` ported from the upstream, `ic_help_outline` from the phone, two new ones for
Health and Environment), `docs/design/tokens.json`, `tools/design/check-tokens.ps1` (a watch-only provisional
meaning), `docs/design/IDENTITY.md` section 5, row PM-041 of `docs/PARITY_MATRIX.md`, the two catalog records, the
pointer and the registry row. Branch B touches `WearSectionIcons.kt`, `SystemInfoScreen.kt` (the glyph slot of
`SectionDisclosure`), six drawables, `tokens.json`, `IDENTITY.md`, PM-041, the pointer and the registry row.

Scope statement (CLAUDE.md section 4, S0021): the user-visible change is on the watch only; the phone group headers
already carry a glyph on all 24 groups, so the phone gets nothing and the matrix row PM-041 is updated in the same
step as the watch change.

Deliberately unchanged: the phone group glyph table, the vocabulary files of the catalog, the restricted build's three
`notShipped` glyphs, and the help pages (they draw no pictures).

Inventory against ICON-RENDER 0.25 rule 1 (the first step of this ticket; static reading, 2026-11-14; no device run):

| Surface | Sibling set | Members that draw a glyph | Verdict |
| --- | --- | --- | --- |
| Phone, System information top bar | the visible actions: copy, save, share, help (`always`), collapse-all (`ifRoom`) | 5 of 5 | conforms |
| Phone, System information overflow popup | notifications (`never`), plus collapse-all when it does not fit | the popup draws none: nothing forces optional icons, so the AppCompat popup shows titles only (rule 2) | conforms by the platform; device observation open |
| Phone, help viewer menu | one item, open on the site (`menu_help.xml`, no glyph, reason in its comment) | 0 of 1 | conforms |
| Phone, System information group headers | the 24 groups (`SystemInfoGroupIcons`) | 24 of 24 | conforms (S0031) |
| Phone, header help button (`csh_iconHelp`) | not a sibling: a hidden control inside a header | not applicable | out of the rule |
| Phone, field rows, search bar, dialogs, snackbar, main screen | rows with label and value; dialogs are a message with buttons (BUTTONS decides them); no picker, list dialog or sheet exists | none draws | conforms (a set without glyphs) |
| Help pages (en, ru, uk) | HTML pages with no image or SVG (`Grep` of `<img|<svg|<picture` over `site/help`: 0 matches) | none | conforms |
| Watch, System information section headers | nine sections and the Help row, all drawn by `SectionDisclosure` | 6 of 10 (App, Sensors, Memory, Storage, Wi-Fi, Phone) | **mixed** |
| Watch, the two action buttons | Refresh, Send to phone (`WearActionButton` takes a mandatory icon) | 2 of 2 | conforms |
| Watch, field rows | label and value rows | none draws | conforms |

The Help row is a finding the audit of S0031 did not make: it sits in the same list and is drawn by the same
composable as the section headers, so it is a seventh member without a glyph, not a bystander.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

1. **Answered, owner, 2026-11-14:** which treatment the watch System information section headers keep - a glyph on every
   header or on none. Answer: a glyph on all ten headers (branch A of section 2); see `### Quiz decisions (2026-11-14)`
   in section 3.3. The researched recommendation and the alternative are in the question block of section 3.3.
2. Answered by research, pass of 2026-11-14: does `system.notification-shade` fit the phone's "Turn on notifications"
   item? No. Its record means "pull down the notification shade" (a gesture action, shape: arrow down from a bar);
   the item asks Android to allow notifications or opens their settings. Reusing that glyph for another meaning is
   what ICON-SET forbids. And the question no longer needs an answer: the item sits in a popup that draws no pictures
   (assumed decision 1 below).

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0031 (found the two sets); S0022 (the owner's decision that the watch headers carry the phone's
  glyphs, `### Quiz decisions (2026-11-13)`); S0007 (device run, the open observations of this ticket); S0021 (PM-041).

### Questions (v1, 2026-11-14) - answered 2026-11-14

- Q: Which treatment do the watch System information section headers keep - a glyph on every header, or no glyph on any?
  - A glyph on all ten headers: nine sections plus the Help row (recommended) - keeps the S0022 decision that the watch carries the phone's glyphs; Device takes the proposed `device.watch` (the `ic_watch` drawing already exists upstream), Help takes `app.help`, and Health and Environment need two new vocabulary meanings that this repository files as `proposed` records beside its existing proposal, with two new drawings that only a device run can judge
  - No glyph on any header - local change only, nothing is filed in the catalog; the six watch glyph drawables are deleted, PM-041's watch cell becomes `not offered: owner-declined`, and it reverses the S0022 decision that the two apps look alike on the headers

### Quiz decisions (2026-11-14)

- Which treatment do the watch System information section headers keep -> a glyph on all ten headers: the nine sections plus the Help row (recommended answer, chosen by the owner; it keeps the S0022 decision that the watch carries the phone's glyphs, and no standing rule contradicts it). Branch A of section 2 is the one to implement: Device takes the proposed `device.watch`, Help takes `app.help`, Health and Environment get two `proposed` meanings filed in the catalog's `PROPOSAL-2026-11-14-deviceinfo-system-info-meanings.md` and two new drawings. The criteria of branch B are void.

### Assumed (unattended, 2026-11-14)

- **The phone notifications item keeps no glyph.** Taken: the item lives in the overflow popup, which draws titles only, so the popup is a sibling set without glyphs (ICON-RENDER 0.25 section 25 rule 2) and the item conforms as it is; a comment in `menu_system_info.xml` records why. Alternative: file a `proposed` meaning for "notifications on" under ICON-SET section 15 and draw a glyph that the popup would never show; or reuse `system.notification-shade`, which means "pull down the notification shade" and so breaks one-glyph-one-meaning. Why this one: a glyph on an item that is never drawn is dead weight, and the recommendation of the ticket (reuse a meaning if one fits) is answered by research - none fits. Owner may overrule.
- **The pointer, the register and the product's own registry row are narrowed now, not at closure.** Taken: the three records say the watch headers are the one open set and the phone overflow menu conforms; the row still reads `partial 0.25`. Alternative: leave the three records until the watch part closes. Why this one: the old text names a defect that does not exist and a task ("the phone item gets a meaning") that the ticket no longer plans. Owner may overrule.
- **The Help row counts as a member of the watch header set.** Taken: it is drawn by `SectionDisclosure` in the same list, so both branches of the owner's question are written for ten headers, not nine. Alternative: treat it as a separate entry, which would leave nine headers and the Help row glyph-less under a glyph-on-all branch. Why this one: the rule counts the items a user sees together, and the row is made to look like a header (its own KDoc says so). Owner may overrule.
- **The device observation of the popup stays in this ticket for the S0007 run, and S0007 is not edited.** Taken: S0007 is another ticket with work in progress; this ticket names the check below and the final report names it again. Alternative: add the line to S0007 now. Owner may overrule.

### Assumed (unattended, 2026-11-14, second pass - the watch build after the owner's answer)

- **Environment draws a leaf.** Taken: `system.environment`, shape "a leaf on its stem with the midrib cut out", drawn for
  this product (the vocabulary has no ambient-sensor meaning: `weather.*` and `feature.dewpoint` are single weather
  readings). Alternative: a thermometer or a sun over a cloud, both closer to weather than to three ambient sensors
  (light, pressure, magnetic field), or a sensor-wave mark, which `feature.live-broadcast` already owns. Risk recorded in
  the proposal: a leaf is also Android's eco-mode picture; the title beside it says "Environment". Owner may overrule.
- **Health draws a pulse trace and means the device's condition.** Taken: `system.health`, a pulse trace; the section
  lists thermal state, battery readings, uptime and the last exit of the app (the ru and uk titles read "Состояние" and
  "Стан", a condition, not medicine). Alternative: a medical cross, which reads as first aid or as `action.add`. Owner may
  overrule.
- **Both new drawings are the product's own, judged on a preview render only.** Taken: one filled silhouette each
  (`M L C Z`, inside the catalog's SVG subset), rendered at 24 px and 16 px from the path data with WPF (nonzero fill) and
  looked at; the pulse outline was computed from a centre line with bevel joins. Alternative: copy Material paths from
  memory, which cannot be verified here. The device look stays an open S0007 check.
- **`ic_watch` is a byte copy of the reference product's drawable, with a ledger row.** Taken:
  `record-port.ps1` row 97 of `docs/port-ledger.jsonl` (the file is outside the port scope, so no scope decision is
  needed); the vocabulary record `source.watch` already names `ic_watch` as the watch app's drawable and the proposal item
  3 says `device.watch` shares that picture. Alternative: redraw the watch, which would break "one meaning, one drawing".
  Owner may overrule.
- **The watch `ic_help_outline` carries the phone's path data and no tint attribute.** Taken: the phone file's
  `android:tint="?attr/colorControlNormal"` needs a theme attribute the watch app does not define; `check-tokens.ps1`
  compares path data only (`phoneSameDrawing`). Alternative: copy the file whole, which would fail to inflate on the watch.
- **`WearSectionIcons.iconFor` keeps its nullable return.** Taken: an unmapped title draws no glyph instead of crashing the
  diagnostics screen, and the static check (`headerTitles` in `check-tokens.ps1`, self-tested) fails the gate first.
  Alternative: a non-null lookup that throws on an unknown title. Owner may overrule.
- **`SystemInfoScreen.kt` is re-pinned as a `candidate` under RP-0003.** Taken: only its KDoc changed in this ticket, the
  last classification of that file was already `candidate` RP-0003, and the glyph table is a DeviceInfo file. Alternative:
  classify `deliberate` with the KDoc excerpt, which would drop the S0023 review from the current bytes.
- **The registry cell reads `-`, not `0.25`.** Taken: the `partial 0.25` claim is withdrawn because the source conforms,
  while no implementation or verification claim is advanced (verification stays `pending`; the rendered headers are an open
  device check). Alternative: `0.25` in the Implements cell, which would claim more than a static check proves.
- **Status `Implemented`, not `BlockNeedUserTest`.** Taken: the S0022 precedent (the same glyph table, the device
  observation carried by S0007) and no probe line has to be added and later removed. Alternative: `BlockNeedUserTest`
  with a `Timber.d("S0035: ..")` probe at the header composable. Owner may overrule.

## 4. Pass record (2026-11-14, unattended)

Evidence, each run in this pass:

1. `Grep` of `setOptionalIconsVisible|MenuBuilder|forceShowIcon|overflowIcon|actionOverflow|popupMenuStyle` over `phone/src` and the phone resource folders: expected no match | actual no match. `StandardToolbar` extends `MaterialToolbar` and overrides nothing of the popup.
2. `pwsh -NoProfile -File tools/contracts/check-pointers.ps1`: exit 0, `20 pointer(s) checked, 2 skipped, 0 mismatch(es)`, 0.38 s.
3. `pwsh -NoProfile -File tools/design/check-tokens.ps1`: exit 0, `146 check(s) equal, 0 mismatch(es)`, 0.43 s (no token, drawable or table row changed).
4. `pwsh -NoProfile -File tools/docs/check-docs.ps1`: exit 0, `PASS WITH ADVISORIES` (the one known advisory, store graphics), 1.37 s.
5. The catalog registry row of ICON-RENDER for this product reads one open set (the watch headers) and the phone popup as conforming; `docs/contracts/ICONOGRAPHY.md` and `docs/contracts/README.md` say the same.

Compile gate: `commands.compileCheck` is absent from `.sza-profile.json`, so the repo declares no compile command. The only edited resource is one XML comment in `menu_system_info.xml`; the note is "no compile command, not built, not tested until the release".

Open manual checks (MANUAL, owner, with the S0007 device run; none is claimed as passed):

- Phone, notifications off: open the overflow popup of System information; expect titles only, no glyph on any entry, and "Collapse all" among them when the bar has no room for it.
- Watch, after the owner's answer is built: open System information; expect every header to start at the same indent, with or without a glyph on all of them.

RELEASE items: none new beyond the build and tests of the release flow (`.\gradlew.bat :phone:assembleDebug :wear:assembleDebug`); the watch change, when it lands, is compiled-not-tested until then.

Parked: none. Filed: none.

### Second pass (2026-11-14, unattended): the watch build after the owner's answer (branch A)

Built: `WearSectionIcons` maps all ten header titles (Device `ic_watch`, App `ic_apps`, Health `ic_sysinfo_health`, Sensors
`ic_compass`, Environment `ic_sysinfo_environment`, Memory, Storage, Wi-Fi, Phone, Help `ic_help_outline`); four vector
drawables added in `wear/src/main/res/drawable` (`ic_watch`, `ic_help_outline`, `ic_sysinfo_health`,
`ic_sysinfo_environment`); `docs/design/tokens.json` gains a `watchOnly` table and loses `provisionalExtra` and the
`wearGap` of the DEVICE row; `tools/design/check-tokens.ps1` reads `watchOnly` and fails on a header title the watch draws
with no glyph; its self-test gains three expectations; the catalog proposal file gains items 4 and 5 and a usage row; the
catalog registry row, the pointer `docs/contracts/ICONOGRAPHY.md` and the register `docs/contracts/README.md` no longer
read `partial 0.25`; `docs/design/IDENTITY.md` section 5, PM-041 and the S0022 note of `docs/PARITY_MATRIX.md`, the
`CHANGELOG.md` entry and the figures in `CLAUDE.md` section 6 follow. Scope statement: the watch only; the phone is
unchanged (24 of 24 groups carry a glyph), recorded against PM-041.

Evidence, each run in this pass:

1. Before the proposal was filed, `pwsh -NoProfile -File tools/design/check-tokens.ps1`: expected exactly the two missing
   proposal names | actual exit 1, `161 check(s) equal, 2 mismatch(es)`: `the proposal does not name 'system.health'` and
   `.. 'system.environment'`. After filing it: exit 0, `163 check(s) equal, 0 mismatch(es)`, 0.27 s.
2. `pwsh -NoProfile -File tools/design/test-check-tokens.ps1`: exit 0, `9 expectation(s), 0 failed`, 4.2 s (the three new
   ones: a removed `watchOnly` row, a proposal that lacks an id, a meaning absent from the vocabulary).
3. The header-title scan of the check, repeated by hand over `wear/src/main/kotlin`: expected 10 titles, all keys of
   `WearSectionIcons` | actual 10 (`system_info_help_title` and nine `system_info_section_*`), all mapped.
4. The four new drawables parse as XML (`[xml]` load): root `vector`, paths 2, 1, 1, 1. A WPF preview of the path data
   (a scratch PNG in the ticket's gitignored temp folder, not committed) shows a watch, a pulse trace, a leaf with a midrib
   and stem, and the question mark.
5. `pwsh -NoProfile -File tools/parity/check-matrix.ps1`: exit 0, 42 rows. `pwsh -NoProfile -File
   tools/contracts/check-pointers.ps1`: exit 0, `20 pointer(s) checked, 2 skipped, 0 mismatch(es)`. `pwsh -NoProfile -File
   tools/docs/check-surfaces.ps1`: exit 0 (no string key changed; the watch headers already had all nine titles and the
   help title).
6. `pwsh -NoProfile -File tools/port-ledger/check-scope.ps1`: exit 0, `376 ported, 19 decided`, 0 new, 0 stale.
   `pwsh -NoProfile -File tools/port-ledger/check-local-divergence.ps1 -RequireClassified`: exit 0, 9 local edits, 0
   unclassified (after re-pinning `SystemInfoScreen.kt`, whose KDoc this ticket changed).
7. `pwsh -NoProfile -File tools/port-ledger/check-drift.ps1`: exit 1, `UNCARRIED: 1 of 105`, the row of
   `CollapsibleSectionHeader.kt`. Not caused by this ticket (a phone file this ticket did not touch; the new `ic_watch` row
   is in step). Tracked: S0039 (carry or decide that drift). Named here so it cannot hide a regression.

Compile gate: `commands.compileCheck` is absent from `.sza-profile.json`, so the repository declares no compile command.
Compiled source was edited (`WearSectionIcons.kt`, a KDoc in `SystemInfoScreen.kt`, four vector resources): the note is "no
compile command, not built, not tested until the release". The `R.drawable` names exist as files and are the only symbols the
Kotlin change uses.

Open manual checks (MANUAL, owner, with the S0007 device run; none is claimed as passed):

- Watch, System information: every one of the ten headers (nine sections and the Help row) shows a glyph and starts at the
  same indent; each glyph is legible at 16 dp on the black glass, the pulse trace and the leaf included (the look of the two
  new drawings is the owner's judgment; the leaf may read as an eco mode, see the proposal note).
- The phone popup check of the first pass stays open.

RELEASE items: `.\gradlew.bat :wear:assembleDebug` (the new resources and the map), `.\gradlew.bat :wear:testDebugUnitTest`,
and the fast gates at the release start (`check-tokens.ps1`, `check-local-divergence.ps1 -RequireClassified`,
`check-pointers.ps1`, `check-docs.ps1`).

Parked: none (the drift of S0039 was already filed). Filed: none.
