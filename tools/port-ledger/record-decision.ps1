#requires -Version 7.0
<#
.SYNOPSIS
    Records a decision NOT to port an in-scope upstream file or string key (docs/port-decisions.jsonl).

.DESCRIPTION
    check-scope.ps1 fails on every in-scope upstream item that is neither ported nor decided. Porting is
    recorded with record-port.ps1; a deliberate not-port is recorded here, with the reason, pinned to the
    upstream version it was made about - the next upstream change re-opens the decision, exactly like
    record-port.ps1 -Decide for drift (PORT-LEDGER 0.1 rule 3):

      record-decision.ps1 -Source <upstream path> -Note "<why>"        a file is deliberately not ported
      record-decision.ps1 -StringKey <key> -Note "<why>"               a string key is not ported by name

    A file decision pins the upstream file's current SHA-256. A string decision pins the key's current value
    in the file that declares it. Running the same item again re-pins it (new value, new note, new date) -
    that is the recovery step after check-scope.ps1 reports STALE DECISION. Paths are relative to the
    upstream root. The upstream tree is only read.

    Exit code: 0 the decision was written; 2 the call could not be honoured (missing file, unknown string key,
    both or neither of -Source and -StringKey, no -Note, absolute or escaping path).

.PARAMETER Source
    Path inside the upstream repository, for example app_v2/src/main/java/com/sza/fastmediasorter/core/util/CoroutineExt.kt.
.PARAMETER StringKey
    A string key the scope's strings block watches, for example sysinfo_search_hint.
.PARAMETER Note
    The reason, one line.
.PARAMETER Date
    yyyy-MM-dd, default today.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $Source,
    [string] $StringKey,
    [Parameter(Mandatory)][string] $Note,
    [string] $Date,
    [string] $SourceRoot,
    [string] $Scope,
    [string] $Decisions
)

. (Join-Path $PSScriptRoot '_ledger.ps1')
. (Join-Path $PSScriptRoot '_scope.ps1')
$ErrorActionPreference = 'Stop'
trap { Write-Host "record-decision: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

if ($Source -and $StringKey) { throw '-Source and -StringKey exclude each other.' }
if (-not $Source -and -not $StringKey) { throw 'Pass -Source or -StringKey.' }
$day = if ($Date) { $Date } else { (Get-Date).ToString('yyyy-MM-dd') }
if ($day -notmatch '^\d{4}-\d{2}-\d{2}$') { throw "-Date '$Date' is not yyyy-MM-dd." }
$trimmedNote = $Note.Trim()
if ([string]::IsNullOrWhiteSpace($trimmedNote)) { throw '-Note may not be blank.' }

$sourceRootResolved = Get-SourceRoot $SourceRoot
$scopeData = Read-ScopeFile (Get-ScopeFile $Scope)

$row = $null
if ($Source) {
    $sourceRel = ConvertTo-RelativeLedgerPath $Source 'Source'
    $sourceFile = Join-Path $sourceRootResolved $sourceRel
    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) { throw "Source file '$sourceRel' does not exist upstream." }
    $row = [ordered]@{
        kind         = 'file'
        item         = $sourceRel
        sourceSha256 = Get-FileSha256 $sourceFile
        note         = $trimmedNote
        decidedOn    = $day
    }
} else {
    $upstreamKeys = Get-UpstreamStringKeys $sourceRootResolved $scopeData
    if (-not $upstreamKeys.ContainsKey($StringKey)) { throw "String key '$StringKey' is not in the upstream files the scope's strings block scans." }
    # Pin the value in the file that declares it; the locale-free `values/` file wins when there are several.
    $occurrences = @($upstreamKeys[$StringKey])
    $base = @($occurrences | Where-Object { $_.file -match '/values/' })
    $chosen = if ($base.Count -gt 0) { $base[0] } else { @($occurrences | Sort-Object file)[0] }
    $row = [ordered]@{
        kind        = 'string'
        item        = $StringKey
        sourceFile  = $chosen.file
        pinnedValue = $chosen.value
        note        = $trimmedNote
        decidedOn   = $day
    }
}

$decisionsPath = Get-DecisionsFile $Decisions
$rows = Read-DecisionRows $decisionsPath
$existing = @($rows | Where-Object { [string]$_['kind'] -eq [string]$row['kind'] -and [string]$_['item'] -eq [string]$row['item'] })
if ($existing.Count -eq 0) {
    $rows.Add([hashtable]$row)
    Write-Host "decided $($row['item']) ($($row['kind']); $($row['decidedOn']))"
} else {
    foreach ($field in 'sourceSha256', 'sourceFile', 'pinnedValue') {
        if ($row.Contains($field)) { $existing[0][$field] = $row[$field] } else { $existing[0].Remove($field) }
    }
    $existing[0]['note'] = $trimmedNote
    $existing[0]['decidedOn'] = $day
    Write-Host "re-pinned $($row['item']) ($($row['kind']); $($row['decidedOn']))"
}
Write-DecisionRows $decisionsPath $rows
exit 0
