#requires -Version 7.0
<#
.SYNOPSIS
    Checks every contract pointer in docs/contracts/ against the shared contracts catalog's front matter.

.DESCRIPTION
    A pointer names a contract by id and the version read; the catalog names the same contract in its
    ```contract front matter. This script reads both sides and reports every mismatch, so a catalog
    version bump that adds duties is caught the day it lands instead of at the next manual re-read
    (which is what let the pointers go stale once, ticket S0016).

    Three pointer shapes are understood:
      - a field table with **Id**, **Version** ("N.M, status (... read YYYY-MM-DD)") and **Home**
        ("shared contracts catalog, `folder/`") rows;
      - a table with "Id | Version read | Home" columns and a "Read YYYY-MM-DD." line below it;
      - a file with an **Id** row but no **Home** - this product's own declaration, which has no
        catalog row to check against; reported and skipped.

    The catalog's location is named once, in the agent-rules file (CLAUDE.md); this script parses it
    from there so the path lives in exactly one file. Set DEVICEINFO_CONTRACTS_CATALOG to override.

    Exit code: 0 every pointer matches; 1 at least one mismatch (id not under its home, version
    differs, version or read date missing or invalid); 2 the catalog or a home README could not be
    reached, or the catalog path could not be resolved.

.PARAMETER Json
    Print one JSON object with the counts and the findings instead of the text report.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $ContractsDir,
    [string] $AgentRulesFile,
    [switch] $Json
)

$ErrorActionPreference = 'Stop'
$script:exitCode = 0
$sw = [System.Diagnostics.Stopwatch]::StartNew()
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

trap { Write-Host "check-pointers: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

function Add-Finding {
    param([string] $Severity, [string] $Message)
    $script:findings += [pscustomobject] @{ severity = $Severity; message = $Message }
    if ($Severity -eq 'MISMATCH' -and $script:exitCode -lt 1) { $script:exitCode = 1 }
}

$script:findings = @()
$checked = @()
$skipped = @()

if (-not $ContractsDir) { $ContractsDir = Join-Path $repoRoot 'docs/contracts' }
if (-not (Test-Path -LiteralPath $ContractsDir)) {
    Write-Host "check-pointers: contracts directory '$ContractsDir' does not exist" -ForegroundColor Red
    exit 2
}

# The catalog path lives in exactly one tracked file (the agent-rules file); parse it from there.
$catalog = $env:DEVICEINFO_CONTRACTS_CATALOG
if (-not $catalog) {
    if (-not $AgentRulesFile) { $AgentRulesFile = Join-Path $repoRoot 'CLAUDE.md' }
    if (-not (Test-Path -LiteralPath $AgentRulesFile)) {
        Write-Host "check-pointers: agent-rules file '$AgentRulesFile' not found; cannot resolve the catalog" -ForegroundColor Red
        exit 2
    }
    $line = (Get-Content -LiteralPath $AgentRulesFile) |
        Where-Object { $_ -match 'catalog at [`]([^`]+)[`]' } |
        Select-Object -First 1
    if (-not $line -or $line -notmatch 'catalog at [`]([^`]+)[`]') {
        Write-Host "check-pointers: no 'catalog at `...`' pointer found in $AgentRulesFile" -ForegroundColor Red
        exit 2
    }
    $catalog = $Matches[1]
}
if (-not (Test-Path -LiteralPath $catalog)) {
    Write-Host "check-pointers: catalog '$catalog' is unreachable (exit 2)" -ForegroundColor Red
    exit 2
}

