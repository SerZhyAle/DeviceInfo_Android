#requires -Version 7.0
<#
.SYNOPSIS
    Holds the product identity equal across its one source, the phone resources and the watch theme (S0022).

.DESCRIPTION
    docs/design/tokens.json is the identity written once. This script reads it and checks, without building:

      colors    every token's day and night value equals the phone's identity_* color (values and values-night),
                the phone theme maps each token to its Material attributes, the watch theme carries the night
                member of each token under the watch role the token names, and no identity color or constant
                exists that the source does not declare;
      contrast  the contrast pairs of the source hold their minimum ratio in day and night, and the watch's
                accent and text roles hold on its black background;
      launcher  the launcher plate color is the same in both modules;
      type      every type role names a phone style or attribute and a watch typography member that the code uses;
      glyphs    the phone's SystemInfoGroupIcons table equals the source table, the watch's WearSectionIcons table
                equals the source's watch entries (the groups it shares with the phone, extraWear, and the headers
                with no phone group, watchOnly), a watch glyph that the phone also has is the same drawable name and
                the same path data, one meaning has one glyph, and every title string the watch draws as a header
                has a glyph (the headers are one sibling set, ICON-RENDER 0.25 section 25 rule 1, S0035); and
                against the ICON-SET vocabulary of the shared contracts catalog, every mapped meaning exists with
                that drawable as its Android (or watch) reference, and every provisional meaning is named by the
                proposal file and is not yet in the vocabulary (a folded one is reported, so the table moves to the
                real id).

    The catalog's location is named once, in the agent-rules file (CLAUDE.md); this script parses it from there.
    Set DEVICEINFO_CONTRACTS_CATALOG to override. No screenshot is read or produced: the same-screen evidence of
    S0022 is a device or emulator run and stays an open manual check.

    Exit code: 0 everything equal; 1 at least one mismatch; 2 the check could not run (a file is missing or
    unparsable, or the catalog is unreachable and -SkipCatalog was not given).

.PARAMETER Tokens
    Path of the tokens file; defaults to docs/design/tokens.json.

.PARAMETER SkipCatalog
    Skip the vocabulary section (offline). The rest still runs; the report says the section was skipped.

.PARAMETER Json
    Print one JSON object with the counts and the findings instead of the text report.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $Tokens,
    [switch] $SkipCatalog,
    [switch] $Json
)

$ErrorActionPreference = 'Stop'
$sw = [System.Diagnostics.Stopwatch]::StartNew()
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:findings = New-Object System.Collections.Generic.List[object]
$script:okCount = 0

trap { Write-Host "check-tokens: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

function Add-Mismatch { param([string] $Area, [string] $Message) $script:findings.Add([pscustomobject] @{ area = $Area; message = $Message }) }
function Add-Ok { param([int] $Count = 1) $script:okCount += $Count }

function Read-RepoFile {
    param([string] $Relative)
    $path = Join-Path $repoRoot $Relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "required file '$Relative' does not exist" }
    return (Get-Content -LiteralPath $path -Raw -Encoding UTF8)
}

function Get-XmlColors {
    param([string] $Text)
    $map = @{}
    foreach ($m in [regex]::Matches($Text, '<color\s+name="([^"]+)"\s*>\s*([^<\s]+)\s*</color>')) { $map[$m.Groups[1].Value] = $m.Groups[2].Value }
    return $map
}

function ConvertTo-Hex6 {
    param([string] $Value)
    return $Value.TrimStart('#').ToUpperInvariant()
}

function Get-Luminance {
    param([string] $Hex)
    $h = $Hex.TrimStart('#')
    $channels = foreach ($i in 0, 2, 4) {
        $v = [Convert]::ToInt32($h.Substring($i, 2), 16) / 255.0
        if ($v -le 0.03928) { $v / 12.92 } else { [math]::Pow(($v + 0.055) / 1.055, 2.4) }
    }
    return 0.2126 * $channels[0] + 0.7152 * $channels[1] + 0.0722 * $channels[2]
}

