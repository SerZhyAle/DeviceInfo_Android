#requires -Version 7.0
<#
.SYNOPSIS
    Self-test of the port ledger tools on a throw-away tree. Touches neither this ledger nor the upstream.

.DESCRIPTION
    A drift check that reports nothing passes as quietly as a clean one, so this proves it can fail: it walks one
    ledger row through every state the check reports (in step, DRIFT, decided, DRIFT again after the next change,
    in step after a carry, SOURCE GONE, NO DEST), the exit codes 0, 1 and 2, and the refusal of a path that
    leaves its repository. It also proves the source-root order of PORT-LEDGER rule 8 (argument, SZA_PORT_SOURCE_ROOT,
    DEVICEINFO_FMS_ROOT, the registry path of extraction.sourceProject), that every unresolvable root is exit 2, and
    that this repository's profile block agrees with the tools' defaults. The scripts run in this process. The scope and local divergence checks have their
    own self-tests, test-port-scope.ps1 and test-local-divergence.ps1.

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
function Invoke-Tool([string] $Script, [hashtable] $ToolArgs) {
    $null = & (Join-Path $PSScriptRoot $Script) @ToolArgs -SourceRoot $upstream -DestinationRoot $here -Ledger $ledger 6>&1 2>&1
    return $LASTEXITCODE
}
function Get-OnlyState { (Get-LedgerStates (Read-LedgerRows $ledger) $upstream $here)[0].State }
function Invoke-WithEnv([hashtable] $Vars, [scriptblock] $Body) {
    $saved = @{}
    foreach ($name in $Vars.Keys) { $saved[$name] = [Environment]::GetEnvironmentVariable($name); [Environment]::SetEnvironmentVariable($name, $Vars[$name]) }
    try { & $Body } finally { foreach ($name in $saved.Keys) { [Environment]::SetEnvironmentVariable($name, $saved[$name]) } }
}
function Invoke-NoRootArg([string] $Script) {
    # The tool without -SourceRoot: the root comes from the environment and the registry only.
    $out = & (Join-Path $PSScriptRoot $Script) -DestinationRoot $here -Ledger $ledger 6>&1 2>&1
    return [pscustomobject]@{ Exit = $LASTEXITCODE; Text = (($out | ForEach-Object { "$_" }) -join "`n") }
}
function Write-Registry([string] $Dir, $Repos) {
    New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $Dir 'repos.json'), (@{ schemaVersion = '1.0'; repos = @($Repos) } | ConvertTo-Json -Depth 5))
}

