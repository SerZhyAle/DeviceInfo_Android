# S0033_port-ledger-source-root-and-extraction

**Status:** Implemented
**Status note:** no compile command (no compiled source edited; commands.compileCheck absent). Source root resolves argument, SZA_PORT_SOURCE_ROOT, DEVICEINFO_FMS_ROOT, registry fms-a; extraction block declared; default path removed. Self-tests 36 PASS 0 FAIL, real drift/scope/local-divergence exit 0 from the registry. Registry rows and pointers updated. RELEASE: none new; drop DEVICEINFO_FMS_ROOT at the next release.
**Created:** 2026-11-14
**Complexity:** medium - assessed at the spec pass of 2026-11-14 and confirmed at the plan pass: one JSON key block, one PowerShell core file (`tools/port-ledger/_ledger.ps1`) and its self-test, four documents and two rows of the shared registry; no compiled source, no wire, no contract text. The weight is in the resolution order (a wrong order silently shadows an override) and in proving every unresolvable case is exit 2, which the self-test now carries

## 0. Owner request (verbatim)

Agent finding (not the owner's words), found during S0025 on 2026-11-14 while writing the PORT-LEDGER registry row.

PORT-LEDGER 0.1 (shared contracts catalog, domain port-ledger/) rule 8 finds the source root from an explicit argument, then the environment variable SZA_PORT_SOURCE_ROOT, then the portfolio registry's path of the project that `extraction.sourceProject` names, and says the root "is never a path in a tracked file". Rule 12 declares the optional `extraction` block of HARNESS-PROFILE 0.17 (the ledger path, the scope file, the source project's registry key and lagBudgetDays). The product's own variable DEVICEINFO_FMS_ROOT stays accepted until the product's next release.

Evidence (read 2026-11-14):
- tools/port-ledger/_ledger.ps1 sets `$script:UpstreamRoot = 'P:\ANDROID\FastMediaSorter_mob_v2'` (line 24) and `Get-SourceRoot` ends in it, after the explicit argument, SZA_PORT_SOURCE_ROOT and DEVICEINFO_FMS_ROOT. That is a path in a tracked file.
- `.sza-profile.json` has no `extraction` block (S0018 left it out on purpose: the tools carry their own defaults), so rule 8's registry-path fallback does not exist.
- Both gaps are recorded as such in the registry row `PORT-LEDGER | DeviceInfo Android` (section 3 of the contract asks for exactly that) and in docs/contracts/PORT-LEDGER.md.

Wanted, for the ticket's own pass to settle: read the current text of PORT-LEDGER rule 8 and rule 12 and HARNESS-PROFILE 0.17 rule 13; add the `extraction` block to `.sza-profile.json`; make the ledger tools resolve the source root through SZA_PORT_SOURCE_ROOT and the registry fallback, with DEVICEINFO_FMS_ROOT kept until the next release; remove the default path from `_ledger.ps1`; keep every `tools/port-ledger` self-test green; update the registry row and the pointer when it is done. The ticket must not edit the upstream checkout.


## 1. Problem

The port-ledger tools of this product ended their search for the upstream checkout in a workstation path written into a tracked file, which the shared contract forbids, and the profile did not name the source product at all, so the portfolio's own way of finding a checkout (its registry) could not be used. A clone on another machine would either fail or, worse, silently read a stale folder that happens to sit at that path. The product's own registry row and pointer carried both gaps as open.

## 2. Done criteria

Each is a command or an observation that can be repeated.

1. `.sza-profile.json` parses and holds `extraction` with `ledger` `docs/port-ledger.jsonl`, `scope` `docs/port-scope.json` and `sourceProject` `fms-a`; `spec_catalog/validate` exits 0 with the block present.
2. With no `-SourceRoot` and none of `SZA_PORT_SOURCE_ROOT`, `DEVICEINFO_FMS_ROOT`, `SZA_PORTFOLIO_ROOT` set, `tools/port-ledger/check-drift.ps1` exits 0 and its report line reads `Upstream root: .. (from registry:fms-a)`; the same for `check-scope.ps1`.
3. A fixed-string search of `tools/port-ledger/*.ps1` for a drive-letter path finds none (the self-test asserts it for every non-test script).
4. A root that cannot be found - a variable pointing nowhere, a registry path that does not exist, a registry without the project, a registry that is not JSON, a missing registry - is exit 2, never 0 and never a silent fall-through to the next step.
5. `DEVICEINFO_FMS_ROOT` stays accepted, behind `SZA_PORT_SOURCE_ROOT` and before the registry.
6. `test-port-ledger.ps1`, `test-port-scope.ps1` and `test-local-divergence.ps1` exit 0; `check-local-divergence.ps1 -RequireClassified` exits 0.
7. The registry rows `PORT-LEDGER | DeviceInfo Android` and `HARNESS-PROFILE | DeviceInfo Android`, the pointer `docs/contracts/PORT-LEDGER.md`, `docs/contracts/RULE-ADOPTION.md`, `docs/contracts/README.md` and `tools/port-ledger/README.md` say the same thing; `tools/contracts/check-pointers.ps1` exits 0.
8. Nothing under the upstream checkout was written.

