#requires -Version 7.0
<#
.SYNOPSIS
    The screenshot generator of the help pages (S0032, CONTEXT-HELP rule 8 item 3 and rule 14): takes the real build on a
    device or an emulator, per page, per locale and per theme, and records the pictures and where each part of the screen is.

.DESCRIPTION
    For every page of the help map and every locale it installs the package, clears the app's data, sets the app's language
    and the night mode, starts the app, brings the screen into the state of the recipe, then takes a screenshot and a UI
    dump (`uiautomator dump`). The pin of each element comes from the bounds of its node in the dump, never from a person's
    pointer: the phone locators are the `view` ids of the help map, the watch locators are in capture-recipes.ps1's JSON.
    A part with no visible node is recorded as absent (CONTEXT-HELP 0.2 item C).

    Each capture proves itself before it is kept (rule 14, a screenshot in another language is a defect):
      - the dump must show the text of the page's `languageProof` strings in the asked locale;
      - the mean brightness of the image must match the theme asked for;
      - the phone is not a watch and the watch is one, by `ro.build.characteristics`;
      - with two themes, the pins of the two must agree (a layout does not move with the theme).
    Nothing is written unless every requested capture passes; then the images and the records land in tools/help/captures/
    (images scaled to at most scaleMaxWidth pixels of width) and `render-help.ps1` turns them into the pages.

    Demo content: the clean state of the system image (app data cleared, no account, nothing else changed but the recipe's
    steps). The build sentinel version is never recorded; -ProductVersion carries the version name of the pin.

    A device run: release tier, not between releases. It needs the packages built (`.\gradlew.bat :phone:assembleDebug
    :wear:assembleDebug`), a phone or emulator on API 33 or newer for the per-app language, and a Wear OS device for the watch.

.PARAMETER PhoneSerial
    adb serial of the phone or emulator (`adb devices`). Required for a phone page.

.PARAMETER WearSerial
    adb serial of the Wear OS device or emulator. Required for a watch page.

.PARAMETER ProductVersion
    The version name the pages are captured against (the pin's). Required while the installed build carries the sentinel.

.PARAMETER Page
    Only these help ids (default: every page). A partial run merges its records into the committed ones.

.PARAMETER Locale
    Only these locales (default: en, ru, uk).

.PARAMETER Adb
    Path of adb. Default: platform-tools of the sdk.dir in local.properties.

.PARAMETER NoInstall
    Do not install the packages; the ones on the device are captured.

.PARAMETER DryRun
    Touch no device: print what would be captured, the locators, the packages and the input hashes, and exit.

.NOTES
    Exit codes: 0 captured (or a dry run that holds together); 1 the run was refused or a capture failed its own proof
    (a missing serial, a device that does not match the page, an app language that did not take, a wrong theme, a recipe
    that is incomplete), and nothing was written; 2 the tool could not run (a missing file, an unreadable source).
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [string] $PhoneSerial = '',
    [string] $WearSerial = '',
    [string] $ProductVersion = '',
    [string[]] $Page = @(),
    [string[]] $Locale = @(),
    [string] $Adb = '',
    [switch] $NoInstall,
    [switch] $DryRun
)

$ErrorActionPreference = 'Stop'
$script:failed = $false
trap {
    Write-Host "capture-help: could not run: $($_.Exception.Message)" -ForegroundColor Red
    exit 2
}

. (Join-Path $PSScriptRoot '_help.ps1')

$map = Get-HelpMap -Root $Root
$pages = Get-HelpPageSources -Root $Root -Map $map
$recipes = Read-CaptureRecipes -Root $Root
$locales = if ($Locale.Count -gt 0) { @($Locale) } else { @($script:HelpLocales) }
foreach ($l in $locales) { if ($l -notin $script:HelpLocales) { throw "Locale '$l' is not shipped (en, ru, uk)" } }
$selected = if ($Page.Count -gt 0) { @($Page) } else { @($pages.Keys) }
foreach ($p in $selected) { if (-not $pages.Contains($p)) { throw "Page '$p' is not in the help map" } }

