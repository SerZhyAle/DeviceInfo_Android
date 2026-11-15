# docs - index

| Path | What it is |
| --- | --- |
| `BOOTSTRAP_HANDOFF.md` | Origin record written when FastMediaSorter created the repository boundary; a starting record, not the work order. |
| `port-ledger.jsonl` | The port ledger: one row per file ported from FastMediaSorter, checked by `tools/port-ledger/check-drift.ps1`. |
| `port-scope.json` | The port scope as data: which upstream files and string-key prefixes are watched, and the exclusions with their reasons; read by `tools/port-ledger/check-scope.ps1`. |
| `port-decisions.jsonl` | The decisions not to port an in-scope upstream file or string key, with the reason, pinned to the upstream version; written by `tools/port-ledger/record-decision.ps1`. |
| `reverse-port-baseline.md` | The initial dated destination baseline, known differences and their classifications, and the source hand-off process. |
| `local-divergence-decisions.jsonl` | Classifications of changed destination bytes, pinned to their SHA-256; written by `tools/port-ledger/record-local-decision.ps1`. |
| `reverse-port-notices.jsonl` | Locally tracked candidates for FastMediaSorter, including their state and source ticket id after hand-off. |
| `DOCUMENT_REGISTRY.jsonl` | The document registry (S0034, `DOC-INTERNAL-QUALITY` rule 1): one record per maintained document or family of documents, with its topic, product area, update triggers and role (`source` or `render`, a render naming its generator and its check); the corpus boundary is `../tools/docs/docs.config.json`, and `../tools/docs/check-docs.ps1` proves coverage both ways, links and anchors, house style, asset citations and offline safety. A new Markdown file under `docs/`, `PLAN/` or `tools/` gets a record in the same edit. |
| `contracts/` | Pointers to the shared contracts this product consumes (`PACKAGE-VERSIONING`, `DATA-LAYER-PAIR`, `INPUT-PARITY`, `CONTEXT-HELP`, `UNIFIED-UI`, `ICON-SET` and `ICON-RENDER` in `ICONOGRAPHY.md`, `FUNCTION-PARITY`, `PORT-LEDGER`, the three site contracts in `PRODUCT-WEB-PAGES.md`, and the canon-layer contracts in `RULE-ADOPTION.md`, `TASK-FLOW.md` and `DOC-INTERNAL-QUALITY.md`, S0026, and `DOC-EXTERNAL-QUALITY.md` for the help pages, S0034); its `README.md` is the register (S0025): what is consumed, what was proposed to the catalog and its state, the registry rows, what blocks the first release. |
| `design/IDENTITY.md`, `design/tokens.json` | The product identity the phone and the watch share (S0022): the rules and the mapping to both apps, and the one source of color tokens, type roles and group glyphs; checked by `tools/design/check-tokens.ps1`. |
| `UI_CONFORMANCE.md` | Phone and Wear UI size profile, contract evidence, approved watch variant and migration exceptions. |
| `../phone/src/main/assets/help/help-map.json`, `../tools/help/`, `../site/help/` | The in-app help (S0024, `CONTEXT-HELP`): the help map (one row per surface, shipped in the app), the page sources and generator (`tools/help/render-help.ps1`) and the gate (`tools/help/check-help-map.ps1`); the pages are render targets in the app's assets and on the site. The screenshots on the pages (S0032) come from the device run `tools/help/capture-help.ps1` into `tools/help/captures/`, and `tools/help/check-help-captures.ps1` is their freshness gate. |
| `RELEASE.md` | The release procedure and the owner-only steps of the first Google Play release. |
| `DOCS_SURFACES.md` | The ship-together surfaces manifest (S0020): every user-facing surface, its role (source or render target) and its locales, and what moves together per kind of change; checked by `tools/docs/check-surfaces.ps1`. |
| `PARITY_MATRIX.md` | The phone-watch parity matrix (S0021): every information category and feature as a row with a phone and a watch cell in the FUNCTION-PARITY vocabulary; checked by `tools/parity/check-matrix.ps1`. |
| `SECURITY_INVENTORY.md` | The permission inventory and the network-surface inventory that the privacy pages, the in-app wording and the Data safety answers render. |
| `play/PLAY_LISTING.md` | The Google Play listing text in English, Russian and Ukrainian and the Play Console fields. |
| `play/PLAY_DATA_SAFETY.md` | The Data safety, app content, content rating and Wear OS answers. |
| `play/icon-512.png`, `play/feature-graphic-1024x500.png` | Listing graphics, render targets of `tools/store/render-store-assets.ps1`. |