function Get-ContrastRatio {
    param([string] $A, [string] $B)
    $x = Get-Luminance $A
    $y = Get-Luminance $B
    return ([math]::Max($x, $y) + 0.05) / ([math]::Min($x, $y) + 0.05)
}

function Get-PathData {
    param([string] $Text)
    return @([regex]::Matches($Text, 'android:pathData="([^"]*)"') | ForEach-Object { $_.Groups[1].Value })
}

$tokensPath = if ($Tokens) { $Tokens } else { Join-Path $repoRoot 'docs/design/tokens.json' }
if (-not (Test-Path -LiteralPath $tokensPath -PathType Leaf)) { throw "tokens file '$tokensPath' does not exist" }
$src = Get-Content -LiteralPath $tokensPath -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable

# ---- colors ----------------------------------------------------------------------------------------------------
$phoneDay = Get-XmlColors (Read-RepoFile 'phone/src/main/res/values/colors.xml')
$phoneNight = Get-XmlColors (Read-RepoFile 'phone/src/main/res/values-night/colors.xml')
$themesText = Read-RepoFile 'phone/src/main/res/values/themes.xml'
$themeItems = @{}
foreach ($m in [regex]::Matches($themesText, '<item\s+name="([^"]+)"\s*>\s*@color/([A-Za-z0-9_]+)\s*</item>')) { $themeItems[$m.Groups[1].Value] = $m.Groups[2].Value }
$wearThemeText = Read-RepoFile 'wear/src/main/kotlin/com/sza/deviceinfo/wear/ui/theme/DeviceInfoWearTheme.kt'
$wearConstants = @{}
foreach ($m in [regex]::Matches($wearThemeText, 'internal\s+val\s+(Identity\w+)\s*=\s*Color\(0xFF([0-9A-Fa-f]{6})\)')) { $wearConstants[$m.Groups[1].Value] = $m.Groups[2].Value.ToUpperInvariant() }
$wearRoleMap = @{}
$colorsBlock = [regex]::Match($wearThemeText, 'Colors\(([\s\S]*?)\)\s*\r?\n\s*\r?\n')
if (-not $colorsBlock.Success) { $colorsBlock = [regex]::Match($wearThemeText, 'Colors\(([\s\S]*?)\n\)') }
if (-not $colorsBlock.Success) { throw 'the Colors(...) block of DeviceInfoWearTheme.kt was not found' }
foreach ($m in [regex]::Matches($colorsBlock.Groups[1].Value, '(\w+)\s*=\s*(\w+)')) { $wearRoleMap[$m.Groups[1].Value] = $m.Groups[2].Value }

