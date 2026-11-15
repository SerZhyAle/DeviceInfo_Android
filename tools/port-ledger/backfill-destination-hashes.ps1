#requires -Version 7.0
<#
.SYNOPSIS
    Records the current destination hash for rows without one, as a baseline, not port history.
.DESCRIPTION
    Existing destination hashes are never overwritten. All destinations are checked before any write.
    Exit 0 on success; 2 for an invalid date, a missing file or an unreadable ledger.
#>
[CmdletBinding(PositionalBinding = $false)]
param([string] $DestinationRoot, [string] $Ledger, [string] $Date)
. (Join-Path $PSScriptRoot '_ledger.ps1')
. (Join-Path $PSScriptRoot '_local-divergence.ps1')
$ErrorActionPreference = 'Stop'
trap { Write-Host "backfill-destination-hashes: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }
$day = if ($Date) { $Date } else { (Get-Date).ToString('yyyy-MM-dd') }
if ($day -notmatch '^\d{4}-\d{2}-\d{2}$') { throw 'Date must be yyyy-MM-dd.' }
$ledgerPath = Get-LedgerFile $Ledger
$rows = Read-LedgerRows $ledgerPath
$count = Initialize-DestinationHashes -Rows $rows -DestinationRoot (Get-DestinationRoot $DestinationRoot) -Date $day
if ($count -gt 0) { Write-LedgerRows $ledgerPath $rows }
Write-Host "Backfilled $count destination hash(es) on $day; this is a baseline, not port history."
exit 0
