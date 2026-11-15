# Port ledger core - shared by every script of tools/port-ledger (S0003, CLAUDE.md section 2 rule 3).
# Dot-sourced, never run directly.
#
# docs/port-ledger.jsonl is one JSON object per line, one line per ported file. Mandatory fields:
#   source        FastMediaSorter path, repo-relative, forward slashes
#   sourceSha256  SHA-256 (lower-case hex) of the source bytes at port time or at the last carry
#   destination   this repository's path, repo-relative, forward slashes
#   portedOn      yyyy-MM-dd
# Optional fields (older rows need not carry them):
#   destinationSha256  SHA-256 of the destination at port, carry or the dated baseline backfill
#   destinationHashedOn  yyyy-MM-dd on which that destination hash was recorded
#   carriedOn     yyyy-MM-dd, set when a newer upstream version was carried across
#   decision      { sourceSha256, note, decidedOn } - a deliberate decision NOT to carry, pinned to the
#                 upstream version it was made about; the next upstream change is drift again
#
# Invariants: the hash is always computed, never typed; a path never leaves its repository root; the ledger is
# written atomically as UTF-8 without BOM with LF endings, sorted by (source, destination), so a carry is a
# one-line diff. The upstream tree is only ever read.

Set-StrictMode -Version Latest

$script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script:LedgerFile = Join-Path $script:RepoRoot 'docs\port-ledger.jsonl'
$script:ProfileFile = Join-Path $script:RepoRoot '.sza-profile.json'
$script:SourceRootOrigin = $null
$script:RequiredFields = @('source', 'sourceSha256', 'destination', 'portedOn')
$script:FieldOrder = @('source', 'sourceSha256', 'destination', 'destinationSha256', 'destinationHashedOn', 'portedOn', 'carriedOn', 'decision')

function Get-PortfolioRegistryFile {
    # The portfolio registry, repos.json: under SZA_PORTFOLIO_ROOT, else under %USERPROFILE%\.sza\portfolio. The same
    # place the portfolio tools read; it lives outside every repository, so no path to a checkout is tracked here.
    $root = $env:SZA_PORTFOLIO_ROOT
    if ([string]::IsNullOrWhiteSpace($root)) {
        $profileDir = $env:USERPROFILE
        if ([string]::IsNullOrWhiteSpace($profileDir)) { $profileDir = [Environment]::GetFolderPath('UserProfile') }
        $root = Join-Path (Join-Path $profileDir '.sza') 'portfolio'
    }
    return (Join-Path $root 'repos.json')
}

function Get-ExtractionSourceProject {
    # extraction.sourceProject of .sza-profile.json (HARNESS-PROFILE 0.17 rule 13): the registry key of the source
    # product. $null when the profile, the block or the key is absent; a profile that is not JSON throws.
    param([string] $ProfileFile = $script:ProfileFile)
    if (-not (Test-Path -LiteralPath $ProfileFile -PathType Leaf)) { return $null }
    try { $doc = [System.IO.File]::ReadAllText($ProfileFile) | ConvertFrom-Json -AsHashtable -ErrorAction Stop }
    catch { throw "Profile '$ProfileFile' is not valid JSON: $($_.Exception.Message)" }
    if (($doc -isnot [hashtable]) -or ($doc['extraction'] -isnot [hashtable])) { return $null }
    $project = $doc['extraction']['sourceProject']
    if (($project -is [string]) -and -not [string]::IsNullOrWhiteSpace($project)) { return $project }
    return $null
}

