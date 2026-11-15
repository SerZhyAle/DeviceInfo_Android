# S0040_bugfix-help-capture-recipe-interface-size

**Status:** Implemented
**Created:** 2026-11-14
**Complexity:** light, confirmed at the spec pass 2026-11-14 - four existing files, one new locator kind in the capture tool, no compiled source, no device. The rung is the complex pipeline, not the primitive one: four changed files exceed the primitive limit of three (spec-to-audit Stage 0).

## 0. Owner request (verbatim)

Found by S0027 (target-state acceptance), 2026-11-14 15:16, agent finding, not the owner's words.

S0023 added the element `interface-size` to the help sources of both pages (`tools/help/source/system-info.json` line 14, `tools/help/source/watch-system-info.json` line 12) and the help map row of the phone page. `tools/help/capture-recipes.json` (S0032) has no locator for the watch element, so the fast-tier commands of CLAUDE.md section 6 for the capture tooling are red:

- `pwsh -NoProfile -File tools/help/capture-help.ps1 -DryRun` exits 1: "incomplete: page 'watch-system-info' element 'interface-size' has no locator (no recipe entry and no view in the help map)" / "capture-help: FAIL dry run (1 recipe problem(s))".
- `pwsh -NoProfile -File tools/help/test-help-captures.ps1` exits 1: "FAIL (5 of 62 expectations did not hold)". The five: "every shown part has a pin linked to its entry, in marker order, and the absent ones have none", "the Russian page carries the Russian words and the same pins", "the watch page has one plain image (the watch has one theme) and the screen caption", "the dry run plans both pages and touches no device", "a real run without a device serial is refused before any device is touched". It also ran 6.25 s on 2026-11-14 against the 4.8 s recorded in CLAUDE.md section 6.
- `tools/help/check-help-captures.ps1` still exits 0 ("NOT HELD", no record yet), and `check-help-map.ps1` and `render-help.ps1 -Check` pass, so the pages themselves are consistent; only the capture recipe and its self-test fixtures lag the new element.

Needed: give the watch element `interface-size` a locator in the recipe (or record why it has none), bring the self-test fixtures in step with the added element on both pages, re-run the dry run and the self-test to exit 0, and update the measured time in CLAUDE.md section 6.


## 1. Problem

The help screenshot tooling cannot find the watch's interface size button. S0023 added the interface size element to both help pages, but the capture recipe gives the watch copy of it no way to be located on the watch screen. The capture dry run therefore refuses the recipe, and the capture self-test fails five of its 62 expectations, because its fixtures still describe both pages as they were before that element existed. The pages, the help map and the phone element are consistent; only the capture path that will photograph them lags behind them.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- [x] **C1** `pwsh -NoProfile -File tools/help/capture-help.ps1 -DryRun` exits 0; its last line is `capture-help: DRY RUN ok (2 page(s), 3 locale(s); no device touched)`; the watch element line names a locator.
- [x] **C2** The new locator kind matches the watch button text in en, ru and uk, and refuses the text of another locale. Proof: a direct call of the changed functions, and two self-test expectations (run under C5).
- [x] **C3** `pwsh -NoProfile -File tools/help/check-help-captures.ps1` exits 0 with `NOT HELD` (no capture record is committed yet).
- [x] **C4** The two edited PowerShell files parse with no syntax error (the PowerShell parser reports 0 errors for each).
- [ ] **C5** `pwsh -NoProfile -File tools/help/test-help-captures.ps1` exits 0 with `PASS (64 expectations)`. RELEASE item: the tool measured 6.25 s on 2026-11-14 (S0027), above the 5 s tier, so it is not run between releases.
- [x] **C6** `pwsh -NoProfile -File tools/docs/check-docs.ps1` exits 0 after the CLAUDE.md edit (its last stdout line is the verdict line).
- [x] **C7** CLAUDE.md section 6 states 64 expectations and the measured time with its date. The time is S0027's 6.25 s; the release run re-measures it.
- [ ] **C8** RELEASE item: the device run of the capture (`pwsh -NoProfile -File tools/help/capture-help.ps1 -PhoneSerial <serial> -WearSerial <serial> -ProductVersion <versionName>`, docs/RELEASE.md step 3a) locates the watch button on a watch emulator in each locale, or records it absent for the baseline.

