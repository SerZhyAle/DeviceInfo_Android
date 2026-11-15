# S0044_bugfix-contract-pointers-stale-2026-11-15

**Status:** Verified
**Created:** 2026-11-15
**Complexity:** light - two pointer files, the register, one conformance-record line and two rows of the catalog registry; no compiled source; confirmed at the plan pass, the two bumps are a clarification and an additive step that change nothing in either app

## 0. Owner request (verbatim)

Noticed by the S0014 resume pass on 2026-11-15 (agent-noticed finding, not an owner order).

`pwsh -NoProfile -File tools/contracts/check-pointers.ps1` exits 1 at the release-start gate list of docs/RELEASE.md step 1 (it exited 0 with "20 pointers, 0 mismatches" at the S0014 pass of the same day, before the catalog moved):

  FAIL ICONOGRAPHY.md: ICON-SET version 0.40 != catalog 0.41 (read 2026-11-14)
  FAIL UNIFIED-UI.md: COLLAPSIBLE-GROUP version 1.2 != catalog 1.3 (read 2026-11-13)
  check-pointers: MISMATCH - 18 pointer(s) checked, 2 skipped, 2 mismatch(es)

Both bumps are catalog decisions of 2026-11-15 on proposals, not edits of this repository:
- ICON-SET 0.40 -> 0.41: accepts this product's own PROPOSAL-2026-11-14-deviceinfo-system-info-meanings (README section 27, items A to H; the five meanings enter as `proposed`).
- COLLAPSIBLE-GROUP 1.2 -> 1.3: clarification, section 8 items B and C (the group headings of one page draw a leading topic glyph on every heading or on none, ICON-RENDER section 25; the state triangle is not that glyph and is drawn on every heading).

Needed: re-read both contracts at the new versions, update docs/contracts/ICONOGRAPHY.md and docs/contracts/UNIFIED-UI.md (version read, read date, version-step lines), update the registry reading of the two adoption rows, check whether the 0.41 wording and the 1.3 items change the phone or watch group headings (docs/design/tokens.json, tools/design/check-tokens.ps1, docs/PARITY_MATRIX.md), and re-run check-pointers to exit 0. Same shape as S0016 and S0031 (both closed); this is the third stale-pointer round - consider whether the release start should re-read pointers automatically.

S0014 (first Google Play publication) waits on this ticket: its release run needs every fast gate at exit 0.


## 1. Problem

The product's pointers to two shared contracts were a version behind the catalog: `ICON-SET` read 0.40 (the catalog is at 0.41) and `COLLAPSIBLE-GROUP` read 1.2 (the catalog is at 1.3). The pointer check failed on both and the release-start gate list was red, which stops the first Google Play publication. The pass re-reads the two amendments (`ICON-SET` section 27, `COLLAPSIBLE-GROUP` section 8), checks them against the phone and the watch, and moves the pointers, the register and the product's own catalog registry rows together. It also answers the owner's side question: whether the release start should re-read pointers by itself.

## 2. Done criteria

- `pwsh -NoProfile -File tools/contracts/check-pointers.ps1` exits 0: `ICON-SET` reads 0.41 and `COLLAPSIBLE-GROUP` reads 1.3, read date 2026-11-15, no mismatch.
- `pwsh -NoProfile -File tools/design/check-tokens.ps1` exits 0 (163 checks): the 0.41 wording changes no glyph mapping.
- The two registry rows of this product in the catalog (`ICON-SET`, `COLLAPSIBLE-GROUP`) read 0.41 and 1.3 with the same finding as the pointers; the `ICON-RENDER` row is untouched because its version did not move.
- The register `docs/contracts/README.md` carries the same reads, the accepted proposal and the open step.
- `pwsh -NoProfile -File tools/docs/check-docs.ps1`, `tools/parity/check-matrix.ps1`, `spec_catalog/validate` and `spec_catalog/release-queue -Validate` exit 0.
- The one follow-up that the amendment creates (the `provisional` to `meaning` switch of five token entries, possible only after the vocabulary carrier reads 0.41) is a Draft with a trigger, S0045, and is not claimed here.

