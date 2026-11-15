# S0043_bugfix-wear-ru-main-title-clipped-on-round-screen

**Status:** BlockNeedUserTest
**Status note:** Compiled (.\a.ps1 fc exit 0, BUILD SUCCESSFUL in 11s); not run on a device. The human must observe on the Wear_OS_Large_Round emulator (454 px), in ru, uk and en, and on the 192 dp profile: the main System information title is whole on the screen, wraps to at most two lines and is not clipped at either edge. Logcat line S0043: wear system info title lines= gives the count. Build first with DEVICEINFO_TIER=Release and .\a.ps1 wd (release tier).
**Created:** 2026-11-15
**Complexity:** light - one watch title on a round screen in three languages; the fix is a string or layout edit, the proof is an emulator look

## 0. Owner request (verbatim)

Found by S0029 (play-owner-prep-keystore-screenshots, Action items 2, 2026-11-15) and parked here by the S0014 pass, agent finding, not the owner's words.

On the watch's main System information screen the Russian title "Сведения о системе" is clipped at both edges on a round 454 px display (Wear_OS_Large_Round emulator, app locale ru). S0029's own text: "the clipping is a UI defect for a follow-up ticket, not changed here (no source edits in this ticket)". As a result the first Wear OS screenshot of every listing language is the group overview without the title.

Dedup by symptom (2026-11-15): grep of PLAN/ for "clipp" finds only S0007 item (the S0024 watch Help row text fitting a round 192 dp screen in ru and uk, a device check not yet run), S0022 (large-text clipping of the wider watch chips, noted as a manual check) and S0029's action item. No ticket owns the title of the main screen, so this is new.

Needed: reproduce on the round emulator in ru (and check uk and en and the 192 dp profile), fix the title so it fits a round screen in all three languages (shorter string key text, a smaller or wrapping title, or the round-screen inset), keep the string keys in en, ru and uk in one edit (CLAUDE.md section 7), update docs/PARITY_MATRIX.md rows if behaviour differs, and retake the three Wear OS listing screenshots if the title then belongs in them. Scope: wear only (the phone title is not clipped); the matrix row is the watch System information screen.


## 1. Problem

On the watch's main System information screen the title is clipped at both edges on a round 454 px display. The clipping is seen in Russian on the Wear_OS_Large_Round emulator (S0029); the Ukrainian and English titles and the 192 dp profile are still to be looked at. The title is one full-width line at the top of the list, where the round edge is closest, so the text runs past the visible circle on both sides. As a result the first Wear OS screenshot of every listing language shows the group overview without its title. The defect was found by S0029 and parked here by the S0014 pass as an agent finding, not as the owner's words; the owner's request is in section 0. The phone title is not clipped and is out of scope.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

1. **Compile gate (run in this pass).** `.\a.ps1 fc` (the declared `commands.compileCheck`, under the Build lock) exits 0 and prints `BUILD SUCCESSFUL` after the last source edit. The result is written into the `## Last Audit` block of this file.
2. **No string change.** The ticket edits no line of `wear/src/main/res/values*/strings_systeminfo.xml`; the key `system_info_title` keeps its three texts. Checked by reading the change at audit.
3. **Catalog gate of the touched spec.** `pwsh -NoProfile -File tools/docs/check-docs.ps1` exits 0 and its last stdout line is the verdict line. Other gates of the fast tier (`check-tokens`, `check-surfaces`, `check-help-map`) are not run: no glyph, string, help text or surface changes.
4. **RELEASE - the round-screen look.** Build the watch debug APK and install it on the Wear_OS_Large_Round emulator (454 px) in en, ru and uk, and on the 192 dp profile. Expected: the main title is whole on the screen, wraps to at most two lines, and is not clipped at either edge; the logcat line `S0043: wear system info title lines=` gives the line count. Command: `$env:DEVICEINFO_TIER='Release'; .\a.ps1 wd` (builds and copies the debug APK to Drive), then the install and the look. Not run in this pass: a debug build is a release-tier run (over 5 s).
5. **RELEASE - the listing screenshots.** If the title then belongs in the three Wear OS listing screenshots (S0029, owner step 3), they are retaken after item 4 passes. This is an owner console step after the fix, not a blocker of it.
6. **Matrix.** `docs/PARITY_MATRIX.md` is not edited, because no row describes the title (section 3.1).

## 3. Approach

### 3.1 Scope

Wear only. Changed: the main title item of the watch's System information screen gets a horizontal inset, so its wrapped lines stay inside the round screen, and one status-bound probe (`S0043:`) logs the title's line count. The probe exists only while the ticket is in BlockNeedUserTest and is removed when it leaves that status.

