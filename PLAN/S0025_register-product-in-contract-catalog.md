# S0025_register-product-in-contract-catalog

**Status:** Implemented
**Status note:** no compile command (no compiled source edited); 13 registry rows, pointers, register and cross-references written and statically audited. Open, none claimed: the ICON proposal decision (catalog owner), the FUNCTION-PARITY columns (register not seeded), the live URL checks and the Verified dates (release items); six canon-layer rows handed to S0026
**Created:** 2026-11-13
**Complexity:** medium - assessed at the spec pass of 2026-11-14 and confirmed: one shared file edited (the product's own registry rows), four new pointer/register files and ten small edits, no code and no contract text; the weight is in reading the catalog and the 13 contracts' state exactly, because the capture's facts were already stale

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

Further order, 2026-11-13, verbatim (chat, Russian), given after the correction of these specs:
"если тут какие то несогласия - предложи изменения к межпроектному контракту"

Carried out by five proposals filed in the shared contracts catalog the same day (the file names are in the done criteria of ticket register-product-in-contract-catalog, S0025): the Wear OS app surface in CONTEXT-HELP, the Wear OS profile in UI-SIZING, BUTTONS and COLLAPSIBLE-GROUP, and the place of the derived apps in FUNCTION-PARITY. Other projects had filed related proposals the same day (the watch scope question, the port ledger, the family function register); these specs are aligned to them rather than competing with them. Until the owners of those contracts decide, the sealed text applies.
This ticket's problem and done criteria (sections 1 and 2) were written from that message. The acceptance of the whole set is ticket target-state-acceptance (S0027).

Twelve tickets were captured by the two orders: bugfix-contract-pointers-stale (S0016), payload-parity-test (S0017), upstream-new-file-inventory-check (S0018), reverse-port-divergence-ledger (S0019), ship-together-surfaces-manifest (S0020), phone-wear-feature-parity-matrix (S0021), phone-wear-visual-identity (S0022), unified-ui-conformance-evidence (S0023), in-app-help-phone-and-wear (S0024), register-product-in-contract-catalog (S0025), canon-resync-stamp (S0026), target-state-acceptance (S0027).

Agent findings below are not the owner's words. They come from the investigation of 2026-11-13; every fact cites the file it was read from.

Position this ticket serves: "принадлежат общему семейству программ и связаны канонами и контрактами" - from the catalog's side.

Problem: the product declares its contracts in docs/contracts/, but the shared contracts catalog names DeviceInfo nowhere, so the family and the contract owners do not know it exists; one of the missing registrations blocks the first shipment.

Evidence (read 2026-11-13):
- SITE-FAMILY-MAP 1.12: nine rows (FastMediaSorter Android, FastMediaSorter for Windows, CyrFlip, doc-html-translate, FileDO, STREAMS Player, OneClickRunner, Universal Agent Kit, the SZA hub); consumers list does not include DeviceInfo; the map has no DeviceInfo row, so no other footer links to this product. The row is filed to the hub only after the three landing URLs answer 200 (rule 5; docs/RELEASE.md). The other Android siblings (StreamsPlayer Android, Tourist, Filler) are not rows either; S0015 tracks the StreamsPlayer Android row on this product's footer.
- PACKAGE-VERSIONING 0.6: consumers FastMediaSorter Android, FastMediaSorter_Lite, StreamsPlayer, doc-html-translate, FileDO. For DeviceInfo only the open proposal PROPOSAL-2026-11-13-deviceinfo-android-bands.md stands in package-versioning/; the contract stays 0.6 until its owner folds it in, and the family ships only after that (docs/contracts/PACKAGE-VERSIONING.md, "Still owed").
- CONTEXT-HELP consumers list: no DeviceInfo. INPUT-PARITY consumers: "every product with a user interface" (generic). UI-SIZING, BUTTONS, COLLAPSIBLE-GROUP: "every Android application" (generic). The catalog README's "Who is bound" columns do not name the product.
- The mechanism for a change to a catalog contract is a dated PROPOSAL-<date>-<slug>.md in the function's folder; this product's own pages never edit a contract page (CONTRACTS, canon invariant 10). CLAUDE.md names catalog tickets already filed (canon:S0057, canon:S0058, hub:S0009).

Wanted:
1. A register in docs/contracts/ (README or table): for every contract the product consumes, what was proposed to the catalog, when, and the state (proposed, accepted, rejected, or needs no row because the contract binds "every product").
2. The missing proposals filed in the catalog's form: consumer rows for CONTEXT-HELP, INPUT-PARITY and the UNIFIED-UI trio where the owner of the page wants named consumers; the SITE-FAMILY-MAP row (and the question whether Android siblings enter the map) prepared for the moment the landing and listing answer 200; the band-table row of PACKAGE-VERSIONING chased to a decision.
3. The canon and the hub told through the portfolio's own channel (projects canon and hub), not by editing their files; the answers recorded in the register.
4. Each pointer updated when the catalog accepts the row (version read, date).
5. A statement in the ticket of which of these items block the first release (the PACKAGE-VERSIONING row does) and a pointer from S0008 and S0014 to it; this ticket owns the catalog-side registrations, S0008 and S0014 own the store and release steps.

No catalog page is edited by this product's session except by adding a proposal file; no release, tag or upload is part of this ticket.


## 1. Problem

The product has to belong to the family from the catalog's side as well: bound by the shared contracts, present in the
registry that the release gate reads, and known to the owners of the contracts it consumes. When this ticket was
captured (2026-11-13) the catalog named DeviceInfo nowhere. At the spec pass of 2026-11-14 the catalog owner had decided
every proposal this product filed (all accepted, three with corrections) and named the product in the consumers lines
of CONTEXT-HELP, FUNCTION-PARITY, PORT-LEDGER and PACKAGE-VERSIONING - but the registry holds one adoption row for the
product (PACKAGE-VERSIONING, `pending`), the product has no single record of what it consumes and what it filed, and its
local pointers still say a row is owed. RELEASE_AND_DISTRIBUTION section 2 (contract gate) makes a current registry
row for every consumed contract a condition of the one-way release step, and RULES section 14 says a contract without a
row does not exist for that gate. A product's own rows are the product's to write (REGISTRY header, RULES section 7), and
two decisions of 2026-11-13 say it in terms: CONTEXT-HELP 0.4 item N ("its adoption row is the product's own") and
FUNCTION-PARITY 0.1 ("DeviceInfo Android writes its two columns .. and its adoption row").

## 2. Done criteria

Rewritten at the spec pass of 2026-11-14 against the catalog as read that day; section 0 keeps the capture's own list
("Wanted") as history. Each criterion is a command or an observation.

Before the first release (static):
1. **The register.** `docs/contracts/README.md` lists every contract the product consumes: the 13 shared contracts
   with a pointer (CONTEXT-HELP, INPUT-PARITY, UI-SIZING, BUTTONS, COLLAPSIBLE-GROUP, ICON-SET, ICON-RENDER,
   PACKAGE-VERSIONING, FUNCTION-PARITY, PORT-LEDGER, PAGE-CONTENT, PAGE-STYLE, SITE-FAMILY-MAP), its own DATA-LAYER-PAIR,
   and the canon-layer contracts handed to S0026. Per contract: the version read, the pointer, the registry row and its
   state, each proposal (catalog file, date, state), each exception, and the ticket that owns what is open.
   Check: `grep -c` of the 13 ids in the table gives 13 rows; every proposal file named in it exists in the catalog.
2. **The registry rows.** `_meta/REGISTRY.md` section 2 holds one adoption row `DeviceInfo Android` per each of the 13
   contracts, `Reads` = the version read, `Verified` = `pending` (nothing is claimed that has not run), the notes stating
   what is built, what is open and which exception row applies. Check: `contract-lag.ps1 -Product DeviceInfo` (canon
   `tools/`) prints `rows: 13` with 0 unparsed; `check-contracts.ps1` exits 0 with no finding beyond the two
   catalog-wide warnings it printed before this ticket.
3. **The pointers.** `docs/contracts/FUNCTION-PARITY.md`, `PORT-LEDGER.md` and `PRODUCT-WEB-PAGES.md` exist in the shape
   `tools/contracts/check-pointers.ps1` reads; no pointer says a row is "owed" or "not yet in the catalog". Check:
   `check-pointers.ps1` reports no mismatch other than the ICON-SET / ICON-RENDER pair that belongs to S0031.
4. **No contract text and no new proposal.** No contract page of the catalog is edited; the register shows, per
   contract, why no further proposal is needed (accepted, or the consumers line is generic) - the proposals that were
   needed exist and are decided.
5. **The portfolio channel.** The register records the notices already given to the canon and the hub and their replies
   (canon:S0057, canon:S0058, hub:S0009); a new ticket is filed only where the evidence shows a gap (none was found).
6. **The release pointers.** S0008 and S0014 each carry a dated line pointing at the register's section on what blocks
   the first release; S0026 carries the handover of the canon-layer registry rows; `docs/RELEASE.md` names the contract
   gate at release start; CLAUDE.md no longer calls the registry row owed.
7. **The statement.** The register says which items block the first release and which do not (section 3.1, "Blocks the
   first release").

After publication (open manual checks, recorded and not claimed):
- The three landing URLs and the Play listing answer 200; the family map lists this product (hub:S0009) and the sibling
  footers link to it.
- The `Verified` cells of the 13 rows carry a date, written at release start from the S0007, S0023 and S0024 evidence.
- The two columns of the FUNCTION-PARITY register are added once the register file exists (FastMediaSorter Web seeds it).
- The proposal `iconography/PROPOSAL-2026-11-14-deviceinfo-system-info-meanings.md` is decided by the catalog owner.

## 3. Approach

### 3.1 Scope

**The catalog as read on 2026-11-14, and what changed since the capture.**

- The catalog owner decided every proposal of this product on 2026-11-13 (canon session, portfolio owner's order):
  CONTEXT-HELP 0.4 (accepted, reading A), UI-SIZING 1.2 and BUTTONS 2.2 (accepted with a correction each),
  COLLAPSIBLE-GROUP 1.2 (accepted), PACKAGE-VERSIONING 0.7 (accepted as requested; the band table has the two DeviceInfo
  rows, registry row `pending`), FUNCTION-PARITY 0.1 (accepted with corrections, rules 1, 2, 5 and 6). The proposals of
  other projects that decide parts of this product's state are accepted too: FMS Web `fms-family-function-parity`,
  Filler `new-contract-source-port-ledger`, Tourist `port-ledger-format` (PORT-LEDGER 0.1) and Filler
  `watch-surface-scope` (UI-SIZING 1.2 answer b). The one proposal still open is the iconography one of S0022
  (2026-11-14). The capture's statement that "PACKAGE-VERSIONING 0.6 .. the contract stays 0.6" and that the version row
  blocks the first release is superseded: the contract is 0.8 and the row is accepted.
- Corrections to the capture, each with its evidence: (1) "No catalog page is edited by this product's session except by
  adding a proposal file" was the capture's own sentence, not the owner's; REGISTRY header and RULES section 7 say a
  project edits its own registry rows and exceptions (sealing covers contracts, not the registry), and S0023 already
  recorded exceptions E1 to E4 there. (2) The unit that blocks the first release is the registry rows (contract gate),
  not the band row. (3) Consumer rows in headers are not wanted by the owners of the generic contracts: INPUT-PARITY,
  UI-SIZING, BUTTONS and COLLAPSIBLE-GROUP name "every product with a user interface" / "every .. Android application",
  and ICON-SET and ICON-RENDER bind by registry row (Tourist Android is a consumer by rows alone). (4) A pointer for
  FUNCTION-PARITY, PORT-LEDGER and the three site contracts did not exist.

**Changes (all static; nothing is built or run on a device):**
- The shared catalog, one file: `_meta/REGISTRY.md` section 2, the product's own rows only - the PACKAGE-VERSIONING row's
  `Reads` moves 0.7 to 0.8 and 12 rows are added next to it (CONTEXT-HELP, INPUT-PARITY, UI-SIZING, BUTTONS,
  COLLAPSIBLE-GROUP, ICON-SET, ICON-RENDER, FUNCTION-PARITY, PORT-LEDGER, PAGE-CONTENT, PAGE-STYLE, SITE-FAMILY-MAP). The
  before and after of those rows is kept in `PLAN/S0025_register-product-in-contract-catalog/attachments/registry-deviceinfo-rows.txt`.
- `docs/contracts/`: new `README.md` (the register), `FUNCTION-PARITY.md`, `PORT-LEDGER.md`, `PRODUCT-WEB-PAGES.md`;
  `PACKAGE-VERSIONING.md`, `ICONOGRAPHY.md`, `CONTEXT-HELP.md`, `INPUT-PARITY.md`, `UNIFIED-UI.md` get their registry-row
  line. `docs/README.md` indexes the register.
- `PLAN/S0008`, `PLAN/S0014` (pointer lines), `PLAN/S0026` (handover line), `docs/RELEASE.md` (contract gate at
  release start), `CLAUDE.md` (sections 3 and 5: the row is no longer owed; the register is named).

**Deliberately not changed:** any contract text; any catalog page except the product's own registry rows; ICONOGRAPHY.md's
version read (S0031 re-reads ICON-SET 0.40 and ICON-RENDER 0.25 and moves the two rows with it); the canon-layer rows
(REPO-STAMP, HARNESS-PROFILE, REPO-LAYOUT, RULE-DELIVERY, TASK-FLOW, DOC-INTERNAL-QUALITY - S0026, which also moves the
stamp); the SITE-FAMILY-MAP row itself (hub:S0009, filed after the listing answers 200, rule 5); the FUNCTION-PARITY
register file (FastMediaSorter Web seeds it); no commit, push, tag or upload.

**Shared-contract boundary:** the ticket touches the registry rows of the boundary and no contract text, code or wire
shape, so no catalog amendment or version bump is owed (CONTRACTS section 4 asks for one only before boundary code).

**Scope, phone and wear (CLAUDE.md section 4, S0021):** no user-visible behavior changes on either side; no
`docs/PARITY_MATRIX.md` row changes.

**Blocks the first release.** (a) The contract gate: a current registry row for every consumed contract - delivered here
for 13 contracts as `pending` rows, and by S0026 for the six canon-layer ones; the first release is not ready while
S0026's rows are missing. (b) The `Verified` dates: written at release start (a `pending` row is honest, not a pass).
(c) The band-table row and the PACKAGE-VERSIONING adoption row: resolved (0.7 accepted 2026-11-13), the Kotlin vectors
run at the release. **Does not block:** the SITE-FAMILY-MAP row (post-publication, hub:S0009), the FUNCTION-PARITY columns
(the register is not seeded), the iconography proposal (a meaning ships under its proposed id, ICON-SET section 15), the
exceptions E1 to E4 (recorded and dated 2026-12-31; recording waives no store blocker).

**Plan (Stage 2; every step ends in a static check).**
1. *Coverage inventory:* done criteria 1 to 7 map to phases P1 (2), P2 (3), P3 (1, 4, 5, 7), P4 (6), P5 (evidence).
2. *Topology:* P1 produces the rows P2 and P3 quote; P2 produces the pointers P3 lists; P3 produces the register P4
   points at; no phase consumes a later phase.
3. *Real-work filter:* every phase changes a registry, a pointer, a ticket spec, a release document or the agent rules.

| Phase | Step | Static check |
| --- | --- | --- |
| P1 | rows into `_meta/REGISTRY.md` by a script that edits only lines of the product's rows | `contract-lag.ps1 -Product DeviceInfo` rows 13, unparsed 0; `check-contracts.ps1` exit 0; `diff` of before/after shows only added/changed `DeviceInfo Android` lines |
| P2 | three new pointers, five pointer lines | `check-pointers.ps1`: mismatches only ICON (S0031) |
| P3 | the register, the docs index | the 13 ids and every proposal file resolve; no catalog path with a drive letter (SZA-CTR02) |
| P4 | S0008, S0014, S0026, RELEASE.md, CLAUDE.md | grep of the register pointer in each; `spec_catalog/validate` exit 0; `check-compliance.ps1` no new finding |
| P5 | fast gates of CLAUDE.md section 6 touched by this diff | exit codes cited in the audit |

### 3.2 Open questions

All answered here or handed to a carrier; none is open.

- Which contracts need rows? The 13 above. The canon-layer six are handed to S0026, which reads those contracts when it
  re-stamps the canon adoption.
  Carrier: S0026
- Do the generic contracts (INPUT-PARITY, UNIFIED-UI trio, ICON pair) need a consumers-line proposal? No - their owners
  bind "every" product or bind by adoption row; the registry row is the route (Tourist Android precedent, rows without
  a header entry).
- The SITE-FAMILY-MAP row? Carried by hub:S0009 (BlockByOtherTask on S0014), with the row text in S0012 and the
  consumers-line entry in the hub's own ticket; filed on the owner's order after the listing answers 200. The Help
  index cell of that row stays `-` until the S0024 help pages answer (rule 5 holds for the column); the prepared address
  is `https://serzhyale.github.io/DeviceInfo_Android/help/en/` (S0024, permanent once published).
- Do the Android siblings enter the map? Each sibling files its own hub ticket when its landing and listing answer (for
  StreamsPlayer Android hub:S0010); this product's footer follows in S0015, S0028 and S0030. Not decided here.
- The FUNCTION-PARITY columns? The register file `family-fastmediasorter.md` does not exist (FastMediaSorter Web's S0055
  follows acceptance with it); `docs/PARITY_MATRIX.md` is the stand-in in the contract's vocabulary and joins
  unchanged. This is an after-publication check, not a question for the owner.

### Assumed (unattended, 2026-11-14)

- `Verified` is `pending` on every new row, with the static evidence in the notes. Alternative: a date from today's
  fast-gate runs. Taken because a date asserts that the implementation matches the contract and no device or rendered
  page has run; the owner may overrule.
- ICON-SET and ICON-RENDER rows read 0.39 and 0.24 (what the pointer records); the catalog is at 0.40 and 0.25.
  Alternative: write the current versions here. Taken because S0031 owns the re-read of the two amendments and the
  decision whether the glyph mapping still holds; the owner may overrule.
- PAGE-CONTENT 1.5, PAGE-STYLE 3.10 and SITE-FAMILY-MAP 1.12 rows read the current versions: the landing's generator
  cites PAGE-STYLE 3.9 for its per-locale form and `docs/RELEASE.md` applies 3.10 item 3; rendered conformance is the
  release's `/site-audit`. Alternative: leave the three rows to a later ticket. The owner may overrule.

### 3.3 Owner inputs (Approval gate)

None. Every choice above is reversible inside the ticket; the one-way steps (a catalog contract change, a commit, the
SITE-FAMILY-MAP row to the hub, any release) are not part of it.

- **Related tickets:** S0008 and S0014 (own the store and release steps; they point here), S0012 (landing, the site
  contracts), S0016 (pointer re-read), S0018 and S0019 (PORT-LEDGER duties), S0021 (the matrix that joins the
  FUNCTION-PARITY register), S0022 and S0031 (ICON pair), S0023 (exceptions E1 to E4), S0024 (help, the Help index cell),
  S0026 (canon-layer rows), S0027 (acceptance of the whole set), hub:S0009, canon:S0057, canon:S0058.

## 4. Implementation record (2026-11-14)

Done in one unattended pass, all static (no build, no test run above 5 s, nothing run on a device). Order as planned.

- **P1, registry.** `_meta/REGISTRY.md` of the shared catalog, section 2, the product's own rows only: the
  PACKAGE-VERSIONING row re-read at 0.8 (Reads 0.7 to 0.8, a dated note) and 12 rows added next to it - CONTEXT-HELP 0.4,
  INPUT-PARITY 0.7, UI-SIZING 1.2, BUTTONS 2.2, COLLAPSIBLE-GROUP 1.2, ICON-SET 0.39, ICON-RENDER 0.24, FUNCTION-PARITY 0.1,
  PORT-LEDGER 0.1, PAGE-CONTENT 1.5, PAGE-STYLE 3.10, SITE-FAMILY-MAP 1.12 - each `C`, `Implements -`, `Verified pending`.
  Written by a script that edits only those lines, after a hash check against a pre-edit copy; the before and after of the rows is `attachments/registry-deviceinfo-rows.txt`. Two rows were
  corrected afterwards from what the code showed: PORT-LEDGER (the tool's default source-root path is a rule 8 gap) and
  CONTEXT-HELP / INPUT-PARITY (S0024 wrote the help while this pass ran).
- **P2, pointers.** New: `FUNCTION-PARITY.md`, `PORT-LEDGER.md`, `PRODUCT-WEB-PAGES.md` (the three site contracts). Registry
  lines added to `PACKAGE-VERSIONING.md` (the "still owed" sentences replaced), `ICONOGRAPHY.md`, `CONTEXT-HELP.md` (one
  sentence of S0024's closing paragraph replaced, the rest untouched), `INPUT-PARITY.md`, `UNIFIED-UI.md`.
- **P3, register.** `docs/contracts/README.md` (8 sections: consumed contracts, proposals filed, proposals of others,
  why no more proposals, the channel, what blocks the first release, after publication, the prepared map row);
  `docs/README.md` indexes it.
- **P4, cross-references.** `PLAN/S0008` (a dated line superseding "the registry is sealed"), `PLAN/S0014` (a pointer to
  section 6 of the register), `PLAN/S0026` (the handover of the six canon-layer registry rows), `docs/RELEASE.md` (the
  pointer check in the fast gates and the contract gate at release start), `CLAUDE.md` section 5.
- **Parked:** `deviceinfo-mob:S0033` (the ledger tool's default source-root path and the missing `extraction` block,
  PORT-LEDGER rules 8 and 12). Not touched: ICONOGRAPHY.md's version read (S0031 owns the 0.40 and 0.25 re-read).
- **Not done, by design:** no commit, no push, no tag, no upload, no new proposal file (none was needed), no ticket
  filed in the canon or the hub (every notice the catalog side needs was already filed on 2026-11-13 and has its reply).

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14

## Last Audit

**Date:** 26-11-14 | **Mode:** static | **Outcome:** Partial
**Counts:** PASS 10 | WARN 0 | FAIL 0 | MANUAL 2 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 2

Not Verified: two after-publication items are open and an open manual item never sits beneath a Verified; the static
contract (done criteria 1 to 7) holds. Nothing was built or run on a device: "not built, not tested until the release".

Evidence, each run in this pass (command | exit | expected -> actual):

1. Register: `grep -c` of the 13 ids at the start of a table row in `docs/contracts/README.md` | 13 -> 13; all 11 proposal
   files it names exist in the catalog (loop over the paths, 11 `exists`). PASS.
2. Registry: `diff` of the pre-edit copy against the live file, taken right after the write | 1 line removed and 13 added,
   all `DeviceInfo Android`, 0 other lines, no CR, no BOM -> as expected (kept as `attachments/registry-deviceinfo-rows.txt`).
   A later diff showed two more changed rows, `DEVICE-EXCHANGE` and `LIVE-BROADCAST` of FastMediaSorter Web, re-read at
   02:06 by that product's own session (a concurrent edit of its own rows, not this ticket's; the 13 rows above are
   intact in the live file); `contract-lag.ps1 -Product DeviceInfo` | 0 | `rows: 13`,
   unparsed 0 -> `rows: 13  (current 0, behind 0, partial 0, pending 13, ahead 0, n/a 0, unparsed 0)`;
   `check-contracts.ps1` | 0 | 0 errors -> `0 error(s), 2 warning(s)` (the same two warnings as before the edit; CTR-STALE moved
   from 71 to 83 of 512 rows, the 12 new `pending` rows). PASS.
3. Pointers: `tools/contracts/check-pointers.ps1` | 1 | only the ICON pair mismatches -> 11 pointers checked, 2 skipped,
   2 mismatches, `ICON-SET 0.39 != 0.40` and `ICON-RENDER 0.24 != 0.25`. Known-red, named so it cannot mask anything: the
   same two mismatches stood before this ticket (baseline run at the start of the pass) and S0031 owns them. PASS.
4. No contract text and no new proposal: the registry diff above touches no contract page; the register's section 4 gives
   per contract why no proposal is needed (accepted, generic consumers line, or registry-row binding). PASS.
5. Channel: register section 5 lists canon:S0057, canon:S0058, hub:S0009, hub:S0010 and the eight footer tickets (all eight
   resolve through `resolve-ticket.ps1`); the only ticket created is the local S0033. PASS.
6. Release pointers: `grep -c "docs/contracts/README.md"` | S0008 1, S0014 1, S0026 1, RELEASE.md 1, CLAUDE.md 1;
   `spec_catalog/validate` | 0 | `10 OK, 0 WARN, 0 FAIL`; `release-queue -Validate` | 0 | `OK - 33 ticket(s), no drift`. PASS.
7. The blocking statement: section 3.1 "Blocks the first release" and register section 6 agree. PASS.
8. `check-compliance.ps1 -RepoRoot P:\ANDROID\deviceinfo_mob -IncludeUntracked` | 0 | 0 errors -> `0 error(s), 2 warning(s)`:
   `SZA-CANON03` (S0026) and `SZA-CTR02` on the archived S0001 (history); no finding from the new files. PASS.
9. House style and paths: fixed-string grep for a drive-letter path in the four new files and in the 13 registry rows | none;
   grep for `...` and long dashes in the new files | none. PASS.
10. Scope purity: every edit is in the declared list of 3.1; two findings outside scope were parked or left (S0033
    captured, S0031 untouched); the active ticket never switched. Other fast gates run unchanged: `check-surfaces.ps1` 0,
    `check-drift.ps1` 0 (104 in step), `check-matrix.ps1` 0 (41 rows). PASS.
11. EXEMPT: `CHANGELOG.md` (no user-visible change, registry and records only). EXEMPT: build, tests, lint (no compiled
    source, resource or Gradle file edited; `commands.compileCheck` is absent, so "no compile command").

### Action items
1. None for the build side. Open work is owned elsewhere: the six canon-layer registry rows and the stamp (S0026), the ICON
   re-read (S0031), the PORT-LEDGER rule 8 and 12 gaps (S0033), the family-map row (hub:S0009).

### Manual / on-target
- [ ] The catalog owner decides `iconography/PROPOSAL-2026-11-14-deviceinfo-system-info-meanings.md`; passing means its status
  line reads accepted, partly accepted or rejected, and `docs/contracts/README.md` section 2 follows.
- [ ] FastMediaSorter Web seeds the FUNCTION-PARITY register file (`family-fastmediasorter.md`); passing means the two
  columns `DeviceInfo phone` and `DeviceInfo watch` are added from `docs/PARITY_MATRIX.md` and the `FUNCTION-PARITY` row of the
  registry says so.

### Release items (RELEASE: not run between releases)
- `curl -s -o /dev/null -w "%{http_code} %{url_effective}\n" -L <url>` for the three landing URLs and the Play listing, then
  the family map lists this product (hub:S0009): `docs/RELEASE.md`, "After the site and the listing are live".
- `contract-lag.ps1 -Product DeviceInfo` from the plugin root's `tools/` at release start, then a `Verified` date written
  into each of the 13 rows from the S0007, S0023 and S0024 evidence (`docs/RELEASE.md` step 1, the contract gate).