$mapRows = @{}
foreach ($row in $map.surfaces) { if ($row.ContainsKey('help')) { $mapRows[[string]$row.help] = $row } }

# The locator of every element of a page: the recipe's own, else the view id of the map's element row (phone).
function Get-ElementLocators {
    param([hashtable] $PageSource, [hashtable] $Recipe, [hashtable] $MapRow)
    $locators = [ordered]@{}
    foreach ($element in $PageSource.elements) {
        $id = [string]$element.id
        $locators[$id] = $null
        if ($Recipe.locate.ContainsKey($id)) { $locators[$id] = $Recipe.locate[$id]; continue }
        if ($MapRow.ContainsKey('elements')) {
            foreach ($mapElement in $MapRow.elements) {
                if ([string]$mapElement.id -eq $id) { $locators[$id] = @{ by = 'id'; value = [string]$mapElement.view } }
            }
        }
    }
    $locators
}

# ------------------------------------------------------------------------------------------------ the plan
$plan = [System.Collections.Generic.List[hashtable]]::new()
$incomplete = [System.Collections.Generic.List[string]]::new()
foreach ($pageId in $selected) {
    $recipe = $recipes.pages[[string]$pageId]
    if ($null -eq $recipe) { throw "capture-recipes.json has no recipe for page '$pageId'" }
    $source = $pages[$pageId]
    $locators = Get-ElementLocators -PageSource $source -Recipe $recipe -MapRow $mapRows[$pageId]
    foreach ($id in $locators.Keys) {
        if ($null -eq $locators[$id]) { $incomplete.Add("page '$pageId' element '$id' has no locator (no recipe entry and no view in the help map)") }
    }
    $apk = Join-Path $Root ([string]$recipe.apk)
    $hashes = @{}
    foreach ($l in $locales) { $hashes[$l] = Get-CaptureInputHash -Root $Root -Recipe $recipe -Locale $l }
    $plan.Add(@{ PageId = $pageId; Recipe = $recipe; Source = $source; Locators = $locators; Apk = $apk; Hashes = $hashes })
}

if ($DryRun) {
    foreach ($item in $plan) {
        $recipe = $item.Recipe
        Write-Host "page $($item.PageId): module $($recipe.module), package $($recipe.package), profile $($recipe.deviceProfile), themes $(@($recipe.themes) -join '+'), locales $($locales -join '+')"
        Write-Host "  package file: $($recipe.apk) ($(if (Test-Path -LiteralPath $item.Apk) { 'present, ' + (Get-Item -LiteralPath $item.Apk).LastWriteTime.ToString('yyyy-MM-dd HH:mm') } else { 'not built yet' }))"
        foreach ($l in $locales) { Write-Host "  inputs $l`: $($item.Hashes[$l].Count) files, hash $($item.Hashes[$l].Hash.Substring(0, 16))" }
        foreach ($id in $item.Locators.Keys) {
            $loc = $item.Locators[$id]
            Write-Host "  element $id`: $(if ($null -eq $loc) { '(none)' } else { $loc.by + ' ' + $loc.value })"
        }
        foreach ($l in $locales) {
            foreach ($loc in $item.Locators.Values) { if ($null -ne $loc) { [void](Resolve-Locator -Root $Root -Module $recipe.module -Locale $l -Locator $loc) } }
            foreach ($key in @($recipe.languageProof)) { [void](Resolve-StringRef -Root $Root -Module $recipe.module -Locale $l -Key ([string]$key)) }
        }
    }
    foreach ($line in $incomplete) { Write-Host "incomplete: $line" -ForegroundColor Red }
    if ($incomplete.Count -gt 0) { Write-Host "capture-help: FAIL dry run ($($incomplete.Count) recipe problem(s))"; exit 1 }
    Write-Host "capture-help: DRY RUN ok ($($plan.Count) page(s), $($locales.Count) locale(s); no device touched)"
    exit 0
}

if ($incomplete.Count -gt 0) {
    foreach ($line in $incomplete) { Write-Host "incomplete: $line" -ForegroundColor Red }
    Write-Host "capture-help: FAIL ($($incomplete.Count) recipe problem(s))"
    exit 1
}

