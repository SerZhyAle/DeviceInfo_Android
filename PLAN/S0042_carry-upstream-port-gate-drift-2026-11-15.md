# S0042_carry-upstream-port-gate-drift-2026-11-15

**Status:** Implemented
**Status note:** Carried: watch SystemInfoScreen.kt (CHIP_GAP 8 dp, bold open title, -Refresh), phone CollapsibleSectionHeader.kt pinned -Decide (focus forwarding not carried), three help pages re-pinned. check-drift exit 0, check-scope exit 0, check-local-divergence -RequireClassified exit 0. Compiled, not tested: compileCheck BUILD SUCCESSFUL in 16s; tests and watch layout on device are RELEASE items (S0007). Unblocks S0014.
**Created:** 2026-11-15
**Complexity:** medium - assessed at the spec pass 2026-11-15: two drifted files and three stale help-page decisions; three upstream diffs read against the local S0010/S0023/S0035 edits, one two-line source carry on the watch (compiled) and a contract check (COLLAPSIBLE-GROUP, BUTTONS); the S0013 and S0039 pattern with a code edit

## 0. Owner request (verbatim)

Found by the S0014 pass (first Google Play publication), 2026-11-15, agent finding, not the owner's words.

Two release-start gates of docs/RELEASE.md step 1 exit 1 because FastMediaSorter_mob_v2 (the upstream checkout, read-only from here) changed in-scope files since the port baseline. Fresh runs at 2026-11-15:

1. pwsh -NoProfile -File tools/port-ledger/check-drift.ps1 -> exit 1:
   DRIFT app_v2/src/main/java/com/sza/fastmediasorter/ui/common/widget/CollapsibleSectionHeader.kt -> phone/src/main/kotlin/com/sza/deviceinfo/ui/common/widget/CollapsibleSectionHeader.kt (anchored on 2026-11-14, the S0039 carry)
   DRIFT wear/src/main/java/com/sza/fastmediasorter/wear/ui/apps/systeminfo/SystemInfoScreen.kt -> wear/src/main/kotlin/com/sza/deviceinfo/wear/ui/apps/systeminfo/SystemInfoScreen.kt (anchored on 2026-11-11)
   UNCARRIED: 2 of 105 row(s) need a carry (record-port.ps1 -Refresh) or a decision (record-port.ps1 -Decide).

2. pwsh -NoProfile -File tools/port-ledger/check-scope.ps1 -> exit 1, three STALE DECISION rows (the upstream help pages changed after the not-port decision was recorded):
   app_v2/src/main/assets/help/en/system-info.html
   app_v2/src/main/assets/help/ru/system-info.html
   app_v2/src/main/assets/help/uk/system-info.html
   OPEN: 3 in-scope upstream item(s) need a port (record-port.ps1) or a decision (record-decision.ps1).

Facts read: the upstream checkout is clean and its newest commits are 09d4972c8 (2026-11-15) and ef06f1177 (2026-11-14); git log of the wear SystemInfoScreen.kt shows 09d4972c8 as its newest. Dedup by symptom: S0013 and S0039 are earlier carries of other drift (three collectors; the same CollapsibleSectionHeader.kt at the 2026-11-14 baseline), both Implemented, so this is a new upstream edit, not their regression. Every other release-start fast gate exited 0 in the same pass (validate, release-queue -Validate, check-local-divergence -RequireClassified, check-surfaces, check-docs, store-assets -Check, check-matrix, check-tokens, check-pointers, both UI sizing checks, payload parity, version parity, help-map, landing -Check, compliance with 0 errors).

Needed: read each upstream diff, decide per behaviour carry (record-port.ps1 -Refresh) versus pinned decision (record-port.ps1 -Decide), keep the local S0010/S0023/S0035 behaviour that the local-divergence check classifies, re-decide or port the three help pages (S0024 owns the help pages of this product: the not-port decision may stand with a refreshed upstream hash), and re-run both gates to exit 0. S0014 criterion 4 (the release run) cannot start until both exit 0.


## 1. Problem

