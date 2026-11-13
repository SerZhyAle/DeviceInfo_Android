<#
.SYNOPSIS
    Renders the three locale pages of the DeviceInfo landing (S0012) from one template and three dictionaries.

.DESCRIPTION
    tools/site/landing/template.html     the one page structure
    tools/site/landing/en.json           English dictionary (the source text)
    tools/site/landing/ru.json           Russian dictionary
    tools/site/landing/uk.json           Ukrainian dictionary

    site/index.html                      English page, also x-default       (https://serzhyale.github.io/DeviceInfo_Android/)
    site/ru/index.html                   Russian page                       (.../ru/)
    site/uk/index.html                   Ukrainian page                     (.../uk/)

    PAGE-STYLE 3.9: English at the site root, every other locale in its own directory, ISO code `uk` in the address,
    each page self-canonical with the same reciprocal hreflang alternates plus x-default. The three pages are render
    targets and are never edited by hand: change the template or a dictionary and render again.

    Before it renders, the script refuses a dictionary set that cannot give three equivalent pages: different keys,
    a different count of list items, a title over 60 characters or a description outside 50..155, the character
    sequence of three dots, a typographic long dash, a key the template never uses, or a page whose tag sequence
    differs from the English one. SITE-FAMILY-MAP rows are held in this script (nine entries; the product itself has
    no row yet), their Type cell is the dictionary's `types` list, in the order of the map.

    Template tokens: {{key}} a dictionary string; {{cards:key}}, {{li:key}}, {{pills:key}}, {{faq:key}} a dictionary
    list rendered as cards, list items, pills or question blocks; {{@name}} a value the script computes per locale.

.PARAMETER Check
    Render in memory and compare with the committed pages. Writes nothing.

.PARAMETER Root
    Repository root. Defaults to two levels above this script.

.NOTES
    Exit codes: 0 pages written, or (with -Check) current; 1 a page is out of date, or the dictionaries are refused.
#>
[CmdletBinding()]
param(
    [switch]$Check,
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'
$dictDir = Join-Path $PSScriptRoot 'landing'
$site = 'https://serzhyale.github.io/DeviceInfo_Android/'
$playUrl = 'https://play.google.com/store/apps/details?id=com.sza.deviceinfo'
$socialImage = $site + 'assets/social-card-1200x630.png'

# SITE-FAMILY-MAP section 2, in the order of the map. The product itself has no row, so every row is a sibling.
$family = @(
    @{ Name = 'Fast Media Sorter & Organizer'; Url = 'https://serzhyale.github.io/FastMediaSorter_mob_v2/' },
    @{ Name = 'Fast Media Sorter & Sharing for Windows'; Url = 'https://serzhyale.github.io/FastMediaSorter_Lite/' },
    @{ Name = 'CyrFlip'; Url = 'https://serzhyale.github.io/CyrFlip/' },
    @{ Name = 'doc-html-translate'; Url = 'https://serzhyale.github.io/doc-html-translate/' },
    @{ Name = 'FileDO'; Url = 'https://serzhyale.github.io/FileDO/' },
    @{ Name = 'STREAMS Player'; Url = 'https://serzhyale.github.io/StreamsPlayer/' },
    @{ Name = 'OneClickRunner'; Url = 'https://serzhyale.github.io/OneClickRunner/' },
    @{ Name = 'Universal Agent Kit'; Url = 'https://serzhyale.github.io/universal-agent-kit/' },
    @{ Name = 'SZA (hub)'; Url = 'https://sza.od.ua' }
)

# The root forwards only on an explicit choice (a valid locale query or a stored sza-lang other than en), never on
# navigator.language (PAGE-STYLE 3.9 item 3). The locale pages do not forward.
$forwardScript = @'
  var q=(location.search.match(/[?&]lang=(ru|en|uk|ua)\b/i)||location.search.match(/[?&]l=(ru|en|uk|ua)\b/i)||[])[1];
  var l=q?q.toLowerCase():localStorage.getItem('sza-lang');
  if(l==='uk')l='ua';
  if(l==='ru')location.replace('ru/');else if(l==='ua')location.replace('uk/');

'@

$locales = @(
    @{ Code = 'en'; Out = 'site\index.html';    Canon = $site;          Base = '';   RootHref = './';  Og = 'en_US'; Privacy = 'privacy.html';
       Urls = "{ru:'ru/',en:'./',ua:'uk/'}";      Forward = $true;  Pressed = @('false', 'true', 'false') },
    @{ Code = 'ru'; Out = 'site\ru\index.html'; Canon = $site + 'ru/';  Base = '../'; RootHref = '../'; Og = 'ru_RU'; Privacy = '../privacy-ru.html';
       Urls = "{ru:'./',en:'../',ua:'../uk/'}";   Forward = $false; Pressed = @('true', 'false', 'false') },
    @{ Code = 'uk'; Out = 'site\uk\index.html'; Canon = $site + 'uk/';  Base = '../'; RootHref = '../'; Og = 'uk_UA'; Privacy = '../privacy-uk.html';
       Urls = "{ru:'../ru/',en:'../',ua:'./'}";   Forward = $false; Pressed = @('false', 'false', 'true') }
)

function Read-Dictionary([string]$code) {
    $path = Join-Path $dictDir "$code.json"
    Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Fail([string]$message) {
    Write-Error $message -ErrorAction Continue
    exit 1
}

function Enc([string]$text) { [System.Net.WebUtility]::HtmlEncode($text) }

# ---- Dictionary validation ----
$dicts = @{}
foreach ($loc in $locales) { $dicts[$loc.Code] = Read-Dictionary $loc.Code }
$enKeys = @($dicts['en'].PSObject.Properties.Name | Sort-Object)
foreach ($loc in $locales) {
    $d = $dicts[$loc.Code]
    $keys = @($d.PSObject.Properties.Name | Sort-Object)
    $diff = Compare-Object $enKeys $keys
    if ($diff) { Fail ("{0}.json: keys differ from en.json: {1}" -f $loc.Code, (($diff | ForEach-Object { "$($_.SideIndicator) $($_.InputObject)" }) -join ', ')) }
    foreach ($k in $enKeys) {
        $ev = $dicts['en'].$k
        $lv = $d.$k
        if (($ev -is [string]) -ne ($lv -is [string])) { Fail "$($loc.Code).json: '$k' is a string in one dictionary and a list in the other." }
        if ($ev -isnot [string] -and @($ev).Count -ne @($lv).Count) { Fail "$($loc.Code).json: '$k' has $(@($lv).Count) items, en.json has $(@($ev).Count)." }
        $flat = @($lv | ForEach-Object { $_ }) -join "`n"
        if ($flat.Contains('...')) { Fail "$($loc.Code).json: '$k' holds three dots; house style writes two." }
        if ($flat.Contains([string][char]0x2013) -or $flat.Contains([string][char]0x2014)) { Fail "$($loc.Code).json: '$k' holds a long dash; house style writes a plain hyphen." }
    }
    $title = [System.Net.WebUtility]::HtmlDecode($d.title)
    $desc = [System.Net.WebUtility]::HtmlDecode($d.description)
    if ($title.Length -gt 60) { Fail "$($loc.Code).json: title is $($title.Length) characters, the limit is 60." }
    if ($desc.Length -lt 50 -or $desc.Length -gt 155) { Fail "$($loc.Code).json: description is $($desc.Length) characters, the range is 50..155." }
    if (@($d.types).Count -ne $family.Count) { Fail "$($loc.Code).json: 'types' has $(@($d.types).Count) items, the family map has $($family.Count)." }
}

# ---- Rendering ----
$template = (Get-Content -LiteralPath (Join-Path $dictDir 'template.html') -Raw -Encoding UTF8) -replace "`r`n", "`n"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$tokenPattern = '\{\{(?:(cards|li|pills|faq):)?(@?\w+)\}\}'

function Render-Page($loc) {
    $d = $dicts[$loc.Code]
    $used = New-Object System.Collections.Generic.HashSet[string]

    $alternates = @(
        ('  <link rel="alternate" hreflang="en" href="' + $site + '">'),
        ('  <link rel="alternate" hreflang="ru" href="' + $site + 'ru/">'),
        ('  <link rel="alternate" hreflang="uk" href="' + $site + 'uk/">'),
        ('  <link rel="alternate" hreflang="x-default" href="' + $site + '">')
    ) -join "`n"

    $ld = [ordered]@{
        '@context'            = 'https://schema.org'
        '@type'               = 'SoftwareApplication'
        name                  = 'DeviceInfo'
        description           = [System.Net.WebUtility]::HtmlDecode($d.description)
        url                   = $loc.Canon
        inLanguage            = $loc.Code
        applicationCategory   = 'UtilitiesApplication'
        operatingSystem       = 'Android, Wear OS'
        image                 = $site + 'assets/icon-512.png'
        installUrl            = $playUrl
        offers                = [ordered]@{ '@type' = 'Offer'; price = '0'; priceCurrency = 'USD' }
        author                = [ordered]@{ '@type' = 'Person'; name = 'Serhii Zhyhunenko'; url = 'https://sza.od.ua' }
        license               = 'https://github.com/SerZhyAle/DeviceInfo_Android/blob/main/LICENSE'
    }
    $themeLabels = [ordered]@{
        light = [System.Net.WebUtility]::HtmlDecode($d.themeToDark)
        dark  = [System.Net.WebUtility]::HtmlDecode($d.themeToLight)
    }
    $tools = for ($i = 0; $i -lt $family.Count; $i++) {
        '    <a href="{0}"><b>{1}</b><span>{2}</span></a>' -f $family[$i].Url, (Enc $family[$i].Name), $d.types[$i]
    }

    # Two dictionary keys reach the page through built-ins (the theme labels of the script, the family grid types).
    foreach ($k in 'themeToDark', 'types') { [void]$used.Add($k) }

    $builtin = @{
        lang         = $loc.Code
        canonical    = $loc.Canon
        alternates   = $alternates
        socialImage  = $socialImage
        ogLocale     = $loc.Og
        jsonld       = ($ld | ConvertTo-Json -Compress -Depth 6)
        forward      = $(if ($loc.Forward) { $forwardScript } else { '' })
        base         = $loc.Base
        rootHref     = $loc.RootHref
        pressedRu    = $loc.Pressed[0]
        pressedEn    = $loc.Pressed[1]
        pressedUa    = $loc.Pressed[2]
        urls         = $loc.Urls
        themeLabels  = ($themeLabels | ConvertTo-Json -Compress)
        tools        = ($tools -join "`n")
        privacy      = $loc.Privacy
    }

    $evaluator = [System.Text.RegularExpressions.MatchEvaluator] {
        param($m)
        $kind = $m.Groups[1].Value
        $name = $m.Groups[2].Value
        if ($name.StartsWith('@')) {
            $b = $name.Substring(1)
            if (-not $builtin.ContainsKey($b)) { Fail "template: unknown built-in token {{@$b}}." }
            return [string]$builtin[$b]
        }
        $prop = $d.PSObject.Properties[$name]
        if ($null -eq $prop) { Fail "template: no dictionary key '$name' in $($loc.Code).json." }
        [void]$used.Add($name)
        $v = $prop.Value
        switch ($kind) {
            ''      { return [string]$v }
            'cards' { return (@($v | ForEach-Object { '      <article class="card"><h3>{0}</h3><p>{1}</p></article>' -f $_[0], $_[1] }) -join "`n") }
            'li'    { return (@($v | ForEach-Object { '        <li>{0}</li>' -f $_ }) -join "`n") }
            'pills' { return (@($v | ForEach-Object { '          <li class="pill">{0}</li>' -f $_ }) -join "`n") }
            'faq'   { return (@($v | ForEach-Object { '      <div class="qa"><h3>{0}</h3><p>{1}</p></div>' -f $_[0], $_[1] }) -join "`n") }
        }
    }
    $html = [regex]::Replace($template, $tokenPattern, $evaluator)
    # Dictionary values may themselves name a built-in (the privacy link); one more pass resolves them.
    $html = [regex]::Replace($html, $tokenPattern, $evaluator)
    if ($html -match '\{\{') { Fail "$($loc.Code): an unresolved {{token}} remains in the rendered page." }

    $unused = @($enKeys | Where-Object { -not $used.Contains($_) })
    if ($unused) { Fail "$($loc.Code).json: keys the template never uses: $($unused -join ', ')." }
    $html
}

$rendered = @{}
foreach ($loc in $locales) { $rendered[$loc.Code] = Render-Page $loc }

# The three pages must have the same tag sequence (scripts and comments removed): one structure, three languages.
function Get-Skeleton([string]$html) {
    $body = [regex]::Replace($html, '(?s)<script.*?</script>|<!--.*?-->', '')
    ([regex]::Matches($body, '<(/?[a-zA-Z][a-zA-Z0-9]*)') | ForEach-Object { $_.Groups[1].Value }) -join ' '
}
$enSkeleton = Get-Skeleton $rendered['en']
foreach ($loc in $locales) {
    if ((Get-Skeleton $rendered[$loc.Code]) -ne $enSkeleton) { Fail "$($loc.Code): the tag sequence of the rendered page differs from the English page." }
}

$stale = @()
foreach ($loc in $locales) {
    $path = Join-Path $Root $loc.Out
    $bytes = $utf8.GetBytes($rendered[$loc.Code])
    if ($Check) {
        if (-not (Test-Path -LiteralPath $path)) { $stale += "$($loc.Out) (missing)"; continue }
        $current = [System.IO.File]::ReadAllBytes($path)
        if (-not [System.Linq.Enumerable]::SequenceEqual([byte[]]$current, [byte[]]$bytes)) { $stale += $loc.Out }
    }
    else {
        New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
        [System.IO.File]::WriteAllBytes($path, $bytes)
        Write-Host ("{0}: {1} bytes" -f $loc.Out.Replace('\', '/'), $bytes.Length)
    }
}
if ($Check) {
    if ($stale.Count) { Fail ("landing pages out of date, run tools/site/render-landing.ps1: " + ($stale -join ', ')) }
    Write-Host 'landing pages are current: 3 of 3'
}
exit 0
