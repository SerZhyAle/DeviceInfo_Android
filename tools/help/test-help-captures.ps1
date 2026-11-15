#requires -Version 7.0
<#
.SYNOPSIS
    Self-test of the help screenshot tooling (S0032): the capture records, the input hash, the UI dump parser, the
    locators, the pin arithmetic, the figure on the pages, the freshness gate and the driver's dry run.

.DESCRIPTION
    A gate that inspects nothing passes as quietly as a clean one, so this proves each part can fail. It copies the small
    pieces of the repository the tooling reads into a throw-away tree under temp/S0032/selftest, writes two synthetic
    PNG images, builds capture records through the same function the device driver uses, renders the pages, and then runs the
    gate on the clean tree and on trees broken one way at a time. Everything runs in this process (no child shell); it measured
    6.25 s on 2026-11-14, above the 5 s of the fast tier, so it is a release-tier run. It needs no device and never touches the repository.

    Exit code: 0 every expectation held; 1 at least one did not; 2 the test could not run.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'
trap { Write-Host "test-help-captures: could not run: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

. (Join-Path $PSScriptRoot '_help.ps1')
Add-Type -AssemblyName System.Drawing

$gate = Join-Path $PSScriptRoot 'check-help-captures.ps1'
$render = Join-Path $PSScriptRoot 'render-help.ps1'
$driver = Join-Path $PSScriptRoot 'capture-help.ps1'
$tree = Join-Path $Root 'temp/S0032/selftest'
if (Test-Path -LiteralPath $tree) { Remove-Item -LiteralPath $tree -Recurse -Force }
[void](New-Item -ItemType Directory -Path $tree -Force)

$copies = @(
    'phone/src/main/assets/help/help-map.json', 'tools/help/source', 'tools/help/vendor/help.css', 'tools/help/capture-recipes.json',
    'site/assets/sza-kit.css', 'gradle.properties',
    'phone/src/main/res/layout', 'phone/src/main/res/menu', 'phone/src/main/res/values', 'phone/src/main/res/values-night',
    'phone/src/main/res/values-ru', 'phone/src/main/res/values-uk',
    'wear/src/main/res/values', 'wear/src/main/res/values-ru', 'wear/src/main/res/values-uk',
    'wear/src/main/kotlin/com/sza/deviceinfo/wear/ui/apps/systeminfo/SystemInfoScreen.kt'
)
foreach ($relative in $copies) {
    $target = Join-Path $tree $relative
    [void](New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force)
    Copy-Item -LiteralPath (Join-Path $Root $relative) -Destination $target -Recurse
}

$utf8 = [System.Text.UTF8Encoding]::new($false)
$failures = 0
$checked = 0

function Assert-That {
    param([string] $Name, [bool] $Condition, [string] $Detail = '')
    $script:checked++
    if ($Condition) { Write-Host "  ok   $Name"; return }
    $script:failures++
    Write-Host "  FAIL $Name $Detail" -ForegroundColor Red
}

function Invoke-Tool {
    param([string] $Script, [hashtable] $Arguments)
    $output = (& $Script @Arguments *>&1 | Out-String)
    @{ Code = $LASTEXITCODE; Output = $output }
}

function New-TestPng {
    param([string] $Path, [int] $Width, [int] $Height, [System.Drawing.Color] $Color)
    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height)
    try {
        $g = [System.Drawing.Graphics]::FromImage($bitmap); $g.Clear($Color); $g.Dispose()
        [void](New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force)
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $bitmap.Dispose() }
}

$map = Get-HelpMap -Root $tree
$pages = Get-HelpPageSources -Root $tree -Map $map
$recipes = Read-CaptureRecipes -Root $tree
$titleEn = Resolve-StringRef -Root $tree -Module phone -Locale en -Key settings_system_info_title

