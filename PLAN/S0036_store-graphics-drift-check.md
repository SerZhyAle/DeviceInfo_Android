# S0036_store-graphics-drift-check

**Status:** Verified
**Created:** 2026-11-14
**Complexity:** light in substance (one generator gains a check mode, one self-test, six documents); by the primitive test the rung is complex, because six existing files and one new file change and the primitive limit is three existing files and no new file. The open question (are the PNG bytes stable enough to compare) was closed by a measurement at this pass, section 4.1

## 0. Owner request (verbatim)

Agent-noticed finding (S0034 pass, 2026-11-14), not the owner's words.

DOC-INTERNAL-QUALITY rule 4 (generated documentation does not drift) has one open gap in this product: docs/play/icon-512.png and docs/play/feature-graphic-1024x500.png (and the landing's social card site/assets/social-card-1200x630.png) are render targets of tools/store/render-store-assets.ps1, a generator with no drift check. The registry record store-graphics in docs/DOCUMENT_REGISTRY.jsonl says so in its check field ("none yet"), and tools/docs/check-docs.ps1 prints it as an advisory, so every run ends in PASS WITH ADVISORIES until a check exists.

Wanted, for the ticket's own pass to settle: whether a PNG written by System.Drawing is byte-stable enough across machines and .NET versions to compare by hash (if not, compare the pixel data or the inputs: the glyph source and the size table), then a -Check mode of render-store-assets.ps1 that exits non-zero while the committed files differ from what the generator writes, its entry in CLAUDE.md section 6 and docs/RELEASE.md, and the check field of the store-graphics record. Evidence: the advisory line of tools/docs/check-docs.ps1; docs/contracts/DOC-INTERNAL-QUALITY.md rule 4.

## 1. Problem

The listing graphics of the store and the link-preview card of the landing are rendered by one generator, and nothing compares the committed picture files with what that generator writes today. A change of the launcher glyph, a colour or a size that is not followed by a re-render would leave the old pictures in place, and every gate of the repository would still pass. This is the one open gap of the documentation rule about generated files in this product, and every documentation gate run names it as an advisory until a check exists.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat.

1. The check passes on the committed tree: `pwsh -NoProfile -File tools/store/render-store-assets.ps1 -Check` exits 0, and its last stdout line is `store-graphics-check: PASS (4 targets, pixels equal to the render)`.
2. The check catches drift: `pwsh -NoProfile -File tools/store/test-render-store-assets.ps1` exits 0 with `0 FAIL`; its cases are one pixel altered (exit 1, the file named), one target missing (exit 1, named) and one target that is not a PNG (exit 1, named).
3. The write path did not change: a default render into a scratch root writes four files whose SHA-256 equal the committed files (recorded on this machine, section 4.4).
4. The documentation gate has no advisory: `pwsh -NoProfile -File tools/docs/check-docs.ps1` exits 0 and its verdict line is `docs-check: PASS (...)`, with no `ADVISORY` line.
5. The records say the same: the `store-graphics` record of `docs/DOCUMENT_REGISTRY.jsonl` has a `check` field that does not begin with `none`; `CLAUDE.md` sections 5 and 6 and `docs/RELEASE.md` step 1 name the check with its exit codes; the rule 4 text of `docs/contracts/DOC-INTERNAL-QUALITY.md` and the register row of `docs/contracts/README.md` state the gap closed.
6. The pointers and the registry are valid: `pwsh -NoProfile -File tools/contracts/check-pointers.ps1` exits 0, and `pwsh -NoProfile -File tools/harness.ps1 document_registry/validate` exits 0.
7. The compile gate: no compiled source is edited (PowerShell, Markdown and JSON only), and `commands.compileCheck` is absent from `.sza-profile.json`, so the note says "no compile command".
8. No device claim: the release-tier run of the check (`docs/RELEASE.md` step 1) is listed as a release item, not as a pass.

## 3. Approach

### 3.1 Scope

In: the generator gains a `-Check` switch; a self-test beside it; the `store-graphics` registry record; `CLAUDE.md` section 5 (one sentence on rule 4) and section 6 (the command); `docs/RELEASE.md` step 1; the rule 4 text of the pointer `docs/contracts/DOC-INTERNAL-QUALITY.md` and its register row in `docs/contracts/README.md`, state text only.

Out, deliberately: the glyph, the colours, the layout and the four PNG files (not re-rendered; the check proves they are current); the catalog's dated exception row for `DOC-INTERNAL-QUALITY` (a row of the shared catalog, narrowed by the owner's order at the next catalog sync, section 4.5); the `ё` and code-comment halves of rule 5; the landing and help checks, which already exist.