Deliberately not changed: the three title texts and the string key (a shorter text is a wording decision and stays with the owner); the title style; the group headers, the Help row and the other watch screens. The phone side gets no change: the phone title is not clipped (S0029), so the one-sided scope is recorded here against `docs/PARITY_MATRIX.md`, and no row of that matrix describes the title. The function set on both sides is the same before and after.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

None open. The inset value is an assumption recorded below; the round-screen look (Done criterion 4) is the check that settles it, not a question for the owner.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0029 (found the defect; mention only), S0014 (parked the ticket here; mention only), S0007 (the device checks of this product; mention only). None of them blocks this ticket: there is no `Blocker:` token.

### Assumed (unattended, 2026-11-15)

- **Fix form: a horizontal inset on the title.** Taken over (a) a shorter title text in the three locales - refused, the wording is the owner's call; (b) a smaller title style (title3 or caption) - refused, it changes the header typography of this screen in all three locales; (c) the toolkit's list header component - not taken, its geometry in wear-compose 1.4.1 is not verified here and it changes the text style. Owner may overrule.
- **Inset value 12 dp on each side.** An estimate, not a measurement: on a 192 dp round display a line about 30 dp below the top edge has a chord of about 139 dp, and a 12 dp inset leaves about 115 dp for wrapped lines. The toolkit's edge scaling and the real line position are unmeasured. Alternative: 16 dp (more margin, narrower lines). The round-screen look decides; owner may overrule the value.
- **Status BlockNeedUserTest, not Implemented.** The round-screen look is an open on-target signal, and the canon keeps a ticket with one open at BlockNeedUserTest or Partial. Alternative: Implemented with the note "compiled, not tested". Owner may overrule.

## Last Audit

**Date:** 26-11-15 01:29 | **Mode:** pre-handoff | **Outcome:** Partial
**Counts:** PASS 6 | WARN 0 | FAIL 0 | MANUAL 1 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 2

Written by the pass itself, without `/spec-check`: the device test needs the probe, and `/spec-check` would remove it (S2324).

Evidence, each run fresh in this pass (expected | actual):

1. Compile gate: `.\a.ps1 fc` (the declared `commands.compileCheck`, through `tools/build/run-gradle.ps1` under the Build lock), run once after the last source edit | exit 0, `BUILD SUCCESSFUL in 11s`, `61 actionable tasks: 2 executed, 59 up-to-date`; the executed tasks include `:wear:compileDebugKotlin`, which compiles the edited file. PASS.
2. Probe invariant: `tools/harness.ps1 spec_catalog/check-probe-present -Id S0043` | exit 0, `Probe present: wear\src\main\kotlin\com\sza\deviceinfo\wear\ui\apps\systeminfo\SystemInfoScreen.kt:187 (1 in all, each alone on its line)`. PASS.
3. Scope of the edit: `SystemInfoScreen.kt` only - one inset constant, one horizontal padding on the title, one `onTextLayout` probe. No string key, layout file or matrix row is changed. Checked by reading the change. PASS.
4. Strings: the three `strings_systeminfo.xml` files are not edited by this ticket (Done criterion 2). PASS.
5. Wear UI sizing resources: `java wear/src/test/java/com/sza/deviceinfo/wear/ui/WearUiSizingResources.java` | exit 0, `Wear UI sizing resource: OK`. PASS.
6. Documentation gate: `pwsh -NoProfile -File tools/docs/check-docs.ps1` | exit 0, last line `docs-check: PASS (30 records, 96 corpus files, 78 Markdown, 7 links, 18 asset citations, 0 baselined)`. PASS.
7. Contract boundary: no shared format, wire shape or algorithm is touched; `docs/contracts/` is not edited. EXEMPT.
8. Persona pass: no user-facing text is changed; the visible result is the title's position, judged in item 1 of the manual list. EXEMPT.
9. Build and install of the watch debug APK and the emulator look: not run in this pass, a release-tier run (over 5 s). RELEASE.
10. Listing screenshots of the three Wear OS locales: retaken only after item 9 passes, an owner console step. RELEASE.

### Action items

None for the code. The fix waits for the on-target check below.

### Manual / on-target

- [ ] Round-screen look on the Wear_OS_Large_Round emulator (454 px) in ru, uk and en, and on the 192 dp profile: the main System information title is whole on the screen, wraps to at most two lines, and is not clipped at either edge. The logcat line `S0043: wear system info title lines=` gives the line count. Pass means all four looks clean; then the probe is removed (`spec_catalog/check-probe-absent`) and the ticket leaves BlockNeedUserTest. Run it as `$env:DEVICEINFO_TIER='Release'; .\a.ps1 wd`, then install the APK on the emulator. Not run in this pass.