Write-Host 'UI dump parser, locators, markers'
$dump = @"
<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>
<hierarchy rotation="0">
  <node index="0" text="" resource-id="" class="android.widget.FrameLayout" content-desc="" clickable="false" bounds="[0,0][1000,2000]">
    <node index="0" text="$titleEn" resource-id="com.sza.deviceinfo:id/toolbar_title" content-desc="" clickable="false" bounds="[100,50][600,150]" />
    <node index="1" text="" resource-id="com.sza.deviceinfo:id/action_system_info_copy" content-desc="" clickable="true" bounds="[800,50][900,150]" />
    <node index="2" text="" resource-id="com.sza.deviceinfo:id/csh_toggleRow" content-desc="" clickable="true" bounds="[0,300][1000,420]" />
    <node index="3" text="" resource-id="com.sza.deviceinfo:id/csh_toggleRow" content-desc="" clickable="true" bounds="[0,420][1000,540]" />
    <node index="4" text="" resource-id="com.sza.deviceinfo:id/offscreen" content-desc="" clickable="true" bounds="[0,2100][1000,2200]" />
    <node index="5" text="" resource-id="" content-desc="Model: Pixel" clickable="true" bounds="[0,600][1000,700]" />
    <node index="6" text="" resource-id="com.sza.deviceinfo:id/empty" content-desc="" clickable="true" bounds="[0,0][0,0]" />
    <node index="7" text="Interface size: 100 %" resource-id="" content-desc="" clickable="true" bounds="[0,800][1000,900]" />
  </node>
</hierarchy>
UI hierchary dumped to: /sdcard/deviceinfo-help-dump.xml
"@
$nodes = ConvertFrom-UiDump -Xml $dump
Assert-That 'the dump parser reads every node, ignoring the tool message after the hierarchy' ($nodes.Count -eq 9) "got $($nodes.Count)"
$locate = { param($l) Resolve-Locator -Root $tree -Module phone -Locale en -Locator $l }
Assert-That 'an id locator finds the first node in view order' ((Find-UiNode -Nodes $nodes -Resolved (& $locate @{ by = 'id'; value = 'csh_toggleRow' }) -ScreenWidth 1000 -ScreenHeight 2000).Bounds[1] -eq 300)
Assert-That 'nth picks the second occurrence' ((Find-UiNode -Nodes $nodes -Resolved (& $locate @{ by = 'id'; value = 'csh_toggleRow'; nth = 1 }) -ScreenWidth 1000 -ScreenHeight 2000).Bounds[1] -eq 420)
Assert-That 'a third occurrence does not exist' ($null -eq (Find-UiNode -Nodes $nodes -Resolved (& $locate @{ by = 'id'; value = 'csh_toggleRow'; nth = 2 }) -ScreenWidth 1000 -ScreenHeight 2000))
Assert-That 'a node below the screen is not shown' ($null -eq (Find-UiNode -Nodes $nodes -Resolved (& $locate @{ by = 'id'; value = 'offscreen' }) -ScreenWidth 1000 -ScreenHeight 2000))
Assert-That 'a node with empty bounds is not shown' ($null -eq (Find-UiNode -Nodes $nodes -Resolved (& $locate @{ by = 'id'; value = 'empty' }) -ScreenWidth 1000 -ScreenHeight 2000))
Assert-That 'a textRef locator matches the text of the UI string of the locale' ($null -ne (Find-UiNode -Nodes $nodes -Resolved (& $locate @{ by = 'textRef'; value = 'settings_system_info_title' }) -ScreenWidth 1000 -ScreenHeight 2000))
Assert-That 'a textRefFormat locator matches the number in the text of its locale' ((Find-UiNode -Nodes $nodes -Resolved (Resolve-Locator -Root $tree -Module wear -Locale en -Locator @{ by = 'textRefFormat'; value = 'system_info_interface_scale'; clickable = $true }) -ScreenWidth 1000 -ScreenHeight 2000).Bounds[1] -eq 800)
Assert-That 'a textRefFormat locator of another locale does not match the English text' ($null -eq (Find-UiNode -Nodes $nodes -Resolved (Resolve-Locator -Root $tree -Module wear -Locale ru -Locator @{ by = 'textRefFormat'; value = 'system_info_interface_scale' }) -ScreenWidth 1000 -ScreenHeight 2000))
Assert-That 'a descPattern locator with clickable matches the content description' ((Find-UiNode -Nodes $nodes -Resolved (& $locate @{ by = 'descPattern'; value = '^[^:]+: .'; clickable = $true }) -ScreenWidth 1000 -ScreenHeight 2000).Bounds[1] -eq 600)
Assert-That 'the language proof sees the title text and refuses another one' ((Test-UiDumpShowsText -Nodes $nodes -Texts @($titleEn)) -and -not (Test-UiDumpShowsText -Nodes $nodes -Texts @('Not on this screen')))
Assert-That 'a textRefPrefix locator needs a string of that prefix' ($(try { [void](Resolve-Locator -Root $tree -Module wear -Locale en -Locator @{ by = 'textRefPrefix'; value = 'no_such_prefix_' }); $false } catch { $true }))
$pin = ConvertTo-PinPosition -Bounds @(900, 100, 1000, 200) -ScreenWidth 1000 -ScreenHeight 2000
Assert-That 'a pin sits half a pin in from the left edge of a wide part, at its vertical centre' ($pin.x -eq 92.2 -and $pin.y -eq 7.5) "got $($pin.x),$($pin.y)"
$narrow = ConvertTo-PinPosition -Bounds @(100, 100, 120, 200) -ScreenWidth 1000 -ScreenHeight 2000
Assert-That 'a part narrower than a pin gets the pin on its centre' ($narrow.x -eq 11 -and $narrow.y -eq 7.5) "got $($narrow.x),$($narrow.y)"
Assert-That 'a part partly below the screen is pinned on its visible half' ((ConvertTo-PinPosition -Bounds @(0, 1900, 1000, 2100) -ScreenWidth 1000 -ScreenHeight 2000).y -eq 97.5)
Assert-That 'a part wholly off the screen has no pin' ($null -eq (ConvertTo-PinPosition -Bounds @(0, 2100, 1000, 2200) -ScreenWidth 1000 -ScreenHeight 2000))

