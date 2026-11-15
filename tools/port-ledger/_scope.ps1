# Port scope core - shared by check-scope.ps1 and record-decision.ps1 (S0018, CLAUDE.md section 2 rule 2).
# Dot-sourced, never run directly. Builds on _ledger.ps1.
#
# docs/port-scope.json says what part of the upstream checkout is watched (PORT-LEDGER 0.1 rule 5):
#   include   globs over upstream paths, relative to the upstream root, forward slashes
#   exclude   [{ glob, reason }] - a file an exclusion covers is out of the watch for good; a reason is required
#   strings   (this repository's addition, not a contract field) the string keys watched by name prefix:
#             scan (upstream globs), prefixes, destinationScan (globs over this repository)
# Glob syntax: `*` and `?` stay inside one path segment, `**/` is any number of segments (also none), a trailing
# `/**` is everything below. Matching is case-sensitive.
#
# docs/port-decisions.jsonl holds the decisions that are NOT ledger rows - an upstream item that was never ported and
# is deliberately left out, one JSON object per line:
#   kind          'file' or 'string'
#   item          upstream path (file) or string key name (string)
#   sourceSha256  file: the upstream file's hash the decision was made about - the next change resurfaces it
#   sourceFile    string: the upstream resource file that declares the key (the locale-free values/ file when several)
#   pinnedValue   string: the key's value in that file when it was decided - a changed value resurfaces it
#   note          the reason, one line
#   decidedOn     yyyy-MM-dd
#
# Invariants: the upstream tree is only read; a ledger row always wins over a decision; the decisions file is written
# atomically as UTF-8 without BOM with LF endings, sorted by (kind, item).

Set-StrictMode -Version Latest

$script:ScopeFile = Join-Path $script:RepoRoot 'docs\port-scope.json'
$script:DecisionsFile = Join-Path $script:RepoRoot 'docs\port-decisions.jsonl'

function Get-ScopeFile { param([string] $Scope) if ($Scope) { $Scope } else { $script:ScopeFile } }
function Get-DecisionsFile { param([string] $Decisions) if ($Decisions) { $Decisions } else { $script:DecisionsFile } }

