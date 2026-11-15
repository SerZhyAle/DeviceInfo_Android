#requires -Version 7.0
<#
.SYNOPSIS
    Self-test of tools/design/check-tokens.ps1 (S0022).

.DESCRIPTION
    Runs the check on the real tokens file (must exit 0) and on corrupted copies of it written under temp/S0022/
    (each must exit 1 and print the expected finding). Run it after editing the check. Exit 0 every expectation
    held; 1 an expectation failed.
#>
[CmdletBinding(PositionalBinding = $false)]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$check = Join-Path $PSScriptRoot 'check-tokens.ps1'
$tokens = Join-Path $repoRoot 'docs/design/tokens.json'
$scratch = Join-Path $repoRoot 'temp/S0022'
New-Item -ItemType Directory -Force -Path $scratch | Out-Null
$text = Get-Content -LiteralPath $tokens -Raw -Encoding UTF8
$failed = 0
$total = 0

function Assert-Run {
    param([string] $Name, [string] $Content, [int] $ExpectedExit, [string] $ExpectedText)
    $script:total++
    $path = Join-Path $scratch "selftest-$Name.json"
    [System.IO.File]::WriteAllText($path, $Content, [System.Text.UTF8Encoding]::new($false))
    $output = (& pwsh -NoProfile -File $check -Tokens $path 2>&1) -join "`n"
    $exit = $LASTEXITCODE
    $ok = ($exit -eq $ExpectedExit) -and (-not $ExpectedText -or $output.Contains($ExpectedText))
    if ($ok) { Write-Host "  ok   $Name (exit $exit)" -ForegroundColor Green }
    else { $script:failed++; Write-Host "  FAIL $Name (exit $exit, expected $ExpectedExit; text '$ExpectedText')" -ForegroundColor Red; Write-Host $output }
}

Assert-Run 'real-tokens' $text 0 'check-tokens: OK'
Assert-Run 'night-accent-differs' $text.Replace('"night": "#64B5F6"', '"night": "#64B5F7"') 1 "token 'accent': phone night"
Assert-Run 'glyph-drawable-differs' $text.Replace('"drawable": "ic_wifi"', '"drawable": "ic_internet"') 1 'stands for two meanings'
Assert-Run 'low-contrast' $text.Replace('"day": "#43474E"', '"day": "#B0B4BB"') 1 'onSurfaceVariant on surfaceVariant in day'
Assert-Run 'meaning-not-in-vocabulary' $text.Replace('"meaning": "system.battery"', '"meaning": "system.batteryx"') 1 "is not in the vocabulary"
Assert-Run 'launcher-plate-differs' $text.Replace('"value": "#0D47A1"', '"value": "#0D47A2"') 1 'ic_launcher_background'
# S0035: the watch headers are one sibling set; a header glyph the table loses, a provisional id the proposal does not
# name and a watch-only meaning the vocabulary lacks are each a finding
Assert-Run 'watch-only-row-removed' ([regex]::Replace($text, '\{ "section": "system_info_section_environment"[^\n]*\n', '')) 1 'which the source does not give a glyph'
Assert-Run 'watch-only-proposal-lacks-id' $text.Replace('"provisional": "system.health"', '"provisional": "system.healthx"') 1 "the proposal does not name 'system.healthx'"
Assert-Run 'watch-only-meaning-not-in-vocabulary' $text.Replace('"meaning": "app.help"', '"meaning": "app.helpx"') 1 "meaning 'app.helpx' is not in the vocabulary"

Write-Host ("test-check-tokens: {0} - {1} expectation(s), {2} failed" -f $(if ($failed -eq 0) { 'OK' } else { 'FAIL' }), $total, $failed)
exit $(if ($failed -eq 0) { 0 } else { 1 })
