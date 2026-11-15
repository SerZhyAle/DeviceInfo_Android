#requires -Version 7.0
<#
.SYNOPSIS
    Classifies the current bytes of one locally edited destination.
.DESCRIPTION
    Candidate requires a matching tracked -Notice. Deliberate requires -EvidenceText, an exact excerpt
    from that Kotlin file's KDoc or XML file's comment. The excerpt proves a comment exists; its relevance
    is reviewed by a person. A later edit requires a new classification. Exit 0 on success, 2 on refusal.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Mandatory)][string] $Destination,
    [Parameter(Mandatory)][ValidateSet('deliberate', 'candidate', 'not-applicable')][string] $Classification,
    [Parameter(Mandatory)][string] $Note,
    [string] $Notice,
    [string] $EvidenceText,
    [string] $DestinationRoot,
    [string] $Ledger,
    [string] $Decisions,
    [string] $Notices,
    [string] $Date
)
. (Join-Path $PSScriptRoot '_ledger.ps1')
. (Join-Path $PSScriptRoot '_local-divergence.ps1')
$ErrorActionPreference = 'Stop'
trap { Write-Host "record-local-decision: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }
if ([string]::IsNullOrWhiteSpace($Note)) { throw 'A classification needs a reason.' }
$Classification = $Classification.ToLowerInvariant()
$day = if ($Date) { $Date } else { (Get-Date).ToString('yyyy-MM-dd') }
if ($day -notmatch '^\d{4}-\d{2}-\d{2}$') { throw 'Date must be yyyy-MM-dd.' }
$destination = ConvertTo-RelativeLedgerPath $Destination 'Destination'
$root = Get-DestinationRoot $DestinationRoot
$file = Join-Path $root $destination
if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Destination '$destination' does not exist." }
$rows = Read-LedgerRows (Get-LedgerFile $Ledger)
$matching = @($rows | Where-Object { $_.destination -eq $destination })
if ($matching.Count -eq 0) { throw "No ledger row names '$destination'." }
$hash = Get-FileSha256 $file
if (@($matching | Where-Object { $_.ContainsKey('destinationSha256') -and $_.destinationSha256 -cne $hash }).Count -eq 0) {
    throw 'The destination has no recorded local edit to classify.'
}
$decisionsPath = if ($Decisions) { $Decisions } else { $script:LocalDecisionsFile }
$noticesPath = if ($Notices) { $Notices } else { $script:ReverseNoticesFile }
$existing = Read-LocalDecisions $decisionsPath
$noticeRows = Read-ReverseNotices $noticesPath
if ($Classification -eq 'candidate' -and (-not $Notice -or -not $noticeRows.ContainsKey($Notice) -or $destination -notin $noticeRows[$Notice].destinations)) {
    throw 'A candidate needs a tracked notice naming this destination.'
}
if ($Classification -eq 'deliberate' -and ([string]::IsNullOrWhiteSpace($EvidenceText) -or -not (Test-LocalEvidence $file $EvidenceText))) {
    throw 'A deliberate difference needs an exact excerpt from the adjacent KDoc or XML comment.'
}
$record = [ordered]@{ destination = $destination; destinationSha256 = $hash; classification = $Classification; note = $Note.Trim(); classifiedOn = $day }
if ($Classification -eq 'candidate') { $record.notice = $Notice }
if ($Classification -eq 'deliberate') { $record.evidenceText = $EvidenceText }
$existing["$destination`n$hash"] = $record
$lines = @($existing.Values | Sort-Object { $_.destination }, { $_.destinationSha256 } | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 5 })
$parent = Split-Path -Parent $decisionsPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
$staging = "$decisionsPath.writetmp"
[System.IO.File]::WriteAllText($staging, (($lines -join "`n") + "`n"), [System.Text.UTF8Encoding]::new($false))
Move-Item -LiteralPath $staging -Destination $decisionsPath -Force
Write-Host "Classified $destination as $Classification (hash $($hash.Substring(0, 12)))."
exit 0