### 3.2 Open questions

- **Q1, is the PNG byte-stable enough to compare by hash:** answered in section 4.1 by a measurement on this machine. The bytes are equal across runs and against the committed files; other Windows builds and other machines are not measured, so the check compares decoded pixels (Assumed 1).
- **Q2, self-test as a committed script or as scratch evidence only:** answered by the repository's convention, every check of `tools/` has a committed self-test (Assumed 2).

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** none

### Assumed (unattended, 2026-11-14)

1. **Pixel comparison, not a hash of the PNG file.** Taken: the check decodes the committed file and a fresh render with the same decoder and compares the 32-bit ARGB pixel rows (size and SHA-256 of the rows). Alternative: a SHA-256 of the file bytes. That is stable here (section 4.1), but the encoder is GDI+, a component of the Windows build, so an unchanged picture can come out with other bytes on another build, and the check would turn red without any change of content. Alternative 2: a fingerprint of the generator inputs (script, glyph geometry, size table); it is machine-independent but does not see a PNG edited by hand. Owner may overrule.
2. **A committed self-test** `tools/store/test-render-store-assets.ps1` beside the check, as the other checks of `tools/` have one. Alternative: the cases as scratch evidence only, not in the repository. Owner may overrule.
3. **The pointer and the register row say the gap is closed here**, while the catalog's dated exception row still names it until the owner's next catalog sync. Alternative: leave the pointer saying "one gap" until the catalog moves. The catalog row is not written from this pass, because it is a shared-catalog row outside the ticket's owner request. Owner may overrule.
4. **All four files are checked**, including the site copy of the icon, and the check prints one line per target, so a failure names the file.

## 4. Record of the pass (2026-11-14)

### 4.1 Measurement (fresh, 2026-11-14)

Probe: `PLAN/S0036_store-graphics-drift-check/attachments/probe-determinism.ps1` (scratch, not committed). It renders the four files twice into two scratch roots with the unchanged generator and compares them with the committed files.

- SHA-256 of the file bytes: equal for all four files across the committed copy and both renders (icon 512 `aa1d5e43...`, feature graphic `2cfb2dfe...`, social card `5a0f5389...`, site icon copy equal to the listing icon).
- SHA-256 of the 32-bit ARGB pixel rows: equal across all three sources for all four files.
- PNG chunks: `IHDR`, `sRGB`, `gAMA`, `pHYs`, `IDAT`, `IEND`; no time chunk, so no volatile field is written.

Reading: on this machine the bytes of the encoder are stable across runs and across the committed files. Not measured: another Windows build, another machine, a different .NET runtime. The encoder belongs to the Windows build (`System.Drawing` on Windows saves through GDI+), so the choice of Assumed 1 rests on that mechanism, not on a second machine.

### 4.2 Plan (each step ends in a static or command check)

- P1 the generator gains `-Check`: the render goes to a scratch folder of the operating system, the four files are compared by decoded pixels with the committed ones, exit 0, 1 or 2, the last stdout line is the verdict. Check: the file parses with the PowerShell parser, zero errors.
- P2 write path unchanged: a default run into a scratch root, the four SHA-256 equal the committed files.
- P3 `-Check` on the committed tree exits 0 with the PASS verdict.
- P4 the self-test `tools/store/test-render-store-assets.ps1` exits 0 with `0 FAIL`.
- P5 documents: `CLAUDE.md` sections 5 and 6, `docs/RELEASE.md` step 1, the `store-graphics` record, the rule 4 text of the pointer, the register row; check: `check-docs.ps1` exits 0 without an advisory, `check-pointers.ps1` exits 0, `document_registry/validate` exits 0.
- P6 the ticket: section 4.4 evidence, the Last Audit block, the status through the tool.

