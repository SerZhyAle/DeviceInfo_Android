# Port ledger and drift check

DeviceInfo copies FastMediaSorter's System info code instead of sharing it (CLAUDE.md section 2), so a fix made
upstream after the copy has to be found and carried across. The ledger (`docs/port-ledger.jsonl`) records which
file was copied from which upstream version; the scripts here keep it honest. They read the upstream checkout
and never write to it.

| Script | When | What it does |
| --- | --- | --- |
| `record-port.ps1 -Source <upstream path> -Destination <path here>` | right after porting a file | adds the row with both files' SHA-256 and the destination hash date |
| `check-drift.ps1 [-Json]` | before any parity claim and at the start of every release | lists every ported file whose upstream source changed since; exit 1 if any is uncarried |
| `record-port.ps1 .. -Refresh` | after carrying a newer upstream version and classifying any changed destination | the row takes both current hashes and gets `carriedOn` and `destinationHashedOn` |
| `record-port.ps1 .. -Decide -Note "<why>"` | a change is deliberately not carried | writes the decision next to the row, pinned to that upstream version |
| `check-scope.ps1 [-Json]` | before any parity claim and at the start of every release | scans the upstream against `docs/port-scope.json` and lists every in-scope file or watched string key that is neither ported nor decided; exit 1 if any (`NEW SOURCE`, `STALE DECISION`) |
| `record-decision.ps1 -Source <upstream path> -Note "<why>"` | an in-scope upstream file is deliberately not ported | writes the decision to `docs/port-decisions.jsonl`, pinned to that upstream version |
| `record-decision.ps1 -StringKey <key> -Note "<why>"` | a watched string key is deliberately not ported by name | the same, pinned to the key's current value |
| `check-local-divergence.ps1 [-Json]` | after local work | lists `LOCAL EDIT` for every destination that differs from its recorded hash; the edits are informational |
| `check-local-divergence.ps1 -RequireClassified` | at the start of every release | exits 1 for an unclassified edit, a missing destination, a missing baseline or a missing baseline date |
| `record-local-decision.ps1 -Destination <path> -Classification <kind> -Note "<why>"` | after reviewing local edits, before a carry refresh or release | records a classification pinned to the destination's current hash |
| `backfill-destination-hashes.ps1` | when adopting the tool with legacy rows | records hashes only where none exist; never overwrites an existing baseline |
| `test-port-ledger.ps1` | after editing `_ledger.ps1`, `record-port.ps1` or `check-drift.ps1`, or the profile's `extraction` block | self-test on a throw-away tree under `temp/S0003`, including the source-root order, the registry fallback and the exit 2 cases; touches neither this ledger nor the upstream |
| `test-port-scope.ps1` | after editing `_scope.ps1`, `check-scope.ps1`, `record-decision.ps1` or the shape of `docs/port-scope.json` | self-test of the scope check, the decision recorder and the glob engine on a throw-away tree under `temp/S0018`, in this process (about one second) |
| `test-local-divergence.ps1` | after editing the local-divergence or ledger scripts | exercises the local check, classification, notices, backfill and refresh in a throw-away tree, in this process |

Paths are relative to their repository root, with forward slashes. The upstream root is found in this order
(PORT-LEDGER rule 8): `-SourceRoot`, `$env:SZA_PORT_SOURCE_ROOT`, `$env:DEVICEINFO_FMS_ROOT` (this product's own
variable, accepted until its next release), then the path the portfolio registry holds for the project that
`.sza-profile.json` `extraction.sourceProject` names (`fms-a`). The registry is `repos.json` under
`$env:SZA_PORTFOLIO_ROOT`, else under `%USERPROFILE%\.sza\portfolio`. No path to a checkout is kept in a tracked file.
A source root that cannot be found (no variable, no registry, no such project, a path that does not exist) is exit 2,
never 0; the report line `Upstream root: .. (from ..)` says which step found it. The profile's `extraction.ledger` and
`extraction.scope` are declarations for the portfolio tools: these scripts keep the same two paths as defaults, and
the self-test fails if the two ever differ.

## The scope check (S0018)

The ledger holds only files that were ported, so a file FastMediaSorter adds to System Info after the port has no
row and `check-drift.ps1` cannot see it. `docs/port-scope.json` states what part of the upstream is watched, as
data: `include` globs, `exclude` entries (each with a reason) and a `strings` block (key prefixes, the upstream
resource files to scan, the resource files here to compare against). `check-scope.ps1` classifies every upstream
item the scope covers:

