# S0016_bugfix-contract-pointers-stale

**Status:** Implemented
**Status note:** Pointer re-read 2026-11-13 against the catalog; IN-APP-HELP.md renamed to CONTEXT-HELP.md (no such catalog id); /fms/ settled against the upstream WearDataLayerPaths; S0007/S0004/S0012/S0010/S0024 corrections; tools/contracts/check-pointers.ps1 added to the fast tier and the release start
**Created:** 2026-11-13
**Complexity:** medium - assessed at implementation: five pointer files re-read, one renamed, five tickets corrected, one new fast-tier script; no build, no contract text touched. Read against the plan: the level stands.

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

Position this ticket serves: "связаны канонами и контрактами".

Problem: the contract pointers in docs/contracts/ do not match the shared contracts catalog, one of them cites an id that does not exist there, and S0007 records them as verified.

Evidence (read 2026-11-13):
- docs/contracts/IN-APP-HELP.md: id IN-APP-HELP, "Version 0.8, draft .. read 2026-11-11". In the catalog (in-app-help/README.md) the contract is id CONTEXT-HELP, version 0.3, draft. The string IN-APP-HELP occurs nowhere in the catalog; only the folder is named in-app-help.
- docs/contracts/INPUT-PARITY.md: version read 0.4. Catalog input-controls/README.md: INPUT-PARITY 0.6, draft (INPUT-CHORD 0.5 is a different contract on the same page).
- docs/contracts/UNIFIED-UI.md: BUTTONS read 2.0, catalog buttons/README.md says 2.1. UI-SIZING 1.1 and COLLAPSIBLE-GROUP 1.1 match. PACKAGE-VERSIONING 0.6 matches.
- docs/contracts/DATA-LAYER-PAIR.md says the /deviceinfo/ prefix isolates the product from FastMediaSorter's "/fms/" routes; S0007 says "/fastmediasorter/". Only one can be the upstream's real prefix.
- S0007 (status BlockNeedUserTest) records "all 5 contract pointers verified" and a contract line naming IN-APP-HELP as verified. That does not hold: the id is wrong and the help the contract asks for is not built (see ticket in-app-help-phone-and-wear).

Wanted:
1. Every pointer re-read against the catalog on the day of the ticket: correct id, version and date read; for each version step since the one previously read, one line on what it adds or changes for this product (a bump can add duties).
2. Every mention of the wrong id fixed (CLAUDE.md section 5, docs/, PLAN/ tickets where editable through the ticket process).
3. The /fms/ versus /fastmediasorter/ difference settled against the upstream's own Data Layer paths (read-only checkout of FastMediaSorter_mob_v2) so both documents say the same true thing.
4. S0007's contract line corrected so it no longer claims a verification that did not happen.
5. A cheap repeatable check so this does not recur: a script under tools/ that reads each pointer's id and version and the catalog's contract front matter and reports mismatches (exit 0 clean, 1 mismatch, 2 catalog unreachable), added to the fast tier list in CLAUDE.md section 6 and to the release-start list.

Fast tier only; nothing above 5 seconds.


## 1. Problem

The list of shared contracts this product obeys is partly out of date and names one contract that does not exist, so the product is not bound to the contracts the way its own records say. The owner's wording is that the apps are "связаны канонами и контрактами"; that has to be true when it is read from the catalog's side as well.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- `pwsh -NoProfile -File tools/contracts/check-pointers.ps1` exits 0: every pointer in docs/contracts/ carries the id, the version and the read date of the catalog's front matter read the same day (exit 1 mismatch, exit 2 catalog unreachable).
- A search for the id `IN-APP-HELP` over CLAUDE.md, docs/ and the non-archived PLAN/ files finds no live citation (a history line may quote it as the old name); the contract is cited as CONTEXT-HELP.
- The duty text of each pointer is the contract's own words and no more: docs/contracts/INPUT-PARITY.md promises touch, keyboard, D-pad and mouse "on phone and on watch", while the watch's duties are read from the contract's own watch column (the rotary crown, INPUT-PARITY 0.6 section 4) and not copied from the phone's.
- The Data Layer prefix named in docs/contracts/DATA-LAYER-PAIR.md and in S0007 equals the constant in the upstream's own Data Layer paths file (read only); the command that compares them is recorded in the ticket.
- S0007's contract line and its counts (86 ledger rows against the 92 the ledger holds now) are corrected or dated.
- `check-compliance.ps1` from the plugin root reports no SZA-CTR02 for a live ticket (S0012 names the catalog by a drive path and is fixed; the archived S0001 is history and the ticket records why it stays).
- The new script is listed in the fast tier and release-start lists of CLAUDE.md section 6 with its measured time; `spec_catalog/validate` and `spec_catalog/release-queue -Validate` exit 0.

