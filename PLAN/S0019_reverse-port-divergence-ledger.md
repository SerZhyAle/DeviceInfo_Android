# S0019_reverse-port-divergence-ledger

**Status:** Implemented
**Status note:** Reverse-port ledger and fast script checks implemented; Android build and tests remain release tier.
**Created:** 2026-11-13
**Complexity:** medium (assessed against the plan 2026-11-14) - an additive ledger field and backfill, a local-edit gate and classification store, a tracked source notice, and script tests; no application or shared-contract change

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

Position this ticket serves: "новый/исправленный функционал обновляется/исправляется .. паралельно" (DeviceInfo to FMS_A direction), and "самостоятельные" without losing the shared origin.

Problem: the port is one-way. FMS_A to DeviceInfo has a ledger and a drift check; DeviceInfo to FMS_A has nothing, so a fix or a new metric made here never reaches FMS_A and nothing says which local edits are deliberate and which are fixes FMS_A would want.

Evidence (read 2026-11-13):
- docs/port-ledger.jsonl rows carry source, sourceSha256, destination, portedOn, optional carriedOn and a pinned decision; no hash of the destination file, so a local edit of a ported file is not detectable.
- DeviceInfo-only changes already exist: the store and restricted flavors (S0009), extended metrics beyond the port (S0010, Partial), the notification-permission request (S0011), the Hilt and Kotlin conversion of every ported file.
- CLAUDE.md section 2 rule 1: the upstream checkout is never modified from this repository. So the reverse flow cannot be a write into FMS_A; it has to be detect, record, notify.
- The portfolio registers FMS_A as pq key fms-a (P:\ANDROID\FastMediaSorter_mob_v2); notice conventions between projects exist (see the S0015 notice from streams-mob and the hub tickets named in CLAUDE.md section 3).

Open question for the owner (decide before the plan pass): what is the intended relation after the port?
 (a) two-way, deliberate: improvements found in either product are carried to the other, each side by its own ticket;
 (b) one-way with a record: FMS_A keeps taking nothing from DeviceInfo, and the divergence is only recorded so it is known;
 (c) FMS_A's System Info later becomes a hand-off to the standalone apps (an FMS_A decision, out of this repository's reach).
The answer is written into CLAUDE.md section 2 as a standing rule.

