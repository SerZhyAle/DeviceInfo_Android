# INPUT-PARITY - pointer

| Field | Value |
| --- | --- |
| **Id** | `INPUT-PARITY` |
| **Version** | 0.7, draft (shared contracts catalog, `input-controls/`, read 2026-11-13) |
| **Home** | shared contracts catalog, `input-controls/` |
| **Owner** | shared (column stewards) |
| **Role here** | adopter - touch, keyboard, mouse and D-pad on the phone; touch and the rotary crown on the watch |

What this repository owes, read from the contract's own device table (section 4) and not copied across devices:

- Phone surfaces: touch, keyboard, mouse and TV remote / D-pad per the table's own columns, from the first screen (`SystemInfoActivity`, S0004) onward - all actions in the toolbar and the list rows are reachable by tap, keyboard focus, D-pad navigation and mouse click.
- Watch surfaces: the touch column and the seeded rotary crown column (0.6, section 4) - a turn scrolls the focused list or page (`page`), in a player view it is `volume`, `confirm` is a tap because the crown's press is the system's (rule 3), one turn never drives two actions, and a turn is never the only route.
- The watch duties are the contract's watch cells: the phone's D-pad and mouse cells name no watch duty, so nothing of them is promised here.
- `help` answers `F1` (0.5, section 4) where the keyboard is attached, per `CONTEXT-HELP` rule 1.

Version steps since the pointer's recorded version (0.4; the "read 2026-11-11" capture was already stale then, 0.5 had been out since 2026-10-29):

- 0.5 (2026-10-29, clarification + additive): "applicable" defined, the viewer table governs viewers, `help` / `F1` added to the action vocabulary.
- 0.6 (2026-11-12, additive): the rotary crown (Wear OS) column, seeded - the watch's own duties, which the table did not carry before.
- 0.7 (2026-11-13, additive): section 3.3, the touch-locked screen, left only by a non-touch input, as a permanent supported variant - no duty of this product until it ships such a screen.

Registry row: `INPUT-PARITY | DeviceInfo Android`, role C (adopter), reads 0.7, declared 2026-11-14 (ticket S0025), verification `pending`. The contract's `consumers` line names "every product with a user interface", so no consumer entry is proposed. Exception E4 (until 2026-12-31): `help` and F1 were consumed with no help to open; S0024 wrote the help on 2026-11-14 (not compiled or run) and S0023 rechecks F1 and the toolbar action before E4 closes.
