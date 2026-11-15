# S0034_docs-registry-and-link-gate

**Status:** Implemented
**Status note:** no compile command (no compiled source edited; commands.compileCheck absent). Registry of 30 records, gate tools/docs/check-docs.ps1 (exit 0 PASS WITH ADVISORIES, 1.44 s) and self-test (49 PASS, 3.79 s); harness document_registry/validate PASS; stamp declares docRegistryShape. Catalog rows: DOC-INTERNAL-QUALITY rewritten, DOC-EXTERNAL-QUALITY added (help pages, item O), E5 renewed, E6 new. RELEASE: none new; owner decides E5 (rename vs catalog decision) by 2026-12-31; S0036 parked for the listing-graphics drift check.
**Created:** 2026-11-14
**Complexity:** medium - assessed at the spec pass of 2026-11-14 and confirmed at the plan pass: one registry file, one PowerShell gate with its configuration, baseline and self-test, six documents and four rows of the shared registry; no compiled source, no wire, no contract text. The weight is in the corpus boundary (what is declared in and what is declared out) and in a gate that must stay under 5 s over about seventy Markdown files

## 0. Owner request (verbatim)

Agent-noticed finding (S0026 canon re-sync pass, 2026-11-14), not the owner's words.

The canon-layer contract DOC-INTERNAL-QUALITY 0.13 binds every repository that maintains internal engineering documentation (its section 2, seven rules). This repository has docs/, PLAN/, README.md, CLAUDE.md, AGENTS.md and Markdown under tools/, but holds only part of the contract:

- Rule 1 (a machine-readable document registry with topic, product area, update triggers and a source/render role): not held. docs/README.md is a hand-written index, docs/DOCS_SURFACES.md is the ship-together surfaces manifest, neither is a registry.
- Rule 2 (reverse coverage, registry to disk and disk to registry): not held.
- Rule 3 (every relative link and anchor resolves): not held; tools/contracts/check-pointers.ps1 checks pointer versions only.
- Rule 4 (generated documentation does not drift): held for the generated pages by tools/site/render-landing.ps1 -Check and tools/help/render-help.ps1 -Check.
- Rule 5 (house text style), rule 6 (asset and screenshot citations resolve), rule 7 (offline safety): not checked by a repository gate.

The siblings that meet it (Filler Android, Tourist Android) built docs/DOCUMENT_REGISTRY.jsonl and tools/docs/check-docs.ps1; their decisions can be reused, never their code. The shipped harness also has a document_registry cluster.

Scope of the ticket: decide the corpus (AGENTS.md, CLAUDE.md, README.md, docs/, PLAN/, Markdown under tools/), write the registry, write the gate with a single CHECK-VERDICT line under 5 s, add it to the fast tier in CLAUDE.md section 6 and to the release start, and update the DeviceInfo Android DOC-INTERNAL-QUALITY registry row and the dated exception that S0026 recorded for rules 1, 2, 3 and 6. The release's contract gate does not need it to be Verified, but the exception is dated 2026-12-31.

Two more items of the same pass (S0026, 2026-11-14), both in the catalog's registry under this product:

- Exception E5 on REPO-LAYOUT 0.11 rule 3: the Markdown documents under docs/ outside docs/contracts/ carry no type prefix (SPECIFICATION_, ROADMAP_, PROGRESS_, RESEARCH_, PLAN_). Decide with the registry whether to rename them (every live citation in CLAUDE.md, docs/README.md, the tickets, the port ledger and the Play listing sources follows in the same edit) or to ask the catalog for a decision that the names stand; close or renew E5 by 2026-12-31.
- DOC-EXTERNAL-QUALITY 0.14 has no row for this product. Read its section 3 against the help pages under site/help/ (en, ru, uk, rendered from tools/help/source/, permanent index address) and write the row, or write the reason it does not bind, in docs/contracts/README.md section 1 and the registry.


## 1. Problem

