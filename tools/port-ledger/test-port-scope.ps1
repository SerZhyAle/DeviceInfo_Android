#requires -Version 7.0
<#
.SYNOPSIS
    Self-test of the scope check (check-scope.ps1) and the decision recorder (record-decision.ps1) on a throw-away
    tree. Touches neither this repository's ledger, scope and decisions nor the upstream.

.DESCRIPTION
    A scope check that reports nothing passes as quietly as a clean one, so this proves it can fail. On a throw-away
    upstream, destination, ledger, scope and decisions it walks every state the check reports: a scope that sees
    nothing (exit 2, never a clean 0), an in-scope file with no ledger row (NEW SOURCE, exit 1), ported, decided,
    STALE DECISION after the upstream file changed, re-pinned, excluded by a plain glob and by a glob with `**`, a
    ledger row that wins over a decision, a string key unported, decided, and stale after its value changed, and the
    exit code 2 (missing scope, malformed decisions, unknown string key, both or neither of -Source and -StringKey).
    It also pins the glob engine (`*`, `?`, `**/`, a trailing `/**`, case) the scope relies on.

    The tools run in this process (no `pwsh` spawn per case), which keeps the whole run near one second. Run it after
    editing check-scope.ps1, record-decision.ps1, _scope.ps1 or docs/port-scope.json's shape.

    Exit code: 0 every expectation held; 1 at least one failed.
#>
[CmdletBinding(PositionalBinding = $false)]
param()

. (Join-Path $PSScriptRoot '_ledger.ps1')
. (Join-Path $PSScriptRoot '_scope.ps1')
$ErrorActionPreference = 'Stop'