$declaredPhoneColors = @{}
$declaredWearConstants = @{}
$declaredPhoneAttrs = @{}
$wearRolesClaimed = @{}
foreach ($name in $src.colors.Keys) {
    $t = $src.colors[$name]
    $day = ConvertTo-Hex6 $t.day
    $night = ConvertTo-Hex6 $t.night
    $pc = $t.phoneColor
    $declaredPhoneColors[$pc] = $true
    foreach ($pair in @(@('day', $phoneDay, $day), @('night', $phoneNight, $night))) {
        $actual = $pair[1][$pc]
        if (-not $actual) { Add-Mismatch 'colors' "token '$name': phone color '$pc' is missing in the $($pair[0]) resources"; continue }
        if ($actual -ne ('#FF' + $pair[2]) -and $actual.ToUpperInvariant() -ne ('#FF' + $pair[2])) {
            Add-Mismatch 'colors' "token '$name': phone $($pair[0]) '$pc' is $actual, the source says #FF$($pair[2])"
        } else { Add-Ok }
    }
    foreach ($attr in $t.phoneAttrs) {
        $declaredPhoneAttrs[$attr] = $true
        if ($themeItems[$attr] -ne $pc) { Add-Mismatch 'colors' "token '$name': theme attribute '$attr' maps to '$($themeItems[$attr])', the source says '$pc'" } else { Add-Ok }
    }
    if ($t.wearConstant) {
        $declaredWearConstants[$t.wearConstant] = $true
        $actual = $wearConstants[$t.wearConstant]
        if (-not $actual) { Add-Mismatch 'colors' "token '$name': watch constant '$($t.wearConstant)' is missing" }
        elseif ($actual -ne $night) { Add-Mismatch 'colors' "token '$name': watch $($t.wearConstant) is 0xFF$actual, the night member in the source is #$night" }
        else { Add-Ok }
        foreach ($role in $t.wearRoles) {
            $wearRolesClaimed[$role] = $true
            if ($wearRoleMap[$role] -ne $t.wearConstant) { Add-Mismatch 'colors' "token '$name': watch role '$role' is '$($wearRoleMap[$role])', the source says '$($t.wearConstant)'" } else { Add-Ok }
        }
    } elseif (@($t.wearRoles).Count -gt 0) {
        Add-Mismatch 'colors' "token '$name' names watch roles but no watch constant"
    }
}
foreach ($name in @($phoneDay.Keys) + @($phoneNight.Keys)) {
    if ($name -like 'identity_*' -and -not $declaredPhoneColors.ContainsKey($name)) { Add-Mismatch 'colors' "phone color '$name' is not declared by the source" }
}
foreach ($pair in $themeItems.GetEnumerator()) {
    if ($pair.Value -like 'identity_*' -and -not $declaredPhoneAttrs.ContainsKey($pair.Key)) { Add-Mismatch 'colors' "theme attribute '$($pair.Key)' uses '$($pair.Value)' but no token declares that attribute" }
}
foreach ($name in $wearConstants.Keys) {
    if (-not $declaredWearConstants.ContainsKey($name)) { Add-Mismatch 'colors' "watch constant '$name' is not declared by the source" }
}
foreach ($role in $wearRoleMap.Keys) {
    if ($role -eq 'background') { continue }
    if (-not $wearRolesClaimed.ContainsKey($role)) { Add-Mismatch 'colors' "watch role '$role' is set but no token claims it" }
}
$bgMatch = [regex]::Match($wearThemeText, 'private\s+val\s+WatchBackground\s*=\s*Color\(0xFF([0-9A-Fa-f]{6})\)')
if (-not $bgMatch.Success -or $wearRoleMap['background'] -ne 'WatchBackground') { Add-Mismatch 'colors' 'the watch background role must be the WatchBackground constant' }
elseif ($bgMatch.Groups[1].Value.ToUpperInvariant() -ne (ConvertTo-Hex6 $src.watchOverrides.background)) { Add-Mismatch 'colors' "watch background is 0xFF$($bgMatch.Groups[1].Value), the source says $($src.watchOverrides.background)" }
else { Add-Ok }

# ---- contrast --------------------------------------------------------------------------------------------------
foreach ($rule in $src.contrast) {
    foreach ($theme in 'day', 'night') {
        $a = $src.colors[$rule.pair[0]][$theme]
        $b = $src.colors[$rule.pair[1]][$theme]
        $ratio = Get-ContrastRatio $a $b
        if ($ratio -lt $rule.min) { Add-Mismatch 'contrast' ("{0} on {1} in {2}: {3:N2} < {4} ({5})" -f $rule.pair[0], $rule.pair[1], $theme, $ratio, $rule.min, $rule.why) } else { Add-Ok }
    }
}
$black = $src.watchOverrides.background
foreach ($check in @(@('accent', 3.0), @('onSurface', 4.5), @('onSurfaceVariant', 4.5), @('error', 4.5))) {
    $ratio = Get-ContrastRatio $src.colors[$check[0]].night $black
    if ($ratio -lt $check[1]) { Add-Mismatch 'contrast' ("watch: {0} on the black background: {1:N2} < {2}" -f $check[0], $ratio, $check[1]) } else { Add-Ok }
}

