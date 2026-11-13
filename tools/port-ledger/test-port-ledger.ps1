#requires -Version 7.0
<#
.SYNOPSIS
    Self-test of the port ledger tools on a throw-away tree. Touches neither this ledger nor the upstream.

.DESCRIPTION
    A drift check that reports nothing passes as quietly as a clean one, so this proves it can fail: it walks one
    ledger row through every state the check reports (in step, DRIFT, decided, DRIFT again after the next change,
    in step after a carry, SOURCE GONE, NO DEST), the exit codes 0, 1 and 2, and the refusal of a path that
    leaves its repository. Run it after editing anything in tools/port-ledger.

    Exit code: 0 every expectation held; 1 at least one failed.
#>
[CmdletBinding(PositionalBinding = $false)]
param()

. (Join-Path $PSScriptRoot '_ledger.ps1')
$ErrorActionPreference = 'Stop'

$scratch = Join-Path $script:RepoRoot 'temp\S0003'
$base = Join-Path $scratch ('ledger-test-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$upstream = Join-Path $base 'up'
$here = Join-Path $base 'here'
$ledger = Join-Path $base 'ledger.jsonl'
New-Item -ItemType Directory -Path $upstream, $here -Force | Out-Null
$failures = 0

function Expect([string] $What, $Actual, $Expected) {
    if ($Actual -eq $Expected) { Write-Host "  PASS  $What (expected: $Expected | actual: $Actual)" }
    else { $script:failures++; Write-Host "  FAIL  $What (expected: $Expected | actual: $Actual)" -ForegroundColor Red }
}
function Invoke-Tool([string] $Script, [string[]] $ToolArgs) {
    $null = & pwsh -NoProfile -File (Join-Path $PSScriptRoot $Script) @ToolArgs -SourceRoot $upstream -DestinationRoot $here -Ledger $ledger 2>&1
    return $LASTEXITCODE
}
function Get-OnlyState { (Get-LedgerStates (Read-LedgerRows $ledger) $upstream $here)[0].State }

try {
    Expect 'empty ledger exits 0' (Invoke-Tool 'check-drift.ps1' @()) 0

    [System.IO.File]::WriteAllText((Join-Path $upstream 'a.kt'), 'v1')
    [System.IO.File]::WriteAllText((Join-Path $here 'a.kt'), 'v1')
    Expect 'record exits 0' (Invoke-Tool 'record-port.ps1' @('-Source', 'a.kt', '-Destination', 'a.kt')) 0
    Expect 'fresh row' (Get-OnlyState) 'in step'

    [System.IO.File]::WriteAllText((Join-Path $upstream 'a.kt'), 'v2')
    Expect 'changed source' (Get-OnlyState) 'DRIFT'
    Expect 'DRIFT exits 1' (Invoke-Tool 'check-drift.ps1' @()) 1

    Expect 'decide exits 0' (Invoke-Tool 'record-port.ps1' @('-Source', 'a.kt', '-Destination', 'a.kt', '-Decide', '-Note', 'not needed')) 0
    Expect 'decision covers this version' (Get-OnlyState) 'decided'
    Expect 'decided exits 0' (Invoke-Tool 'check-drift.ps1' @()) 0

    [System.IO.File]::WriteAllText((Join-Path $upstream 'a.kt'), 'v3')
    Expect 'next change is drift again' (Get-OnlyState) 'DRIFT'

    Expect 'refresh exits 0' (Invoke-Tool 'record-port.ps1' @('-Source', 'a.kt', '-Destination', 'a.kt', '-Refresh')) 0
    Expect 'carried row' (Get-OnlyState) 'in step'
    Expect 'carriedOn is set' ([bool]((Read-LedgerRows $ledger)[0]).ContainsKey('carriedOn')) $true

    Remove-Item -LiteralPath (Join-Path $upstream 'a.kt')
    Expect 'removed source' (Get-OnlyState) 'SOURCE GONE'
    [System.IO.File]::WriteAllText((Join-Path $upstream 'a.kt'), 'v3')
    Remove-Item -LiteralPath (Join-Path $here 'a.kt')
    Expect 'removed destination' (Get-OnlyState) 'NO DEST'

    Expect 'escaping path is refused with 2' (Invoke-Tool 'record-port.ps1' @('-Source', '../x.kt', '-Destination', 'a.kt')) 2
    Set-Content -LiteralPath $ledger -Value 'not json'
    Expect 'malformed ledger exits 2' (Invoke-Tool 'check-drift.ps1' @()) 2
}
finally {
    if ($base.StartsWith($scratch) -and (Test-Path -LiteralPath $base)) { Remove-Item -LiteralPath $base -Recurse -Force }
}

if ($failures -eq 0) { Write-Host 'port-ledger self-test: all expectations held.'; exit 0 }
Write-Host "port-ledger self-test: $failures expectation(s) failed." -ForegroundColor Red
exit 1
