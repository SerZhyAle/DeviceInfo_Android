# S0021_phone-wear-feature-parity-matrix

**Status:** Implemented
**Status note:** Docs-and-tools, fast tier: docs/PARITY_MATRIX.md (39 rows, FUNCTION-PARITY vocabulary, S0006/S0010 one-by-one), tools/parity/check-matrix.ps1 + self-test, standing scope rule in CLAUDE.md s4. Check exit 0 (0.34 s), self-test 29 PASS (0.55 s), no unowned gap - the only planned cells are the S0024 help cells.
**Created:** 2026-11-13
**Complexity:** medium - not assessed at capture

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

Position this ticket serves: "развиваются вместе .. новый/исправленный функционал обновляется/исправляется в них паралельно" (phone and wear).

Problem: there is no record of which information category or feature exists on which side, so nobody can tell a deliberate absence from a forgotten port, and no ticket states whether it is for the phone, the watch or both.

Evidence (read 2026-11-13):
- Phone presents the sections of GatherSystemInfoUseCase and its collectors (S0007 counts 11 telemetry sections), plus the extended metrics of S0010 (Partial) and the restricted-flavor sections of S0009.
- Wear surfaces 9 contributors in domain/systeminfo/: App, Device, Environment, Health, Memory, PhoneLink, RadioCapability, Sensors, Storage.
- Battery on the watch is read inside HealthInfoContributor and AndroidWearHealthDataSource only; the advanced battery details carried by S0006 (charge speed, power profile, nominal profile, time to charge, runtime left) are phone-side files, while the handoff's goals 2 and 3 name battery for the watch and the advanced details without saying for which side.
- Nothing in the ticket template or CLAUDE.md asks a ticket to name the side(s) it covers.

Wanted:
1. A committed parity matrix (docs/PARITY_MATRIX.md or a jsonl with a renderer): every information category and feature as a row; columns phone and wear; each cell one of present, absent by design (with the reason: form factor, hardware, permission, privacy), or open with the ticket that owns it.
2. A first pass that fills the matrix from the code, and from it the list of real gaps - including whether the new S0010 metrics and the S0006 battery details have a meaningful watch counterpart - each gap either a new Draft ticket or a recorded "by design".
3. A standing rule in CLAUDE.md: every ticket that changes user-visible behavior states its scope as phone, wear or both, and a one-sided change records why the other side does not get it; the rule is checked at the ticket's audit.
4. A check under tools/ that fails when a row has no cell value, or an "open" cell names a ticket that is closed or missing; added to the fast tier list.

Device claims stay open manual checks (CLAUDE.md section 2 rule 4). Fast tier only.


## 1. Problem

Nobody can see which functions the phone app and the watch app have and which are missing on purpose, so the owner's rule that a new or fixed function reaches both apps in parallel cannot be checked.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- The parity matrix is committed in the row and cell vocabulary proposed for FUNCTION-PARITY (offered; planned <repo-key>:<ticket>; not offered with a reason class: os-only, form-factor, owner-declined) so that it moves into the family register unchanged if the owner accepts it, and words that differ are replaced by the owner's; every row has a cell for the phone and one for the watch; `pwsh -NoProfile -File tools/parity/check-matrix.ps1` exits 0 (every cell filled, every planned cell names a ticket that exists).
- Every gap the first pass finds is a Draft ticket or a recorded absence by design; the S0006 battery details and the S0010 metrics are classified one by one.
- CLAUDE.md carries the standing rule: a ticket that changes behavior names its scope (phone, watch or both) and a one-sided change records why; the rule is applied to S0006, S0009, S0010 and S0011 in the matrix.
- The check is in the fast tier list.

## 3. Approach

### 3.1 Scope

What changed (2026-11-14):

- `docs/PARITY_MATRIX.md` - the parity matrix: 39 rows (one per information category and feature),
  each with a phone cell and a watch cell in the `FUNCTION-PARITY` 0.1 row and cell vocabulary
  (`offered`, `planned deviceinfo-mob:Sxxxx`, `not offered:` with the reason class `os-only`,
  `form-factor`, `owner-declined (date)` or `subset`), so the file moves into the family register
  unchanged when the owner adds DeviceInfo's columns (S0025 carries the registration). Section 3
  applies the standing rule backwards to the one-sided tickets S0006, S0009, S0010 and S0011; sections
  4 and 5 classify the S0006 battery details and the S0010 metrics one by one.
- `tools/parity/check-matrix.ps1` - the check: parses the matrix main table and `PLAN/spec-catalog.jsonl`;
  exit 0 every row carries both cells in the vocabulary and every planned cell names an open ticket,
  1 a mismatch, 2 could not run (wrong root, a required file missing, the main table header not found).