## 3. Approach

### 3.1 Scope

What changed:

- Every pointer in `docs/contracts/` re-read against the catalog on 2026-11-13, with the version each pointer moves to and one line per version step since the previously read one (see the implementation record below). The catalog had moved on every contract since the pointers were captured, and 0.4/0.7/2.2/1.2/1.2/0.8 all carry Wear OS duties this product asked for (S0024's proposal).
- The pointer file `docs/contracts/IN-APP-HELP.md` renamed to `docs/contracts/CONTEXT-HELP.md` and rewritten: the captured id `IN-APP-HELP` is no id of the catalog and never was.
- Mentions of the wrong id fixed where live: CLAUDE.md section 5, `docs/README.md`, S0007 (dated corrections), S0010, S0024. The closed S0004 keeps its history mentions as quotes of the old name, with a dated correction block of its own.
- The `/fms/` versus `/fastmediasorter/` difference settled against the upstream's own Data Layer paths (read-only checkout): every route in both upstream `WearDataLayerPaths` files sits under `/fms/`; DATA-LAYER-PAIR.md's `/fms/` was the true one. S0007's `/fastmediasorter/` line corrected with a dated note; DATA-LAYER-PAIR.md carries the settling line.
- S0007's contract line, its done criterion and its audit rung corrected (dated) so they no longer claim a contract verification that did not happen; the 86-ledger-rows counts dated (86 at the audit moment, 92 on 2026-11-13).
- S0012's drive-path naming of the catalog removed (SZA-CTR02); the archived S0001's stays as history, and the reason is recorded here.
- New fast-tier check `tools/contracts/check-pointers.ps1` (exit 0 clean, 1 mismatch, 2 catalog unreachable), listed in CLAUDE.md section 6 with its measured time and the release-start mark.

What deliberately does not change:

- No contract text, here or in the catalog: the pointer is a reader's record, the catalog side is the catalog session's.
- The archived S0001 keeps its drive-path mention: it is history, not a live citation.
- The help the CONTEXT-HELP contract asks for is not built here - that is S0024.
- The catalog registry row for the two DeviceInfo families is not filed here - that is S0025.
- The stale canon adoption stamp (compliance gate's SZA-CANON03 warning) is not touched here - that is S0026.
- The "Compatibility across package versions" section already standing in DATA-LAYER-PAIR.md (uncommitted work of S0017's line) is left as it stands.

### 3.2 Open questions

None. Every question of the capture was answered by the re-read itself.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0024 (the CONTEXT-HELP duties it builds; the proposal that moved the catalog to 0.4), S0025 (the registry row), S0026 (the canon stamp), S0017 (the payload compatibility lines already in DATA-LAYER-PAIR.md), S0027 (accepts the whole set).

## Implementation record (2026-11-13)

Pointer re-read, each against the catalog's own front matter, same day:

| Pointer | Was (capture) | Now (catalog 2026-11-13) | Version steps since the last read, one line each |
| --- | --- | --- | --- |
| `CONTEXT-HELP.md` (was `IN-APP-HELP.md`) | `IN-APP-HELP` 0.8, draft, read 2026-11-11 - no such id in the catalog | `CONTEXT-HELP` 0.4, draft | 0.3 (2026-11-12): the help button opens the page top, never the button's own anchor. 0.4 (2026-11-13): a Wear OS app screen is a surface with an inherited row by default; DeviceInfo Android joins the consumers; the id is `CONTEXT-HELP`. |
| `INPUT-PARITY.md` | 0.4, draft, read 2026-11-11 (already stale at capture - 0.5 was out since 2026-10-29) | 0.7, draft | 0.5 (2026-10-29): "applicable" defined, the viewer table governs viewers, `help`/`F1` added to the vocabulary. 0.6 (2026-11-12): the rotary crown (Wear OS) column, seeded - the watch's own duties. 0.7 (2026-11-13): the touch-locked screen as a permanent supported variant - no duty here until such a screen ships. |
| `UNIFIED-UI.md` - BUTTONS | 2.0, read 2026-11-11 | 2.2, active | 2.1 (2026-11-12): the touch naming sentence binds every icon-only command on a touch surface; the accessible name is the assistive-technology route, a `title` is not a touch route. 2.2 (2026-11-13): the contract binds Wear OS app surfaces; toolkit chips and buttons are a permanent variant. |
| `UNIFIED-UI.md` - UI-SIZING | 1.1, read 2026-11-11 | 1.2, active | 1.2 (2026-11-13): Wear OS app surfaces bind under a watch profile; toolkit chips, buttons and lists on a round display are a permanent variant recorded in the product's size-profile record. |
| `UNIFIED-UI.md` - COLLAPSIBLE-GROUP | 1.1, read 2026-11-11 | 1.2, active | 1.2 (2026-11-13): on a Wear OS round display the marker stands at the reading-start side of the toolkit's safe area; whole-header activation at the touch baseline. |
| `PACKAGE-VERSIONING.md` | 0.6, draft, read 2026-11-10 | 0.8, draft | 0.7 (2026-11-13): this product's band table accepted into rule 3 - phone band 0..5, watch band 6..9 under the shared id; the proposal the pointer named as open is folded in. 0.8 (2026-11-13): Filler Android's families registered - no duty change for this product. |

The `/fms/` settling, the commands that compare the declaration against the upstream's own paths (both read-only; run 2026-11-13):

- `grep -n 'system_info' "P:\ANDROID\FastMediaSorter_mob_v2\app_v2\src\main\java\com\sza\fastmediasorter\service\WearDataLayerPaths.kt"` - `SYSTEM_INFO_REPORT = "/fms/watch/system_info_report"` (line 156), `SYSTEM_INFO_REPORT_ACK = "/fms/phone/system_info_report_ack"` (line 159).
- `grep -rn -o -E '"/[a-z_/]+[a-z]"' ... wear/src/main/.../WearDataLayerPaths.kt` - every route in the wear-side file under `/fms/` (30 distinct routes sampled, all `/fms/...`).
- `grep -c 'fms/'` over the phone-side file: 82 path constants, all `/fms/`; a search for `/fastmediasorter/` as a route prefix over both upstream source trees finds nothing.

Ledger counts: 86 rows at S0007's audit moment (2026-11-11 04:05); 92 rows on 2026-11-13 (16 ported 2026-11-10, 70 on 2026-11-11 - six wear test-suite rows after the audit - 3 on 2026-11-12, 3 on 2026-11-13).

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14

## Last Audit

**Date:** 2026-11-13 | **Mode:** static | **Outcome:** all done criteria verified in this pass
**Counts:** PASS 7 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 0

Evidence, each run fresh in this pass (expected | actual):

1. `pwsh -NoProfile -File tools/contracts/check-pointers.ps1` | exit 0; 6 pointer(s) checked, 1 skipped (DATA-LAYER-PAIR, local declaration), 0 mismatch(es), 0.2 s. Exit 1 and exit 2 verified separately against a skeleton catalog under the temp directory (6 version mismatches - exit 1; missing catalog - exit 2); the repo tree was not touched for those runs. PASS.
2. Search for `IN-APP-HELP` over CLAUDE.md, docs/ and the non-archived PLAN/ | every remaining occurrence sits in a dated correction or history line quoting the old name (CLAUDE.md section 5's rename clause, the pointer's own history line, S0007's and S0004's correction blocks, S0024's and S0010's bracketed notes, this ticket's evidence); no live citation remains, and the contract is cited as `CONTEXT-HELP`. PASS.
3. Duty text of each pointer is the contract's own words | `INPUT-PARITY.md` promises the phone's touch, keyboard, mouse and D-pad columns for the phone and reads the watch's duties from the contract's own watch column (the seeded rotary crown, 0.6 section 4: a turn scrolls, `volume` in a player view, `confirm` is a tap, one turn one action, never the only route), not from the phone's columns. PASS.
4. The Data Layer prefix | DATA-LAYER-PAIR.md's `/fms/` equals the constant in the upstream's own paths files (the commands above); S0007's `/fastmediasorter/` corrected with a dated note; the settling recorded in DATA-LAYER-PAIR.md. PASS.
5. S0007 | contract line, done criterion 4 and audit rung 4 carry dated corrections that no longer claim a pointer verification; the 86-row counts dated against the 92 the ledger holds now. PASS.
6. `check-compliance.ps1 -RepoRoot P:\ANDROID\deviceinfo_mob` | 0 error(s); SZA-CTR02 for the live S0012 gone (drive path removed); the only SZA-CTR02 left is the archived S0001 - history, kept because a correction would rewrite what the archived ticket actually read on the day, and the gate's allowed-file list cannot include archive files; SZA-CANON03 (stale adoption stamp) is S0026's. PASS.
7. The new script in CLAUDE.md section 6 | listed in the fast tier with its measured time (0.2 s, 2026-11-13) and the release-start mark ("at every release start"); `spec_catalog/validate` exit 0 (9 OK, 1 WARN - the pre-existing S0019/S0022 complexity lines, not this ticket's) and `spec_catalog/release-queue -Validate` exit 0 (30 tickets, no drift). PASS.

EXEMPT: no contract text mutated (pointer side only); the catalog itself is outside this repository and only read. RELEASE: nothing here is a build or test run - all checks are the fast tier.