The product's internal documentation grew to about seventy Markdown files and a dozen records (tickets, contract pointers, the release procedure, the Play answers, the port and parity ledgers), and nothing reads it as a whole. A new document can be added without anyone declaring what it is, which area it belongs to or what change should make its author reopen it; a link or an anchor can break when a file moves and be found only by a reader; a screenshot or a figure can be cited and not exist; the house text style (plain hyphen, two dots) is kept by hand. The shared contract asks for a machine-readable registry and one gate that proves coverage both ways, links, asset citations, style and offline safety. The same pass owes two answers to the catalog: whether the documents under `docs/` keep names without a type prefix, and whether the help pages make the product a publisher of external documentation.

## 2. Done criteria

Each is a command or an observation that can be repeated.

1. `docs/DOCUMENT_REGISTRY.jsonl` exists, every line parses, each record carries `id`, `title`, `category`, `audience`, `paths`, `published`, `indexable`, `product_areas`, `update_triggers`, `generated`; `pwsh -NoProfile -File tools/harness.ps1 document_registry/validate` exits 0.
2. `pwsh -NoProfile -File tools/docs/check-docs.ps1` exits 0 and its last stdout line is `docs-check: PASS ..` (or `PASS WITH ADVISORIES` naming each advisory); the run takes under 5 s.
3. Reverse coverage holds both ways: a Markdown file added under `docs/` with no record fails the gate; a record whose pattern matches nothing fails it; both are cases of the self-test.
4. Links: a relative link to a missing file and a link to a missing `#anchor` each fail the gate; a link inside a record marked `archive` is not judged and a link into it is.
5. Style, assets and offline: a three-dot run, an ellipsis character, an em or en dash in prose, an image or an image path in inline code that resolves to no tracked file, an `http:` link and a remote script each fail the gate; fenced blocks, inline code and link targets are not read as prose.
6. Every accepted finding sits in `tools/docs/baseline.txt` with the reason in this spec; the baseline is a set that may only fall (a finding it does not list fails; an entry no finding raises fails).
7. `pwsh -NoProfile -File tools/docs/test-check-docs.ps1` exits 0 (each check passes clean and fails on its own defect; an unreadable input is exit 2).
8. `.sza-canon.json` declares `docRegistryShape` 1 and `docRegistryFile` `docs/DOCUMENT_REGISTRY.jsonl` and `check-compliance.ps1` still exits 0 with no new error.
9. `CLAUDE.md` section 6 lists the gate in the fast tier and at the release start; `docs/RELEASE.md` names it in the release-start run; `docs/README.md` indexes the registry and the tool; the pointer `docs/contracts/DOC-INTERNAL-QUALITY.md` and the register `docs/contracts/README.md` say what is held and what is not.
10. The catalog's registry rows of this product are updated and say the same: `DOC-INTERNAL-QUALITY` (adoption row and exception), `REPO-LAYOUT` E5, and a new `DOC-EXTERNAL-QUALITY` row with the reading of its section 3 against the help pages.
11. `spec_catalog/validate` and `spec_catalog/release-queue -Validate` exit 0; no file of another product, no ticket of another repository and nothing under the upstream checkout was written.

## 3. Approach

### 3.1 Scope

Phone and wear: neither. No user-visible behavior changes, so `docs/PARITY_MATRIX.md` has no row to update and `CHANGELOG.md` is not touched (the same call as S0025 and S0033).

Changes:

- New: `docs/DOCUMENT_REGISTRY.jsonl`; `tools/docs/check-docs.ps1`, `tools/docs/docs.config.json`, `tools/docs/baseline.txt`, `tools/docs/test-check-docs.ps1`, `tools/docs/README.md`.
- Edited: `.sza-canon.json` (two keys, REPO-STAMP rule 4); `CLAUDE.md` (sections 5 and 6); `docs/README.md`; `docs/RELEASE.md` (the release-start run); `docs/contracts/DOC-INTERNAL-QUALITY.md` and `docs/contracts/README.md`; findings of the first run that sit in documents this repository owns.
- Shared catalog, this product's own rows of `_meta/REGISTRY.md` only (the same edit rights S0025, S0026 and S0033 used): the `DOC-INTERNAL-QUALITY` adoption row, its exception, the `REPO-LAYOUT` E5 row, and one new `DOC-EXTERNAL-QUALITY` adoption row.

