#requires -Version 7.0
<#
.SYNOPSIS
    Tests destination baselines, classification and notice handling in a throw-away tree.
.DESCRIPTION
    Runs the actual scripts in this process. Tests old rows, backfill, new ports, informational and strict
    checks, stale classifications, notices, KDoc evidence, decisions, carries and error exits. Exit 0 on
    success, 1 on a failed expectation. Neither the real ledger nor the upstream is touched.
#>
[CmdletBinding(PositionalBinding = $false)]
param()
. (Join-Path $PSScriptRoot '_ledger.ps1')
$ErrorActionPreference = 'Stop'
$scratch = Join-Path $script:RepoRoot 'temp\S0019'
$base = Join-Path $scratch ('local-test-' + [guid]::NewGuid().ToString('N'))
$upstream = Join-Path $base 'up'
$here = Join-Path $base 'here'
$ledger = Join-Path $base 'ledger.jsonl'
$decisions = Join-Path $base 'decisions.jsonl'
$notices = Join-Path $base 'notices.jsonl'
New-Item -ItemType Directory -Path $upstream, $here -Force | Out-Null
$failures = 0

function Expect([string] $What, $Actual, $Expected) {
    if ($Actual -ceq $Expected) { Write-Host "  PASS  $What (expected: $Expected | actual: $Actual)" }
    else { $script:failures++; Write-Host "  FAIL  $What (expected: $Expected | actual: $Actual)" -ForegroundColor Red }
}
function Invoke-Local([hashtable] $ArgsMap = @{}) {
    $script:localOutput = @(& (Join-Path $PSScriptRoot 'check-local-divergence.ps1') -DestinationRoot $here -Ledger $ledger -Decisions $decisions -Notices $notices @ArgsMap 6>&1 2>&1)
    return $LASTEXITCODE
}
function Invoke-Port([hashtable] $ArgsMap = @{}) {
    $null = & (Join-Path $PSScriptRoot 'record-port.ps1') -Source 'a.kt' -Destination 'a.kt' -SourceRoot $upstream -DestinationRoot $here -Ledger $ledger -LocalDecisions $decisions -Notices $notices -Date '2026-11-14' @ArgsMap 6>&1 2>&1
    return $LASTEXITCODE
}
function Invoke-Classification([hashtable] $ArgsMap) {
    $null = & (Join-Path $PSScriptRoot 'record-local-decision.ps1') -Destination 'a.kt' -DestinationRoot $here -Ledger $ledger -Decisions $decisions -Notices $notices -Date '2026-11-14' @ArgsMap 6>&1 2>&1
    return $LASTEXITCODE
}
function Row { (Read-LedgerRows $ledger)[0] }