FastMediaSorter changed its System Info group header on the phone, its System Info screen on the watch and the footer of
its System Info help pages after DeviceInfo copied them, so the two release-start gates that watch the copy exit non-zero
and the first Google Play publication (S0014, criterion 4) cannot start. Each upstream change has to be read and either
carried into DeviceInfo or declined with a recorded reason, keeping what DeviceInfo deliberately does differently.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- `pwsh -NoProfile -File tools/port-ledger/check-drift.ps1` exits 0 (observed 2026-11-15 after the records, see Last Audit; before: exit 1, 2 of 105 uncarried).
- `pwsh -NoProfile -File tools/port-ledger/check-scope.ps1` exits 0 (observed 2026-11-15; before: exit 1, 3 STALE DECISION rows).
- The watch row carries `sourceSha256` equal to the SHA-256 of the current upstream file (`04d3d000..`) and `carriedOn` 2026-11-15; the phone header row carries a decision pinned to `2f3e784d..`; the three help rows are re-pinned to the current upstream hashes with a note that names the real reason.
- `pwsh -NoProfile -File tools/port-ledger/check-local-divergence.ps1 -RequireClassified` exits 0: the edited watch file is classified (hash `badc551f..`).
- The two upstream behaviours that the watch lacked are in the port: 8 dp between sibling group headers and between the two action buttons (COLLAPSIBLE-GROUP 1.2 section 3 rule 6, BUTTONS gap token), and a bold open-group title (COLLAPSIBLE-GROUP section 3 rule 1, `docs/design/IDENTITY.md` section 3: the phone's open header is 16 sp bold).
- The declared compile check passes (`commands.compileCheck` of `.sza-profile.json`, run once): exit 0, `:wear:compileDebugKotlin` executed.
- RELEASE: unit tests and the watch layout on a device or emulator are not run by this ticket (above 5 s or needing a device); see Last Audit.

## 3. Approach

### 3.1 Scope

Scope (S0021): **watch** for the source edit; the phone gets no source change. A one-sided change records why the other side does not get it, stated against `docs/PARITY_MATRIX.md`: the phone's open header title is already 16 sp bold (`view_collapsible_section_header.xml`, `IDENTITY.md` section 3), and the phone lays collapsed headers out with its own span packing (`SystemInfoHeaderPacking`), not with a 4 dp chip gap. The edit is a spacing and weight token inside a row the matrix already covers, so no `docs/PARITY_MATRIX.md` row changes; `check-matrix.ps1` is not run for it.

What the upstream commit `09d4972c8` (2026-11-15) contains for the three watched items, read 2026-11-15 against the local code:

**Watch `SystemInfoScreen.kt`** (upstream blob `f158976b`, sha256 `04d3d000..`, 129 changed lines; the S4628 and S4632 header rework):

| Upstream hunk | Port today | Disposition |
| --- | --- | --- |
| State marker leads the caption, filled triangle, down open, toward the reading end closed, left in RTL (`GroupStateMarker`, `markerPath`) | `SectionDisclosure` draws the same triangle with the same corner fractions and the RTL branch (S0023) | Already present |
| 8 dp between marker and caption (`HEADER_MARKER_GAP`), marker 16 dp | `DISCLOSURE_MARKER_GAP` 8 dp, `DISCLOSURE_MARKER_SIZE` 16 dp | Already present |
| One `clickable(role = Role.Button)` over the whole row, at least the 48 dp target high and wide, padding inside the target, caption wraps (`Box` to `Row`, `maxLines` dropped, `TextAlign.Start`) | one `clickable(role = Role.Button)`, `sizeIn` of the declared 48 dp resource, padding after the clickable, `Row`, no `maxLines` | Already present |
| `CHIP_GAP` 4 dp to 8 dp (sibling groups; the chip cloud) | 4 dp, and the same constant spaces the Refresh and Send buttons (BUTTONS: button and wrapped-row gap 8) | **Carried**: `CHIP_GAP = 8.dp`; the one constant brings the chip cloud and the action flow to the contract's 8 |
| Open title `title3` with `FontWeight.Bold` (the contract asks for a type treatment distinct from body text, such as a stronger weight) | `title3`, regular | **Carried**: bold on the open branch only; the collapsed header stays `caption2` like the upstream's chip; matches the phone's 16 sp bold and `IDENTITY.md` section 3 |
| `SECTION_TOP_PADDING`, `SECTION_TITLE_BOTTOM_PADDING` removed | the port never held them | Nothing to do |
| `Timber.d("S4628 ..")`, `Timber.d("S4632 ..")` | not present | Not carried: status-bound probes of FMS_A's own tickets (they exist there while those tickets await a device test); a probe tagged with another repository's ticket id would be a stray in this product |
| `GridColumnFit.DEFAULT_MIN_TARGET_DP` for the 48 dp floor, `contentDescription = "$title. $hint"` | the declared dimension `system_info_touch_target_min`, `stateDescription` (S0023) | Kept: local choices already classified (RP-0003) |
| Title colour and a group glyph | on-surface title and the glyph before it (S0022) | Kept: classified `deliberate` in `docs/local-divergence-decisions.jsonl` |

Disposition: `record-port.ps1 -Refresh`. The behaviours the upstream added are present in the port, two of them since this pass; what the port does otherwise is classified. The destination changed, so the new bytes were classified first with `record-local-decision.ps1` (`candidate`, RP-0003, hash `badc551f..`), the way S0035 did for the same file; the note says the two carried values are a carry, not a candidate.

**Phone `CollapsibleSectionHeader.kt`** (upstream sha256 `2f3e784d..`; the carried baseline was the uncommitted state of 2026-11-14, `edb3a8bf..`, S0039):

| Upstream hunk | Port today | Disposition |
| --- | --- | --- |
| `onRtlPropertiesChanged` re-applies the chevron; rotation read from `CollapsibleMarker.rotation(expanded, layoutDirection)` | the same behaviour with the angles inline (S0039); `CollapsibleMarker.kt` is a new upstream file outside `docs/port-scope.json`, and its `apply` and `describe` serve the launcher and tiles | Behaviour present, the object is not mirrored (values `0`, `-90`, `+90` are identical; checked against the file text) |
| `forwardNextFocusIds()` in the constructor, `setHeaderNextFocusUpId`, `setHeaderNextFocusDownId`: D-pad next-focus ids set on the widget reach the focusable inner row | nothing in `phone/src` sets a next-focus id on a header (grep over Kotlin and XML, 0 hits) and nothing would call the setters; the upstream's only caller is its Streams screen | **Not carried**: it would be dead code (dead-weight rule); port it with its first caller |
| Test `CollapsibleSectionHeaderTest` gains two RTL tests | the port holds no test for this file | Outside the scope and a release-tier run; the RTL chevron stays an S0007 device check |

Disposition: `record-port.ps1 -Decide` pinned to `2f3e784d..` (a `-Refresh` would say the focus forwarding is carried, which it is not). The destination is unchanged.

**Help pages `system-info.html`, en, ru, uk** (upstream blob diff, one line each): the footer span `Fast Media Sorter, 2026-10-26` became `Fast Media Sorter, 2026-11-14`; nothing in the page body changed. DeviceInfo's help is its own set, `tools/help/source/system-info.json` and `watch-system-info.json` rendered by `render-help.ps1` (S0024), so the upstream pages are not ported by design. The three decisions were re-pinned (`record-decision.ps1`, the documented recovery from STALE DECISION) with that reason; the old note ("not ported yet .. S0024 decides") was stale since S0024.

What deliberately did not change: the phone source, strings in any module, `docs/port-scope.json` (a scope that grows to hold `CollapsibleMarker.kt` would turn it into a NEW SOURCE decision of its own, with no consumer here), the help sources, the CHANGELOG (no new behaviour or metric: the sentence about the shared section header holds for both sides, the whole watch UI is unreleased) and the landing, listing and Data safety surfaces (`docs/DOCS_SURFACES.md`: no string, permission, behaviour or metric changed).

### Assumed (unattended, 2026-11-15)

- **Carry `CHIP_GAP` 8 dp and the bold open title in code, then `-Refresh`.** Alternative: `-Decide` the whole watch file with a note and change no source. Taken because both values are written in the catalog contracts the product consumes (COLLAPSIBLE-GROUP section 3 rules 1 and 6, BUTTONS gap token) and the port was off them, the cost is two lines and one compile, and the S0039 reasoning for `-Refresh` (carry what is missing, then the row is true) applies once the code is carried. Owner may overrule.
- **`-Decide` for the phone header, not `-Refresh`.** Alternative: port the focus forwarding and the two setters so the next diff is smaller. Taken because it has no caller or XML attribute here, so it would add unused public API (dead-weight rule) and a new classification and compile for nothing observable. Owner may overrule.
- **Bold only on the open branch.** Alternative: bold on the collapsed header too. Taken because the upstream's own collapsed chip stays regular weight and the identity table gives the collapsed header `caption2`. Owner may overrule.
- **Help pages stay "not ported", re-pinned.** Alternative: port the footer date. Taken because the pages are product-authored (S0024) and the footer names another product. Owner may overrule.
- **Classification `candidate` (RP-0003) for the new bytes.** Alternative: `not-applicable` for the carry. Taken because a classification covers the whole current file and the S0023 edits in it still wait for the RP-0003 review (the S0035 precedent). Owner may overrule.
- **Complexity stays `medium`.** Alternative: `light`. Kept because the pass contained a carry-versus-decision call per file, a contract check and a compiled edit.

### 3.2 Open questions

None. Every point above was answered by reading the three upstream diffs, the local code, the two catalog contracts and the identity table.

### 3.3 Owner inputs (Approval gate)

None.

- **Related tickets:** none (S0014 waits on this one, recorded by the status tool below; S0007 owns the watch layout and RTL device checks; RP-0003 keeps the S0023 review of the same file. These are mentions, not blockers.)

## Last Audit

**Date:** 26-11-15 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 9 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 2

Checks, each run on 2026-11-15 in this pass:

- PASS - `tools/port-ledger/check-drift.ps1` after the records: `OK: nothing uncarried (104 in step, 1 decided)`. expected: exit 0 | actual: exit 0 (before: exit 1, `UNCARRIED: 2 of 105`).
- PASS - `tools/port-ledger/check-scope.ps1`: `OK: every in-scope upstream item is ported or decided (376 ported, 19 decided)`. expected: exit 0 | actual: exit 0 (before: exit 1, 3 STALE DECISION rows, `OPEN: 3`).
- PASS - ledger rows: watch row `sourceSha256` `04d3d000..` equals the hash of the current upstream file, `carriedOn` 2026-11-15, `destinationSha256` `badc551f..`; phone header row `decision.sourceSha256` `2f3e784d..`, destination hash unchanged `fbf7766e..`; the three help decisions re-pinned 2026-11-15. expected: all | actual: all.
- PASS - `tools/port-ledger/check-local-divergence.ps1 -RequireClassified`: `OK: every local edit is classified` (8 local edits, 0 unclassified; the watch file was the one unclassified edit before `record-local-decision.ps1`). expected: exit 0 | actual: exit 0.
- PASS - the carried values are on declaration lines of the watch file: `private val CHIP_GAP = 8.dp` (line 95), `import androidx.compose.ui.text.font.FontWeight` (46), `title3.copy(fontWeight = FontWeight.Bold)` on the open branch (584). expected: 3 hits | actual: 3 hits.
- PASS - compile gate (S0040), `commands.compileCheck` through `.\a.ps1 fc` under the Build lock, once, foreground: `BUILD SUCCESSFUL in 16s`, 61 actionable tasks, 22 executed (`:wear:compileDebugKotlin` among them). expected: exit 0 | actual: exit 0. The only compiler warning is the deprecated `FEATURE_TELEVISION` in `PlatformDetailsCollector.kt`, not part of this diff. Compiled, not tested.
- PASS - fast gates touched by the edited files: `check-tokens.ps1` (IDENTITY.md row edited) `OK - 163 check(s) equal, 0 mismatch(es)`; `check-help-captures.ps1` `NOT HELD` exit 0 (no record exists, as before); `WearUiSizingResources.java` `OK`. expected: exit 0 each | actual: exit 0 each.
- PASS - `tools/docs/check-docs.ps1`: `docs-check: PASS (30 records, 95 corpus files, ...0 baselined)`; `spec_catalog/validate` (10 OK, 0 WARN, 0 FAIL) and `spec_catalog/release-queue -Validate` (`OK - 43 ticket(s), no drift`). expected: exit 0 each | actual: exit 0 each.
- PASS - probe invariant: no `S0042` line under `phone/src` or `wear/src`, and the ticket is not in the needs-manual-test status. expected: 0 hits | actual: 0 hits.
- EXEMPT - user-facing surfaces, parity matrix rows, CHANGELOG, landing, listing: no string, permission, behaviour or metric changed; the watch edit is a spacing and weight token (scope statement and reasons in 3.1).
- EXEMPT - phone source and `check-matrix.ps1`: the phone side has no source edit and no matrix row changed.
- RELEASE - unit tests of the changed watch file: `.\gradlew.bat :wear:testDebugUnitTest` and the phone suite `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest`; both above 5 s, not run here.
- RELEASE - the watch layout with 8 dp gaps and the bold open title on a 192 dp and a 240 dp round screen, and the RTL chevron of the phone header, on a device or emulator (S0007): the gates and the code reading prove the ledger, the values and the compile, not a rendered screen. Not run here.

### Action items
1. none for this ticket. Seen while reading, not part of the three watched items and not a gate failure: the upstream phone test `CollapsibleSectionHeaderTest` gained two RTL tests that the port has no counterpart of (the test file is outside `docs/port-scope.json`); the RTL chevron stays an S0007 device check and no ticket was drafted.

### Manual / on-target
- none for this ticket; the two device scenarios above stay with S0007.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0014 | was: Draft | since: 2026-11-15 | released: 2026-11-15 -> Draft
