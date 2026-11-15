#requires -Version 7.0
<#
.SYNOPSIS
    The ship-together surfaces check (S0020): string-key parity en/ru/uk per module, and permission parity across
    the AndroidManifest.xml files, docs/SECURITY_INVENTORY.md, the three privacy pages and the Data safety answers.

.DESCRIPTION
    The surfaces manifest docs/DOCS_SURFACES.md (DOCUMENTATION_CONCEPT section 5, invariant 17) lists every
    user-facing surface and every authored locale. This check enforces the two columns of it that a machine can
    hold:

      string-key parity   per module (phone: src/main + src/restricted, wear: src/main) the key sets of values,
                          values-ru and values-uk must agree; a base key marked translatable="false" is exempt from
                          the translated locales (the platform's own marker, such as app_name), and a key a
                          translated locale carries without the base locale is an orphan.
      permission parity   every uses-permission of phone/src/main, phone/src/restricted and wear/src/main is named
                          by the permission inventory (SECURITY_INVENTORY section 1, per package), by the
                          permissions section of each privacy page and by a permission row of
                          docs/play/PLAY_DATA_SAFETY.md; and every permission token those surfaces name is declared
                          by a manifest (invariant 14: the privacy page, the permission list and the Data safety
                          form say the same thing). A token inside a row that is not a permission statement (a
                          negation such as "Neither package declares INTERNET") is out of scope by construction:
                          only rows whose first cell speaks of permissions are read.

    Exit code: 0 in step; 1 at least one mismatch; 2 the check could not run (wrong repo root, a required file
    missing or unreadable). The repository is only read.

.PARAMETER RepoRoot
    The repository root. Default: the tree this script's tools/docs directory sits in. The self-test passes a
    throw-away tree shaped like the repository.

.PARAMETER Json
    Print one JSON object with the counts and the mismatches instead of the text report.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $RepoRoot,
    [switch] $Json
)

$ErrorActionPreference = 'Stop'
trap { Write-Host "check-surfaces: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
}
$required = @('phone', 'wear', 'docs', 'site')
foreach ($name in $required) {
    if (-not (Test-Path (Join-Path $RepoRoot $name))) {
        throw "RepoRoot '$RepoRoot' does not look like this repository (no $name/ directory)."
    }
}

$mismatches = [System.Collections.Generic.List[string]]::new()

# ---------------------------------------------------------------- string-key parity per module
# Keys are the name attributes of <string>, <string-array> and <plurals> elements in every res values
# directory of the module's source sets, united per locale.
$elementRegex = [regex]'<(string|string-array|plurals)\b([^>]*)>'
$nameRegex = [regex]'name\s*=\s*"([^"]+)"'
$nonTranslatableRegex = [regex]'translatable\s*=\s*"false"'
$moduleResRoots = [ordered]@{
    phone = @('phone/src/main/res', 'phone/src/restricted/res')
    wear  = @('wear/src/main/res')
}
$stringCounts = @{}
foreach ($moduleName in $moduleResRoots.Keys) {
    $keys = @{}
    foreach ($locale in 'values', 'values-ru', 'values-uk') {
        $set = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        $exempt = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($resRoot in $moduleResRoots[$moduleName]) {
            $localeDir = Join-Path (Join-Path $RepoRoot $resRoot) $locale
            if (-not (Test-Path $localeDir)) { continue }
            foreach ($file in (Get-ChildItem -Path $localeDir -Filter '*.xml' -File)) {
                $text = Get-Content -Path $file.FullName -Raw
                foreach ($element in $elementRegex.Matches($text)) {
                    $name = $nameRegex.Match($element.Groups[2].Value)
                    if (-not $name.Success) { continue }
                    [void]$set.Add($name.Groups[1].Value)
                    if ($nonTranslatableRegex.IsMatch($element.Groups[2].Value)) {
                        [void]$exempt.Add($name.Groups[1].Value)
                    }
                }
            }
        }
        $keys[$locale] = $set
        if ($locale -eq 'values') { $keys['exempt'] = $exempt }
    }
    $stringCounts[$moduleName] = @{
        values    = $keys['values'].Count
        ru        = $keys['values-ru'].Count
        uk        = $keys['values-uk'].Count
        exempt    = $keys['exempt'].Count
    }
    foreach ($key in $keys['values']) {
        if ($keys['exempt'].Contains($key)) { continue }
        if (-not $keys['values-ru'].Contains($key)) {
            $mismatches.Add("strings $moduleName`: key '$key' of values is missing from values-ru")
        }
        if (-not $keys['values-uk'].Contains($key)) {
            $mismatches.Add("strings $moduleName`: key '$key' of values is missing from values-uk")
        }
    }
    foreach ($locale in 'values-ru', 'values-uk') {
        foreach ($key in $keys[$locale]) {
            if (-not $keys['values'].Contains($key)) {
                $mismatches.Add("strings $moduleName`: $locale carries key '$key' that values does not declare")
            }
        }
    }
}