## 3. Approach

### 3.1 Scope

Changes: `.sza-profile.json` (the block); `tools/port-ledger/_ledger.ps1` (`Get-SourceRoot` and three small readers, the default path removed); `check-drift.ps1` and `check-scope.ps1` (one report line gains the origin of the root); `test-port-ledger.ps1` (20 new expectations); `tools/port-ledger/README.md`; the pointers `docs/contracts/PORT-LEDGER.md`, `RULE-ADOPTION.md` and `README.md`; and, in the shared catalog, only this product's own two rows of `_meta/REGISTRY.md` (section 2 of the registry; the same edit rights S0025 and S0026 used).

Does not change: any contract text; the ledger and its rows; the scope file and the decisions; any other product's profile, ticket or row; compiled source; phone and wear (scope: neither, there is no user-visible behavior, so `docs/PARITY_MATRIX.md` has no row to update); the upstream checkout.

Contract boundary: the ticket implements what `PORT-LEDGER` 0.1 rules 8 and 12 and `HARNESS-PROFILE` 0.17 rule 13 already say; it amends nothing in the catalog, so no catalog-first step exists. The registry rows are the consumer's own adoption record.

### 3.2 Open questions

None open. The reversible choices are in `### Assumed` below.

### 3.3 Owner inputs (Approval gate)

None needed: no one-way or outward step, no contract change, no scope change, no money.

- **Related tickets:** S0018 (wrote the scope check and the first `SZA_PORT_SOURCE_ROOT` step), S0025 (declared the registry row and filed this ticket), S0026 (the canon-layer rows; named this ticket for the profile block), S0019 (the local-divergence tools, which do not read the source root)

### Assumed (unattended, 2026-11-14)

Each was taken because it is reversible inside this ticket and has a researched recommendation. Owner may overrule.

1. **`DEVICEINFO_FMS_ROOT` sits after `SZA_PORT_SOURCE_ROOT` and before the registry.** The contract says only that the product's own variable "stays accepted"; an explicit machine override should beat a lookup, and this was the order before. Alternative: after the registry (the registry would then shadow a developer's override). Owner may overrule.
2. **`lagBudgetDays` is not declared.** `PORT-LEDGER` and `HARNESS-PROFILE` both say they give it no meaning and it has no shipped default; a number nobody chose would be an invented fact. Filler Android's profile omits it too. Alternative: declare an arbitrary number. Owner may overrule.
3. **The tools keep their own default ledger and scope paths; the profile declares the same two paths, and the self-test fails if they differ.** Alternative: make every script read both from the profile (one source, but every script and the self-test fixtures gain a profile dependency, and S0018 left the defaults in the tools on purpose). Owner may overrule.
4. **The registry is read by a small reader in `_ledger.ps1`, not by dot-sourcing the plugin's `lib/registry.ps1`.** The tools must run on a clone without the plugin installed and the plugin's install path is machine-specific, which is the very thing rule 8 forbids in a tracked file. The reader knows only the file location (`SZA_PORTFOLIO_ROOT`, else `%USERPROFILE%\.sza\portfolio\repos.json`) and the two fields `key` and `path`. Alternative: depend on the plugin. Owner may overrule.
5. **The `Verified` column of the registry row stays `pending`.** The conformance cases of rule 13 (rung 2) do not exist in the catalog, so a dated verification would claim more than ran. Alternative: date it today on rung 1 and rung 3 only. Owner may overrule.
6. **`CHANGELOG.md` is not touched.** No user-visible change: tooling, profile and records only (the same call as S0025).

## 4. Record of the pass (2026-11-14)

### 4.1 Contract text read (fresh, 2026-11-14)

