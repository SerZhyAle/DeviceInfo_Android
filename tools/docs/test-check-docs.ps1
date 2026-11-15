#requires -Version 7.0
<#
.SYNOPSIS
    Self-test of tools/docs/check-docs.ps1 (S0034): each check passes on a clean tree and fails on its own defect,
    and every input the gate cannot read is exit 2.

.DESCRIPTION
    Works on throw-away git trees under temp/docs-selftest (gitignored, removed at the end), never on the real
    corpus. Each run of the gate is one process, so the expectations are grouped by tree: one tree carries several
    defects of the same check and the report is searched for each message, and for the absence of the messages of
    the things that must pass (a good anchor, a link inside a frozen archive, code that is not prose). The runs
    that do not depend on each other go in one parallel batch; the baseline sequence (accept, pass, fix, stale)
    is sequential by nature.

    Exit code: 0 every expectation held, 1 at least one did not, 2 the test could not run.
#>
[CmdletBinding(PositionalBinding = $false)]
param()

$ErrorActionPreference = 'Stop'
trap { Write-Host "docs-check self-test: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$gate = Join-Path $PSScriptRoot 'check-docs.ps1'
if (-not (Test-Path -LiteralPath $gate)) { throw 'check-docs.ps1 is missing' }
$work = Join-Path $repoRoot 'temp/docs-selftest'
if (Test-Path -LiteralPath $work) { Remove-Item -LiteralPath $work -Recurse -Force }
New-Item -ItemType Directory -Path $work | Out-Null
$utf8 = [Text.UTF8Encoding]::new($false)

$script:pass = 0
$script:fail = 0
function Assert-That([string] $Name, [bool] $Condition, [string] $Detail = '') {
    if ($Condition) { $script:pass++; return }
    $script:fail++
    Write-Host "FAIL $Name$(if ($Detail) { " - $Detail" })" -ForegroundColor Red
}

function Rec([string] $Id, [string[]] $Paths, [hashtable] $Extra = @{}) {
    $r = [ordered]@{
        id = $Id; title = "Title of $Id"; category = 'process'; audience = 'contributor'; paths = $Paths
        published = $false; indexable = $false; product_areas = @('documentation'); update_triggers = @('documentation'); generated = $false
    }
    foreach ($k in $Extra.Keys) { $r[$k] = $Extra[$k] }
    return ($r | ConvertTo-Json -Compress -Depth 5)
}

$baseRecords = @(
    (Rec 'readme' @('README.md')),
    (Rec 'notes' @('docs/notes.md')),
    (Rec 'registry' @('docs/DOCUMENT_REGISTRY.jsonl'))
)

function New-Tree([string] $Name, [hashtable] $Override = @{}, [string[]] $Records = $null, [string] $Config = $null, [switch] $NoGit) {
    $dir = if ($NoGit) { Join-Path ([IO.Path]::GetTempPath()) "s0034-$Name-$([guid]::NewGuid().ToString('N').Substring(0, 8))" } else { Join-Path $work $Name }
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    if (-not $NoGit) { & git -C $dir init -q }
    if (-not $Records) { $Records = $baseRecords }
    if (-not $Config) { $Config = '{"corpus":{"folders":["docs","PLAN"],"files":["AGENTS.md","CLAUDE.md","README.md"]},"registry":"docs/DOCUMENT_REGISTRY.jsonl","ignore":[],"baseline":"tools/docs/baseline.txt"}' }
    $files = @{
        'tools/docs/docs.config.json' = $Config
        'tools/docs/baseline.txt' = ''
        'README.md' = "# Product`n`nSee [the notes](docs/notes.md#real-heading), [again](docs/notes.md#real-heading-1) and [the docs](docs/).`n"
        'docs/notes.md' = "# Notes`n`n## Real Heading`n`nPlain hyphen - and two dots..`n`n## Real Heading`n`nSecond.`n"
        'docs/DOCUMENT_REGISTRY.jsonl' = ($Records -join "`n") + "`n"
    }
    foreach ($k in $Override.Keys) { if ($null -eq $Override[$k]) { [void]$files.Remove($k) } else { $files[$k] = $Override[$k] } }
    foreach ($k in $files.Keys) {
        $path = Join-Path $dir $k
        New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force | Out-Null
        [IO.File]::WriteAllText($path, [string]$files[$k], $utf8)
    }
    return $dir
}

function Invoke-Gate([string] $Tree, [string[]] $GateArgs = @()) {
    $out = & pwsh -NoProfile -File $gate -RepoRoot $Tree -SkipHarness @GateArgs 2>&1 | ForEach-Object { "$_" -replace '\x1b\[[0-9;]*m', '' }
    return [pscustomobject]@{ Code = $LASTEXITCODE; Text = ($out -join "`n"); Last = ($out | Select-Object -Last 1) }
}
function Invoke-Batch([object[]] $Specs) {
    $results = $Specs | ForEach-Object -Parallel {
        $spec = $_
        $out = & pwsh -NoProfile -File $using:gate -RepoRoot $spec.Tree -SkipHarness @($spec.GateArgs) 2>&1 | ForEach-Object { "$_" -replace '\x1b\[[0-9;]*m', '' }
        [pscustomobject]@{ Name = $spec.Name; Code = $LASTEXITCODE; Text = ($out -join "`n"); Last = ($out | Select-Object -Last 1) }
    } -ThrottleLimit 8
    $map = @{}
    foreach ($r in $results) { $map[$r.Name] = $r }
    return $map
}
function Has($Run, [string] $Needle) { return $Run.Text.Contains($Needle) }
function Spec([string] $Name, [string] $Tree, [string[]] $GateArgs = @()) { return @{ Name = $Name; Tree = $Tree; GateArgs = $GateArgs } }

# ---------------------------------------------------------------------------------------------- the trees
$tick = [char]96
$specs = [System.Collections.Generic.List[object]]::new()

$specs.Add((Spec 'clean' (New-Tree 'clean')))

$specs.Add((Spec 'registry' (New-Tree 'registry' @{
            'docs/unlisted.md' = "# Unlisted`n"; 'docs/two.md' = "# Two`n"; 'docs/ignored.md' = "# Ignored`n"; 'docs/thin.md' = "# Thin`n"
        } -Records @(
            (Rec 'readme' @('README.md')), (Rec 'notes' @('docs/notes.md')), (Rec 'registry' @('docs/DOCUMENT_REGISTRY.jsonl')),
            (Rec 'two-a' @('docs/two.md')), (Rec 'two-b' @('docs/t*.md')), (Rec 'ghost' @('docs/ghost.md')),
            (Rec 'render-no-generator' @('docs/ignored.md') @{ generated = $true; check = 'tools/x.ps1' }),
            (Rec 'render-no-check' @('docs/thin.md') @{ generated = $true; generator = 'tools/x.ps1' }),
            (Rec 'no-area' @('docs/unlisted-area.md') @{ product_areas = @() })
        )) @('-Check', 'registry')))

$ignoreConfig = '{"corpus":{"folders":["docs"],"files":["README.md"]},"registry":"docs/DOCUMENT_REGISTRY.jsonl","ignore":[{"path":"docs/extra.md","reason":"scratch note kept out on purpose"},{"path":"docs/extra2.md","reason":"too thin"},{"path":"docs/none.md","reason":"matches nothing at all today"}],"baseline":"tools/docs/baseline.txt"}'
$specs.Add((Spec 'ignore' (New-Tree 'ignore' @{ 'docs/extra.md' = "# Extra`n"; 'docs/extra2.md' = "# Extra2`n" } -Config $ignoreConfig) @('-Check', 'registry')))

$specs.Add((Spec 'advisory' (New-Tree 'advisory' -Records @(
                (Rec 'readme' @('README.md')),
                (Rec 'notes' @('docs/notes.md') @{ generated = $true; generator = 'tools/render.ps1'; check = 'none yet: nothing compares the file' }),
                (Rec 'registry' @('docs/DOCUMENT_REGISTRY.jsonl'))))))

$linksBody = "# Links`n`n[gone](missing.md) [bad anchor](notes.md#nope) [good](notes.md#real-heading) [dir](../docs/) [web](https://example.com/x#y) [mail](mailto:a@b.c) [here](#links) [into archive](old/gone.md) $tick$tick[in code](nowhere.md)$tick$tick.`n`n~~~`n[fenced](nowhere.md)`n~~~`n"
$specs.Add((Spec 'links' (New-Tree 'links' @{
            'docs/links.md' = $linksBody
            'docs/old/frozen.md' = "# Frozen`n`n[broken inside archive](nowhere.md)`n"
            'docs/old/kept.md' = "# Kept`n"
        } -Records @($baseRecords + (Rec 'links' @('docs/links.md')) + (Rec 'archive' @('docs/old/*.md') @{ archive = $true }))) @('-Check', 'links')))

$styleBody = "# Style`n`nthree dots... here`nan ellipsis character$([char]0x2026) here`nan em dash $([char]0x2014) here`nan en dash $([char]0x2013) here`ninline $tick$tick" + "a...b$tick$tick code and [link](notes.md#x...y) and plain hyphen - and two dots..`n`n$tick$tick$tick" + "text`nfenced ... and $([char]0x2014) stay`n$tick$tick$tick`n"
$styleTree = New-Tree 'style' @{ 'docs/style.md' = $styleBody } -Records @($baseRecords + (Rec 'style' @('docs/style.md')))
$specs.Add((Spec 'style' $styleTree @('-Check', 'style')))
$specs.Add((Spec 'selection' $styleTree @('-Check', 'registry')))

$specs.Add((Spec 'assets' (New-Tree 'assets' @{
            'docs/assets.md' = "# Assets`n`n![ok](pics/ok.png) ![gone](pics/gone.png) ![web](https://example.com/a.png)`n`nPaths in code: $tick" + 'pics/ok.png' + "$tick, $tick" + 'ok.png' + "$tick, $tick" + 'missing/lost.png' + "$tick, $tick" + 'ignored/secret.png' + "$tick and $tick" + 'NN_<what>.png' + "$tick.`n"
            'docs/pics/ok.png' = 'x'; 'ignored/secret.png' = 'x'; '.gitignore' = "ignored/`n"
        } -Records @($baseRecords + (Rec 'assets' @('docs/assets.md')) + (Rec 'pics' @('docs/pics/*.png')))) @('-Check', 'assets')))

$specs.Add((Spec 'offline' (New-Tree 'offline' @{
            'docs/offline.md' = "# Offline`n`n[plain](http://example.com/a) [safe](https://example.com/a) [local](http://localhost:8080/x)`n`n<script src=""https://cdn.example.com/x.js""></script>`n<img src=""https://example.com/p.png"">`n"
        } -Records @($baseRecords + (Rec 'offline' @('docs/offline.md')))) @('-Check', 'offline')))

$baseTree = New-Tree 'baseline' @{ 'docs/style.md' = "# Style`n`nthree dots... here`n" } -Records @($baseRecords + (Rec 'style' @('docs/style.md')))
$specs.Add((Spec 'baseline-none' $baseTree @('-Check', 'style')))

$specs.Add((Spec 'no-config' (New-Tree 'no-config' @{ 'tools/docs/docs.config.json' = $null })))
$specs.Add((Spec 'bad-config' (New-Tree 'bad-config' @{ 'tools/docs/docs.config.json' = '{ not json' })))
$specs.Add((Spec 'no-registry' (New-Tree 'no-registry' @{ 'docs/DOCUMENT_REGISTRY.jsonl' = $null })))
$specs.Add((Spec 'bad-registry' (New-Tree 'bad-registry' @{ 'docs/DOCUMENT_REGISTRY.jsonl' = "{ not json`n" })))
$noGit = New-Tree 'no-git' -NoGit
$specs.Add((Spec 'no-git' $noGit))

$r = Invoke-Batch $specs

# ---------------------------------------------------------------------------------------------- clean tree
$run = $r['clean']
Assert-That 'clean tree: exit 0' ($run.Code -eq 0) $run.Text
Assert-That 'clean tree: verdict line is the last line' ($run.Last -match '^docs-check: PASS \(') $run.Last
Assert-That 'clean tree: a good anchor and its duplicate-heading suffix resolve' (-not (Has $run 'no such anchor'))

# ---------------------------------------------------------------------------------------------- registry
$run = $r['registry']
Assert-That 'registry: exit 1' ($run.Code -eq 1) $run.Text
Assert-That 'registry: a file with no record is named' (Has $run 'docs/unlisted.md has no record')
Assert-That 'registry: a pattern that matches nothing is named' (Has $run 'ghost pattern matches no file')
Assert-That 'registry: a file claimed twice is named' (Has $run 'docs/two.md is claimed by 2 records')
Assert-That 'registry: a render without a generator is named' (Has $run 'render-no-generator is generated and names no generator')
Assert-That 'registry: a render without a check is named' (Has $run 'render-no-check is generated and names no check')
Assert-That 'registry: an empty product area is named' (Has $run 'no-area has no product area')
Assert-That 'registry: a file with a record is not reported' (-not (Has $run 'README.md has no record'))
$run = $r['ignore']
Assert-That 'registry: an ignore entry with a four-word reason covers its file' (-not (Has $run 'docs/extra.md has no record'))
Assert-That 'registry: an ignore entry with a thin reason is refused' (Has $run 'docs/extra2.md has a reason of fewer than four words')
Assert-That 'registry: an ignore entry that matches nothing is refused' (Has $run 'ignore entry docs/none.md matches no corpus file')
$run = $r['advisory']
Assert-That 'advisory: a render with no drift check is exit 0 with an advisory verdict' ($run.Code -eq 0 -and $run.Last -match '^docs-check: PASS WITH ADVISORIES \(1 ') $run.Text
Assert-That 'advisory: the advisory is named' (Has $run 'ADVISORY notes')

# ---------------------------------------------------------------------------------------------- links
$run = $r['links']
Assert-That 'links: exit 1' ($run.Code -eq 1) $run.Text
Assert-That 'links: a link to a missing file is named' (Has $run 'docs/links.md -> missing.md (no such file)')
Assert-That 'links: a link to a missing anchor is named' (Has $run 'docs/links.md -> notes.md#nope (no such anchor)')
Assert-That 'links: a link into an archive that does not resolve is named' (Has $run 'docs/links.md -> old/gone.md (no such file)')
Assert-That 'links: a good anchor, a folder, a web link, a mail link and a same-file anchor pass' (-not (Has $run '#real-heading') -and -not (Has $run '../docs/') -and -not (Has $run 'example.com') -and -not (Has $run '#links'))
Assert-That 'links: a link inside code or a fenced block is not read' (-not (Has $run 'nowhere.md'))
Assert-That 'links: a broken link inside a frozen archive is not judged' (-not (Has $run 'frozen.md'))

# ---------------------------------------------------------------------------------------------- style
$run = $r['style']
Assert-That 'style: exit 1' ($run.Code -eq 1) $run.Text
Assert-That 'style: three dots are named' (Has $run 'docs/style.md ellipsis three dots')
Assert-That 'style: the ellipsis character is named' (Has $run 'docs/style.md ellipsis an ellipsis character')
Assert-That 'style: an em dash is named' (Has $run 'docs/style.md em-dash an em dash')
Assert-That 'style: an en dash is named' (Has $run 'docs/style.md en-dash an en dash')
Assert-That 'style: inline code, a link target, a fenced block and two plain dots are not prose findings' ((@($run.Text -split "`n" | Where-Object { $_ -match '^FINDING docs-style' }).Count) -eq 4) $run.Text
Assert-That 'selection: -Check registry does not report a style defect' ($r['selection'].Code -eq 0 -and -not (Has $r['selection'] 'docs-style')) $r['selection'].Text

# ---------------------------------------------------------------------------------------------- assets
$run = $r['assets']
Assert-That 'assets: exit 1' ($run.Code -eq 1) $run.Text
Assert-That 'assets: an image link to a missing file is named' (Has $run 'cites pics/gone.png (no tracked file)')
Assert-That 'assets: an image path in code that exists nowhere is named' (Has $run 'cites missing/lost.png (no tracked file)')
Assert-That 'assets: a git-ignored asset is refused' (Has $run 'cites ignored/secret.png (no tracked file)')
Assert-That 'assets: an existing image, a bare name that resolves and a placeholder pass' (-not (Has $run 'cites pics/ok.png') -and -not (Has $run 'cites ok.png') -and -not (Has $run 'NN_'))

# ---------------------------------------------------------------------------------------------- offline
$run = $r['offline']
Assert-That 'offline: exit 1' ($run.Code -eq 1) $run.Text
Assert-That 'offline: an http link is named' (Has $run 'non-https link http://example.com/a')
Assert-That 'offline: a remote script is named' (Has $run 'remote embed <script src="https:')
Assert-That 'offline: a remote image is named' (Has $run 'remote embed <img src="https:')
Assert-That 'offline: an https link and a localhost link pass' (-not (Has $run 'localhost') -and -not (Has $run '[safe]'))

# ---------------------------------------------------------------------------------------------- baseline
Assert-That 'baseline: the defect fails without a baseline' ($r['baseline-none'].Code -eq 1) $r['baseline-none'].Text
$run = Invoke-Gate $baseTree @('-Check', 'style', '-UpdateBaseline')
Assert-That 'baseline: -UpdateBaseline accepts and prints the identifier' ($run.Code -eq 0 -and (Has $run 'baseline accepts: docs-style docs/style.md ellipsis three dots... here')) $run.Text
$run = Invoke-Gate $baseTree @('-Check', 'style')
Assert-That 'baseline: the accepted defect passes' ($run.Code -eq 0) $run.Text
[IO.File]::WriteAllText((Join-Path $baseTree 'docs/style.md'), "# Style`n`nfixed here`n", $utf8)
$run = Invoke-Gate $baseTree @('-Check', 'style')
Assert-That 'baseline: an entry no finding raises fails until it is removed' ($run.Code -eq 1 -and (Has $run 'STALE BASELINE')) $run.Text

# ---------------------------------------------------------------------------------------------- exit 2
Assert-That 'exit 2: a missing configuration' ($r['no-config'].Code -eq 2 -and $r['no-config'].Last -match '^docs-check: COULD NOT VERIFY') $r['no-config'].Text
Assert-That 'exit 2: a configuration that is not JSON' ($r['bad-config'].Code -eq 2) $r['bad-config'].Text
Assert-That 'exit 2: a missing registry' ($r['no-registry'].Code -eq 2) $r['no-registry'].Text
Assert-That 'exit 2: a registry line that is not JSON' ($r['bad-registry'].Code -eq 2) $r['bad-registry'].Text
Assert-That 'exit 2: a tree that is not a git work tree' ($r['no-git'].Code -eq 2 -and (Has $r['no-git'] 'not a git work tree')) $r['no-git'].Text
Remove-Item -LiteralPath $noGit -Recurse -Force

Remove-Item -LiteralPath $work -Recurse -Force
Write-Host "docs-check self-test: $script:pass PASS, $script:fail FAIL"
if ($script:fail -gt 0) { exit 1 }
Write-Host 'docs-check self-test: all expectations held.'
exit 0
