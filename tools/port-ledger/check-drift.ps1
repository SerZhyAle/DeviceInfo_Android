#requires -Version 7.0
<#
.SYNOPSIS
    Lists every ported file whose upstream source changed since it was ported - the to-do list for carrying a
    fix across.

.DESCRIPTION
    Re-hashes the upstream source of every ledger row and compares it with the hash recorded at port time.
    Run it at the start of every release and before any parity claim.

    A row is one of:
      in step      the upstream source still hashes to the recorded value
      decided      the source changed, and a decision written for exactly this source version covers it
      DRIFT        the source changed and nobody carried it or wrote a decision
      SOURCE GONE  the source no longer exists (removed or moved) and no decision covers that
      NO DEST      the destination file is missing here - the ledger is wrong

    An empty or absent ledger is in step by definition. The upstream tree is only read.

    Exit code: 0 nothing uncarried; 1 at least one DRIFT, SOURCE GONE or NO DEST; 2 the check could not run
    (no upstream root, malformed ledger).

.PARAMETER Json
    Print one JSON object with the counts and the uncarried rows instead of the text report.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $SourceRoot,
    [string] $DestinationRoot,
    [string] $Ledger,
    [switch] $Json
)

. (Join-Path $PSScriptRoot '_ledger.ps1')
$ErrorActionPreference = 'Stop'
trap { Write-Host "check-drift: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

$ledgerPath = Get-LedgerFile $Ledger
$sourceRootResolved = Get-SourceRoot $SourceRoot
$rows = Read-LedgerRows $ledgerPath
$states = Get-LedgerStates $rows $sourceRootResolved (Get-DestinationRoot $DestinationRoot)
$uncarried = @($states | Where-Object { $_.State -in 'DRIFT', 'SOURCE GONE', 'NO DEST' })
$inStep = @($states | Where-Object State -eq 'in step').Count
$decided = @($states | Where-Object State -eq 'decided').Count

if ($Json) {
    [ordered]@{
        ledger    = $ledgerPath
        rows      = $states.Count
        inStep    = $inStep
        decided   = $decided
        uncarried = @($uncarried | ForEach-Object { [ordered]@{ state = $_.State; source = $_.Source; destination = $_.Destination; since = $_.AnchoredOn } })
    } | ConvertTo-Json -Depth 5
    exit ([int]($uncarried.Count -gt 0))
}

Write-Host "Port ledger: $($states.Count) row(s) in $ledgerPath"
Write-Host "Upstream root: $sourceRootResolved (from $script:SourceRootOrigin)"
foreach ($settled in @($states | Where-Object State -eq 'decided')) {
    Write-Host ("  decided      {0}`n               {1}" -f $settled.Source, $settled.Note)
}
foreach ($open in $uncarried) {
    Write-Host ("  {0,-12} {1}  ->  {2}  (anchored on {3})" -f $open.State, $open.Source, $open.Destination, $open.AnchoredOn) -ForegroundColor Yellow
}
if ($uncarried.Count -eq 0) {
    Write-Host "OK: nothing uncarried ($inStep in step, $decided decided)."
    exit 0
}
Write-Host "UNCARRIED: $($uncarried.Count) of $($states.Count) row(s) need a carry (record-port.ps1 -Refresh) or a decision (record-port.ps1 -Decide)." -ForegroundColor Yellow
exit 1