function Get-RegistrySourceRoot {
    # The path the portfolio registry holds for one project key (PORT-LEDGER 0.1 rule 8, third step).
    param([Parameter(Mandatory)][string] $Project, [string] $RegistryFile = (Get-PortfolioRegistryFile))
    if (-not (Test-Path -LiteralPath $RegistryFile -PathType Leaf)) {
        throw "Portfolio registry '$RegistryFile' not found, so project '$Project' has no path. Pass -SourceRoot or set SZA_PORT_SOURCE_ROOT."
    }
    try { $doc = [System.IO.File]::ReadAllText($RegistryFile) | ConvertFrom-Json -AsHashtable -ErrorAction Stop }
    catch { throw "Portfolio registry '$RegistryFile' is not valid JSON: $($_.Exception.Message)" }
    $entry = $null
    if ($doc -is [hashtable]) { $entry = @($doc['repos']) | Where-Object { ($_ -is [hashtable]) -and ($_['key'] -ceq $Project) } | Select-Object -First 1 }
    if ($null -eq $entry) { throw "Portfolio registry '$RegistryFile' has no project '$Project'. Pass -SourceRoot or set SZA_PORT_SOURCE_ROOT." }
    $path = $entry['path']
    if (($path -isnot [string]) -or [string]::IsNullOrWhiteSpace($path)) { throw "Portfolio registry '$RegistryFile' holds no path for project '$Project'." }
    return $path
}

function Get-SourceRoot {
    # PORT-LEDGER 0.1 rule 8: an explicit argument, then SZA_PORT_SOURCE_ROOT, then this product's own variable
    # (DEVICEINFO_FMS_ROOT, accepted until its next release), then the registry path of the project that
    # extraction.sourceProject names. No path to a checkout is kept in a tracked file. A root that cannot be found
    # throws, which every script maps to exit 2 (rule 7). $script:SourceRootOrigin says where the root came from.
    param([string] $SourceRoot)
    if ($SourceRoot) { $candidate = $SourceRoot; $origin = '-SourceRoot' }
    elseif ($env:SZA_PORT_SOURCE_ROOT) { $candidate = $env:SZA_PORT_SOURCE_ROOT; $origin = 'SZA_PORT_SOURCE_ROOT' }
    elseif ($env:DEVICEINFO_FMS_ROOT) { $candidate = $env:DEVICEINFO_FMS_ROOT; $origin = 'DEVICEINFO_FMS_ROOT' }
    else {
        $project = Get-ExtractionSourceProject
        if (-not $project) {
            throw "No source root: pass -SourceRoot, set SZA_PORT_SOURCE_ROOT, or declare extraction.sourceProject in '$script:ProfileFile'."
        }
        $candidate = Get-RegistrySourceRoot $project
        $origin = "registry:$project"
    }
    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) {
        throw "Source root '$candidate' ($origin) not found. Pass -SourceRoot or set SZA_PORT_SOURCE_ROOT."
    }
    $script:SourceRootOrigin = $origin
    return (Resolve-Path -LiteralPath $candidate).Path
}

function Get-DestinationRoot {
    param([string] $DestinationRoot)
    if (-not $DestinationRoot) { return $script:RepoRoot }
    if (-not (Test-Path -LiteralPath $DestinationRoot -PathType Container)) { throw "Destination root '$DestinationRoot' not found." }
    return (Resolve-Path -LiteralPath $DestinationRoot).Path
}

function Get-LedgerFile {
    param([string] $Ledger)
    if ($Ledger) { $Ledger } else { $script:LedgerFile }
}

function ConvertTo-RelativeLedgerPath {
    # Backslashes become forward slashes; anything absolute or climbing out ('..') is refused, because a ledger
    # row may only relate two files inside their own trees.
    param([Parameter(Mandatory)][string] $Path, [Parameter(Mandatory)][string] $Role)
    $normalized = (($Path -replace '\\', '/').Trim()) -replace '^\./', ''
    $segments = @($normalized -split '/')
    if (($normalized -eq '') -or $normalized.StartsWith('/') -or ($normalized -match '^[A-Za-z]:') -or ($segments -contains '..')) {
        throw "$Role path '$Path' must be a relative path that stays inside its repository."
    }
    return $normalized
}

