#requires -Version 7.0
<#
.SYNOPSIS
    Reports every upstream file or string key inside the declared port scope that this repository has neither
    ported nor decided - the fresh upstream inventory that CLAUDE.md section 2 rule 2 asks for.

.DESCRIPTION
    The port ledger holds only files that were ported, so a file or string key FastMediaSorter adds to the
    System Info surface after the port is invisible to check-drift.ps1. This check closes that gap:
    docs/port-scope.json states what part of the upstream is watched (PORT-LEDGER 0.1 rule 5), the upstream
    checkout is scanned against it, and every in-scope item must be classified:

      ported          the file has a ledger row, or the string key is declared in this repository's resources
      decided         a decision in docs/port-decisions.jsonl covers the item's current upstream version
      STALE DECISION  a decision exists, but the upstream item changed after it was written
      NEW SOURCE      no row and no decision - someone has to port it or decide it

    Exit code: 0 in step; 1 at least one NEW SOURCE or STALE DECISION; 2 the check could not run (no upstream
    root, unreadable scope, malformed ledger or decisions). The upstream tree is only read.

.PARAMETER Json
    Print one JSON object with the counts and the open items instead of the text report.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $SourceRoot,
    [string] $DestinationRoot,
    [string] $Ledger,
    [string] $Scope,
    [string] $Decisions,
    [switch] $Json
)