The corpus boundary (contract item V, declared and never inferred), in `tools/docs/docs.config.json`:

- In: `AGENTS.md`, `CLAUDE.md`, `README.md`, every file under `docs/` and `PLAN/`, and the Markdown under `tools/`. Only files git tracks or could track are read (a git-ignored file is outside).
- Out, by declaration (stated in the tool README): `site/` and `phone/src/main/assets/help/` (the published pages: the landing and the help pages are renders held by `tools/site/render-landing.ps1 -Check` and `tools/help/render-help.ps1 -Check`, the privacy pages are hand-authored pages of `DOC-EXTERNAL-QUALITY` and `PAGE-STYLE`; item W "excluded" form); `.claude/commands/` (command forwarders rendered by the harness scaffold); `CHANGELOG.md` and `LICENSE` (the release ledger and the licence, surfaces of the release flow); `temp/` and `build/` (scratch and output).

Registry shape: one tracked registry. `PLAN/` is tracked, so the contract's split into a tracked and a local registry (items J and K) does not arise, as in Filler Android. Fields: the harness's ten, plus `generator`, `check` (a render names both, item W), `contract` (item X, read by the gate only to see that its id exists in `docs/contracts/README.md`), `archive` (item Q) and `notes`.

Contract boundary: the ticket implements what `DOC-INTERNAL-QUALITY` 0.13 rules 1 to 7 and items J, Q, V, W and X say and amends nothing in the catalog, so no catalog-first step exists. The registry rows are the consumer's own adoption record.

### 3.2 Open questions

None open. Every choice is reversible inside this ticket and is recorded in `### Assumed` below, with the alternative.

### 3.3 Owner inputs (Approval gate)

None needed: no one-way or outward step, no contract change, no scope change, no money. E5 is renewed and not renamed (assumed 1); a rename or a request to the catalog stays the owner's call and is stated as such in the registry.

- **Related tickets:** S0026 (declared the rows, the exceptions and this ticket), S0025 (the contracts register, `docs/contracts/README.md`), S0020 (the surfaces manifest and its check, which this gate neighbours but does not replace), S0024 (the help pages and their gate), S0033 (the most recent catalog-row edit)

### Assumed (unattended, 2026-11-14)

Each was taken because it is reversible inside this ticket and has a researched recommendation. Owner may overrule.

1. **E5 is renewed, not closed by a rename, and no catalog request is filed.** Renaming ten documents needs ten owner-grade naming choices (`RELEASE.md` is a procedure and a plan at once; the Play files are named after the console forms), touches about twenty live citations in gates that read the names (`check-surfaces.ps1`, `check-matrix.ps1`, the store tools), and leaves the catalog's own dated rows and the canon contrib record citing paths that no longer exist, which a session of this repository may not edit. The siblings did not agree either: Filler Android renamed six documents and kept `play/PLAY_*.md`, Tourist Android kept `BOOTSTRAP_HANDOFF.md`. A request that the names stand is a contract-level ask. What changes now is the compensating behavior: every one of the ten documents has a registry record with category, product area and update triggers, checked both ways by the gate, so the index the exception relied on is no longer a hand-written table. Alternatives: rename with the citations; file a catalog proposal. Review date stays 2026-12-31. Owner may overrule.
2. **One registry `docs/DOCUMENT_REGISTRY.jsonl`, not one per folder.** `PLAN/` is tracked and public in this product; items J and K split registries only for a partly ignored folder. It is also the path the harness validator reads by default, so `.sza-canon.json` names the default. Alternative: a second registry beside `PLAN/`. Owner may overrule.
3. **The port ledger and its two decision files are recorded `generated`**, with `record-port.ps1`, `record-decision.ps1` and `record-local-decision.ps1` as generators and the three drift checks as checks, because only those scripts write them (as Filler Android does). Alternative: `source` with a note. Owner may overrule.
4. **`CHANGELOG.md` stays outside the corpus.** It is the release ledger written for users and listing text, a surface of the release flow (`docs/DOCS_SURFACES.md`), not an engineering document; the contract lets the repository declare its boundary. Alternative: add it. Owner may overrule.
5. **The gate keeps a set baseline for findings inside records that must stay as written** (the origin record and the verbatim owner requests quoted in tickets), and every other finding is fixed in the document. The baseline may only fall. Alternative: edit the verbatim text. Owner may overrule.
6. **A render whose drift check does not exist is an advisory, not a pass.** The listing graphics have a generator and no check; the gate says so in its verdict (`PASS WITH ADVISORIES`) and a draft ticket is parked for the check. Alternative: write the check now (out of scope: a PNG render is not byte-stable across .NET versions without a decision). Owner may overrule.
7. **The `DOC-EXTERNAL-QUALITY` row is a consumer row for the help pages, read with item O.** The pages are published from a `CONTEXT-HELP` source, so rules 2 and 5 do not apply to them (they carry `noindex`, are not in `sitemap.xml`, `robots.txt` does not block them); rules 1, 3, 4, 6 and 7 are read, and the gaps are recorded as a dated exception instead of a claim of conformance. Alternative: write that the contract does not bind. The text of section 3 opens "web help centers" and item O removes only rules 2 and 5, so "does not bind" would claim more than the contract says. Owner may overrule.
8. **Rule 7 (offline safety) is a check of the gate, not a reading.** The gate fails on an `http:` link outside code and on a remote script, font, stylesheet or image in Markdown; `http://localhost` and `127.0.0.1` are allowed. Alternative: hold rule 7 by reading, as the siblings do. Owner may overrule.

