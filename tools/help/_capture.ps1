#requires -Version 7.0
<#
Shared functions of the help screenshot tooling (S0032, CONTEXT-HELP rule 8 item 3, rule 14, section 4 rung 2):
the capture records, the hash of what a screenshot could show, the parser of an Android UI dump, the locator of one
element in it and the arithmetic of a marker. `render-help.ps1`, `check-help-captures.ps1`, `capture-help.ps1` and the
self-test dot-source it after `_help.ps1`; the functions that read UI strings call into `_help.ps1`. Not run on its own.
#>
Set-StrictMode -Version Latest

$script:CaptureThemes = @('dark', 'light')
$script:CapturesRelative = 'tools/help/captures'
$script:CaptureRecordsRelative = 'tools/help/captures/captures.json'
$script:CaptureBaselineRelative = 'tools/help/captures/absent-baseline.json'
$script:CaptureRecipesRelative = 'tools/help/capture-recipes.json'
# Half the width of a marker pin, as a percentage of the image width (help.css: 28 px on a frame of about 640 px).
$script:PinHalfPercent = 2.2
# Two themes of one layout must give the same pin; more than this many percent apart is a defect of the capture.
$script:PinThemeTolerance = 0.5

function Get-CaptureImageRelative {
    param([string] $HelpId, [string] $Locale, [string] $Theme)
    "$($script:CapturesRelative)/$HelpId/$Locale-$Theme.png"
}

function Get-FileSha256 {
    param([Parameter(Mandatory)][string] $Path)
    $stream = [System.IO.File]::OpenRead($Path)
    try { [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::HashData($stream)).Replace('-', '').ToLowerInvariant() }
    finally { $stream.Dispose() }
}

function Get-BytesSha256 {
    param([byte[]] $Bytes)
    [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::HashData($Bytes)).Replace('-', '').ToLowerInvariant()
}

# The records file, or $null when no capture has ever been recorded.
function Read-CaptureRecords {
    param([string] $Root)
    $path = Join-Path $Root $script:CaptureRecordsRelative
    if (-not (Test-Path -LiteralPath $path)) { return $null }
    Read-HelpJson $path
}

function Read-CaptureRecipes {
    param([string] $Root)
    Read-HelpJson (Join-Path $Root $script:CaptureRecipesRelative)
}

# Width and height of a PNG from its header, or $null when the bytes are not a PNG.
function Get-PngSize {
    param([byte[]] $Bytes)
    if ($Bytes.Length -lt 24) { return $null }
    $signature = @(137, 80, 78, 71, 13, 10, 26, 10)
    for ($i = 0; $i -lt 8; $i++) { if ($Bytes[$i] -ne $signature[$i]) { return $null } }
    $width = ([int]$Bytes[16] -shl 24) -bor ([int]$Bytes[17] -shl 16) -bor ([int]$Bytes[18] -shl 8) -bor [int]$Bytes[19]
    $height = ([int]$Bytes[20] -shl 24) -bor ([int]$Bytes[21] -shl 16) -bor ([int]$Bytes[22] -shl 8) -bor [int]$Bytes[23]
    @{ Width = $width; Height = $height }
}

# ----------------------------------------------------------------------------------------------- the input hash

$script:TextExtensions = @('.xml', '.kt', '.kts', '.json', '.txt', '.md')

function Get-NormalizedBytes {
    param([string] $Path)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    if ([System.IO.Path]::GetExtension($Path).ToLowerInvariant() -notin $script:TextExtensions) { return , $bytes }
    $kept = [System.Collections.Generic.List[byte]]::new($bytes.Length)
    foreach ($b in $bytes) { if ($b -ne 13) { $kept.Add($b) } }
    , $kept.ToArray()
}

