#requires -Version 7.0
# Direct call of the changed locator kind (S0040): the watch button text of each locale against the new textRefFormat.
$ErrorActionPreference = 'Stop'
$root = 'P:\ANDROID\deviceinfo_mob'
. (Join-Path $root 'tools/help/_help.ps1')
. (Join-Path $root 'tools/help/_capture.ps1')

function New-FakeNode([string] $Text, [int] $Top) {
    [pscustomobject]@{ ResourceId = ''; Text = $Text; ContentDesc = ''; Clickable = $true; Bounds = @(0, $Top, 1000, ($Top + 100)) }
}
function Find-Interface([object[]] $Nodes, [string] $Locale) {
    $locator = Resolve-Locator -Root $root -Module wear -Locale $Locale -Locator @{ by = 'textRefFormat'; value = 'system_info_interface_scale'; clickable = $true }
    Find-UiNode -Nodes $Nodes -Resolved $locator -ScreenWidth 1000 -ScreenHeight 2000
}

$all = @(
    (New-FakeNode 'Model: Pixel' 600),
    (New-FakeNode 'Interface size: 100 %' 800),
    (New-FakeNode 'Размер интерфейса: 115 %' 900),
    (New-FakeNode 'Розмір інтерфейсу: 130 %' 1000),
    (New-FakeNode 'Interface size: x %' 1100)
)
$checks = [ordered]@{
    'en matches its own text'                     = { $h = Find-Interface $all 'en'; $null -ne $h -and $h.Bounds[1] -eq 800 }
    'ru matches its own text'                     = { $h = Find-Interface $all 'ru'; $null -ne $h -and $h.Bounds[1] -eq 900 }
    'uk matches its own text'                     = { $h = Find-Interface $all 'uk'; $null -ne $h -and $h.Bounds[1] -eq 1000 }
    'en refuses the Russian text alone'           = { $null -eq (Find-Interface @($all[2]) 'en') }
    'en refuses a text without a number'          = { $null -eq (Find-Interface @($all[4]) 'en') }
    'uk refuses the English text alone'           = { $null -eq (Find-Interface @($all[1]) 'uk') }
}
$failed = 0
foreach ($name in $checks.Keys) {
    $ok = [bool](& $checks[$name])
    if (-not $ok) { $failed++ }
    "{0,-4} {1}" -f $(if ($ok) { 'ok' } else { 'FAIL' }), $name
}
$pattern = (Resolve-Locator -Root $root -Module wear -Locale en -Locator @{ by = 'textRefFormat'; value = 'system_info_interface_scale' }).TextPattern
"en pattern: $($pattern.ToString())"
if ($failed -gt 0) { "direct-check: FAIL ($failed of $($checks.Count))"; exit 1 }
"direct-check: PASS ($($checks.Count) checks)"
exit 0
