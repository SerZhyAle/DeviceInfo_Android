#requires -Version 7.0
<#
.SYNOPSIS
    Lists local changes to ported files. -RequireClassified is the release gate.
.DESCRIPTION
    LOCAL EDIT is informational by default, even without a classification. The release mode exits 1 for
    an unclassified edit, a missing destination, a missing baseline or a baseline without its recording date.
    A classification covers exactly the destination hash it names. Exit 2 means the check could not run.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $DestinationRoot,
    [string] $Ledger,
    [string] $Decisions,
    [string] $Notices,
    [switch] $RequireClassified,
    [switch] $Json
)
. (Join-Path $PSScriptRoot '_ledger.ps1')
. (Join-Path $PSScriptRoot '_local-divergence.ps1')
$ErrorActionPreference = 'Stop'
trap { Write-Host "check-local-divergence: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

$ledgerPath = Get-LedgerFile $Ledger
$decisionsPath = if ($Decisions) { $Decisions } else { $script:LocalDecisionsFile }
$noticesPath = if ($Notices) { $Notices } else { $script:ReverseNoticesFile }
$states = Get-LocalStates -Rows (Read-LedgerRows $ledgerPath) -DestinationRoot (Get-DestinationRoot $DestinationRoot) `
    -Decisions (Read-LocalDecisions $decisionsPath) -Notices (Read-ReverseNotices $noticesPath)
$edits = @($states | Where-Object State -eq 'LOCAL EDIT')
$unclassified = @($edits | Where-Object { -not $_.Classification })
$missing = @($states | Where-Object State -eq 'NO DEST')
$unanchored = @($states | Where-Object { $_.State -eq 'NO BASELINE' -or $_.MissingDate })
$failed = ($missing.Count -gt 0) -or ($RequireClassified -and ($unclassified.Count -gt 0 -or $unanchored.Count -gt 0))

if ($Json) {
    [ordered]@{ ledger = $ledgerPath; rows = $states.Count; localEdits = $edits.Count;
        unclassified = $unclassified.Count; missing = $missing.Count; unanchored = $unanchored.Count;
        items = @($states | Where-Object { $_.State -ne 'unchanged' -or $_.MissingDate }) } | ConvertTo-Json -Depth 6
} else {
    Write-Host "Local divergence: $($states.Count) row(s) in $ledgerPath"
    foreach ($item in @($states | Where-Object { $_.State -ne 'unchanged' -or $_.MissingDate })) {
        $detail = if ($item.Classification) { $item.Classification } elseif ($item.Reason) { $item.Reason } else { 'unclassified' }
        if ($item.Notice) { $detail += "; notice $($item.Notice)" }
        if ($item.MissingDate) { $detail += '; baseline date missing' }
        Write-Host ("  {0,-12} {1} ({2})" -f $item.State, $item.Destination, $detail)
    }
    Write-Host "Local edits: $($edits.Count); unclassified: $($unclassified.Count); missing: $($missing.Count); unanchored: $($unanchored.Count)."
    if ($RequireClassified -and -not $failed) { Write-Host 'OK: every local edit is classified.' }
}
exit ([int]$failed)
