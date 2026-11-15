# S0026_canon-resync-stamp

**Status:** Implemented
**Created:** 2026-11-13
**Complexity:** medium - confirmed at the spec pass 2026-11-14: one stamp write, six registry rows, one exception pair and three pointers, prose and comment edits only, no compiled behaviour changes

## 0. Owner request (verbatim)

Owner's correction order, 2026-11-13, verbatim (chat, Russian), given after ten tickets (S0016-S0025) had been captured from the first order recorded in S0016 section 0:

"правильно ли я понял, что по производству всех заказаных задач
это приложение будет иметь весь функционал по соответствующей суб-программы телефона (любом андроид устройстве), часах , который реализован в FMS_A был представлен в виде самостоятельных приложений android,  которые могут заинтересовать пользователя, которому не интересен весь остальной функционал FMS_A
Но при этом эти приложения будут выглядеть более-менее одинаково, развиваться вместе и новый/исправленный функционал обновляется/исправляется в них паралельно, они пересекаются по документации, принадлежат общему семейству программ и связаны канонами и контрактами.
Поправь спецификации чтобы было именно так"

Agent findings below are not the owner's words.

Position this ticket serves: "связаны канонами".

Finding (check-compliance.ps1 run from the plugin root, 2026-11-13, exit 0 with 3 warnings):
- WARN SZA-CANON03 .sza-canon.json: adoption is stale: stamp digest sha256:9abe1d23.. (canon 2026.11.09.1, reconciledOn 2026-11-10) against the canon's sha256:910b613c.. (canon 2026.11.13.2). The fix the gate names: re-read the changed rule docs, reconcile, update canon.version, canon.coreDigest and canon.reconciledOn through the adopt-canon skill.
- The other two warnings (SZA-CTR02, a ticket naming the catalog by a drive path) belong to ticket bugfix-contract-pointers-stale.
- CLAUDE.md names the canon's contrib record of this product (rules/contrib/deviceinfo_mob.md in the canon repository) and says a rule that looks wrong for this repository is reported to the canon session, never patched here.

Scope: run the adopt-canon re-sync path in this repository; no canon file is edited from here.


## 1. Problem

The repository says it follows the canon, but its adoption stamp is older than the canon, so the canon-compliance gate warns that the adoption is stale. The owner wants the apps bound by the canons; that has to be current, not historical.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- The adopt-canon re-sync has been run: .sza-canon.json carries the current canon version, digest and reconciliation date.
- `check-compliance.ps1` from the plugin root exits 0 and prints no SZA-CANON03.
- Every rule that changed between the stamped canon and the current one is read, and each divergence it exposes is fixed or recorded in this repository's own deltas, never by editing the canon.
- The refresh of this product's contrib record in the canon repository is requested from the canon session and the request is recorded.

## 3. Approach

### 3.1 Scope

Changes: `.sza-canon.json` (version, digest, reconciliation date); the wording about when the application id freezes, in `CLAUDE.md`, `docs/RELEASE.md`, `gradle.properties` and the two module build scripts (comments only); six registry rows and two exceptions of this product in the shared catalog's registry; three pointers and the register in `docs/contracts/`; the two index sentences in `CLAUDE.md` and `docs/README.md`; one new local Draft, S0034.

Also changes, from the second pass of 2026-11-14 (Assumed 1): the dated section `## Canon adoption 2026-11-14` in this product's own contrib record `rules/contrib/deviceinfo_mob.md` in the canon repository - the one canon file a project session may write (adopt-canon, step 9).

Does not change: any other canon file, any ticket of another repository, `PLAN/archive` (frozen, `REPO-LAYOUT` rule 6; the one SZA-CTR02 warning that remains names a file there and belongs to S0016), compiled behaviour, the port ledger, the `extraction` block of the profile (S0033), the ICON pointers (S0031).

### 3.2 Open questions

None open. Every choice the pass took is under `### Assumed (unattended, 2026-11-14)` below; the one outward step it did not take (filing the contrib refresh in the canon queue) is recorded there and in section 4.

### 3.3 Owner inputs (Approval gate)