# ---- launcher plate --------------------------------------------------------------------------------------------
$plate = $src.fixed.launcherPlate
foreach ($rel in $plate.phoneFile, $plate.wearFile) {
    $colors = Get-XmlColors (Read-RepoFile $rel)
    $actual = $colors[$plate.colorName]
    if (-not $actual -or (ConvertTo-Hex6 $actual) -ne (ConvertTo-Hex6 $plate.value)) { Add-Mismatch 'launcher' "$rel : $($plate.colorName) is '$actual', the source says $($plate.value)" } else { Add-Ok }
}

# ---- type roles ------------------------------------------------------------------------------------------------
$phoneTypeText = (Read-RepoFile 'phone/src/main/res/values/styles.xml') + (Read-RepoFile 'phone/src/main/res/layout/view_collapsible_section_header.xml')
$wearSources = (Get-ChildItem -LiteralPath (Join-Path $repoRoot 'wear/src/main/kotlin') -Filter '*.kt' -Recurse | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 }) -join "`n"
foreach ($role in $src.typeRoles) {
    if ($phoneTypeText.Contains($role.phone)) { Add-Ok } else { Add-Mismatch 'type' "role '$($role.role)': the phone style or id '$($role.phone)' is not in styles.xml or the section header layout" }
    if ($wearSources.Contains("MaterialTheme.typography.$($role.wear)")) { Add-Ok } else { Add-Mismatch 'type' "role '$($role.role)': no watch code uses MaterialTheme.typography.$($role.wear)" }
}

# ---- glyphs ----------------------------------------------------------------------------------------------------
$groupEnumText = Read-RepoFile 'phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/SystemInfoGroup.kt'
$enumNames = @([regex]::Matches($groupEnumText, '(?m)^\s*([A-Z][A-Z_]*)\("') | ForEach-Object { $_.Groups[1].Value })
$phoneIconsText = Read-RepoFile 'phone/src/main/kotlin/com/sza/deviceinfo/ui/systeminfo/helpers/SystemInfoGroupIcons.kt'
$phoneIcons = @{}
foreach ($m in [regex]::Matches($phoneIconsText, 'SystemInfoGroup\.([A-Z_]+)\s+to\s+R\.drawable\.(\w+)')) { $phoneIcons[$m.Groups[1].Value] = $m.Groups[2].Value }
$wearIconsText = Read-RepoFile 'wear/src/main/kotlin/com/sza/deviceinfo/wear/ui/apps/systeminfo/WearSectionIcons.kt'
$wearIcons = @{}
foreach ($m in [regex]::Matches($wearIconsText, 'R\.string\.(\w+)\s+to\s+R\.drawable\.(\w+)')) { $wearIcons[$m.Groups[1].Value] = $m.Groups[2].Value }

$groups = @($src.glyphs.groups)
$srcGroupNames = @($groups | ForEach-Object { $_.group })
foreach ($e in $enumNames) { if ($e -notin $srcGroupNames) { Add-Mismatch 'glyphs' "phone group $e has no row in the source table" } }
foreach ($g in $srcGroupNames) { if ($g -notin $enumNames) { Add-Mismatch 'glyphs' "the source table names group $g, which the phone does not have" } }