# ------------------------------------------------------------------------------------------------ the device
if ($Adb -eq '') {
    $properties = Join-Path $Root 'local.properties'
    if (-not (Test-Path -LiteralPath $properties)) { throw 'No -Adb and no local.properties with sdk.dir' }
    $line = Get-Content -LiteralPath $properties | Where-Object { $_ -match '^\s*sdk\.dir\s*=' } | Select-Object -First 1
    if (-not $line) { throw 'local.properties has no sdk.dir' }
    $sdk = ([regex]::Replace(($line -split '=', 2)[1].Trim(), '\\(.)', '$1'))
    $Adb = Join-Path $sdk 'platform-tools/adb.exe'
}
if (-not (Test-Path -LiteralPath $Adb)) { throw "adb not found at $Adb" }
Add-Type -AssemblyName System.Drawing

function Invoke-Adb {
    param([string] $Serial, [string[]] $Arguments, [switch] $AllowFail)
    $output = & $Adb -s $Serial @Arguments 2>&1
    if ($LASTEXITCODE -ne 0 -and -not $AllowFail) { throw "adb -s $Serial $($Arguments -join ' ') failed with $LASTEXITCODE`: $(($output | Out-String).Trim())" }
    ($output | Out-String)
}

$scratch = Join-Path $Root 'temp/S0032/capture'
if (Test-Path -LiteralPath $scratch) { Remove-Item -LiteralPath $scratch -Recurse -Force }
[void](New-Item -ItemType Directory -Path $scratch -Force)

function Get-DeviceDump {
    param([string] $Serial, [string] $Name)
    # uiautomator refuses a dump while the screen animates ("could not get idle state"): try again a few times.
    for ($try = 1; $true; $try++) {
        try { [void](Invoke-Adb $Serial @('shell', 'uiautomator', 'dump', '/sdcard/deviceinfo-help-dump.xml')); break }
        catch { if ($try -ge 4) { throw }; Start-Sleep -Seconds 1 }
    }
    $local = Join-Path $scratch "$Name.xml"
    [void](Invoke-Adb $Serial @('pull', '/sdcard/deviceinfo-help-dump.xml', $local))
    , (ConvertFrom-UiDump -Xml ([System.IO.File]::ReadAllText($local)))
}

function Get-MeanBrightness {
    param([string] $PngPath)
    $bitmap = [System.Drawing.Bitmap]::new($PngPath)
    try {
        $sum = 0.0; $count = 0
        for ($i = 0; $i -lt 24; $i++) {
            for ($j = 0; $j -lt 24; $j++) {
                $c = $bitmap.GetPixel([int](($i + 0.5) * $bitmap.Width / 24), [int](($j + 0.5) * $bitmap.Height / 24))
                $sum += (0.299 * $c.R + 0.587 * $c.G + 0.114 * $c.B) / 255; $count++
            }
        }
        $sum / $count
    } finally { $bitmap.Dispose() }
}

