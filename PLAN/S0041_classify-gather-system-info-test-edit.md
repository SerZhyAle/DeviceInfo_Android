# S0041_classify-gather-system-info-test-edit

**Status:** Verified
**Created:** 2026-11-14
**Complexity:** light - primitive rung: one classification and one notice line; no code, no new file, no schema; the one judgment is recorded under Assumed (spec pass, 2026-11-14)

## 0. Owner request (verbatim)

Found by S0039 (carry of the collapsible header drift), 2026-11-14, agent finding, not the owner's words.

`pwsh -NoProfile -File tools/port-ledger/check-local-divergence.ps1 -RequireClassified` exits 1 on 2026-11-14 with one unclassified local edit:

  LOCAL EDIT   phone/src/test/kotlin/com/sza/deviceinfo/domain/usecase/GatherSystemInfoUseCaseTest.kt (unclassified)
  Local edits: 10; unclassified: 1; missing: 0; unanchored: 0.

Facts read 2026-11-14: S0027's acceptance pass of the same day recorded this command at exit 0 (`OK: every local edit is classified`), so the edit came after it; S0037 (Implemented, test-only edit of this file) is the ticket that touched it and records no classification. The command runs at every release start, so the release start would stop on it.

Needed: review the whole current change of the file against the upstream test, record exactly one classification of the current bytes with `tools/port-ledger/record-local-decision.ps1 -Destination phone/src/test/kotlin/com/sza/deviceinfo/domain/usecase/GatherSystemInfoUseCaseTest.kt -Classification <deliberate|candidate|not-applicable> -Note "<why>"` (a `candidate` needs a notice in `docs/reverse-port-notices.jsonl` first), then re-run `check-local-divergence.ps1 -RequireClassified` to exit 0.


## 1. Problem

The release start runs a local-divergence check that stops on any edit of a ported file that no record classifies.
One phone unit test file carries such an edit: a test-only battery broadcast context added under S0037, which no
record classifies. The check exits 1, so the release start would stop on it, and the acceptance ticket S0027 waits
for this classification. Nothing in the product changes.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- `pwsh -NoProfile -File tools/port-ledger/check-local-divergence.ps1 -RequireClassified` exits 0, and its last
  line is `OK: every local edit is classified` (fast tier, 0.5 s; read 2026-11-14: exit 0, `Local edits: 9;
  unclassified: 0; missing: 0; unanchored: 0.`).
- The classification journal `docs/local-divergence-decisions.jsonl` holds one record for the test file, `candidate`,
  pinned to the current SHA-256, and it names notice RP-0007 in `docs/reverse-port-notices.jsonl`, which stays `open`
  with the destination named.
- `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` exits 0 after the status moves (fast tier).
- `pwsh -NoProfile -File tools/docs/check-docs.ps1` exits 0 after the ticket edit (fast tier; the ticket is in the corpus).
- RELEASE item (not run between releases): the release start repeats the first criterion, and
  `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest --tests "com.sza.deviceinfo.domain.usecase.GatherSystemInfoUseCaseTest"`
  exits 0 with 0 failures on the classified bytes. Not built and not run until the release.

## 3. Approach

### 3.1 Scope

In: the classification of the one current destination, one notice line (RP-0007) for the coverage checks the
classification rests on, and this ticket's status moves. Out: any edit of the test file or of product code; any
change to the upstream checkout, which is read-only from here; the hand-over of RP-0007 to FastMediaSorter, which
the owner orders through the fms-a capture; the battery test's run, which is S0037's RELEASE item.

### 3.2 Open questions

None open. The one choice, `candidate` or `not-applicable`, is taken under Assumed below.

### Assumed (unattended, 2026-11-14)

- **Taken:** `candidate`, with notice RP-0007 (state `open`). The three header checks and the battery context may
  improve FastMediaSorter: its suite has five checks, none of them covers the battery, extended, sensor or media
  headers, and the upstream code produces every string key those checks name. The notice keeps the question
  visible; the owner decides whether to order it.
- **Alternative, not taken:** `not-applicable`. The S0037 delta alone needs nothing upstream, because the upstream
  suite has no battery check to fix. It would hide the coverage gap the three checks show.
- **Alternative, not taken:** `deliberate`. Rejected: the difference is coverage, not a product difference, and a
  deliberate record would need KDoc evidence that does not explain it.
- **Review note:** the committed baseline (commit c12f2d4, SHA-256 487cef) already held the three checks and the
  package port. The delta since that baseline is the S0037 battery context, the builder helper and their imports. The
  section-header check lists sensors and media after time, while the use case builds them after hardware; `contains`
  ignores list order, so no verdict depends on it, and it is left as committed.
- **Owner may overrule.** An overrule is a new classification of the current bytes, and a notice moved to
  `declined` needs a reason.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0027 waits on this ticket (its `Blocks:` line below); S0037 made the test-only edit this
  classification covers. Both are mentions, not blockers.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14 | released: 2026-11-14 -> Draft

## Last Audit

**Date:** 26-11-14 16:35 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 9 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 1 | RELEASE 1

### Action items
1. None open between releases. The RELEASE item below closes at the release-tier run.

### Checks (this run)
- `pwsh -NoProfile -File tools/port-ledger/check-local-divergence.ps1 -RequireClassified` - exit 0, expected `OK: every local edit is classified` | actual `Local edits: 9; unclassified: 0; missing: 0; unanchored: 0.` and `OK: every local edit is classified`.
- `record-local-decision.ps1` (candidate, notice RP-0007) - exit 0, expected one record | actual `Classified phone/src/test/kotlin/.../GatherSystemInfoUseCaseTest.kt as candidate (hash 59baab59cdc9).`
- Notice RP-0007 - parsed by the check's notice reader in the run above, and read again with `ConvertFrom-Json`: id RP-0007, state open, destination named.
- `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` - exit 0, expected OK | actual `Summary: 10 OK, 0 WARN, 0 FAIL`.
- `pwsh -NoProfile -File tools/docs/check-docs.ps1` - exit 0, expected PASS | actual `docs-check: PASS (30 records, 92 corpus files, 75 Markdown, 7 links, 18 asset citations, 0 baselined)`.
- `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/release-queue -Validate` - exit 0, expected OK | actual `release-queue: OK - 41 ticket(s), no drift`.
- Probe invariant: a search for `S0041` under `phone/src` returns no files; the ticket is not in a needs-manual-test status.
- Scope purity: edits are the ticket, one appended notice line, and the classification record written by the tool. No product or test source was edited.
- Whole-change review: the working file against the upstream test (five checks) shows port adaptation, three header checks and the battery context. The committed baseline (commit c12f2d4) has SHA-256 487cef, the value the ledger pins; the delta since that baseline is the S0037 test-only battery context, the `gatherWith` builder and their imports. Each string key the added checks name is produced by upstream main code.
- Compile gate: EXEMPT. No compiled source was edited in this pass; the declared `commands.compileCheck` was not run, and no compile claim is made.

### Why Verified
The ticket changes no product behaviour, so the entry precondition about user-visible behaviour does not apply. Its done criteria are fast checks that ran in this pass and passed. The one behaviour proof, the unit test run of the classified bytes, is a RELEASE item and is not claimed here.

### RELEASE item
`.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest --tests "com.sza.deviceinfo.domain.usecase.GatherSystemInfoUseCaseTest"` - expected: exit 0 with 0 failures on the classified bytes. Not built and not tested until the release. The release start also repeats `check-local-divergence.ps1 -RequireClassified`.