## 3. Approach

### 3.1 Scope

In scope, four files: (a) one locator kind in the capture tool's locator set that matches the text of a UI string carrying one number; (b) the watch recipe's locator for `interface-size`, using that kind; (c) the self-test fixtures of both pages and two expectations for the new kind; (d) the expectation count and measured time in CLAUDE.md section 6. The self-test's header comment, which says the test stays under the 5 s tier, is corrected in the same edit (its measured time is now known to be above it).

Out of scope: any phone or watch UI change (no content description is added to the watch button); the help pages, the help map and the page sources; a capture record or an absent baseline (only the device run writes them, release tier); the phone recipe (its locator already resolves through the map).

Deliberately not done: a recipe entry that says "no locator" for the watch element. The capture tool has no such form; adding one is a larger change than this bug, and the element is locatable by its text.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

- **Which locator form reads the watch button?** Answered. `textRef` matches a whole string and cannot match `Interface size: 100 %`, because the string carries the number as `%1$d`. `descPattern` reads the content description, which the watch button does not set. `textRefPrefix` returns the same format string. A `textPattern` with a locale-neutral regex would match any "label: N %" row. Chosen: a `textRefFormat` kind that reads the string of the locale and turns `%1$d` and `%%` into a pattern (see Assumed).
- **Is the watch button a clickable node with its text in the device dump?** Not verifiable without a device. Answered as a release item (C8): the device run decides it; if the node is not found, the element is recorded absent and the baseline takes it.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** none

### 3.4 Plan (complex rung, plan pass 2026-11-14)

Coverage inventory: C1 maps to steps 1 and 2; C2 to steps 1 and 3; C3 to step 2 (the gate is unchanged, run as is); C4 to steps 1 to 3; C5 to step 3 (the run itself is a release item); C6 and C7 to step 4; C8 is a release item. Constraint "no UI change" maps to no step, because no step edits `phone/` or `wear/`. Constraint "nothing above 5 s between releases" maps to the two release items and to the direct calls that stand in for the self-test.

Topology: step 1 produces the locator kind `textRefFormat`; step 2 consumes it in the recipe; step 3 consumes the kind (the new expectations) and the recipe (the dry-run expectation); step 4 consumes the expectation count of step 3. No step consumes what a later step produces.

Steps, each with its static predicate:
1. `tools/help/_capture.ps1`: the kind `textRefFormat` joins the header list and the switch of `Resolve-Locator`. It reads the string of the locale, escapes it, turns `%1$d` into `\d+` and `%%` into `%`, anchors it, and stores it in a `TextPattern` key of the resolved hashtable (default `$null`). `Find-UiNode` matches a node whose trimmed text matches it. Predicate: `Select-String` finds `textRefFormat` and `TextPattern` in the file, and the parser accepts the file (C4).
2. `tools/help/capture-recipes.json`: the watch `locate` gains `"interface-size": { "by": "textRefFormat", "value": "system_info_interface_scale", "clickable": true }`, between `row` and `help-row`. Predicate: the JSON parses; the dry run exits 0 (C1); the gate exits 0 (C3).
3. `tools/help/test-help-captures.ps1`: the dump gains node index 7 (text `Interface size: 100 %`, clickable, bounds `[0,800][1000,900]`); its node count becomes 9; two expectations are added after the `textRef` one (the English text matches at y 800; the Russian pattern does not match it); the phone pins become 9 in en and ru (11 elements, 2 absent); the watch pins become 5 (6 elements, 1 absent); the header comment is corrected. Predicate: `^Assert-That ` lines count 64; the parser accepts the file (C4).
4. CLAUDE.md section 6: the self-test entry gives 6.25 s (S0027, 2026-11-14) and 64 expectations. Predicate: the entry contains `64 expectations`; `check-docs.ps1` exits 0 (C6, C7).