Write-Host 'Input hash'
$systemRecipe = $recipes.pages['system-info']
$h1 = (Get-CaptureInputHash -Root $tree -Recipe $systemRecipe -Locale en).Hash
Assert-That 'the hash is the same twice' ($h1 -eq (Get-CaptureInputHash -Root $tree -Recipe $systemRecipe -Locale en).Hash)
Assert-That 'the locales differ (each has its own strings)' ($h1 -ne (Get-CaptureInputHash -Root $tree -Recipe $systemRecipe -Locale ru).Hash)
$layoutFile = Get-ChildItem -LiteralPath (Join-Path $tree 'phone/src/main/res/layout') -File | Select-Object -First 1
$layoutBytes = [System.IO.File]::ReadAllBytes($layoutFile.FullName)
$crlf = $utf8.GetBytes(([System.IO.File]::ReadAllText($layoutFile.FullName) -replace "`r?`n", "`r`n"))
[System.IO.File]::WriteAllBytes($layoutFile.FullName, $crlf)
Assert-That 'line endings do not change the hash' ($h1 -eq (Get-CaptureInputHash -Root $tree -Recipe $systemRecipe -Locale en).Hash)
[System.IO.File]::WriteAllBytes($layoutFile.FullName, $layoutBytes + $utf8.GetBytes('<!-- changed -->'))
Assert-That 'a change to a layout changes the hash' ($h1 -ne (Get-CaptureInputHash -Root $tree -Recipe $systemRecipe -Locale en).Hash)
[System.IO.File]::WriteAllBytes($layoutFile.FullName, $layoutBytes)
$ruStrings = Get-ChildItem -LiteralPath (Join-Path $tree 'phone/src/main/res/values-ru') -Filter 'strings*.xml' | Select-Object -First 1
$ruBytes = [System.IO.File]::ReadAllBytes($ruStrings.FullName)
[System.IO.File]::WriteAllBytes($ruStrings.FullName, $ruBytes + $utf8.GetBytes('<!-- changed -->'))
Assert-That 'a Russian string does not stale the English capture' ($h1 -eq (Get-CaptureInputHash -Root $tree -Recipe $systemRecipe -Locale en).Hash)
[System.IO.File]::WriteAllBytes($ruStrings.FullName, $ruBytes)
$emptyRecipe = @{ inputs = @{ roots = @('phone/src/main/res'); include = @('^nothing-matches$') } }
Assert-That 'a recipe whose inputs match no file is refused' ($(try { [void](Get-CaptureInputHash -Root $tree -Recipe $emptyRecipe -Locale en); $false } catch { $true }))