| State | Meaning | Fails |
| --- | --- | --- |
| ported | the file has a ledger row; the string key is declared in this repository's resources | no |
| decided | a decision in `docs/port-decisions.jsonl` covers the current upstream version | no |
| excluded | an `exclude` entry covers the file (a file rewritten on purpose, build output, the upstream's `temp/`) | no |
| `NEW SOURCE` | nothing covers the item: port it (`record-port.ps1`) or decide it (`record-decision.ps1`) | yes |
| `STALE DECISION` | the file (or the key's value) changed after the decision was written: carry it or decide again | yes |

Glob syntax: `*` and `?` stay inside one path segment, `**/` spans any number of segments, matching is
case-sensitive, and each glob walks only its own literal directory prefix (never the whole upstream tree). A scope
whose globs match no file at all, or a strings scan that matches no resource file, is a blind check and exits 2
instead of passing. A ledger row always wins over a decision. Exit codes of `check-scope.ps1`: 0 every in-scope item
classified, 1 at least one `NEW SOURCE` or `STALE DECISION`, 2 the check could not run (no upstream root, unreadable
scope, malformed ledger or decisions, a blind scope).

`docs/port-decisions.jsonl` is one JSON object per line: `kind` (`file` or `string`), `item`, `sourceSha256` (file) or
`sourceFile` and `pinnedValue` (string), `note`, `decidedOn`. The string watch is this repository's addition to the
PORT-LEDGER 0.1 scope shape (`include` and `exclude`); string keys are ported by key selection and have no ledger rows.
The watch sees keys by prefix only: a key a ported file uses that carries none of the prefixes is not covered.

A decision stops covering a file the moment the upstream changes it again: the next change is drift until it is
carried or decided too. An empty ledger is in step by definition. Exit codes of `check-drift.ps1`: 0 nothing
uncarried, 1 at least one `DRIFT`, `SOURCE GONE` or `NO DEST` row, 2 the check could not run.

The ledger holds only files that were ported; what the scope covers and the ledger does not is the scope check's
business (above). What a port ticket left out, and why, is the disposition table of that ticket's record; the parity
ticket (S0007) reads both. Strings are ported by key selection and have no row.

## Local changes and source notices (S0019)

Every new port records `destinationSha256` and `destinationHashedOn`; a carry records both hashes again. The initial
backfill dated 2026-11-14 is the state on that day, not a reconstruction of the original port. The known pre-baseline
features and their classifications live in `docs/reverse-port-baseline.md`. Edits to files without ledger rows are
outside this hash check and still need a feature-level review.

For a `LOCAL EDIT`, review the entire change and record exactly one classification of those current bytes:

- `deliberate`: the product intentionally differs. Record the reason and `-EvidenceText "<exact excerpt>"` from the
  destination Kotlin file's KDoc or XML comment. The script checks that the excerpt exists in a comment; a reviewer
  checks that it explains the actual difference.
- `candidate`: the change may improve FastMediaSorter. First add a notice in `docs/reverse-port-notices.jsonl`, then
  pass its id as `-Notice RP-0001`. A notice is a JSON object with `id` (`RP-` and four digits), `state`, `title`,
  `summary`, `identifiedOn` and a `destinations` array; add evidence and acceptance details so it can be acted on.
- `not-applicable`: explain why the source does not need the change, including a pure upstream carry.

The classification is pinned to the destination's SHA-256 in `docs/local-divergence-decisions.jsonl`. Any further
edit needs another classification. A candidate must still have a notice naming that destination. For `-Refresh`,
classify the complete current destination after the carry, including any pre-existing local edits; the command refuses
to overwrite an unclassified baseline. `-Decide` only records an upstream decision and never changes the local hash.

Notices progress `open` -> `handed-over` -> `accepted` or `declined`; from `handed-over` onward they contain the
`sourceTicket` field (`fms-a:Sxxxx`), and a decline includes the reason. `open` means recorded here, not sent. The
owner orders the FMS_A ticket with `/sd fms-a: ...`; this repository's sessions never edit the source checkout.
FUNCTION-PARITY 0.1 rule 5 specifies the intended two-way ticket flow; the local notice is the holding record until
the owner's capture. The check never treats the existence of an open notice as proof of a source ticket.

The default local check exits 0 for edits even when unclassified, 1 for a missing destination, 2 when it cannot run.
`-RequireClassified` also exits 1 for any unclassified edit, absent destination hash, or absent recording date; malformed
classifications or notices exit 2. A missing source checkout does not affect this local-only check.

Run every script as `pwsh -NoProfile -File tools/port-ledger/<script>.ps1 ..` from the repository root.