## 3. Approach

### 3.1 Scope

Changes: `docs/contracts/ICONOGRAPHY.md` and `docs/contracts/UNIFIED-UI.md` (version read, read date, the version-step finding), `docs/contracts/README.md` (two register rows, the state of the accepted proposal, one accepted companion proposal, the open step), one line of `docs/UI_CONFORMANCE.md` (the contract it is read against), the product's own two rows in the catalog registry (`_meta/REGISTRY.md`; the registry's rule is that a project session edits its own rows and nothing else), this ticket, and the new Draft S0045.

Deliberately unchanged: every phone and wear source, resource, drawable, string and token (the re-read finds nothing to change); `docs/design/tokens.json` (the five `provisional` entries stay until the vocabulary carrier reads 0.41, S0045); `docs/PARITY_MATRIX.md` (PM-038 and PM-041 stay `offered` on both sides); the `ICON-RENDER` row and pointer (0.25 did not move); the catalog's vocabulary, glyph files and the contract texts themselves (the entry of the five records is the exporter owner's owed step); historical tickets, which keep the reads they were written with.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

None open. Answered in this pass (2026-11-15):

1. Does `COLLAPSIBLE-GROUP` 1.3 item B change a header of either app? No. The phone header draws the state triangle, then the topic glyph, then the title, and `SystemInfoGroupIcons` maps all 24 `SystemInfoGroup` values to a glyph, so the set is uniform. The watch's `SectionDisclosure` draws the marker, the glyph and the title on all ten headers (nine report sections and the Help row, `WearSectionIcons`; S0035). Item C adds nothing to decide: a header and its rows are two sets, and the state triangle stays outside the vocabulary. The rendered order is an open check of S0007.
2. Does `ICON-SET` 0.41 change the glyph mapping, the tokens or a string? No. The five records carry the ids the tokens already use. The path data of `ic_sysinfo_hardware`, `ic_sysinfo_memory` (the phone's and the watch's equal), `ic_sysinfo_health` and `ic_sysinfo_environment` is found verbatim in the proposal the records come from, and `device.watch` references the existing `ic_watch`. The catalog's two corrections (`system.memory` shares its drawing with `feature.raw-probe`; `device.watch` is named Wear OS watch because `source.watch` owns the proposed names) change no file here; the watch section is titled "Device", a topic title that rung 3 does not read.
3. Does `check-tokens.ps1` still pass? Yes, 163 checks. It will fail by design once the vocabulary carrier enters the five records (it demands `meaning` in place of `provisional`); that is S0045, a Draft that waits for the carrier to read 0.41, so nothing is red because of it today.
4. Should the release start re-read pointers automatically? Answered under Assumed below: the detection already runs at the release start and in the fast pass; the read itself stays a person's act.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0016 and S0031 (the two earlier stale-pointer rounds, closed); S0014 (waits on this ticket, released by the status tool when this one moves); S0045 (successor, a mention and not a blocker); S0035 (the ten-member watch header set that item B is read against); S0007 (the device run that owns the rendered order).

### Assumed (unattended, 2026-11-15)

- **No automatic pointer re-read at the release start.** Taken: the existing detection stays the gate - `check-pointers.ps1` runs in `tools/check-fast.ps1` (`contract-pointers`) and in step 1 of `docs/RELEASE.md`, and caught both bumps the day they landed; the read itself (what the amendment asks of the product) stays a person's act and is recorded in the pointer. Alternative: let the check print the catalog's document-log rows between the read version and the current one (a cheaper re-read), or rewrite the version cell by script. Why this one: a script that bumps a pointer turns "what was read" into a false statement, and the digest is a tool improvement, not a bugfix of this pointer. The third round is the catalog moving between sessions, which no local rule can stop. Owner may overrule.
- **The product's own two catalog rows written from this session.** The registry's rule lets a project session edit its own rows; S0031 did the same. The proposal's decision says the `ICON-SET` row moves "in the canon's record of the round"; if the canon session also writes it, the values converge. Alternative: leave the catalog untouched and hand both rows to the catalog session. Owner may overrule.
- **Status Verified.** Every done criterion is proven by a command run in this pass, and no manual item belongs to this ticket; the rendered order of triangle, glyph and title stays with S0007 and is not claimed. Alternative: Implemented, leaving the verdict to a re-audit. Owner may overrule.
- **`ICON-RENDER` left alone.** Its version stayed 0.25 (section 27 states it), so its pointer line, register row and catalog row keep the S0031 and S0035 text. Alternative: touch the row to say "re-confirmed 2026-11-15". Owner may overrule.

