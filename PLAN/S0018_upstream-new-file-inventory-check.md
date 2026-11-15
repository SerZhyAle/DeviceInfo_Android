# S0018_upstream-new-file-inventory-check

**Status:** Implemented
**Status note:** Scope check and decision recorder built and self-tested; no compiled source edited (no compile command declared); first run classified every in-scope item.
**Created:** 2026-11-13
**Complexity:** medium - assessed at the spec pass 2026-11-14: two new data files, three new scripts and a shared helper under tools/port-ledger, twelve new ledger rows, no compiled source and no wire or contract change; the one real risk was two writers on the same files (recorded below)

## 0. Owner request (verbatim)

Owner's positions and order, 2026-11-13, verbatim (chat, Russian):

Positions:
"Так.
Идея этого приложения была чтобы весь функционал по суб-программы Device Infoна телефоне (любом андроид устройстве), часах , который реализован в FMS_A был представлен в виде самостоятельных приложений android,  которые могут заинтересовать пользователя, которому не интересен весь остальной функционал FMS_A
Но при этом эти приложения не только выглядят более-менее одинаково, но и развиваются вместеи новый/исправленный функционал обновляется/исправляется в них паралельно, они пересекаются по документации, принадлежат общему семейству программ и связаны канонами и контрактами.
Исследуй всё ли верно в моих мположениях?"

Order:
"Создай такие спецификации в рамках этого продукта, которые приведут его к вышеописанному заказанному состоянию"

Correction order, 2026-11-13, verbatim (chat, Russian), given after these tickets were captured:
"правильно ли я понял, что по производству всех заказаных задач
это приложение будет иметь весь функционал по соответствующей суб-программы телефона (любом андроид устройстве), часах , который реализован в FMS_A был представлен в виде самостоятельных приложений android,  которые могут заинтересовать пользователя, которому не интересен весь остальной функционал FMS_A
Но при этом эти приложения будут выглядеть более-менее одинаково, развиваться вместе и новый/исправленный функционал обновляется/исправляется в них паралельно, они пересекаются по документации, принадлежат общему семейству программ и связаны канонами и контрактами.
Поправь спецификации чтобы было именно так"

This ticket's problem and done criteria (sections 1 and 2) were written from that message. The acceptance of the whole set is ticket target-state-acceptance (S0027).

Twelve tickets were captured by the two orders: bugfix-contract-pointers-stale (S0016), payload-parity-test (S0017), upstream-new-file-inventory-check (S0018), reverse-port-divergence-ledger (S0019), ship-together-surfaces-manifest (S0020), phone-wear-feature-parity-matrix (S0021), phone-wear-visual-identity (S0022), unified-ui-conformance-evidence (S0023), in-app-help-phone-and-wear (S0024), register-product-in-contract-catalog (S0025), canon-resync-stamp (S0026), target-state-acceptance (S0027).

Agent findings below are not the owner's words. They come from the investigation of 2026-11-13; every fact cites the file it was read from.

Position this ticket serves: the full System Info functionality of FMS_A is represented here, and a new or fixed function there is updated here (FMS_A to DeviceInfo direction).

Problem: tools/port-ledger/check-drift.ps1 only re-hashes files that are already in docs/port-ledger.jsonl, so a file added to the upstream System Info after the port is invisible to every automatic check. CLAUDE.md section 2 rule 2 says the class list is "a starting list, not a baseline", but nothing mechanical enforces a fresh inventory.

Evidence (read 2026-11-13):
- tools/port-ledger/README.md: "The ledger holds only files that were ported."
- A manual inventory of FastMediaSorter_mob_v2 (modules app_v2 and wear, files whose path or name contains systeminfo or SystemInfo, kt and xml, excluding build output): 58 files, all of them in the ledger; the ledger has 92 rows (46 app_v2, 46 wear). So there is no gap today, but only because a person looked.
- The upstream tree contains copies under temp/scratch/wt-sitemap and temp/archive; any scope scan must exclude the upstream's temp/ directory or it reports phantom files.
- Strings are ported by key selection and have no ledger row, so a string key added upstream for System Info is not covered either.

