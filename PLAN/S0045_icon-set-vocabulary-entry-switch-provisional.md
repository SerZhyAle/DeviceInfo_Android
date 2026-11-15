# S0045_icon-set-vocabulary-entry-switch-provisional

**Status:** Draft
**Created:** 2026-11-15
**Complexity:** light - five tokens entries and a check re-run, once the catalog vocabulary reads 0.41

## 0. Owner request (verbatim)

Agent-noticed finding of the S0044 pass (2026-11-15), not an owner order.

ICON-SET 0.41 (catalog README section 27) accepted this product's five meanings (`system.hardware`, `system.memory`, `device.watch`, `system.health`, `system.environment`) as `proposed` records, but the vocabulary carrier (`iconography/vocabulary.jsonl`, `vocabulary.version`) still reads 0.40: the entry of the records is an owed step of the exporter's owner (FastMediaSorter Android), not of this repository.

When that step lands, `tools/design/check-tokens.ps1` fails by design ("'<id>' is now in the vocabulary - switch the source row from 'provisional' to 'meaning' and check its reference") and that failure turns the release-start gate red.

Needed: after the vocabulary carrier reads 0.41 or later, in `docs/design/tokens.json` switch the five `provisional` entries to `meaning`, check that each Android reference equals its drawable (note: `device.watch` carries the reference `ic_watch` of `source.watch`; `system.memory` shares its drawing with `feature.raw-probe`, declared on both sides), re-run `tools/design/check-tokens.ps1` and `tools/design/test-check-tokens.ps1`, and update the register rows (`docs/contracts/README.md`, `docs/contracts/ICONOGRAPHY.md`, the catalog registry row of ICON-SET). The restricted build's three `notShipped` groups stay as they are.

Trigger, not a date: the ticket is workable only once the catalog's vocabulary carrier reads 0.41. Until then it stays a Draft and nothing in this repository is red because of it.


## 1. Problem

The catalog's ICON-SET vocabulary is still at 0.40, so it does not yet hold the five system-information meanings this product draws: hardware, memory, the watch device, health and environment. The 0.41 amendment of the catalog already accepted them as proposed records, but the entry of the records is a step owed by the exporter's owner, FastMediaSorter Android. Until that step lands, the five source rows of the design token file stay `provisional` and the token check stays green. Once the vocabulary holds the meanings, the check fails by design on each of those rows, and that failure turns the release-start gate red. This ticket moves the five rows to `meaning`, checks each Android drawing against its reference, and brings the register rows up to ICON-SET 0.41, so the gate reads the vocabulary as it then stands.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- **Trigger:** `cat /p/Contracts/iconography/vocabulary.version` prints `ICON-SET 0.41` or a later version. Until it does, the ticket stays Draft and none of the criteria below is run.
- **Source rows:** in `docs/design/tokens.json` the five rows `system.hardware` (group HARDWARE), `system.memory` (group MEMORY), `device.watch` (watch section `system_info_section_device`), `system.health` and `system.environment` read `meaning`, and none keeps a `provisional` key for those ids. `pwsh -NoProfile -File tools/design/check-tokens.ps1` exits 0 and its verdict line starts `check-tokens: OK` with `vocabulary section: checked` (not skipped).
- **References:** the `device.watch` row keeps `ic_watch` of `source.watch`; the `system.memory` row keeps the drawing it shares with `feature.raw-probe`, declared on both sides. The verdict of the check above reports `0 mismatch(es)` for both.
- **Restricted build:** the three rows carrying `notShipped` (PERMISSIONS, INSTALLER_SIGNATURE, MOUNTS) keep their text, and `grep -c notShipped docs/design/tokens.json` still prints 3.
- **Self-test:** `pwsh -NoProfile -File tools/design/test-check-tokens.ps1` exits 0 with every expectation passing.
- **Registers:** `docs/contracts/README.md` and `docs/contracts/ICONOGRAPHY.md` name ICON-SET 0.41 and the five meanings as entered (`grep -n` of each id in both files finds the rows). The catalog registry row of ICON-SET is handled as recorded under Assumed below.
- **Docs gate:** after the edit of any corpus document, `pwsh -NoProfile -File tools/docs/check-docs.ps1` exits 0 with no finding outside `tools/docs/baseline.txt`.
- **No compiled source changes:** the edit is data and documents, so the compile check is not applicable here; no drawable, layout, string or colour changes, so no on-device claim is made.

## 3. Approach

### 3.1 Scope

In: the five `provisional` rows of `docs/design/tokens.json` move to `meaning`; the register rows of `docs/contracts/README.md` and `docs/contracts/ICONOGRAPHY.md` name ICON-SET 0.41.

Out: any drawable, layout, string or colour change; the restricted build's three `notShipped` groups; any write to the catalog at `P:\Contracts` (the vocabulary, its carrier and the catalog registry row belong to the exporter's step and the catalog side); any claim of product conformance to ICON-SET 0.41.

Shared-contract boundary: yes, ICON-SET (`docs/contracts/ICONOGRAPHY.md`). The catalog amendment already exists (catalog README section 27, ICON-SET 0.41); this ticket is a consumer of it and writes no boundary code.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

No open question. The owner's text settles the five ids, the drawable references, the restricted groups and the register rows. The catalog side of the registry row is recorded under Assumed below.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0044 (origin of the finding, this repository). The owed step lives in the catalog (README section 27), not in a ticket of this repository.

### Assumed (unattended, 2026-11-15)

- **Trigger not met, so the ticket stays Draft.** Checked 2026-11-15: `P:\Contracts\iconography\vocabulary.version` reads `ICON-SET 0.40`, and catalog README section 27 names the carrier step as owed by the exporter's owner (FastMediaSorter Android). The owner's text fixes the state at Draft until the carrier reads 0.41, so no source row was switched and no register row was edited. Alternative: park in `BlockByOtherTask` with a cross-repository blocker filed by `spec-draft.ps1 -Project fms-a`. Not taken: the owner set the Draft state explicitly, and the owed step is already recorded in the catalog and in this ticket, so a new FastMediaSorter queue item would duplicate it. Owner may overrule.
- **Catalog registry row not written from this repository.** The ICON-SET registry row moves with the carrier (catalog README section 27: the step "moves it with them to 0.41"), so the catalog side files it when the carrier reads 0.41, through the `contract-sync` path. Alternative: edit the row from here now. Not taken: it would record a version the catalog does not yet hold. Owner may overrule.
