# FUNCTION-PARITY - pointer

| Field | Value |
| --- | --- |
| **Id** | `FUNCTION-PARITY` |
| **Version** | 0.1, draft (shared contracts catalog, `function-parity/`, read 2026-11-14) |
| **Home** | shared contracts catalog, `function-parity/` |
| **Owner** | shared |
| **Role here** | consumer - a derived product with one column per form factor, `DeviceInfo phone` and `DeviceInfo watch` |

This product joined the contract on 2026-11-13 through its own proposal (`PROPOSAL-2026-11-13-deviceinfo-joins-function-parity.md`, accepted with corrections: its additions are rules 1, 2, 5 and 6) and is named in the contract's `consumers` line.

What this repository owes (section 2 of the contract):

- **The columns (rules 1 and 2).** One cell per function and form factor, exactly one of `offered`, `planned deviceinfo-mob:<ticket>` or `not offered: <reason class>`; a deliberate subset says so once and reads `not offered: subset` for the family functions it does not carry. The register file of the FastMediaSorter family (`family-fastmediasorter.md`) does not exist yet; until it does the columns are `docs/PARITY_MATRIX.md`, written in the register's vocabulary so that it joins unchanged, and `tools/parity/check-matrix.ps1` proves every cell filled and every `planned` cell naming an open ticket (section 4 of the contract).
- **A new function, a change, a fix (rules 3 and 4).** A ticket that changes behavior names its scope - phone, wear or both - and updates the matrix rows it concerns in the same step (`CLAUDE.md` section 4); a function that another product's cell offers gets a Draft ticket captured there.
- **Both ways with the source (rule 5).** A change or a fix to a function offered in both columns is captured as a Draft in the other product's queue: candidates are recorded first in `docs/reverse-port-notices.jsonl` and handed over on the owner's order (`CLAUDE.md` section 2 rule 5); the drift check of `PORT-LEDGER` stays the safety net.
- **Alike (rule 6).** The phone and the watch carry one function under the same name, glyph and action: the glyph table `docs/design/tokens.json` and the matrix.

State: the registry row is declared (2026-11-14, ticket S0025), reads 0.1, `pending`. Adding the two columns to the register is open until the register file exists; FastMediaSorter Web seeds it (its ticket S0055 follows the contract's acceptance).