function Get-FileSha256 {
    param([Parameter(Mandatory)][string] $Path)
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Read-LedgerRows {
    # A missing or empty ledger is a valid, empty ledger: nothing has been ported yet.
    param([Parameter(Mandatory)][string] $Path)
    $rows = [System.Collections.Generic.List[hashtable]]::new()
    if (-not (Test-Path -LiteralPath $Path)) { return , $rows }
    $lineNumber = 0
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        $lineNumber++
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $row = $line | ConvertFrom-Json -AsHashtable -ErrorAction Stop }
        catch { throw "$Path line ${lineNumber} is not valid JSON: $($_.Exception.Message)" }
        foreach ($field in $script:RequiredFields) {
            if (-not $row.ContainsKey($field) -or [string]::IsNullOrWhiteSpace([string]$row[$field])) { throw "$Path line ${lineNumber} has no '$field'." }
        }
        if ($row['sourceSha256'] -notmatch '^[0-9a-f]{64}$') { throw "$Path line ${lineNumber}: sourceSha256 is not a lower-case hex SHA-256." }
        if ($row.ContainsKey('destinationSha256') -and $row['destinationSha256'] -notmatch '^[0-9a-f]{64}$') { throw "$Path line ${lineNumber}: destinationSha256 is not a lower-case hex SHA-256." }
        if ($row.ContainsKey('destinationHashedOn') -and $row['destinationHashedOn'] -notmatch '^\d{4}-\d{2}-\d{2}$') { throw "$Path line ${lineNumber}: destinationHashedOn is not yyyy-MM-dd." }
        $rows.Add($row)
    }
    # The leading comma keeps the list whole on the way out; a bare return would hand an empty ledger back as $null.
    return , $rows
}

function Write-LedgerRows {
    param([Parameter(Mandatory)][string] $Path, [Parameter(Mandatory)] $Rows)
    $sorted = @($Rows) | Sort-Object -Property { $_['source'] }, { $_['destination'] }
    $lines = foreach ($row in $sorted) {
        $ordered = [ordered]@{}
        foreach ($field in $script:FieldOrder) { if ($row.ContainsKey($field)) { $ordered[$field] = $row[$field] } }
        # A local writer must not discard fields introduced by another compatible ledger reader.
        foreach ($field in @($row.Keys | Where-Object { $_ -notin $script:FieldOrder } | Sort-Object)) { $ordered[$field] = $row[$field] }
        $ordered | ConvertTo-Json -Compress -Depth 100 -EscapeHandling Default
    }
    $content = if ($lines) { ($lines -join "`n") + "`n" } else { '' }
    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) { New-Item -ItemType Directory -Path $directory -Force | Out-Null }
    $staging = "$Path.writetmp"
    [System.IO.File]::WriteAllText($staging, $content, [System.Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $staging -Destination $Path -Force
}

function Get-LedgerStates {
    # One state per row: 'in step', 'decided', 'DRIFT', 'SOURCE GONE' or 'NO DEST'.
    param([Parameter(Mandatory)] $Rows, [Parameter(Mandatory)][string] $SourceRoot, [Parameter(Mandatory)][string] $DestinationRoot)
    $states = foreach ($row in $Rows) {
        $sourceFile = Join-Path $SourceRoot $row['source']
        $destinationFile = Join-Path $DestinationRoot $row['destination']
        $current = if (Test-Path -LiteralPath $sourceFile -PathType Leaf) { Get-FileSha256 $sourceFile } else { 'missing' }
        $decision = if ($row.ContainsKey('decision')) { $row['decision'] } else { $null }
        $covered = ($null -ne $decision) -and ($decision['sourceSha256'] -eq $current)
        $state = if (-not (Test-Path -LiteralPath $destinationFile -PathType Leaf)) { 'NO DEST' }
                 elseif ($current -eq $row['sourceSha256']) { 'in step' }
                 elseif ($covered) { 'decided' }
                 elseif ($current -eq 'missing') { 'SOURCE GONE' }
                 else { 'DRIFT' }
        [pscustomobject]@{
            State       = $state
            Source      = $row['source']
            Destination = $row['destination']
            AnchoredOn  = if ($row.ContainsKey('carriedOn')) { $row['carriedOn'] } else { $row['portedOn'] }
            Note        = if ($covered) { $decision['note'] } else { $null }
        }
    }
    return , @($states)
}