# The files a capture of one page in one locale could show, and one hash over their paths and contents (CONTEXT-HELP 0.2
# item D). The recipe says which: `inputs.roots` are directories searched, `inputs.include` are regular expressions over
# the repository-relative path (forward slashes) in which {locale} is the capture's locale. The recipe file itself is an
# input, because what the driver does on the screen decides what the picture shows. Text files hash without carriage
# returns, so a checkout with other line endings gives the same hash.
function Get-CaptureInputHash {
    param([string] $Root, [hashtable] $Recipe, [string] $Locale)
    $rootPrefix = $Root.TrimEnd('\', '/').Length + 1
    $regexes = @($Recipe.inputs.include | ForEach-Object { [regex]::new(([string]$_).Replace('{locale}', $Locale)) })
    $found = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($rootRelative in @($Recipe.inputs.roots)) {
        $dir = Join-Path $Root $rootRelative
        if (-not (Test-Path -LiteralPath $dir)) { continue }
        foreach ($file in (Get-ChildItem -LiteralPath $dir -File -Recurse)) {
            $relative = $file.FullName.Substring($rootPrefix).Replace('\', '/')
            foreach ($regex in $regexes) { if ($regex.IsMatch($relative)) { [void]$found.Add($relative); break } }
        }
    }
    if ($found.Count -eq 0) { throw "The capture inputs of the recipe match no file under $Root (roots: $(@($Recipe.inputs.roots) -join ', '))" }
    [void]$found.Add($script:CaptureRecipesRelative)
    $paths = [string[]]@($found)
    [Array]::Sort($paths, [StringComparer]::Ordinal)
    $lines = [System.Text.StringBuilder]::new()
    foreach ($relative in $paths) {
        $full = Join-Path $Root $relative
        if (-not (Test-Path -LiteralPath $full)) { throw "A capture input is missing: $relative" }
        [void]$lines.Append($relative).Append('|').Append((Get-BytesSha256 (Get-NormalizedBytes $full))).Append("`n")
    }
    @{ Hash = (Get-BytesSha256 ([System.Text.UTF8Encoding]::new($false).GetBytes($lines.ToString()))); Count = $paths.Count; Files = $paths }
}

# ----------------------------------------------------------------------------------------------- the UI dump

# The nodes of an `uiautomator dump`, in document order. Bounds are screen pixels: left, top, right, bottom.
function ConvertFrom-UiDump {
    param([Parameter(Mandatory)][string] $Xml)
    $start = $Xml.IndexOf('<?xml')
    if ($start -lt 0) { $start = $Xml.IndexOf('<hierarchy') }
    if ($start -lt 0) { throw 'The UI dump holds no hierarchy' }
    $end = $Xml.LastIndexOf('</hierarchy>')
    if ($end -lt 0) { throw 'The UI dump is cut short (no closing hierarchy)' }
    $document = [System.Xml.XmlDocument]::new()
    $document.LoadXml($Xml.Substring($start, $end + '</hierarchy>'.Length - $start))
    $nodes = [System.Collections.Generic.List[object]]::new()
    foreach ($node in $document.SelectNodes('//node')) {
        $bounds = @(0, 0, 0, 0)
        $m = [regex]::Match($node.GetAttribute('bounds'), '^\[(-?\d+),(-?\d+)\]\[(-?\d+),(-?\d+)\]$')
        if ($m.Success) { $bounds = @(1..4 | ForEach-Object { [int]$m.Groups[$_].Value }) }
        $nodes.Add([pscustomobject]@{
                ResourceId  = $node.GetAttribute('resource-id')
                Text        = $node.GetAttribute('text')
                ContentDesc = $node.GetAttribute('content-desc')
                Clickable   = ($node.GetAttribute('clickable') -eq 'true')
                Bounds      = $bounds
            })
    }
    , $nodes.ToArray()
}

# A locator the driver can match, with the string references of the recipe turned into the texts of one locale:
#   id               a resource id (the package prefix is ignored)
#   textRef          the text of one UI string
#   textRefPrefix    the text of any UI string whose key starts with the prefix
#   textRefFormat    the text of one UI string with one number (%1$d) and a literal percent sign (%%), as a node text with a number in it
#   descPattern      a regular expression over the content description
# `nth` (default 0) picks the occurrence in view order; `clickable` (default any) narrows by the clickable flag.
function Resolve-Locator {
    param([string] $Root, [string] $Module, [string] $Locale, [hashtable] $Locator)
    $nth = if ($Locator.ContainsKey('nth')) { [int]$Locator.nth } else { 0 }
    $resolved = @{ Nth = $nth; Clickable = $null; Ids = @(); Texts = @(); DescPattern = $null; TextPattern = $null }
    if ($Locator.ContainsKey('clickable')) { $resolved.Clickable = [bool]$Locator.clickable }
    switch ([string]$Locator.by) {
        'id' { $resolved.Ids = @([string]$Locator.value) }
        'textRef' { $resolved.Texts = @(Resolve-StringRef -Root $Root -Module $Module -Locale $Locale -Key ([string]$Locator.value)) }
        'textRefPrefix' {
            $strings = (Get-ModuleStrings -Root $Root -Module $Module -Locale $Locale).Strings
            $resolved.Texts = @($strings.Keys | Where-Object { $_.StartsWith([string]$Locator.value) } | Sort-Object | ForEach-Object { $strings[$_] })
            if ($resolved.Texts.Count -eq 0) { throw "No $Module string of locale $Locale starts with '$($Locator.value)'" }
        }
        'textRefFormat' {
            # The format string is escaped first, so its own punctuation is literal; the escaped %1\$d becomes a number and %% a percent sign.
            $format = [string](Resolve-StringRef -Root $Root -Module $Module -Locale $Locale -Key ([string]$Locator.value))
            $body = [regex]::Escape($format) -replace '%1\\\$d', '\d+' -replace '%%', '%'
            $resolved.TextPattern = [regex]::new('^' + $body + '$')
        }
        'descPattern' { $resolved.DescPattern = [regex]::new([string]$Locator.value) }
        default { throw "Unknown locator kind '$($Locator.by)'" }
    }
    $resolved
}

# Whether a node's bounds show something on a screen of the given size.
function Get-VisibleBounds {
    param([int[]] $Bounds, [int] $ScreenWidth, [int] $ScreenHeight)
    $l = [Math]::Max(0, $Bounds[0]); $t = [Math]::Max(0, $Bounds[1])
    $r = [Math]::Min($ScreenWidth, $Bounds[2]); $b = [Math]::Min($ScreenHeight, $Bounds[3])
    if ($r -le $l -or $b -le $t) { return $null }
    , @($l, $t, $r, $b)
}

# The node a resolved locator picks: the nth match in view order among the nodes that show on the screen, or $null.
function Find-UiNode {
    param([object[]] $Nodes, [hashtable] $Resolved, [int] $ScreenWidth, [int] $ScreenHeight)
    $seen = 0
    foreach ($node in $Nodes) {
        if ($null -eq (Get-VisibleBounds -Bounds $node.Bounds -ScreenWidth $ScreenWidth -ScreenHeight $ScreenHeight)) { continue }
        if ($null -ne $Resolved.Clickable -and $node.Clickable -ne $Resolved.Clickable) { continue }
        $match = $false
        if ($Resolved.Ids.Count -gt 0) {
            foreach ($id in $Resolved.Ids) { if ($node.ResourceId -eq $id -or $node.ResourceId.EndsWith(":id/$id", [StringComparison]::Ordinal)) { $match = $true } }
        }
        if ($Resolved.Texts.Count -gt 0) {
            foreach ($text in $Resolved.Texts) {
                if ($node.Text.Trim() -ceq $text -or $node.ContentDesc.Trim() -ceq $text) { $match = $true }
            }
        }
        if ($null -ne $Resolved.DescPattern -and $node.ContentDesc -ne '' -and $Resolved.DescPattern.IsMatch($node.ContentDesc)) { $match = $true }
        if ($null -ne $Resolved.TextPattern -and $Resolved.TextPattern.IsMatch($node.Text.Trim())) { $match = $true }
        if (-not $match) { continue }
        if ($seen -eq $Resolved.Nth) { return $node }
        $seen++
    }
    $null
}

# Whether any node of the dump carries the text of one of the strings (the proof that the screen is in the asked language).
function Test-UiDumpShowsText {
    param([object[]] $Nodes, [string[]] $Texts)
    foreach ($node in $Nodes) {
        foreach ($text in $Texts) { if ($node.Text.Trim() -ceq $text -or $node.ContentDesc.Trim() -ceq $text) { return $true } }
    }
    $false
}

# ----------------------------------------------------------------------------------------------- the marker

# Where a marker sits on the image, as percentages of the image: the vertical centre of the part, and horizontally its
# left edge plus half a pin or half the part's width, whichever is smaller. $null when the part shows nothing.
function ConvertTo-PinPosition {
    param([int[]] $Bounds, [int] $ScreenWidth, [int] $ScreenHeight)
    $visible = Get-VisibleBounds -Bounds $Bounds -ScreenWidth $ScreenWidth -ScreenHeight $ScreenHeight
    if ($null -eq $visible) { return $null }
    $widthPercent = ($visible[2] - $visible[0]) / $ScreenWidth * 100
    $x = $visible[0] / $ScreenWidth * 100 + [Math]::Min($widthPercent / 2, $script:PinHalfPercent)
    $y = ($visible[1] + $visible[3]) / 2 / $ScreenHeight * 100
    @{ x = [Math]::Round($x, 2); y = [Math]::Round($y, 2) }
}

# ----------------------------------------------------------------------------------------------- the records

# Writes what a successful capture run produced: the images into tools/help/captures/<page>/ and one record per page and
# locale into captures.json, merged into the records already committed (a partial run keeps the others), every record
# rebuilt in one fixed key order so a rewrite shows only the real change in a diff. A result is a hashtable with PageId,
# Locale, Version, Device, Themes (theme -> @{ Png; Dimensions; Pins; Absent }), First (the first theme's entry, whose pins
# the page uses), Hash (the inputs hash taken before the run) and Elements (the page's element ids in marker order).
function Save-CaptureResults {
    param([string] $Root, [object[]] $Results, [string] $Date)
    $existing = Read-CaptureRecords -Root $Root
    $store = @{}
    if ($null -ne $existing) {
        foreach ($pageId in $existing.records.Keys) {
            $store[$pageId] = @{}
            foreach ($locale in $existing.records[$pageId].Keys) { $store[$pageId][$locale] = $existing.records[$pageId][$locale] }
        }
    }
    foreach ($result in $Results) {
        $pageId = [string]$result.PageId
        $locale = [string]$result.Locale
        $imageHashes = [ordered]@{}
        foreach ($theme in $result.Themes.Keys) {
            $destination = Join-Path $Root (Get-CaptureImageRelative -HelpId $pageId -Locale $locale -Theme $theme)
            $dir = Split-Path -Parent $destination
            if (-not (Test-Path -LiteralPath $dir)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
            Copy-Item -LiteralPath $result.Themes[$theme].Png -Destination $destination -Force
            $imageHashes[$theme] = Get-FileSha256 $destination
        }
        $pinList = @()
        foreach ($id in $result.Elements) {
            if ($result.First.Pins.Contains($id)) { $pinList += [ordered]@{ id = [string]$id; x = [double]$result.First.Pins[$id].x; y = [double]$result.First.Pins[$id].y } }
        }
        if (-not $store.ContainsKey($pageId)) { $store[$pageId] = @{} }
        $store[$pageId][$locale] = [ordered]@{
            version    = [string]$result.Version
            date       = $Date
            device     = [string]$result.Device
            themes     = @($result.Themes.Keys)
            image      = [ordered]@{ width = [int]$result.First.Dimensions.Width; height = [int]$result.First.Dimensions.Height }
            images     = $imageHashes
            pins       = $pinList
            absent     = @($result.First.Absent)
            inputsHash = [string]$result.Hash
        }
    }
    $pagesOut = [ordered]@{}
    foreach ($pageId in ($store.Keys | Sort-Object)) {
        $pagesOut[$pageId] = [ordered]@{}
        foreach ($locale in $script:HelpLocales) {
            if (-not $store[$pageId].ContainsKey($locale)) { continue }
            $r = $store[$pageId][$locale]
            $images = [ordered]@{}
            foreach ($theme in $script:CaptureThemes) { if ($r.images.Contains($theme)) { $images[$theme] = [string]$r.images[$theme] } }
            $pagesOut[$pageId][$locale] = [ordered]@{
                version    = [string]$r.version
                date       = [string]$r.date
                device     = [string]$r.device
                themes     = @($r.themes | ForEach-Object { [string]$_ })
                image      = [ordered]@{ width = [int]$r.image.width; height = [int]$r.image.height }
                images     = $images
                pins       = @($r.pins | ForEach-Object { [ordered]@{ id = [string]$_.id; x = [double]$_.x; y = [double]$_.y } })
                absent     = @($r.absent | ForEach-Object { [string]$_ })
                inputsHash = [string]$r.inputsHash
            }
        }
    }
    $path = Join-Path $Root $script:CaptureRecordsRelative
    $dir = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $dir)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
    $json = ([ordered]@{ schemaVersion = 1; records = $pagesOut } | ConvertTo-Json -Depth 8)
    [System.IO.File]::WriteAllText($path, $json.Replace("`r`n", "`n") + "`n", [System.Text.UTF8Encoding]::new($false))
}

function Get-PageElementIds {
    param([hashtable] $Page)
    @($Page.elements | ForEach-Object { [string]$_.id })
}

# Everything the renderer and the gate rely on in the records file; the text of each refusal says what to fix. Records of a
# page the map does not have, or of a locale the product does not ship, are refused too.
function Test-CaptureRecords {
    param([string] $Root, [System.Collections.IDictionary] $Pages, [hashtable] $Records)
    $problems = [System.Collections.Generic.List[string]]::new()
    if (-not $Records.ContainsKey('schemaVersion') -or $Records.schemaVersion -ne 1) { $problems.Add("captures.json: schemaVersion is not 1"); return , $problems }
    if (-not $Records.ContainsKey('records')) { $problems.Add('captures.json has no records'); return , $problems }
    foreach ($helpId in $Records.records.Keys) {
        if (-not $Pages.Contains([string]$helpId)) { $problems.Add("captures.json: page '$helpId' is not in the help map"); continue }
        $elementIds = Get-PageElementIds $Pages[[string]$helpId]
        foreach ($locale in $Records.records[$helpId].Keys) {
            $tag = "captures.json $helpId/$locale"
            if ($locale -notin $script:HelpLocales) { $problems.Add("$tag`: '$locale' is not a shipped locale"); continue }
            $record = $Records.records[$helpId][$locale]
            foreach ($field in 'version', 'date', 'device', 'themes', 'image', 'images', 'pins', 'absent', 'inputsHash') {
                if (-not $record.ContainsKey($field)) { $problems.Add("$tag has no '$field'") }
            }
            if (@('version', 'date', 'device', 'themes', 'image', 'images', 'pins', 'absent', 'inputsHash' | Where-Object { -not $record.ContainsKey($_) }).Count -gt 0) { continue }
            if ([string]::IsNullOrWhiteSpace([string]$record.version)) { $problems.Add("$tag has an empty version") }
            if (([string]$record.date) -notmatch '^\d{4}-\d{2}-\d{2}$') { $problems.Add("$tag date '$($record.date)' is not a date") }
            if (([string]$record.inputsHash) -notmatch '^[0-9a-f]{64}$') { $problems.Add("$tag inputsHash is not a SHA-256") }
            $themes = @($record.themes)
            if ($themes.Count -eq 0 -or @($themes | Where-Object { $_ -notin $script:CaptureThemes }).Count -gt 0 -or @($themes | Select-Object -Unique).Count -ne $themes.Count) {
                $problems.Add("$tag themes '$($themes -join ',')' are not a non-empty set of dark and light")
            }
            foreach ($theme in $themes) {
                $relative = Get-CaptureImageRelative -HelpId $helpId -Locale $locale -Theme $theme
                $path = Join-Path $Root $relative
                if (-not (Test-Path -LiteralPath $path)) { $problems.Add("$tag has no image $relative"); continue }
                $bytes = [System.IO.File]::ReadAllBytes($path)
                $size = Get-PngSize $bytes
                if ($null -eq $size) { $problems.Add("$relative is not a PNG"); continue }
                if ($size.Width -ne [int]$record.image.width -or $size.Height -ne [int]$record.image.height) {
                    $problems.Add("$relative is $($size.Width)x$($size.Height), the record says $($record.image.width)x$($record.image.height)")
                }
                if (-not $record.images.ContainsKey($theme) -or $record.images[$theme] -ne (Get-BytesSha256 $bytes)) {
                    $problems.Add("$relative differs from the hash of the record (the image was changed after the capture)")
                }
            }
            if ([int]$record.image.width -le 0 -or [int]$record.image.height -le 0) { $problems.Add("$tag image size is not positive") }
            $pinIds = @($record.pins | ForEach-Object { [string]$_.id })
            $absentIds = @($record.absent | ForEach-Object { [string]$_ })
            foreach ($pin in $record.pins) {
                foreach ($axis in 'x', 'y') {
                    if (-not $pin.ContainsKey($axis) -or [double]$pin[$axis] -lt 0 -or [double]$pin[$axis] -gt 100) { $problems.Add("$tag pin '$($pin.id)' has $axis outside 0..100") }
                }
            }
            foreach ($id in ($pinIds + $absentIds)) { if ($id -notin $elementIds) { $problems.Add("$tag names element '$id', which the page source does not have") } }
            if (@($pinIds | Select-Object -Unique).Count -ne $pinIds.Count) { $problems.Add("$tag pins an element twice") }
            foreach ($id in $pinIds) { if ($id -in $absentIds) { $problems.Add("$tag has '$id' both pinned and absent") } }
            foreach ($id in $elementIds) { if ($id -notin $pinIds -and $id -notin $absentIds) { $problems.Add("$tag neither pins nor records as absent the element '$id'") } }
        }
    }
    , $problems
}
