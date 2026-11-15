# DOC-EXTERNAL-QUALITY - pointer

| Field | Value |
| --- | --- |
| **Id** | `DOC-EXTERNAL-QUALITY` |
| **Version** | 0.14, draft (shared contracts catalog, `documentation-quality/`, read 2026-11-14) |
| **Home** | shared contracts catalog, `documentation-quality/` |
| **Owner** | FastMediaSorter Android (the reference implementation) |
| **Role here** | consumer for one corpus only: the help pages under `site/help/<locale>/` (en, ru, uk), published from a `CONTEXT-HELP` source (`docs/contracts/CONTEXT-HELP.md`) |

Read by ticket S0034 on 2026-11-14, section 3 against the pages as they stand. What the contract binds here and what it does
not:

- **Out by item M.** The landing (`site/index.html`, `site/ru/index.html`, `site/uk/index.html`) is not documentation and is
  governed by the site contracts (`PAGE-CONTENT`, `PAGE-STYLE`); the privacy pages are hosted legal pages of the same kind.
- **Rules 2 and 5 do not apply to the help pages, by item O.** They are published from a `CONTEXT-HELP` source, so they are
  not listed in `sitemap.xml` (read: 6 rows, none under `/help/`), owe no SEO block and carry
  `<meta name="robots" content="noindex">` (read in `site/help/en/index.html`); `site/robots.txt` allows everything, so they
  stay crawlable, and their address `/help/<locale>/` is permanent under `CONTEXT-HELP` rule 15. Item N keeps them out of the
  25-page count.
- **Rule 1, task orientation - read, met in form.** Each page is one screen (System information on the phone, System information
  on the watch), reached from a help index per locale that names the surface and carries its one-line summary. The index and
  the pages are the subject index; a glossary does not exist because the pages name controls by the UI strings (`nameRef`).
- **Rule 3, localization - read, met in form.** A page is one source with its en, ru and uk variants written whole
  (`tools/help/source/*.json`) and rendered together; `tools/help/check-help-map.ps1` fails on a page missing in any of the
  three locales or on unequal bytes between the app and the site. No staleness flag is needed while the three variants are
  rendered from one file.
- **Rule 4, termbase - not held.** No termbase gate exists. Control names come from the module's UI strings by `nameRef`, which
  keeps them equal to the screen; a forbidden-synonym check does not exist.
- **Rule 6, screenshots - not held.** The device run `tools/help/capture-help.ps1` has not run, so no page carries a
  screenshot (`docs/RELEASE.md` step 3a; the freshness gate `tools/help/check-help-captures.ps1` reports `NOT HELD`).
- **Rule 7, link integrity - read.** `check-help-map.ps1` resolves every link of the pages and rejects a page that makes a
  request; the external link is the issue tracker on `https://github.com`. Each page carries a breadcrumb back to its index
  (`nav.help-crumbs`); previous-next links do not exist (two pages per locale and an index).

The gaps (rules 4 and 6) are a dated exception in the catalog's registry (until 2026-12-31), owner of the remedy: S0032 for the
screenshots, and a termbase gate that no ticket holds yet. The row is `pending`; nothing is claimed on a rendered page or a
device.
