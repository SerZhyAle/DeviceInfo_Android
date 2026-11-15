#requires -Version 7.0
<#
.SYNOPSIS
    Adds, refreshes or decides one row of the port ledger (docs/port-ledger.jsonl).

.DESCRIPTION
    Run right after porting a file: the row takes the current source and destination SHA-256 hashes.

      record-port.ps1 -Source <upstream path> -Destination <path here>            add a row
      record-port.ps1 -Source <..> -Destination <..> -Refresh                    a newer upstream version was carried
      record-port.ps1 -Source <..> -Destination <..> -Decide -Note "<why>"       a change is deliberately not carried

    A decision is pinned to the upstream version it was written about: the next upstream change is drift again.
    Before -Refresh replaces a changed destination baseline, classify the current destination bytes using
    record-local-decision.ps1. A decision not to carry never changes the destination baseline.
    Paths are relative to their repository roots. The upstream tree is only read.

    Exit code: 0 the row was written; 2 the call could not be honoured (missing file, duplicate row, no row to
    refresh or decide, absolute or escaping path).

.PARAMETER Source
    Path inside the upstream repository, for example app_v2/src/main/java/com/sza/fastmediasorter/core/systeminfo/SystemInfoGroup.kt.
.PARAMETER Destination
    Path inside this repository.
.PARAMETER Refresh
    Take both files' current hashes and set carriedOn and destinationHashedOn.
.PARAMETER Decide
    Pin a decision not to carry the current upstream version; needs -Note.
.PARAMETER Note
    The reason, one line.
.PARAMETER Date
    yyyy-MM-dd, default today.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Mandatory)][string] $Source,
    [Parameter(Mandatory)][string] $Destination,
    [switch] $Refresh,
    [switch] $Decide,
    [string] $Note,
    [string] $Date,
    [string] $SourceRoot,
    [string] $DestinationRoot,
    [string] $Ledger,
    [string] $LocalDecisions,
    [string] $Notices
)

. (Join-Path $PSScriptRoot '_ledger.ps1')
. (Join-Path $PSScriptRoot '_local-divergence.ps1')
$ErrorActionPreference = 'Stop'
trap { Write-Host "record-port: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

if ($Refresh -and $Decide) { throw '-Refresh and -Decide exclude each other.' }
if ($Decide -and [string]::IsNullOrWhiteSpace($Note)) { throw '-Decide needs -Note.' }
$day = if ($Date) { $Date } else { (Get-Date).ToString('yyyy-MM-dd') }
if ($day -notmatch '^\d{4}-\d{2}-\d{2}$') { throw "-Date '$Date' is not yyyy-MM-dd." }

$sourceRel = ConvertTo-RelativeLedgerPath $Source 'Source'
$destinationRel = ConvertTo-RelativeLedgerPath $Destination 'Destination'
$sourceFile = Join-Path (Get-SourceRoot $SourceRoot) $sourceRel
$destinationRootResolved = Get-DestinationRoot $DestinationRoot
$destinationFile = Join-Path $destinationRootResolved $destinationRel
if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) { throw "Source file '$sourceRel' does not exist upstream." }
if (-not (Test-Path -LiteralPath $destinationFile -PathType Leaf)) { throw "Destination file '$destinationRel' does not exist here." }

$ledgerPath = Get-LedgerFile $Ledger
$rows = Read-LedgerRows $ledgerPath
$existing = @($rows | Where-Object { $_['source'] -eq $sourceRel -and $_['destination'] -eq $destinationRel })
if ($existing.Count -gt 1) { throw "Duplicate ledger rows for $sourceRel -> $destinationRel." }
$hash = Get-FileSha256 $sourceFile
$destinationHash = Get-FileSha256 $destinationFile

if ($existing.Count -eq 0) {
    if ($Refresh -or $Decide) { throw "No ledger row for $sourceRel -> $destinationRel." }
    $rows.Add(@{ source = $sourceRel; sourceSha256 = $hash; destination = $destinationRel; destinationSha256 = $destinationHash; destinationHashedOn = $day; portedOn = $day })
    Write-Host "recorded $sourceRel -> $destinationRel"
} elseif ($Refresh) {
    if (-not $existing[0].ContainsKey('destinationSha256')) { throw 'Backfill the destination baseline before refreshing this row.' }
    if ($existing[0]['destinationSha256'] -cne $destinationHash) {
        $decisionsPath = if ($LocalDecisions) { $LocalDecisions } else { $script:LocalDecisionsFile }
        $noticesPath = if ($Notices) { $Notices } else { $script:ReverseNoticesFile }
        $localState = @(Get-LocalStates -Rows $existing -DestinationRoot $destinationRootResolved `
            -Decisions (Read-LocalDecisions $decisionsPath) -Notices (Read-ReverseNotices $noticesPath))[0]
        if (-not $localState.Classification) { throw 'Classify the current destination before replacing its baseline.' }
    }
    $existing[0]['sourceSha256'] = $hash
    $existing[0]['destinationSha256'] = $destinationHash
    $existing[0]['destinationHashedOn'] = $day
    $existing[0]['carriedOn'] = $day
    $existing[0].Remove('decision')
    Write-Host "refreshed $sourceRel (carriedOn $day)"
} elseif ($Decide) {
    $existing[0]['decision'] = [ordered]@{ sourceSha256 = $hash; note = $Note.Trim(); decidedOn = $day }
    Write-Host "decided $sourceRel (pinned to $($hash.Substring(0, 12)))"
} else {
    throw "A row for $sourceRel -> $destinationRel exists; use -Refresh after carrying a newer version."
}
Write-LedgerRows $ledgerPath $rows
exit 0