### 4.3 Files touched

- Edited: `tools/store/render-store-assets.ps1`; `CLAUDE.md` (sections 5 and 6); `docs/RELEASE.md` (step 1); `docs/DOCUMENT_REGISTRY.jsonl` (the `store-graphics` record); `docs/contracts/DOC-INTERNAL-QUALITY.md` (rule 4 bullet and the exception sentence); `docs/contracts/README.md` (the `DOC-INTERNAL-QUALITY` row, text only).
- New: `tools/store/test-render-store-assets.ps1`.
- Not touched: the four PNG files, the glyph sources, the catalog, the upstream checkout.

### 4.4 Evidence (fresh runs, 2026-11-14, from the repository root)

| Command | Exit | Expected / actual |
| --- | --- | --- |
| `pwsh -NoProfile -File tools/store/render-store-assets.ps1 -Check` | 0 | expected: PASS, four targets equal; actual: four `PASS ... pixels equal` lines, then `store-graphics-check: PASS (4 targets, pixels equal to the render)` (0.41 s) |
| `pwsh -NoProfile -File tools/store/test-render-store-assets.ps1` | 0 | expected: 5 PASS, 0 FAIL; actual: `store-graphics-check self-test: 5 PASS, 0 FAIL`, `store-graphics-check self-test: all expectations held.` (0.76 s; the altered, missing and not-a-PNG cases each exit 1 and name the file) |
| default render into a scratch root, SHA-256 of the four files against the committed ones | 0 | expected: four equal; actual: four `sha256 equal=True` (the write path is unchanged) |
| PowerShell parser over `tools/store/render-store-assets.ps1` | - | expected: 0 errors; actual: 0 errors |
| `pwsh -NoProfile -File tools/docs/check-docs.ps1` | 0 | expected: PASS with no advisory; actual: `docs-check: PASS (30 records, 85 corpus files, 70 Markdown, 7 links, 18 asset citations, 0 baselined)`, 0 `ADVISORY` lines |
| `pwsh -NoProfile -File tools/contracts/check-pointers.ps1` | 0 | expected: 0 mismatch; actual: `check-pointers: OK - 20 pointer(s) checked, 2 skipped, 0 mismatch(es), 184 ms` |
| `pwsh -NoProfile -File tools/harness.ps1 document_registry/validate` | 0 | expected: valid; actual: `Document registry PASS: 30 record(s)` |
| `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` | 0 | expected: 0 FAIL; actual: `10 OK, 0 WARN, 0 FAIL` (after the status moves) |
| `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/release-queue -Validate` | 0 | expected: no drift; actual: `release-queue: OK - 36 ticket(s), no drift` |
| Grep `none yet`, `no drift check`, `one gap`, `one advisory` over the repository outside `PLAN/` and the check tooling | - | expected: no statement that the listing graphics lack a check; actual: three general matches only (the policy line of `docs/RELEASE.md` step 1, the `(none yet)` of the pointers sentence in `CLAUDE.md` section 1, the generic render rule of `CLAUDE.md` section 6) |
| Grep `S0036` over `phone/src` and `wear/src` | - | expected: no match (no probe, no compiled source touched); actual: no match |

Compile gate: no compiled source was edited (PowerShell, Markdown, JSON only); `.sza-profile.json` carries no `commands.compileCheck`, so the declared absence is recorded and no compile command was run: "no compile command".

Not exercised: the exit-2 path (`COULD NOT VERIFY`) of the check has no safe trigger on this machine and is verified by reading the code only. The first self-test runs failed for two reasons inside the test, both fixed in the test and not in the check: a `Bitmap(path)` that the parent process kept open made the cleanup fail, and a save over the path the bitmap was loaded from failed with a generic GDI+ error (reproduced in a scratch script, then avoided by reading the source through a memory stream). The verdict is printed before the cleanup, so a cleanup failure cannot hide an expectation.

### 4.5 Release items