function ConvertTo-GlobRegex {
    param([Parameter(Mandatory)][string] $Glob)
    $pattern = [System.Text.StringBuilder]::new('^')
    $i = 0
    while ($i -lt $Glob.Length) {
        $c = $Glob[$i]
        if ($c -eq '*') {
            if (($i + 1 -lt $Glob.Length) -and ($Glob[$i + 1] -eq '*')) {
                if (($i + 2 -lt $Glob.Length) -and ($Glob[$i + 2] -eq '/')) { [void]$pattern.Append('(?:.*/)?'); $i += 3; continue }
                [void]$pattern.Append('.*'); $i += 2; continue
            }
            [void]$pattern.Append('[^/]*')
        }
        elseif ($c -eq '?') { [void]$pattern.Append('[^/]') }
        else { [void]$pattern.Append([regex]::Escape([string] $c)) }
        $i++
    }
    [void]$pattern.Append('$')
    return [regex]::new($pattern.ToString(), [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
}

function Get-GlobWalkRoot {
    # The literal directory the glob starts in, so a scan never walks the whole upstream tree (build output, temp/).
    param([Parameter(Mandatory)][string] $Glob)
    $segments = @($Glob -split '/')
    $literal = [System.Collections.Generic.List[string]]::new()
    for ($i = 0; $i -lt $segments.Count - 1; $i++) {
        if ($segments[$i] -match '[*?]') { break }
        $literal.Add($segments[$i])
    }
    return ($literal -join '/')
}

function Find-GlobMatches {
    # Every file under $Root whose root-relative path matches one of the globs, as a sorted string array.
    param([Parameter(Mandatory)][string] $Root, [Parameter(Mandatory)][string[]] $Globs)
    $found = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($glob in $Globs) {
        $walk = Get-GlobWalkRoot $glob
        $start = if ($walk) { Join-Path $Root $walk } else { $Root }
        if (-not (Test-Path -LiteralPath $start -PathType Container)) { continue }
        $regex = ConvertTo-GlobRegex $glob
        foreach ($file in [System.IO.Directory]::EnumerateFiles($start, '*', [System.IO.SearchOption]::AllDirectories)) {
            $relative = $file.Substring($Root.Length).TrimStart('\', '/') -replace '\\', '/'
            if ($regex.IsMatch($relative)) { [void]$found.Add($relative) }
        }
    }
    $sorted = [string[]]@($found)
    [array]::Sort($sorted, [System.StringComparer]::Ordinal)
    return , $sorted
}

function Read-ScopeFile {
    param([Parameter(Mandatory)][string] $Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Scope file '$Path' not found." }
    try { $scope = [System.IO.File]::ReadAllText($Path) | ConvertFrom-Json -AsHashtable -ErrorAction Stop }
    catch { throw "$Path is not valid JSON: $($_.Exception.Message)" }
    if ($scope -isnot [hashtable]) { throw "$Path must hold one JSON object." }

    function Test-GlobList($List, [string] $What) {
        if (($null -eq $List) -or ($List -is [string]) -or ($List -isnot [System.Collections.IEnumerable]) -or (@($List).Count -eq 0)) { throw "$Path '$What' must be a non-empty list of globs." }
        foreach ($glob in $List) {
            if (($glob -isnot [string]) -or [string]::IsNullOrWhiteSpace($glob)) { throw "$Path '$What' holds an empty or non-string glob." }
            if ($glob.StartsWith('/') -or ($glob -match '^[A-Za-z]:') -or (@($glob -split '/') -contains '..')) { throw "$Path '$What' glob '$glob' must stay relative." }
        }
    }
    Test-GlobList $scope['include'] 'include'
    if ($scope.ContainsKey('exclude')) {
        foreach ($entry in @($scope['exclude'])) {
            if (($entry -isnot [hashtable]) -or [string]::IsNullOrWhiteSpace([string] $entry['glob'])) { throw "$Path 'exclude' entries need a 'glob'." }
            if ([string]::IsNullOrWhiteSpace([string] $entry['reason'])) { throw "$Path exclusion '$($entry['glob'])' has no reason; PORT-LEDGER rule 5 requires one." }
        }
    }
    if ($scope.ContainsKey('strings')) {
        $strings = $scope['strings']
        if ($strings -isnot [hashtable]) { throw "$Path 'strings' must be an object." }
        Test-GlobList $strings['scan'] 'strings.scan'
        Test-GlobList $strings['destinationScan'] 'strings.destinationScan'
        $prefixes = @($strings['prefixes'])
        if (($prefixes.Count -eq 0) -or (@($prefixes | Where-Object { [string]::IsNullOrWhiteSpace([string] $_) }).Count -gt 0)) { throw "$Path 'strings.prefixes' must be a non-empty list of key prefixes." }
    }
    return $scope
}

function Read-DecisionRows {
    # A missing or empty decisions file is valid: nothing was decided yet.
    param([Parameter(Mandatory)][string] $Path)
    $rows = [System.Collections.Generic.List[hashtable]]::new()
    if (-not (Test-Path -LiteralPath $Path)) { return , $rows }
    $lineNumber = 0
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        $lineNumber++
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $row = $line | ConvertFrom-Json -AsHashtable -ErrorAction Stop }
        catch { throw "$Path line ${lineNumber} is not valid JSON: $($_.Exception.Message)" }
        foreach ($field in 'kind', 'item', 'note', 'decidedOn') {
            if (-not $row.ContainsKey($field) -or [string]::IsNullOrWhiteSpace([string] $row[$field])) { throw "$Path line ${lineNumber} has no '$field'." }
        }
        if ($row['kind'] -notin 'file', 'string') { throw "$Path line ${lineNumber}: kind must be 'file' or 'string'." }
        if ($row['kind'] -eq 'file') {
            if (-not $row.ContainsKey('sourceSha256') -or ($row['sourceSha256'] -notmatch '^[0-9a-f]{64}$')) { throw "$Path line ${lineNumber}: a file decision needs a lower-case hex sourceSha256." }
        }
        else {
            if (-not $row.ContainsKey('sourceFile') -or [string]::IsNullOrWhiteSpace([string] $row['sourceFile'])) { throw "$Path line ${lineNumber}: a string decision needs a sourceFile." }
            if (-not $row.ContainsKey('pinnedValue')) { throw "$Path line ${lineNumber}: a string decision needs a pinnedValue." }
        }
        $rows.Add($row)
    }
    return , $rows
}

function Write-DecisionRows {
    param([Parameter(Mandatory)][string] $Path, [Parameter(Mandatory)] $Rows)
    $sorted = @($Rows) | Sort-Object -Property { $_['kind'] }, { $_['item'] }
    $lines = foreach ($row in $sorted) {
        $ordered = [ordered]@{}
        foreach ($field in 'kind', 'item', 'sourceSha256', 'sourceFile', 'pinnedValue', 'note', 'decidedOn') { if ($row.ContainsKey($field)) { $ordered[$field] = $row[$field] } }
        $ordered | ConvertTo-Json -Compress -Depth 3 -EscapeHandling Default
    }
    $content = if ($lines) { ($lines -join "`n") + "`n" } else { '' }
    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) { New-Item -ItemType Directory -Path $directory -Force | Out-Null }
    $staging = "$Path.writetmp"
    [System.IO.File]::WriteAllText($staging, $content, [System.Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $staging -Destination $Path -Force
}

function Get-UpstreamFiles {
    # The in-scope upstream files: matched by an include glob and not covered by an exclusion. Throws when the include
    # globs see nothing at all - a scope that sees nothing is blind, and a blind check must not pass as a clean one.
    param([Parameter(Mandatory)][string] $SourceRoot, [Parameter(Mandatory)] $Scope)
    $included = Find-GlobMatches $SourceRoot @($Scope['include'])
    if ($included.Count -eq 0) { throw "The include globs of the scope match no file under '$SourceRoot'; a scope that sees nothing is blind, not clean." }
    $exclusions = @($(if ($Scope.ContainsKey('exclude')) { $Scope['exclude'] } else { @() }) | ForEach-Object { ConvertTo-GlobRegex ([string] $_['glob']) })
    $kept = @($included | Where-Object { $path = $_; -not ($exclusions | Where-Object { $_.IsMatch($path) }) })
    return , $kept
}

function Get-StringElements {
    # Every string, plurals and string-array element declared in the resource files matching $Globs under $Root:
    # a hashtable key name -> list of { file; value } (one entry per file that declares it, value = the element's
    # inner text, trimmed). Throws when the globs match no file, for the same reason as Get-UpstreamFiles.
    param([Parameter(Mandatory)][string] $Root, [Parameter(Mandatory)][string[]] $Globs, [Parameter(Mandatory)][string] $What)
    $files = Find-GlobMatches $Root $Globs
    if ($files.Count -eq 0) { throw "$What matches no file under '$Root'; a scan that sees nothing is blind, not clean." }
    $element = [regex]::new('<(string|plurals|string-array)\s[^>]*?name\s*=\s*"([^"]+)"[^>]*?(?:/>|>(.*?)</\1>)', [System.Text.RegularExpressions.RegexOptions]::CultureInvariant -bor [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $keys = @{}
    foreach ($file in $files) {
        foreach ($match in $element.Matches([System.IO.File]::ReadAllText((Join-Path $Root $file)))) {
            $name = $match.Groups[2].Value
            if (-not $keys.ContainsKey($name)) { $keys[$name] = [System.Collections.Generic.List[object]]::new() }
            $keys[$name].Add([pscustomobject]@{ file = $file; value = $match.Groups[3].Value.Trim() })
        }
    }
    return $keys
}

function Get-UpstreamStringKeys {
    param([Parameter(Mandatory)][string] $SourceRoot, [Parameter(Mandatory)] $Scope)
    if (-not $Scope.ContainsKey('strings')) { return @{} }
    return Get-StringElements $SourceRoot @($Scope['strings']['scan']) 'strings.scan'
}

function Get-DestinationStringKeys {
    param([Parameter(Mandatory)][string] $DestinationRoot, [Parameter(Mandatory)] $Scope)
    $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    if (-not $Scope.ContainsKey('strings')) { return , $set }
    foreach ($name in (Get-StringElements $DestinationRoot @($Scope['strings']['destinationScan']) 'strings.destinationScan').Keys) { [void]$set.Add($name) }
    return , $set
}