- `tools/parity/test-check-matrix.ps1` - the self-test on a throw-away tree (30 expectations: the clean
  tree with the optional `since` stamp, every reason class and an open planned ticket; an empty cell, a
  cell outside the vocabulary, `owner-declined` without its date, planned cells that name a missing, a
  closed, an archived and a foreign-repo ticket, a repeated id, a five-cell row, and the exit 2 of a
  missing matrix, a missing catalog and a missing header).
- `CLAUDE.md` - section 4 carries the standing rule (a behavior-changing ticket names its scope - phone,
  wear or both - and a one-sided change records why, stated against the matrix, updated in the same
  step, checked at the audit); section 5 points at the matrix and `tools/parity/`; section 6 adds the
  check and its self-test to the fast tier.
- `docs/README.md` - the index row; `docs/RELEASE.md` - the check in the step 1 fast gates.

What deliberately does not change:

- No new Draft tickets: the first pass found no unowned gap - every absence is classified by design
  with its reason (mostly `subset`, the charter scoping each app to its FastMediaSorter sub-app), and
  the only planned cells are the two in-app-help cells, owned by the existing S0024.
- No family register and no `DeviceInfo` column is written here: the register is the catalog owner's
  artifact (S0025); this matrix only agrees with its vocabulary.
- No `since` stamps on the offered cells: no release exists yet (the version properties carry the
  non-releasable sentinels, S0008); the first release tags them.
- No Kotlin, Gradle or resource edit: the matrix records what the code of both modules carries today;
  a docs-and-tools pass only.

### 3.2 Open questions

None. The one design question - which reason class fits an absence that is neither hardware-forced nor
a recorded owner decision - is answered by declaring both columns subset columns once, as
`FUNCTION-PARITY` rule 2 prescribes: each carries the System Info functions of its form factor's
FastMediaSorter sub-app (the owner's order of 2026-11-13), so `not offered: subset` means the upstream
sub-app of that form factor never carried the function and no counterpart is proposed. `os-only` and
`form-factor` stay reserved for what the platform or the interaction really forces; `owner-declined`
carries its date (the S0009 quiz, 2026-11-13). The classifications are recorded in the matrix and the
owner may overrule any of them.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0025 (the register registration this vocabulary prepares), S0024 (the owner of
  the only planned cells), S0027 (the acceptance of the whole set).

## 4. Implementation record (2026-11-14)

Every done criterion of section 2, with the command and the exit code:

- The matrix is committed in the FUNCTION-PARITY vocabulary: `docs/PARITY_MATRIX.md`, section 1 (the
  vocabulary and the per-column subset declaration), section 2 (the main table, 39 rows, every row a
  phone and a watch cell), section 3 (the standing rule applied to S0006, S0009, S0010 and S0011),
  sections 4 and 5 (the S0006 battery details and the S0010 metrics, one by one), section 6 (the
  first-pass result and the maintenance rules).
- The check and its first run: `pwsh -NoProfile -File tools/parity/check-matrix.ps1` - **exit 0**
  (0.34 s): 39 rows; phone offered 33, planned 1, not offered 5; watch offered 18, planned 1, not
  offered 20; the one planned cell per column names `deviceinfo-mob:S0024` (Draft in the store).
- Self-test: `pwsh -NoProfile -File tools/parity/test-check-matrix.ps1` - 29 expectations, all PASS,
  **exit 0** (0.55 s). The first run failed 2 expectations - the junk-cell mutation anchored on `$`
  never matched a multi-line here-string, so its tree stayed clean; the mutation was fixed, the re-run
  passed. A check that reports nothing must be proven able to fail.
- Every gap classified, none unowned: the S0006 battery details (6 items) and the S0010 metrics (6
  items) are classified one by one in `docs/PARITY_MATRIX.md` sections 4 and 5; each absence carries a
  reason class and the why; no new Draft ticket was needed.
- The standing rule: `CLAUDE.md` section 4, bullet "Scope of a behavior-changing ticket (S0021)";
  applied to S0006, S0009, S0010 and S0011 in `docs/PARITY_MATRIX.md` section 3.
- The check is in the fast tier list: `CLAUDE.md` section 6 (the check, its self-test, the run-after
  rule) and `docs/RELEASE.md` step 1.

Audit: a docs-and-tools change only - no Kotlin, Gradle or resource edit, so nothing is
compiled-not-tested; every command above ran inside the fast tier (the slowest is the self-test at
0.55 s). RELEASE items: none - nothing here depends on a release-tier run.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14
