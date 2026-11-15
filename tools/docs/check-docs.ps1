#requires -Version 7.0
<#
.SYNOPSIS
    The internal documentation gate (S0034): DOC-INTERNAL-QUALITY rules 1, 2, 3, 5, 6 and 7 over the maintained
    corpus of this repository.

.DESCRIPTION
    The corpus is declared in tools/docs/docs.config.json and never inferred: AGENTS.md, CLAUDE.md, README.md,
    every file under docs/ and PLAN/, and the Markdown under tools/. Only files git tracks or could track (not
    git-ignored) are read. The registry is docs/DOCUMENT_REGISTRY.jsonl.

      registry   rule 1 and rule 2. Every record carries the harness fields (id, title, category, audience, paths,
                 published, indexable, product_areas, update_triggers, generated) with a topic, a product area and
                 an update trigger that are not empty; a generated record names its generator and its check
                 (contract item W; a check written as "none .." is an advisory, never a pass); every pattern of a
                 record matches a corpus file; every corpus file is matched by exactly one record or by an
                 ignore entry of the configuration with a reason of four words or more; a record names no file
                 outside the declared corpus; a `contract` value names an id of docs/contracts/README.md.
      links      rule 3. A relative Markdown link resolves to a file or folder, and a #fragment to a heading of
                 the target (GitHub's slug) or an explicit name= or id= anchor. A link inside a record marked
                 "archive": true is not judged (a frozen archive, item Q); a link into it is.
      style      rule 5. No three dots, no ellipsis character and no em or en dash in Markdown prose. Fenced
                 blocks, inline code and link targets are removed first.
      assets     rule 6. An image link, and an image path written in inline code, resolves to a file git tracks
                 or could track; a tracked document may not cite a git-ignored asset.
      offline    rule 7. No http: link outside code (localhost and 127.0.0.1 excepted) and no remote script,
                 stylesheet, font or image in a Markdown file.
      all        the five above, then the harness document_registry/validate (skipped by -SkipHarness).

    Accepted debt lives in the baseline file named by the configuration, a set that may only fall: a finding it
    does not list fails, and an entry no finding raises fails until it is removed.

    Exit codes: 0 PASS (or PASS WITH ADVISORIES); 1 FAIL, a finding was judged defective; 2 COULD NOT VERIFY
    (unreadable configuration or registry, no git work tree, the harness validator missing). The last line written
    to stdout is the CHECK-VERDICT line: `docs-check: PASS|PASS WITH ADVISORIES|FAIL|COULD NOT VERIFY (..)`.

.PARAMETER Check
    registry, links, style, assets, offline or all (default).

.PARAMETER RepoRoot
    The repository root. Default: the tree this script's tools/docs directory sits in. The self-test passes a
    throw-away git tree.

.PARAMETER UpdateBaseline
    Rewrite the baseline of the selected check(s) to the current findings and print every identifier accepted.
    Use only when the debt is accepted on purpose, with the reason in the ticket.

.PARAMETER SkipHarness
    Do not call the harness validator (the self-test uses it; the harness is not in a throw-away tree).
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [ValidateSet('registry', 'links', 'style', 'assets', 'offline', 'all')]
    [string] $Check = 'all',
    [string] $RepoRoot,
    [switch] $UpdateBaseline,
    [switch] $SkipHarness
)

$ErrorActionPreference = 'Stop'

function Stop-CouldNotVerify([string] $Reason) {
    Write-Host "docs-check: $Reason" -ForegroundColor Red
    Write-Host "docs-check: COULD NOT VERIFY ($Reason)"
    exit 2
}
trap { Stop-CouldNotVerify $_.Exception.Message }

