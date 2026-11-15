#requires -Version 7.0
<#
.SYNOPSIS
    Self-test of tools/store/render-store-assets.ps1 -Check (S0036). Writes only under the operating system's scratch
    folder; the committed files are read and their write times are checked to be unchanged.

.DESCRIPTION
    Expectations:
    1 the committed tree is current: exit 0 and the PASS verdict is the last line;
    2 one pixel of a copy is changed: exit 1, the feature graphic is named as differing, one of four failed;
    3 a copy without one target: exit 1, the target is named as missing;
    4 a copy whose target is not a PNG: exit 1, the target is named as not decodable;
    5 the committed targets keep their write times through the four runs.
    The four runs go in one parallel batch.

    Exit codes: 0 every expectation held; 1 an expectation failed.
#>
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$gen = Join-Path $PSScriptRoot 'render-store-assets.ps1'
$pwshExe = (Get-Process -Id $PID).Path
$targets = @(
    'docs\play\icon-512.png',
    'docs\play\feature-graphic-1024x500.png',
    'site\assets\social-card-1200x630.png',
    'site\assets\icon-512.png'
)
$feature = 'docs\play\feature-graphic-1024x500.png'
$work = Join-Path ([System.IO.Path]::GetTempPath()) ('deviceinfo-store-selftest-' + [guid]::NewGuid().ToString('N'))
$results = [System.Collections.Generic.List[object]]::new()
$code = 0

function Add-Expectation {
    param([string]$Label, [bool]$Held, [string]$Actual)
    $results.Add([pscustomobject]@{ Label = $Label; Held = $Held; Actual = $Actual })
}

function Get-WriteTimes {
    param([string]$Root)
    (@($targets | ForEach-Object { (Get-Item -LiteralPath (Join-Path $Root $_)).LastWriteTimeUtc.Ticks }) -join ',')
}

# Writes a copy of the feature graphic with one pixel changed at the corner (background); the other pixels are copied.
# The source is read through a memory stream: GDI+ keeps a file opened by Bitmap(path) for the bitmap's life, and a
# save over that same path then fails with a generic GDI+ error.
function Write-AlteredFeature {
    param([string]$Path)
    $stream = [System.IO.MemoryStream]::new([System.IO.File]::ReadAllBytes($Path))
    try {
        $src = [System.Drawing.Bitmap]::new($stream)
        try {
            $copy = $src.Clone([System.Drawing.Rectangle]::new(0, 0, $src.Width, $src.Height), [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        }
        finally { $src.Dispose() }
    }
    finally { $stream.Dispose() }
    try {
        $copy.SetPixel(0, 0, [System.Drawing.Color]::Red)
        $copy.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally { $copy.Dispose() }
}

try {
    # Copies of the committed targets for the cases that alter them.
    foreach ($name in 'altered', 'missing', 'corrupt') {
        foreach ($target in $targets) {
            $dst = Join-Path $work (Join-Path $name $target)
            New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
            Copy-Item -LiteralPath (Join-Path $repo $target) -Destination $dst
        }
    }
    $altered = Join-Path $work 'altered'
    $missing = Join-Path $work 'missing'
    $corrupt = Join-Path $work 'corrupt'

    Write-AlteredFeature -Path (Join-Path $altered $feature)
    Remove-Item -LiteralPath (Join-Path $missing $feature) -Force
    [System.IO.File]::WriteAllText((Join-Path $corrupt $feature), 'not a png')

    $stampBefore = Get-WriteTimes $repo

    $cases = @(
        [pscustomobject]@{ Name = 'committed'; Root = $repo },
        [pscustomobject]@{ Name = 'altered'; Root = $altered },
        [pscustomobject]@{ Name = 'missing'; Root = $missing },
        [pscustomobject]@{ Name = 'corrupt'; Root = $corrupt }
    )
    $runs = @($cases | ForEach-Object -Parallel {
        $text = & $using:pwshExe -NoProfile -File $using:gen -Check -Root $_.Root 2>&1 | ForEach-Object { "$_" }
        [pscustomobject]@{ Name = $_.Name; Code = $LASTEXITCODE; Text = @($text) }
    } -ThrottleLimit 4)

    $stampAfter = Get-WriteTimes $repo
    $byName = @{}
    foreach ($run in $runs) { $byName[$run.Name] = $run }

    $c = $byName['committed']
    Add-Expectation '1 the committed tree is current: exit 0, the PASS verdict last' `
        ($c.Code -eq 0 -and $c.Text[-1] -match '^store-graphics-check: PASS \(4 targets') `
        "exit $($c.Code), last line: $($c.Text[-1])"

    $a = $byName['altered']
    Add-Expectation '2 one altered pixel: exit 1, the feature graphic named as differing, 1 of 4' `
        ($a.Code -eq 1 -and ($a.Text -match 'feature-graphic-1024x500\.png differs from its render').Count -eq 1 -and $a.Text[-1] -match '^store-graphics-check: FAIL \(1 of 4 ') `
        "exit $($a.Code), last line: $($a.Text[-1])"

    $m = $byName['missing']
    Add-Expectation '3 one target missing: exit 1, the feature graphic named as missing, 1 of 4' `
        ($m.Code -eq 1 -and ($m.Text -match 'feature-graphic-1024x500\.png is missing').Count -eq 1 -and $m.Text[-1] -match '^store-graphics-check: FAIL \(1 of 4 ') `
        "exit $($m.Code), last line: $($m.Text[-1])"

    $k = $byName['corrupt']
    Add-Expectation '4 one target not a PNG: exit 1, the feature graphic named as not decodable, 1 of 4' `
        ($k.Code -eq 1 -and ($k.Text -match 'feature-graphic-1024x500\.png cannot be decoded').Count -eq 1 -and $k.Text[-1] -match '^store-graphics-check: FAIL \(1 of 4 ') `
        "exit $($k.Code), last line: $($k.Text[-1])"

    Add-Expectation '5 the committed targets keep their write times through the runs' `
        ($stampBefore -eq $stampAfter) `
        'a write time of a committed target changed'
}
catch {
    Add-Expectation 'the self-test ran to the end' $false $_.Exception.Message
}

foreach ($result in $results) {
    $mark = if ($result.Held) { 'PASS' } else { 'FAIL' }
    Write-Host "$mark $($result.Label)"
    if (-not $result.Held) { Write-Host "     actual: $($result.Actual)" }
}
$failed = @($results | Where-Object { -not $_.Held }).Count
$passed = $results.Count - $failed
if ($failed -eq 0) {
    Write-Host "store-graphics-check self-test: $passed PASS, 0 FAIL"
    Write-Host 'store-graphics-check self-test: all expectations held.'
}
else {
    Write-Host "store-graphics-check self-test: $passed PASS, $failed FAIL"
    $code = 1
}

# The scratch folder is removed after the verdict has been written; a folder that cannot be removed is named and does
# not change the verdict.
if (Test-Path -LiteralPath $work) {
    try { Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction Stop }
    catch { Write-Host "note: the scratch folder $work was left behind: $($_.Exception.Message)" }
}
exit $code