try {
    Expect 'empty ledger exits 0' (Invoke-Tool 'check-drift.ps1' @{}) 0

    # --- the source root, PORT-LEDGER rule 8: argument, SZA_PORT_SOURCE_ROOT, DEVICEINFO_FMS_ROOT, then the registry
    $nowhere = Join-Path $base 'nowhere'
    $portfolio = Join-Path $base 'portfolio'
    $clear = @{ SZA_PORT_SOURCE_ROOT = $null; DEVICEINFO_FMS_ROOT = $null; SZA_PORTFOLIO_ROOT = $portfolio }
    Write-Registry $portfolio @(@{ key = 'other'; path = $nowhere; enabled = $true }, @{ key = 'fms-a'; path = $upstream; enabled = $true })
    Invoke-WithEnv $clear {
        $r = Invoke-NoRootArg 'check-drift.ps1'
        Expect 'registry path of extraction.sourceProject names the root: exit' $r.Exit 0
        Expect 'registry path of extraction.sourceProject names the root: origin' ($r.Text -like '*(from registry:fms-a)*') $true
        [Environment]::SetEnvironmentVariable('DEVICEINFO_FMS_ROOT', $upstream)
        $r = Invoke-NoRootArg 'check-drift.ps1'
        Expect 'DEVICEINFO_FMS_ROOT stays accepted: origin' ($r.Text -like '*(from DEVICEINFO_FMS_ROOT)*') $true
        [Environment]::SetEnvironmentVariable('SZA_PORT_SOURCE_ROOT', $upstream)
        $r = Invoke-NoRootArg 'check-drift.ps1'
        Expect 'SZA_PORT_SOURCE_ROOT comes first: origin' ($r.Text -like '*(from SZA_PORT_SOURCE_ROOT)*') $true
        [Environment]::SetEnvironmentVariable('SZA_PORT_SOURCE_ROOT', $nowhere)
        Expect 'a variable that points nowhere is exit 2, not a silent fall-through' (Invoke-NoRootArg 'check-drift.ps1').Exit 2
    }
    Invoke-WithEnv $clear {
        Write-Registry $portfolio @(@{ key = 'fms-a'; path = $nowhere; enabled = $true })
        Expect 'registry path that does not exist is exit 2' (Invoke-NoRootArg 'check-drift.ps1').Exit 2
        Write-Registry $portfolio @(@{ key = 'other'; path = $upstream; enabled = $true })
        Expect 'registry without the source project is exit 2' (Invoke-NoRootArg 'check-drift.ps1').Exit 2
        Expect 'Get-RegistrySourceRoot returns the path of the named project' (Get-RegistrySourceRoot 'other' (Join-Path $portfolio 'repos.json')) $upstream
        $threw = $false
        try { $null = Get-RegistrySourceRoot 'OTHER' (Join-Path $portfolio 'repos.json') } catch { $threw = $true }
        Expect 'registry keys match case-sensitively' $threw $true
        Set-Content -LiteralPath (Join-Path $portfolio 'repos.json') -Value 'not json'
        Expect 'registry that is not JSON is exit 2' (Invoke-NoRootArg 'check-drift.ps1').Exit 2
        Remove-Item -LiteralPath (Join-Path $portfolio 'repos.json')
        Expect 'missing registry is exit 2' (Invoke-NoRootArg 'check-drift.ps1').Exit 2
    }

    # --- extraction.sourceProject of the profile (HARNESS-PROFILE rule 13), read from a throw-away profile
    $tmpProfile = Join-Path $base 'profile.json'
    Expect 'no profile file: no source project' ($null -eq (Get-ExtractionSourceProject $tmpProfile)) $true
    [System.IO.File]::WriteAllText($tmpProfile, '{"projectName":"x"}')
    Expect 'profile without an extraction block: no source project' ($null -eq (Get-ExtractionSourceProject $tmpProfile)) $true
    [System.IO.File]::WriteAllText($tmpProfile, '{"extraction":{"ledger":"l.jsonl"}}')
    Expect 'extraction block without sourceProject: no source project' ($null -eq (Get-ExtractionSourceProject $tmpProfile)) $true
    [System.IO.File]::WriteAllText($tmpProfile, '{"extraction":{"ledger":"l.jsonl","sourceProject":"src-key"}}')
    Expect 'extraction.sourceProject is read' (Get-ExtractionSourceProject $tmpProfile) 'src-key'
    [System.IO.File]::WriteAllText($tmpProfile, 'not json')
    $threw = $false
    try { $null = Get-ExtractionSourceProject $tmpProfile } catch { $threw = $true }
    Expect 'profile that is not JSON throws' $threw $true

    # --- this repository's own profile: the block exists and agrees with the tools' defaults, and no path is tracked
    . (Join-Path $PSScriptRoot '_scope.ps1')
    $own = [System.IO.File]::ReadAllText($script:ProfileFile) | ConvertFrom-Json -AsHashtable
    $ext = $own['extraction']
    $relative = { param($p) [System.IO.Path]::GetRelativePath($script:RepoRoot, $p) -replace '\\', '/' }
    Expect 'profile declares extraction.sourceProject' (Get-ExtractionSourceProject) 'fms-a'
    Expect 'profile extraction.ledger equals the tools'' default ledger' $ext['ledger'] (& $relative $script:LedgerFile)
    Expect 'profile extraction.scope equals the tools'' default scope file' $ext['scope'] (& $relative $script:ScopeFile)
    $tracked = @(Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.ps1' | Where-Object { $_.Name -notlike 'test-*' } |
        Where-Object { (Get-Content -LiteralPath $_.FullName -Raw) -match '(?i)[a-z]:\\[a-z]' })
    Expect 'no tool script holds a drive-letter path (rule 8: never a path in a tracked file)' $tracked.Count 0

    [System.IO.File]::WriteAllText((Join-Path $upstream 'a.kt'), 'v1')
    [System.IO.File]::WriteAllText((Join-Path $here 'a.kt'), 'v1')
    Expect 'record exits 0' (Invoke-Tool 'record-port.ps1' @{ Source = 'a.kt'; Destination = 'a.kt' }) 0
    Expect 'fresh row' (Get-OnlyState) 'in step'

    [System.IO.File]::WriteAllText((Join-Path $upstream 'a.kt'), 'v2')
    Expect 'changed source' (Get-OnlyState) 'DRIFT'
    Expect 'DRIFT exits 1' (Invoke-Tool 'check-drift.ps1' @{}) 1

    Expect 'decide exits 0' (Invoke-Tool 'record-port.ps1' @{ Source = 'a.kt'; Destination = 'a.kt'; Decide = $true; Note = 'not needed' }) 0
    Expect 'decision covers this version' (Get-OnlyState) 'decided'
    Expect 'decided exits 0' (Invoke-Tool 'check-drift.ps1' @{}) 0

    [System.IO.File]::WriteAllText((Join-Path $upstream 'a.kt'), 'v3')
    Expect 'next change is drift again' (Get-OnlyState) 'DRIFT'

    Expect 'refresh exits 0' (Invoke-Tool 'record-port.ps1' @{ Source = 'a.kt'; Destination = 'a.kt'; Refresh = $true }) 0
    Expect 'carried row' (Get-OnlyState) 'in step'
    Expect 'carriedOn is set' ([bool]((Read-LedgerRows $ledger)[0]).ContainsKey('carriedOn')) $true

    Remove-Item -LiteralPath (Join-Path $upstream 'a.kt')
    Expect 'removed source' (Get-OnlyState) 'SOURCE GONE'
    [System.IO.File]::WriteAllText((Join-Path $upstream 'a.kt'), 'v3')
    Remove-Item -LiteralPath (Join-Path $here 'a.kt')
    Expect 'removed destination' (Get-OnlyState) 'NO DEST'

    Expect 'escaping path is refused with 2' (Invoke-Tool 'record-port.ps1' @{ Source = '../x.kt'; Destination = 'a.kt' }) 2
    Set-Content -LiteralPath $ledger -Value 'not json'
    Expect 'malformed ledger exits 2' (Invoke-Tool 'check-drift.ps1' @{}) 2
}
finally {
    if ($base.StartsWith($scratch) -and (Test-Path -LiteralPath $base)) { Remove-Item -LiteralPath $base -Recurse -Force }
}

if ($failures -eq 0) { Write-Host 'port-ledger self-test: all expectations held.'; exit 0 }
Write-Host "port-ledger self-test: $failures expectation(s) failed." -ForegroundColor Red
exit 1