if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot) }
$RepoRoot = [IO.Path]::GetFullPath($RepoRoot).TrimEnd('\', '/')
$utf8 = [Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = $utf8

# ------------------------------------------------------------------------------------------ configuration
$configPath = Join-Path $RepoRoot 'tools/docs/docs.config.json'
if (-not (Test-Path -LiteralPath $configPath)) { Stop-CouldNotVerify 'tools/docs/docs.config.json is missing' }
try { $config = [IO.File]::ReadAllText($configPath, $utf8) | ConvertFrom-Json } catch { Stop-CouldNotVerify 'docs.config.json is not valid JSON' }
foreach ($key in 'corpus', 'registry', 'baseline') {
    if (-not ($config.PSObject.Properties.Name -contains $key)) { Stop-CouldNotVerify "docs.config.json has no '$key'" }
}
$corpusFolders = @($config.corpus.folders)
$corpusFiles = @($config.corpus.files)
$ignoreEntries = @($config.ignore | Where-Object { $_ })
$registryRel = [string]$config.registry
$baselineRel = [string]$config.baseline

# ------------------------------------------------------------------------------------------ the file set
$gitDir = & git -C $RepoRoot rev-parse --is-inside-work-tree 2>$null
if ($LASTEXITCODE -ne 0 -or "$gitDir".Trim() -ne 'true') { Stop-CouldNotVerify 'not a git work tree' }
$listed = & git -C $RepoRoot -c core.quotepath=false ls-files --cached --others --exclude-standard 2>$null
if ($LASTEXITCODE -ne 0) { Stop-CouldNotVerify 'git ls-files failed' }
$trackable = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
foreach ($path in $listed) {
    if ($path -and (Test-Path -LiteralPath (Join-Path $RepoRoot $path) -PathType Leaf)) { [void]$trackable.Add($path) }
}
$byName = @{}
foreach ($path in $trackable) {
    $leaf = $path.Substring($path.LastIndexOf('/') + 1)
    if (-not $byName.ContainsKey($leaf)) { $byName[$leaf] = [System.Collections.Generic.List[string]]::new() }
    $byName[$leaf].Add($path)
}

function ConvertTo-GlobRegex([string] $Glob) {
    $out = [System.Text.StringBuilder]::new('^')
    $i = 0
    while ($i -lt $Glob.Length) {
        $c = $Glob[$i]
        if ($c -eq '*') {
            if ($i + 1 -lt $Glob.Length -and $Glob[$i + 1] -eq '*') {
                if ($i + 2 -lt $Glob.Length -and $Glob[$i + 2] -eq '/') { [void]$out.Append('(?:.*/)?'); $i += 3; continue }
                [void]$out.Append('.*'); $i += 2; continue
            }
            [void]$out.Append('[^/]*'); $i++; continue
        }
        if ($c -eq '?') { [void]$out.Append('[^/]'); $i++; continue }
        if ($c -eq '[') {
            $close = $Glob.IndexOf(']', $i + 1)
            if ($close -gt $i) { [void]$out.Append($Glob.Substring($i, $close - $i + 1)); $i = $close + 1; continue }
        }
        [void]$out.Append([regex]::Escape([string]$c)); $i++
    }
    [void]$out.Append('$')
    return [regex]::new($out.ToString())
}

$corpusFileRegexes = @($corpusFiles | ForEach-Object { ConvertTo-GlobRegex $_ })
$corpus = [System.Collections.Generic.List[string]]::new()
foreach ($path in ($trackable | Sort-Object)) {
    $inFolder = $false
    foreach ($folder in $corpusFolders) { if ($path.StartsWith($folder.TrimEnd('/') + '/', [StringComparison]::Ordinal)) { $inFolder = $true; break } }
    $inFiles = $false
    foreach ($rx in $corpusFileRegexes) { if ($rx.IsMatch($path)) { $inFiles = $true; break } }
    if ($inFolder -or $inFiles) { $corpus.Add($path) }
}

# ------------------------------------------------------------------------------------------ the registry
$registryPath = Join-Path $RepoRoot $registryRel
if (-not (Test-Path -LiteralPath $registryPath)) { Stop-CouldNotVerify "$registryRel is missing" }
$records = [System.Collections.Generic.List[object]]::new()
$lineNumber = 0
foreach ($line in [IO.File]::ReadAllLines($registryPath, $utf8)) {
    $lineNumber++
    if (-not $line.Trim()) { continue }
    try { $records.Add(($line | ConvertFrom-Json)) } catch { Stop-CouldNotVerify "$registryRel line ${lineNumber}: not valid JSON" }
}

$findings = [System.Collections.Generic.List[object]]::new()   # @{ Kind; Id; Where }
$advisories = [System.Collections.Generic.List[string]]::new()
function Add-Finding([string] $Kind, [string] $Id, [string] $Where = '') {
    $findings.Add([pscustomobject]@{ Kind = $Kind; Id = $Id; Where = $Where })
}

$recordRegexes = @{}   # record id -> list of regex
$fileOwners = @{}      # file -> list of record ids
$archiveFiles = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$ignoreRegexes = @($ignoreEntries | ForEach-Object { [pscustomobject]@{ Entry = $_; Regex = (ConvertTo-GlobRegex ([string]$_.path)); Hits = 0 } })

$contractIds = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$contractsReadme = Join-Path $RepoRoot 'docs/contracts/README.md'
if (Test-Path -LiteralPath $contractsReadme) {
    foreach ($m in [regex]::Matches([IO.File]::ReadAllText($contractsReadme, $utf8), '`([A-Z][A-Z0-9]+(?:-[A-Z0-9]+)+)`')) { [void]$contractIds.Add($m.Groups[1].Value) }
}

function Test-Registry {
    $required = 'id', 'title', 'category', 'audience', 'paths', 'published', 'indexable', 'product_areas', 'update_triggers', 'generated'
    $seen = @{}
    foreach ($record in $records) {
        $rid = [string]$record.id
        foreach ($field in $required) {
            if (-not ($record.PSObject.Properties.Name -contains $field)) { Add-Finding 'docs-registry' "$rid missing field $field" }
        }
        if ($rid -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') { Add-Finding 'docs-registry' "$rid invalid id" }
        if ($seen.ContainsKey($rid)) { Add-Finding 'docs-registry' "$rid duplicate id" } else { $seen[$rid] = $true }
        if (-not ([string]$record.title).Trim()) { Add-Finding 'docs-registry' "$rid has no title (topic)" }
        if (@($record.product_areas | Where-Object { $_ }).Count -eq 0) { Add-Finding 'docs-registry' "$rid has no product area" }
        if (@($record.update_triggers | Where-Object { $_ }).Count -eq 0) { Add-Finding 'docs-registry' "$rid has no update trigger" }
        if ($record.generated -eq $true) {
            if (-not ([string]$record.generator).Trim()) { Add-Finding 'docs-registry' "$rid is generated and names no generator" }
            $check = ([string]$record.check).Trim()
            if (-not $check) { Add-Finding 'docs-registry' "$rid is generated and names no check" }
            elseif ($check -match '^none\b') { $advisories.Add("$rid : $check") }
        }
        if ($record.PSObject.Properties.Name -contains 'contract' -and $record.contract -and $contractIds.Count -gt 0) {
            $cid = ([string]$record.contract -split '[\s;,]+')[0]
            if (-not $contractIds.Contains($cid)) { Add-Finding 'docs-registry' "$rid contract '$cid' is not an id of docs/contracts/README.md" }
        }
        $regexes = [System.Collections.Generic.List[object]]::new()
        foreach ($pattern in @($record.paths)) {
            if (([string]$pattern) -match '(^|/)\.\.(/|$)' -or [IO.Path]::IsPathRooted([string]$pattern)) { Add-Finding 'docs-registry' "$rid path escapes the repository: $pattern"; continue }
            $rx = ConvertTo-GlobRegex ([string]$pattern)
            $hit = 0
            foreach ($file in $corpus) {
                if ($rx.IsMatch($file)) {
                    $hit++
                    if (-not $fileOwners.ContainsKey($file)) { $fileOwners[$file] = [System.Collections.Generic.List[string]]::new() }
                    if (-not $fileOwners[$file].Contains($rid)) { $fileOwners[$file].Add($rid) }
                    if ($record.archive -eq $true) { [void]$archiveFiles.Add($file) }
                }
            }
            if ($hit -eq 0) {
                if ($trackable | Where-Object { $rx.IsMatch($_) } | Select-Object -First 1) { Add-Finding 'docs-registry' "$rid pattern is outside the declared corpus: $pattern" }
                else { Add-Finding 'docs-registry' "$rid pattern matches no file: $pattern" }
            }
        }
    }
    foreach ($ignore in $ignoreRegexes) {
        $words = @(([string]$ignore.Entry.reason -split '\s+') | Where-Object { $_ })
        if ($words.Count -lt 4) { Add-Finding 'docs-registry' "ignore entry $($ignore.Entry.path) has a reason of fewer than four words" }
    }
    foreach ($file in $corpus) {
        $owners = if ($fileOwners.ContainsKey($file)) { @($fileOwners[$file]) } else { @() }
        $ignored = @($ignoreRegexes | Where-Object { $_.Regex.IsMatch($file) })
        foreach ($ig in $ignored) { $ig.Hits++ }
        if ($owners.Count -eq 0 -and $ignored.Count -eq 0) { Add-Finding 'docs-registry' "$file has no record" }
        elseif ($owners.Count -gt 1) { Add-Finding 'docs-registry' "$file is claimed by $($owners.Count) records: $($owners -join ', ')" }
        elseif ($owners.Count -ge 1 -and $ignored.Count -ge 1) { Add-Finding 'docs-registry' "$file has a record and an ignore entry" }
    }
    foreach ($ig in $ignoreRegexes) { if ($ig.Hits -eq 0) { Add-Finding 'docs-registry' "ignore entry $($ig.Entry.path) matches no corpus file" } }
}

# Archive membership is needed by links even when only the links check runs.
function Resolve-Ownership {
    foreach ($record in $records) {
        foreach ($pattern in @($record.paths)) {
            $rx = ConvertTo-GlobRegex ([string]$pattern)
            foreach ($file in $corpus) {
                if ($rx.IsMatch($file)) {
                    if ($record.archive -eq $true) { [void]$archiveFiles.Add($file) }
                }
            }
        }
    }
}

# ------------------------------------------------------------------------------------------ Markdown model
$fenceRx = [regex]::new('^\s*(```|~~~)')
$headingRx = [regex]::new('^\s{0,3}#{1,6}\s+(.+?)\s*#*\s*$')
$codeSpanRx = [regex]::new('(`+)(.+?)\1')
$linkRx = [regex]::new('(?<!\!)\[[^\]]*\]\(\s*(<[^>]*>|[^)\s]+)(?:\s+"[^"]*")?\s*\)')
$imageRx = [regex]::new('\!\[[^\]]*\]\(\s*(<[^>]*>|[^)\s]+)(?:\s+"[^"]*")?\s*\)')
$refDefRx = [regex]::new('^\s{0,3}\[[^\]]+\]:\s*(<[^>]*>|\S+)')
$anchorRx = [regex]::new('<a\s+[^>]*?(?:name|id)\s*=\s*"([^"]+)"|\sid\s*=\s*"([^"]+)"')
$imagePathRx = [regex]::new('^[A-Za-z0-9_./\\-]+\.(?:png|jpe?g|gif|svg|webp)$', 'IgnoreCase')

function Get-Slug([string] $Heading) {
    $t = [regex]::Replace($Heading, '\[([^\]]*)\]\([^)]*\)', '$1')
    $t = $t -replace '[`*]', ''
    $t = $t -replace '<[^>]+>', ''
    $t = $t.ToLowerInvariant()
    $t = [regex]::Replace($t, '[^\p{L}\p{N}\p{M}\s\-_]', '')
    return ($t -replace '\s', '-')
}

$modelCache = @{}
function Get-Model([string] $Path) {
    if ($modelCache.ContainsKey($Path)) { return $modelCache[$Path] }
    $text = [IO.File]::ReadAllText((Join-Path $RepoRoot $Path), $utf8)
    $lines = $text -split "`r?`n"
    $inFence = $false
    $prose = [System.Collections.Generic.List[object]]::new()    # @{ N; Text } with code removed
    $spans = [System.Collections.Generic.List[object]]::new()    # @{ N; Text }
    $rawProse = [System.Collections.Generic.List[object]]::new() # @{ N; Text } with code removed, links kept
    $anchors = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $slugCount = @{}
    $n = 0
    foreach ($line in $lines) {
        $n++
        if ($fenceRx.IsMatch($line)) { $inFence = -not $inFence; continue }
        if ($inFence) { continue }
        $stripped = $line
        if ($line.Contains('`')) {
            foreach ($m in $codeSpanRx.Matches($line)) { $spans.Add([pscustomobject]@{ N = $n; Text = $m.Groups[2].Value.Trim() }) }
            $stripped = $codeSpanRx.Replace($line, 'CODE')
        }
        $rawProse.Add([pscustomobject]@{ N = $n; Text = $stripped })
        $h = $headingRx.Match($stripped)
        if ($h.Success) {
            $headingText = $headingRx.Match($line).Groups[1].Value
            $slug = Get-Slug $headingText
            if ($slugCount.ContainsKey($slug)) { $slugCount[$slug]++; [void]$anchors.Add("$slug-$($slugCount[$slug])") }
            else { $slugCount[$slug] = 0; [void]$anchors.Add($slug) }
        }
        if ($stripped.Contains('=')) {
            foreach ($a in $anchorRx.Matches($stripped)) {
                $name = if ($a.Groups[1].Success) { $a.Groups[1].Value } else { $a.Groups[2].Value }
                [void]$anchors.Add($name)
            }
        }
    }
    $model = [pscustomobject]@{ Prose = $rawProse; Spans = $spans; Anchors = $anchors }
    $modelCache[$Path] = $model
    return $model
}

function Get-LinkTargets($Model) {
    foreach ($entry in $Model.Prose) {
        $text = $entry.Text
        if (-not ($text.Contains('](') -or $text.Contains(']:'))) { continue }
        foreach ($m in $linkRx.Matches($text)) { [pscustomobject]@{ N = $entry.N; Target = $m.Groups[1].Value.Trim('<', '>'); Image = $false } }
        foreach ($m in $imageRx.Matches($text)) { [pscustomobject]@{ N = $entry.N; Target = $m.Groups[1].Value.Trim('<', '>'); Image = $true } }
        $d = $refDefRx.Match($text)
        if ($d.Success) { [pscustomobject]@{ N = $entry.N; Target = $d.Groups[1].Value.Trim('<', '>'); Image = $false } }
    }
}

function Resolve-RelativeTarget([string] $From, [string] $Target) {
    # Returns @{ Path (repo-relative, '/'), Fragment } or $null when the target is not a relative file link.
    if ($Target -match '^[A-Za-z][A-Za-z0-9+.\-]*:' -or $Target.StartsWith('//')) { return $null }
    $fragment = ''
    $pathPart = $Target
    $hash = $Target.IndexOf('#')
    if ($hash -ge 0) { $pathPart = $Target.Substring(0, $hash); $fragment = $Target.Substring($hash + 1) }
    $q = $pathPart.IndexOf('?'); if ($q -ge 0) { $pathPart = $pathPart.Substring(0, $q) }
    $pathPart = [Uri]::UnescapeDataString($pathPart)
    if ($pathPart -eq '') { return [pscustomobject]@{ Path = $From; Fragment = $fragment } }
    $base = if ($pathPart.StartsWith('/')) { $RepoRoot } else { Join-Path $RepoRoot (Split-Path -Parent $From) }
    $combined = [IO.Path]::GetFullPath((Join-Path $base $pathPart.TrimStart('/')))
    if (-not $combined.StartsWith($RepoRoot, [StringComparison]::OrdinalIgnoreCase)) { return [pscustomobject]@{ Path = $null; Fragment = $fragment; Outside = $true } }
    $relative = $combined.Substring($RepoRoot.Length).TrimStart('\', '/').Replace('\', '/')
    return [pscustomobject]@{ Path = $relative; Fragment = $fragment }
}

$markdownFiles = @($corpus | Where-Object { $_ -like '*.md' })
$linkCount = 0
$assetCount = 0

function Test-Links {
    foreach ($file in $markdownFiles) {
        if ($archiveFiles.Contains($file)) { continue }
        $model = Get-Model $file
        foreach ($link in (Get-LinkTargets $model)) {
            if ($link.Image) { continue }
            $resolved = Resolve-RelativeTarget $file $link.Target
            if ($null -eq $resolved) { continue }
            $script:linkCount++
            if ($resolved.PSObject.Properties.Name -contains 'Outside') { Add-Finding 'docs-links' "$file -> $($link.Target) (leaves the repository)" "line $($link.N)"; continue }
            $target = $resolved.Path
            $isFile = $trackable.Contains($target)
            $isDir = $false
            if (-not $isFile) { $prefix = $target.TrimEnd('/') + '/'; $isDir = [bool]($trackable | Where-Object { $_.StartsWith($prefix, [StringComparison]::Ordinal) } | Select-Object -First 1) }
            if (-not $isFile -and -not $isDir) { Add-Finding 'docs-links' "$file -> $($link.Target) (no such file)" "line $($link.N)"; continue }
            if ($resolved.Fragment -and $isFile -and $target -like '*.md') {
                $fragment = [Uri]::UnescapeDataString($resolved.Fragment).ToLowerInvariant()
                $targetModel = Get-Model $target
                $has = $targetModel.Anchors.Contains($fragment) -or $targetModel.Anchors.Contains($resolved.Fragment)
                if (-not $has -and $fragment -match '^l\d+(-l\d+)?$') { $has = $true }
                if (-not $has) { Add-Finding 'docs-links' "$file -> $($link.Target) (no such anchor)" "line $($link.N)" }
            }
        }
    }
}

$dashKinds = @(
    @{ Kind = 'ellipsis'; Rx = [regex]::new('\.{3,}|…') },
    @{ Kind = 'em-dash'; Rx = [regex]::new('—') },
    @{ Kind = 'en-dash'; Rx = [regex]::new('–') }
)
function Test-Style {
    foreach ($file in $markdownFiles) {
        $model = Get-Model $file
        foreach ($entry in $model.Prose) {
            $text = $linkRx.Replace($imageRx.Replace($entry.Text, '![]()'), '[]()')
            $text = [regex]::Replace($text, '\]\([^)]*\)', ']()')
            foreach ($k in $dashKinds) {
                if ($k.Rx.IsMatch($text)) {
                    $excerpt = ($entry.Text.Trim() -replace '\s+', ' ')
                    if ($excerpt.Length -gt 70) { $excerpt = $excerpt.Substring(0, 70) }
                    Add-Finding 'docs-style' "$file $($k.Kind) $excerpt" "line $($entry.N)"
                }
            }
        }
    }
}

function Test-Assets {
    foreach ($file in $markdownFiles) {
        $model = Get-Model $file
        $citations = [System.Collections.Generic.List[object]]::new()
        foreach ($link in (Get-LinkTargets $model)) { if ($link.Image) { $citations.Add([pscustomobject]@{ N = $link.N; Target = $link.Target; Kind = 'image' }) } }
        foreach ($span in $model.Spans) { if ($imagePathRx.IsMatch($span.Text)) { $citations.Add([pscustomobject]@{ N = $span.N; Target = $span.Text; Kind = 'path' }) } }
        foreach ($c in $citations) {
            $script:assetCount++
            $found = $false
            $resolved = Resolve-RelativeTarget $file ($c.Target -replace '\\', '/')
            if ($resolved -and $resolved.Path -and $trackable.Contains($resolved.Path)) { $found = $true }
            if (-not $found -and $c.Kind -eq 'path') {
                $asRoot = ($c.Target -replace '\\', '/').TrimStart('/')
                if ($trackable.Contains($asRoot)) { $found = $true }
                elseif ($asRoot -notmatch '/') { $found = $byName.ContainsKey($asRoot) }
                else {
                    $leaf = $asRoot.Substring($asRoot.LastIndexOf('/') + 1)
                    if ($byName.ContainsKey($leaf)) { $found = [bool]($byName[$leaf] | Where-Object { $_.EndsWith('/' + $asRoot, [StringComparison]::Ordinal) } | Select-Object -First 1) }
                }
            }
            if (-not $found) { Add-Finding 'docs-assets' "$file cites $($c.Target) (no tracked file)" "line $($c.N)" }
        }
    }
}

$remoteEmbedRx = [regex]::new('<\s*(?:script|iframe)\b[^>]*\bsrc\s*=\s*["'']?https?:|<\s*link\b[^>]*\bhref\s*=\s*["'']?https?:|<\s*img\b[^>]*\bsrc\s*=\s*["'']?https?:|@import\s+url\(\s*["'']?https?:', 'IgnoreCase')
$httpRx = [regex]::new('http://(?!localhost\b|127\.0\.0\.1\b)[^\s)>\]]+', 'IgnoreCase')
function Test-Offline {
    foreach ($file in $markdownFiles) {
        $model = Get-Model $file
        foreach ($entry in $model.Prose) {
            if ($remoteEmbedRx.IsMatch($entry.Text)) { Add-Finding 'docs-offline' "$file remote embed $($remoteEmbedRx.Match($entry.Text).Value)" "line $($entry.N)" }
            $m = $httpRx.Match($entry.Text)
            if ($m.Success) { Add-Finding 'docs-offline' "$file non-https link $($m.Value)" "line $($entry.N)" }
        }
    }
}

# ------------------------------------------------------------------------------------------ run
$selected = if ($Check -eq 'all') { @('registry', 'links', 'style', 'assets', 'offline') } else { @($Check) }
Resolve-Ownership
$kindOf = @{ registry = 'docs-registry'; links = 'docs-links'; style = 'docs-style'; assets = 'docs-assets'; offline = 'docs-offline' }
foreach ($name in $selected) {
    switch ($name) {
        'registry' { Test-Registry }
        'links' { Test-Links }
        'style' { Test-Style }
        'assets' { Test-Assets }
        'offline' { Test-Offline }
    }
}

# ------------------------------------------------------------------------------------------ baseline
$baselinePath = Join-Path $RepoRoot $baselineRel
$baselineHeader = @(
    '# CHECK-BASELINE set baseline of tools/docs/check-docs.ps1 (DOC-INTERNAL-QUALITY, S0034): one finding identifier',
    '# per line, sorted. It may only fall - a finding not listed fails, a listed identifier no finding raises fails until',
    '# it is removed. Rewritten only by check-docs.ps1 -UpdateBaseline, which prints every identifier it accepts.'
)
$baseline = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
if (Test-Path -LiteralPath $baselinePath) {
    foreach ($line in [IO.File]::ReadAllLines($baselinePath, $utf8)) { if ($line.Trim() -and -not $line.StartsWith('#')) { [void]$baseline.Add($line.TrimEnd()) } }
}
$selectedKinds = @($selected | ForEach-Object { $kindOf[$_] })

if ($UpdateBaseline) {
    $kept = @($baseline | Where-Object { $id = $_; -not ($selectedKinds | Where-Object { $id.StartsWith("$_ ") }) })
    $accepted = @($findings | ForEach-Object { "$($_.Kind) $($_.Id)" } | Sort-Object -Unique -CaseSensitive)
    foreach ($id in $accepted) { Write-Host "baseline accepts: $id" }
    $all = @($kept + $accepted | Sort-Object -Unique -CaseSensitive)
    [IO.File]::WriteAllText($baselinePath, ((@($baselineHeader) + $all) -join "`n") + "`n", $utf8)
    Write-Host "docs-check: PASS (baseline rewritten, $($accepted.Count) accepted for $($selectedKinds -join ', '))"
    exit 0
}

$failures = [System.Collections.Generic.List[string]]::new()
$raised = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
foreach ($f in $findings) {
    $id = "$($f.Kind) $($f.Id)"
    [void]$raised.Add($id)
    if (-not $baseline.Contains($id)) { $failures.Add("FINDING $id" + $(if ($f.Where) { " ($($f.Where))" } else { '' })) }
}
foreach ($id in $baseline) {
    $kindMatches = $selectedKinds | Where-Object { $id.StartsWith("$_ ") }
    if ($kindMatches -and -not $raised.Contains($id)) { $failures.Add("STALE BASELINE $id (no finding raises it any more; remove it)") }
}

# ------------------------------------------------------------------------------------------ the harness validator
if ($Check -eq 'all' -and -not $SkipHarness) {
    $forwarder = Join-Path $RepoRoot 'tools/harness.ps1'
    if (-not (Test-Path -LiteralPath $forwarder)) { Stop-CouldNotVerify 'tools/harness.ps1 is missing' }
    $out = & pwsh -NoProfile -File $forwarder 'document_registry/validate' 2>&1
    $code = $LASTEXITCODE
    if ($code -eq 2) { Stop-CouldNotVerify 'the harness document_registry/validate could not run' }
    if ($code -ne 0) {
        foreach ($line in $out) { Write-Host "  harness: $line" }
        $failures.Add("FINDING harness document_registry/validate exited $code")
    }
}

$counts = "$($records.Count) records, $($corpus.Count) corpus files, $($markdownFiles.Count) Markdown, $linkCount links, $assetCount asset citations, $($baseline.Count) baselined"
foreach ($line in $failures) { Write-Host $line -ForegroundColor Red }
foreach ($a in $advisories) { Write-Host "ADVISORY $a" -ForegroundColor Yellow }
if ($failures.Count -gt 0) {
    Write-Host "docs-check: FAIL ($($failures.Count) finding(s); $counts)"
    exit 1
}
if ($advisories.Count -gt 0) {
    Write-Host "docs-check: PASS WITH ADVISORIES ($($advisories.Count) advisory(ies) named above; $counts)"
    exit 0
}
Write-Host "docs-check: PASS ($counts)"
exit 0