Write-Host 'Records, figure, footer'
$noRecordFiles = (Get-HelpExpectedFiles -Root $tree).Files
Assert-That 'with no record a page has no figure and no picture is generated' (-not ([System.Text.Encoding]::UTF8.GetString($noRecordFiles['phone/src/main/assets/help/en/system-info.html']).Contains('<figure')) -and @($noRecordFiles.Keys | Where-Object { $_ -like '*.png' }).Count -eq 0)
$dark = Join-Path $tree 'temp/dark.png'; $light = Join-Path $tree 'temp/light.png'; $watchPng = Join-Path $tree 'temp/watch.png'
New-TestPng $dark 54 120 ([System.Drawing.Color]::FromArgb(18, 18, 18))
New-TestPng $light 54 120 ([System.Drawing.Color]::FromArgb(250, 250, 250))
New-TestPng $watchPng 45 45 ([System.Drawing.Color]::Black)
$results = [System.Collections.Generic.List[hashtable]]::new()
foreach ($pageId in $pages.Keys) {
    $source = $pages[$pageId]
    $ids = @(Get-PageElementIds $source)
    $absentIds = if ($pageId -eq 'system-info') { @('share', 'notifications') } else { @('help-row') }
    foreach ($locale in $script:HelpLocales) {
        $pins = [ordered]@{}
        $n = 0
        foreach ($id in $ids) { $n++; if ($id -notin $absentIds) { $pins[$id] = @{ x = [double](5 + $n * 3.25); y = [double](10 + $n * 7) } } }
        $themes = [ordered]@{}
        $dimensions = if ($pageId -eq 'system-info') { @{ Width = 54; Height = 120 } } else { @{ Width = 45; Height = 45 } }
        if ($pageId -eq 'system-info') {
            $themes['dark'] = @{ Png = $dark; Dimensions = $dimensions; Pins = $pins; Absent = $absentIds }
            $themes['light'] = @{ Png = $light; Dimensions = $dimensions; Pins = $pins; Absent = $absentIds }
        } else {
            $themes['dark'] = @{ Png = $watchPng; Dimensions = $dimensions; Pins = $pins; Absent = $absentIds }
        }
        $results.Add(@{ PageId = $pageId; Locale = $locale; Version = '9.9.9'; Device = 'Test device, Android 15 (API 35), 1080x2400, 420 dpi'
                Themes = $themes; First = $themes['dark']; Hash = (Get-CaptureInputHash -Root $tree -Recipe $recipes.pages[$pageId] -Locale $locale).Hash; Elements = $ids })
    }
}
Save-CaptureResults -Root $tree -Results $results -Date '2026-11-14'
$records = Read-CaptureRecords -Root $tree
Assert-That 'the records written by the driver function pass the record check' ((Test-CaptureRecords -Root $tree -Pages $pages -Records $records).Count -eq 0) ((Test-CaptureRecords -Root $tree -Pages $pages -Records $records) -join '; ')
Assert-That 'the records file holds 3 locales for each of the 2 pages' (@($records.records['system-info'].Keys).Count -eq 3 -and @($records.records['watch-system-info'].Keys).Count -eq 3)