# The catalog front matter: every ```contract block of one README as a list of id/version/status hashtables.
function Read-CatalogContracts {
    param([string] $Readme)
    $found = @()
    $current = $null
    foreach ($row in (Get-Content -LiteralPath $Readme)) {
        if ($row -match '^```') {
            if ($current) { $found += $current; $current = $null }
            continue
        }
        if ($row -match '^\s*id:\s*(.+?)\s*$') {
            if (-not $current -or $current.id) { if ($current) { $found += $current } ; $current = @{} }
            $current.id = $Matches[1]
        }
        elseif ($current) {
            if ($row -match '^\s*version:\s*([0-9]+\.[0-9]+)\s*$') { $current.version = $Matches[1] }
            elseif ($row -match '^\s*status:\s*(\S+)\s*$') { $current.status = $Matches[1] }
        }
    }
    if ($current) { $found += $current }
    return $found
}

function Test-ReadDate {
    param([string] $ReadDate)
    if (-not $ReadDate) { return $false }
    $parsed = [datetime]::MinValue
    if (-not [datetime]::TryParseExact($ReadDate, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$parsed)) {
        return $false
    }
    if ($parsed.Date -gt [datetime]::UtcNow.Date) { return $false }
    return $true
}

# Extract the pointer rows of one file. Returns a list of [pscustomobject] with id, version, status,
# home, readDate, shape - version/home/readDate may be empty when the file does not carry them.
function Read-PointerRows {
    param([string] $Path)
    $rows = @()
    $lines = Get-Content -LiteralPath $Path
    $fieldIds = @{}
    $fieldVersion = $null
    $fieldHome = $null
    $fieldReadDate = $null
    foreach ($line in $lines) {
        if ($line -match '^\s*\|\s*\*\*Id\*\*\s*\|\s*`([^`]+)`\s*\|') { $fieldIds[$Matches[1]] = $true }
        elseif ($line -match '^\s*\|\s*\*\*Version(\s+read)?\*\*\s*\|\s*([0-9]+\.[0-9]+)(?:\s*,\s*([a-z]+))?') {
            $fieldVersion = [pscustomobject] @{ version = $Matches[2]; status = if ($Matches[3]) { $Matches[3] } else { '' } }
            if ($line -match 'read\s+([0-9]{4}-[0-9]{2}-[0-9]{2})') { $fieldReadDate = $Matches[1] }
        }
        elseif ($line -match '^\s*\|\s*\*\*Home\*\*\s*\|\s*.*`([a-z0-9-]+)/`\s*\|') { $fieldHome = $Matches[1] }
    }
    foreach ($id in $fieldIds.Keys) {
        if ($fieldHome) {
            $rows += [pscustomobject] @{ id = $id; version = $fieldVersion.version; status = $fieldVersion.status; home = $fieldHome; readDate = $fieldReadDate; shape = 'field table' }
        }
        else {
            $rows += [pscustomobject] @{ id = $id; version = $null; status = ''; home = $null; readDate = $null; shape = 'local declaration' }
        }
    }
    if ($rows.Count -gt 0) { return $rows }

    # Table shape: "| Id | Version read | Home | ..." rows plus a "Read YYYY-MM-DD." line, in either order.
    $tableReadDate = $null
    foreach ($line in $lines) {
        if ($line -match '(?i)^\s*Read\s+([0-9]{4}-[0-9]{2}-[0-9]{2})\s*\.') { $tableReadDate = $Matches[1] }
    }
    $inTable = $false
    foreach ($line in $lines) {
        if ($line -match '^\s*\|\s*Id\s*\|.*Version\s*read.*\|\s*Home\s*\|') { $inTable = $true; continue }
        if ($inTable) {
            if ($line -notmatch '^\s*\|') { $inTable = $false; continue }
            $cells = $line -split '\|' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
            if ($cells.Count -ge 3 -and $cells[0] -ne '---' -and $cells[0] -notmatch '^[-: ]+$') {
                $homeFolder = ''
                if ($cells[2] -match '`([a-z0-9-]+)/`') { $homeFolder = $Matches[1] }
                $rows += [pscustomobject] @{ id = $cells[0]; version = $cells[1]; status = ''; home = $homeFolder; readDate = $tableReadDate; shape = 'table' }
            }
        }
    }
    return $rows
}