. (Join-Path $PSScriptRoot '_ledger.ps1')
. (Join-Path $PSScriptRoot '_scope.ps1')
$ErrorActionPreference = 'Stop'
trap { Write-Host "check-scope: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

$scopePath = Get-ScopeFile $Scope
$decisionsPath = Get-DecisionsFile $Decisions
$ledgerPath = Get-LedgerFile $Ledger
$sourceRootResolved = Get-SourceRoot $SourceRoot
$destinationRootResolved = Get-DestinationRoot $DestinationRoot

$scopeData = Read-ScopeFile $scopePath
$ledgerRows = Read-LedgerRows $ledgerPath
$decisionRows = Read-DecisionRows $decisionsPath

$ledgerSources = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($row in $ledgerRows) { [void]$ledgerSources.Add([string]$row['source']) }
$fileDecisions = @{}
$stringDecisions = @{}
foreach ($decision in $decisionRows) {
    if ([string]$decision['kind'] -eq 'file') { $fileDecisions[[string]$decision['item']] = $decision }
    else { $stringDecisions[[string]$decision['item']] = $decision }
}

$fileStates = @(foreach ($file in (Get-UpstreamFiles $sourceRootResolved $scopeData)) {
    $state = if ($ledgerSources.Contains($file)) { 'ported' }
             elseif ($fileDecisions.ContainsKey($file)) {
                 $current = Get-FileSha256 (Join-Path $sourceRootResolved $file)
                 if ($current -eq [string]$fileDecisions[$file]['sourceSha256']) { 'decided' } else { 'STALE DECISION' }
             } else { 'NEW SOURCE' }
    [pscustomobject]@{ Kind = 'file'; Item = $file; State = $state }
})

$upstreamKeys = Get-UpstreamStringKeys $sourceRootResolved $scopeData
$destinationKeys = Get-DestinationStringKeys $destinationRootResolved $scopeData
$prefixes = @()
if ($scopeData['strings']) { $prefixes = @($scopeData['strings']['prefixes']) }
$inScopeKeys = @($upstreamKeys.Keys | Where-Object { $key = $_
    @($prefixes | Where-Object { $key.StartsWith($_, [StringComparison]::Ordinal) }).Count -gt 0
} | Sort-Object)

$stringStates = @(foreach ($key in $inScopeKeys) {
    $state = if ($destinationKeys.Contains($key)) { 'ported' }
             elseif ($stringDecisions.ContainsKey($key)) {
                 $decision = $stringDecisions[$key]
                 $current = @($upstreamKeys[$key] | Where-Object { $_.file -eq [string]$decision['sourceFile'] })[0]
                 if ($current -and $current.value -eq [string]$decision['pinnedValue']) { 'decided' } else { 'STALE DECISION' }
             } else { 'NEW SOURCE' }
    [pscustomobject]@{ Kind = 'string'; Item = $key; State = $state }
})

$allStates = @($fileStates + $stringStates)
$ported = @($allStates | Where-Object State -eq 'ported').Count
$decided = @($allStates | Where-Object State -eq 'decided').Count
$stale = @($allStates | Where-Object State -eq 'STALE DECISION')
$newSource = @($allStates | Where-Object State -eq 'NEW SOURCE')
$open = @($stale + $newSource | Sort-Object -Property Kind, Item)

if ($Json) {
    [ordered]@{
        scope        = $scopePath
        sourceRoot   = $sourceRootResolved
        ledger       = $ledgerPath
        ledgerRows   = $ledgerRows.Count
        decisions    = $decisionsPath
        decisionRows = $decisionRows.Count
        files        = [ordered]@{
            inScope       = $fileStates.Count
            ported        = @($fileStates | Where-Object State -eq 'ported').Count
            decided       = @($fileStates | Where-Object State -eq 'decided').Count
            staleDecision = @($fileStates | Where-Object State -eq 'STALE DECISION').Count
            newSource     = @($fileStates | Where-Object State -eq 'NEW SOURCE').Count
        }
        strings      = [ordered]@{
            inScope       = $stringStates.Count
            ported        = @($stringStates | Where-Object State -eq 'ported').Count
            decided       = @($stringStates | Where-Object State -eq 'decided').Count
            staleDecision = @($stringStates | Where-Object State -eq 'STALE DECISION').Count
            newSource     = @($stringStates | Where-Object State -eq 'NEW SOURCE').Count
        }
        open         = @($open | ForEach-Object { [ordered]@{ kind = $_.Kind; state = $_.State; item = $_.Item } })
    } | ConvertTo-Json -Depth 5
    exit ([int]($open.Count -gt 0))
}

Write-Host "Port scope: $scopePath"
Write-Host "Upstream root: $sourceRootResolved (from $script:SourceRootOrigin)"
Write-Host "Ledger: $ledgerPath ($($ledgerRows.Count) row(s))"
Write-Host "Decisions: $decisionsPath ($($decisionRows.Count) row(s))"
Write-Host ("In-scope upstream files: {0} (ported {1}, decided {2}, STALE DECISION {3}, NEW SOURCE {4})" -f `
    $fileStates.Count,
    (@($fileStates | Where-Object State -eq 'ported')).Count,
    (@($fileStates | Where-Object State -eq 'decided')).Count,
    (@($fileStates | Where-Object State -eq 'STALE DECISION')).Count,
    (@($fileStates | Where-Object State -eq 'NEW SOURCE')).Count)
Write-Host ("In-scope upstream string keys: {0} (ported {1}, decided {2}, STALE DECISION {3}, NEW SOURCE {4})" -f `
    $stringStates.Count,
    (@($stringStates | Where-Object State -eq 'ported')).Count,
    (@($stringStates | Where-Object State -eq 'decided')).Count,
    (@($stringStates | Where-Object State -eq 'STALE DECISION')).Count,
    (@($stringStates | Where-Object State -eq 'NEW SOURCE')).Count)
foreach ($item in $open) {
    Write-Host ("  {0,-14} {1}  {2}" -f $item.State, $item.Kind, $item.Item) -ForegroundColor Yellow
}
if ($open.Count -eq 0) {
    Write-Host "OK: every in-scope upstream item is ported or decided ($ported ported, $decided decided)."
    exit 0
}
Write-Host "OPEN: $($open.Count) in-scope upstream item(s) need a port (record-port.ps1) or a decision (record-decision.ps1)." -ForegroundColor Yellow
exit 1