$scratch = Join-Path $script:RepoRoot 'temp\S0018'
$base = Join-Path $scratch ('scope-test-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$upstream = Join-Path $base 'up'
$here = Join-Path $base 'here'
$ledger = Join-Path $base 'ledger.jsonl'
$scope = Join-Path $base 'scope.json'
$decisions = Join-Path $base 'decisions.jsonl'
New-Item -ItemType Directory -Path $upstream, $here -Force | Out-Null
$failures = 0

function Expect([string] $What, $Actual, $Expected) {
    if ($Actual -eq $Expected) { Write-Host "  PASS  $What (expected: $Expected | actual: $Actual)" }
    else { $script:failures++; Write-Host "  FAIL  $What (expected: $Expected | actual: $Actual)" -ForegroundColor Red }
}
# The scripts end with `exit N`; run with `&` in this process that ends the script, not this one, and sets $LASTEXITCODE.
function Invoke-ScopeCheck { $null = & (Join-Path $PSScriptRoot 'check-scope.ps1') -SourceRoot $upstream -DestinationRoot $here -Ledger $ledger -Scope $scope -Decisions $decisions 6>&1 2>&1; return $LASTEXITCODE }
function Invoke-DecisionTool([hashtable] $ToolArgs) { $null = & (Join-Path $PSScriptRoot 'record-decision.ps1') -SourceRoot $upstream -Scope $scope -Decisions $decisions @ToolArgs 6>&1 2>&1; return $LASTEXITCODE }
function Invoke-PortTool([string] $File) { $null = & (Join-Path $PSScriptRoot 'record-port.ps1') -Source $File -Destination $File -SourceRoot $upstream -DestinationRoot $here -Ledger $ledger 6>&1 2>&1; return $LASTEXITCODE }
function Write-Text([string] $Root, [string] $Relative, [string] $Text) {
    $path = Join-Path $Root $Relative
    New-Item -ItemType Directory -Force (Split-Path -Parent $path) | Out-Null
    [System.IO.File]::WriteAllText($path, $Text)
}

try {
    # --- the glob engine ---
    function Matches([string] $Glob, [string] $Path) { (ConvertTo-GlobRegex $Glob).IsMatch($Path) }
    Expect '* stays inside a segment' (Matches 'a/*.kt' 'a/x.kt') $true
    Expect '* does not cross a slash' (Matches 'a/*.kt' 'a/b/x.kt') $false
    Expect '? is one character' (Matches 'a/?.kt' 'a/xy.kt') $false
    Expect '**/ spans several segments' (Matches 'a/**/x.kt' 'a/b/c/x.kt') $true
    Expect '**/ also spans none' (Matches 'a/**/x.kt' 'a/x.kt') $true
    Expect 'trailing /** is everything below' (Matches 'a/**' 'a/b/c.kt') $true
    Expect 'a dot is literal' (Matches 'a/x.kt' 'a/xykt') $false
    Expect 'matching is case-sensitive' (Matches 'a/*System*.kt' 'a/xsystem.kt') $false
    Expect 'walk root stops at the first wildcard segment' (Get-GlobWalkRoot 'a/b/*/c/*.kt') 'a/b'
    Expect 'walk root of a literal file is its directory' (Get-GlobWalkRoot 'a/b/x.kt') 'a/b'

    # --- the scope check ---
    Write-Text $here 'unrelated.txt' 'x'
    [System.IO.File]::WriteAllText($scope, '{"include":["b.kt","c.kt","d2.kt","gen/**"],"exclude":[{"glob":"d2.kt","reason":"excluded by the self-test"},{"glob":"gen/**","reason":"generated"}],"strings":{"scan":["res/values/strings.xml"],"prefixes":["sysinfo_"],"destinationScan":["res/values/strings.xml"]}}')
    Expect 'a scope that sees nothing exits 2, never a clean 0' (Invoke-ScopeCheck) 2

    Write-Text $upstream 'res/values/strings.xml' '<resources><string name="sysinfo_alpha">alpha v1</string></resources>'
    Write-Text $here 'res/values/strings.xml' '<resources><string name="sysinfo_alpha">alpha v1</string></resources>'
    Write-Text $upstream 'b.kt' 'b'
    Expect 'in-scope file with no ledger row exits 1 (NEW SOURCE)' (Invoke-ScopeCheck) 1
    Write-Text $here 'b.kt' 'b'
    Expect 'record-port exits 0' (Invoke-PortTool 'b.kt') 0
    Expect 'ported file and ported string exit 0' (Invoke-ScopeCheck) 0

    Write-Text $upstream 'c.kt' 'c1'
    Expect 'a second new file exits 1' (Invoke-ScopeCheck) 1
    Expect 'file decision exits 0' (Invoke-DecisionTool @{ Source = 'c.kt'; Note = 'deliberately not ported' }) 0
    Expect 'decided file exits 0' (Invoke-ScopeCheck) 0
    Write-Text $upstream 'c.kt' 'c2'
    Expect 'file changed after its decision exits 1 (STALE DECISION)' (Invoke-ScopeCheck) 1
    Expect 're-pin exits 0' (Invoke-DecisionTool @{ Source = 'c.kt'; Note = 'still not ported' }) 0
    Expect 're-pinned file exits 0' (Invoke-ScopeCheck) 0
    Write-Text $here 'c.kt' 'c2'
    Expect 'record-port of a decided file exits 0' (Invoke-PortTool 'c.kt') 0
    Write-Text $upstream 'c.kt' 'c3'
    Expect 'a ledger row wins: the stale decision is ignored, the row is check-drift''s business' (Invoke-ScopeCheck) 0

    Write-Text $upstream 'd2.kt' 'd2'
    Write-Text $upstream 'gen/x.kt' 'x'
    Expect 'files covered by an exclusion exit 0' (Invoke-ScopeCheck) 0

    Write-Text $upstream 'res/values/strings.xml' '<resources><string name="sysinfo_alpha">alpha v1</string><string name="sysinfo_beta">beta v1</string><string name="other_gamma">g</string></resources>'
    Expect 'unported string key exits 1 (NEW SOURCE)' (Invoke-ScopeCheck) 1
    Expect 'string decision exits 0' (Invoke-DecisionTool @{ StringKey = 'sysinfo_beta'; Note = 'ported under another key' }) 0
    Expect 'decided string key exits 0' (Invoke-ScopeCheck) 0
    Write-Text $upstream 'res/values/strings.xml' '<resources><string name="sysinfo_alpha">alpha v1</string><string name="sysinfo_beta">beta v2</string><string name="other_gamma">g</string></resources>'
    Expect 'string value changed after its decision exits 1 (STALE DECISION)' (Invoke-ScopeCheck) 1
    Write-Text $here 'res/values/strings.xml' '<resources><string name="sysinfo_alpha">alpha v1</string><string name="sysinfo_beta">b</string></resources>'
    Expect 'a key declared here is ported, whatever its decision says' (Invoke-ScopeCheck) 0

    # --- refusals and exit code 2 ---
    Expect 'unknown string key is refused with 2' (Invoke-DecisionTool @{ StringKey = 'sysinfo_nope'; Note = 'x' }) 2
    Expect 'a decision for a missing file is refused with 2' (Invoke-DecisionTool @{ Source = 'nope.kt'; Note = 'x' }) 2
    Expect 'an escaping path is refused with 2' (Invoke-DecisionTool @{ Source = '../x.kt'; Note = 'x' }) 2
    Expect '-Source and -StringKey together are refused with 2' (Invoke-DecisionTool @{ Source = 'c.kt'; StringKey = 'sysinfo_alpha'; Note = 'x' }) 2
    Expect 'neither -Source nor -StringKey is refused with 2' (Invoke-DecisionTool @{ Note = 'x' }) 2
    $realScope = $scope
    $scope = Join-Path $base 'absent.json'
    Expect 'a missing scope file exits 2' (Invoke-ScopeCheck) 2
    $scope = Join-Path $base 'no-reason.json'
    [System.IO.File]::WriteAllText($scope, '{"include":["b.kt"],"exclude":[{"glob":"c.kt","reason":""}]}')
    Expect 'an exclusion without a reason exits 2 (PORT-LEDGER rule 5)' (Invoke-ScopeCheck) 2
    $scope = $realScope
    Set-Content -LiteralPath $decisions -Value 'not json'
    Expect 'a malformed decisions file exits 2' (Invoke-ScopeCheck) 2
}
finally {
    if ($base.StartsWith($scratch) -and (Test-Path -LiteralPath $base)) { Remove-Item -LiteralPath $base -Recurse -Force }
}

if ($failures -eq 0) { Write-Host 'port-scope self-test: all expectations held.'; exit 0 }
Write-Host "port-scope self-test: $failures expectation(s) failed." -ForegroundColor Red
exit 1
