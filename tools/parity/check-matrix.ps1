#requires -Version 7.0
<#
.SYNOPSIS
    The phone-watch parity matrix check (S0021): every row of docs/PARITY_MATRIX.md carries a phone cell
    and a watch cell in the FUNCTION-PARITY 0.1 vocabulary, and every planned cell names a ticket that
    exists and is open.

.DESCRIPTION
    The matrix is this product's private map of which function the phone app and the watch app carry,
    written in the row and cell vocabulary of FUNCTION-PARITY 0.1 (docs/PARITY_MATRIX.md section 1).
    This check enforces the grammar a machine can hold:

      row          the main table's header reads exactly Id, Function, Group, Contract, Phone, Watch;
                   every data row has six non-empty cells, a unique id of the form PM-NNN, and a
                   Contract cell of `none` or a contract id (uppercase and dashes).
      cell         one of `offered` (optionally `(since <version or date>)`), `planned
                   deviceinfo-mob:Sxxxx`, `not offered: os-only`, `not offered: form-factor`,
                   `not offered: subset`, or `not offered: owner-declined (YYYY-MM-DD)` - the date is
                   required for owner-declined (FUNCTION-PARITY rule 1).
      planned      the ticket id must exist in PLAN/spec-catalog.jsonl with a status of the work set
                   (not Implemented, Verified, BlockNeedUserTest or Archived - a closed ticket means the
                   cell must read offered or the ticket must reopen); a ticket only in
                   PLAN/spec-catalog-archive.jsonl counts as closed. A repo key other than
                   deviceinfo-mob is a mismatch: this private matrix carries this repository's tickets
                   only; a capture into another product's queue belongs in the family register.

    Exit code: 0 in step; 1 at least one mismatch; 2 the check could not run (a required file missing
    or unreadable, the main table header not found). The repository is only read.

.PARAMETER RepoRoot
    The repository root. Default: the tree this script's tools/parity directory sits in. The self-test
    passes a throw-away tree shaped like the repository.

.PARAMETER Json
    Print one JSON object with the counts and the mismatches instead of the text report.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $RepoRoot,
    [switch] $Json
)

$ErrorActionPreference = 'Stop'
trap { Write-Host "check-matrix: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
}
$matrixPath = Join-Path $RepoRoot 'docs/PARITY_MATRIX.md'
$catalogPath = Join-Path $RepoRoot 'PLAN/spec-catalog.jsonl'
$archivePath = Join-Path $RepoRoot 'PLAN/spec-catalog-archive.jsonl'
if (-not (Test-Path $matrixPath)) { throw 'Required file is missing: docs/PARITY_MATRIX.md' }
if (-not (Test-Path $catalogPath)) { throw 'Required file is missing: PLAN/spec-catalog.jsonl' }

# ---------------------------------------------------------------- the ticket store: id -> status
$tickets = @{}
foreach ($line in (Get-Content -Path $catalogPath)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $tickets[$row.id] = [string]$row.status
}
$archived = @{}
if (Test-Path $archivePath) {
    foreach ($line in (Get-Content -Path $archivePath)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $row = $line | ConvertFrom-Json
        $archived[$row.id] = $true
    }
}
$closedStatuses = @('Implemented', 'Verified', 'BlockNeedUserTest', 'Archived')

# ---------------------------------------------------------------- the main table
# The main table is the first table whose header row reads exactly the six register columns; the
# one-by-one tables of the notes carry other headers and are not parsed.
$expectedHeader = @('id', 'function', 'group', 'contract', 'phone', 'watch')
$lines = @(Get-Content -Path $matrixPath)
function Get-Cells([string] $Line) {
    # Cells of one markdown row: no cell of this matrix carries a literal pipe.
    return @($Line.Trim().Trim('|').Split('|') | ForEach-Object { $_.Trim() })
}
$headerIndex = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].TrimStart().StartsWith('|')) { continue }
    $cells = Get-Cells $lines[$i]
    if ($cells.Count -ne 6) { continue }
    $matchesHeader = $true
    for ($c = 0; $c -lt 6; $c++) {
        if ($cells[$c].ToLowerInvariant() -ne $expectedHeader[$c]) { $matchesHeader = $false; break }
    }
    if ($matchesHeader) { $headerIndex = $i; break }
}
if ($headerIndex -lt 0) {
    throw 'The matrix main table header (| Id | Function | Group | Contract | Phone | Watch |) was not found.'
}

