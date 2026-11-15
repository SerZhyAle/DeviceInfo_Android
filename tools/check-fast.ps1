#requires -Version 7.0
<#
.SYNOPSIS
    Runs the fast-tier gates of this repository (every check of CLAUDE.md section 6 that takes 5 s or less) in one pass.

.DESCRIPTION
    One line per gate (PASS, FAIL or SKIP with its time), the tail of a failing gate's output under it, and one
    verdict line at the end. Each gate runs as its own process and judges itself by its own exit code; this script
    adds no verdict of its own. A gate that cannot run on this machine (no JDK for the three Java source checks) is a
    SKIP and is named in the verdict, never a silent pass.

    Not included, because they are slower than 5 s or change files: the compile check, the unit tests, the builds,
    the self-tests of the check scripts (run after editing the scripts), and the help-screenshot device run.

.PARAMETER Only
    Runs only the gates whose name contains this text (case-insensitive), for example -Only docs.

.PARAMETER List
    Prints the gate names and runs nothing.

.PARAMETER Show
    Prints the whole output of every gate, not only the tail of a failing one.

.EXAMPLE
    pwsh -NoProfile -File tools/check-fast.ps1
    pwsh -NoProfile -File tools/check-fast.ps1 -Only help -Show

.NOTES
    Exit codes: 0 every gate that ran passed (skips are named in the verdict line), 1 a gate failed or its script is
    missing, 2 no gate matched -Only. The last stdout line is the verdict line.
