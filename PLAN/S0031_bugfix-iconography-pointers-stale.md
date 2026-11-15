# S0031_bugfix-iconography-pointers-stale

**Status:** Verified
**Created:** 2026-11-14
**Complexity:** light - two pointer versions and two registry rows; the amendments expose two mixed glyph sets, parked as S0035 and not fixed here

## 0. Owner request (verbatim)

Agent finding (not the owner's words), found during S0023 on 2026-11-14: tools/contracts/check-pointers.ps1 exits 1 because docs/contracts/ICONOGRAPHY.md reads ICON-SET 0.39 and ICON-RENDER 0.24 while the catalog is now at ICON-SET 0.40 and ICON-RENDER 0.25 (catalog read 2026-11-14). The pointer belongs to S0022 and S0025. Re-read the two amendments in the catalog, check whether the product's glyph mapping, tokens and registry rows still hold against them, then update the pointer versions and its read date, and run check-pointers and check-tokens. Evidence: "FAIL ICONOGRAPHY.md: ICON-SET version 0.39 != catalog 0.40 (read 2026-11-14)" and "FAIL ICONOGRAPHY.md: ICON-RENDER version 0.24 != catalog 0.25". Not fixed in S0023 because it is outside its scope.


## 1. Problem

The product's pointer to the shared iconography contracts reads ICON-SET 0.39 and ICON-RENDER 0.24, while the catalog is at 0.40 and 0.25. The pointer check fails on both, and the product's registry rows carry the same stale reads. The pass re-reads the two amendments of 2026-11-14 (ICON-SET section 26, ICON-RENDER section 25), checks the glyph mapping, the identity tokens and the registry rows against them, and moves the pointer and the rows to the catalog's versions. The re-read also finds what a version bump alone would hide: ICON-RENDER 0.25 rule 1 requires a sibling set to draw a glyph on every member or on none, and two sets of this product do not - the watch System information section headers and the phone System information overflow menu. The honest state is therefore `partial 0.25`, and the migration is parked as S0035.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- `pwsh -NoProfile -File tools/contracts/check-pointers.ps1` exits 0: ICON-SET reads 0.40 and ICON-RENDER reads 0.25, read date 2026-11-14 (run in this pass; exit and output cited in the Last Audit block).
- `pwsh -NoProfile -File tools/design/check-tokens.ps1` exits 0 against the 0.40 vocabulary (146 checks, 0 mismatches).
- The two registry rows of this product in the catalog read the same versions; the ICON-RENDER row reads `partial 0.25` with a dated migration plan that names S0035.
- The register in `docs/contracts/README.md` carries the same reads and the same open gap.
- `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` exits 0 with this ticket and S0035 in the ledger.
- The gap stays open and owned: S0035 is a Draft that names both mixed sets. Nothing here claims rule 1 is met.

## 3. Approach

### 3.1 Scope

Changes: `docs/contracts/ICONOGRAPHY.md` (the two versions, the read date, the rule 25 finding), `docs/contracts/README.md` (the two register rows), the product's own two rows in the catalog registry (`_meta/REGISTRY.md`; the registry rules let a product write its own rows), and this ticket.

Deliberately unchanged: any phone or wear source, resource, drawable, menu or string (the two mixed sets are S0035); the vocabulary, the glyph files and the proposal of the catalog owner; the rendered-contrast check (S0007); the historical tickets, which keep the 0.39 and 0.24 reads they were written with.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

None open. Answered in this pass (2026-11-14):

1. Does ICON-SET 0.40 change the product's glyph mapping? No. Its six meanings are `proposed` and none is mapped here; `check-tokens.ps1` still resolves every mapped meaning against the 0.40 vocabulary, with its Android reference equal to the drawable.
2. Does ICON-RENDER 0.25 change the product's state? Yes, for two sets (rule 1). The registry row records it as `partial 0.25` (rule 6), with the migration plan.
3. Is any product code changed by this ticket? No.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0022 and S0025 (declared the pointer and the rows with the stale reads); S0023 and S0024 (found the drift and left it to this ticket); S0035 (successor: the migration of the two mixed sets, a mention and not a blocker).

### Assumed (unattended, 2026-11-14)

- **Mixed sets recorded as `partial 0.25`, not fixed here.** Taken: the pointer and the registry row state the truth and the two sets move to S0035. Alternative: fix them now - draw a glyph on all nine watch headers (two new meanings are needed for Health and Environment too, so a proposal under ICON-SET section 15 comes first), or remove the six watch glyphs (ICON-RENDER 0.25 rule 4), and give the phone menu item a meaning. Why this one: the watch choice is a product design call that rule 4 leaves open, and the fix touches compiled phone and wear code, outside a pointer ticket. Owner may overrule.
- **Registry cells as `partial 0.25` in Implements and `0.25` in Reads.** This is the register's form for a partial consumer (the CONTEXT-HELP rows of CyrFlip and FastMediaSorter Lite). Alternative: keep Implements at `-` and state the partial only in Notes. Owner may overrule.
- **The product's own two catalog rows written from this session.** The registry rules let a product write its own rows. Alternative: leave the catalog untouched and hand the rows to the catalog session. Owner may overrule.
- **Status Verified.** Every done criterion is proven by a command run in this pass, and no manual item belongs to this ticket; the rendered-contrast check stays with S0007 and is not claimed. Alternative: Implemented, leaving the verdict to a re-audit. Owner may overrule.

## Last Audit

**Date:** 26-11-14 03:40 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 7 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 3 | RELEASE 0

Compile gate: `commands.compileCheck` is absent from `.sza-profile.json`, so the repo declares no compile command. No compiled source was edited (markdown, the register and the ledger only); the note is "no compile command".

Checks, run in this pass:

1. PASS - `pwsh -NoProfile -File tools/contracts/check-pointers.ps1`: exit 0, `19 pointer(s) checked, 2 skipped, 0 mismatch(es)`; `ICON-SET 0.40 == catalog 0.40`, `ICON-RENDER 0.25 == catalog 0.25` (read 2026-11-14).
2. PASS - `pwsh -NoProfile -File tools/design/check-tokens.ps1`: exit 0, `146 check(s) equal, 0 mismatch(es)`, vocabulary section checked.
3. PASS - `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate`: exit 0, `10 OK, 0 WARN, 0 FAIL`.
4. PASS - `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/release-queue -Validate`: exit 0, `OK - 35 ticket(s), no drift`.
5. PASS - the six meanings ICON-SET 0.40 adds (`view.compact`, `app.animations`, `app.units`, `media.visualizer`, `view.full-resolution`, `view.halo`) have zero hits in `docs/design/tokens.json`.
6. PASS - phone group headers: `SystemInfoGroupIcons` maps all 24 `SystemInfoGroup` values, and `GatherSystemInfoUseCase` gives every phone section a group.
7. PASS - no stale `0.39` or `0.24` ICON read remains in `docs/contracts/ICONOGRAPHY.md` or `docs/contracts/README.md`; the two catalog registry rows of this product read `0.40` and `0.25` (`partial 0.25` in Implements for ICON-RENDER).

Exempt, with reason:

1. EXEMPT - ICON-RENDER 0.25 rule 1 on the watch System information section headers (App, Memory, Storage, Wi-Fi, Phone and Sensors have a glyph; Device, Health and Environment have none; `WearSectionIcons`). A product-conformance gap, recorded as `partial 0.25`; the fix is S0035, not this pointer ticket.
2. EXEMPT - the same rule on the phone System information overflow menu (`action_system_info_notifications` has no `android:icon` beside `action_system_info_expand_collapse`, which has one; `menu_system_info.xml`). Recorded as `partial 0.25`; the fix is S0035.
3. EXEMPT - ICON-RENDER section 3 rule 3 (contrast on rendered screens) and ICON-SET section 6 rung 3 (labels against glyphs). Needs a device or emulator run; owned by S0007, not claimed here.

### Action items

1. None blocking. S0035 (Draft) carries the two mixed sets; the owner's choice for the watch headers is its first question.

### Manual / on-target

- None owned by this ticket. The rendered checks of the exemptions above stay with S0007.