$run = Invoke-Tool $render @{ Root = $tree }
Assert-That 'render writes the pages with the figure' ($run.Code -eq 0) $run.Output
$phoneEn = [System.IO.File]::ReadAllText((Join-Path $tree 'phone/src/main/assets/help/en/system-info.html'))
$phoneRu = [System.IO.File]::ReadAllText((Join-Path $tree 'phone/src/main/assets/help/ru/system-info.html'))
$watchEn = [System.IO.File]::ReadAllText((Join-Path $tree 'phone/src/main/assets/help/en/watch-system-info.html'))
Assert-That 'the figure comes before the order list and carries both theme images and the frame width' ($phoneEn.IndexOf('<figure class="shot">') -gt 0 -and $phoneEn.IndexOf('<figure') -lt $phoneEn.IndexOf('class="order"') -and $phoneEn.Contains('class="on-dark" src="system-info-dark.png" width="54" height="120"') -and $phoneEn.Contains('class="on-light" src="system-info-light.png"') -and $phoneEn.Contains('max-width:54px'))
Assert-That 'every shown part has a pin linked to its entry, in marker order, and the absent ones have none' (([regex]::Matches($phoneEn, 'class="pin"')).Count -eq 9 -and $phoneEn.Contains('href="#copy" aria-label="1, ') -and $phoneEn.Contains('class="pin" style="--x:') -and -not ($phoneEn -match 'class="pin"[^>]*href="#(share|notifications)"') -and $phoneEn.Contains('id="notifications"'))
Assert-That 'the alt text names the surface and the pinned parts; the second theme image has an empty alt' ($phoneEn -match 'alt="The [^"]+ window with its parts numbered: 1 ' -and $phoneEn.Contains('class="on-light" src="system-info-light.png" width="54" height="120" alt=""'))
Assert-That 'the Russian page carries the Russian words and the same pins' ($phoneRu.Contains('Окно «') -and $phoneRu.Contains('Демонстрационные данные') -and ([regex]::Matches($phoneRu, 'class="pin"')).Count -eq 9)
Assert-That 'the watch page has one plain image (the watch has one theme) and the screen caption' ($watchEn.Contains('<img src="watch-system-info-dark.png" width="45" height="45"') -and -not $watchEn.Contains('on-light') -and $watchEn.Contains('part of the screen') -and ([regex]::Matches($watchEn, 'class="pin"')).Count -eq 5)
Assert-That 'the footer carries the version and the capture date' ($phoneEn.Contains('Captured against DeviceInfo 9.9.9, 2026-11-14.') -and [System.IO.File]::ReadAllText((Join-Path $tree 'site/help/uk/system-info.html')).Contains('Знімок екрана зроблено в DeviceInfo 9.9.9, 2026-11-14.'))
$sameBytes = $true
foreach ($theme in 'dark', 'light') {
    $inApp = [System.IO.File]::ReadAllBytes((Join-Path $tree "phone/src/main/assets/help/ru/system-info-$theme.png"))
    $onSite = [System.IO.File]::ReadAllBytes((Join-Path $tree "site/help/ru/system-info-$theme.png"))
    if (-not [System.Linq.Enumerable]::SequenceEqual([byte[]]$inApp, [byte[]]$onSite)) { $sameBytes = $false }
}
Assert-That 'the images are render targets: the same bytes in the app and on the site' $sameBytes
Assert-That 'the index page does not carry a capture' (-not [System.IO.File]::ReadAllText((Join-Path $tree 'phone/src/main/assets/help/en/index.html')).Contains('Captured against'))
Assert-That 'render -Check passes on what render wrote' ((Invoke-Tool $render @{ Root = $tree; Check = $true }).Code -eq 0)
[System.IO.File]::WriteAllBytes((Join-Path $tree 'site/help/en/stray.png'), @(1, 2, 3))
$stray = Invoke-Tool $render @{ Root = $tree; Check = $true }
Assert-That 'render -Check refuses a picture the generator does not own' ($stray.Code -eq 1 -and $stray.Output -match 'not owned by the generator: site/help/en/stray\.png')
Remove-Item -LiteralPath (Join-Path $tree 'site/help/en/stray.png')

Write-Host 'Record validation (each can fail)'
function Test-Mutated {
    param([scriptblock] $Mutate)
    $copy = Read-CaptureRecords -Root $tree
    & $Mutate $copy
    ((Test-CaptureRecords -Root $tree -Pages $pages -Records $copy) -join '; ')
}
Assert-That 'a pin on an element the page lacks is refused' ((Test-Mutated { param($r) $r.records['system-info']['en'].pins[0].id = 'nope' }) -match "names element 'nope'")
Assert-That 'an element neither pinned nor absent is refused' ((Test-Mutated { param($r) $r.records['system-info']['en'].absent = @('share') }) -match "neither pins nor records as absent the element 'notifications'")
Assert-That 'an element both pinned and absent is refused' ((Test-Mutated { param($r) $r.records['system-info']['en'].absent += 'copy' }) -match "'copy' both pinned and absent")
Assert-That 'a size that is not the image''s size is refused' ((Test-Mutated { param($r) $r.records['system-info']['en'].image.width = 99 }) -match 'is 54x120, the record says 99x120')
Assert-That 'a pin outside the image is refused' ((Test-Mutated { param($r) $r.records['system-info']['en'].pins[0].x = 120 }) -match 'x outside 0..100')
Assert-That 'a date that is not a date is refused' ((Test-Mutated { param($r) $r.records['system-info']['en'].date = 'yesterday' }) -match 'is not a date')
Assert-That 'a record of a locale the product does not ship is refused' ((Test-Mutated { param($r) $r.records['system-info']['de'] = $r.records['system-info']['en'] }) -match "'de' is not a shipped locale")
Assert-That 'a record of a page the map does not have is refused' ((Test-Mutated { param($r) $r.records['ghost'] = @{ en = @{} } }) -match "page 'ghost' is not in the help map")

