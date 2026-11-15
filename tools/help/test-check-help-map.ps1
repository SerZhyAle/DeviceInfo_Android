#requires -Version 7.0
<#
.SYNOPSIS
    Self-test of tools/help/check-help-map.ps1 and tools/help/render-help.ps1 (S0024).

.DESCRIPTION
    A gate that inspects nothing passes as quietly as a clean one, so this proves that the gate can fail: it copies the
    pieces of the repository the gate reads into a throw-away tree under temp/S0024, checks that the copy passes, then
    breaks many independent things at once, runs the gate a single time and expects it to name every one of them (each
    expectation is a separate pattern of the one run's output). One more run, with the render check, proves that
    a source edited without a regeneration is caught. The repository itself is never written.

    Exit code: 0 every expectation held; 1 at least one did not; 2 the test could not run.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'
trap { Write-Host "test-check-help-map: could not run: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

$gate = Join-Path $PSScriptRoot 'check-help-map.ps1'
$tree = Join-Path $Root 'temp/S0024/selftest'
if (Test-Path -LiteralPath $tree) { Remove-Item -LiteralPath $tree -Recurse -Force }
[void](New-Item -ItemType Directory -Path $tree -Force)

foreach ($relative in @('phone/src', 'wear/src', 'site/help', 'tools/help')) {
    $target = Join-Path $tree $relative
    [void](New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force)
    Copy-Item -LiteralPath (Join-Path $Root $relative) -Destination $target -Recurse
}
[void](New-Item -ItemType Directory -Path (Join-Path $tree 'site/assets') -Force)
foreach ($relative in @('site/assets/sza-kit.css', 'site/index.html', 'site/privacy.html', 'site/privacy-ru.html', 'site/privacy-uk.html', 'site/sitemap.xml', 'site/robots.txt')) {
    Copy-Item -LiteralPath (Join-Path $Root $relative) -Destination (Join-Path $tree $relative)
}
foreach ($loc in 'ru', 'uk') {
    [void](New-Item -ItemType Directory -Path (Join-Path $tree "site/$loc") -Force)
    Copy-Item -LiteralPath (Join-Path $Root "site/$loc/index.html") -Destination (Join-Path $tree "site/$loc/index.html")
}

$utf8 = [System.Text.UTF8Encoding]::new($false)
$failures = 0
$checked = 0

function Invoke-Gate {
    param([switch] $WithRender)
    $arguments = @{ Root = $tree }
    if (-not $WithRender) { $arguments.SkipRender = $true }
    $output = (& $gate @arguments *>&1 | Out-String)
    @{ Code = $LASTEXITCODE; Output = $output }
}

function Assert-Gate {
    param([string] $Name, [int] $ExpectedCode, [string] $Pattern, $Run)
    $script:checked++
    $codeOk = $Run.Code -eq $ExpectedCode
    $patternOk = [string]::IsNullOrEmpty($Pattern) -or $Run.Output -match $Pattern
    if ($codeOk -and $patternOk) { Write-Host "  ok   $Name"; return }
    $script:failures++
    Write-Host "  FAIL $Name (exit $($Run.Code), expected $ExpectedCode; pattern '$Pattern')" -ForegroundColor Red
}

# One independent defect: the file it breaks, how, and what the gate must say. A mutation that returns $null deletes the file.
$cases = [System.Collections.Generic.List[hashtable]]::new()
function Add-Case {
    param([string] $Name, [string] $File, [scriptblock] $Mutate, [string] $Pattern)
    $cases.Add(@{ Name = $Name; File = $File; Mutate = $Mutate; Pattern = $Pattern })
}

$mapFile = 'phone/src/main/assets/help/help-map.json'
$appEn = 'phone/src/main/assets/help/en/system-info.html'
$windowManager = 'phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/helpers/SystemInfoWindowManager.kt'
$activityFile = 'phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/SystemInfoActivity.kt'
$screenFile = 'wear/src/main/kotlin/com/sza/deviceinfo/wear/ui/apps/systeminfo/SystemInfoScreen.kt'

# surfaces against the map
Add-Case 'a surface with no row (the help viewer row is gone)' $mapFile {
    param($t) $t -replace '(?s)\{\s*"id": "help-viewer".*?\},\s*(?=\{\s*"id": "notifications-prompt")', ''
} 'surface with no row: activity phone\|\.ui\.help\.HelpActivity'
Add-Case 'a row with no surface (an activity no manifest declares)' $mapFile {
    param($t) $t -replace '"source": "activity:\.MainActivity"', '"source": "activity:.Ghost"'
} 'row with no surface'
Add-Case 'a none row with no reason' $mapFile {
    param($t) $t.Replace('"reason": "A launcher trampoline: it starts System information and finishes at once, so it shows nothing to explain."', '"reason": ""')
} "surface 'launcher' is 'none' with no reason"
Add-Case 'a dialog the map does not count' 'phone/src/main/kotlin/com/sza/deviceinfo/ui/help/HelpLauncher.kt' {
    param($t) $t.Replace('object HelpLauncher {', 'object HelpLauncher {' + [Environment]::NewLine + '    private fun extra(c: android.content.Context) = androidx.appcompat.app.AlertDialog.Builder(c)')
} 'dialogs of phone/src/main/kotlin/com/sza/deviceinfo/ui/help/HelpLauncher\.kt'
Add-Case 'a UI string the map names does not exist' $mapFile {
    param($t) $t.Replace('"nameRef": "notifications_prompt_title"', '"nameRef": "no_such_string"')
} 'no_such_string'

# pages and links
Add-Case 'a page missing on the site' 'site/help/ru/system-info.html' { param($t) $null } 'page missing: site/help/ru/system-info\.html'
Add-Case 'an address outside an anchor' $appEn {
    param($t) $t.Replace('<h2>Related</h2>', '<h2>Related</h2><p>see https://tracker.invalid/x</p>')
} 'holds an address outside an anchor'
Add-Case 'a link to a file that does not exist' $appEn {
    param($t) $t.Replace('<a href="index.html">Help index</a><span', '<a href="nope.html">Help index</a><span')
} 'links nope\.html, and the file does not exist'
Add-Case 'a link to an anchor that does not exist' $appEn {
    param($t) $t.Replace('href="#groups"', 'href="#no-such-anchor"')
} 'which has no anchor on the page'
Add-Case 'an own-site address with no file behind it' $appEn {
    param($t) $t.Replace('DeviceInfo_Android/privacy.html', 'DeviceInfo_Android/privacy-nope.html')
} 'site/privacy-nope\.html does not exist'
Add-Case 'an address that is not allow-listed' $appEn {
    param($t) $t.Replace('https://github.com/SerZhyAle/DeviceInfo_Android/issues', 'https://elsewhere.invalid/')
} 'neither the support address nor this product'
Add-Case 'the app and the site hold different bytes' $appEn {
    param($t) $t.Replace('</main>', '</main> ')
} 'different bytes for en/system-info\.html'
Add-Case 'a page without the noindex meta' $appEn {
    param($t) $t.Replace('<meta name="robots" content="noindex">', '')
} 'no noindex meta'
Add-Case 'a page that loads a script from outside' $appEn {
    param($t) $t.Replace('</head>', '<script src="x.js"></script></head>')
} 'loads a script'
Add-Case 'a stylesheet that is not one of the two shipped' $appEn {
    param($t) $t.Replace('href="../help.css"', 'href="../other.css"')
} 'not one of the two shipped stylesheets'
Add-Case 'a help page listed in the sitemap' 'site/sitemap.xml' {
    param($t) $t.Replace('</urlset>', '<url><loc>https://x.invalid/help/en/</loc></url></urlset>')
} 'lists a help page'
Add-Case 'a landing page that no longer links down to the help index' 'site/index.html' {
    param($t) $t.Replace('href="help/en/"', 'href="help/xx/"')
} 'does not link down to the help index'
Add-Case 'a robots file that blocks the help' 'site/robots.txt' {
    param($t) $t + 'Disallow: /help/' + [Environment]::NewLine
} 'blocks /help'

# map elements
Add-Case 'a map element that is no element of the page' $mapFile {
    param($t) $t.Replace('{ "id": "search", "view": "systemInfoSearchView" }', '{ "id": "no-anchor", "view": "systemInfoSearchView" }')
} 'is not an element of the page source'
Add-Case 'a map element whose view no layout declares' $mapFile {
    param($t) $t.Replace('"view": "csh_toggleRow"', '"view": "noSuchView"')
} 'no phone layout or menu declares'
Add-Case 'the help button as an element' $mapFile {
    param($t) $t.Replace('"view": "action_system_info_copy"', '"view": "action_help"')
} "help button's own view"

# the controls do something
Add-Case 'an empty Help branch' $windowManager {
    param($t) $t.Replace('R.id.action_help -> HelpLauncher.open(activity, HelpSurfaces.SYSTEM_INFO)', 'R.id.action_help -> { /* later */ }')
} 'an empty Help branch'
Add-Case 'a swallowed F1' $activityFile {
    param($t) $t.Replace('if (event?.repeatCount == 0) HelpLauncher.open(this, HelpSurfaces.SYSTEM_INFO, currentFocus)', '')
} 'a swallowed F1'
Add-Case 'a watch screen that does not show its help row' $screenFile {
    param($t) $t.Replace('                WearHelpEntry()', '                // WearHelpEntry()')
} 'does not show WearHelpEntry'
Add-Case 'a watch help string missing in one locale' 'wear/src/main/res/values-uk/strings_systeminfo.xml' {
    param($t) [regex]::Replace($t, '\s*<string name="system_info_help_text">[^\r\n]*</string>', '')
} 'system_info_help_text'

# sources
Add-Case 'an element with no "next" text' 'tools/help/source/watch-system-info.json' {
    param($t) $t.Replace('"next": "The note stays open until you tap the row again.",', '')
} "has no 'next'"
Add-Case 'the character sequence of three dots' 'tools/help/source/watch-system-info.json' {
    param($t) $t.Replace('"one": "Reads the watch again."', '"one": "Reads the watch again..."')
} 'three dots'

Write-Host 'test-check-help-map: the copy of the tree'
Assert-Gate -Name 'the unchanged copy passes' -ExpectedCode 0 -Pattern 'help-map: PASS' -Run (Invoke-Gate)

function Invoke-Defects {
    param($Cases, [switch] $WithRender)
    $saved = @{}
    try {
        foreach ($case in $Cases) {
            $path = Join-Path $tree $case.File
            if (-not $saved.ContainsKey($path)) { $saved[$path] = [System.IO.File]::ReadAllBytes($path) }
            $text = $utf8.GetString([System.IO.File]::ReadAllBytes($path))
            $changed = & $case.Mutate $text
            if ($null -eq $changed) { Remove-Item -LiteralPath $path; continue }
            if ($changed -ceq $text) { throw "the mutation of '$($case.Name)' changed nothing in $($case.File)" }
            [System.IO.File]::WriteAllBytes($path, $utf8.GetBytes($changed))
        }
        Invoke-Gate -WithRender:$WithRender
    } finally {
        foreach ($path in $saved.Keys) { [System.IO.File]::WriteAllBytes($path, $saved[$path]) }
    }
}

Write-Host "test-check-help-map: $($cases.Count) defects broken at once, one run of the gate"
$run = Invoke-Defects $cases
Assert-Gate -Name 'the gate fails (exit 1) on the broken copy' -ExpectedCode 1 -Pattern 'help-map: FAIL' -Run $run
foreach ($case in $cases) { Assert-Gate -Name $case.Name -ExpectedCode 1 -Pattern $case.Pattern -Run $run }

Write-Host 'test-check-help-map: a source edited without a regeneration'
$stale = @(@{
        Name = 'pages that no longer equal their sources'
        File = 'tools/help/source/watch-system-info.json'
        Mutate = { param($t) $t.Replace('"one": "Читает часы заново."', '"one": "Читает часы заново и сразу."') }
        Pattern = 'out of date: site/help/ru/watch-system-info\.html'
    })
$staleRun = Invoke-Defects $stale -WithRender
Assert-Gate -Name $stale[0].Name -ExpectedCode 1 -Pattern $stale[0].Pattern -Run $staleRun

Remove-Item -LiteralPath $tree -Recurse -Force
if ($failures -gt 0) {
    Write-Host "test-check-help-map: FAIL ($failures of $checked expectations did not hold)"
    exit 1
}
Write-Host "test-check-help-map: PASS ($checked expectations held)"
exit 0