Wanted:
1. The port scope written down as data in this repository (for example docs/port-scope.json): directories, name patterns, the noLegal source set, wear data/wear/AndroidWearSystemInfo*, the string-key prefixes (sysinfo_*) and the exclusions (temp/, build output).
2. A check script under tools/port-ledger/ that scans the upstream checkout (read-only, never writes it) against that scope and lists every upstream file or string key that is in scope but neither in the ledger nor on a "decided not to port" list with a reason; exit 0 clean, 1 at least one unclassified item, 2 cannot run.
3. A way to classify an item: port it (record-port.ps1) or decide it (a recorded reason pinned to the upstream version, like -Decide for drift).
4. Self-test in test-port-ledger.ps1 style on a throw-away tree, and the new check added to the fast tier and release-start lists in CLAUDE.md section 6.
5. The result of the first run recorded in the ticket as the fresh inventory that rule 2 asks for.

Fast tier only; nothing above 5 seconds.


## 1. Problem

The owner's promise is that everything the Device Information part of FMS_A does is available in these apps. Today that holds because someone counted by hand. If FMS_A adds a function after the port, no check notices, so the promise can quietly stop being true.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- docs/port-scope.json states the scope of the port as data (include globs; exclude entries, each with a reason), in the form of the Tourist Android PORT-LEDGER proposal of 2026-11-13 (rule-adoption folder of the catalog).
- `pwsh -NoProfile -File tools/port-ledger/check-scope.ps1` exits 0 on the current tree and prints the counts of in-scope upstream files, ledger rows and decided items; its self-test shows exit 1 when an in-scope upstream file is missing from the ledger.
- The first run is pasted in the ticket as the fresh inventory that CLAUDE.md section 2 rule 2 asks for; every in-scope upstream item is ported, decided with a reason, or has a Draft ticket.
- The upstream checkout is only read during the run: the ticket records that no file there changed.
- The check reports an in-scope upstream file with no ledger row and no exclusion as NEW SOURCE and fails on it, as rule 5 of that proposal. It is built on the row fields and statuses of the two PORT-LEDGER proposals of 2026-11-13 (Filler Android in the catalog's _meta folder, Tourist Android in rule-adoption); where they differ the catalog owner's decision wins, and the ticket records which reading it followed.
- The command is in the fast tier and release-start lists of CLAUDE.md section 6.

## 3. Approach

### 3.1 Scope

Contract boundary: none crossed. PORT-LEDGER 0.1 (catalog, draft, owner shared) is consumed, not amended; no format
another product reads is written. No compiled source, resource or wire shape changes, so there is no compile step.

Changes, all tracked:

- `docs/port-scope.json` (new): the scope as data. 53 include globs (System Info sources and tests of `app_v2` and
  `wear`, the files ported as their dependencies, the System Info layouts, drawables, menu, colour and help pages by
  name), 4 exclusions each with a reason (`temp/**`, `**/build/**`, and the two `WearDataLayerPaths.kt` files that are
  rewritten on purpose), and a `strings` block (prefixes `sysinfo_`, `system_info_`, `nolegal_diag_`).
- `docs/port-decisions.jsonl` (new): 19 decisions not to port, 10 files and 9 string keys, each with a reason, a file
  decision pinned to the upstream SHA-256 and a string decision pinned to the key's value.
- `tools/port-ledger/_scope.ps1` (new, shared core: glob engine, scope and decisions readers and writer, upstream file
  and string-key scans), `check-scope.ps1` (new, the check), `record-decision.ps1` (new, the classifier),
  `test-port-scope.ps1` (new, self-test, 36 expectations).
- `tools/port-ledger/_ledger.ps1`: the upstream root is found as argument, then `SZA_PORT_SOURCE_ROOT`, then
  `DEVICEINFO_FMS_ROOT`, then the default (PORT-LEDGER rule 8). `docs/port-ledger.jsonl`: 12 new rows (resources).
- `tools/port-ledger/README.md`, `docs/README.md`, `CLAUDE.md` sections 2, 5 and 6: the scope, the two scripts and the
  fast-tier and release-start entries.

Deliberately not changed: the upstream checkout (only read), the ported code and resources, `check-drift.ps1`,
`record-port.ps1`, `.sza-profile.json` (the optional `extraction` block of HARNESS-PROFILE 0.17 is not added; the tools
carry their own defaults), and no `docs/contracts/PORT-LEDGER.md` pointer (registering the product against the contract
is S0025).

Reading of the two proposals: followed the catalog's decision, `PORT-LEDGER` 0.1 in `P:/Contracts/port-ledger/`, which
merged them. Rule 5: scope file with `include` and `exclude` (reason required), an in-scope file with no row and no
exclusion is `NEW SOURCE` and fails. Rule 7: exit 0 in step, 1 an open item, 2 cannot verify. Rule 8: source root order.
Where the proposals differ the contract took Tourist's scope file and Filler's single source-root variable; the statuses
`LOCAL EDIT` and `kind: partial` of rules 2 and 4 are not built here (the divergence ledger is S0019), and the existing
`check-drift.ps1` keeps its own status names (`in step`, `decided`).

### 3.2 Open questions

None open. Answered:

- Which proposal wins: the catalog's merged contract, see 3.1.
- Do resources and help pages belong in the scope: yes, the ticket's own evidence counted 58 Kotlin files by name, but the
  System Info layouts, drawables, menu, colour and help pages exist upstream under `system_info`, `sysinfo` and
  `system-info` names, and a changed layout is the same blind spot as a changed class.
- Where a deliberate not-port lives: a permanent one (a file rewritten on purpose) is an `exclude` entry with a reason,
  as the contract offers; one that is deferred or that may be revisited is a decision in `docs/port-decisions.jsonl`,
  pinned to the upstream version so that the next upstream change reopens it.

### 3.3 Owner inputs (Approval gate)

None needed. The reversible choices taken in this pass are listed under Assumed.

### Assumed (unattended, 2026-11-14)

Each is reversible inside the ticket; the owner may overrule any of them.

- A decisions file of its own, `docs/port-decisions.jsonl`, beside the ledger and the scope. Alternative: write every
  not-port as an `exclude` entry (contract-native, but not pinned to a version, so a later upstream change would stay
  silent).
- Resources and help pages are in scope. Alternative: keep the scope to Kotlin sources, which leaves a changed layout,
  drawable or menu invisible.
- The 12 resource rows were recorded on 2026-11-14 after a line-level comparison with the copies in `phone/src/main/res`:
  the drawables are identical, the layouts differ by the renamed package, style and text-appearance names and one dropped
  upstream comment, and the menu carries one extra item (`action_system_info_notifications`) and lacks one upstream
  comment. The row's hash is the
  upstream version of today, not of the original port; the port date of these rows is the recording date. Alternative:
  leave the resources unledgered.
- Both `WearDataLayerPaths.kt` files are exclusions with a reason, not pinned decisions: the upstream object is a
  catalogue of about sixty `/fms/` routes that grows with every upstream sub-program, so a pinned decision would reopen on
  each unrelated route. Alternative: two pinned decisions, re-pinned on every upstream change.
- The help pages and their six screenshots are decisions that name S0024 (a Draft that decides the in-app help of phone and
  watch), not a new ticket, so the "has a Draft ticket" part of the done criterion is met by S0024.
- A scope whose globs match no file, or a strings scan that matches no resource file, exits 2. Alternative: exit 0 with a
  warning, which lets a moved or wrong upstream root pass as a clean check.
- The string watch is by key prefix only. A key that a ported file uses and that carries none of the three prefixes is not
  seen. Alternative: derive the watched keys from the `R.string` references of the ported sources, a larger tool.
- The 24-run extension that another writer made to `test-port-ledger.ps1` was replaced by the in-process
  `test-port-scope.ps1` (0.85 s), and `test-port-ledger.ps1` was restored to its original 8-run form (2.74 s). Alternative:
  keep the extension, which is longer than 5 s, unmeasured and so a release-tier run.

### 3.4 Concurrent writer (audit trail)

While this pass ran under its lease (`run-spec-queue pq3`), another writer with no lease and no entry in the shared chat
created `check-scope.ps1`, `record-decision.ps1`, the first `docs/port-scope.json`, the `SZA_PORT_SOURCE_ROOT` change in
`_ledger.ps1` and a scope extension of `test-port-ledger.ps1` in the same minutes (about 23:54 to 00:02 local). It was not
identified; the only live Claude process for this ticket was this pass, and the peer deviceinfo session wrote nothing here.
This pass's write of `_scope.ps1` at 23:58:49 overwrote that writer's version of the file (the tool reported an update, not a
creation); it was rewritten at 00:00:44 to the functions the writer's two scripts call, and two defects of those scripts
were fixed in place: a typed parameter and a local variable of the same name (`$Scope` and `$scope`, `$Decisions` and
`$decisions`; PowerShell variables are case-insensitive) turned the parsed scope and the decision list into strings and made
every run exit 2. After 00:03:19 only this pass wrote to the files above. What the other writer may still hold in an
unsaved state is unknown.

### Related tickets

S0024 (in-app help; the help pages and screenshots are decided there), S0019 (reverse divergence ledger; `LOCAL EDIT`),
S0025 (registers the product against PORT-LEDGER), S0027 (acceptance of the whole set). No ticket blocks this one.

## 4. Fresh inventory (CLAUDE.md section 2 rule 2)

First run of `pwsh -NoProfile -File tools/port-ledger/check-scope.ps1` on 2026-11-14, against the live working tree of
`P:\ANDROID\FastMediaSorter_mob_v2`, before any item was classified (exit 1, 2.2 s):

```
In-scope upstream files: 114 (ported 92, decided 0, STALE DECISION 0, NEW SOURCE 22)
In-scope upstream string keys: 281 (ported 272, decided 0, STALE DECISION 0, NEW SOURCE 9)
OPEN: 31 in-scope upstream item(s) need a port (record-port.ps1) or a decision (record-decision.ps1).
```

The 31 open items: 9 help files (`app_v2/src/main/assets/help/{en,ru,uk}/system-info.html` and six
`help/img/system-info-{en,ru,uk}-{dark,light}.webp`), 13 resources (`color/system_info_row_shade.xml`, five drawables,
three layouts, three layout-land, `menu/menu_system_info.xml`) and 9 string keys (seven `nolegal_diag_section_*`,
`sysinfo_field_flavor`, `sysinfo_field_camera_app_view`). The scope of the first draft had 93 files; the wear
`WearDataLayerPaths.kt` in it had no ledger row, and the phone one was not in it.

Disposition of every in-scope item:

| Items | Count | Disposition |
| --- | --- | --- |
| Kotlin sources and tests already in the ledger | 92 | ported (rows recorded by the earlier port tickets); `check-drift.ps1`: in step |
| Resource files copied to the phone (5 drawables, 3 layouts, 3 layout-land, 1 menu) | 12 | ported: ledger rows recorded with `record-port.ps1`, see Assumed for the basis |
| `color/system_info_row_shade.xml` | 1 | decided: carried as plain values in `values/colors.xml` and `values-night/colors.xml` |
| Help pages (3) and their screenshots (6) | 9 | decided: not ported yet, S0024 decides the form and records the port |
| `WearDataLayerPaths.kt`, upstream phone and watch | 2 | excluded with a reason: rewritten on purpose under `/deviceinfo/` (DATA-LAYER-PAIR, S0005) |
| String keys declared in this repository | 272 | ported |
| `nolegal_diag_section_*` | 7 | decided: carried as `sysinfo_section_*` in the restricted flavor (S0009) |
| `sysinfo_field_flavor`, `sysinfo_field_camera_app_view` | 2 | decided: not ported, recorded in the KDoc of `GatherSystemInfoUseCase` |

After the classification the same command exits 0: `In-scope upstream files: 114 (ported 104, decided 10, STALE DECISION 0,
NEW SOURCE 0)`, `In-scope upstream string keys: 281 (ported 272, decided 9, STALE DECISION 0, NEW SOURCE 0)`. The ledger
holds 104 rows and `check-drift.ps1` exits 0 (104 in step). Every in-scope item is ported, decided with a reason or
excluded with a reason; none is left to a new ticket, so no Draft was filed.

What the first run showed that a person counting Kotlin files had missed: the System Info layouts, drawables, menu and
colour, and the help pages, had no ledger row, so a change upstream to any of them was invisible to `check-drift.ps1`.
They are watched now. Limits that remain, stated so they are not read as coverage: the string watch sees keys by prefix
only; the check reads the live upstream working tree, which has uncommitted edits of its own, so an upstream file edited
and not yet committed counts as changed; a ported file whose destination was edited here is not reported
(`LOCAL EDIT` is S0019).

The upstream checkout was only read. The scripts open it for reading and hash it; this pass wrote nothing under
`P:\ANDROID\FastMediaSorter_mob_v2`. Checked near the end: no file under its `app_v2/src` or `wear/src` had a modification
time within the 40 minutes before the check, a window that covers the whole pass (its own sessions changed only its
`PLAN/`).

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14

## Last Audit

**Date:** 26-11-14 00:12 | **Mode:** fast and static | **Outcome:** Implemented; nothing above 5 s was run
**Counts:** PASS 7 | WARN 2 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 1

- PASS - Scope as data: `docs/port-scope.json` holds 53 include globs and 4 exclusions, each with a reason; the reader refuses an exclusion without one (self-test case "an exclusion without a reason exits 2 (PORT-LEDGER rule 5)").
- PASS - `pwsh -NoProfile -File tools/port-ledger/check-scope.ps1`: exit 0, 2.21 s, `In-scope upstream files: 114 (ported 104, decided 10, STALE DECISION 0, NEW SOURCE 0)`, `In-scope upstream string keys: 281 (ported 272, decided 9, STALE DECISION 0, NEW SOURCE 0)`; it prints the counts of in-scope files, ledger rows (104) and decisions (19).
- PASS - `pwsh -NoProfile -File tools/port-ledger/test-port-scope.ps1`: exit 0, 0.82 s, 36 expectations held, among them "in-scope file with no ledger row exits 1 (NEW SOURCE)", "file changed after its decision exits 1 (STALE DECISION)", "unported string key exits 1", "a scope that sees nothing exits 2, never a clean 0" and the refusals with exit 2.
- PASS - The first run is pasted in section 4 as the fresh inventory (31 open items before, 0 after); every in-scope item is ported, decided with a reason or excluded with a reason.
- PASS - Upstream only read: no file under `app_v2/src` or `wear/src` of the FastMediaSorter checkout had a modification time within the 40 minutes before the check; the scripts open it for reading and hashing only.
- PASS - The reading of the two proposals is recorded in 3.1 (catalog `PORT-LEDGER` 0.1, rules 5, 7 and 8). `CLAUDE.md` section 6 names `check-scope.ps1` in the fast tier with "at every release start", plus its self-test; sections 2 and 5 and `tools/port-ledger/README.md` and `docs/README.md` describe the scope, the decisions file and the two scripts.
- PASS - Gates re-run at the end: `spec_catalog/validate` exit 0 (9 OK, 1 WARN) 0.84 s; `release-queue -Validate` exit 0 (30 tickets, no drift) 0.78 s; `check-compliance.ps1` exit 0 (0 errors, 2 warnings) 0.76 s; `tools/contracts/check-pointers.ps1` exit 0, 0 mismatches; `check-drift.ps1` exit 0 (104 in step) 0.35 s; `test-port-ledger.ps1` exit 0, 2.91 s (it covers the changed `_ledger.ps1`).
- WARN - Concurrent writer: another writer with no lease edited `check-scope.ps1`, `record-decision.ps1`, `port-scope.json`, `_ledger.ps1` and `test-port-ledger.ps1` in the same minutes and was never identified (3.4); none of those files changed after 00:03:19 except by this pass, but what that writer holds unsaved is unknown. Re-read the tree before relying on this verdict.
- WARN - Unrelated gate warnings, outside S0018: the validator's captured complexity line of S0022, the stale canon stamp (`SZA-CANON03`) and the archived S0001 naming the catalog by path (`SZA-CTR02`).
- EXEMPT - Compile and device checks: no compiled source, resource or manifest changed, so no compile step applies (`commands.compileCheck` is absent from `.sza-profile.json` in any case) and there is nothing to run on a device or emulator.
- EXEMPT - User-facing surfaces, listing and changelog: the change is repository tooling and records; no product behaviour or text changes.
- RELEASE - At the release start run `pwsh -NoProfile -File tools/port-ledger/check-scope.ps1` and `pwsh -NoProfile -File tools/port-ledger/check-drift.ps1` and name both results in the release verdict (PORT-LEDGER rule 9); every `NEW SOURCE`, `STALE DECISION` or `DRIFT` ends ported or decided first. This is the routine of `docs/RELEASE.md`, not a skipped rung.

### Manual / on-target
- None.