$meaningToDrawable = @{}
$drawableToMeaning = @{}
$expectedWear = @{}
foreach ($g in $groups) {
    $d = $g.drawable
    $id = if ($g.meaning) { $g.meaning } elseif ($g.provisional) { $g.provisional } elseif ($g.notShipped) { "unshipped:$d" } else { $null }
    $kinds = @('meaning', 'provisional', 'notShipped') | Where-Object { $g[$_] }
    if (@($kinds).Count -gt 1) { Add-Mismatch 'glyphs' "group $($g.group): more than one of meaning, provisional and notShipped is set" }
    if (-not $id) { Add-Mismatch 'glyphs' "group $($g.group): none of meaning, provisional and notShipped is set"; continue }
    if ($phoneIcons[$g.group] -ne $d) { Add-Mismatch 'glyphs' "group $($g.group): SystemInfoGroupIcons uses '$($phoneIcons[$g.group])', the source says '$d'" } else { Add-Ok }
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot "phone/src/main/res/drawable/$d.xml"))) { Add-Mismatch 'glyphs' "phone drawable '$d.xml' does not exist" }
    if ($meaningToDrawable.ContainsKey($id) -and $meaningToDrawable[$id] -ne $d) { Add-Mismatch 'glyphs' "meaning '$id' has two glyphs: $($meaningToDrawable[$id]) and $d" }
    if ($drawableToMeaning.ContainsKey($d) -and $drawableToMeaning[$d] -ne $id) { Add-Mismatch 'glyphs' "glyph '$d' stands for two meanings: $($drawableToMeaning[$d]) and $id" }
    $meaningToDrawable[$id] = $d
    $drawableToMeaning[$d] = $id
    if ($g.wear) { $expectedWear[$g.wear.section] = $d }
}
foreach ($x in $src.glyphs.extraWear) {
    $expectedWear[$x.section] = $x.drawable
    if ($drawableToMeaning[$x.drawable] -ne $x.meaning) { Add-Mismatch 'glyphs' "watch section $($x.section): glyph '$($x.drawable)' is the phone's glyph of '$($drawableToMeaning[$x.drawable])', the source says it stands for '$($x.meaning)'" }
}
foreach ($x in $src.glyphs.outOfScope) {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot "phone/src/main/res/drawable/$($x.drawable).xml"))) { Add-Mismatch 'glyphs' "out-of-scope drawable '$($x.drawable).xml' does not exist" }
}
# watch headers with no phone group of their own (S0035): the watch's own drawing under a meaning of the vocabulary or a
# provisional one; phoneSameDrawing says the phone also ships that drawing and the two must draw the same path data
$watchOnly = @{}
foreach ($x in @($src.glyphs.watchOnly)) {
    $d = $x.drawable
    $kinds = @('meaning', 'provisional') | Where-Object { $x[$_] }
    if (@($kinds).Count -ne 1) { Add-Mismatch 'glyphs' "watch-only section $($x.section): exactly one of meaning and provisional must be set"; continue }
    $id = if ($x.meaning) { $x.meaning } else { $x.provisional }
    if ($expectedWear.ContainsKey($x.section)) { Add-Mismatch 'glyphs' "watch section $($x.section) is given a glyph twice in the source"; continue }
    if ($meaningToDrawable.ContainsKey($id) -and $meaningToDrawable[$id] -ne $d) { Add-Mismatch 'glyphs' "meaning '$id' has two glyphs: $($meaningToDrawable[$id]) and $d" }
    if ($drawableToMeaning.ContainsKey($d) -and $drawableToMeaning[$d] -ne $id) { Add-Mismatch 'glyphs' "glyph '$d' stands for two meanings: $($drawableToMeaning[$d]) and $id" }
    $meaningToDrawable[$id] = $d
    $drawableToMeaning[$d] = $id
    $expectedWear[$x.section] = $d
    $watchOnly[$x.section] = $x
}
foreach ($section in $expectedWear.Keys) {
    $d = $expectedWear[$section]
    if ($wearIcons[$section] -ne $d) { Add-Mismatch 'glyphs' "watch section $section : WearSectionIcons uses '$($wearIcons[$section])', the source says '$d'"; continue }
    $wearFile = Join-Path $repoRoot "wear/src/main/res/drawable/$d.xml"
    $phoneFile = Join-Path $repoRoot "phone/src/main/res/drawable/$d.xml"
    if (-not (Test-Path -LiteralPath $wearFile)) { Add-Mismatch 'glyphs' "watch drawable '$d.xml' does not exist"; continue }
    $wearPaths = Get-PathData (Get-Content -LiteralPath $wearFile -Raw -Encoding UTF8)
    if ($watchOnly.ContainsKey($section) -and -not $watchOnly[$section].phoneSameDrawing) {
        if ($wearPaths.Count -eq 0) { Add-Mismatch 'glyphs' "watch drawable '$d.xml' draws no path" } else { Add-Ok }
        continue
    }
    if (-not (Test-Path -LiteralPath $phoneFile)) { Add-Mismatch 'glyphs' "the phone has no drawable '$d.xml' for the watch drawable to equal"; continue }
    $phonePaths = Get-PathData (Get-Content -LiteralPath $phoneFile -Raw -Encoding UTF8)
    if ($wearPaths.Count -eq 0 -or ($wearPaths -join '|') -ne ($phonePaths -join '|')) { Add-Mismatch 'glyphs' "watch drawable '$d.xml' does not draw the same path data as the phone's" } else { Add-Ok }
}
foreach ($section in $wearIcons.Keys) { if (-not $expectedWear.ContainsKey($section)) { Add-Mismatch 'glyphs' "WearSectionIcons maps section $section, which the source does not give a glyph" } }
# every title a watch header is drawn with has a glyph: the headers are one sibling set (ICON-RENDER 0.25 section 25 rule 1)
$headerTitles = @([regex]::Matches($wearSources, 'titleRes\s*=\s*R\.string\.(system_info_section_\w+|system_info_help_title)\b') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
if ($headerTitles.Count -eq 0) { Add-Mismatch 'glyphs' 'no watch header title string was found in the watch sources, so the sibling-set check is blind' }
foreach ($t in $headerTitles) {
    if ($wearIcons.ContainsKey($t)) { Add-Ok } else { Add-Mismatch 'glyphs' "watch header title '$t' is drawn by SectionDisclosure and has no glyph in WearSectionIcons: a sibling set draws a glyph on every member or on none (ICON-RENDER 0.25 section 25 rule 1)" }
}
$expectedWearFiles = @($expectedWear.Values) + 'ic_launcher_foreground'
foreach ($f in Get-ChildItem -LiteralPath (Join-Path $repoRoot 'wear/src/main/res/drawable') -Filter '*.xml') {
    if ($f.BaseName -notin $expectedWearFiles) { Add-Mismatch 'glyphs' "watch drawable '$($f.Name)' is not declared by the source" }
}

# ---- vocabulary ------------------------------------------------------------------------------------------------
$vocabularyNote = 'checked'
if ($SkipCatalog) {
    $vocabularyNote = 'skipped (-SkipCatalog)'
} else {
    $catalog = $env:DEVICEINFO_CONTRACTS_CATALOG
    if (-not $catalog) {
        $rules = Read-RepoFile 'CLAUDE.md'
        $m = [regex]::Match($rules, 'catalog at [`]([^`]+)[`]')
        if (-not $m.Success) { throw "no 'catalog at `...`' pointer found in CLAUDE.md" }
        $catalog = $m.Groups[1].Value
    }
    $vocabFile = Join-Path $catalog 'iconography/vocabulary.jsonl'
    if (-not (Test-Path -LiteralPath $vocabFile)) { throw "the ICON-SET vocabulary '$vocabFile' is unreachable (use -SkipCatalog offline)" }
    $records = @{}
    foreach ($line in Get-Content -LiteralPath $vocabFile -Encoding UTF8) {
        if ($line.Trim()) { $r = $line | ConvertFrom-Json -AsHashtable; $records[$r.id] = $r }
    }
    $proposalPath = Join-Path $catalog ('iconography/' + $src.glyphs.provisionalProposal)
    $proposalText = if (Test-Path -LiteralPath $proposalPath) { Get-Content -LiteralPath $proposalPath -Raw -Encoding UTF8 } else { $null }
    foreach ($g in $groups) {
        if ($g.meaning) {
            $r = $records[$g.meaning]
            if (-not $r) { Add-Mismatch 'vocabulary' "group $($g.group): meaning '$($g.meaning)' is not in the vocabulary"; continue }
            if ($r.ref.android -ne $g.drawable) { Add-Mismatch 'vocabulary' "group $($g.group): '$($g.meaning)' has Android reference '$($r.ref.android)', the product draws '$($g.drawable)'" } else { Add-Ok }
        } elseif ($g.provisional) {
            if ($records.ContainsKey($g.provisional)) { Add-Mismatch 'vocabulary' "group $($g.group): '$($g.provisional)' is now in the vocabulary - switch the source row from 'provisional' to 'meaning' and check its reference" }
            elseif (-not $proposalText) { Add-Mismatch 'vocabulary' "group $($g.group): the proposal file '$($src.glyphs.provisionalProposal)' is not in the catalog" }
            elseif (-not $proposalText.Contains('`' + $g.provisional + '`')) { Add-Mismatch 'vocabulary' "group $($g.group): the proposal does not name '$($g.provisional)'" }
            else { Add-Ok }
        }
    }
    foreach ($x in @($src.glyphs.watchOnly)) {
        if ($x.provisional) {
            $id = $x.provisional
            if ($records.ContainsKey($id)) { Add-Mismatch 'vocabulary' "watch section $($x.section): '$id' is now in the vocabulary - switch the source row from 'provisional' to 'meaning' and check its reference" }
            elseif (-not $proposalText) { Add-Mismatch 'vocabulary' "the proposal file '$($src.glyphs.provisionalProposal)' is not in the catalog" }
            elseif (-not $proposalText.Contains('`' + $id + '`')) { Add-Mismatch 'vocabulary' "watch section $($x.section): the proposal does not name '$id'" }
            else { Add-Ok }
        } elseif ($x.meaning) {
            $r = $records[$x.meaning]
            if (-not $r) { Add-Mismatch 'vocabulary' "watch section $($x.section): meaning '$($x.meaning)' is not in the vocabulary" }
            elseif ($r.ref.android -ne $x.drawable -and $r.ref.wear -ne $x.drawable) { Add-Mismatch 'vocabulary' "watch section $($x.section): '$($x.meaning)' has Android reference '$($r.ref.android)', the product draws '$($x.drawable)'" }
            elseif ($r.ref.wear -and $r.ref.wear -ne $x.drawable) { Add-Mismatch 'vocabulary' "watch section $($x.section): '$($x.meaning)' has watch reference '$($r.ref.wear)', the product draws '$($x.drawable)'" }
            else { Add-Ok }
        }
    }
    foreach ($x in $src.glyphs.extraWear) {
        $r = $records[$x.meaning]
        if (-not $r) { Add-Mismatch 'vocabulary' "watch section $($x.section): meaning '$($x.meaning)' is not in the vocabulary" }
        elseif ($r.ref.wear -and $r.ref.wear -ne $x.drawable) { Add-Mismatch 'vocabulary' "watch section $($x.section): '$($x.meaning)' has watch reference '$($r.ref.wear)', the product draws '$($x.drawable)'" }
        else { Add-Ok }
    }
    foreach ($g in $groups) {
        if ($g.meaning -and $g.wear) {
            $r = $records[$g.meaning]
            if ($r -and $r.ref.wear -and $r.ref.wear -ne $g.drawable) { Add-Mismatch 'vocabulary' "group $($g.group): '$($g.meaning)' has watch reference '$($r.ref.wear)', the watch draws '$($g.drawable)'" }
        }
    }
}

# ---- report ----------------------------------------------------------------------------------------------------
$exit = if ($script:findings.Count -eq 0) { 0 } else { 1 }
if ($Json) {
    [pscustomobject] @{ ok = $script:okCount; mismatches = $script:findings.Count; vocabulary = $vocabularyNote; exitCode = $exit; findings = $script:findings; elapsedMs = $sw.Elapsed.TotalMilliseconds } | ConvertTo-Json -Depth 4
    exit $exit
}
Write-Host 'design tokens check'
Write-Host "tokens: $tokensPath"
Write-Host "vocabulary section: $vocabularyNote"
foreach ($f in $script:findings) { Write-Host "  FAIL [$($f.area)] $($f.message)" -ForegroundColor Red }
Write-Host ("check-tokens: {0} - {1} check(s) equal, {2} mismatch(es), {3:N0} ms" -f $(if ($exit -eq 0) { 'OK' } else { 'MISMATCH' }), $script:okCount, $script:findings.Count, $sw.Elapsed.TotalMilliseconds)
exit $exit