# ---------------------------------------------------------------- permission parity
$permissionShortRegex = [regex]'<uses-permission\s+android:name="android\.permission\.([^"]+)"'
$manifestFiles = [ordered]@{
    phone = @('phone/src/main/AndroidManifest.xml', 'phone/src/restricted/AndroidManifest.xml')
    wear  = @('wear/src/main/AndroidManifest.xml')
}
$declared = @{}
foreach ($packageName in $manifestFiles.Keys) {
    $set = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($relative in $manifestFiles[$packageName]) {
        $path = Join-Path $RepoRoot $relative
        if (-not (Test-Path $path)) {
            # The restricted manifest is optional; the two main manifests are the product's declaration.
            if ($relative -notlike '*restricted*') {
                throw "Required manifest is missing: $relative"
            }
            continue
        }
        $text = Get-Content -Path $path -Raw
        foreach ($match in $permissionShortRegex.Matches($text)) {
            $short = $match.Groups[1].Value
            if ($short.Contains('.')) { $short = ($short -split '\.')[-1] }
            [void]$set.Add($short)
        }
    }
    $declared[$packageName] = $set
}
$declaredAll = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
foreach ($packageName in $declared.Keys) { foreach ($permission in $declared[$packageName]) { [void]$declaredAll.Add($permission) } }

# SECURITY_INVENTORY.md section 1: | Package | Declared in | Permission | ... rows.
$inventoryPath = Join-Path $RepoRoot 'docs/SECURITY_INVENTORY.md'
if (-not (Test-Path $inventoryPath)) { throw 'Required file is missing: docs/SECURITY_INVENTORY.md' }
$packageMap = @{ Phone = 'phone'; Watch = 'wear' }
$inventoryRows = @()
$inventoryLines = (Get-Content -Path $inventoryPath -Raw) -split "\r?\n"
$inInventorySection = $false
foreach ($line in $inventoryLines) {
    if ($line -match '^\s*##\s') {
        $inInventorySection = ($line -match '^\s*##\s+1\.')
        continue
    }
    if (-not $inInventorySection -or -not $line.StartsWith('|')) { continue }
    $cells = $line.Trim().Trim('|').Split('|') | ForEach-Object { $_.Trim() }
    if ($cells.Count -lt 3) { continue }
    $packageCell = $cells[0]
    if ($packageCell -in @('Package', '---')) { continue }
    $permissionCell = $cells[2] -replace '`', ''
    if (-not $packageMap.ContainsKey($packageCell)) {
        $mismatches.Add("permissions SECURITY_INVENTORY section 1 has a row with unknown package '$packageCell'")
        continue
    }
    if ($permissionCell -notmatch '^[A-Z][A-Z_]+$') {
        $mismatches.Add("permissions SECURITY_INVENTORY section 1 row for $packageCell has no readable permission cell ('$($cells[2])')")
        continue
    }
    $inventoryRows += @{ Package = $packageMap[$packageCell]; Permission = $permissionCell }
}

# The three privacy pages: the permissions section between <h2 id="permissions"> and the next <h2.
$codeTokenRegex = [regex]'<code>([A-Z][A-Z_]{2,})</code>'
$privacyTokens = @{}
foreach ($page in 'site/privacy.html', 'site/privacy-ru.html', 'site/privacy-uk.html') {
    $path = Join-Path $RepoRoot $page
    if (-not (Test-Path $path)) { throw "Required privacy page is missing: $page" }
    $html = Get-Content -Path $path -Raw
    $start = $html.IndexOf('<h2 id="permissions">')
    if ($start -lt 0) {
        $mismatches.Add("permissions $page has no permissions section")
        $privacyTokens[$page] = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        continue
    }
    $end = $html.IndexOf('<h2', $start + 1)
    if ($end -lt 0) { $end = $html.Length }
    $section = $html.Substring($start, $end - $start)
    $set = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($match in $codeTokenRegex.Matches($section)) { [void]$set.Add($match.Groups[1].Value) }
    $privacyTokens[$page] = $set
}

