# DOC-INTERNAL-QUALITY - pointer

| Field | Value |
| --- | --- |
| **Id** | `DOC-INTERNAL-QUALITY` |
| **Version** | 0.13, draft (shared contracts catalog, `documentation-quality/`, read 2026-11-14) |
| **Home** | shared contracts catalog, `documentation-quality/` |
| **Owner** | FastMediaSorter Android (the reference implementation) |
| **Role here** | consumer, internal corpus only: `AGENTS.md`, `CLAUDE.md`, `README.md`, `docs/`, `PLAN/` and the Markdown under `tools/` (the boundary is declared in `tools/docs/docs.config.json`, item V) |

What this repository owes (section 2 of the contract, seven rules), and where it stands. Ticket S0034 (2026-11-14) wrote the
registry and the gate: `docs/DOCUMENT_REGISTRY.jsonl` (30 records) and `tools/docs/check-docs.ps1`, which ends with one
verdict line and runs in about 1.4 s; its self-test is `tools/docs/test-check-docs.ps1`. The stamp declares
`docRegistryShape` 1 and `docRegistryFile` (`REPO-STAMP` rule 4).

- **Rule 1, a machine-readable document registry - held.** Each record carries a topic (`title`), a product area, update
  triggers and a role: `generated` false is `source`, true is `render` and names its generator and its check (item W). The
  optional `contract` field (item X) is used and its ids are checked against `docs/contracts/README.md`. One tracked
  registry, because `PLAN/` is tracked (items J and K).
- **Rule 2, reverse coverage - held.** Registry to disk (every pattern matches a corpus file) and disk to registry (every
  corpus file has exactly one record or a reasoned ignore, none today). The harness validator `document_registry/validate`
  runs in the same pass.
- **Rule 3, links and anchors - held.** Relative links and `#fragment` anchors of the corpus resolve; `PLAN/archive/` is the
  declared frozen archive (item Q), its links are not judged and links into it are. Only 7 relative links exist in the
  corpus today, because the documents name files in code spans; a path in code is not a link and rule 3 does not read it.
- **Rule 4, generated documentation does not drift - held.** The landing and the help pages equal their
  sources (`tools/site/render-landing.ps1 -Check`, `tools/help/render-help.ps1 -Check`); both lie outside the corpus (item W,
  excluded form). The release queue files are renders of the harness with `release-queue -Validate`, and the three port
  files have their drift checks. The listing graphics `docs/play/icon-512.png` and `feature-graphic-1024x500.png` equal their
  generator's render (`tools/store/render-store-assets.ps1 -Check`, S0036, by decoded pixels; the landing's social card and the
  site icon copy are compared the same way). Since S0036 the gate names no advisory for them, because the registry record names the check.
- **Rule 5, house text style - checked** for Markdown prose (no three dots, no ellipsis character, no em or en dash).
  Not checked: the `ё` spelling and the English-only comment rule in source.
- **Rule 6, asset citations - checked** for image links and image paths written in code spans, against files git tracks or
  could track (a git-ignored asset is refused).
- **Rule 7, offline safety - checked** (no `http:` link outside code, no remote script, stylesheet, font or image in
  Markdown).

The dated exception in the catalog's registry (until 2026-12-31) still names rule 4 for the listing graphics, which S0036 closes
here with the generator's check, and the `ё` and comment halves of rule 5. The catalog row is narrowed at the owner's next catalog
sync (a release item of S0036); until then the exception stands as recorded there. Nothing is `Verified` by the catalog; the row
stays `pending`. The siblings that meet the contract (Filler Android, Tourist Android) show the decisions; their code
is not copied.

State: the registry row `DOC-INTERNAL-QUALITY | DeviceInfo Android` is declared (2026-11-14, ticket S0026), reads 0.13,
`pending`, and was rewritten by S0034 the same day.
