# Product web pages - pointers

| Id | Version read | Home | Role |
| --- | --- | --- | --- |
| PAGE-CONTENT | 1.5 | `product-web-pages/` | consumer |
| PAGE-STYLE | 3.10 | `product-web-pages/` | consumer |
| SITE-FAMILY-MAP | 1.12 | `product-web-pages/` | consumer |

Read 2026-11-14.

The line above is a version check against the catalog's front matter, not a conformance read: the landing (S0012, 2026-11-13) was built to these contracts, and reading the rendered live pages against them is the release's `/site-audit` (`docs/RELEASE.md`), which is open.

What this repository owes, as recorded by the landing ticket S0012 and read in `SITE-FAMILY-MAP`:

- **The landing (`PAGE-CONTENT`, `PAGE-STYLE`).** One standalone page per locale in the directory form of `PAGE-STYLE` 3.9 - English at the root, `ru/` and `uk/` - rendered by `tools/site/render-landing.ps1` from one template and three dictionaries (`-Check` proves the pages current); the use case is shown as scenario cards because the repository holds no device screenshot; the pages use the vendored reference kit byte for byte (`site/assets/PROVENANCE.txt`) and a page layer. The store-only product states no version on the page and links its store listing (3.10 item 3).
- **The hosted privacy pages.** `site/privacy.html`, `site/privacy-ru.html` and `site/privacy-uk.html`, hand-authored, in the same kit.
- **The footer grid (`SITE-FAMILY-MAP` rule 1).** The landing carries every sibling row of the table - nine at 1.12 - with the Type labels translated per 1.12; a row added to the map is added to the generator's table and to the three dictionaries in one edit (`docs/RELEASE.md`).
- **This product's own row (rule 5).** It enters the table only once its URLs answer; the hub's ticket hub:S0009 enters it after the three landing URLs and the Play listing answer 200. The Help index column stays `-` until the in-app help pages answer (S0024).

State: three registry rows declared (2026-11-14, ticket S0025), each `pending`.
