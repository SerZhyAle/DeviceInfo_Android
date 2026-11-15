#requires -Version 7.0
<#
.SYNOPSIS
    The help gate of DeviceInfo (S0024, CONTEXT-HELP rule 19): does every surface have a row in the help map, does
    every row have a surface, is every help page there in every shipped locale, does every link resolve, and does
    every page keep the offline rule.

.DESCRIPTION
    Reads (never writes):
      phone/src/main/assets/help/help-map.json    the one help map (rule 17); the shipped file the resolver reads
      phone and wear AndroidManifest.xml          the activities: the surfaces the product draws
      phone/src/**/*.kt                           dialogs: every MaterialAlertDialogBuilder( or AlertDialog.Builder(
      wear/src/main/**/*.kt                       Compose dialogs (Dialog(, Alert(, Confirmation()
      <module>/src/main/res                       the UI strings the map and the pages name, the view ids of the map
      phone/src/main/assets/help/<locale>/*.html and site/help/<locale>/*.html   the generated pages
      site/sitemap.xml and site/robots.txt        help pages stay out of the sitemap and crawlable (0.2 item G)

    It fails (exit 1) on: a surface with no row; a row with no surface; a `none` or `inherit` row with no reason; an
    `inherit` row whose parent has no help; a page missing in a shipped locale or on the site; a link that does not
    resolve (a missing file, a missing anchor, an own-site address with no file behind it, an address that is not
    allow-listed); a URL outside an anchor, a script or stylesheet from outside, a missing no-referrer or noindex
    meta, a missing lang (rule 12); a map element with no anchor in a page or no view in the layouts; the app and the
    site holding different bytes; a Help branch or an F1 handler that does nothing; a watch row without its strings or
    its call in SystemInfoScreen; pages that differ from their sources (render-help.ps1 -Check).

    The last line written to stdout is the CHECK-VERDICT line.

.PARAMETER Root
    Repository root. Defaults to two levels above this script; the self-test passes a throw-away tree.

.PARAMETER SkipRender
    Do not run render-help.ps1 -Check (the self-test tree has no sources to render).

.NOTES
    Exit codes: 0 in step; 1 at least one mismatch; 2 could not verify (a required file is missing or unreadable).
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [switch] $SkipRender
)

$ErrorActionPreference = 'Stop'
trap {
    Write-Host "check-help-map: could not run: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'help-map: COULD NOT VERIFY (a required input is missing or unreadable)'
    exit 2
}

. (Join-Path $PSScriptRoot '_help.ps1')

$mismatches = [System.Collections.Generic.List[string]]::new()
function Add-Mismatch { param([string] $Text) $mismatches.Add($Text) }

function Read-Text {
    param([string] $Relative)
    $path = Join-Path $Root $Relative
    if (-not (Test-Path -LiteralPath $path)) { throw "Required file is missing: $Relative" }
    [System.IO.File]::ReadAllText($path)
}

function ConvertTo-Relative {
    param([string] $FullName)
    $FullName.Substring($Root.TrimEnd('\', '/').Length + 1).Replace('\', '/')
}

$map = Get-HelpMap -Root $Root
$pages = Get-HelpPageSources -Root $Root -Map $map
$common = Read-HelpJson (Join-Path $Root 'tools/help/source/common.json')
$locales = $script:HelpLocales

# ------------------------------------------------------------------------------------- sources
foreach ($problem in (Test-HelpSources -Root $Root -Map $map -Pages $pages -Common $common)) { Add-Mismatch "source: $problem" }

# ------------------------------------------------------------------------------------- the map's own shape
if ($map.schemaVersion -ne 1) { Add-Mismatch "map: schemaVersion is '$($map.schemaVersion)', the gate reads 1" }
if ((@($map.locales) -join ',') -ne ($locales -join ',')) { Add-Mismatch "map: locales are '$(@($map.locales) -join ',')', the shipped set is '$($locales -join ',')'" }
if (-not ([string]$map.siteRoot).StartsWith('https://') -or -not ([string]$map.siteRoot).EndsWith('/help/')) {
    Add-Mismatch "map: siteRoot '$($map.siteRoot)' is not an https address ending in /help/"
}
$siteBase = Get-SiteBase $map
$byId = @{}
foreach ($row in $map.surfaces) {
    $id = [string]$row.id
    if ($byId.ContainsKey($id)) { Add-Mismatch "map: surface id '$id' appears twice" }
    $byId[$id] = $row
}
foreach ($row in $map.surfaces) {
    $id = [string]$row.id
    if ($row.form -notin 'layer', 'page', 'both', 'inherit', 'none') { Add-Mismatch "map: surface '$id' has form '$($row.form)'" }
    if ($row.module -notin 'phone', 'wear') { Add-Mismatch "map: surface '$id' has module '$($row.module)'" }
    if (-not $row.ContainsKey('source') -or ([string]$row.source) -notmatch '^(activity|dialog):.+') {
        Add-Mismatch "map: surface '$id' has no source of the form activity:<name> or dialog:<path>"
    }
    if ($row.form -in 'none', 'inherit' -and [string]::IsNullOrWhiteSpace([string]$row.reason)) {
        Add-Mismatch "map: surface '$id' is '$($row.form)' with no reason (CONTEXT-HELP rule 4)"
    }
    if ($row.form -eq 'inherit') {
        $parent = [string]$row.parent
        if (-not $byId.ContainsKey($parent) -or $byId[$parent].form -notin 'page', 'layer', 'both') {
            Add-Mismatch "map: surface '$id' inherits from '$parent', which has no help of its own"
        }
    }
    if ($row.form -in 'page', 'layer', 'both' -and [string]::IsNullOrWhiteSpace([string]$row.help)) {
        Add-Mismatch "map: surface '$id' is '$($row.form)' with no help id"
    }
    foreach ($loc in $locales) {
        try { [void](Resolve-StringRef -Root $Root -Module $row.module -Locale $loc -Key ([string]$row.nameRef)) }
        catch { Add-Mismatch "map: surface '$id' name: $($_.Exception.Message)" }
    }
}

# ------------------------------------------------------------------------------------- surfaces from the source of truth
$codeActivities = @{}
foreach ($pair in @(
        @{ Module = 'phone'; Files = @('phone/src/main/AndroidManifest.xml', 'phone/src/restricted/AndroidManifest.xml') },
        @{ Module = 'wear'; Files = @('wear/src/main/AndroidManifest.xml') })) {
    foreach ($relative in $pair.Files) {
        $path = Join-Path $Root $relative
        if (-not (Test-Path -LiteralPath $path)) {
            if ($relative -like '*restricted*') { continue }
            throw "Required manifest is missing: $relative"
        }
        foreach ($m in [regex]::Matches([System.IO.File]::ReadAllText($path), '(?s)<activity(?:-alias)?\b[^>]*?android:name="([^"]+)"')) {
            $codeActivities["$($pair.Module)|$($m.Groups[1].Value)"] = $true
        }
    }
}
$rowActivities = @{}
foreach ($row in $map.surfaces) {
    if (([string]$row.source).StartsWith('activity:')) {
        $key = "$($row.module)|$(([string]$row.source).Substring('activity:'.Length))"
        if ($rowActivities.ContainsKey($key)) { Add-Mismatch "map: activity '$key' has two rows" }
        $rowActivities[$key] = $row.id
    }
}
foreach ($key in $codeActivities.Keys) {
    if (-not $rowActivities.ContainsKey($key)) { Add-Mismatch "surface with no row: activity $key is declared by a manifest and absent from the map" }
}
foreach ($key in $rowActivities.Keys) {
    if (-not $codeActivities.ContainsKey($key)) { Add-Mismatch "row with no surface: '$($rowActivities[$key])' names activity $key, which no manifest declares" }
}

$dialogCounts = @{}
$dialogRegex = [regex]'(?:MaterialAlertDialogBuilder|AlertDialog\.Builder)\('
foreach ($file in (Get-ChildItem -LiteralPath (Join-Path $Root 'phone/src') -Filter '*.kt' -File -Recurse)) {
    $count = $dialogRegex.Matches([System.IO.File]::ReadAllText($file.FullName)).Count
    if ($count -gt 0) { $dialogCounts[(ConvertTo-Relative $file.FullName)] = $count }
}
$wearDialogRegex = [regex]'\b(?:Dialog|Alert|Confirmation)\s*\('
foreach ($file in (Get-ChildItem -LiteralPath (Join-Path $Root 'wear/src/main') -Filter '*.kt' -File -Recurse)) {
    $count = $wearDialogRegex.Matches([System.IO.File]::ReadAllText($file.FullName)).Count
    if ($count -gt 0) { $dialogCounts[(ConvertTo-Relative $file.FullName)] = $count }
}
$rowDialogs = @{}
foreach ($row in $map.surfaces) {
    if (([string]$row.source).StartsWith('dialog:')) {
        $file = ([string]$row.source).Substring('dialog:'.Length)
        if (-not (Test-Path -LiteralPath (Join-Path $Root $file))) { Add-Mismatch "row with no surface: '$($row.id)' names dialog file $file, which does not exist" }
        $rowDialogs[$file] = 1 + $(if ($rowDialogs.ContainsKey($file)) { $rowDialogs[$file] } else { 0 })
    }
}
foreach ($file in $dialogCounts.Keys) {
    $rows = if ($rowDialogs.ContainsKey($file)) { $rowDialogs[$file] } else { 0 }
    if ($rows -ne $dialogCounts[$file]) {
        Add-Mismatch "dialogs of $file`: the source builds $($dialogCounts[$file]), the map has $rows row(s)"
    }
}
foreach ($file in $rowDialogs.Keys) {
    if (-not $dialogCounts.ContainsKey($file) -and (Test-Path -LiteralPath (Join-Path $Root $file))) {
        Add-Mismatch "row with no surface: dialog rows name $file, which builds no dialog"
    }
}

# ------------------------------------------------------------------------------------- pages per surface and locale
$pageCount = 0
$helpIds = [System.Collections.Generic.List[string]]::new()
foreach ($row in $map.surfaces) {
    if ($row.form -in 'page', 'layer', 'both' -and -not $helpIds.Contains([string]$row.help)) { $helpIds.Add([string]$row.help) }
}
$needed = @($helpIds) + @([string]$map.index)
foreach ($outRoot in $script:HelpOutputRoots) {
    foreach ($loc in $locales) {
        foreach ($helpId in $needed) {
            $relative = "$outRoot/$loc/$helpId.html"
            if (-not (Test-Path -LiteralPath (Join-Path $Root $relative))) { Add-Mismatch "page missing: $relative" } else { $pageCount++ }
        }
    }
}
foreach ($loc in $locales) {
    foreach ($helpId in $needed) {
        $a = Join-Path $Root "phone/src/main/assets/help/$loc/$helpId.html"
        $b = Join-Path $Root "site/help/$loc/$helpId.html"
        if ((Test-Path -LiteralPath $a) -and (Test-Path -LiteralPath $b)) {
            if (-not [System.Linq.Enumerable]::SequenceEqual([byte[]][System.IO.File]::ReadAllBytes($a), [byte[]][System.IO.File]::ReadAllBytes($b))) {
                Add-Mismatch "the app and the site hold different bytes for $loc/$helpId.html (CONTEXT-HELP rule 12)"
            }
        }
    }
}

# ------------------------------------------------------------------------------------- page content, links, rule 12
$ownSiteRoot = $siteBase
$anchorsOf = @{}
$htmlFiles = @()
$assetHelp = Join-Path $Root 'phone/src/main/assets/help'
if (Test-Path -LiteralPath $assetHelp) { $htmlFiles = @(Get-ChildItem -LiteralPath $assetHelp -Filter '*.html' -File -Recurse) }
foreach ($file in $htmlFiles) {
    $text = [System.IO.File]::ReadAllText($file.FullName)
    $set = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($m in [regex]::Matches($text, '\bid="([^"]+)"')) { [void]$set.Add($m.Groups[1].Value) }
    $anchorsOf[$file.FullName] = $set
}
foreach ($file in $htmlFiles) {
    $relative = ConvertTo-Relative $file.FullName
    $text = [System.IO.File]::ReadAllText($file.FullName)
    $loc = Split-Path -Leaf (Split-Path -Parent $file.FullName)
    if ($text -notmatch "<html lang=`"$loc`" dir=`"ltr`">") { Add-Mismatch "$relative has no lang=`"$loc`" and dir (rule 13)" }
    if ($text -notmatch '<meta name="referrer" content="no-referrer">') { Add-Mismatch "$relative has no no-referrer meta (rule 12)" }
    if ($text -notmatch '<meta name="robots" content="noindex">') { Add-Mismatch "$relative has no noindex meta (0.2 item G)" }
    $withoutAnchors = [regex]::Replace($text, '(?s)<a\b[^>]*>', '<a>')
    foreach ($m in [regex]::Matches($withoutAnchors, 'https?://[^\s"''<>]+')) {
        Add-Mismatch "$relative holds an address outside an anchor: $($m.Value) (rule 12)"
    }
    if ($text -match '<script\b[^>]*\bsrc=') { Add-Mismatch "$relative loads a script (rule 12)" }
    if ($text -match '<img\b[^>]*\bsrc="https?:') { Add-Mismatch "$relative loads a remote image (rule 12)" }
    foreach ($m in [regex]::Matches($text, '<link\b[^>]*\bhref="([^"]*)"')) {
        if ($m.Groups[1].Value -notin '../sza-kit.css', '../help.css') { Add-Mismatch "$relative links $($m.Groups[1].Value), which is not one of the two shipped stylesheets (rule 12)" }
    }
    foreach ($m in [regex]::Matches($text, '<a\b[^>]*?\bhref="([^"]*)"')) {
        $href = $m.Groups[1].Value
        if ($href.StartsWith('#')) {
            if (-not $anchorsOf[$file.FullName].Contains($href.Substring(1))) { Add-Mismatch "$relative links $href, which has no anchor on the page" }
        } elseif ($href -eq [string]$common.supportUrl) {
            continue
        } elseif ($href.StartsWith($ownSiteRoot)) {
            $rest = $href.Substring($ownSiteRoot.Length)
            $frag = ''
            if ($rest.Contains('#')) { $frag = $rest.Substring($rest.IndexOf('#') + 1); $rest = $rest.Substring(0, $rest.IndexOf('#')) }
            $target = if ($rest -eq '' -or $rest.EndsWith('/')) { "site/$($rest)index.html" } else { "site/$rest" }
            if (-not (Test-Path -LiteralPath (Join-Path $Root $target))) { Add-Mismatch "$relative links $href, and $target does not exist" }
        } elseif ($href -match '^https?:') {
            Add-Mismatch "$relative links $href, which is neither the support address nor this product's site"
        } else {
            $name = $href
            $frag = ''
            if ($name.Contains('#')) { $frag = $name.Substring($name.IndexOf('#') + 1); $name = $name.Substring(0, $name.IndexOf('#')) }
            $targetPath = Join-Path (Split-Path -Parent $file.FullName) $name
            if (-not (Test-Path -LiteralPath $targetPath)) { Add-Mismatch "$relative links $href, and the file does not exist" }
            elseif ($frag -ne '' -and $anchorsOf.ContainsKey((Resolve-Path -LiteralPath $targetPath).Path) -and -not $anchorsOf[(Resolve-Path -LiteralPath $targetPath).Path].Contains($frag)) {
                Add-Mismatch "$relative links $href, which has no such anchor"
            }
        }
    }
}

$sitemapPath = Join-Path $Root 'site/sitemap.xml'
if (Test-Path -LiteralPath $sitemapPath) {
    if ([System.IO.File]::ReadAllText($sitemapPath).Contains('/help/')) { Add-Mismatch 'site/sitemap.xml lists a help page (0.2 item G: help pages stay out of the sitemap)' }
}
$landingLinks = [ordered]@{ 'site/index.html' = 'help/en/'; 'site/ru/index.html' = '../help/ru/'; 'site/uk/index.html' = '../help/uk/' }
foreach ($landing in $landingLinks.Keys) {
    $landingPath = Join-Path $Root $landing
    if ((Test-Path -LiteralPath $landingPath) -and -not [System.IO.File]::ReadAllText($landingPath).Contains("href=`"$($landingLinks[$landing])`"")) {
        Add-Mismatch "$landing does not link down to the help index $($landingLinks[$landing]) (CONTEXT-HELP rule 11)"
    }
}
$robotsPath = Join-Path $Root 'site/robots.txt'
if (Test-Path -LiteralPath $robotsPath) {
    if ([System.IO.File]::ReadAllText($robotsPath) -match '(?im)^\s*Disallow:\s*/help') { Add-Mismatch 'site/robots.txt blocks /help (0.2 item G: help pages stay crawlable)' }
}

# ------------------------------------------------------------------------------------- map elements: anchors and views
$layoutText = ''
$resDir = Join-Path $Root 'phone/src/main/res'
if (Test-Path -LiteralPath $resDir) {
    foreach ($dir in (Get-ChildItem -LiteralPath $resDir -Directory | Where-Object { $_.Name -like 'layout*' -or $_.Name -like 'menu*' })) {
        foreach ($file in (Get-ChildItem -LiteralPath $dir.FullName -Filter '*.xml' -File)) { $layoutText += [System.IO.File]::ReadAllText($file.FullName) }
    }
}
foreach ($row in $map.surfaces) {
    if (-not $row.ContainsKey('elements')) { continue }
    foreach ($element in $row.elements) {
        $anchor = [string]$element.id
        if ($row.help -and $pages.Contains([string]$row.help)) {
            if (@($pages[[string]$row.help].elements | Where-Object { $_.id -eq $anchor }).Count -eq 0) {
                Add-Mismatch "map: element '$anchor' of '$($row.id)' is not an element of the page source $($row.help).json"
            }
        }
        foreach ($loc in $locales) {
            $pagePath = Join-Path $Root "phone/src/main/assets/help/$loc/$($row.help).html"
            if ((Test-Path -LiteralPath $pagePath) -and -not [System.IO.File]::ReadAllText($pagePath).Contains("id=`"$anchor`"")) {
                Add-Mismatch "map: element '$anchor' of '$($row.id)' has no anchor in $loc/$($row.help).html"
            }
        }
        if ($layoutText -notmatch ('@\+?id/' + [regex]::Escape([string]$element.view) + '\b')) {
            Add-Mismatch "map: element '$anchor' names view '$($element.view)', which no phone layout or menu declares"
        }
        if ($element.view -eq 'action_help') { Add-Mismatch "map: the help button's own view is an element; the resolver must open the top for it (0.3 item K)" }
    }
}

# ------------------------------------------------------------------------------------- the controls do something
$windowManager = Read-Text 'phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/helpers/SystemInfoWindowManager.kt'
if ($windowManager -notmatch 'R\.id\.action_help\s*->\s*HelpLauncher\.open\(') { Add-Mismatch 'SystemInfoWindowManager: the action_help branch does not call HelpLauncher.open (an empty Help branch)' }
$activity = Read-Text 'phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/SystemInfoActivity.kt'
$f1 = [regex]::Match($activity, '(?s)KEYCODE_F1.{0,400}')
if (-not $f1.Success) { Add-Mismatch 'SystemInfoActivity: no F1 handler (CONTEXT-HELP rule 1)' }
elseif ($f1.Value -notmatch 'HelpLauncher\.open\(') { Add-Mismatch 'SystemInfoActivity: the F1 handler does not call HelpLauncher.open (a swallowed F1)' }
if ($activity -match 'Reserved for in-app help viewer') { Add-Mismatch 'SystemInfoActivity: the placeholder comment of the swallowed F1 is still there' }

foreach ($row in $map.surfaces) {
    if ($row.ContainsKey('entry') -and $row.entry -eq 'row-end-of-list') {
        foreach ($loc in $locales) {
            foreach ($key in 'system_info_help_title', 'system_info_help_text') {
                try { [void](Resolve-StringRef -Root $Root -Module $row.module -Locale $loc -Key $key) }
                catch { Add-Mismatch "watch entry of '$($row.id)': $($_.Exception.Message)" }
            }
        }
        $screen = Read-Text 'wear/src/main/kotlin/com/sza/deviceinfo/wear/ui/apps/systeminfo/SystemInfoScreen.kt'
        if ($screen -notmatch '(?s)item\s*\{\s*WearHelpEntry\(\)') { Add-Mismatch "watch entry of '$($row.id)': SystemInfoScreen does not show WearHelpEntry" }
    }
}

# ------------------------------------------------------------------------------------- pages equal their sources
if (-not $SkipRender) {
    $render = Join-Path $PSScriptRoot 'render-help.ps1'
    $output = & pwsh -NoProfile -File $render -Check -Root $Root 2>&1
    if ($LASTEXITCODE -ne 0) {
        foreach ($line in $output) { Write-Host "  render-help: $line" }
        Add-Mismatch "pages differ from their sources (render-help.ps1 -Check exited $LASTEXITCODE)"
    }
}

# ------------------------------------------------------------------------------------- verdict
if ($mismatches.Count -gt 0) {
    foreach ($line in $mismatches) { Write-Host "MISMATCH $line" -ForegroundColor Red }
    Write-Host "help-map: FAIL ($($mismatches.Count) mismatch(es))"
    exit 1
}
Write-Host "help-map: PASS ($(@($map.surfaces).Count) surfaces, $($pages.Count) help pages, $pageCount page files, $($htmlFiles.Count) read)"
exit 0
