<#
.SYNOPSIS
    PACKAGE-VERSIONING parity gate (Android profile, rule 8) for the phone and the watch app.

.DESCRIPTION
    A second implementation of the contract's formula (rules 2 and 3) in the toolchain of the repository's
    scripts, held against three things:
      1. the contract's own fixed-instant vectors, so this implementation cannot drift from the formula;
      2. the checked-in sentinels in gradle.properties (rule 7), which must be the formula applied to the instant
         their versionName encodes, for both families;
      3. buildSrc/.../VersionStampTest.kt, which must carry the same contract vector, so the Kotlin derivation
         (the in-build net) and this one are tested against the same strings.
    It reads files only and runs in well under a second. The Kotlin vectors themselves run with
    `.\gradlew.bat -p buildSrc test`, a release-tier run.

    Exit codes: 0 PASS, 1 FAIL (a drifted vector or sentinel), 2 could not verify (an input file is missing).

.PARAMETER Root
    Repository root. Defaults to two levels above this script.
#>
[CmdletBinding()]
param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'
$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

# The formula lives in one place for the scripts of this repository: tools/release/VersionStamp.ps1.
. (Join-Path $PSScriptRoot 'VersionStamp.ps1')

function Assert-Equal {
    param([string]$What, $Expected, $Actual)
    $script:checks++
    if ("$Expected" -ne "$Actual") { $script:failures.Add("$What : expected $Expected | actual $Actual") }
}

# 1. The contract's vectors: the example of rules 2 and 3, the band edges, a leap day.
$vectors = @(
    @{ Instant = '2609262322'; Family = 'phone'; Name = '2.60.9262.322'; Code = 260926232 },
    @{ Instant = '2609262322'; Family = 'wear'; Name = '2.60.9262.322'; Code = 260926237 },
    @{ Instant = '2611130800'; Family = 'phone'; Name = '2.61.1130.800'; Code = 261113080 },
    @{ Instant = '2611130859'; Family = 'phone'; Name = '2.61.1130.859'; Code = 261113085 },
    @{ Instant = '2611130800'; Family = 'wear'; Name = '2.61.1130.800'; Code = 261113086 },
    @{ Instant = '2611130815'; Family = 'wear'; Name = '2.61.1130.815'; Code = 261113087 },
    @{ Instant = '2611130859'; Family = 'wear'; Name = '2.61.1130.859'; Code = 261113089 },
    @{ Instant = '2802290000'; Family = 'phone'; Name = '2.80.2290.000'; Code = 280229000 }
)
foreach ($v in $vectors) {
    $got = Convert-InstantToStamp -Instant $v.Instant -Family $v.Family
    Assert-Equal "vector $($v.Instant) $($v.Family) name" $v.Name $got.Name
    Assert-Equal "vector $($v.Instant) $($v.Family) code" $v.Code $got.Code
}

# The two families never repeat a code under one application id, for every minute of an hour.
for ($minute = 0; $minute -lt 60; $minute++) {
    $instant = '26111308{0:D2}' -f $minute
    $phone = (Convert-InstantToStamp -Instant $instant -Family 'phone').Code
    $wear = (Convert-InstantToStamp -Instant $instant -Family 'wear').Code
    $checks++
    if ($phone -eq $wear) { $failures.Add("minute ${minute}: phone and watch share code $phone") }
    $checks++
    if (($phone % 10) -gt 5 -or ($wear % 10) -lt 6) { $failures.Add("minute ${minute}: a code left its band ($phone, $wear)") }
}

# 2. The checked-in sentinels (rule 7).
$propertiesPath = Join-Path $Root 'gradle.properties'
$testPath = Join-Path $Root 'buildSrc\src\test\kotlin\com\sza\deviceinfo\buildlogic\VersionStampTest.kt'
foreach ($required in @($propertiesPath, $testPath)) {
    if (-not (Test-Path -LiteralPath $required)) {
        Write-Host "check-version-parity: could not verify - missing $required"
        exit 2
    }
}

$props = @{}
foreach ($line in Get-Content -LiteralPath $propertiesPath) {
    if ($line -match '^\s*([A-Za-z0-9_.]+)\s*=\s*(.*?)\s*$' -and $line -notmatch '^\s*#') { $props[$Matches[1]] = $Matches[2] }
}
foreach ($key in 'deviceinfo.sentinel.versionName', 'deviceinfo.sentinel.versionCode.phone', 'deviceinfo.sentinel.versionCode.wear') {
    if (-not $props.ContainsKey($key)) {
        Write-Host "check-version-parity: could not verify - gradle.properties has no $key"
        exit 2
    }
}

$sentinelName = $props['deviceinfo.sentinel.versionName']
if ($sentinelName -notmatch '^\d\.\d{2}\.\d{4}\.\d{3}$') {
    $failures.Add("sentinel versionName '$sentinelName' is not Y.YM.MDDH.Hmm")
}
else {
    $sentinelInstant = $sentinelName -replace '\.', ''
    foreach ($family in 'phone', 'wear') {
        $expected = Convert-InstantToStamp -Instant $sentinelInstant -Family $family
        Assert-Equal "sentinel $family versionName" $expected.Name $sentinelName
        Assert-Equal "sentinel $family versionCode" $expected.Code $props["deviceinfo.sentinel.versionCode.$family"]
    }
}

# 3. The Kotlin vectors carry the contract example too (the two derivations are tested against the same strings).
$kotlinTest = Get-Content -LiteralPath $testPath -Raw
foreach ($needle in '2609262322', '2.60.9262.322', '260926232', '260926237') {
    $checks++
    if (-not $kotlinTest.Contains($needle)) { $failures.Add("VersionStampTest.kt does not carry the contract vector '$needle'") }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Host "FAIL $_" }
    Write-Host "check-version-parity: FAIL ($($failures.Count) of $checks checks)"
    exit 1
}
Write-Host "check-version-parity: PASS ($checks checks; sentinel $sentinelName / phone $($props['deviceinfo.sentinel.versionCode.phone']) / watch $($props['deviceinfo.sentinel.versionCode.wear']))"
exit 0