Wanted (shape depends on the answer, but at least):
1. destinationSha256 (and the date) recorded per ledger row by record-port.ps1, without breaking check-drift.ps1 or test-port-ledger.ps1; existing rows backfilled from the current files and a note that the backfill is a baseline, not a history.
2. A check (tools/port-ledger/check-local-divergence.ps1) listing ported files whose destination changed since the recorded hash and requiring each to be classified: deliberate difference (recorded in the KDoc next to the code, per section 7 port conventions), candidate for FMS_A (needs a notice), or not applicable.
3. The notice path for a candidate: what is filed, where (a ticket in the fms-a project through the owner's order, or a file under docs/), and how its state is tracked here.
4. The DeviceInfo-only features listed once as a baseline (S0009, S0010, S0011 and the rest found by the check), each classified.

Fast tier only; nothing above 5 seconds.


## 1. Problem

A fix or a new function made in these apps stays in these apps: nothing records what differs from FMS_A, and there is no way to hand a fix back. The owner's wording "новый/исправленный функционал обновляется/исправляется в них паралельно" is covered for the phone and the watch by other tickets; for the relation with FMS_A it depends on what the owner wants that relation to be, which the first question of this ticket asks.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- The owner's answer to the question in 3.2 is recorded there and written into CLAUDE.md section 2 as a standing rule.
- Every ledger row carries `destinationSha256`, the hash of the destination file as ported or carried (the field name of the Tourist Android PORT-LEDGER proposal of 2026-11-13); `check-drift.ps1` still exits 0 and `test-port-ledger.ps1` passes.
- The check reports `LOCAL EDIT` for every ported file whose destination hash differs from `destinationSha256` (informative and never failing in that proposal; a mode of check-drift.ps1 or `tools/port-ledger/check-local-divergence.ps1`, as the plan chooses). This product's own rule adds that before a release each such file is classified (deliberate difference, candidate for the source, not applicable); the first run is recorded as the baseline.
- If the answer is a two-way flow: the notice path to FMS_A exists (the carrier proposed in the catalog is FUNCTION-PARITY rule 3, a Draft ticket captured in the other product's queue) and one real notice is filed and tracked here; otherwise the divergence record alone is the deliverable and the ticket says so.

## 3. Approach

### 3.1 Scope

Add the destination hash and its recording date to each local ledger row. An initial backfill records the files as they stand on 2026-11-14; it cannot reconstruct their original port-time bytes. New ports and carries record both hashes; a decision not to carry does not reset the local baseline. Existing contract readers accept the additive optional field (PORT-LEDGER 0.1 rule 2); the date and classification stores are local extensions, not a shared format amendment.

The local check is informational by default and has a release mode that refuses unclassified edits. Classifications are pinned to the changed destination bytes; candidates name a tracked notice. A later edit invalidates the old classification. A carry may replace the destination baseline only after the current bytes are classified, so it cannot silently erase an edit. Classifying a deliberate difference requires a reason and the adjacent code documentation; whether the documentation explains that difference is reviewed by a person. Missing files and unreadable records do not pass the release gate.

The local notices hold the candidate and its state. They do not claim an FMS_A ticket exists: the owner orders its capture separately. The baseline lists known product-only changes and identifies what the hash backfill cannot prove. No application behaviour, user-facing text, catalog contract, or upstream checkout changes.

### Plan (2026-11-14)

Coverage and order: (1) extend the ledger reader/writer and record-port, retaining the old reader and preserving unknown fields; (2) add the local state and classification/notice readers plus the informational and release checks and classification recorder; (3) backfill existing rows, document and classify known differences and file a real local notice; (4) exercise both the legacy and new self-tests in-process within the fast tier; (5) update the release procedure, repository contract, tool README and ticket audit. Each phase consumes only files from an earlier phase or the existing ledger. Checks: fields and hashes round-trip; an edited destination reports LOCAL EDIT; strict mode fails until the exact bytes are classified; a stale classification and missing notice fail again; the real ledger and release gate report their actual counts. Plan self-review: all four requested deliverables, legacy compatibility, release classification, read-only upstream and the five-second limit map to a phase.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

Q: After the port, what is the relation between the System Info of FMS_A and the standalone apps - (a) two-way: improvements found in either product are carried to the other, each by its own ticket; (b) one-way with a record: only FMS_A's changes come here and the divergence is only recorded; (c) FMS_A's System Info later hands off to the standalone apps?

The catalog has the same question at portfolio level (proposals of 2026-11-13): PORT-LEDGER rule 8 in the Filler Android proposal (P: the source owes nothing; H: the source opens a hand-off ticket; R: the source's release preflight lists each derived product's uncarried files), FUNCTION-PARITY rule 3 (a change or a fix captures a Draft ticket in each other product whose cell is offered), and the DeviceInfo proposal that makes that rule two-way. The answer here is taken together with the catalog owner's decision: (a) is H made two-way with FUNCTION-PARITY rule 3 as its carrier, (b) is P, and R is an addition the source side may take on top of either.

Answered 2026-11-13 (owner, quiz): (a) two-way. Improvements and fixes found in either product are carried to the other, each by its own ticket; FUNCTION-PARITY rule 3 is the carrier, and the drift check of the port ledger stays as the safety net. Resolved: the relation is two-way, so the done criterion "the notice path to FMS_A exists and one real notice is filed and tracked here" applies and the divergence record alone is not the deliverable. Notice path (answered 2026-11-13): a candidate for FMS_A is recorded first as a file under `docs/` in this repository with a tracked state; the Draft ticket in the fms-a queue is captured only on the owner's own capture command (`/sd fms-a: ...`), never written into the FMS_A checkout by a session of this repository, so CLAUDE.md section 2 rule 1 stays unchanged. The two answers are written into CLAUDE.md section 2 as a standing rule by the implementation pass.

Catalog correction read 2026-11-14: the accepted draft FUNCTION-PARITY 0.1 puts the two-way source/derived carrier in rule 5, not the proposal's rule 3. PORT-LEDGER 0.1 rule 11 chose the source preflight option R; it complements the function-level carrier. Both contracts remain draft and no adoption row or family register is created by this ticket.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** none

### Quiz decisions (2026-11-13)
- After the port, what is the relation between the System Info of FMS_A and the standalone apps? -> (a) two-way, deliberate (the owner picked the recommended option; it matches the order "новый/исправленный функционал обновляется/исправляется .. паралельно" and the catalog proposal `deviceinfo-joins-function-parity`, which makes FUNCTION-PARITY rule 3 two-way; PORT-LEDGER rule 8 option H with rule 3 as carrier).
- How does a candidate for FMS_A leave this repository, given that CLAUDE.md section 2 rule 1 forbids modifying the FMS_A checkout from here? -> a file under `docs/` here holds the candidate and its state (open, handed over, accepted, declined); the Draft ticket in the fms-a queue is captured only on the owner's own order (`/sd fms-a: ...`), so rule 1 is not changed (the owner picked the recommended option).
- Consequence for the plan pass: the done criterion of section 2 on a real tracked notice applies; the notice file format and its state tracking are a plan decision of this ticket, not an open owner question.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14

## Last Audit

**Date:** 26-11-14 | **Mode:** fast and static | **Outcome:** Implemented; Android build and suites remain release tier
**Counts:** PASS 9 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 2

- PASS - `pwsh -NoProfile -File tools/port-ledger/backfill-destination-hashes.ps1 -Date 2026-11-14`: exit 0, `Backfilled 104 destination hash(es)`. A separate `Get-FileHash` comparison of every row: exit 0, `PASS: 104 destination hashes match their files and the baseline date`. These are the files as of the backfill, not recovered port-time history.
- PASS - `pwsh -NoProfile -File tools/port-ledger/check-local-divergence.ps1 -RequireClassified`: exit 0, 104 rows, 0 local edits, 0 unclassified, 0 missing and 0 unanchored. This is the first post-backfill run; the pre-backfill informational run reported 104 rows without baselines.
- PASS - `pwsh -NoProfile -File tools/port-ledger/test-local-divergence.ps1`: exit 0, all 45 expectations held, 0.81 s. It exercised actual tool entry points on a throw-away tree: multiple LOCAL EDIT rows, informational and strict exits, hash-pinned classifications, stale edits, notice and KDoc refusals, legacy rows, backfill, unknown fields, carry protection and malformed data.
- PASS - `pwsh -NoProfile -File tools/port-ledger/check-drift.ps1`: exit 0, `104 in step, 0 decided`; `pwsh -NoProfile -File tools/port-ledger/test-port-ledger.ps1`: exit 0, all 16 expectations held, 0.60 s.
- PASS - `pwsh -NoProfile -File tools/port-ledger/check-scope.ps1`: exit 0, 114 in-scope files and 281 watched string keys, no NEW SOURCE or STALE DECISION; `pwsh -NoProfile -File tools/port-ledger/test-port-scope.ps1`: exit 0, all 36 expectations held, 0.92 s.
- PASS - A fresh comparison of `keySensorsSummary` in the local and upstream `SensorsDiagnosticsCollector.kt` plus the parsed notice store: exit 0, `RP-0001 is open and its step-counter difference matches both source files`. `RP-0002` also tracks the notification-recovery candidate for source-side investigation. Both are local notices, not claims of source tickets.
- PASS - `rg -n 'check-local-divergence|reverse-port-notices|both ways|2026-11-14.*baseline' CLAUDE.md docs/RELEASE.md docs/README.md tools/port-ledger/README.md docs/reverse-port-baseline.md`: exit 0; the standing decision, baseline, operator path and release gate are named in their respective records.
- PASS - `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate`: exit 0, 9 OK, 1 unrelated complexity warning for S0022. `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/release-queue -Validate`: exit 0, 30 tickets, no drift.
- PASS - Canon `tools/check-compliance.ps1`: exit 0, 0 errors, 2 warnings (the adoption stamp and an archived catalog-path reference, outside this ticket). A search for `S0019` probes in phone and wear Kotlin: exit 0 after asserting no matches.
- EXEMPT - Application UI, localizations and device scenarios: no app code or user-facing behaviour changed.
- EXEMPT - Shared catalog change: PORT-LEDGER 0.1 already permits the destination hash; the date and classification records are local extensions, and the catalog is read-only here.
- RELEASE - Build both Android apps: `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug` under the Build lock. Not built between releases.
- RELEASE - Run the Android suites: `.\gradlew.bat :phone:testDebugUnitTest :wear:testDebugUnitTest` under the Build lock. Not run between releases. No compile-only command is declared.

### Action items

1. At release run the two RELEASE commands and retain their outputs and exit codes.
2. When the owner orders the source captures, use the details of `RP-0001` and `RP-0002`; record each resulting `fms-a:Sxxxx` and update the corresponding notice state. No FMS_A ticket has been created by this pass.