try {
    [System.IO.File]::WriteAllText((Join-Path $upstream 'a.kt'), 'source1')
    [System.IO.File]::WriteAllText((Join-Path $here 'a.kt'), 'destination1')
    $sourceHash = Get-FileSha256 (Join-Path $upstream 'a.kt')
    [System.IO.File]::WriteAllText($ledger, "{`"source`":`"a.kt`",`"sourceSha256`":`"$sourceHash`",`"destination`":`"a.kt`",`"portedOn`":`"2026-11-10`",`"futureField`":{`"value`":42}}`n")
    Expect 'legacy row is informational' (Invoke-Local) 0
    Expect 'legacy row cannot pass the release gate' (Invoke-Local @{ RequireClassified = $true }) 1
    $null = & (Join-Path $PSScriptRoot 'backfill-destination-hashes.ps1') -DestinationRoot $here -Ledger $ledger -Date '2026-11-14' 6>&1 2>&1
    Expect 'backfill exits 0' $LASTEXITCODE 0
    Expect 'backfill hash matches destination' ((Row).destinationSha256) (Get-FileSha256 (Join-Path $here 'a.kt'))
    Expect 'backfill date is explicit' ((Row).destinationHashedOn) '2026-11-14'
    Expect 'unknown ledger field survives' ((Row).futureField.value) 42
    Expect 'backfilled row passes release gate' (Invoke-Local @{ RequireClassified = $true }) 0
    $baselineHash = (Row).destinationSha256

    [System.IO.File]::WriteAllText((Join-Path $here 'a.kt'), '/** Deliberate adaptation for this product. */ class A')
    Expect 'local edit is informative' (Invoke-Local) 0
    Expect 'local edit is printed' ([bool](($script:localOutput -join "`n") -match 'LOCAL EDIT')) $true
    Expect 'unclassified edit fails release gate' (Invoke-Local @{ RequireClassified = $true }) 1
    Expect 'refresh cannot erase an unclassified edit' (Invoke-Port @{ Refresh = $true }) 2
    Expect 'baseline survived refused refresh' ((Row).destinationSha256) $baselineHash
    $null = & (Join-Path $PSScriptRoot 'backfill-destination-hashes.ps1') -DestinationRoot $here -Ledger $ledger -Date '2026-11-14' 6>&1 2>&1
    Expect 'repeat backfill exits 0' $LASTEXITCODE 0
    Expect 'repeat backfill cannot erase an edit' ((Row).destinationSha256) $baselineHash

    Expect 'candidate without notice is refused' (Invoke-Classification @{ Classification = 'candidate'; Note = 'candidate'; Notice = 'RP-0001' }) 2
    Expect 'missing KDoc evidence is refused' (Invoke-Classification @{ Classification = 'deliberate'; Note = 'adaptation'; EvidenceText = 'not in the KDoc' }) 2
    Expect 'deliberate difference with KDoc is recorded' (Invoke-Classification @{ Classification = 'deliberate'; Note = 'adaptation'; EvidenceText = 'Deliberate adaptation' }) 0
    Expect 'documented difference passes release gate' (Invoke-Local @{ RequireClassified = $true }) 0

    $notice = @{ id = 'RP-0001'; state = 'open'; title = 'Carry improvement'; summary = 'A real change'; identifiedOn = '2026-11-14'; destinations = @('a.kt') }
    [System.IO.File]::WriteAllText($notices, (($notice | ConvertTo-Json -Compress) + "`n"))
    Expect 'candidate with tracked notice is recorded' (Invoke-Classification @{ Classification = 'candidate'; Note = 'carry it'; Notice = 'RP-0001' }) 0
    Expect 'candidate passes release gate' (Invoke-Local @{ RequireClassified = $true }) 0
    Remove-Item -LiteralPath $notices
    Expect 'deleted notice fails release gate' (Invoke-Local @{ RequireClassified = $true }) 1
    $notice.state = 'handed-over'
    [System.IO.File]::WriteAllText($notices, (($notice | ConvertTo-Json -Compress) + "`n"))
    Expect 'handover without source ticket is invalid' (Invoke-Local @{ RequireClassified = $true }) 2
    $notice.state = 'declined'
    $notice.sourceTicket = 'fms-a:S4543'
    [System.IO.File]::WriteAllText($notices, (($notice | ConvertTo-Json -Compress) + "`n"))
    Expect 'decline without reason is invalid' (Invoke-Local @{ RequireClassified = $true }) 2
    $notice.state = 'open'
    $notice.Remove('sourceTicket')
    [System.IO.File]::WriteAllText($notices, (($notice | ConvertTo-Json -Compress) + "`n"))

    [System.IO.File]::WriteAllText((Join-Path $here 'a.kt'), 'destination changed again')
    [System.IO.File]::WriteAllText((Join-Path $upstream 'a.kt'), 'source2')
    Expect 'old classification does not cover another edit' (Invoke-Local @{ RequireClassified = $true }) 1
    Expect 'upstream decision exits 0' (Invoke-Port @{ Decide = $true; Note = 'not carried yet' }) 0
    Expect 'upstream decision leaves local baseline untouched' ((Row).destinationSha256) $baselineHash
    Expect 'new bytes can be classified case-insensitively' (Invoke-Classification @{ Classification = 'NOT-APPLICABLE'; Note = 'carry preparation' }) 0
    Expect 'classified bytes pass release gate' (Invoke-Local @{ RequireClassified = $true }) 0
    Expect 'classified carry can refresh' (Invoke-Port @{ Refresh = $true }) 0
    Expect 'carry records destination bytes' ((Row).destinationSha256) (Get-FileSha256 (Join-Path $here 'a.kt'))
    Expect 'carry records source bytes' ((Row).sourceSha256) (Get-FileSha256 (Join-Path $upstream 'a.kt'))
    Expect 'carry records date' ((Row).carriedOn) '2026-11-14'
    Expect 'carry removes upstream decision' ((Row).ContainsKey('decision')) $false
    Expect 'carry preserves unknown fields' ((Row).futureField.value) 42
    Expect 'carried row passes release gate' (Invoke-Local @{ RequireClassified = $true }) 0

    [System.IO.File]::WriteAllText((Join-Path $upstream 'b.kt'), 'source b')
    [System.IO.File]::WriteAllText((Join-Path $here 'b.kt'), 'destination b')
    $null = & (Join-Path $PSScriptRoot 'record-port.ps1') -Source 'b.kt' -Destination 'b.kt' -SourceRoot $upstream -DestinationRoot $here -Ledger $ledger -Date '2026-11-14' 6>&1 2>&1
    Expect 'new port exits 0' $LASTEXITCODE 0
    $newRow = @((Read-LedgerRows $ledger) | Where-Object { $_.destination -eq 'b.kt' })[0]
    Expect 'new port records destination hash' $newRow.destinationSha256 (Get-FileSha256 (Join-Path $here 'b.kt'))
    Expect 'new port records destination date' $newRow.destinationHashedOn '2026-11-14'
    $null = & (Join-Path $PSScriptRoot 'check-drift.ps1') -SourceRoot $upstream -DestinationRoot $here -Ledger $ledger 6>&1 2>&1
    Expect 'forward drift check still passes' $LASTEXITCODE 0
    [System.IO.File]::WriteAllText((Join-Path $here 'a.kt'), 'another a edit')
    [System.IO.File]::WriteAllText((Join-Path $here 'b.kt'), 'another b edit')
    Expect 'multiple local edits remain informational' (Invoke-Local @{ Json = $true }) 0
    $report = ($script:localOutput -join "`n") | ConvertFrom-Json
    Expect 'both edited destinations are listed' $report.localEdits 2
    Expect 'all listed items are LOCAL EDIT' (@($report.items | Where-Object State -eq 'LOCAL EDIT').Count) 2
    Expect 'multiple unclassified edits fail release gate' (Invoke-Local @{ RequireClassified = $true }) 1
    Remove-Item -LiteralPath (Join-Path $here 'a.kt')
    Expect 'missing destination fails even informational check' (Invoke-Local) 1
    [System.IO.File]::WriteAllText($decisions, 'not json')
    Expect 'malformed classifications exit 2' (Invoke-Local) 2
} catch {
    $script:failures++
    Write-Host "  FAIL  unexpected exception: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    $resolvedBase = [System.IO.Path]::GetFullPath($base)
    $resolvedScratch = [System.IO.Path]::GetFullPath($scratch).TrimEnd('\') + '\'
    if ($resolvedBase.StartsWith($resolvedScratch, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedBase)) {
        Remove-Item -LiteralPath $resolvedBase -Recurse -Force
    }
}
if ($failures -eq 0) { Write-Host 'local divergence self-test: all expectations held.'; exit 0 }
Write-Host "local divergence self-test: $failures expectation(s) failed." -ForegroundColor Red
exit 1
