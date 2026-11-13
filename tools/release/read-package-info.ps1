<#
.SYNOPSIS
    Reads the identity of a built package back from the file and compares it with what the release meant to ship.

.DESCRIPTION
    PACKAGE-VERSIONING P5: each artifact of a release carries the pinned stamp in a field a check reads back from the
    produced file, not from the build script's own variable. This script reads package name, versionCode, versionName
    and the declared permissions of

      - an .apk with `aapt2 dump badging` (aapt2 from the build-tools of the SDK named in local.properties), or
      - an .aab with bundletool (`-BundletoolJar`, or `bundletool` on PATH) via `dump manifest`.

    It then compares them with -ExpectedPackage, -ExpectedName and -ExpectedCode when given, refuses the permission
    `android.permission.INTERNET` (neither package declares it, and the privacy page says so), and, with
    -AllowedPermissions, refuses any permission outside that list. The AndroidX generated
    `<package>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` is not counted.

    Exit codes: 0 PASS, 1 FAIL (a mismatch or a refused permission), 2 could not verify (no tool, unreadable file).

.EXAMPLE
    pwsh -NoProfile -File tools/release/read-package-info.ps1 phone\build\outputs\apk\release\phone-release.apk `
        -ExpectedName 2.61.1130.822 -ExpectedCode 261113082 -AllowedPermissions ACCESS_NETWORK_STATE,POST_NOTIFICATIONS
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)][string]$Path,
    [string]$ExpectedPackage = 'com.sza.deviceinfo',
    [string]$ExpectedName,
    [string]$ExpectedCode,
    [string[]]$AllowedPermissions,
    [string]$BundletoolJar
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

function Stop-Unverified([string]$Why) {
    Write-Host "read-package-info: could not verify - $Why"
    exit 2
}

if (-not (Test-Path -LiteralPath $Path)) { Stop-Unverified "no such file: $Path" }
$file = (Resolve-Path -LiteralPath $Path).Path
$extension = [IO.Path]::GetExtension($file).ToLowerInvariant()

$package = $null; $code = $null; $name = $null
$permissions = New-Object System.Collections.Generic.List[string]

if ($extension -eq '.apk') {
    $sdk = $null
    $localProperties = Join-Path $root 'local.properties'
    if (Test-Path -LiteralPath $localProperties) {
        $line = Select-String -LiteralPath $localProperties -Pattern '^\s*sdk\.dir\s*=\s*(.+?)\s*$' | Select-Object -First 1
        if ($line) { $sdk = ($line.Matches[0].Groups[1].Value -replace '\\\\', '\' -replace '\\:', ':') }
    }
    if (-not $sdk -or -not (Test-Path -LiteralPath $sdk)) { Stop-Unverified 'sdk.dir of local.properties is missing or does not exist' }
    $aapt2 = Get-ChildItem -LiteralPath (Join-Path $sdk 'build-tools') -Filter 'aapt2.exe' -Recurse -Depth 2 -ErrorAction SilentlyContinue |
        Sort-Object { [version]($_.Directory.Name -replace '[^\d.]', '') } -Descending | Select-Object -First 1
    if (-not $aapt2) { Stop-Unverified 'no aapt2.exe under the SDK build-tools' }
    $badging = & $aapt2.FullName dump badging $file 2>&1
    if ($LASTEXITCODE -ne 0) { Stop-Unverified "aapt2 could not read $file" }
    foreach ($line in $badging) {
        if ($line -match "^package: name='([^']*)' versionCode='([^']*)' versionName='([^']*)'") {
            $package = $Matches[1]; $code = $Matches[2]; $name = $Matches[3]
        }
        elseif ($line -match "^uses-permission(-sdk-\d+)?: name='([^']*)'") { $permissions.Add($Matches[2]) }
    }
}
elseif ($extension -eq '.aab') {
    $manifest = $null
    if ($BundletoolJar) {
        if (-not (Test-Path -LiteralPath $BundletoolJar)) { Stop-Unverified "no such bundletool jar: $BundletoolJar" }
        $manifest = & java -jar $BundletoolJar dump manifest --bundle=$file 2>&1
    }
    elseif (Get-Command bundletool -ErrorAction SilentlyContinue) {
        $manifest = & bundletool dump manifest --bundle=$file 2>&1
    }
    else { Stop-Unverified 'an .aab needs bundletool: pass -BundletoolJar or put bundletool on PATH' }
    if ($LASTEXITCODE -ne 0) { Stop-Unverified "bundletool could not read $file" }
    $text = $manifest -join "`n"
    if ($text -match '<manifest[^>]*\spackage="([^"]*)"') { $package = $Matches[1] }
    if ($text -match 'android:versionCode="([^"]*)"') { $code = $Matches[1] }
    if ($text -match 'android:versionName="([^"]*)"') { $name = $Matches[1] }
    foreach ($m in [regex]::Matches($text, '<uses-permission[^>]*android:name="([^"]*)"')) { $permissions.Add($m.Groups[1].Value) }
}
else { Stop-Unverified "unsupported file type '$extension' (an .apk or an .aab is expected)" }

if (-not $package) { Stop-Unverified "no package identity found in $file" }

$declared = @($permissions | Where-Object { $_ -notlike '*.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION' } | Sort-Object -Unique)
$failures = New-Object System.Collections.Generic.List[string]
function Compare-Field([string]$What, $Expected, $Actual) {
    if ($PSBoundParameters.ContainsKey('Expected') -and $null -ne $Expected -and "$Expected" -ne '' -and "$Expected" -ne "$Actual") {
        $failures.Add("$What : expected $Expected | actual $Actual")
    }
}
Compare-Field 'package' $ExpectedPackage $package
Compare-Field 'versionName' $ExpectedName $name
Compare-Field 'versionCode' $ExpectedCode $code
if ($declared -contains 'android.permission.INTERNET') { $failures.Add('the package declares android.permission.INTERNET') }
if ($AllowedPermissions) {
    $allowed = @($AllowedPermissions | ForEach-Object { if ($_ -like '*.*') { $_ } else { "android.permission.$_" } })
    foreach ($p in $declared) { if ($allowed -notcontains $p) { $failures.Add("permission not in the allowed list: $p") } }
}

Write-Host "package     $package"
Write-Host "versionCode $code"
Write-Host "versionName $name"
Write-Host "permissions $(if ($declared.Count) { $declared -join ', ' } else { '(none)' })"
if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Host "FAIL $_" }
    Write-Host "read-package-info: FAIL ($($failures.Count))"
    exit 1
}
Write-Host "read-package-info: PASS ($(Split-Path $file -Leaf))"
exit 0
