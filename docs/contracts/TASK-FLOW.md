# TASK-FLOW - pointer

| Field | Value |
| --- | --- |
| **Id** | `TASK-FLOW` |
| **Version** | 0.27, draft (shared contracts catalog, `task-flow/`, read 2026-11-15) |
| **Home** | shared contracts catalog, `task-flow/` |
| **Owner** | shared |
| **Role here** | consumer - this repository runs the shared harness unmodified |

The contract's `consumers` line names every repository that runs the harness. This repository does: the ledger is `PLAN/spec-catalog.jsonl`, written only through `spec_catalog/insert`, `update`, `close` and `archive`; tickets are `PLAN/Sxxxx_<slug>.md` with the id grammar `^S\d{4}$`; the release package files are `PLAN/RELEASE_QUEUE.md`, `PLAN/RELEASE_READY.md` and `PLAN/RELEASE_QUEUE_DONE.md`; the root launchers `r0.ps1`, `r1.ps1` to `r3.ps1`, `rs.ps1`, `rm.ps1` and `rw.ps1` and the eight spec command forwarders in `.claude/commands/` are rendered by the harness scaffold. A harness script is run through `tools/harness.ps1` and is never edited or copied; the configuration is `.sza-profile.json` and nothing else (`HARNESS-PROFILE`, `docs/contracts/RULE-ADOPTION.md`). The operating rules of this repository's ticket store are in `CLAUDE.md` section 4.

Checked on 2026-11-14: `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` exit 0 (10 OK, 0 WARN, 0 FAIL) and `spec_catalog/release-queue -Validate` exit 0 (`OK - 34 ticket(s), no drift`).

Not claimed: the contract (about 1 200 lines, dozens of rules) was not read rule by rule, so the registry row stays `pending` and carries no verification date.

Re-read at 0.27 on 2026-11-15 (S0014): the 0.27 entry is additive - rule 70 moves a finished spec into `paths.specArchiveDir` and back on reopen, done by every harness tool that writes a status; this repository runs those tools unmodified, so nothing here changes.

State: the registry row `TASK-FLOW | DeviceInfo Android` is declared (2026-11-14, ticket S0026), reads 0.27, `pending`.