#>
[CmdletBinding()]
param(
    [string]$Only,
    [switch]$List,
    [switch]$Show
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
. (Join-Path $PSScriptRoot 'build\_common.ps1')

$harness = Get-HarnessRoot
$compliance = if ($harness) { Join-Path (Split-Path -Parent (Split-Path -Parent $harness)) 'tools\check-compliance.ps1' } else { $null }
$java = Get-Command java -ErrorAction SilentlyContinue | Select-Object -First 1
$payloadPhone = 'phone/src/main/kotlin/com/sza/deviceinfo/domain/model/WearSystemInfoReportPayload.kt'
$payloadWear = 'wear/src/main/kotlin/com/sza/deviceinfo/wear/data/wear/WearSystemInfoReportPayload.kt'

# Kind 'ps' runs `pwsh -NoProfile -File <File> <Args>`, kind 'java' runs `java <File> <Args>` (single-file source).
$gates = @(
    @{ Name = 'spec-catalog';       Kind = 'ps';   File = 'tools/harness.ps1';                                 Args = @('spec_catalog/validate') }
    @{ Name = 'release-queue';      Kind = 'ps';   File = 'tools/harness.ps1';                                 Args = @('spec_catalog/release-queue', '-Validate') }
    @{ Name = 'canon-compliance';   Kind = 'ps';   File = $compliance;                                         Args = @(); Absolute = $true }
    @{ Name = 'contract-pointers';  Kind = 'ps';   File = 'tools/contracts/check-pointers.ps1';                Args = @() }
    @{ Name = 'port-drift';         Kind = 'ps';   File = 'tools/port-ledger/check-drift.ps1';                 Args = @() }
    @{ Name = 'port-scope';         Kind = 'ps';   File = 'tools/port-ledger/check-scope.ps1';                 Args = @() }
    @{ Name = 'local-divergence';   Kind = 'ps';   File = 'tools/port-ledger/check-local-divergence.ps1';      Args = @('-RequireClassified') }
    @{ Name = 'surfaces';           Kind = 'ps';   File = 'tools/docs/check-surfaces.ps1';                     Args = @() }
    @{ Name = 'docs';               Kind = 'ps';   File = 'tools/docs/check-docs.ps1';                         Args = @() }
    @{ Name = 'version-parity';     Kind = 'ps';   File = 'tools/release/check-version-parity.ps1';            Args = @() }
    @{ Name = 'store-graphics';     Kind = 'ps';   File = 'tools/store/render-store-assets.ps1';               Args = @('-Check') }
    @{ Name = 'landing';            Kind = 'ps';   File = 'tools/site/render-landing.ps1';                     Args = @('-Check') }
    @{ Name = 'parity-matrix';      Kind = 'ps';   File = 'tools/parity/check-matrix.ps1';                     Args = @() }
    @{ Name = 'identity-tokens';    Kind = 'ps';   File = 'tools/design/check-tokens.ps1';                     Args = @() }
    @{ Name = 'help-map';           Kind = 'ps';   File = 'tools/help/check-help-map.ps1';                     Args = @() }
    @{ Name = 'help-render';        Kind = 'ps';   File = 'tools/help/render-help.ps1';                        Args = @('-Check') }
    @{ Name = 'help-captures';      Kind = 'ps';   File = 'tools/help/check-help-captures.ps1';                Args = @() }
    @{ Name = 'payload-parity';     Kind = 'java'; File = 'phone/src/test/java/com/sza/deviceinfo/service/WearPayloadParity.java'; Args = @($payloadPhone, $payloadWear) }
    @{ Name = 'phone-ui-sizing';    Kind = 'java'; File = 'phone/src/test/java/com/sza/deviceinfo/ui/PhoneUiSizingResources.java';  Args = @() }
    @{ Name = 'wear-ui-sizing';     Kind = 'java'; File = 'wear/src/test/java/com/sza/deviceinfo/wear/ui/WearUiSizingResources.java'; Args = @() }
)

if ($Only) { $gates = @($gates | Where-Object { $_.Name -like "*$Only*" }) }
if ($gates.Count -eq 0) {
    Write-Host "check-fast: no gate matches '$Only'."
    exit 2
}
if ($List) {
    $gates | ForEach-Object { Write-Host $_.Name }
    exit 0
}

$total = [Diagnostics.Stopwatch]::StartNew()
$failed = New-Object System.Collections.Generic.List[string]
$skipped = New-Object System.Collections.Generic.List[string]
$passed = 0
$index = 0

Push-Location -LiteralPath $root
try {
    foreach ($gate in $gates) {
        $index++
        $label = '[{0,2}/{1}] {2,-18}' -f $index, $gates.Count, $gate.Name
        $file = if ($gate.Absolute) { $gate.File } else { Join-Path $root $gate.File }

        if ($gate.Kind -eq 'java' -and -not $java) {
            Write-Host "$label SKIP  no java on PATH (JDK 17 or newer)" -ForegroundColor Yellow
            $skipped.Add($gate.Name)
            continue
        }
        if (-not $file -or -not (Test-Path -LiteralPath $file -PathType Leaf)) {
            Write-Host "$label FAIL  script not found: $($gate.File)" -ForegroundColor Red
            $failed.Add($gate.Name)
            continue
        }

        $watch = [Diagnostics.Stopwatch]::StartNew()
        $output = if ($gate.Kind -eq 'java') { & $java.Source $file @($gate.Args) 2>&1 | Out-String }
                  else { & pwsh -NoProfile -File $file @($gate.Args) 2>&1 | Out-String }
        $code = $LASTEXITCODE
        $watch.Stop()
        $time = '{0:N1} s' -f $watch.Elapsed.TotalSeconds

        if ($code -eq 0) {
            $passed++
            Write-Host "$label PASS  $time" -ForegroundColor Green
            if ($Show) { Write-Host $output.TrimEnd() -ForegroundColor DarkGray }
        }
        else {
            $failed.Add($gate.Name)
            Write-Host "$label FAIL  $time (exit $code)" -ForegroundColor Red
            $lines = @($output -split "`r?`n" | Where-Object { $_.Trim() })
            $shown = if ($Show) { $lines } else { @($lines | Select-Object -Last 15) }
            foreach ($line in $shown) { Write-Host "         $line" -ForegroundColor DarkGray }
        }
    }
}
finally {
    Pop-Location
}

$seconds = '{0:N1}' -f $total.Elapsed.TotalSeconds
$skipNote = if ($skipped.Count -gt 0) { ", $($skipped.Count) skipped ($($skipped -join ', '))" } else { '' }
if ($failed.Count -gt 0) {
    Write-Host "check-fast: FAIL - $($failed.Count) of $($gates.Count) gates failed ($($failed -join ', ')), $passed passed$skipNote, $seconds s"
    exit 1
}
$verdict = if ($skipped.Count -gt 0) { 'PASS WITH SKIPS' } else { 'PASS' }
Write-Host "check-fast: $verdict - $passed of $($gates.Count) gates passed$skipNote, $seconds s"
exit 0
