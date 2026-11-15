# S0047_contract-catchup-20261115

**Status:** Draft
**Created:** 2026-11-15
**Complexity:** medium - the amount of work is set by the spec generated at run time

## 0. Owner request (verbatim)

распространи задачи во все проекты чтобы сверились с новыми контрактами с момента (версии) последней сверки и делали это каждый раз перед релизом

(The owner, in the canon session, 2026-11-15.)

--- Canon session note (written by the agent from that order; not the owner's words) ---

Task: bring this product up to the current shared contracts, starting from the version it was last synchronized with, and make the same check the first step of every release.

Moved in the catalog on 2026-11-15 (see _meta/CONSOLIDATION-2026-11-15.md): STREAM-BANK 2.10, BOOLEAN-OPTION 2.2, COLLAPSIBLE-GROUP 1.3, SETTINGS-NAVIGATION 2.3, ICON-SET 0.41, DEVICE-EXCHANGE 1.15 (with REMOTE-SCHEDULE-2026-11-15.md), LIVE-BROADCAST 1.8, APP-COMMANDS 0.2, APP-ACTIVATION 0.15, CAPTURE-OUTPUT 0.8, and the new PORT-LEDGER 0.1, FUNCTION-PARITY 0.1, FILLER-RESERVE 0.1. The live spec below lists everything that moved since this product's own last synchronized version, not only these.

1. Generate the live synchronization spec. The catalog moves daily, so never work from a copy; run it when you start:

       pwsh -NoProfile -File "<sza plugin root>/tools/contract-lag.ps1" -Product "DeviceInfo Android" -EmitSpec -OutFile temp/contract-catchup-DeviceInfo-Android.md

   The plugin root is resolved as the contract-sync skill and the spec-all skill do it; the canon checkout (P:\WEB\sza-unified-rules\tools\contract-lag.ps1) has the same script. Per contract the spec lists the document-log entries between the version the registry says this product is synchronized with and the current one, each with its kind and what it obliges, plus the definition of done. Registry product names to use: "DeviceInfo Android".

   Note: Mostly `pending` rows: a first verification as much as a catch-up. ICON-SET 0.41 added five DeviceInfo meanings (proposed); the generated vocabulary follows after the FastMediaSorter Android exporter runs.

2. Run the `contract-sync` skill's catch-up path with that spec (its steps 4-6 for the contracts the spec lists): read every log entry since the last synchronized version against the code, fix a real divergence in this product, or record it as a dated exception (`_meta/RULES.md` section 7). A row that is `pending`, `partial` or `unparsed` is normalised by this product.

3. Edit only this product's own rows of `_meta/REGISTRY.md` (the version it is synchronized with and the Verified date) and its own pointers. Never another product's rows and never a contract's text; a problem found in a contract goes in as a PROPOSAL file in that contract's folder (`_meta/RULES.md` section 7).

4. Done when `contract-lag.ps1 -Product <the names above>` shows no `behind`, `partial`, `pending` or `unparsed` row of this product that does not carry a dated reason in the row, and the audit records the command, its exit code and the remaining count. Between releases nothing above 5 seconds runs: a build or a suite with no fast form is a `RELEASE` item in the audit.

5. Every release of this product starts the same way: before the version is cut, repeat steps 1-4 for the contracts that moved since the last release; the contract gate of the `release` skill (CONTRACTS.md section 6) reads the result. A release is not cut on a row that is stale or behind without a dated reason.

No older contract ticket of this project is open.


## 1. Problem

What is wrong or missing, in the owner's terms. One paragraph; no class names, no file paths.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- criterion one

## 3. Approach

### 3.1 Scope

What changes and what deliberately does not.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** none
