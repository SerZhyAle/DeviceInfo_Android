# S0039_carry-collapsible-section-header-drift

**Status:** Implemented
**Status note:** Carried with record-port.ps1 -Refresh, no code edit (RTL chevron behaviour already in the port): check-drift exit 0 (105 in step), check-scope exit 0. No compiled source edited, so no compile gate; not built, not tested until the release. RTL device check stays with S0007. Parked: S0041.
**Created:** 2026-11-14
**Complexity:** medium - assessed at the spec pass: one file and one upstream diff of three small hunks; no code edit was needed, the work was reading the diff against the local S0010/S0023 edits and deciding carry versus decision with a contract check (COLLAPSIBLE-GROUP)

## 0. Owner request (verbatim)

Found by S0027 (target-state acceptance), 2026-11-14 15:16, agent finding, not the owner's words.

`pwsh -NoProfile -File tools/port-ledger/check-drift.ps1` exits 1:

  DRIFT  app_v2/src/main/java/com/sza/fastmediasorter/ui/common/widget/CollapsibleSectionHeader.kt  ->  phone/src/main/kotlin/com/sza/deviceinfo/ui/common/widget/CollapsibleSectionHeader.kt  (anchored on 2026-11-11)
  UNCARRIED: 1 of 104 row(s) need a carry (record-port.ps1 -Refresh) or a decision (record-port.ps1 -Decide).

Facts read 2026-11-14: the upstream file has an uncommitted change in the FastMediaSorter_mob_v2 checkout (git status ` M`, file mtime 2026-11-14 14:15); the destination file carries the local S0010/S0023 edits (disclosure marker and target size) and is classified in the local-divergence check. The drift is the upstream's own new edit since the anchor, not a local one.

Needed: read the upstream diff, decide per behaviour carry versus pinned decision (the S0013 pattern), keep the local S0023 target-size and disclosure behaviour, record with record-port.ps1, and re-run check-drift.ps1 to exit 0. S0027 criterion T1 waits on this exit code.


## 1. Problem

The upstream changed the group header that the System Info screen uses after DeviceInfo copied it (the marker of a collapsed group now points toward the reading end, left in a right-to-left layout), so the drift check that guards every parity claim and every release start exits non-zero for that one file. Until the change is read and either carried or deliberately declined, the target-state acceptance (S0027, criterion T1) cannot pass and the release flow cannot start.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- `pwsh -NoProfile -File tools/port-ledger/check-drift.ps1` exits 0 (observed 2026-11-14 after the carry, see Last Audit).
- The ledger row of the header carries `sourceSha256` equal to the SHA-256 of the current upstream file (`edb3a8bf85db..`) and `carriedOn` 2026-11-14; the destination file is byte for byte the file that was classified before this ticket (SHA-256 `fbf7766eccb6..`): no source edit.
- The behaviour of the upstream hunks is present in the destination, checked by reading the code against the catalog contract: expanded 0 degrees (down), collapsed -90 degrees in LTR (right) and +90 degrees in RTL (left), re-applied when the layout direction is resolved.
- `pwsh -NoProfile -File tools/port-ledger/check-scope.ps1` still exits 0.
- RELEASE: nothing compiled was edited, so no compile rung is owed by this ticket; the release run (`.\gradlew.bat :phone:assembleDebug`) builds the file as it stands. The RTL chevron on a device or emulator is an S0007 manual check, not a result of this ticket.

## 3. Approach

### 3.1 Scope

Scope (S0021): phone only, no user-visible change, so no `docs/PARITY_MATRIX.md` row changes. The watch has its own disclosure (`SectionDisclosure`, COLLAPSIBLE-GROUP row of `docs/UI_CONFORMANCE.md`), which already draws a reading-start triangle and supports RTL; it holds no port of this file.

What the upstream diff contains, read 2026-11-14. The anchored hash `7c4103e5..` equals the upstream's committed blob (commit `30f98c871`, 2026-10-18), so the whole drift is the uncommitted working-tree edit made 2026-11-14 14:15 (`git diff`, 19 insertions, 3 deletions, three hunks):

| Upstream hunk | Port today | Disposition |
| --- | --- | --- |
| `onRtlPropertiesChanged` override re-applies the chevron without animation once the layout direction is known (it is not resolved while the constructor runs) | `onRtlPropertiesChanged` override re-applies the rotation after cancelling any running animation (same effect) | Behaviour already present, carried without a code change |
| `updateChevron` picks the collapsed rotation by layout direction | `updateChevron` picks 0 / +90 / -90 the same way | Behaviour already present |
| constants `COLLAPSED_ROTATION_LTR = -90f` and `COLLAPSED_ROTATION_RTL = 90f` with a comment citing COLLAPSIBLE-GROUP section 2 rule 2 | the same values as literals in two places | Same values; the rename is cosmetic and is not mirrored (Assumed 2) |

Check of the equivalence, not trusted from the diff alone: `ic_group_triangle` points down at rotation 0 (path `M0,4 L16,4 L8,12`), so -90 points right and +90 points left, which is the catalog text (`P:\Contracts\collapsible-group\README.md` line 55: right when collapsed in LTR, left in RTL, down when expanded). The contract is unchanged by this ticket; the port already conforms.

What stays different from the upstream in this file, and is not this drift: the port rotates the marker instantly (no 150 ms animation and no `AnimationPolicy`, which the port never held), adds the state description, the accessibility heading and the toggle row id. They are the S0010 and S0023 edits, classified against RP-0003 in `docs/local-divergence-decisions.jsonl` (hash `fbf7766e..`); this ticket does not touch them. RP-0003, if the owner orders its FMS_A capture, must not offer the RTL rotation as news: the upstream now has it.