### Assumed (unattended, 2026-11-14)

- **Locator form for the watch button.** Taken: a `textRefFormat` kind, which reads the string of the locale, so the pattern is correct in en, ru and uk. Alternatives weighed: a `textPattern` with the locale-neutral regex `^[^:]+: \d+ %$`, which could pick another "label: N %" row; a recipe entry that says "no locator", which the tool has no form for. Owner may overrule.
- **Self-test time.** Taken: CLAUDE.md records the 6.25 s that S0027 measured on 2026-11-14, in place of the older 4.8 s, and this pass does not run the self-test again, because that run is above the 5 s tier. Alternative: keep the 4.8 s figure. Owner may overrule.
- **Status after the pass.** Taken: Implemented. The self-test (C5) and the device run (C8) are release items, so the static audit scores Verified with RELEASE items open, and the status moves to Verified at the release run. Alternative: Verified now, which would claim the self-test without running it. Owner may overrule.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14 | released: 2026-11-14 -> Draft
- Blocks: S0027 | was: Draft | since: 2026-11-14

## Last Audit

**Date:** 26-11-14 16:24 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 6 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 0 | RELEASE 2

Static pass after the edits of the four files (`tools/help/_capture.ps1`, `tools/help/capture-recipes.json`, `tools/help/test-help-captures.ps1`, `CLAUDE.md`). No compiled source was edited, so the compile gate was not triggered and no compile command was run.

### Checks

- PASS C1 `pwsh -NoProfile -File tools/help/capture-help.ps1 -DryRun`: exit 0; `capture-help: DRY RUN ok (2 page(s), 3 locale(s); no device touched)`; the watch line reads `element interface-size: textRefFormat system_info_interface_scale`.
- PASS C2 `pwsh -NoProfile -File PLAN/S0040_bugfix-help-capture-recipe-interface-size/attachments/direct-check.ps1` (scratch, not committed): exit 0, `direct-check: PASS (6 checks)`. The en, ru and uk texts match at their own rows; en refuses the Russian text and a text without a number; uk refuses the English text. The en pattern is `^Interface\ size:\ \d+\ %$`.
- PASS C3 `pwsh -NoProfile -File tools/help/check-help-captures.ps1`: exit 0, `help-captures: NOT HELD (no capture record; 9 image(s) are owed by the device run ...)`.
- PASS C4 PowerShell parser: 0 errors in `_capture.ps1` and in `test-help-captures.ps1`; `capture-recipes.json` parses; 64 `^Assert-That ` lines in the self-test (was 62).
- PASS C6 `pwsh -NoProfile -File tools/docs/check-docs.ps1`: exit 0, `docs-check: PASS (30 records, 91 corpus files, 75 Markdown, 7 links, 18 asset citations, 0 baselined)`.
- PASS C7 CLAUDE.md section 6 names `64 expectations`, `6.25 s` (S0027, 2026-11-14) and `textRefFormat`.
- RELEASE C5 `pwsh -NoProfile -File tools/help/test-help-captures.ps1`: expected exit 0 and `test-help-captures: PASS (64 expectations)`. Not run in this pass: the tool measured 6.25 s on 2026-11-14, above the 5 s tier. The release run re-measures it and writes the time into CLAUDE.md section 6.
- RELEASE C8 device run `pwsh -NoProfile -File tools/help/capture-help.ps1 -PhoneSerial <serial> -WearSerial <serial> -ProductVersion <versionName>` (docs/RELEASE.md step 3a). Not run: no device in this pass.

### Action items

None open in scope. The fixture arithmetic (phone 11 elements, 2 absent, 9 pins; watch 6 elements, 1 absent, 5 pins; 9 dump nodes) is checked by reading the test file against the page sources, not by running the self-test (see C5).

### Manual / on-target

- [ ] None open. C8 is a release item: the watch button is located in each locale on a watch emulator, or recorded absent for the baseline.

Probe invariant: holds. No probe line was added; the ticket is not in the needs-manual-test status.