Write-Host 'Freshness gate'
$first = Invoke-Tool $gate @{ Root = $tree }
Assert-That 'absent parts that the baseline does not accept fail the gate' ($first.Code -eq 1 -and $first.Output -match "absent: system-info/en does not show element 'share'" -and $first.Output -match "absent: watch-system-info/uk does not show element 'help-row'")
$written = Invoke-Tool $gate @{ Root = $tree; WriteBaseline = $true }
Assert-That 'the first adoption writes the baseline' ($written.Code -eq 0 -and (Test-Path -LiteralPath (Join-Path $tree 'tools/help/captures/absent-baseline.json')))
$clean = Invoke-Tool $gate @{ Root = $tree; ExpectVersion = '9.9.9' }
Assert-That 'with the baseline the gate passes and says rung 2 is held' ($clean.Code -eq 0 -and $clean.Output -match 'help-captures: PASS \(6 record\(s\) current, rung 2 held in the static form\)') $clean.Output
Assert-That 'another expected version fails' ((Invoke-Tool $gate @{ Root = $tree; ExpectVersion = '1.0.0' }).Output -match 'was captured against 9\.9\.9, expected 1\.0\.0')

[System.IO.File]::WriteAllBytes($layoutFile.FullName, $layoutBytes + $utf8.GetBytes('<!-- changed -->'))
$stale = Invoke-Tool $gate @{ Root = $tree }
Assert-That 'a layout changed after the capture makes the phone records stale and not the watch''s' ($stale.Code -eq 1 -and $stale.Output -match 'stale: system-info/en' -and $stale.Output -match 'stale: system-info/uk' -and $stale.Output -notmatch 'stale: watch-system-info')
[System.IO.File]::WriteAllBytes($layoutFile.FullName, $layoutBytes)
[System.IO.File]::WriteAllBytes($ruStrings.FullName, $ruBytes + $utf8.GetBytes('<!-- changed -->'))
$staleRu = Invoke-Tool $gate @{ Root = $tree }
Assert-That 'a Russian string stales only the Russian records' ($staleRu.Code -eq 1 -and $staleRu.Output -match 'stale: system-info/ru' -and $staleRu.Output -notmatch 'stale: system-info/en' -and $staleRu.Output -notmatch 'stale: system-info/uk')
[System.IO.File]::WriteAllBytes($ruStrings.FullName, $ruBytes)

$imagePath = Join-Path $tree 'tools/help/captures/system-info/uk-light.png'
$imageBytes = [System.IO.File]::ReadAllBytes($imagePath)
New-TestPng $imagePath 54 120 ([System.Drawing.Color]::Red)
Assert-That 'an image changed after the capture fails the gate' ((Invoke-Tool $gate @{ Root = $tree }).Output -match 'system-info/uk-light\.png differs from the hash of the record')
[System.IO.File]::WriteAllBytes($imagePath, $imageBytes)
Remove-Item -LiteralPath (Join-Path $tree 'tools/help/captures/watch-system-info/en-dark.png')
Assert-That 'a missing image fails the gate' ((Invoke-Tool $gate @{ Root = $tree }).Output -match 'has no image tools/help/captures/watch-system-info/en-dark\.png')
[System.IO.File]::WriteAllBytes((Join-Path $tree 'tools/help/captures/watch-system-info/en-dark.png'), [System.IO.File]::ReadAllBytes($watchPng))