- The catalog's exception row for `DOC-INTERNAL-QUALITY` (until 2026-12-31) still names rule 4 for the listing graphics. Narrowing it is a write to the shared catalog's registry for this product's row; it is the owner's order at the next catalog sync.
- The release-tier run of the check at release start (`docs/RELEASE.md` step 1), and after any change of the glyph. Not run here as a release item; the fast form was run in this pass (section 4.4).
- Cross-machine: the check is valid on the machine that rendered the files. A mismatch on another Windows build is answered by a re-render on the owner's machine, never by editing a PNG. Not measured here.

## Last Audit

**Date:** 26-11-14 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 15 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 3 | RELEASE 0

Criteria of section 2 against the runs of section 4.4, then the checklist:

- PASS - criterion 1: `render-store-assets.ps1 -Check` exit 0; last line `store-graphics-check: PASS (4 targets, pixels equal to the render)`.
- PASS - criterion 2: the self-test exit 0, `5 PASS, 0 FAIL`; the altered, missing and not-a-PNG cases exit 1 and name the feature graphic.
- PASS - criterion 3: a default render into a scratch root gives four files whose SHA-256 equal the committed files.
- PASS - criterion 4: `check-docs.ps1` exit 0, `docs-check: PASS (30 records, ...)`, 0 `ADVISORY` lines.
- PASS - criterion 5: the `store-graphics` record names the check; `CLAUDE.md` sections 5 and 6, `docs/RELEASE.md` step 1, the rule 4 text of the pointer and the register row of `docs/contracts/README.md` say the gap is closed (grep, section 4.4).
- PASS - criterion 6: `check-pointers.ps1` exit 0 (20 checked, 0 mismatch); `document_registry/validate` exit 0 (30 records).
- EXEMPT - criterion 7: no compiled source edited and no compile command declared (`commands.compileCheck` absent from `.sza-profile.json`).
- PASS - criterion 8: no device or emulator scenario was claimed; the release-start run is named in `docs/RELEASE.md` step 1 and section 4.5.
- PASS - contract boundary: no shared format or wire changed; the check implements `DOC-INTERNAL-QUALITY` rule 4 as the contract states it; no catalog text was amended (the catalog exception row is an action item).
- PASS - scope purity: every edit is in the file list of section 4.3; the catalog row is not touched; nothing was parked.
- PASS - probe invariant: the ticket is `In Progress`, and no `S0036` line exists in `phone/src` or `wear/src` (grep, section 4.4).
- PASS - house style: `check-docs` style check held over the corpus, which includes this ticket and the edited documents.
- PASS - doc sync: the registry record, `CLAUDE.md` sections 5 and 6, `docs/RELEASE.md` step 1, the pointer and the register row changed in one pass; no user-facing surface changed, so the ship-together manifest has nothing to land.
- PASS - filesystem safety: the check writes only to a scratch folder of the operating system and removes it; the self-test leaves no folder (checked after the last run); the probe lives in `temp/S0036`, which is git-ignored; no repo-root write.
- PASS - hygiene: the rendering code moved into one function with no change of geometry, colours or order; no dead code or stale keys were left behind.
- PASS - recurrence: the GDI+ path lock (a bitmap loaded from a path keeps that file for GDI+) appeared twice inside this pass, once in the cleanup and once in the save. It is handled in the self-test and noted there; one ticket, no gate proposed.
- PASS - claim audit: every claim in this section cites a command of section 4.4 or a line of section 4.1.
- EXEMPT - `CHANGELOG.md`: no user-visible change (tooling and records).
- EXEMPT - build, unit tests, lint: no compiled source edited and no compile command declared.

### Action items

1. The catalog's exception row for `DOC-INTERNAL-QUALITY` (until 2026-12-31) still names rule 4 for the listing graphics. Narrowing it is a write to the shared catalog's registry for this product's row; it waits for the owner's next catalog sync.
2. Cross-machine stability of the pixels is not measured: the check is valid on the machine that renders the files. A mismatch on another Windows build is answered by a render on the owner's machine, never by editing a PNG.
3. The exit-2 path of the check is verified by reading only (section 4.4).

### Manual / on-target

- None.
