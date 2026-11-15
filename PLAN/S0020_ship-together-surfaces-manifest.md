# S0020_ship-together-surfaces-manifest

**Status:** Implemented
**Status note:** Docs-only, fast tier: docs/DOCS_SURFACES.md manifest, tools/docs/check-surfaces.ps1 + self-test, PLAY_DATA_SAFETY declared-permissions row. First run exit 1 (2 mismatches), fixed, re-run exit 0; self-test 11 PASS; all fast gates exit 0.
**Created:** 2026-11-13
**Complexity:** medium - not assessed at capture

## 0. Owner request (verbatim)

Owner's positions and order, 2026-11-13, verbatim (chat, Russian):

Positions:
"Так.
Идея этого приложения была чтобы весь функционал по суб-программы Device Infoна телефоне (любом андроид устройстве), часах , который реализован в FMS_A был представлен в виде самостоятельных приложений android,  которые могут заинтересовать пользователя, которому не интересен весь остальной функционал FMS_A
Но при этом эти приложения не только выглядят более-менее одинаково, но и развиваются вместеи новый/исправленный функционал обновляется/исправляется в них паралельно, они пересекаются по документации, принадлежат общему семейству программ и связаны канонами и контрактами.
Исследуй всё ли верно в моих мположениях?"

Order:
"Создай такие спецификации в рамках этого продукта, которые приведут его к вышеописанному заказанному состоянию"

Correction order, 2026-11-13, verbatim (chat, Russian), given after these tickets were captured:
"правильно ли я понял, что по производству всех заказаных задач
это приложение будет иметь весь функционал по соответствующей суб-программы телефона (любом андроид устройстве), часах , который реализован в FMS_A был представлен в виде самостоятельных приложений android,  которые могут заинтересовать пользователя, которому не интересен весь остальной функционал FMS_A
Но при этом эти приложения будут выглядеть более-менее одинаково, развиваться вместе и новый/исправленный функционал обновляется/исправляется в них паралельно, они пересекаются по документации, принадлежат общему семейству программ и связаны канонами и контрактами.
Поправь спецификации чтобы было именно так"

This ticket's problem and done criteria (sections 1 and 2) were written from that message. The acceptance of the whole set is ticket target-state-acceptance (S0027).

Twelve tickets were captured by the two orders: bugfix-contract-pointers-stale (S0016), payload-parity-test (S0017), upstream-new-file-inventory-check (S0018), reverse-port-divergence-ledger (S0019), ship-together-surfaces-manifest (S0020), phone-wear-feature-parity-matrix (S0021), phone-wear-visual-identity (S0022), unified-ui-conformance-evidence (S0023), in-app-help-phone-and-wear (S0024), register-product-in-contract-catalog (S0025), canon-resync-stamp (S0026), target-state-acceptance (S0027).

Agent findings below are not the owner's words. They come from the investigation of 2026-11-13; every fact cites the file it was read from.

Position this ticket serves: "они пересекаются по документации".

Problem: the documentation of the product is spread over many surfaces in several locales, but the repository declares no list of the surfaces that must change together, so a user-visible change can land in one and leave the others stale.

