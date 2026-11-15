# Contracts register - DeviceInfo Android

The one place that says which shared contracts this product consumes, what it asked of the catalog and what came of it,
and what is still open. Written by ticket S0025 on 2026-11-14 from the catalog as read that day. The catalog's own
registry is the authority for the adoption rows and the exceptions; this page follows it and names, for every contract,
the pointer file of this directory. Contracts are cited by id and section, never by path (the catalog is named once, in
`CLAUDE.md`).

Proof that the page and the catalog agree: `pwsh -NoProfile -File tools/contracts/check-pointers.ps1` (versions and
read dates of the pointers against the catalog) and, from the canon's `tools/` folder,
`contract-lag.ps1 -Product DeviceInfo` (lists the 20 registry rows below, none unparsed).

## 1. What this product consumes

All 20 rows are role consumer, declared 2026-11-14 (PACKAGE-VERSIONING since 2026-11-13). Sixteen are `pending`
verification; `pending` is an honest state: nothing is claimed that has not run on a device or a rendered page. Four
canon-layer rows (`REPO-STAMP`, `HARNESS-PROFILE`, `REPO-LAYOUT`, `RULE-DELIVERY`) carry the verification date 2026-11-14,
written by S0026 after the canon re-sync, because the stamp, the profile, the layout and the delivery are measured by the
compliance gate and the harness validator, not by a device.

