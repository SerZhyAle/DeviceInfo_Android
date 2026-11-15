# Local destination baselines and classifications. Dot-source after _ledger.ps1.

$script:LocalDecisionsFile = Join-Path $script:RepoRoot 'docs\local-divergence-decisions.jsonl'
$script:ReverseNoticesFile = Join-Path $script:RepoRoot 'docs\reverse-port-notices.jsonl'

function Read-LocalJsonLines {
    param([Parameter(Mandatory)][string] $Path)
    $records = [System.Collections.Generic.List[hashtable]]::new()
    if (-not (Test-Path -LiteralPath $Path)) { return , $records }
    $lineNumber = 0
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        $lineNumber++
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $record = $line | ConvertFrom-Json -AsHashtable -ErrorAction Stop }
        catch { throw "$Path line ${lineNumber}: invalid JSON." }
        if ($record -isnot [System.Collections.IDictionary]) { throw "$Path line ${lineNumber}: expected an object." }
        $records.Add($record)
    }
    return , $records
}

function Assert-LocalFields {
    param($Record, [string[]] $Fields, [string] $Description)
    foreach ($field in $Fields) {
        if (-not $Record.ContainsKey($field) -or [string]::IsNullOrWhiteSpace([string]$Record[$field])) {
            throw "$Description has no '$field'."
        }
    }
}

function Read-ReverseNotices {
    param([string] $Path = $script:ReverseNoticesFile)
    $notices = Read-LocalJsonLines $Path
    $ids = @{}
    foreach ($notice in $notices) {
        Assert-LocalFields $notice @('id', 'state', 'title', 'summary', 'identifiedOn', 'destinations') "Notice in $Path"
        if ($notice.id -cnotmatch '^RP-\d{4}$' -or $ids.ContainsKey($notice.id)) { throw "Invalid or duplicate notice id '$($notice.id)'." }
        if ($notice.state -cnotin @('open', 'handed-over', 'accepted', 'declined')) { throw "Notice $($notice.id) has an invalid state." }
        if ($notice.identifiedOn -notmatch '^\d{4}-\d{2}-\d{2}$') { throw "Notice $($notice.id) has an invalid date." }
        if ($notice.destinations -is [string] -or @($notice.destinations).Count -eq 0) { throw "Notice $($notice.id) needs destination paths." }
        foreach ($destination in $notice.destinations) { [void](ConvertTo-RelativeLedgerPath $destination 'Notice destination') }
        if ($notice.state -ne 'open' -and (-not $notice.ContainsKey('sourceTicket') -or $notice.sourceTicket -cnotmatch '^fms-a:S\d{4,}$')) {
            throw "Notice $($notice.id) needs an fms-a ticket once handed over."
        }
        if ($notice.state -eq 'declined') { Assert-LocalFields $notice @('reason') "Declined notice $($notice.id)" }
        $ids[$notice.id] = $notice
    }
    return , $ids
}

function Read-LocalDecisions {
    param([string] $Path = $script:LocalDecisionsFile)
    $decisions = Read-LocalJsonLines $Path
    $byVersion = @{}
    foreach ($decision in $decisions) {
        Assert-LocalFields $decision @('destination', 'destinationSha256', 'classification', 'note', 'classifiedOn') "Classification in $Path"
        $destination = ConvertTo-RelativeLedgerPath $decision.destination 'Classification destination'
        if ($decision.destinationSha256 -cnotmatch '^[0-9a-f]{64}$') { throw "Invalid destination hash in $Path." }
        if ($decision.classification -cnotin @('deliberate', 'candidate', 'not-applicable')) { throw "Invalid classification in $Path." }
        if ($decision.classifiedOn -notmatch '^\d{4}-\d{2}-\d{2}$') { throw "Invalid classification date in $Path." }
        if ($decision.classification -eq 'candidate') { Assert-LocalFields $decision @('notice') "Candidate in $Path" }
        if ($decision.classification -eq 'deliberate') { Assert-LocalFields $decision @('evidenceText') "Deliberate difference in $Path" }
        $key = "$destination`n$($decision.destinationSha256)"
        if ($byVersion.ContainsKey($key)) { throw "Duplicate classification for $destination and its hash." }
        $byVersion[$key] = $decision
    }
    return , $byVersion
}

function Test-LocalEvidence {
    param([string] $File, [string] $EvidenceText)
    $content = [System.IO.File]::ReadAllText($File)
    $pattern = if ($File -match '\.kt$') { '(?s)/\*\*.*?\*/' }
               elseif ($File -match '\.xml$') { '(?s)<!--.*?-->' }
               else { return $false }
    foreach ($comment in [regex]::Matches($content, $pattern)) {
        if ($comment.Value.Contains($EvidenceText, [System.StringComparison]::Ordinal)) { return $true }
    }
    return $false
}

function Get-LocalStates {
    param($Rows, [string] $DestinationRoot, $Decisions, $Notices)
    $states = foreach ($row in $Rows) {
        $destination = ConvertTo-RelativeLedgerPath $row.destination 'Destination'
        $file = Join-Path $DestinationRoot $destination
        $state = 'unchanged'
        $classification = $null
        $noticeId = $null
        $reason = $null
        $hash = $null
        $missingDate = $row.ContainsKey('destinationSha256') -and -not $row.ContainsKey('destinationHashedOn')
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { $state = 'NO DEST' }
        elseif (-not $row.ContainsKey('destinationSha256')) { $state = 'NO BASELINE' }
        else {
            $hash = Get-FileSha256 $file
            if ($hash -cne $row.destinationSha256) {
                $state = 'LOCAL EDIT'
                $key = "$destination`n$hash"
                if ($Decisions.ContainsKey($key)) {
                    $decision = $Decisions[$key]
                    $classification = $decision.classification
                    $reason = $decision.note
                    if ($classification -eq 'candidate') {
                        $noticeId = $decision.notice
                        if (-not $Notices.ContainsKey($noticeId) -or $destination -notin $Notices[$noticeId].destinations) {
                            $classification = $null; $reason = 'notice missing or does not name this destination'
                        }
                    } elseif ($classification -eq 'deliberate' -and -not (Test-LocalEvidence $file $decision.evidenceText)) {
                        $classification = $null; $reason = 'adjacent KDoc or XML comment does not contain the recorded evidence'
                    }
                }
            }
        }
        [pscustomobject]@{ State = $state; Source = $row.source; Destination = $destination; CurrentSha256 = $hash;
            Classification = $classification; Notice = $noticeId; Reason = $reason; MissingDate = $missingDate }
    }
    return , @($states)
}

function Initialize-DestinationHashes {
    param($Rows, [string] $DestinationRoot, [string] $Date)
    # Validate every missing row first: a missing file cannot leave a partially written backfill.
    $pending = @($Rows | Where-Object { -not $_.ContainsKey('destinationSha256') })
    foreach ($row in $pending) {
        $destination = ConvertTo-RelativeLedgerPath $row.destination 'Destination'
        if (-not (Test-Path -LiteralPath (Join-Path $DestinationRoot $destination) -PathType Leaf)) { throw "Destination '$destination' does not exist." }
    }
    foreach ($row in $pending) {
        $row['destinationSha256'] = Get-FileSha256 (Join-Path $DestinationRoot $row.destination)
        $row['destinationHashedOn'] = $Date
    }
    return $pending.Count
}
