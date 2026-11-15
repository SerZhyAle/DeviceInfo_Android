# PORT-LEDGER - pointer

| Field | Value |
| --- | --- |
| **Id** | `PORT-LEDGER` |
| **Version** | 0.1, draft (shared contracts catalog, `port-ledger/`, read 2026-11-14) |
| **Home** | shared contracts catalog, `port-ledger/` |
| **Owner** | shared |
| **Role here** | consumer - a product derived from FastMediaSorter Android (the source product), which keeps a ledger and a drift check of its own |

This product is named in the contract's `consumers` line. Before the contract existed the repository kept the same ledger and the same fields (S0003); the contract's rule 2 is the format the ledger already had.

What this repository owes (section 2 of the contract), and where it stands:

- **The ledger (rules 1 and 2).** `docs/port-ledger.jsonl`, UTF-8 JSON Lines, one object per ported file with `source`, `sourceSha256`, `destination` and `portedOn`, plus `destinationSha256`, `destinationHashedOn` (a field the contract does not name; a reader skips it) and `carriedOn`. Written by `tools/port-ledger/record-port.ps1`.
- **The statuses and exit codes (rules 3, 4 and 7).** `tools/port-ledger/check-drift.ps1` gives the five states of rule 4 (it prints `in step` for `OK` and `decided` for `DECIDED`, then `DRIFT`, `SOURCE GONE` and `NO DEST`) and exits 0, 1 or 2; `tools/port-ledger/check-local-divergence.ps1` gives `LOCAL EDIT`, which is informational and, with `-RequireClassified`, fails on an unclassified edit, a missing destination or a missing baseline. The scripts read the source checkout and never write it.
- **The scope file (rule 5).** `docs/port-scope.json` (`include` globs and `exclude` entries with a reason) with the decisions `docs/port-decisions.jsonl`; `tools/port-ledger/check-scope.ps1` gives `NEW SOURCE` and `STALE DECISION`.
- **At every release start (rule 9).** The three checks run and every uncovered row ends carried or decided before the release (`docs/RELEASE.md` step 1).
- **A defect found in ported behavior (rule 10)** goes to the source product's owner as a hand-off through `docs/reverse-port-notices.jsonl`; where the function is a register row, `FUNCTION-PARITY` rule 5 captures the ticket.
- **The source root (rule 8) and the `extraction` block (rule 12).** `.sza-profile.json` declares `extraction` with `ledger` `docs/port-ledger.jsonl`, `scope` `docs/port-scope.json` and `sourceProject` `fms-a` (ticket S0033, 2026-11-14; `lagBudgetDays` is not declared: neither contract gives it a meaning). `tools/port-ledger/_ledger.ps1` finds the source root in this order: the `-SourceRoot` argument, `SZA_PORT_SOURCE_ROOT`, `DEVICEINFO_FMS_ROOT` (this product's own variable, accepted until its next release), then the path the portfolio registry (`repos.json` under `SZA_PORTFOLIO_ROOT`, else `%USERPROFILE%\.sza\portfolio`) holds for the project `extraction.sourceProject` names. No path to a checkout is kept in a tracked file; a root that cannot be found is exit 2. The self-test `tools/port-ledger/test-port-ledger.ps1` proves each step, the exit 2 cases, and that the profile's `ledger` and `scope` equal the tools' own defaults.

Recorded gap of this product's own check (section 3 of the contract; the registry row says the same): the contract's own conformance cases (rule 13) do not exist in the catalog yet and are not run.

State: the registry row is declared (2026-11-14, ticket S0025) and re-written by S0033 the same day, reads 0.1, `pending`.