## 4. Record of the pass (2026-11-14)

### 4.1 Contract text read (fresh, 2026-11-14)

`DOC-INTERNAL-QUALITY` 0.13 (`documentation-quality/README.md` of the catalog): section 2 rules 1 to 7; items J and K (where a registry lives, a partly tracked folder), L (rules 2 and 3 are shown by a check that runs reverse coverage and link resolution, not by a stamp), Q (a frozen archive is exempt from rule 3 inside, links into it must resolve), V (the corpus boundary is declared and never inferred), W (a generated file is a `render` with a registered generator and a drift check, or lies outside the corpus by a reasoned ignore), X (the optional `contract` field). `DOC-EXTERNAL-QUALITY` 0.14: section 3 rules 1 to 7, section 8 items A to E, section 9 items F to I, items M, N, O (a help page published from a `CONTEXT-HELP` source is out of rules 2 and 5, carries `noindex`, is not in the sitemap), R, S, T, U. `REPO-LAYOUT` 0.11 rule 3 (the type prefix and its three exceptions). `REPO-STAMP` rule 4 (`docRegistryShape` and `docRegistryFile`). `CHECK-VERDICT` section 2 (exit codes 0, 1, 2; one verdict line, the last on stdout; `2` and `COULD NOT VERIFY` travel together). Sibling decisions read, not code: Filler Android and Tourist Android (`docs/DOCUMENT_REGISTRY.jsonl`, `tools/docs/docs.config.json`, README of the gate).

### 4.2 Files touched

- New: `docs/DOCUMENT_REGISTRY.jsonl` (30 records); `tools/docs/check-docs.ps1`, `tools/docs/docs.config.json`, `tools/docs/baseline.txt` (empty), `tools/docs/test-check-docs.ps1`, `tools/docs/README.md`; `docs/contracts/DOC-EXTERNAL-QUALITY.md` (the pointer of the new row).
- Edited: `.sza-canon.json` (`docRegistryShape` 1, `docRegistryFile`); `CLAUDE.md` (sections 5 and 6); `docs/README.md`; `docs/RELEASE.md` (the release-start run); `docs/contracts/DOC-INTERNAL-QUALITY.md` (rewritten to what is held) and `docs/contracts/README.md` (20 rows, E5 renewed, E6, the two rows).
- Findings of the first run fixed in documents this repository owns: twelve author-side ellipses in the prose of eight closed tickets (S0016, S0017, S0019, S0021, S0022, S0023, S0024, S0026): `...` became `..` in quoted text, and four path fragments were put in code spans (`/.../` read as a path is not prose). The verbatim words of the owner were not changed, only the elision marker the ticket's author had inserted.
- Shared catalog, this product's own rows of `_meta/REGISTRY.md` only: `DOC-INTERNAL-QUALITY | DeviceInfo Android` (rewritten), new `DOC-EXTERNAL-QUALITY | DeviceInfo Android`, exception `REPO-LAYOUT` E5 (renewed), exception `DOC-INTERNAL-QUALITY` (narrowed), new exception E6 (`DOC-EXTERNAL-QUALITY`).
- Parked: `PLAN/S0036_store-graphics-drift-check.md` (Draft), the one open rule 4 gap.
- This ticket's spec.