Disposition: carry. `record-port.ps1 -Refresh` takes the current upstream hash `edb3a8bf..` and the unchanged destination hash `fbf7766e..` and writes `carriedOn`. The destination is classified, so the command does not refuse.

What deliberately did not change: the destination file, wear, strings, tests, the notices, and the unrelated unclassified local edit of `GatherSystemInfoUseCaseTest.kt` that `check-local-divergence.ps1 -RequireClassified` reports (exit 1 on 2026-11-14; not part of this file, parked as S0041).

### Assumed (unattended, 2026-11-14)

- **`-Refresh`, not `-Decide`.** Alternative: `record-port.ps1 -Decide -Note ".."` pinned to the upstream hash. Taken because the behaviour the upstream added is already in the port (S0013's Battery precedent), so "carried" is the true statement and `-Decide` ("deliberately not carried") would say the opposite; both pin to the upstream hash and both go stale on the next upstream edit. Owner may overrule.
- **No source edit to mirror the named constants and the upstream KDoc.** Alternative: rename the two literals to `COLLAPSED_ROTATION_LTR` and `COLLAPSED_ROTATION_RTL` and copy the KDoc, so the next diff is smaller. Taken because it changes no behaviour, any edit changes the destination hash (a new classification against RP-0003 is owed) and compiled source then owes the compile gate; the cost is not paid by anything. Owner may overrule.
- **Pin to the uncommitted upstream state.** Alternative: wait for the upstream to commit. Taken because waiting holds S0027 and the release start, and a later upstream edit is drift again whatever the pin is (the row holds the one hash it was written against, `tools/port-ledger/README.md`). If the upstream reverts or edits the file, the check reports it and a new pass reads it. Owner may overrule.
- **Complexity stays `medium`.** Alternative: `light` (no code edit). Kept because the pass contained a carry-versus-decision call and a contract check; in doubt the higher level applies.

### 3.2 Open questions

None. Every point above was answered by reading the upstream diff, the port, the drawable and the catalog contract.

### 3.3 Owner inputs (Approval gate)

None.

- **Related tickets:** none (S0027 waits on this one, recorded by the status tool below; S0041 holds the unclassified test edit named above; S0007 owns the RTL device check. These are mentions, not blockers.)

## Last Audit

**Date:** 26-11-14 17:05 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 7 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 2

Checks, each run on 2026-11-14 in this pass:

- PASS - `tools/port-ledger/check-drift.ps1` after `record-port.ps1 -Refresh`: `OK: nothing uncarried (105 in step, 0 decided)`. expected: exit 0 | actual: exit 0 (before the carry: exit 1, `UNCARRIED: 1 of 105`).
- PASS - ledger row of the header: `sourceSha256` `edb3a8bf85db..` equals the hash of the current upstream file, `carriedOn` 2026-11-14. expected: both | actual: both.
- PASS - destination bytes unchanged: SHA-256 `FBF7766E..` before and after, equal to the hash classified in `docs/local-divergence-decisions.jsonl`. expected: equal | actual: equal.
- PASS - behaviour equivalence read in code: `updateChevron` and `onRtlPropertiesChanged` of the port give 0 expanded, -90 LTR, +90 RTL; `ic_group_triangle` points down at 0 (`M0,4 L16,4 L8,12`); the catalog text (COLLAPSIBLE-GROUP README line 55) says right in LTR, left in RTL, down when expanded. expected: same three values | actual: same three values.
- PASS - `tools/port-ledger/check-scope.ps1`: `OK: every in-scope upstream item is ported or decided (376 ported, 19 decided)`. expected: exit 0 | actual: exit 0.
- PASS - `tools/docs/check-docs.ps1` (this spec is in the corpus): `docs-check: PASS (30 records, 90 corpus files ..., 0 baselined)`. expected: exit 0 | actual: exit 0.
- PASS - `spec_catalog/validate` (10 OK, 0 WARN, 0 FAIL) and `spec_catalog/release-queue -Validate` (`OK - 40 ticket(s), no drift`), both exit 0; probe invariant: no `S0039` line under `phone/src` or `wear/src`, and the ticket is not in the needs-manual-test status. expected: holds | actual: holds.
- EXEMPT - compile gate: no compiled source was edited, so `commands.compileCheck` is not owed; not run.
- EXEMPT - user-facing surfaces, parity matrix rows and CHANGELOG: nothing user-visible changed (scope statement in 3.1).
- RELEASE - the file as it stands is built and unit-tested by the release run: `.\gradlew.bat :phone:assembleDebug` and `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest`. Not run here, both above 5 s.
- RELEASE - RTL chevron direction on a device or emulator (S0007): `check-drift.ps1` and the code reading above prove the ledger and the values, not a rendered screen. Not run here.

### Action items
1. none for this ticket. Out of scope, seen while checking: `check-local-divergence.ps1 -RequireClassified` exits 1 on 2026-11-14 for one unclassified edit of `phone/src/test/kotlin/com/sza/deviceinfo/domain/usecase/GatherSystemInfoUseCaseTest.kt`; it is not part of this file. S0037 edited the test and records no classification, so nothing owned it: parked: S0041 (Draft), which must land before the release start.

### Manual / on-target
- none for this ticket; the RTL device scenario stays with S0007.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14
