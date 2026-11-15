#requires -Version 7.0
<#
.SYNOPSIS
    Self-test of the parity matrix check (tools/parity/check-matrix.ps1) on a throw-away tree. Touches
    nothing of this repository but the gitignored temp/S0021 scratch.

.DESCRIPTION
    A check that reports nothing passes as quietly as a clean one, so this proves it can fail. On a
    throw-away tree shaped like the repository it walks the rules: a clean tree (exit 0, with the
    optional offered "since" stamp, every reason class and an open planned ticket accepted), an empty
    phone cell, a cell outside the vocabulary, a planned cell whose ticket does not exist, whose ticket
    is closed, whose ticket is archived, and whose repo key is foreign, an owner-declined cell without
    its date, a repeated row id, a row with the wrong cell count, and the exit 2 of a missing matrix, a
    missing catalog and a missing main table header.

    The check runs in this process (no `pwsh` spawn per case), which keeps the whole run near one
    second. Run it after editing check-matrix.ps1.

    Exit code: 0 every expectation held; 1 at least one failed.
#>
[CmdletBinding(PositionalBinding = $false)]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$scratch = Join-Path $repoRoot 'temp\S0021'
$base = Join-Path $scratch ('matrix-test-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$failures = 0

function Expect([string] $What, $Actual, $Expected) {
    if ($Actual -eq $Expected) { Write-Host "  PASS  $What (expected: $Expected | actual: $Actual)" }
    else { $script:failures++; Write-Host "  FAIL  $What (expected: $Expected | actual: $Actual)" -ForegroundColor Red }
}
function Expect-Contains([string] $What, $Mismatches, [string] $Needle) {
    $hit = @($Mismatches | Where-Object { "$_" -like "*$Needle*" })
    if ($hit.Count -gt 0) { Write-Host "  PASS  $What (found: $Needle)" }
    else { $script:failures++; Write-Host "  FAIL  $What (no mismatch matched: $Needle)" -ForegroundColor Red }
}
# check-matrix.ps1 ends with `exit N`; run with `&` in this process, which ends the script, not this
# one, and sets $LASTEXITCODE.
function Invoke-Check([string] $TreeRoot) {
    $null = & (Join-Path $PSScriptRoot 'check-matrix.ps1') -RepoRoot $TreeRoot 6>&1 2>&1
    return $LASTEXITCODE
}
function Invoke-CheckJson([string] $TreeRoot) {
    $out = & (Join-Path $PSScriptRoot 'check-matrix.ps1') -RepoRoot $TreeRoot -Json 6>$null
    return (($out -join '') | ConvertFrom-Json)
}
function Write-Text([string] $Root, [string] $Relative, [string] $Text) {
    $path = Join-Path $Root $Relative
    New-Item -ItemType Directory -Force (Split-Path -Parent $path) | Out-Null
    [System.IO.File]::WriteAllText($path, $Text)
}
$goodMatrix = @'
# PARITY_MATRIX

## 2. The matrix

| Id | Function | Group | Contract | Phone | Watch |
| --- | --- | --- | --- | --- | --- |
| PM-001 | Alpha | Device | none | offered | offered |
| PM-002 | Beta | Help | CONTEXT-HELP | planned deviceinfo-mob:S0001 | offered |
| PM-003 | Gamma | Environment | none | not offered: subset | offered |
| PM-004 | Delta | Report | none | not offered: owner-declined (2026-11-13) | not offered: form-factor |
| PM-005 | Epsilon | Hardware | UNIFIED-UI | offered (since 1.0.0.0) | offered |

The one-by-one notes table below must not be parsed as the matrix:

| S0006 item | Phone | Watch | Class | Why |
| --- | --- | --- | --- | --- |
| Battery current | offered | not offered: subset | subset | Upstream is phone-only. |
'@
$goodCatalog = @'
{"id":"S0001","name":"draft-ticket","status":"Draft"}
{"id":"S0009","name":"done-ticket","status":"Implemented"}
'@
$goodArchive = @'
{"id":"S0002","name":"old-ticket","status":"Archived"}
'@
function New-GoodTree([string] $Root) {
    New-Item -ItemType Directory -Path $Root -Force | Out-Null
    Write-Text $Root 'docs/PARITY_MATRIX.md' $goodMatrix
    Write-Text $Root 'PLAN/spec-catalog.jsonl' $goodCatalog
    Write-Text $Root 'PLAN/spec-catalog-archive.jsonl' $goodArchive
}
function Set-Matrix([string] $Root, [string] $Text) {
    Write-Text $Root 'docs/PARITY_MATRIX.md' $Text
}

Write-Host "check-matrix self-test: $base"
$tree = Join-Path $base 'clean'
New-GoodTree $tree
Expect 'clean tree exits 0' (Invoke-Check $tree) 0
$json = Invoke-CheckJson $tree
Expect 'clean tree row count' $json.rows 5
Expect 'clean tree phone offered count' $json.cells.phone.offered 2
Expect 'clean tree phone planned count' $json.cells.phone.planned 1
Expect 'clean tree phone not offered count' $json.cells.phone.'not offered' 2
Expect 'clean tree watch offered count' $json.cells.watch.offered 4
Expect 'clean tree watch not offered count' $json.cells.watch.'not offered' 1
Expect 'clean tree mismatch count' $json.mismatches.Count 0

$tree = Join-Path $base 'empty-phone'
New-GoodTree $tree
Set-Matrix $tree ($goodMatrix -replace '\| PM-001 \| Alpha \| Device \| none \| offered', '| PM-001 | Alpha | Device | none |   ')
$json = Invoke-CheckJson $tree
Expect 'empty phone cell exits 1' (Invoke-Check $tree) 1
Expect-Contains 'empty phone cell reported' $json.mismatches 'no phone cell value'

$tree = Join-Path $base 'junk-cell'
New-GoodTree $tree
Set-Matrix $tree ($goodMatrix -replace '\| none \| offered \| offered \|', '| none | partly | offered |')
$json = Invoke-CheckJson $tree
Expect 'cell outside the vocabulary exits 1' (Invoke-Check $tree) 1
Expect-Contains 'cell outside the vocabulary reported' $json.mismatches 'outside the vocabulary'

$tree = Join-Path $base 'owner-no-date'
New-GoodTree $tree
Set-Matrix $tree ($goodMatrix -replace 'not offered: owner-declined \(2026-11-13\)', 'not offered: owner-declined')
$json = Invoke-CheckJson $tree
Expect 'owner-declined without a date exits 1' (Invoke-Check $tree) 1
Expect-Contains 'owner-declined without a date reported' $json.mismatches 'outside the vocabulary'

$tree = Join-Path $base 'planned-missing'
New-GoodTree $tree
Set-Matrix $tree ($goodMatrix -replace 'planned deviceinfo-mob:S0001', 'planned deviceinfo-mob:S0099')
$json = Invoke-CheckJson $tree
Expect 'planned cell with a missing ticket exits 1' (Invoke-Check $tree) 1
Expect-Contains 'planned missing ticket reported' $json.mismatches 'no such ticket in the store'

$tree = Join-Path $base 'planned-closed'
New-GoodTree $tree
Set-Matrix $tree ($goodMatrix -replace 'planned deviceinfo-mob:S0001', 'planned deviceinfo-mob:S0009')
$json = Invoke-CheckJson $tree
Expect 'planned cell with a closed ticket exits 1' (Invoke-Check $tree) 1
Expect-Contains 'planned closed ticket reported' $json.mismatches 'the ticket is Implemented'

$tree = Join-Path $base 'planned-archived'
New-GoodTree $tree
Set-Matrix $tree ($goodMatrix -replace 'planned deviceinfo-mob:S0001', 'planned deviceinfo-mob:S0002')
$json = Invoke-CheckJson $tree
Expect 'planned cell with an archived ticket exits 1' (Invoke-Check $tree) 1
Expect-Contains 'planned archived ticket reported' $json.mismatches 'archived'

$tree = Join-Path $base 'planned-foreign'
New-GoodTree $tree
Set-Matrix $tree ($goodMatrix -replace 'planned deviceinfo-mob:S0001', 'planned fms_a:S0001')
$json = Invoke-CheckJson $tree
Expect 'planned cell with a foreign repo key exits 1' (Invoke-Check $tree) 1
Expect-Contains 'planned foreign repo key reported' $json.mismatches 'deviceinfo-mob tickets only'

$tree = Join-Path $base 'duplicate-id'
New-GoodTree $tree
Set-Matrix $tree ($goodMatrix -replace '\| PM-005 \| Epsilon', '| PM-001 | Epsilon')
$json = Invoke-CheckJson $tree
Expect 'repeated row id exits 1' (Invoke-Check $tree) 1
Expect-Contains 'repeated row id reported' $json.mismatches "repeats id 'PM-001'"

$tree = Join-Path $base 'short-row'
New-GoodTree $tree
Set-Matrix $tree ($goodMatrix -replace '\| PM-003 \| Gamma \| Environment \| none \| not offered: subset \| offered \|', '| PM-003 | Gamma | Environment | not offered: subset | offered |')
$json = Invoke-CheckJson $tree
Expect 'row with five cells exits 1' (Invoke-Check $tree) 1
Expect-Contains 'row with five cells reported' $json.mismatches 'has 5 cells, expected 6'

$tree = Join-Path $base 'no-matrix'
New-GoodTree $tree
Remove-Item (Join-Path $tree 'docs/PARITY_MATRIX.md')
Expect 'missing matrix exits 2' (Invoke-Check $tree) 2

$tree = Join-Path $base 'no-catalog'
New-GoodTree $tree
Remove-Item (Join-Path $tree 'PLAN/spec-catalog.jsonl')
Expect 'missing catalog exits 2' (Invoke-Check $tree) 2

$tree = Join-Path $base 'no-header'
New-GoodTree $tree
Set-Matrix $tree ($goodMatrix -replace '\| Id \| Function \| Group \| Contract \| Phone \| Watch \|', '| Id | Function | Phone | Watch |')
Expect 'missing main table header exits 2' (Invoke-Check $tree) 2

Remove-Item -Recurse -Force $base
if ($failures -eq 0) {
    Write-Host 'OK: every expectation held.'
    exit 0
}
Write-Host "OPEN: $failures expectation(s) failed."
exit 1
