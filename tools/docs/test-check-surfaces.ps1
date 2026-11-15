#requires -Version 7.0
<#
.SYNOPSIS
    Self-test of the surfaces check (tools/docs/check-surfaces.ps1) on a throw-away tree. Touches nothing of this
    repository but the gitignored temp/S0020 scratch.

.DESCRIPTION
    A parity check that reports nothing passes as quietly as a clean one, so this proves it can fail. On a
    throw-away tree shaped like the repository it walks the rules: a clean tree (exit 0, with a base key marked
    translatable="false" exempt from ru/uk and a negated "declares INTERNET" mention in non-permission rows not
    flagged), a key missing from values-ru, an orphan key in values-uk, a permission declared by no surface named,
    an inventory row for a permission no manifest declares, an inventory row with an unknown package, a privacy
    page missing a permission, a Data safety token declared by no manifest, and the exit 2 of a missing privacy
    page and a missing main manifest.

    The check runs in this process (no `pwsh` spawn per case), which keeps the whole run near one second. Run it
    after editing check-surfaces.ps1.

    Exit code: 0 every expectation held; 1 at least one failed.
#>
[CmdletBinding(PositionalBinding = $false)]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$scratch = Join-Path $repoRoot 'temp\S0020'
$base = Join-Path $scratch ('surfaces-test-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$failures = 0

function Expect([string] $What, $Actual, $Expected) {
    if ($Actual -eq $Expected) { Write-Host "  PASS  $What (expected: $Expected | actual: $Actual)" }
    else { $script:failures++; Write-Host "  FAIL  $What (expected: $Expected | actual: $Actual)" -ForegroundColor Red }
}
# check-surfaces.ps1 ends with `exit N`; run with `&` in this process, which ends the script, not this one, and
# sets $LASTEXITCODE.
function Invoke-Check([string] $TreeRoot) {
    $null = & (Join-Path $PSScriptRoot 'check-surfaces.ps1') -RepoRoot $TreeRoot 6>&1 2>&1
    return $LASTEXITCODE
}
function Write-Text([string] $Root, [string] $Relative, [string] $Text) {
    $path = Join-Path $Root $Relative
    New-Item -ItemType Directory -Force (Split-Path -Parent $path) | Out-Null
    [System.IO.File]::WriteAllText($path, $Text)
}
function New-GoodTree([string] $Root) {
    New-Item -ItemType Directory -Path $Root -Force | Out-Null
    Write-Text $Root 'phone/src/main/AndroidManifest.xml' @'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
</manifest>
'@
    Write-Text $Root 'phone/src/restricted/AndroidManifest.xml' @'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <queries><package android:name="com.example.marker" /></queries>
</manifest>
'@
    Write-Text $Root 'wear/src/main/AndroidManifest.xml' @'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
</manifest>
'@
    Write-Text $Root 'phone/src/main/res/values/strings.xml' @'
<resources>
    <string name="app_name" translatable="false">DeviceInfo</string>
    <string name="sysinfo_a">A</string>
</resources>
'@
    Write-Text $Root 'phone/src/main/res/values-ru/strings.xml' @'
<resources>
    <string name="sysinfo_a">A</string>
</resources>
'@
    Write-Text $Root 'phone/src/main/res/values-uk/strings.xml' @'
<resources>
    <string name="sysinfo_a">A</string>
</resources>
'@
    Write-Text $Root 'docs/SECURITY_INVENTORY.md' @'
# Security posture inventory

## 1. Permission inventory

| Package | Declared in | Permission | Consumer | Justification |
| --- | --- | --- | --- | --- |
| Phone | `phone/src/main/AndroidManifest.xml` | `ACCESS_NETWORK_STATE` | The Network section | Tells whether the device is online. |
| Phone | `phone/src/main/AndroidManifest.xml` | `POST_NOTIFICATIONS` | The watch report notification | Shows the notification. |
| Watch | `wear/src/main/AndroidManifest.xml` | `ACCESS_WIFI_STATE` | The Wi-Fi section | Names the Wi-Fi bands. |

Dropped: watch `WAKE_LOCK`, no consumer.

## 2. Network-surface inventory

| Surface | What leaves |
| --- | --- |
| Outbound connection | Nothing: neither package declares `INTERNET`. |
'@
    foreach ($locale in 'privacy.html', 'privacy-ru.html', 'privacy-uk.html') {
        Write-Text $Root "site/$locale" @'
<html><body>
<h2 id="data">4. Data</h2><p>No telemetry.</p>
<h2 id="permissions">5. Permissions</h2>
<table>
<tr><td>Phone</td><td><code>ACCESS_NETWORK_STATE</code></td><td>Network state.</td></tr>
<tr><td>Phone</td><td><code>POST_NOTIFICATIONS</code></td><td>The notification.</td></tr>
<tr><td>Watch</td><td><code>ACCESS_WIFI_STATE</code></td><td>Wi-Fi bands.</td></tr>
</table>
<p>There is nothing else: no internet, location or camera permission.</p>
<h2 id="google">6. Google Play services</h2><p>The Data Layer runs through Google Play services.</p>
</body></html>
'@
    }
    Write-Text $Root 'docs/play/PLAY_DATA_SAFETY.md' @'
# Google Play Data safety

## Data safety form

| Question | Answer | Why it is true |
| --- | --- | --- |
| Does the app collect or share any of the required user data types? | No | Neither package declares `INTERNET`. |

## App content

| Item | Answer |
| --- | --- |
| Permissions declaration forms | None needed: the only runtime permission is `POST_NOTIFICATIONS` |
| Declared permissions | Phone: `ACCESS_NETWORK_STATE`, `POST_NOTIFICATIONS`; watch: `ACCESS_WIFI_STATE` |
'@
}

try {
    # --- the clean tree, with the two built-in exemptions
    New-GoodTree $base
    Expect 'a tree in step exits 0' (Invoke-Check $base) 0
    Expect 'translatable="false" key exempt from ru/uk' (Test-Path (Join-Path $base 'phone/src/main/res/values/strings.xml')) $true

    # --- string-key parity
    $tree = Join-Path $scratch 't-missing-ru'
    New-GoodTree $tree
    Write-Text $tree 'phone/src/main/res/values-ru/strings.xml' @'
<resources><string name="sysinfo_other">B</string></resources>
'@
    Expect 'a base key missing from values-ru exits 1' (Invoke-Check $tree) 1

    $tree = Join-Path $scratch 't-orphan-uk'
    New-GoodTree $tree
    Write-Text $tree 'phone/src/main/res/values-uk/strings.xml' @'
<resources>
    <string name="sysinfo_a">A</string>
    <string name="sysinfo_orphan">O</string>
</resources>
'@
    Expect 'a values-uk key the base locale does not declare exits 1' (Invoke-Check $tree) 1

    # --- permission parity
    $tree = Join-Path $scratch 't-undeclared-permission'
    New-GoodTree $tree
    Write-Text $tree 'phone/src/main/AndroidManifest.xml' @'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.CAMERA" />
</manifest>
'@
    Expect 'a manifest permission no surface names exits 1' (Invoke-Check $tree) 1

    $tree = Join-Path $scratch 't-phantom-inventory-row'
    New-GoodTree $tree
    Write-Text $tree 'docs/SECURITY_INVENTORY.md' @'
## 1. Permission inventory

| Package | Declared in | Permission | Consumer | Justification |
| --- | --- | --- | --- | --- |
| Phone | `phone/src/main/AndroidManifest.xml` | `ACCESS_NETWORK_STATE` | The Network section | Tells whether the device is online. |
| Phone | `phone/src/main/AndroidManifest.xml` | `POST_NOTIFICATIONS` | The watch report notification | Shows the notification. |
| Watch | `wear/src/main/AndroidManifest.xml` | `ACCESS_WIFI_STATE` | The Wi-Fi section | Names the Wi-Fi bands. |
| Watch | `wear/src/main/AndroidManifest.xml` | `BODY_SENSORS` | The Health section | Reads heart rate. |
'@
    Expect 'an inventory row for a permission no manifest declares exits 1' (Invoke-Check $tree) 1

    $tree = Join-Path $scratch 't-unknown-package'
    New-GoodTree $tree
    Write-Text $tree 'docs/SECURITY_INVENTORY.md' @'
## 1. Permission inventory

| Package | Declared in | Permission | Consumer | Justification |
| --- | --- | --- | --- | --- |
| Restricted | `phone/src/restricted/AndroidManifest.xml` | `ACCESS_NETWORK_STATE` | The Network section | Tells whether the device is online. |
'@
    Expect 'an inventory row with an unknown package exits 1' (Invoke-Check $tree) 1

    $tree = Join-Path $scratch 't-privacy-missing-permission'
    New-GoodTree $tree
    Write-Text $tree 'site/privacy-uk.html' @'
<html><body>
<h2 id="permissions">5. Дозволи</h2>
<table>
<tr><td>Phone</td><td><code>ACCESS_NETWORK_STATE</code></td><td>Мережа.</td></tr>
</table>
<h2 id="google">6. Служби Google Play</h2><p>Data Layer.</p>
</body></html>
'@
    Expect 'a privacy page missing declared permissions exits 1' (Invoke-Check $tree) 1

    $tree = Join-Path $scratch 't-data-safety-phantom'
    New-GoodTree $tree
    Write-Text $tree 'docs/play/PLAY_DATA_SAFETY.md' @'
## App content

| Item | Answer |
| --- | --- |
| Permissions declaration forms | None needed: the only runtime permission is `POST_NOTIFICATIONS` |
| Declared permissions | Phone: `ACCESS_NETWORK_STATE`, `POST_NOTIFICATIONS`; watch: `ACCESS_WIFI_STATE`, `CAMERA` |
'@
    Expect 'a Data safety token no manifest declares exits 1' (Invoke-Check $tree) 1

    # --- exit 2: the check could not run
    $tree = Join-Path $scratch 't-missing-privacy'
    New-GoodTree $tree
    Remove-Item (Join-Path $tree 'site/privacy-ru.html') -Force
    Expect 'a missing privacy page exits 2' (Invoke-Check $tree) 2

    $tree = Join-Path $scratch 't-missing-manifest'
    New-GoodTree $tree
    Remove-Item (Join-Path $tree 'phone/src/main/AndroidManifest.xml') -Force
    Expect 'a missing main manifest exits 2' (Invoke-Check $tree) 2

    if ($failures -eq 0) {
        Write-Host 'OK: every expectation of the surfaces self-test held.'
        exit 0
    }
    Write-Host "FAILED: $failures expectation(s) of the surfaces self-test did not hold." -ForegroundColor Red
    exit 1
}
finally {
    Remove-Item $base -Recurse -Force -ErrorAction SilentlyContinue
}
