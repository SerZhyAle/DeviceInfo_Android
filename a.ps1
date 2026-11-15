#requires -Version 7.0
<#
.SYNOPSIS
    DeviceInfo project scripts launcher: one short command per task, the way a.ps1 works in FastMediaSorter.

.DESCRIPTION
    .\a.ps1 <command> [options]      run one command; options after the command go to its script
    .\a.ps1                          list every command with its tier

    The table below is the single source of both the dispatch and the listing. Every target runs as a child
    `pwsh -NoProfile -File`, so its own parser binds every flag by name. An option of the command line replaces a
    preset of the same name only when it repeats the preset's value; a contradicting one is refused (exit 2) with
    the command that presets it.

    Tiers (CLAUDE.md section 6, canon TESTING_AND_QA section 2): `fast` runs in 5 s or less, `pass` is the compile
    check an unattended pass may run once after an edit of compiled source, `release` is a build or a test run.
    In an agent shell (CLAUDECODE=1) a release-tier command is refused (exit 6) unless the run says it is a release
    run or one the owner named: DEVICEINFO_TIER=Release in the environment. The owner's own shell is never refused.
    DEVICEINFO_TIER=Fast forces the refusal in any shell.

    A Gradle-backed command whose stdout is redirected (a pipe or a file, which is an agent's call) runs through
    tools/build/invoke-isolated.ps1, so a Gradle daemon cannot keep the caller's pipe open after the build is done.
    DEVICEINFO_ISOLATE_STDOUT=1 forces that, 0 turns it off.

.PARAMETER Command
    The command to run; see the listing.

.EXAMPLE
    .\a.ps1 fg
    .\a.ps1 wd
    .\a.ps1 d -DryRun
    .\a.ps1 fu -GradleArgs "--tests com.sza.deviceinfo.core.systeminfo.CameraActiveArrayTextTest"

.NOTES
    Exit codes: the target's own code is returned unchanged. The launcher adds only these:
    1  unknown command or no command, or a target script that does not exist;
    2  an option contradicts the command's preset;
    6  a release-tier command was asked for in an agent shell outside a release run; nothing ran.
#>
param(
    [string]$Command = ''
)

# Everything after <Command> is forwarded to the target. The automatic $args, not a declared parameter, so that
# -flag tokens survive (a declared remaining-arguments parameter would reject them).
$Rest = $args

$ErrorActionPreference = 'Stop'
$ProjectRoot = $PSScriptRoot

$phoneChecks = ':phone:compileStoreDebugKotlin :phone:compileRestrictedDebugKotlin :phone:processStoreDebugResources :phone:processRestrictedDebugResources'
$wearChecks = ':wear:compileDebugKotlin :wear:processDebugResources'

# Args: a hashtable binds by name (a switch is $true); an array is passed as tokens (a positional first argument).
# Tier: fast | pass | release. Gradle: the target starts Gradle, so a redirected stdout is isolated.
$scripts = [ordered]@{
    # --- Build the debug APKs and copy them to Drive (c:\GD\WORK\DeviceInfo) -----------------------------------
    'd'    = @{ Group = 'Debug APKs (build, then copy to c:\GD\WORK\DeviceInfo)'; Path = 'tools\build\build-debug.ps1'; Args = @{ Variant = 'store' }; Tier = 'release'; Gradle = $true; Help = 'Phone store debug APK' }
    'nd'   = @{ Path = 'tools\build\build-debug.ps1'; Args = @{ Variant = 'restricted' }; Tier = 'release'; Gradle = $true; Help = 'Phone restricted debug APK (the seven extended diagnostics sections)' }
    'wd'   = @{ Path = 'tools\build\build-debug.ps1'; Args = @{ Variant = 'wear' }; Tier = 'release'; Gradle = $true; Help = 'Wear OS debug APK' }
    'da'   = @{ Path = 'tools\build\build-debug.ps1'; Args = @{ Variant = 'all' }; Tier = 'release'; Gradle = $true; Help = 'All three debug APKs' }
    'db'   = @{ Path = 'tools\build\build-debug.ps1'; Args = @{ Variant = 'all'; NoCopy = $true }; Tier = 'release'; Gradle = $true; Help = 'All three debug APKs, no Drive copy' }
    'cp'   = @{ Path = 'tools\build\copy-apk.ps1'; Args = @{}; Tier = 'fast'; Help = 'Copy the already built debug APKs to Drive (-Variant, -DriveDir, -DryRun)' }

    # --- Compile and test (Build lock) -------------------------------------------------------------------------
    'fc'   = @{ Group = 'Compile checks and tests (each call takes the Build lock)'; Path = 'tools\build\run-gradle.ps1'; Args = @{ Tasks = "$phoneChecks $wearChecks"; GradleArgs = '--continue' }; Tier = 'pass'; Gradle = $true; Help = 'The declared compile check: Kotlin and resources, both phone flavors and wear' }
    'fk'   = @{ Path = 'tools\build\run-gradle.ps1'; Args = @{ Tasks = ':phone:compileStoreDebugKotlin' }; Tier = 'pass'; Gradle = $true; Help = 'Kotlin compile, phone store' }
    'fkn'  = @{ Path = 'tools\build\run-gradle.ps1'; Args = @{ Tasks = ':phone:compileRestrictedDebugKotlin' }; Tier = 'pass'; Gradle = $true; Help = 'Kotlin compile, phone restricted' }
    'fr'   = @{ Path = 'tools\build\run-gradle.ps1'; Args = @{ Tasks = ':phone:processStoreDebugResources' }; Tier = 'pass'; Gradle = $true; Help = 'Resources and manifest, phone store' }
    'frn'  = @{ Path = 'tools\build\run-gradle.ps1'; Args = @{ Tasks = ':phone:processRestrictedDebugResources' }; Tier = 'pass'; Gradle = $true; Help = 'Resources and manifest, phone restricted' }
    'fw'   = @{ Path = 'tools\build\run-gradle.ps1'; Args = @{ Tasks = ':wear:compileDebugKotlin' }; Tier = 'pass'; Gradle = $true; Help = 'Kotlin compile, wear (a change under wear/ needs this, the phone targets do not look at it)' }
    'fwr'  = @{ Path = 'tools\build\run-gradle.ps1'; Args = @{ Tasks = ':wear:processDebugResources' }; Tier = 'pass'; Gradle = $true; Help = 'Resources and manifest, wear' }
    'fu'   = @{ Path = 'tools\build\run-gradle.ps1'; Args = @{ Tasks = ':phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest' }; Tier = 'release'; Gradle = $true; Help = 'Phone unit tests, both flavors (-GradleArgs "--tests <class>" narrows)' }
    'fwu'  = @{ Path = 'tools\build\run-gradle.ps1'; Args = @{ Tasks = ':wear:testDebugUnitTest' }; Tier = 'release'; Gradle = $true; Help = 'Wear unit tests' }
    'fb'   = @{ Path = 'tools\build\run-gradle.ps1'; Args = @{ Tasks = 'test'; GradleArgs = '--project-dir buildSrc' }; Tier = 'release'; Gradle = $true; Help = 'buildSrc unit tests (VersionStamp, ReleaseSigning)' }

    # --- Gates and queue ---------------------------------------------------------------------------------------
    'fg'   = @{ Group = 'Gates and the ticket queue'; Path = 'tools\check-fast.ps1'; Args = @{}; Tier = 'fast'; Help = 'Every fast-tier gate of CLAUDE.md section 6 in one pass (-Only <text>, -List, -Show)' }
    'ss'   = @{ Path = 'tools\harness.ps1'; Args = @('spec_catalog/release-queue', '-List'); Tier = 'fast'; Help = 'Show the release queue (work remaining); -Ready shows the ready set' }

    # --- Queue runners (the root launchers rendered by the harness) -------------------------------------------
    'r0'   = @{ Group = 'Queue runners'; Path = 'r0.ps1'; Args = @{}; Help = 'Portfolio worker for this repository (pq); -DryRun shows what would start' }
    'r1'   = @{ Path = 'r1.ps1'; Args = @{}; Help = 'Run the release queue unattended, instance A (one fresh process per ticket)' }
    'r2'   = @{ Path = 'r2.ps1'; Args = @{}; Help = 'Same, instance B, staggered' }
    'r3'   = @{ Path = 'r3.ps1'; Args = @{}; Help = 'Same, instance C, staggered further' }
    'rs'   = @{ Path = 'rs.ps1'; Args = @{}; Help = 'Stop the runners after the ticket each is on' }
    'rm'   = @{ Path = 'rm.ps1'; Args = @{}; Help = 'Monitor the runners (-Watch to refresh, -Json for the snapshot)' }
    'rw'   = @{ Path = 'rw.ps1'; Args = @{}; Help = 'Portfolio dispatcher scoped to this repository' }

    # --- Locks -------------------------------------------------------------------------------------------------
    'ub'   = @{ Group = 'Locks'; Path = 'tools\harness.ps1'; Args = @('locks/clear-agent-lock', '-Name', 'Build'); Tier = 'fast'; Help = 'Unlock build: clear a stale or dead Build lock (refuses a live holder; -Force once the holder is gone)' }
    'uc'   = @{ Path = 'tools\harness.ps1'; Args = @('locks/clear-agent-lock', '-Name', 'Code'); Tier = 'fast'; Help = 'Unlock code: the same for the Code locks' }
}

function Resolve-ActiveTier {
    # DEVICEINFO_TIER wins; otherwise an agent shell is Fast and everything else (the owner, CI) is Release.
    $requested = $env:DEVICEINFO_TIER
    if ($requested -ieq 'Fast') { return 'Fast' }
    if ($requested -ieq 'Release') { return 'Release' }
    if ($env:CLAUDECODE -eq '1') { return 'Fast' }
    return 'Release'
}

function Write-Usage {
    Write-Host "DeviceInfo scripts launcher - .\a.ps1 <command> [options]" -ForegroundColor Cyan
    foreach ($entry in $scripts.GetEnumerator()) {
        if ($entry.Value.Group) {
            Write-Host ""
            Write-Host $entry.Value.Group -ForegroundColor Yellow
        }
        $mark = switch ($entry.Value.Tier) { 'release' { '[release]' } 'pass' { '[pass]   ' } 'fast' { '[fast]   ' } default { '         ' } }
        Write-Host ("  {0,-5} {1} {2}" -f $entry.Key, $mark, $entry.Value.Help) -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "Tiers: [fast] 5 s or less. [pass] the compile check, allowed once per unattended pass. [release] a build or a test run:" -ForegroundColor Gray
    Write-Host "an agent shell is refused (exit 6) unless DEVICEINFO_TIER=Release is set for a release run or a run the owner named." -ForegroundColor Gray
    Write-Host "Example: .\a.ps1 fg     .\a.ps1 wd     .\a.ps1 d -DryRun" -ForegroundColor Gray
}

function ConvertTo-ChildArgumentList {
    param($Preset, $Extra)

    # A hashtable splat cannot cross a process boundary, so the preset is flattened to tokens: a switch carries no
    # value, everything else is two tokens. An extra `-Variant wear` replaces the preset `-Variant store` (the
    # repeat check below has already refused a contradiction, so this only drops a repeated value).
    $flat = @()
    $overridden = @($Extra | Where-Object { "$_" -match '^-([A-Za-z_][\w-]*)' } | ForEach-Object { $Matches[1] })
    if ($Preset -is [hashtable]) {
        foreach ($key in $Preset.Keys) {
            if ($overridden -contains $key) { continue }
            $value = $Preset[$key]
            if ($value -is [bool]) { if ($value) { $flat += "-$key" } }
            else { $flat += "-$key"; $flat += "$value" }
        }
    }
    elseif ($Preset) {
        $flat += @($Preset | ForEach-Object { "$_" })
    }
    foreach ($token in $Extra) {
        # `pwsh -File` hands `-Flag:false` over as two tokens, the second a [bool]; a switch given $false is the
        # switch absent, so the flag is dropped, and $true keeps the bare flag.
        if ($token -is [bool] -and $flat.Count -gt 0 -and $flat[-1] -match '^-[A-Za-z_][\w-]*$') {
            if (-not $token) { $flat = @($flat | Select-Object -SkipLast 1) }
            continue
        }
        $flat += "$token"
    }
    return , $flat
}

function Resolve-PresetRepeats {
    param([hashtable]$Preset, $Extra, [string]$TargetPath)

    # A repeat of a preset value is dropped with a note; a different value is refused here, naming the commands
    # that already preset it, instead of letting PowerShell fail with "specified more than once".
    $kept = New-Object System.Collections.Generic.List[object]
    $tokens = @($Extra)
    for ($i = 0; $i -lt $tokens.Count; $i++) {
        $token = $tokens[$i]
        $key = $null
        $inline = $null
        if ($token -is [string] -and $token -match '^-([A-Za-z][A-Za-z0-9]*)(?::(.*))?$') {
            $key = @($Preset.Keys | Where-Object { $_ -ieq $Matches[1] }) | Select-Object -First 1
            if ($Matches.ContainsKey(2)) { $inline = $Matches[2] }
        }
        if (-not $key) { $kept.Add($token); continue }

        $boolFollows = (($i + 1) -lt $tokens.Count) -and ($tokens[$i + 1] -is [bool])
        if (($inline -eq '' -or ($null -eq $inline -and $boolFollows)) -and ($i + 1) -lt $tokens.Count) { $i++; $inline = $tokens[$i] }
        $presetValue = $Preset[$key]
        if ($presetValue -is [bool]) {
            $asked = if ($null -eq $inline) { $true } elseif ($inline -is [bool]) { $inline } else { "$inline" -in @('$true', 'true') }
            $same = ($asked -eq $presetValue)
        }
        else {
            if ($null -eq $inline -and ($i + 1) -lt $tokens.Count) { $i++; $inline = $tokens[$i] }
            $asked = "$inline"
            $same = ($asked -ieq "$presetValue")
        }
        if ($same) {
            Write-Host "Note: -$key $asked is already this command's preset - dropped the repeat." -ForegroundColor DarkGray
            continue
        }
        $matching = @($scripts.GetEnumerator() | Where-Object {
                $other = $_.Value.Args
                $otherValue = if ($other -is [hashtable] -and $other.ContainsKey($key)) { $other[$key] } elseif ($asked -is [bool]) { $false } else { $null }
                $_.Value.Path -eq $TargetPath -and $null -ne $otherValue -and "$otherValue" -ieq "$asked"
            } | ForEach-Object { $_.Key } | Sort-Object)
        $hint = if ($matching.Count -gt 0) { "use .\a.ps1 $($matching -join ' / ') instead" } else { "call $TargetPath directly with -$key $asked" }
        Write-Host "a.ps1: '$Command' presets -$key $presetValue, and -$key $asked contradicts it - $hint." -ForegroundColor Red
        exit 2
    }
    return , $kept.ToArray()
}

$Command = $Command.Trim().ToLowerInvariant()
if ([string]::IsNullOrWhiteSpace($Command) -or -not $scripts.Contains($Command)) {
    if ($Command) { Write-Host "Unknown command: $Command" -ForegroundColor Red; Write-Host "" }
    Write-Usage
    exit 1
}

$entry = $scripts[$Command]
$scriptPath = Join-Path $ProjectRoot $entry.Path

# Between releases an agent runs only checks of 5 s or less; a release-tier command is refused unless the run says
# it is a release run or one the owner named.
if ((Resolve-ActiveTier) -eq 'Fast' -and $entry.Tier -eq 'release') {
    Write-Host "a.ps1: '$Command' is a release-tier command (a build or a test run; the line is 5 s) and does not run between releases." -ForegroundColor Yellow
    Write-Host "  Fast gates for what you changed:  .\a.ps1 fg" -ForegroundColor Yellow
    Write-Host "  A release run, or one the owner named:  `$env:DEVICEINFO_TIER = 'Release'; .\a.ps1 $Command .." -ForegroundColor Yellow
    Write-Host "  Report it as: not built, not tested until the release." -ForegroundColor Yellow
    exit 6
}

if (-not (Test-Path -LiteralPath $scriptPath)) {
    Write-Host "Script not found: $scriptPath" -ForegroundColor Red
    exit 1
}

$preset = $entry.Args
if ($preset -is [hashtable] -and $preset.Count -gt 0 -and @($Rest).Count -gt 0) {
    $Rest = Resolve-PresetRepeats -Preset $preset -Extra $Rest -TargetPath $entry.Path
}

$display = if ($preset -is [hashtable]) {
    ($preset.GetEnumerator() | ForEach-Object { if ($_.Value -is [bool]) { "-$($_.Key)" } else { "-$($_.Key) $($_.Value)" } }) -join ' '
} else { $preset -join ' ' }
Write-Host "Executing: $($entry.Path) $display $($Rest -join ' ')" -ForegroundColor Green
Write-Host ""

$childArgs = ConvertTo-ChildArgumentList -Preset $preset -Extra $Rest
$isolate = switch ($env:DEVICEINFO_ISOLATE_STDOUT) {
    '1' { $true }
    '0' { $false }
    default { [bool]$entry.Gradle -and [Console]::IsOutputRedirected }
}
if ($isolate) {
    & (Join-Path $ProjectRoot 'tools\build\invoke-isolated.ps1') -ScriptPath $scriptPath -Arguments $childArgs
}
else {
    & pwsh -NoProfile -File $scriptPath @childArgs
}
exit $LASTEXITCODE