Evidence (read 2026-11-13):
- A search of CLAUDE.md, .sza-profile.json, docs/README.md and docs/RELEASE.md for a surfaces manifest (the canon's ship-together surfaces manifest, DOCUMENTATION_CONCEPT section 5, the feature-to-site skill) finds none.
- The surfaces that exist: phone strings (values, values-ru, values-uk; strings_systeminfo.xml), wear strings (same three locales), CHANGELOG.md, the landing dictionaries tools/site/landing/en.json, ru.json, uk.json rendered by tools/site/render-landing.ps1 into site/index.html, site/ru/index.html, site/uk/index.html, the hand-authored privacy pages (site/privacy.html, privacy-ru.html, privacy-uk.html), docs/play/PLAY_LISTING.md (en, ru, uk), docs/play/PLAY_DATA_SAFETY.md, docs/SECURITY_INVENTORY.md (the inventory that the privacy pages, in-app wording and Data safety answers render), the future help pages (ticket in-app-help-phone-and-wear).
- Existing gates cover only parts: render-landing.ps1 -Check proves the landing is current; nothing compares the permission list of the two AndroidManifest.xml files with SECURITY_INVENTORY, the privacy pages and the Data safety answers (canon invariant 14: they must say the same thing).
- The landing and the listing describe the phone and the watch together (the landing mentions the watch in all three locales), so one feature statement has to stay true for both packages.

Wanted:
1. The manifest declared in this repository in the form the canon's feature-to-site skill reads: for each kind of user-facing change, the surfaces it touches, each locale, and which are render targets (never hand-edited) and which are sources.
2. A repo-local consistency check under tools/: string-key parity en/ru/uk per module, and permission parity across both AndroidManifest.xml files, SECURITY_INVENTORY.md, the privacy pages and PLAY_DATA_SAFETY.md; exit 0 clean, 1 mismatch.
3. A line in CLAUDE.md section 5 pointing at the manifest, the check added to the fast tier and release-start lists in section 6.
4. A first run recorded in the ticket, with every mismatch it finds fixed or listed.

Write every surface as a shipped, present-tense fact (canon invariant 17). Fast tier only; nothing above 5 seconds.


## 1. Problem

The documentation of the product is spread over several places and three languages, and nothing lists which of them must change together. The owner wants the documentation to overlap: one true statement about a function, in the apps, on the site, in the store listing and in the privacy text, for the phone and for the watch.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- The manifest of surfaces is declared in the form the feature-to-site skill reads; it names every surface and every locale and marks the render targets as never edited by hand.
- `pwsh -NoProfile -File tools/docs/check-surfaces.ps1` exits 0 (string-key parity en/ru/uk per module; permission parity across both manifests, SECURITY_INVENTORY, the privacy pages and the Data safety answers); the mismatches of the first run are fixed or listed with a reason.
- For one real feature (a metric of S0010) the manifest's procedure names the phone surfaces and the watch surfaces, or records why one side has none.
- `pwsh -NoProfile -File tools/site/render-landing.ps1 -Check` still exits 0.
- CLAUDE.md section 5 points at the manifest; the check is in the fast tier and release-start lists.

## 3. Approach

### 3.1 Scope

What changed (2026-11-14):

- `docs/DOCS_SURFACES.md` - the ship-together surfaces manifest in the form the canon's feature-to-site skill reads
  (its step 1 manifest and its step 10 table): every surface with files, role (source or render target) and locales,
  what moves together per kind of user-facing change, the procedure, the worked example of a real S0010 metric, and
  the maintenance rules.
- `tools/docs/check-surfaces.ps1` - the parity check: string-key parity en/ru/uk per module (phone: `src/main` +
  `src/restricted`; a base key marked `translatable="false"` is exempt, the platform's own marker) and permission
  parity across the three manifests, `SECURITY_INVENTORY.md` section 1, the three privacy pages'
  permissions sections and the permission rows of `PLAY_DATA_SAFETY.md`; exit 0 clean, 1 mismatch, 2 could not run.
- `tools/docs/test-check-surfaces.ps1` - the self-test, which builds its throw-away tree at run time and touches
  nothing committed (11 expectations:
  a check that reports nothing must be proven able to fail).
- `docs/play/PLAY_DATA_SAFETY.md` - a `Declared permissions` row naming all three declared permissions, the one
  mismatch the first run found (below).
- `CLAUDE.md` section 5 (the `docs/` and `tools/` enumerations point at the manifest and the check), section 6 (the
  check and its self-test in the fast-tier list, the check at every release start); `docs/RELEASE.md` step 1 fast
  gates; `docs/README.md` index row.

What deliberately does not change:

- No documentation registry (DOCUMENTATION_CONCEPT section 6) is declared: this ticket carries section 5's
  ship-together rule, and the registry's adoption is a separate owner decision, not a part of the requested
  manifest.
- No text rewrite on the landing, the listing or the privacy pages beyond the one parity fix: their copy is already
  written as shipped facts, and the gates below prove it.
- The help pages exist only as an honest "declared by S0024, not present yet" row of the manifest; S0024 owns the
  pages and fills the row when they land.
- No shared contract is declared: the manifest and the check are repository-internal.

### 3.2 Open questions

None. The one design question - what exempts a string key from the en/ru/uk parity - is answered by the platform's
own marker: `app_name` is `translatable="false"` in both modules (the frozen store name `DeviceInfo` in every
locale), and the check reads that marker instead of carrying a private exclusion list.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** none

## 4. Implementation record (2026-11-14)

Every done criterion of section 2, with the command and the exit code:

- The manifest is declared: `docs/DOCS_SURFACES.md`, sections 1 (surfaces), 2 (what moves together), 3 (procedure),
  4 (worked example), 5 (maintenance). Render targets are marked "never hand-edited"; the sources name their
  generators.
- The check and its first run: `pwsh -NoProfile -File tools/docs/check-surfaces.ps1`
  - First run, 2026-11-14, **exit 1 with 2 mismatches**: `PLAY_DATA_SAFETY does not name 'ACCESS_WIFI_STATE'`,
    `PLAY_DATA_SAFETY does not name 'ACCESS_NETWORK_STATE'` - the Data safety answers named only
    `POST_NOTIFICATIONS`. Fixed in the same pass: a `Declared permissions` row in the App content table of
    `docs/play/PLAY_DATA_SAFETY.md` names all three declared permissions.
  - Re-run, **exit 0** (0.4 s): strings phone values 216 (1 exempt) / ru 215 / uk 215, wear 85 (1 exempt) / 84 / 84;
    permissions declared phone `ACCESS_NETWORK_STATE`, `POST_NOTIFICATIONS`, wear `ACCESS_WIFI_STATE`; inventory
    rows 3; privacy page tokens 3/3/3; Data safety permission rows 2.
- Self-test: `pwsh -NoProfile -File tools/docs/test-check-surfaces.ps1` - 11 expectations, all PASS, **exit 0**
  (0.5 s): clean tree 0 with the `translatable="false"` exemption and the negation rows unflagged, the four string
  and permission mismatches, the unknown package, the two exit-2 breaks.
- One real feature: the battery charge speed metric of S0010 (FastMediaSorter S4529) is the worked example in
  `docs/DOCS_SURFACES.md` section 4 - it names the phone surfaces (strings en/ru/uk, changelog, landing copy deck
  and pages, listing) and records why the watch side has none (`BatteryDetailsCollector` is phone-only; the watch
  Health section reports sensor facts, not charging).
- `pwsh -NoProfile -File tools/site/render-landing.ps1 -Check` - "landing pages are current: 3 of 3", **exit 0**.
- `CLAUDE.md`: section 5 points at `docs/DOCS_SURFACES.md` and `tools/docs/`; section 6 fast tier names the check
  (run after editing any in-app string, a manifest permission, the inventory, a privacy page or the Data safety
  answers, and at every release start) and its self-test; `docs/RELEASE.md` step 1 lists
  `tools/docs/check-surfaces.ps1` among the fast gates; `docs/README.md` indexes the manifest.

Audit: a docs-and-tools change only - no Kotlin, Gradle or resource edit, so nothing is compiled-not-tested; every
command above ran inside the fast tier (the slowest is the self-test at 0.5 s). RELEASE items: none - nothing here
depends on a release-tier run.

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14