$offeredRegex = [regex]'^offered(\s+\(since [^)]+\))?$'
$plannedRegex = [regex]'^planned ([A-Za-z0-9_-]+):(S\d{4})$'
$notOfferedRegex = [regex]'^not offered: (os-only|form-factor|subset)$'
$ownerDeclinedRegex = [regex]'^not offered: owner-declined \(\d{4}-\d{2}-\d{2}\)$'
$contractRegex = [regex]'^([A-Z][A-Z0-9-]+|none)$'
$idRegex = [regex]'^PM-\d{3}$'
$seenIds = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)

$mismatches = [System.Collections.Generic.List[string]]::new()
$sideCount = [ordered]@{
    phone = [ordered]@{ offered = 0; planned = 0; 'not offered' = 0 }
    watch = [ordered]@{ offered = 0; planned = 0; 'not offered' = 0 }
}
$rows = 0
for ($i = $headerIndex + 1; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if (-not $line.TrimStart().StartsWith('|')) { break }
    $cells = Get-Cells $line
    if (($cells | Where-Object { $_ -match '^-{3,}$' }).Count -eq $cells.Count) { continue } # separator
    $rows++
    $where = "row $($rows) of the matrix"
    if ($cells.Count -ne 6) {
        $mismatches.Add("$where has $($cells.Count) cells, expected 6")
        continue
    }
    $id, $function, $group, $contract, $phoneCell, $watchCell = $cells
    if ($id -notmatch $idRegex) {
        $mismatches.Add("$where has id '$id' outside the PM-NNN form")
    } elseif (-not $seenIds.Add($id)) {
        $mismatches.Add("$where repeats id '$id'")
    }
    foreach ($pair in @(@('Function', $function), @('Group', $group))) {
        if ([string]::IsNullOrWhiteSpace($pair[1])) {
            $mismatches.Add("$where ($id) has an empty $($pair[0]) cell")
        }
    }
    if (-not $contractRegex.IsMatch($contract)) {
        $mismatches.Add("$where ($id) has contract cell '$contract', expected 'none' or a contract id")
    }
    foreach ($side in @(@('phone', $phoneCell), @('watch', $watchCell))) {
        $sideName, $cell = $side
        if ([string]::IsNullOrWhiteSpace($cell)) {
            $mismatches.Add("$where ($id) has no $sideName cell value")
            continue
        }
        if ($offeredRegex.IsMatch($cell)) {
            $sideCount[$sideName].offered++
            continue
        }
        if ($notOfferedRegex.IsMatch($cell) -or $ownerDeclinedRegex.IsMatch($cell)) {
            $sideCount[$sideName]['not offered']++
            continue
        }
        $plannedMatch = $plannedRegex.Match($cell)
        if ($plannedMatch.Success) {
            $repoKey, $ticketId = $plannedMatch.Groups[1].Value, $plannedMatch.Groups[2].Value
            if ($repoKey -ne 'deviceinfo-mob') {
                $mismatches.Add("$where ($id) plans '$cell': this matrix carries deviceinfo-mob tickets only")
                continue
            }
            $sideCount[$sideName].planned++
            if (-not $tickets.ContainsKey($ticketId)) {
                if ($archived.ContainsKey($ticketId)) {
                    $mismatches.Add("$where ($id) plans '$cell': the ticket is archived (closed)")
                } else {
                    $mismatches.Add("$where ($id) plans '$cell': no such ticket in the store")
                }
                continue
            }
            if ($closedStatuses -contains $tickets[$ticketId]) {
                $mismatches.Add("$where ($id) plans '$cell': the ticket is $($tickets[$ticketId]) - the cell must read offered or the ticket must reopen")
            }
            continue
        }
        $mismatches.Add("$where ($id) has a $sideName cell outside the vocabulary: '$cell'")
    }
}

# ---------------------------------------------------------------- report
if ($Json) {
    [ordered]@{
        repoRoot   = $RepoRoot
        rows       = $rows
        cells      = $sideCount
        mismatches = @($mismatches)
    } | ConvertTo-Json -Depth 5
    exit ([int]($mismatches.Count -gt 0))
}

Write-Host "Parity matrix check: $RepoRoot"
Write-Host "Rows: $rows; phone offered $($sideCount.phone.offered), planned $($sideCount.phone.planned), not offered $($sideCount.phone.'not offered'); watch offered $($sideCount.watch.offered), planned $($sideCount.watch.planned), not offered $($sideCount.watch.'not offered')"
foreach ($mismatch in $mismatches) {
    Write-Host "  MISMATCH $mismatch" -ForegroundColor Yellow
}
if ($mismatches.Count -eq 0) {
    Write-Host "OK: every row carries a phone and a watch cell in the FUNCTION-PARITY vocabulary, and every planned cell names an open ticket."
    exit 0
}
Write-Host "OPEN: $($mismatches.Count) matrix mismatch(es) - fill the cell, fix the grammar, or record the absence by design."
exit 1
