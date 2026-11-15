# Documentation checks

Two gates live here. `check-surfaces.ps1` (S0020) holds the ship-together surfaces: string-key parity and permission
parity (its own header says what it reads). `check-docs.ps1` (S0034) holds `DOC-INTERNAL-QUALITY` rules 1, 2, 3, 5, 6
and 7 over the internal corpus, and this page describes it.

The corpus is declared in `docs.config.json` and never inferred: `AGENTS.md`, `CLAUDE.md`, `README.md`, every file under
`docs/` and `PLAN/`, and the Markdown under `tools/`. Only files git tracks or could track are in it, so a git-ignored
file is outside. Outside the corpus by declaration: `site/` and `phone/src/main/assets/help/` (the published pages and
the help renders, held by `tools/site/render-landing.ps1 -Check` and `tools/help/render-help.ps1 -Check`), `.claude/commands/`
(forwarders rendered by the harness scaffold), `CHANGELOG.md` and `LICENSE` (the release ledger and the licence) and the
scratch folders `temp/` and `build/`. Rule 4 (generated documents) is held by the generator and the check that each
`generated` record of the registry names.

| Script | When | What it does |
| --- | --- | --- |
| `check-docs.ps1 [-Check registry\|links\|style\|assets\|offline\|all]` | after any edit to the corpus, and at every release start | runs the checks below; `all` (the default) also runs the harness `document_registry/validate` and ends with `docs-check: <WORD> (..)` |
| `check-docs.ps1 -Check <check> -UpdateBaseline` | only when debt is accepted on purpose, with the reason in the ticket | rewrites that check's baseline entries and prints every identifier it accepts |
| `test-check-docs.ps1` | after editing these scripts | 49 expectations on throw-away git trees: each check passes clean and fails on its own defect, an unreadable input is exit 2 |

- **registry** (rules 1 and 2) - every record of `docs/DOCUMENT_REGISTRY.jsonl` carries the harness fields, a title (the
  topic), a product area and an update trigger; a `generated` record names its generator and its check; every declared
  pattern matches a corpus file; every corpus file has exactly one record, or an `ignore` entry with a reason of four
  words or more in `docs.config.json` (empty today); a record names no file outside the declared corpus; a `contract`
  value names an id of `docs/contracts/README.md`.
- **links** (rule 3) - relative Markdown links resolve to a file or folder, and a `#fragment` to a heading of the target
  (GitHub's slug) or an explicit `name=` or `id=` anchor. Links inside a record marked `"archive": true` are not judged
  (a frozen archive); links into it are.
- **style** (rule 5) - no three dots, no ellipsis character, no em or en dash in Markdown prose; fenced blocks, inline
  code and link targets are removed first.
- **assets** (rule 6) - image links and image paths written in inline code resolve to a file git tracks or could track; a
  bare file name resolves to any such file of that name; a git-ignored asset is refused.
- **offline** (rule 7) - no `http:` link outside code (`localhost` and `127.0.0.1` excepted) and no remote script,
  stylesheet, font or image in a Markdown file.

A new document either matches an existing record's glob or gets a record of its own. `generated: true` marks a render
that is regenerated and never hand-edited, and says how in `generator` and `check`; a `check` that starts with `none`
is an advisory of the verdict (`PASS WITH ADVISORIES`, each one named), never a pass. The optional `contract` field names
the contract id and section a document describes (`DOC-INTERNAL-QUALITY` item X).

Accepted debt lives in `baseline.txt`, a set baseline that may only fall: a finding it does not list fails, and an entry
no finding raises fails until it is removed. It is empty today. Exit codes: 0 PASS or PASS WITH ADVISORIES, 1 FAIL,
2 COULD NOT VERIFY (unreadable configuration or registry, no git work tree, the harness validator missing). The last
line on stdout is the verdict line.

Run each script as `pwsh -NoProfile -File tools/docs/<script>.ps1 ..` from the repository root.
