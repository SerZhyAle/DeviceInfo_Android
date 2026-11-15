# S0046_bugfix-local-divergence-wear-systeminfoscreen-unclassified

**Status:** Verified
**Created:** 2026-11-15
**Complexity:** light - one record-local-decision call on one file plus a gate re-run, no source change

## 0. Owner request (verbatim)

Found by S0014 (second resume pass after S0044, 2026-11-15, not the owner's words but an agent-noticed finding):

`pwsh -NoProfile -File tools/port-ledger/check-local-divergence.ps1 -RequireClassified` exits 1: `Local edits: 9; unclassified: 1`. The one unclassified edit is `wear/src/main/kotlin/com/sza/deviceinfo/wear/ui/apps/systeminfo/SystemInfoScreen.kt`. The ledger row (`docs/port-ledger.jsonl`) was carried by S0042 on 2026-11-15 (destinationSha256 starting badc551f, 8 local edits, 0 unclassified at S0014's earlier pass); the file was edited again at 01:29 the same day by S0043 (the clipped Russian main title, `BlockNeedUserTest`), so the current bytes no longer match the carried hash and no local decision names them.

Evidence: the S0014 pass at 2026-11-15 ran the gate and printed `LOCAL EDIT wear/.../SystemInfoScreen.kt (unclassified)`; `git diff --stat` on the file shows 294 insertions and 92 deletions against the committed copy (the diff includes S0042's carry, so it is not S0043's alone). S0043's spec does not mention `record-local-decision.ps1`.

What is needed: classify the current bytes with `tools/port-ledger/record-local-decision.ps1` (a candidate for the reverse port per `docs/reverse-port-notices.jsonl`, or a recorded local difference), then re-run `check-local-divergence.ps1 -RequireClassified` to exit 0. `docs/RELEASE.md` step 1 and `CLAUDE.md` section 6 require that exit at every release start, so the release run of S0014 cannot start while it is 1.

Not in scope here: the title fix itself (S0043) and the ledger rows of other files.


## 1. Problem

The local divergence release gate exits 1 with one unclassified local edit: a locally edited watch file whose current bytes no local decision names. The bytes changed when the watch title inset of S0043 was added after the last carry (S0042, 2026-11-15). The carried hash no longer matches, and no classification covers the new hash. The release-start checks require exit 0, so the S0014 release run cannot start while the gate exits 1. The title fix itself belongs to S0043 and is not reopened here.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- `pwsh -NoProfile -File tools/port-ledger/check-local-divergence.ps1 -RequireClassified` exits 0 and lists no unclassified local edit. Expected: exit 0. Actual: recorded in the audit.
- The watch destination `wear/src/main/kotlin/com/sza/deviceinfo/wear/ui/apps/systeminfo/SystemInfoScreen.kt` has a classification of its current SHA-256 in `docs/local-divergence-decisions.jsonl`, kind `candidate`, naming `RP-0008`; `docs/reverse-port-notices.jsonl` holds `RP-0008` in state `open`, naming that destination.
- The watch file's bytes are the same before and after the classification: its SHA-256 equals the `destinationSha256` of the new classification line (`sha256sum` read before and after).
- No source is edited by this ticket: the only writes are one appended notice line, one appended classification line and this ticket record.
- `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` exits 0 and `pwsh -NoProfile -File tools/docs/check-docs.ps1` exits 0 after this ticket's edits (verdict line read).
- No probe of this ticket is in code: `grep -rn "S0046" phone/src wear/src` finds nothing.

## 3. Approach

### 3.1 Scope

Changes: one candidate notice `RP-0008` appended to the reverse-port notices journal; one classification of the watch file's current bytes, written by `tools/port-ledger/record-local-decision.ps1`, appended to the local divergence decisions journal; this ticket record. Both journals already exist (the notices journal holds RP-0001 to RP-0007, the decisions journal 28 classifications), so the ticket creates no file.

Deliberately not changed: no phone or wear source (the title inset, its S0043 status-bound probe and the S0043 manual check stay as they are); the title text, the string keys and the title style; the ledger rows (carried by S0042); the upstream checkout, which is read only. Shared-contract boundary: none. The two journals are this repository's own records, and no other product reads them. Behaviour: none changes, and no parity matrix row concerns the title (S0043 section 3.1).

Known consequence, not done here: S0043's probe is removed when S0043 leaves BlockNeedUserTest. That edit changes the watch file's bytes again, so the gate exits 1 until the new bytes are classified too; the S0043 close has to run `record-local-decision.ps1` for the new hash.

### 3.2 Open questions

None. The classification choice is taken under Assumed below and is reversible inside this ticket.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0014 (waits on this ticket, see Blocked tickets below), S0043 (the edit classified here), S0042 (the last carry of the watch row). No owner input is needed and no `DO:` action is owed.

### Assumed (unattended, 2026-11-15)

- **Classification of the watch file's current bytes: `candidate`, notice `RP-0008` (state open).** Alternative: `deliberate`, with the evidence excerpt "Inset on each side of the main title" from the KDoc of the inset constant, which the gate accepts because it sits in an adjacent KDoc. Why candidate: the inset fixes a clip that the upstream title item most likely shares (same text, style and alignment without an inset; evidence in `RP-0008`), and fixes travel both ways (CLAUDE.md section 2, rule 5). A deliberate difference is kept for a choice the product keeps. Owner may overrule.
- **Rung: Fix.** The gate failure is narrow, understood and data-only, so no plan is written; the ticket carries the three sections. Alternative: the full pipeline with a plan. Owner may overrule.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0014 | was: Draft | since: 2026-11-15 | released: 2026-11-15 -> Draft

## Last Audit

**Date:** 26-11-15 02:05 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 7 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 1 | RELEASE 0

Checks, all run in this pass (expected | actual):

1. Gate `tools/port-ledger/check-local-divergence.ps1 -RequireClassified`: exit 0 | exit 0, output `Local edits: 9; unclassified: 0; missing: 0; unanchored: 0` and `OK: every local edit is classified.` PASS. Before the classification the default form showed `unclassified: 1` on the watch file.
2. Classification line: one line in `docs/local-divergence-decisions.jsonl` with the current SHA-256 `83d8e23c...bef6bf`, kind `candidate`, notice `RP-0008`; the gate reads it and the notice names the destination. PASS.
3. Watch file bytes unchanged by the pass: SHA-256 `83d8e23c...bef6bf` before and after. PASS.
4. No source edited: the pass wrote one notice line, one classification line and this record. PASS.
5. `tools/harness.ps1 spec_catalog/validate`: exit 0 | exit 0, `Summary: 10 OK, 0 WARN, 0 FAIL`. PASS.
6. `tools/docs/check-docs.ps1`: exit 0 | exit 0, `docs-check: PASS (30 records, 98 corpus files, 80 Markdown, 7 links, 18 asset citations, 0 baselined)`. PASS.
7. Probe invariant: `S0046` in `phone/src` and `wear/src` | 0 hits. PASS.
8. Compile gate: no compiled source changed, so `commands.compileCheck` was not run. EXEMPT (declared, not triggered).

Not covered by this ticket: the watch title look on the round emulator is S0043's manual check. The gate result is a static record, not a device run.

### Action items

1. S0043 close: when its status-bound probe is removed, the watch file's bytes change and the gate exits 1 again. The S0043 close runs `tools/port-ledger/record-local-decision.ps1` for the new hash (follow-up, not a failure of this ticket).

### Manual / on-target

- None for this ticket.
