# PACKAGE-VERSIONING, Android profile, rules 1 to 3, for the phone and the watch app of DeviceInfo: the PowerShell
# implementation of the formula that buildSrc/.../VersionStamp.kt implements for the build. Dot-source it:
#     . (Join-Path $PSScriptRoot 'VersionStamp.ps1')
# check-version-parity.ps1 holds both against the contract's vectors and the checked-in sentinels (rule 8).

# The family's map of a minute (0..59) into its band of the last versionCode digit: the phone owns 0..5 in 10-minute
# slots, the watch app 6..9 in 15-minute slots, because both install under one application id (rule 3).
function Get-Partition {
    param([string]$Family, [int]$Minute)
    if ($Family -eq 'phone') { return [int][math]::Floor($Minute / 10) }
    return 6 + [int][math]::Floor($Minute / 15)
}

# Rules 1 to 3: the ten digits yyMMddHHmm rendered as versionName (Y.YM.MDDH.Hmm) and as the 9-digit versionCode of a
# family. An instant that is not a real date and time throws.
function Convert-InstantToStamp {
    param([string]$Instant, [string]$Family)
    if ($Instant -notmatch '^\d{10}$') { throw "The instant must be ten digits, yyMMddHHmm; got '$Instant'." }
    $year = 2000 + [int]$Instant.Substring(0, 2)
    $month = [int]$Instant.Substring(2, 2)
    $day = [int]$Instant.Substring(4, 2)
    $hour = [int]$Instant.Substring(6, 2)
    $minute = [int]$Instant.Substring(8, 2)
    if ($month -lt 1 -or $month -gt 12) { throw "The instant '$Instant' has no month $month." }
    if ($day -lt 1 -or $day -gt [datetime]::DaysInMonth($year, $month)) { throw "The instant '$Instant' has no day $day." }
    if ($hour -gt 23) { throw "The instant '$Instant' has no hour $hour." }
    if ($minute -gt 59) { throw "The instant '$Instant' has no minute $minute." }
    [pscustomobject]@{
        Name = '{0}.{1}.{2}.{3}' -f $Instant[0], $Instant.Substring(1, 2), $Instant.Substring(3, 4), $Instant.Substring(7)
        Code = ([int]$Instant.Substring(0, 8)) * 10 + (Get-Partition -Family $Family -Minute $minute)
    }
}