Findings of the pass: (1) two defects of the first self-test were the test's own: a code span written in a double-quoted PowerShell string lost its backtick (PowerShell's escape character) and became a real link, and one tree carried a link target that the links check rightly refused; both fixed in the test. (2) The self-test's first form took 7.1 s (19 gate processes one after another); the independent runs now go in one parallel batch (2.8 s to 3.8 s).

### 4.3 Evidence (fresh runs, 2026-11-14, from the repository root)

| Command | Exit | Expected / actual |
| --- | --- | --- |
| `pwsh -NoProfile -File tools/docs/check-docs.ps1` | 0 | expected: no finding, the one known gap named; actual: `docs-check: PASS WITH ADVISORIES (1 advisory(ies) named above; 30 records, 85 corpus files, 70 Markdown, 7 links, 18 asset citations, 0 baselined)`, `ADVISORY store-graphics`, harness validator inside the run (1.44 s) |
| `pwsh -NoProfile -File tools/docs/test-check-docs.ps1` | 0 | expected: all held; actual: `49 PASS, 0 FAIL`, `docs-check self-test: all expectations held.` (3.79 s; 2.83 s on the first run) |
| `pwsh -NoProfile -File tools/harness.ps1 document_registry/validate` | 0 | expected: valid; actual: `Document registry PASS: 30 record(s)` |
| `check-compliance.ps1` from the installed plugin root, after the stamp edit | 0 | expected: 0 errors; actual: 0 errors, 1 warning (SZA-CTR02 in `PLAN/archive/S0001`, S0016's, not this change) (0.67 s) |
| `pwsh -NoProfile -File tools/contracts/check-pointers.ps1` | 0 | expected: 0 mismatch; actual: 20 pointers checked, 2 skipped, 0 mismatches (0.19 s) |
| `contract-lag.ps1 -Product DeviceInfo` from the canon's `tools/` folder | 0 | expected: 20 rows, none unparsed; actual: `rows: 20 (current 4, behind 0, partial 0, pending 16, ahead 0, n/a 0, unparsed 0)` (0.50 s) |
| `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` | 0 | expected: 0 FAIL; actual: 10 OK, 0 WARN, 0 FAIL |
| `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/release-queue -Validate` | 0 | expected: no drift; actual: `OK - 36 ticket(s), no drift` |
| `pwsh -NoProfile -File tools/docs/check-surfaces.ps1` | 0 | expected: held; actual: OK, string keys and permission surfaces agree |
| Grep `S0034` over `phone/src` and `wear/src` | - | expected: no match; actual: no match |

The gate has links to check only in `README.md` (7 relative links): the documents of this product name files in code spans, which rule 3 does not read. The count was cross-checked against a grep of `](` over the Markdown outside `site/`, `phone/`, `wear/`: the same seven in `README.md` (and one in `CHANGELOG.md`, outside the corpus).

Compile gate: no compiled source was edited (PowerShell, JSON and Markdown only), and `commands.compileCheck` is absent from `.sza-profile.json`: no compile command, none run.

### 4.4 Release items

- None new for the build. `docs/RELEASE.md` step 1 now lists `tools/docs/check-docs.ps1`; a `PASS WITH ADVISORIES` verdict is read at the release start, and its one advisory closes with S0036.
- E5, E6 and the narrowed `DOC-INTERNAL-QUALITY` exception are dated 2026-12-31 in the catalog; E5 needs the owner's choice (rename with citations, or a catalog decision that the names stand), E6 closes with the first device run of S0032 (screenshots) and a termbase decision.
- The `Verified` cells of the two rows stay `pending`: the catalog has no conformance cases for either contract.

## Last Audit

**Date:** 26-11-14 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 17 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 0

Criteria of section 2 against the runs of section 4.3, then the checklist:

- PASS - criterion 1: the registry parses, every record carries the ten fields; `document_registry/validate` exit 0 (30 records).
- PASS - criterion 2: `check-docs.ps1` exit 0, last line `docs-check: PASS WITH ADVISORIES (..)`, one advisory named, 1.44 s.
- PASS - criterion 3: the self-test cases `a file with no record`, `a pattern that matches nothing` and `a file claimed twice` fail the gate (49 PASS, 0 FAIL).
- PASS - criterion 4: the self-test cases for a missing file, a missing anchor, a link into an archive that does not resolve (named) and a broken link inside an archive (not judged).
- PASS - criterion 5: style, assets and offline cases each name their defect and leave code spans, fenced blocks, link targets, `localhost` and https links alone.
- PASS - criterion 6: `tools/docs/baseline.txt` is empty and the gate reads 0 baselined; the set semantics (fail on an unlisted finding, fail on a stale entry) are self-test cases.
- PASS - criterion 7: `test-check-docs.ps1` exit 0, 49 PASS, 0 FAIL; the five exit-2 cases (missing config, config not JSON, missing registry, registry not JSON, no git work tree) are in it.
- PASS - criterion 8: `.sza-canon.json` holds both keys; `check-compliance.ps1` exit 0, 0 errors, the one warning is S0016's.
- PASS - criterion 9: `CLAUDE.md` sections 5 and 6, `docs/RELEASE.md` step 1, `docs/README.md`, both pointers and `docs/contracts/README.md` carry the gate, the registry and the state; `check-pointers.ps1` exit 0 (20 checked, 0 mismatch).
- PASS - criterion 10: the three rows and the E5, narrowed and E6 exceptions are written in the catalog and say the same as the pointers; `contract-lag.ps1 -Product DeviceInfo` reads 20 rows, 0 unparsed.
- PASS - criterion 11: `spec_catalog/validate` 10 OK, 0 WARN, 0 FAIL and `release-queue -Validate` OK; no ticket of another repository was read or written, nothing under the upstream checkout was touched; the one shared file written is this product's own rows of the catalog registry.
- PASS - scope purity: every edit is in the file list of section 4.2; the one finding outside scope (the listing graphics without a drift check) was parked as S0036 and reported, not fixed inline.
- PASS - probe invariant: no `S0034` line in `phone/src` or `wear/src` (grep, 0 files); the ticket is not in the needs-manual-test status.
- PASS - house style: no long dash and no ellipsis in the spec or the new documents (grep, 0 matches); the gate itself holds the corpus clean.
- PASS - document sync: registry, tool README, `docs/README.md`, `CLAUDE.md`, `RELEASE.md`, pointers, register and catalog rows were edited in one pass; no user-facing surface changed, so the ship-together manifest has nothing to land.
- PASS - contract boundary: nothing another product reads or writes changed; rules 1 to 3 and 5 to 7 are implemented as `DOC-INTERNAL-QUALITY` 0.13 states them and the help pages are read as item O of `DOC-EXTERNAL-QUALITY` 0.14 states; no catalog text was amended.
- PASS - recurrence: the PowerShell escape-character slip in the self-test (a backtick in a double-quoted string) is one sighting here; no gate proposed.
- EXEMPT - `CHANGELOG.md`: no user-visible change (tooling and records); it is also outside the corpus by declaration.
- EXEMPT - build, unit tests, lint: no compiled source edited and no compile command declared (`commands.compileCheck` absent); nothing above 5 s was run (the slowest run was the self-test, 3.79 s).

### Action items
1. The owner chooses for E5 between a rename of the ten documents with every citation and a catalog decision that the names stand (assumed 1 of section 3 renewed it); review 2026-12-31.
2. S0036 (Draft): a drift check for the listing graphics closes the one advisory of the gate.
3. E6 closes with the first device run of S0032 (screenshots) and a decision on a termbase gate; review 2026-12-31.

### Manual / on-target
- None.