function Save-ScaledPng {
    param([string] $From, [string] $To, [int] $MaxWidth)
    $source = [System.Drawing.Bitmap]::new($From)
    try {
        $width = [Math]::Min($MaxWidth, $source.Width)
        $height = [int][Math]::Round($source.Height * $width / $source.Width)
        $target = [System.Drawing.Bitmap]::new($width, $height)
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($target)
            try {
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $graphics.DrawImage($source, 0, 0, $width, $height)
            } finally { $graphics.Dispose() }
            $target.Save($To, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally { $target.Dispose() }
        @{ Width = $width; Height = $height }
    } finally { $source.Dispose() }
}

$sentinel = ''
$gradleProperties = Join-Path $Root 'gradle.properties'
if (Test-Path -LiteralPath $gradleProperties) {
    $line = Get-Content -LiteralPath $gradleProperties | Where-Object { $_ -match '^\s*deviceinfo\.sentinel\.versionName\s*=' } | Select-Object -First 1
    if ($line) { $sentinel = ($line -split '=', 2)[1].Trim() }
}

$results = [System.Collections.Generic.List[hashtable]]::new()
$touched = [System.Collections.Generic.List[hashtable]]::new()
try {
    foreach ($item in $plan) {
        $recipe = $item.Recipe
        $pageId = $item.PageId
        $package = [string]$recipe.package
        $serial = if ($recipe.module -eq 'wear') { $WearSerial } else { $PhoneSerial }
        if ($serial -eq '') { throw "Page '$pageId' is a $($recipe.module) page: pass -$(if ($recipe.module -eq 'wear') { 'WearSerial' } else { 'PhoneSerial' })" }
        $state = (Invoke-Adb $serial @('get-state') -AllowFail).Trim()
        if ($state -ne 'device') { throw "Device '$serial' is not there (adb get-state says '$state')" }
        $touched.Add(@{ Serial = $serial; Package = $package; Night = ($recipe.themes.Count -gt 1) })

        $sdkLevel = [int](Invoke-Adb $serial @('shell', 'getprop', 'ro.build.version.sdk')).Trim()
        if ($sdkLevel -lt 33) { throw "Device '$serial' runs API $sdkLevel; the per-app language needs API 33 or newer" }
        $characteristics = (Invoke-Adb $serial @('shell', 'getprop', 'ro.build.characteristics')).Trim()
        $isWatch = $characteristics -match 'watch'
        if (($recipe.module -eq 'wear') -ne $isWatch) { throw "Device '$serial' ($characteristics) does not match the $($recipe.module) page '$pageId'" }

        if (-not $NoInstall) {
            if (-not (Test-Path -LiteralPath $item.Apk)) { throw "The package $($recipe.apk) is not built (.\gradlew.bat :phone:assembleDebug :wear:assembleDebug)" }
            $newestInput = [datetime]::MinValue
            foreach ($l in $locales) {
                foreach ($relative in $item.Hashes[$l].Files) {
                    $time = (Get-Item -LiteralPath (Join-Path $Root $relative)).LastWriteTime
                    if ($time -gt $newestInput) { $newestInput = $time }
                }
            }
            if ((Get-Item -LiteralPath $item.Apk).LastWriteTime -lt $newestInput) {
                throw "The package $($recipe.apk) is older than its inputs (newest change $($newestInput.ToString('yyyy-MM-dd HH:mm:ss'))): rebuild it"
            }
            [void](Invoke-Adb $serial @('install', '-r', '-g', $item.Apk))
        }
        $dumpsys = Invoke-Adb $serial @('shell', 'dumpsys', 'package', $package)
        $installed = [regex]::Match($dumpsys, 'versionName=(\S+)').Groups[1].Value
        if ($installed -eq '') { throw "Package $package is not installed on '$serial'" }
        if ($installed -eq $sentinel -and $ProductVersion -eq '') { throw "The installed build carries the sentinel version $sentinel, which is never recorded: pass -ProductVersion with the version name of the pin" }
        if ($ProductVersion -ne '' -and $installed -ne $sentinel -and $installed -ne $ProductVersion) { throw "The installed build is $installed, not $ProductVersion" }
        $version = if ($ProductVersion -ne '') { $ProductVersion } else { $installed }

        $size = [regex]::Matches((Invoke-Adb $serial @('shell', 'wm', 'size')), '(\d+)x(\d+)') | Select-Object -Last 1
        $screenW = [int]$size.Groups[1].Value; $screenH = [int]$size.Groups[2].Value
        $density = [regex]::Matches((Invoke-Adb $serial @('shell', 'wm', 'density')), '(\d+)\s*$', 'Multiline') | Select-Object -Last 1
        $model = (Invoke-Adb $serial @('shell', 'getprop', 'ro.product.model')).Trim()
        $release = (Invoke-Adb $serial @('shell', 'getprop', 'ro.build.version.release')).Trim()
        $deviceText = "$model, Android $release (API $sdkLevel), $($screenW)x$screenH, $($density.Groups[1].Value) dpi"

        foreach ($l in $locales) {
            $themeResults = [ordered]@{}
            foreach ($theme in @($recipe.themes)) {
                $tag = "$pageId/$l/$theme"
                [void](Invoke-Adb $serial @('shell', 'am', 'force-stop', $package) -AllowFail)
                [void](Invoke-Adb $serial @('shell', 'pm', 'clear', $package))
                [void](Invoke-Adb $serial @('shell', 'cmd', 'locale', 'set-app-locales', $package, '--locales', $l))
                $applied = Invoke-Adb $serial @('shell', 'cmd', 'locale', 'get-app-locales', $package)
                if ($applied -notmatch "\[\s*$l\b") { throw "$tag`: the app language did not take effect (get-app-locales: $($applied.Trim()))" }
                if ($recipe.themes.Count -gt 1) { [void](Invoke-Adb $serial @('shell', 'cmd', 'uimode', 'night', $(if ($theme -eq 'dark') { 'yes' } else { 'no' }))) }
                [void](Invoke-Adb $serial @('shell', 'monkey', '-p', $package, '-c', 'android.intent.category.LAUNCHER', '1'))

                $proof = @($recipe.languageProof | ForEach-Object { Resolve-StringRef -Root $Root -Module $recipe.module -Locale $l -Key ([string]$_) })
                $nodes = $null
                for ($attempt = 1; $attempt -le 10; $attempt++) {
                    Start-Sleep -Seconds 1
                    $nodes = Get-DeviceDump $serial "$pageId-$l-$theme-start"
                    if (Test-UiDumpShowsText -Nodes $nodes -Texts $proof) { break }
                    $nodes = $null
                }
                if ($null -eq $nodes) { throw "$tag`: the screen never showed the $l text '$($proof -join "' or '")' (is the app language applied, did the app start?)" }

                foreach ($step in @($recipe.steps)) {
                    if ($step.op -ne 'tap') { throw "$tag`: unknown step '$($step.op)'" }
                    if ($step.ContainsKey('unless')) {
                        $unless = Resolve-Locator -Root $Root -Module $recipe.module -Locale $l -Locator $step.unless
                        if ($null -ne (Find-UiNode -Nodes $nodes -Resolved $unless -ScreenWidth $screenW -ScreenHeight $screenH)) { continue }
                    }
                    $target = Find-UiNode -Nodes $nodes -Resolved (Resolve-Locator -Root $Root -Module $recipe.module -Locale $l -Locator $step.find) -ScreenWidth $screenW -ScreenHeight $screenH
                    if ($null -eq $target) { throw "$tag`: the step target ($($step.find.by) $($step.find.value)) is not on the screen" }
                    $cx = [int](($target.Bounds[0] + $target.Bounds[2]) / 2); $cy = [int](($target.Bounds[1] + $target.Bounds[3]) / 2)
                    [void](Invoke-Adb $serial @('shell', 'input', 'tap', "$cx", "$cy"))
                    Start-Sleep -Seconds 1
                    $nodes = Get-DeviceDump $serial "$pageId-$l-$theme-step"
                }

                Start-Sleep -Seconds 1
                [void](Invoke-Adb $serial @('shell', 'screencap', '-p', '/sdcard/deviceinfo-help-shot.png'))
                $rawPng = Join-Path $scratch "$pageId-$l-$theme-raw.png"
                [void](Invoke-Adb $serial @('pull', '/sdcard/deviceinfo-help-shot.png', $rawPng))
                $nodes = Get-DeviceDump $serial "$pageId-$l-$theme-final"
                if (-not (Test-UiDumpShowsText -Nodes $nodes -Texts $proof)) { throw "$tag`: the final screen does not show the $l text '$($proof -join "' or '")'" }

                if ($recipe.themes.Count -gt 1) {
                    $brightness = Get-MeanBrightness $rawPng
                    if ($theme -eq 'dark' -and $brightness -ge 0.35) { throw "$tag`: asked for the dark theme, the image is bright (mean $([Math]::Round($brightness, 2)))" }
                    if ($theme -eq 'light' -and $brightness -le 0.6) { throw "$tag`: asked for the light theme, the image is dark (mean $([Math]::Round($brightness, 2)))" }
                }

                $pins = [ordered]@{}
                $absent = [System.Collections.Generic.List[string]]::new()
                foreach ($id in $item.Locators.Keys) {
                    $node = Find-UiNode -Nodes $nodes -Resolved (Resolve-Locator -Root $Root -Module $recipe.module -Locale $l -Locator $item.Locators[$id]) -ScreenWidth $screenW -ScreenHeight $screenH
                    $position = if ($null -eq $node) { $null } else { ConvertTo-PinPosition -Bounds $node.Bounds -ScreenWidth $screenW -ScreenHeight $screenH }
                    if ($null -eq $position) { $absent.Add($id) } else { $pins[$id] = $position }
                }
                $scaled = Join-Path $scratch "$pageId-$l-$theme.png"
                $dimensions = Save-ScaledPng -From $rawPng -To $scaled -MaxWidth ([int]$recipes.scaleMaxWidth)
                $themeResults[$theme] = @{ Png = $scaled; Dimensions = $dimensions; Pins = $pins; Absent = @($absent) }
                Write-Host "  captured $tag ($($pins.Count) pinned, $($absent.Count) absent: $($absent -join ', '))"
            }

            $first = $themeResults[@($recipe.themes)[0]]
            foreach ($theme in (@($recipe.themes) | Select-Object -Skip 1)) {
                $other = $themeResults[$theme]
                if ((@($first.Absent) -join ',') -ne (@($other.Absent) -join ',')) { throw "$pageId/$l`: the themes show different parts ($(@($first.Absent) -join ',') against $(@($other.Absent) -join ','))" }
                foreach ($id in $first.Pins.Keys) {
                    if ([Math]::Abs($first.Pins[$id].x - $other.Pins[$id].x) -gt $script:PinThemeTolerance -or [Math]::Abs($first.Pins[$id].y - $other.Pins[$id].y) -gt $script:PinThemeTolerance) {
                        throw "$pageId/$l`: the pin of '$id' moves with the theme ($($first.Pins[$id].x),$($first.Pins[$id].y) against $($other.Pins[$id].x),$($other.Pins[$id].y))"
                    }
                }
            }
            $current = Get-CaptureInputHash -Root $Root -Recipe $recipe -Locale $l
            if ($current.Hash -ne $item.Hashes[$l].Hash) { throw "$pageId/$l`: an input changed while the capture ran; run it again" }
            $results.Add(@{ PageId = $pageId; Locale = $l; Recipe = $recipe; Version = $version; Device = $deviceText; Themes = $themeResults; First = $first; Hash = $item.Hashes[$l].Hash; Elements = $item.Locators.Keys })
        }
    }
} catch {
    $script:failed = $true
    Write-Host "capture-help: FAIL - $($_.Exception.Message)" -ForegroundColor Red
} finally {
    foreach ($device in $touched) {
        [void](Invoke-Adb $device.Serial @('shell', 'am', 'force-stop', $device.Package) -AllowFail)
        if ($device.Night) { [void](Invoke-Adb $device.Serial @('shell', 'cmd', 'uimode', 'night', 'auto') -AllowFail) }
        [void](Invoke-Adb $device.Serial @('shell', 'cmd', 'locale', 'set-app-locales', $device.Package, '--locales', '') -AllowFail)
        [void](Invoke-Adb $device.Serial @('shell', 'rm', '-f', '/sdcard/deviceinfo-help-dump.xml', '/sdcard/deviceinfo-help-shot.png') -AllowFail)
    }
}
if ($script:failed) { Write-Host 'capture-help: nothing was written'; exit 1 }

# ------------------------------------------------------------------------------------------------ the records
Save-CaptureResults -Root $Root -Results $results -Date (Get-Date).ToString('yyyy-MM-dd')
Write-Host "capture-help: PASS ($($results.Count) record(s) written to $($script:CaptureRecordsRelative); next: render-help.ps1, then check-help-captures.ps1 -Require)"
exit 0