| Contract | Read | Pointer | Exceptions (catalog, until 2026-12-31) | Open, and who owns it |
| --- | --- | --- | --- | --- |
| `CONTEXT-HELP` | 0.4 | `CONTEXT-HELP.md` | E4 | The help was written by S0024 on 2026-11-14 against 0.4, statically checked, not compiled or run; the device walk is S0007; E4 closes when S0023 rechecks the Help action; the Help index cell enters the family map once the pages answer |
| `INPUT-PARITY` | 0.7 | `INPUT-PARITY.md` | E4 | The keyboard and crown walk on a device (S0007) |
| `UI-SIZING` | 1.2 | `UNIFIED-UI.md` | E1, E2 | S0023 (Partial) and the device run (S0007); size-profile record `docs/UI_CONFORMANCE.md` |
| `BUTTONS` | 2.2 | `UNIFIED-UI.md` | E2, E4 | S0023 and S0007 |
| `COLLAPSIBLE-GROUP` | 1.3 (read 2026-11-15, S0044) | `UNIFIED-UI.md` | E3 | S0023 and S0007; 1.3 section 8 item B (a topic glyph on every heading of a page or on none) is met in source on both surfaces (phone 24 of 24 groups, watch 10 of 10 headers), the rendered order of triangle, glyph and title is an open check of S0007 |
| `ICON-SET` | 0.41 (read 2026-11-15, S0044) | `ICONOGRAPHY.md` | none; five meanings ship under their proposed ids (ICON-SET section 15; the last three are the watch's own header glyphs, S0035), accepted into 0.41 as `proposed` records | The exporter's owner enters the five records in the vocabulary carrier, which still reads 0.40 (owed by the catalog's decision, not by this product); S0045 then switches the five `provisional` token entries to `meaning`; the six meanings of 0.40 are not mapped here |
| `ICON-RENDER` | 0.25 (read 2026-11-14, S0031) | `ICONOGRAPHY.md` | none: section 25 rule 1 is met in source since S0035 (the watch headers carry a glyph on all ten members, the owner's choice); the phone overflow menu conforms, its popup draws no icons (S0035 inventory, 2026-11-14) | The rendered watch headers, rendered contrast and the overflow popup on a device (S0007) |
| `PACKAGE-VERSIONING` | 0.8 | `PACKAGE-VERSIONING.md` | none | The Kotlin vectors and the package read-back run at the release (S0008) |
| `FUNCTION-PARITY` | 0.1 | `FUNCTION-PARITY.md` | none | The two columns join the register when the register file exists (FastMediaSorter Web seeds it, its ticket S0055); the stand-in is `docs/PARITY_MATRIX.md` |
| `PORT-LEDGER` | 0.1 | `PORT-LEDGER.md` | none; gap recorded in the row | The conformance cases of rule 13 do not exist in the catalog yet; the source root (rule 8) and the `extraction` block (rule 12) were closed by S0033, 2026-11-14 |
| `PAGE-CONTENT` | 1.5 | `PRODUCT-WEB-PAGES.md` | none | `/site-audit` of the live pages at the release |
| `PAGE-STYLE` | 3.10 | `PRODUCT-WEB-PAGES.md` | none | the same audit |
| `SITE-FAMILY-MAP` | 1.12 | `PRODUCT-WEB-PAGES.md` | none | This product's own row: hub:S0009, after the listing answers 200 (rule 5) |
| `REPO-STAMP` | 0.13 | `RULE-ADOPTION.md` | none | Nothing: the stamp is current (canon 2026.11.13.8, reconciled 2026-11-14); the next re-sync is an adopt-canon run, never a hand write |
| `HARNESS-PROFILE` | 0.17 | `RULE-ADOPTION.md` | none | Rules 8-12 not read rule by rule; rule 13 (the `extraction` block) read and declared by S0033, 2026-11-14 |
| `REPO-LAYOUT` | 0.11 | `RULE-ADOPTION.md` | E5 | E5 (the Markdown under `docs/` carries no type prefix) was reviewed by S0034 on 2026-11-14 and renewed: the names stand until the owner chooses between a rename with every citation and a catalog decision that they stand; every one of the ten documents now has a registry record, checked both ways; review 2026-12-31 |
| `RULE-DELIVERY` | 0.12 | `RULE-ADOPTION.md` | none | Nothing: plugin 2026.1113.8 and the stamp agree |
| `TASK-FLOW` | 0.27 | `TASK-FLOW.md` | none | The contract was not read rule by rule: the row stays `pending` until a read says which of its rules this product holds |
| `DOC-INTERNAL-QUALITY` | 0.13 | `DOC-INTERNAL-QUALITY.md` | one row, until 2026-12-31, narrowed by S0034 | Registry and gate written by S0034 (2026-11-14, `tools/docs/check-docs.ps1`, exit 0, 1.4 s): rules 1, 2, 3, 5, 6 and 7 are checked; rule 4 for the listing graphics is checked by the generator's `-Check` (S0036, 2026-11-14); open: the `ё` and code-comment halves of rule 5, and the catalog row's exception for the listing graphics, narrowed at the owner's next catalog sync |
| `DOC-EXTERNAL-QUALITY` | 0.14 | `DOC-EXTERNAL-QUALITY.md` | one row, until 2026-12-31 (E6) | Consumer for the help pages only, read with item O (rules 2 and 5 do not apply to a page published from a `CONTEXT-HELP` source); open: rule 6 (no screenshot until the device run of S0032, `docs/RELEASE.md` step 3a) and rule 4 (no termbase gate) |

Not in the catalog by design: `DATA-LAYER-PAIR` (`DATA-LAYER-PAIR.md`), the internal wire pair of the phone and the watch
under the prefix `/deviceinfo/`; it is this product's own declaration and has no catalog home. `ICON-EXTERNAL` is not
adopted (neither app shows a third-party mark). `INSTALL-TRUST` and the update-manifest contracts are unbound: the first
release is Google Play only (`CLAUDE.md` section 3).

The six canon-layer contracts `REPO-STAMP`, `HARNESS-PROFILE`, `REPO-LAYOUT`, `RULE-DELIVERY`, `TASK-FLOW` and
`DOC-INTERNAL-QUALITY` all bind this repository; their rows are the six before the last, written by ticket S0026 on
2026-11-14 when the canon re-sync read them. Each of the four rule-adoption contracts has its pointer in `RULE-ADOPTION.md`
(one file naming every id inside, `REPO-LAYOUT` rule 2). `DOC-EXTERNAL-QUALITY` has the last row, written by S0034 on
2026-11-14: the help pages under `site/help/` (S0024, en, ru, uk, rendered from sources, permanent index address) are a web
help centre published from a `CONTEXT-HELP` source, so the contract binds them; item O of the contract takes them out of rules
2 and 5 only, which is why the row is a consumer row and not a statement that the contract does not bind. The landing and the
privacy pages are outside it (item M). `DOC-INTERNAL-QUALITY` is met except for the gaps its row names.

## 2. Proposals this product filed in the catalog

| Catalog file | Filed | Contract | State | What it produced |
| --- | --- | --- | --- | --- |
| `package-versioning/PROPOSAL-2026-11-13-deviceinfo-android-bands.md` | 2026-11-13 | PACKAGE-VERSIONING | accepted as requested, 2026-11-13 | 0.7: the band rows (phone 0..5, watch 6..9) and the adoption row |
| `in-app-help/PROPOSAL-2026-11-13-deviceinfo-wear-os-app-surface.md` | 2026-11-13 | CONTEXT-HELP | accepted, reading A, 2026-11-13 | 0.4 items L to O: a Wear OS app screen is a surface, the id is `CONTEXT-HELP`, this product is a consumer |
| `ui-sizing/PROPOSAL-2026-11-13-deviceinfo-wear-os-profile.md` | 2026-11-13 | UI-SIZING | accepted with a correction, 2026-11-13 | 1.2 section 3: toolkit chips, buttons and lists on a round display are a permanent variant (what the product draws itself is not) |
| `buttons/PROPOSAL-2026-11-13-deviceinfo-wear-os-chips.md` | 2026-11-13 | BUTTONS | accepted with a correction, 2026-11-13 | 2.2 section 10 item A |
| `collapsible-group/PROPOSAL-2026-11-13-deviceinfo-wear-os-group-header.md` | 2026-11-13 | COLLAPSIBLE-GROUP | accepted, 2026-11-13 | 1.2 section 7 item A |
| `_meta/PROPOSAL-2026-11-13-deviceinfo-joins-function-parity.md` | 2026-11-13 | FUNCTION-PARITY | accepted with corrections, 2026-11-13 | 0.1 rules 1, 2, 5 and 6 |
| `iconography/PROPOSAL-2026-11-14-deviceinfo-system-info-meanings.md` | 2026-11-14 | ICON-SET | accepted with corrections, 2026-11-15 | 0.41 section 27 items A to H: the five meanings as `proposed` records (`system.memory` shares its drawing with `feature.raw-probe`, `device.watch` is named Wear OS watch because `source.watch` owns the proposed names), the 20 usage rows recorded; the vocabulary entry is owed by the exporter's owner, then S0045 |

## 3. Proposals of other projects that decide parts of this product's state

All accepted on 2026-11-13: `_meta/PROPOSAL-2026-11-13-fms-family-function-parity.md` (FastMediaSorter Web) and
`_meta/PROPOSAL-2026-11-13-new-contract-source-port-ledger.md` (Filler Android) with
`rule-adoption/PROPOSAL-2026-11-13-port-ledger-format.md` (Tourist Android) - the sources of FUNCTION-PARITY 0.1 and
PORT-LEDGER 0.1 - and `ui-sizing/PROPOSAL-2026-11-13-watch-surface-scope.md` (Filler Android, answer b), which put Wear OS
app surfaces under UI-SIZING 1.2, BUTTONS 2.2 and COLLAPSIBLE-GROUP 1.2. One more, accepted on 2026-11-15:
`collapsible-group/PROPOSAL-2026-11-14-fms-sibling-set-glyphs.md` (FastMediaSorter Android), the source of COLLAPSIBLE-GROUP
1.3 section 8 items B and C (a leading topic glyph on every heading of a page or on none; the state triangle is not that glyph).

## 4. Why no further proposal is needed

- **Consumer entries in a contract header** are wanted by no owner of the generic contracts: INPUT-PARITY names "every
  product with a user interface", and UI-SIZING, BUTTONS and COLLAPSIBLE-GROUP name every Android application. ICON-SET
  and ICON-RENDER and the three site contracts bind by registry row (Tourist Android is a consumer by rows alone).
  CONTEXT-HELP, FUNCTION-PARITY, PORT-LEDGER and PACKAGE-VERSIONING already name this product.
- **A contract text that disagrees with the ordered state:** none is left. The corrections the catalog made against the
  proposals (the toolkit variant does not cover what a product draws itself; the id `IN-APP-HELP` never existed) were
  taken into the product.
- **The site contracts** (PAGE-CONTENT, PAGE-STYLE, SITE-FAMILY-MAP) are the hub's; the one change this product needs of
  them is its map row, which the hub's own ticket carries (section 5).

## 5. The portfolio's channel

| Ticket | What | State on 2026-11-14 |
| --- | --- | --- |
| canon:S0057 | refresh of this product's contrib record in the canon; told the canon the product is ready | Implemented 2026-11-13 |
| canon:S0058 | the Android public-presence procedure (GitHub, Pages, Play Console) as a canon skill reference | Implemented 2026-11-13 |
| hub:S0009 | the `SITE-FAMILY-MAP` row, the consumers-line entry and the hub card | BlockByOtherTask, blocker deviceinfo-mob:S0014 (waits for the listing to answer 200) |
| fms-a:S4561, fms-lite:L0309, cyrflip:S0101, epub2html:E0138, filedo:SP-0211, uak:S0011, streams-win:SP-0265, oneclickrunner:T0045 | each product adds this product to its footer grid after the row exists | filed 2026-11-13; they become workable with hub:S0009 |
| hub:S0010 | the StreamsPlayer Android row - the sibling direction: Android siblings enter the map by their own hub tickets | not this product's; this product's footer follows in S0015, S0028 and S0030 |

S0025 filed no new ticket in another project: every notice the catalog's side needs was already given and has its reply
above. The one new Draft is local: S0033, the PORT-LEDGER source-root gap of section 1. S0026 (2026-11-14) filed no ticket in
another project either; its one new Draft is local: S0034, the document registry and link gate that
`DOC-INTERNAL-QUALITY` asks for (done 2026-11-14; S0034 filed no ticket in another project either and parked one local Draft,
the drift check of the listing graphics, S0036). The contrib refresh of this product's record in the canon stays canon:S0057 (above).

## 6. What blocks the first release

- **Blocks.** (a) The contract gate (RELEASE_AND_DISTRIBUTION section 2): a current registry row for every consumed
  contract - all 20 rows are written (the 13 of S0025, the six canon-layer rows of S0026 and `DOC-EXTERNAL-QUALITY` of S0034, 2026-11-14). (b) The `Verified` dates: written at release start from the S0007, S0023 and S0024 evidence; a `pending`
  row is honest, not a pass. (c) The band table and the PACKAGE-VERSIONING row are resolved (0.7, accepted 2026-11-13);
  only the vectors and the package read-back remain, at the release.
- **Does not block.** The `SITE-FAMILY-MAP` row (after publication, hub:S0009); the FUNCTION-PARITY columns (the register
  is not seeded); the iconography proposal (a meaning ships under its proposed id); exceptions E1 to E6 and the
  `DOC-INTERNAL-QUALITY` row (recorded and dated 2026-12-31; recording one waives no store, legal or security blocker).

The release steps themselves stay with S0008 and S0014 (`docs/RELEASE.md`); both point here.

## 7. After publication - open checks, not claimed

- The three landing URLs and the Play listing answer 200; the family map lists this product (hub:S0009) and the sibling
  footers link to it.
- The `Verified` cell of each `pending` row (16 of the 20) carries a date from the release-start run.
- The FUNCTION-PARITY columns are added once the register file exists.
- The catalog's vocabulary carrier reads 0.41 (the entry of the five meanings, owed by the exporter's owner); S0045 then switches the five `provisional` token entries to `meaning`. The pointer of `ICON-SET` reads 0.41 since S0044 (2026-11-15) and `COLLAPSIBLE-GROUP` 1.3.

## 8. Prepared, not filed: the `SITE-FAMILY-MAP` row

Filed only after the three landing URLs and the listing answer 200 (`SITE-FAMILY-MAP` rule 5), through hub:S0009:

| Tool | Type | URL | Help index |
| --- | --- | --- | --- |
| DeviceInfo | Android and Wear OS device information | https://serzhyale.github.io/DeviceInfo_Android/ | - |

The Help index cell becomes `https://serzhyale.github.io/DeviceInfo_Android/help/en/` (S0024, permanent once published,
CONTEXT-HELP rule 15) when those pages answer; until then the column holds `-`. The header of the map names this product
as a consumer in the same edit.
