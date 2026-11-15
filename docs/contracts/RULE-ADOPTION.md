# Rule adoption - pointers

| Id | Version read | Home | Role |
| --- | --- | --- | --- |
| REPO-STAMP | 0.13 | `rule-adoption/` | consumer |
| HARNESS-PROFILE | 0.17 | `rule-adoption/` | consumer |
| REPO-LAYOUT | 0.11 | `rule-adoption/` | consumer |
| RULE-DELIVERY | 0.12 | `rule-adoption/` | consumer |

Read 2026-11-14. The four contracts are the machine-readable interface between the canon and this repository: the stamp it declares, the tooling profile the shipped harness reads, the names a tool may address, and how the rule set arrives and how staleness is judged. The rules themselves stay in the canon's prose and are not restated here.

What this repository holds, and where it stands (ticket S0026, the canon re-sync of 2026-11-14):

- **`REPO-STAMP`.** `.sza-canon.json` at the root, valid JSON, the three top-level keys and the three `canon` keys, `schemaVersion` 1.0, role `product`, no exemption, no `docRegistryShape`. The stamp is written by the adopt-canon run and never by hand: `canon.version`, `coreDigest` and `reconciledOn` move together, `adoptedOn` (2026-11-10) never moves. The re-sync of 2026-11-14 wrote canon 2026.11.13.8.
- **`HARNESS-PROFILE`.** `.sza-profile.json` at the root, `version` `"1"`, no `paths` key (shipped defaults), the three lock domains with their shipped ranks and a complete path-rule list, `commands.compileCheck` absent (none declared), and the optional `extraction` block of 0.17 (rule 13: `ledger`, `scope`, `sourceProject` `fms-a`; ticket S0033, 2026-11-14), which `tools/port-ledger/` reads for the source root and the other keys equal the tools' own defaults. Harness scripts are run through `tools/harness.ps1` and never edited or copied (`CLAUDE.md` section 4).
- **`REPO-LAYOUT`.** `CLAUDE.md` carries the canon pointer and `AGENTS.md` delegates to it; pointers sit in `docs/contracts/` named by id and are indexed by `docs/contracts/README.md`; tickets are `PLAN/Sxxxx_<slug>.md` and the release package files keep their default names; `README.md`, `LICENSE` and a root `CHANGELOG.md` exist; `PLAN/archive` is never rewritten. Open: exception E5 (the Markdown under `docs/` carries no type prefix), ticket S0034.
- **`RULE-DELIVERY`.** The plugin `sza@sza-unified-rules` delivers the canon; its version is derived from `CANON_VERSION` (2026.11.13.8 gives 2026.1113.8). Staleness is judged by `check-compliance.ps1` from the installed plugin: equal digest owes nothing, a differing digest is a warning inside 180 days of `reconciledOn` and an error after; the fix is a re-run of the adopt-canon re-sync. No copy of the check lives here.

Registry rows: `REPO-STAMP`, `HARNESS-PROFILE`, `REPO-LAYOUT` and `RULE-DELIVERY | DeviceInfo Android`, role C, readings 0.13, 0.17, 0.11 and 0.12, written 2026-11-14 (ticket S0026), each with a verification date of that day. The one exception is E5 on `REPO-LAYOUT`, dated 2026-12-31.
