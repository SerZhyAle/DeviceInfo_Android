# Port ledger and drift check

DeviceInfo copies FastMediaSorter's System info code instead of sharing it (CLAUDE.md section 2), so a fix made
upstream after the copy has to be found and carried across. The ledger (`docs/port-ledger.jsonl`) records which
file was copied from which upstream version; the scripts here keep it honest. They read the upstream checkout
and never write to it.

| Script | When | What it does |
| --- | --- | --- |
| `record-port.ps1 -Source <upstream path> -Destination <path here>` | right after porting a file | adds the row with the upstream file's SHA-256 as it is now |
| `check-drift.ps1 [-Json]` | before any parity claim and at the start of every release | lists every ported file whose upstream source changed since; exit 1 if any is uncarried |
| `record-port.ps1 .. -Refresh` | after carrying a newer upstream version | the row takes the current hash and gets `carriedOn` |
| `record-port.ps1 .. -Decide -Note "<why>"` | a change is deliberately not carried | writes the decision next to the row, pinned to that upstream version |
| `test-port-ledger.ps1` | after editing these scripts | self-test on a throw-away tree under `temp/S0003`; touches neither this ledger nor the upstream |

Paths are relative to their repository root, with forward slashes. The upstream root is
`P:\ANDROID\FastMediaSorter_mob_v2` unless `-SourceRoot` or `$env:DEVICEINFO_FMS_ROOT` says otherwise.

A decision stops covering a file the moment the upstream changes it again: the next change is drift until it is
carried or decided too. An empty ledger is in step by definition. Exit codes of `check-drift.ps1`: 0 nothing
uncarried, 1 at least one `DRIFT`, `SOURCE GONE` or `NO DEST` row, 2 the check could not run.

The ledger holds only files that were ported. What a port ticket left out, and why, is the disposition table of
that ticket's record; the parity ticket (S0007) reads both. Strings are ported by key selection and have no row.

Run every script as `pwsh -NoProfile -File tools/port-ledger/<script>.ps1 ..` from the repository root.