- **Done 2026-11-14, handed over from S0025:** the registry adoption rows for the canon-layer contracts `REPO-STAMP`, `HARNESS-PROFILE`, `REPO-LAYOUT`, `RULE-DELIVERY`, `TASK-FLOW` and `DOC-INTERNAL-QUALITY` are written by this ticket once the re-sync has read them (it confirms which of the six bind this repository); the release's contract gate (RELEASE_AND_DISTRIBUTION section 2) needs a current row for each, and `docs/contracts/README.md` section 1 lists them as "no row yet, owned by S0026". A pointer file under `docs/contracts/` for them follows the shape `tools/contracts/check-pointers.ps1` reads; the register line is updated in the same step.
- **Related tickets:** S0025 (hands the canon-layer registry rows over), S0027 (acceptance of the whole set), S0034 (the remedy of what this pass found partly met), S0033 (the profile's `extraction` block), S0031 (the ICON pointers), S0016 (the SZA-CTR02 warning)

### Assumed (unattended, 2026-11-14)

Each entry: what was taken, the alternative it was weighed against, and that the owner may overrule.

1. **The contrib refresh is written into this product's own contrib record in the canon repository, by the second pass (2026-11-14); this supersedes the first pass's choice.** The first pass kept the facts in section 4 only and left the record alone, citing the scope line of section 0 ("no canon file is edited from here"). That line sits under the capture's "Agent findings below are not the owner's words", and the skills make one exception to the canon being read-only from a project session: the repository's own record under `rules/contrib/` (adopt-canon, step 9: "Append a dated `## Canon adoption` section"; spec-to-audit, Stage 1: a ticket that asks for that record "is not blocked: write the record"). So the skill governs and the record was written: `## Canon adoption 2026-11-14` in `rules/contrib/deviceinfo_mob.md`, placed above the section it supersedes (the file runs newest first), written and not committed in the canon repository. Alternatives: file a Draft with `spec-draft.ps1 -Project canon` (the headless pass allows cross-repository filing only as a blocker, and nothing here blocks), or leave the step to the owner. Owner may overrule: delete that one section from the contrib record, or `/sd canon: ..` to have the canon session reword it.
2. **REPO-LAYOUT rule 3 (no type prefix on the Markdown under `docs/`) is a dated exception, not a rename.** Alternative: rename ten files and every live citation now. Taken because no gate reads the prefix, the rename touches the port ledger, the Play listing sources and many tickets, and it fits the registry work of S0034. Exception E5, until 2026-12-31. Owner may overrule.
3. **DOC-INTERNAL-QUALITY is declared `pending` with a dated exception and the Draft S0034, not built in this pass.** Alternative: write the document registry and the link gate now (the siblings did, in a ticket of their own). Taken: it is a new gate with its own corpus decisions, far above this ticket's size. Owner may overrule.
4. **TASK-FLOW is declared `pending` without a rule-by-rule read.** Alternative: read the contract (about 1 200 lines) and claim a date. Taken: the sibling Filler Android declared it the same way, and a date with no read behind it is worse than none. Owner may overrule.
5. **DOC-EXTERNAL-QUALITY gets no row in this pass.** Whether the help pages under `site/help/` make this product a publisher of external documentation is a reading of the contract's section 3 that S0034 does together with the internal corpus. Owner may overrule.
6. **The SZA-CTR02 warning is left alone.** It names `PLAN/archive/S0001_canon-and-foundation.md`; an archive is frozen (`REPO-LAYOUT` rule 6) and the warning belongs to S0016. Owner may overrule.

## 4. Record of the pass (2026-11-14)

### 4.1 What changed in the canon since the stamp, and what it means here

Stamped: canon 2026.11.09.1, digest `9abe1d23..`, reconciled 2026-11-10. Current: canon 2026.11.13.8, plugin 2026.1113.8, digest `75bd013b..`. The rule documents that changed (git diff of the canon's `rules/` between `1f71679` and `HEAD`, README, SPREAD_BACK_PROMPT and contrib excluded - the digest's own scope) are eleven; each was read:

| Canon document | What changed | Reading for this repository | Result |
| --- | --- | --- | --- |
| `INVARIANTS` | Play `applicationId` is bound when the console app is created | The console app was created 2026-11-13 with `com.sza.deviceinfo` | DIVERGE found, fixed (4.2) |
| `PLATFORM_OVERLAYS` | the same, and "first public presence, before any bundle" | Same; the order was followed by S0014 and the owner's session | DIVERGE found, fixed (4.2) |
| `CHANNEL_MATRIX` | `msstore` machine channel; the Play console app comes first | Play only; the console app exists | none |
| `NEW_PROJECT_CHECKLIST` | no-plugin switch for CI gates; first-commit, branch, history-scan and `pq hold` steps; Android store product step | The Pages check job calls `render-landing.ps1 -Check` and `check-help-map.ps1`, neither names the harness, the plugin or the catalog (grep, no hit); the one-time steps are past | none |
| `SITE_CONFIGURATION` | `core.autocrlf` off on a Windows runner; Pages workflow template; privacy-pages-only minimum | `pages.yml` has the step before `actions/checkout`; its diff against `templates/github-pages.yml` is product literals and two extra trigger paths | none |
| `REPOSITORY_LAYOUT` | `*token*` and `*secret*` globs hide product source (`SZA-SEC05`) | `.gitignore` has `/token` and `/secret`, anchored at the root; `git ls-files --others --ignored --exclude-standard --directory` lists build output only; `git check-ignore docs/design/tokens.json` exits 1; the gate prints no SZA-SEC05 | none |
| `DOCUMENTATION_CONCEPT`, `LOCALIZATION` | `og:locale` in the 13-language `ll_CC` map | All six pages carry `en_US`, `ru_RU` or `uk_UA` (grep) | none |
| `TESTING_AND_QA` | an unattended pass runs the declared compile check once | `commands.compileCheck` is absent: "no compile command" | none |
| `DEVELOPMENT` | `DO:` owner actions, cross-repository `BlockByOtherTask`, back-links (TASK-FLOW rule 69) | Harness behaviour; `CLAUDE.md` section 4 does not restate it; this ticket files and holds nothing | none |
| `AI_USAGE` | an unattended pass assumes the reversible recommendation | This pass did, under the Assumed heading above | none |

### 4.2 Files touched

- `.sza-canon.json`: `canon.version` 2026.11.13.8, `canon.coreDigest` `sha256:75bd013b..` (from `check-compliance.ps1 -PrintDigest`), `canon.reconciledOn` 2026-11-14; `adoptedOn` unchanged.
- The application-id wording ("frozen with the first shipped package", "still editable until a package ships") became "frozen since the Play Console app was created with it on 2026-11-13": `CLAUDE.md` (sections 1 and 3), `docs/RELEASE.md`, `gradle.properties` (comment), `phone/build.gradle.kts` and `wear/build.gradle.kts` (comments only). The historical records `PLAN/S0008_independent-release.md` keep the owner's decision as written that day.
- `docs/contracts/RULE-ADOPTION.md`, `TASK-FLOW.md`, `DOC-INTERNAL-QUALITY.md` (new pointers), `docs/contracts/README.md` (19 rows, E5, the S0034 line), `CLAUDE.md` section 5 and `docs/README.md` (index sentences).
- The shared catalog's `_meta/REGISTRY.md`, this product's own rows only: six adoption rows after the `SITE-FAMILY-MAP | DeviceInfo Android` row, and two exception rows after E4 (`REPO-LAYOUT` E5, `DOC-INTERNAL-QUALITY`), both until 2026-12-31.
- New local Draft `PLAN/S0034_docs-registry-and-link-gate.md`.
- Second pass, 2026-11-14: `rules/contrib/deviceinfo_mob.md` in the canon repository gained the section `## Canon adoption 2026-11-14` (section 4.4 below is its source); no other canon file was touched.

### 4.3 Which of the six canon-layer contracts bind this repository

All six. `REPO-STAMP`, `HARNESS-PROFILE`, `REPO-LAYOUT` and `RULE-DELIVERY` bind through the stamp, the profile, the layout and the plugin; `TASK-FLOW` because the repository runs the harness; `DOC-INTERNAL-QUALITY` because it maintains internal documentation (`docs/`, `PLAN/`). `DOC-EXTERNAL-QUALITY` is not decided (Assumed 5).

### 4.4 Canon hand-off, for the canon session (the contrib refresh request)

The canon's `rules/contrib/deviceinfo_mob.md` section "Canon state of this repository, 2026-11-13" is out of date after this pass. Facts for the refresh, all measured 2026-11-14 in this repository:

- Stamp: canon 2026.11.13.8, digest `75bd013b..` equal to the canon's, `reconciledOn` 2026-11-14, `adoptedOn` 2026-11-10; `check-compliance.ps1` exit 0, 0 errors, 1 warning (SZA-CTR02, `PLAN/archive/S0001_canon-and-foundation.md`, ticket S0016); before the pass it also printed SZA-CANON03.
- One DIVERGE closed in this repository: the product's own text said the application id freezes with the first shipped package; the canon (INVARIANTS, PLATFORM_OVERLAYS) and the contrib record say it froze when the console app was created. The text is corrected in six files; the canon needs no change.
- Catalog: 19 registry rows for this product (`contract-lag.ps1 -Product DeviceInfo`: current 4, pending 15, unparsed 0); two exceptions added (`REPO-LAYOUT` E5, `DOC-INTERNAL-QUALITY`), until 2026-12-31; pointers `RULE-ADOPTION.md`, `TASK-FLOW.md`, `DOC-INTERNAL-QUALITY.md`.
- Contrib section "Deltas by document" candidates: `CONTRACTS.md` now has six more consumed contracts and a `contract-sync` run is owed to no one (rows written); `REPOSITORY_LAYOUT.md` rule 3 (type prefix) is the one open layout divergence; `TESTING_AND_QA.md` section 2 is unchanged (no compile command).
- Canon fixes found: none.

How it reached the canon: the first pass did not write it (the facts above were its hand-over); the second pass of 2026-11-14 re-measured the stamp, the gate, the validator, the queue, the pointers and the registry rows (4.5, second block) and wrote the section `## Canon adoption 2026-11-14` into `rules/contrib/deviceinfo_mob.md` (Assumed 1). The section is written and not committed in the canon repository.

### 4.5 Evidence (fresh runs, 2026-11-14)

| Check | Command | Exit | Expected / actual |
| --- | --- | --- | --- |
| Canon digest | `check-compliance.ps1 -PrintDigest` (plugin root) | 0 | stamp digest = printed digest `75bd013b..` / equal |
| Compliance gate, before | `check-compliance.ps1` | 0 | SZA-CANON03 and SZA-CTR02 / both printed |
| Compliance gate, after | `check-compliance.ps1` | 0 | no SZA-CANON03 / 0 errors, 1 warning (SZA-CTR02 only) |
| Ticket validator | `tools/harness.ps1 spec_catalog/validate` | 0 | 0 FAIL / 10 OK, 0 WARN, 0 FAIL |
| Release queue | `tools/harness.ps1 spec_catalog/release-queue -Validate` | 0 | no drift / `OK - 34 ticket(s), no drift` |
| Version parity | `tools/release/check-version-parity.ps1` | 0 | PASS / PASS (144 checks) |
| Surfaces | `tools/docs/check-surfaces.ps1` | 0 | string keys and permissions agree / OK |
| Pointers | `tools/contracts/check-pointers.ps1` | 1 | the four new pointer files OK / 17 checked, 2 mismatches, both `ICONOGRAPHY.md` (ICON-SET 0.39 against 0.40, ICON-RENDER 0.24 against 0.25: S0031, known) |
| Registry rows | `contract-lag.ps1 -Product DeviceInfo` (plugin tools) | 0 | 19 rows, 0 unparsed / current 4, pending 15, unparsed 0 |

Second pass, fresh runs 2026-11-14 (the first block above is the first pass's and stays as its record):

| Check | Command | Exit | Expected / actual |
| --- | --- | --- | --- |
| Canon digest | `check-compliance.ps1 -PrintDigest` (plugin root) | 0 | stamp digest = printed digest / `sha256:75bd013b..` and canon `2026.11.13.8`, both equal to `.sza-canon.json` |
| Compliance gate | `check-compliance.ps1` | 0 | no SZA-CANON03 / `0 error(s), 1 warning(s)`, the warning is SZA-CTR02 only |
| Ticket validator | `tools/harness.ps1 spec_catalog/validate` | 0 | 0 FAIL / `10 OK, 0 WARN, 0 FAIL` |
| Release queue | `tools/harness.ps1 spec_catalog/release-queue -Validate` | 0 | no drift / `OK - 34 ticket(s), no drift` |
| Pointers | `tools/contracts/check-pointers.ps1` | 1 | only the known S0031 pair fails / 17 checked, 2 skipped, 2 mismatches, both `ICONOGRAPHY.md` |
| Registry rows | `contract-lag.ps1 -Product DeviceInfo` (plugin tools) | 0 | 19 rows, 0 unparsed / current 4, pending 15, unparsed 0 |
| Registry exceptions | grep of `P:\Contracts\_meta\REGISTRY.md` | - | `REPO-LAYOUT` E5 and `DOC-INTERNAL-QUALITY` rows present / lines 872 and 873 |
| Contrib record | grep of `rules/contrib/deviceinfo_mob.md` | - | the dated section names canon `2026.11.13.8` and `reconciledOn` 2026-11-14 / line 80 heading, lines 82 and 84 |

Compile gate: two build scripts and one properties file were edited, comments only (first pass; the second pass edited no compiled source). `commands.compileCheck` is absent from `.sza-profile.json`: no compile command, nothing compiled, nothing tested. `check-version-parity.ps1` reads `gradle.properties` and passed after the edit. The release rung that covers it is `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug` (`RELEASE`).

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14

## Last Audit

**Date:** 26-11-14 | **Mode:** re-audit | **Outcome:** Verified
**Counts:** PASS 13 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 1 | RELEASE 1

Re-audit of the second pass; the checks were re-run in this pass (section 4.5, second block). Criteria of section 2, then the pass's own checks:

- PASS - criterion 1: `.sza-canon.json` carries 2026.11.13.8, `sha256:75bd013b..` (equal to `check-compliance.ps1 -PrintDigest`) and `reconciledOn` 2026-11-14.
- PASS - criterion 2: `check-compliance.ps1` exit 0, no SZA-CANON03 (0 errors, 1 warning, SZA-CTR02).
- PASS - criterion 3: eleven changed rule documents read, one divergence (application id freeze) fixed in six files, the layout and documentation gaps recorded as dated exceptions (section 4.1, 4.2).
- PASS - criterion 4 (was WARN): the refresh is carried out in a stronger form than a request - the canon's contrib record of this product holds `## Canon adoption 2026-11-14` naming canon 2026.11.13.8 and `reconciledOn` 2026-11-14 (grep, line 80 and following), which is the second pass condition the first audit named; the facts are in section 4.4.
- PASS - the six canon-layer rows exist: `contract-lag.ps1 -Product DeviceInfo`, 19 rows, unparsed 0; the two exception rows are in the registry (lines 872, 873).
- PASS - the pointers of the new rows: `check-pointers.ps1` OK for `RULE-ADOPTION.md` (four ids), `TASK-FLOW.md`, `DOC-INTERNAL-QUALITY.md`; its exit 1 is the two known `ICONOGRAPHY.md` mismatches of S0031.
- PASS - `spec_catalog/validate` exit 0 (10 OK); `release-queue -Validate` exit 0 (no drift). `check-version-parity.ps1` and `check-surfaces.ps1` were last run by the first pass (exit 0, 144 checks); the second pass edited no file either reads.
- PASS - probe invariant: no `S0026` line in `phone/src` or `wear/src` (grep, 0 files); the ticket is not in the needs-manual-test status.
- PASS - house style: no `...` and no long dash in the new section of the contrib record (grep) nor in the new text of this ticket.
- PASS - scope purity: the one canon file written is this product's own contrib record, the exception adopt-canon allows (Assumed 1); no other canon file and no ticket of another repository was read or written; the registry edits are this product's own rows.
- PASS - document sync: registry records stated (this ticket, the contrib record, the registry rows); no user-facing surface changed, so the ship-together manifest has nothing to land.
- PASS - recurrence: the first pass's own scope line contradicted the skill (a project session may write its contrib record); recorded in Assumed 1, no new gate proposed - one sighting.
- EXEMPT - SZA-CTR02 (an archived ticket naming the catalog by path): belongs to S0016, the archive is frozen.
- RELEASE - the comment-only edits of two build scripts and `gradle.properties`: `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug` at the release (no compile command is declared; compiled, not tested).

### Action items
1. S0034 closes the exceptions E5 and `DOC-INTERNAL-QUALITY` by 2026-12-31 and decides DOC-EXTERNAL-QUALITY.
2. The new section in the canon's `rules/contrib/deviceinfo_mob.md` is written and not committed in the canon repository; committing it is the canon session's or the owner's step.

### Manual / on-target
- None.