## Last Audit

**Date:** 26-11-15 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 9 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 0

Compile gate: no compiled source was edited (Markdown, the register and the catalog registry only), so `commands.compileCheck` of `.sza-profile.json` was not run; nothing compiled changed.

Checks, run in this pass:

1. PASS - `pwsh -NoProfile -File tools/contracts/check-pointers.ps1`: exit 0, `20 pointer(s) checked, 2 skipped, 0 mismatch(es)`; `ICON-SET 0.41 == catalog 0.41` and `COLLAPSIBLE-GROUP 1.3 == catalog 1.3`, read 2026-11-15 (before the pass: exit 1, the two FAIL lines of section 0).
2. PASS - `pwsh -NoProfile -File tools/design/check-tokens.ps1`: exit 0, `163 check(s) equal, 0 mismatch(es)`, vocabulary section checked.
3. PASS - `pwsh -NoProfile -File tools/docs/check-docs.ps1`: exit 0, `PASS (30 records, 97 corpus files, 79 Markdown, 7 links, 18 asset citations, 0 baselined)`.
4. PASS - `pwsh -NoProfile -File tools/parity/check-matrix.ps1`: exit 0, 42 rows, every planned cell names an open ticket (PM-038 and PM-041 stay `offered` on both sides).
5. PASS - `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate`: exit 0, `10 OK, 0 WARN, 0 FAIL`; `spec_catalog/release-queue -Validate`: exit 0, `OK - 45 ticket(s), no drift`.
6. PASS - the catalog registry rows of this product read `COLLAPSIBLE-GROUP` 1.3 and `ICON-SET` 0.41 (a grep of `_meta/REGISTRY.md`), and `ICON-RENDER` still 0.25; no stale `ICON-SET 0.40` or `COLLAPSIBLE-GROUP 1.2` read remains in the three contract files except the dated version-step lines that record the earlier reads.
7. PASS - the tree against `COLLAPSIBLE-GROUP` 1.3 item B: `SystemInfoGroupIcons` maps 24 groups against 24 `SystemInfoGroup` values; the phone header layout orders `csh_chevron`, `csh_icon`, `csh_title`; the watch `SectionDisclosure` draws marker, glyph and title for the nine sections and for `WearHelpEntry` (`WearSectionIcons` maps `system_info_help_title`).
8. PASS - the path data of `ic_sysinfo_hardware`, `ic_sysinfo_memory`, `ic_sysinfo_health` and `ic_sysinfo_environment` is found verbatim in the catalog proposal behind `ICON-SET` 0.41 (four of four string searches), and the phone's and the watch's `ic_sysinfo_memory` path data are equal.
9. PASS - probe invariant: no `S0044` string in `phone/src` or `wear/src` (the ticket changed no code and hosts no probe).

Exempt, with reason:

1. EXEMPT - the rendered order and spacing of triangle, glyph and title on a phone and a watch, and `ICON-SET` section 6 rung 3 on rendered screens: needs a device or an emulator run; owned by S0007, not claimed here.
2. EXEMPT - the entry of the five records in the catalog's vocabulary carrier (still 0.40): the exporter owner's step in the catalog, not a duty of this repository; the product-side consequence is the Draft S0045, which waits for the carrier to read 0.41.

### Action items

1. None blocking. S0045 (Draft) switches the five `provisional` token entries to `meaning` once the vocabulary carrier reads 0.41.

### Manual / on-target

- None owned by this ticket. The rendered checks above stay with S0007.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0014 | was: Draft | since: 2026-11-15 | released: 2026-11-15 -> Draft