$recordsPath = Join-Path $tree 'tools/help/captures/captures.json'
$recordsText = [System.IO.File]::ReadAllText($recordsPath)
$sentinel = ((Get-Content -LiteralPath (Join-Path $tree 'gradle.properties') | Where-Object { $_ -match '^\s*deviceinfo\.sentinel\.versionName' }) -split '=', 2)[1].Trim()
[System.IO.File]::WriteAllText($recordsPath, $recordsText.Replace('"version": "9.9.9"', "`"version`": `"$sentinel`""), $utf8)
Assert-That 'a record carrying the build sentinel as its version fails the gate' ((Invoke-Tool $gate @{ Root = $tree }).Output -match 'carries the build sentinel')
[System.IO.File]::WriteAllText($recordsPath, $recordsText, $utf8)

$baselinePath = Join-Path $tree 'tools/help/captures/absent-baseline.json'
$baselineText = [System.IO.File]::ReadAllText($baselinePath)
[System.IO.File]::WriteAllText($baselinePath, ($baselineText -replace '"notifications",\s*"share"', '"notifications", "share", "copy"'), $utf8)
Assert-That 'a baseline entry that is shown now fails the gate' ((Invoke-Tool $gate @{ Root = $tree }).Output -match "baseline: system-info/en lists 'copy' as absent")
[System.IO.File]::WriteAllText($baselinePath, ($baselineText -replace '"notifications",\s*"share"', '"notifications"'), $utf8)
Assert-That 'a part absent but missing from the baseline fails the gate' ((Invoke-Tool $gate @{ Root = $tree }).Output -match "does not show element 'share' and the baseline does not accept it")
$grow = Invoke-Tool $gate @{ Root = $tree; WriteBaseline = $true }
Assert-That 'the baseline may only fall: a regeneration that would grow it is refused' ($grow.Code -eq 1 -and $grow.Output -match 'the baseline may only fall')
[System.IO.File]::WriteAllText($baselinePath, $baselineText, $utf8)

$parsed = $recordsText | ConvertFrom-Json -AsHashtable
$parsed.records['system-info'].Remove('ru')
[System.IO.File]::WriteAllText($recordsPath, ($parsed | ConvertTo-Json -Depth 8), $utf8)
Assert-That 'a page with no record in one locale fails the gate' ((Invoke-Tool $gate @{ Root = $tree }).Output -match 'missing: no capture record for system-info/ru')
[System.IO.File]::WriteAllText($recordsPath, $recordsText, $utf8)
Assert-That 'the clean tree passes again after every repair' ((Invoke-Tool $gate @{ Root = $tree }).Code -eq 0)

Remove-Item -LiteralPath $recordsPath
$none = Invoke-Tool $gate @{ Root = $tree }
$noneRequired = Invoke-Tool $gate @{ Root = $tree; Require = $true }
Assert-That 'with no record at all rung 2 is NOT HELD and the gate exits 0' ($none.Code -eq 0 -and $none.Output -match 'help-captures: NOT HELD \(no capture record; 9 image')
Assert-That 'with -Require the same state fails' ($noneRequired.Code -eq 1 -and $noneRequired.Output -match 'help-captures: FAIL \(no capture record')
Assert-That 'with -WriteBaseline and no record the gate cannot run' ((Invoke-Tool $gate @{ Root = $tree; WriteBaseline = $true }).Code -eq 2)

Write-Host 'Driver dry run'
$dry = Invoke-Tool $driver @{ Root = $tree; DryRun = $true }
Assert-That 'the dry run plans both pages and touches no device' ($dry.Code -eq 0 -and $dry.Output -match 'capture-help: DRY RUN ok \(2 page' -and $dry.Output -match 'element help: id action_help')
$recipePath = Join-Path $tree 'tools/help/capture-recipes.json'
$recipeText = [System.IO.File]::ReadAllText($recipePath)
[System.IO.File]::WriteAllText($recipePath, $recipeText.Replace('"help": { "by": "id", "value": "action_help" }', '"ignored": { "by": "id", "value": "action_help" }'), $utf8)
$broken = Invoke-Tool $driver @{ Root = $tree; DryRun = $true }
Assert-That 'a recipe that leaves an element without a locator is refused' ($broken.Code -eq 1 -and $broken.Output -match "element 'help' has no locator")
[System.IO.File]::WriteAllText($recipePath, $recipeText, $utf8)
[System.IO.File]::WriteAllBytes((Join-Path $tree 'adb.exe'), @(0))
$noSerial = Invoke-Tool $driver @{ Root = $tree; Adb = (Join-Path $tree 'adb.exe') }
Assert-That 'a real run without a device serial is refused before any device is touched' ($noSerial.Code -eq 1 -and $noSerial.Output -match 'pass -PhoneSerial' -and $noSerial.Output -match 'nothing was written')

if ($failures -gt 0) {
    Write-Host "test-help-captures: FAIL ($failures of $checked expectations did not hold)" -ForegroundColor Red
    exit 1
}
Write-Host "test-help-captures: PASS ($checked expectations)"
exit 0