`PORT-LEDGER` 0.1 (`port-ledger/README.md` of the catalog): rule 8 (argument, `SZA_PORT_SOURCE_ROOT`, the registry path of `extraction.sourceProject`; "never a path in a tracked file"; the product's own variable stays accepted until its next release), rule 7 (a root that cannot be found is exit 2, never 0), rule 12 (the block declares ledger path, scope file, source registry key and `lagBudgetDays`). `HARNESS-PROFILE` 0.17 rule 13 (`rule-adoption/README.md`, amendment 2026-11-13): `ledger` required inside the block, `scope`, `sourceProject`, `lagBudgetDays` optional, objects merge key by key, no key has a shipped default, a profile without the block declares no extraction. The registry file is `repos.json` under `SZA_PORTFOLIO_ROOT`, else `%USERPROFILE%\.sza\portfolio` (`lib/paths.ps1` of the harness); the key of the source product there is `fms-a`.

### 4.2 Files touched

- `.sza-profile.json` - the `extraction` block.
- `tools/port-ledger/_ledger.ps1` - `$script:UpstreamRoot` removed; `Get-PortfolioRegistryFile`, `Get-ExtractionSourceProject`, `Get-RegistrySourceRoot` added; `Get-SourceRoot` rewritten and sets `$script:SourceRootOrigin`.
- `tools/port-ledger/check-drift.ps1`, `tools/port-ledger/check-scope.ps1` - the `Upstream root:` line names the origin.
- `tools/port-ledger/test-port-ledger.ps1` - 20 new expectations (16 before, 36 now); the header describes them.
- `tools/port-ledger/README.md`, `docs/contracts/PORT-LEDGER.md`, `docs/contracts/RULE-ADOPTION.md`, `docs/contracts/README.md`.
- Shared catalog, this product's rows only: `_meta/REGISTRY.md` lines of `PORT-LEDGER | DeviceInfo Android` and `HARNESS-PROFILE | DeviceInfo Android`.
- This ticket's spec.

A finding of the pass: a test variable `$profileFile` silently overwrote `$script:ProfileFile` (PowerShell variable names are case-insensitive), failing the first run of the new expectations; fixed in the test by renaming it to `$tmpProfile`.

### 4.3 Evidence (fresh runs, 2026-11-14, from the repository root; `SZA_PORT_SOURCE_ROOT`, `DEVICEINFO_FMS_ROOT` and `SZA_PORTFOLIO_ROOT` verified empty first)

| Command | Exit | Expected / actual |
| --- | --- | --- |
| `pwsh -NoProfile -File tools/port-ledger/test-port-ledger.ps1` | 0 | expected: all expectations held, 0 FAIL; actual: 36 PASS, 0 FAIL, `port-ledger self-test: all expectations held.` (0.59 s) |
| `pwsh -NoProfile -File tools/port-ledger/test-port-scope.ps1` | 0 | expected: held; actual: `port-scope self-test: all expectations held.` (0.83 s) |
| `pwsh -NoProfile -File tools/port-ledger/test-local-divergence.ps1` | 0 | expected: held; actual: `local divergence self-test: all expectations held.` (0.76 s) |
| `pwsh -NoProfile -File tools/port-ledger/check-drift.ps1` (no argument) | 0 | expected: root from the registry; actual: `Upstream root: P:\ANDROID\FastMediaSorter_mob_v2 (from registry:fms-a)`, `OK: nothing uncarried (104 in step, 0 decided).` (0.35 s) |
| `pwsh -NoProfile -File tools/port-ledger/check-scope.ps1` (no argument) | 0 | expected: root from the registry, 0 NEW SOURCE; actual: `(from registry:fms-a)`, 114 files and 281 string keys in scope, `376 ported, 19 decided`, 0 NEW SOURCE, 0 STALE DECISION (1.98 s) |
| `pwsh -NoProfile -File tools/port-ledger/check-local-divergence.ps1 -RequireClassified` | 0 | expected: all classified; actual: 9 local edits, 0 unclassified, 0 missing (0.38 s) |
| `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` | 0 | expected: 0 FAIL with the block present; actual: 10 OK, 0 WARN, 0 FAIL (0.79 s) |
| `check-compliance.ps1` from the installed plugin root | 0 | expected: 0 errors; actual: 0 errors, 1 warning (SZA-CTR02 in `PLAN/archive/S0001`, S0016's, not this change) (0.72 s) |
| `pwsh -NoProfile -File tools/contracts/check-pointers.ps1` | 0 | expected: 0 mismatch; actual: 19 pointers checked, 0 mismatches (0.41 s) |
| `pwsh -NoProfile -File tools/docs/check-surfaces.ps1` | 0 | expected: held; actual: OK, string keys and permission surfaces agree (0.34 s) |
| Grep `[A-Za-z]:\\` over `tools/port-ledger/*.ps1` | - | expected: no match; actual: no match |

The self-test also proves each unresolvable case is exit 2 (variable pointing nowhere, registry path that does not exist, registry without the project, registry not JSON, registry missing) and that the profile's `ledger` and `scope` equal the tools' defaults.

No command of this pass wrote under `P:\ANDROID\FastMediaSorter_mob_v2`: the scripts open it for reading, and the self-test works on a throw-away tree under `temp/S0003`.

Compile gate: no compiled source was edited (JSON, PowerShell and Markdown only), and `commands.compileCheck` is absent from `.sza-profile.json`: no compile command, none run.

### 4.4 Release items

- At the product's next release (PORT-LEDGER rule 8, "until that product's next release"): drop `DEVICEINFO_FMS_ROOT` from `Get-SourceRoot`, `tools/port-ledger/README.md`, `docs/contracts/PORT-LEDGER.md` and the self-test expectation `DEVICEINFO_FMS_ROOT stays accepted`. The release owner decides the day; nothing here forces it.
- The conformance cases of rule 13 do not exist in the catalog; when they do, run them on this product's tool and date the registry row.

## Last Audit

**Date:** 26-11-14 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 14 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 0

Criteria of section 2 against the runs of section 4.3, then the checklist:

- PASS - criterion 1: the block is in `.sza-profile.json`; `spec_catalog/validate` exit 0, 10 OK, 0 WARN, 0 FAIL with it present.
- PASS - criterion 2: `check-drift.ps1` and `check-scope.ps1` with no argument and no variable exit 0 and print `(from registry:fms-a)`.
- PASS - criterion 3: Grep `[A-Za-z]:\\` over `tools/port-ledger/*.ps1` found no match (a miss is the pass here); the self-test asserts the same.
- PASS - criterion 4: the five unresolvable cases are exit 2 in the self-test (expected: 2 | actual: 2 each).
- PASS - criterion 5: the self-test case `DEVICEINFO_FMS_ROOT stays accepted` and `SZA_PORT_SOURCE_ROOT comes first` hold the order.
- PASS - criterion 6: the three self-tests exit 0 and `check-local-divergence.ps1 -RequireClassified` exit 0.
- PASS - criterion 7: registry rows, pointer, `RULE-ADOPTION.md`, `README.md` and the tool README were edited in one pass; `check-pointers.ps1` exit 0 (19 checked, 0 mismatch).
- PASS - criterion 8: no write path to the upstream exists in the scripts (they open it for reading only); the self-test runs on a throw-away tree.
- PASS - scope purity: every edit is in the file list of section 4.2; the one shared file written is this product's own two registry rows; no ticket of another repository was read or written.
- PASS - probe invariant: no `S0033` line in `phone/src` or `wear/src` (grep, 0 files); the ticket is not in the needs-manual-test status.
- PASS - house style: no `...` and no long dash in the spec or in `_ledger.ps1` (grep, 0 matches).
- PASS - document sync: registry rows, pointer, `RULE-ADOPTION.md`, contracts `README.md`, tool README, self-test header; no user-facing surface changed, so the ship-together manifest has nothing to land.
- PASS - contract boundary: nothing another product reads or writes changed; rules 8 and 12 and rule 13 are implemented as the catalog states them, no catalog text amended.
- PASS - recurrence: the case-insensitive variable clash of the test (`$profileFile` over `$script:ProfileFile`) is one sighting; no gate proposed.
- EXEMPT - `CHANGELOG.md`: no user-visible change (tooling and records).
- EXEMPT - build, unit tests, lint: no compiled source edited and no compile command declared (`commands.compileCheck` absent); nothing above 5 s was run (the slowest run was `check-scope.ps1`, 1.98 s).

### Action items
1. At the product's next release drop `DEVICEINFO_FMS_ROOT` (section 4.4); the day is the release owner's.
2. When the catalog gains the conformance cases of rule 13, run them and date the `PORT-LEDGER | DeviceInfo Android` row.

### Manual / on-target
- None.