$files = @(Get-ChildItem -LiteralPath $ContractsDir -Filter '*.md' | Sort-Object Name)
foreach ($file in $files) {
    $rows = Read-PointerRows $file.FullName
    if ($rows.Count -eq 0) {
        $skipped += "$($file.Name): no pointer fields found - skipped"
        Add-Finding 'NOTE' "$($file.Name): no pointer fields found - skipped"
        continue
    }
    foreach ($row in $rows) {
        if (-not $row.home) {
            $skipped += "$($file.Name): $($row.id) - local declaration, no catalog home - skipped"
            Add-Finding 'NOTE' "$($file.Name): $($row.id) - local declaration, no catalog home - skipped"
            continue
        }
        $readme = Join-Path $catalog (Join-Path $row.home 'README.md')
        if (-not (Test-Path -LiteralPath $readme)) {
            Add-Finding 'UNREACHABLE' "$($file.Name): $($row.id) home '$($row.home)/' has no README.md in the catalog"
            $script:exitCode = 2
            continue
        }
        if (-not (Test-ReadDate $row.readDate)) {
            Add-Finding 'MISMATCH' "$($file.Name): $($row.id) has no valid read date (found '$($row.readDate)')"
            continue
        }
        $contracts = @(Read-CatalogContracts $readme | Where-Object { $_.id -eq $row.id })
        if ($contracts.Count -eq 0) {
            Add-Finding 'MISMATCH' "$($file.Name): id '$($row.id)' does not exist in the catalog front matter of '$($row.home)/README.md'"
            continue
        }
        $cat = $contracts[0]
        if (-not $row.version) {
            Add-Finding 'MISMATCH' "$($file.Name): $($row.id) carries no version"
            continue
        }
        if ($row.version -ne $cat.version) {
            Add-Finding 'MISMATCH' "$($file.Name): $($row.id) version $($row.version) != catalog $($cat.version) (read $($row.readDate))"
            continue
        }
        $statusNote = if ($row.status -and $cat.status -and $row.status -ne $cat.status) { " - status differs: pointer $($row.status), catalog $($cat.status)" } else { '' }
        $checked += "$($file.Name): $($row.id) $($row.version) == catalog $($cat.version) ($(if ($cat.status) { $cat.status } else { 'no status' })) (read $($row.readDate))$statusNote"
        if ($statusNote) { Add-Finding 'NOTE' "$($file.Name): $($row.id)$statusNote" }
    }
}

if ($Json) {
    [pscustomobject] @{
        catalog    = $catalog
        checked    = $checked.Count
        skipped    = $skipped.Count
        mismatches = @($script:findings | Where-Object severity -eq 'MISMATCH').Count
        exitCode   = $script:exitCode
        findings   = $script:findings
        elapsedMs  = $sw.Elapsed.TotalMilliseconds
    } | ConvertTo-Json -Depth 4
    exit $script:exitCode
}

Write-Host "contracts pointers check"
Write-Host "catalog: $catalog"
foreach ($line in $checked) { Write-Host "  OK   $line" -ForegroundColor Green }
foreach ($line in $skipped) { Write-Host "  skip $line" -ForegroundColor DarkGray }
foreach ($f in ($script:findings | Where-Object severity -eq 'MISMATCH')) {
    Write-Host "  FAIL $($f.message)" -ForegroundColor Red
}
$mismatchCount = @($script:findings | Where-Object severity -eq 'MISMATCH').Count
Write-Host ("check-pointers: {0} - {1} pointer(s) checked, {2} skipped, {3} mismatch(es), {4:N0} ms" -f `
    ($(if ($script:exitCode -eq 0) { 'OK' } elseif ($script:exitCode -eq 1) { 'MISMATCH' } else { 'UNREACHABLE' })), `
    $checked.Count, $skipped.Count, $mismatchCount, $sw.Elapsed.TotalMilliseconds)
exit $script:exitCode
