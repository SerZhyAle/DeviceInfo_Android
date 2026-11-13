<#
.SYNOPSIS
    Prints the release pin of DeviceInfo (PACKAGE-VERSIONING rule 5) for one instant.

.DESCRIPTION
    One instant, yyMMddHHmm of the local wall clock (rule 1), renders the versionName both packages share and the
    versionCode of each family. The three Gradle properties are passed together to the one invocation that builds both
    packages; buildSrc refuses a pin that does not describe one instant of each family's partition. The release tag is
    v + the versionName. Nothing is written and no tag is cut: the release flow is run on the owner's order only.

.PARAMETER Instant
    yyMMddHHmm. Defaults to the local clock now.

.EXAMPLE
    pwsh -NoProfile -File tools/release/new-version-pin.ps1 -Instant 2611130822
    -Pdeviceinfo.pin.versionName=2.61.1130.822 -Pdeviceinfo.pin.versionCode.phone=261113082 -Pdeviceinfo.pin.versionCode.wear=261113087
#>
[CmdletBinding()]
param([string]$Instant = (Get-Date -Format 'yyMMddHHmm'))

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'VersionStamp.ps1')

$phone = Convert-InstantToStamp -Instant $Instant -Family 'phone'
$wear = Convert-InstantToStamp -Instant $Instant -Family 'wear'
Write-Host "-Pdeviceinfo.pin.versionName=$($phone.Name) -Pdeviceinfo.pin.versionCode.phone=$($phone.Code) -Pdeviceinfo.pin.versionCode.wear=$($wear.Code)"
Write-Host "tag v$($phone.Name)"