# PLAY_DATA_SAFETY.md: permission tokens from the table rows whose first cell speaks of permissions.
$dataSafetyPath = Join-Path $RepoRoot 'docs/play/PLAY_DATA_SAFETY.md'
if (-not (Test-Path $dataSafetyPath)) { throw 'Required file is missing: docs/play/PLAY_DATA_SAFETY.md' }
$dataSafetyTokens = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$dataSafetyRows = 0
foreach ($line in ((Get-Content -Path $dataSafetyPath -Raw) -split "\r?\n")) {
    if (-not $line.StartsWith('|')) { continue }
    $firstCell = ($line -split '\|')[1].Trim()
    if ($firstCell -notmatch '(?i)permission') { continue }
    $dataSafetyRows++
    foreach ($match in [regex]::Matches($line, '`([A-Z][A-Z_]{2,})`')) {
        [void]$dataSafetyTokens.Add($match.Groups[1].Value)
    }
}

# --- the parity rules themselves
foreach ($packageName in $declared.Keys) {
    $inventoryPermissions = @($inventoryRows | Where-Object Package -eq $packageName | ForEach-Object Permission)
    foreach ($permission in $declared[$packageName]) {
        if ($inventoryPermissions -notcontains $permission) {
            $mismatches.Add("permissions $packageName manifest declares '$permission', SECURITY_INVENTORY section 1 does not list it")
        }
    }
    foreach ($row in ($inventoryRows | Where-Object Package -eq $packageName)) {
        if (-not $declared[$packageName].Contains($row.Permission)) {
            $mismatches.Add("permissions SECURITY_INVENTORY lists '$($row.Permission)' for $packageName, no manifest of that package declares it")
        }
    }
}
foreach ($page in $privacyTokens.Keys) {
    foreach ($permission in $declaredAll) {
        if (-not $privacyTokens[$page].Contains($permission)) {
            $mismatches.Add("permissions $page does not name '$permission'")
        }
    }
    foreach ($token in $privacyTokens[$page]) {
        if (-not $declaredAll.Contains($token)) {
            $mismatches.Add("permissions $page names '$token', no manifest declares it")
        }
    }
}
foreach ($permission in $declaredAll) {
    if (-not $dataSafetyTokens.Contains($permission)) {
        $mismatches.Add("permissions PLAY_DATA_SAFETY does not name '$permission'")
    }
}
foreach ($token in $dataSafetyTokens) {
    if (-not $declaredAll.Contains($token)) {
        $mismatches.Add("permissions PLAY_DATA_SAFETY names '$token', no manifest declares it")
    }
}

# ---------------------------------------------------------------- report
$permissionCount = $inventoryRows.Count
if ($Json) {
    [ordered]@{
        repoRoot    = $RepoRoot
        strings     = $stringCounts
        permissions = [ordered]@{
            declared          = [ordered]@{ phone = @($declared['phone'] | Sort-Object); wear = @($declared['wear'] | Sort-Object) }
            inventoryRows     = $permissionCount
            dataSafetyRows    = $dataSafetyRows
            dataSafetyTokens  = @($dataSafetyTokens | Sort-Object)
            privacyPageTokens = [ordered]@{
                'site/privacy.html'    = $privacyTokens['site/privacy.html'].Count
                'site/privacy-ru.html' = $privacyTokens['site/privacy-ru.html'].Count
                'site/privacy-uk.html' = $privacyTokens['site/privacy-uk.html'].Count
            }
        }
        mismatches  = @($mismatches)
    } | ConvertTo-Json -Depth 5
    exit ([int]($mismatches.Count -gt 0))
}

Write-Host "Surfaces check: $RepoRoot"
foreach ($moduleName in $stringCounts.Keys) {
    $c = $stringCounts[$moduleName]
    Write-Host ("Strings {0}: values {1} (exempt translatable=""false"" {2}), values-ru {3}, values-uk {4}" -f `
        $moduleName, $c['values'], $c['exempt'], $c['ru'], $c['uk'])
}
$phoneList = (@($declared['phone'] | Sort-Object) -join ', ')
$wearList = (@($declared['wear'] | Sort-Object) -join ', ')
Write-Host "Permissions declared: phone [$($phoneList -replace '^$','none')], wear [$($wearList -replace '^$','none')]"
Write-Host "Permission surfaces: inventory rows $permissionCount, privacy page tokens $(($privacyTokens['site/privacy.html'] | Measure-Object).Count)/$(($privacyTokens['site/privacy-ru.html'] | Measure-Object).Count)/$(($privacyTokens['site/privacy-uk.html'] | Measure-Object).Count), Data safety permission rows $dataSafetyRows"
foreach ($mismatch in $mismatches) {
    Write-Host "  MISMATCH $mismatch" -ForegroundColor Yellow
}
if ($mismatches.Count -eq 0) {
    Write-Host "OK: string keys agree across en/ru/uk per module, and the manifests, the inventory, the privacy pages and the Data safety answers name the same permissions."
    exit 0
}
Write-Host "OPEN: $($mismatches.Count) surface mismatch(es) - land the missing surface or record why beside the claim."
exit 1
