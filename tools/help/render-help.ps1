#requires -Version 7.0
<#
.SYNOPSIS
    Renders the help pages of DeviceInfo (S0024, CONTEXT-HELP) from one source into the app's assets and the site.

.DESCRIPTION
    Sources (the only files edited by hand):
      phone/src/main/assets/help/help-map.json   the help map: one row per surface (rule 17); it ships with the app
      tools/help/source/common.json              the words every page shares, en/ru/uk in one file
      tools/help/source/<help id>.json           one page: its elements, order steps and en/ru/uk text in one file
      tools/help/vendor/help.css                 the contract's reference layer, byte for byte (see PROVENANCE.txt)
      site/assets/sza-kit.css                    the family kit, byte for byte (see site/assets/PROVENANCE.txt)
      <module>/src/main/res/values*/strings*.xml the UI strings: an element named by `nameRef` takes its name from
                                                 here, so a renamed button is renamed in its help by the same edit (rule 13)

    Render targets, never edited by hand (invariant 16), the same bytes in both places (rule 12):
      phone/src/main/assets/help/<locale>/<help id>.html and index.html, help.css, sza-kit.css
      site/help/<locale>/<help id>.html and index.html, help.css, sza-kit.css
      The site address of the index is https://serzhyale.github.io/DeviceInfo_Android/help/<locale>/ (rule 15, 0.2 item F).

    Before it renders, the script refuses sources that cannot give three equivalent pages: a missing locale, an
    element without its five texts, more than seven order steps, an unknown {element} token, an unresolved UI string,
    the character sequence of three dots or a typographic long dash.

.PARAMETER Check
    Render in memory and compare with the committed files. Writes nothing; also reports files the generator does
    not own inside the output directories.

.PARAMETER Root
    Repository root. Defaults to two levels above this script.

.NOTES
    Exit codes: 0 written, or (with -Check) current; 1 a file is out of date or the sources are refused;
    2 the tool could not run (a missing file, an unreadable source).
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [switch] $Check,
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'
trap { Write-Host "render-help: could not run: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

. (Join-Path $PSScriptRoot '_help.ps1')

$result = Get-HelpExpectedFiles -Root $Root
if ($result.Problems.Count -gt 0) {
    foreach ($problem in $result.Problems) { Write-Host "refused: $problem" -ForegroundColor Red }
    Write-Host "render-help: FAIL ($($result.Problems.Count) source problem(s))"
    exit 1
}
$files = $result.Files

if (-not $Check) {
    foreach ($relative in $files.Keys) {
        $path = Join-Path $Root $relative
        $dir = Split-Path -Parent $path
        if (-not (Test-Path -LiteralPath $dir)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
        [System.IO.File]::WriteAllBytes($path, $files[$relative])
    }
    Write-Host "render-help: PASS ($($files.Count) files written)"
    exit 0
}

$stale = [System.Collections.Generic.List[string]]::new()
foreach ($relative in $files.Keys) {
    $path = Join-Path $Root $relative
    if (-not (Test-Path -LiteralPath $path)) { $stale.Add("missing: $relative"); continue }
    $actual = [System.IO.File]::ReadAllBytes($path)
    $expected = $files[$relative]
    if (-not [System.Linq.Enumerable]::SequenceEqual([byte[]]$actual, [byte[]]$expected)) { $stale.Add("out of date: $relative") }
}
foreach ($outRoot in $script:HelpOutputRoots) {
    $dir = Join-Path $Root $outRoot
    if (-not (Test-Path -LiteralPath $dir)) { continue }
    foreach ($file in (Get-ChildItem -LiteralPath $dir -File -Recurse)) {
        $relative = $file.FullName.Substring($Root.TrimEnd('\', '/').Length + 1).Replace('\', '/')
        if ($relative -eq $script:HelpMapRelative) { continue }
        if (-not $files.Contains($relative)) { $stale.Add("not owned by the generator: $relative") }
    }
}
if ($stale.Count -gt 0) {
    foreach ($line in $stale) { Write-Host $line -ForegroundColor Red }
    Write-Host "render-help: FAIL ($($stale.Count) file(s) differ from their sources; run tools/help/render-help.ps1)"
    exit 1
}
Write-Host "render-help: PASS ($($files.Count) files current)"
exit 0
