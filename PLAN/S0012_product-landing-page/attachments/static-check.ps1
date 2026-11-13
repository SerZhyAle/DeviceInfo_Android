$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = 'P:\ANDROID\deviceinfo_mob'
$site = Join-Path $root 'site'
$base = 'https://serzhyale.github.io/DeviceInfo_Android/'
$pages = @(
    @{ Rel = 'index.html';    Url = $base;          Lang = 'en' },
    @{ Rel = 'ru\index.html'; Url = $base + 'ru/';  Lang = 'ru' },
    @{ Rel = 'uk\index.html'; Url = $base + 'uk/';  Lang = 'uk' }
)
$fail = 0
function Ok([string]$m)  { Write-Host "PASS $m" }
function Bad([string]$m) { Write-Host "FAIL $m"; $script:fail++ }
function Check([bool]$c, [string]$m) { if ($c) { Ok $m } else { Bad $m } }

$altSets = @()
foreach ($p in $pages) {
    $path = Join-Path $site $p.Rel
    $html = [IO.File]::ReadAllText($path)
    $n = $p.Rel

    # 1 h1
    Check (([regex]::Matches($html, '<h1[ >]')).Count -eq 1) "$n one h1"
    # canonical
    $canons = [regex]::Matches($html, '<link rel="canonical" href="([^"]+)"')
    Check ($canons.Count -eq 1 -and $canons[0].Groups[1].Value -eq $p.Url) "$n canonical = $($p.Url)"
    # hreflang
    $alts = ([regex]::Matches($html, '<link rel="alternate" hreflang="([^"]+)" href="([^"]+)"') | ForEach-Object { $_.Groups[1].Value + '=' + $_.Groups[2].Value }) -join '|'
    $altSets += $alts
    Check ($alts -eq "en=${base}|ru=${base}ru/|uk=${base}uk/|x-default=${base}") "$n hreflang alternates (4, absolute, reciprocal)"
    # html lang
    Check ($html -match "<html lang=`"$($p.Lang)`"") "$n html lang=$($p.Lang)"
    # JSON-LD
    $ldm = [regex]::Matches($html, '(?s)<script type="application/ld\+json">(.*?)</script>')
    Check ($ldm.Count -eq 1) "$n one JSON-LD block"
    $ld = $ldm[0].Groups[1].Value | ConvertFrom-Json
    Check ($ld.'@type' -eq 'SoftwareApplication' -and $ld.offers.price -eq '0' -and $ld.installUrl -like 'https://play.google.com/store/apps/details?id=com.sza.deviceinfo' -and $ld.url -eq $p.Url -and -not $ld.softwareVersion -and -not $ld.aggregateRating) "$n JSON-LD SoftwareApplication, price 0, Play installUrl, no version, no rating"
    # OG / twitter
    foreach ($t in 'og:title', 'og:description', 'og:url', 'og:image', 'og:locale') { Check ($html -match "property=`"$t`"") "$n $t" }
    Check ($html -match 'name="twitter:card" content="summary_large_image"') "$n twitter:card summary_large_image"
    Check ($html -match "property=`"og:url`" content=`"$([regex]::Escape($p.Url))`"") "$n og:url = canonical"
    # title/description
    $title = [regex]::Match($html, '<title>(.*?)</title>').Groups[1].Value
    $desc = [regex]::Match($html, '<meta name="description" content="([^"]*)"').Groups[1].Value
    Check ($title.Length -ge 1 -and $title.Length -le 60) "$n title length $($title.Length)"
    Check ($desc.Length -ge 50 -and $desc.Length -le 155) "$n description length $($desc.Length)"

    # visible text
    $vis = [regex]::Replace($html, '(?s)<script.*?</script>|<style.*?</style>|<!--.*?-->|<noscript>.*?</noscript>', '')
    $vis = [regex]::Replace($vis, '<[^>]+>', ' ')
    $vis = [System.Net.WebUtility]::HtmlDecode($vis)
    $cyr = ([regex]::Matches($vis, '[\u0400-\u04FF]')).Count
    $lat = ([regex]::Matches($vis, '[A-Za-z]')).Count
    $share = [math]::Round(100 * $cyr / [math]::Max(1, $cyr + $lat), 1)
    if ($p.Lang -eq 'en') { Check ($share -le 20) "$n Cyrillic share $share% (limit 20 for en)" } else { Check ($share -ge 50) "$n Cyrillic share $share% (minimum 50 for $($p.Lang))" }
    # House style and hygiene over the whole file
    Check (-not $html.Contains('...')) "$n no three dots"
    Check (-not ($html.Contains([string][char]0x2013) -or $html.Contains([string][char]0x2014))) "$n no long dash"
    Check (-not ([regex]::IsMatch($html, '[\uD83C-\uD83E][\uDC00-\uDFFF]|[\u2600-\u27BF]'))) "$n no emoji"
    $hedge = [regex]::Matches($vis + ' ' + $title + ' ' + $desc, '(?i)coming soon|not yet|in development|\bbeta\b|experimental|planned|upcoming|(?<!\p{L})скоро(?!\p{L})|планируется|ещё не|(?<!\p{L})бета(?!\p{L})|экспериментальн|незабаром|плануєтьс|ще не')
    Check ($hedge.Count -eq 0) "$n no readiness hedge or forward look ($($hedge.Count))"
    Check ($html -notmatch 'target="_blank"') "$n no target=_blank"
    Check ($html -notmatch '(?i)(src|href)="https?://(?!(serzhyale\.github\.io|sza\.od\.ua|github\.com|play\.google\.com)/)[^"]*"[^>]*(rel="stylesheet"|<script)') "$n no third-party script or stylesheet"
    Check (-not [regex]::IsMatch($html, '<script[^>]+src=')) "$n no external script"
    Check (-not [regex]::IsMatch($html, '<iframe')) "$n no iframe"
    Check (-not [regex]::IsMatch($html, '\{\{')) "$n no unrendered token"

    # tag balance
    $void = 'meta','link','img','br','hr','input','source','wbr'
    $stack = New-Object System.Collections.Generic.Stack[string]
    $body = [regex]::Replace($html, '(?s)<script.*?</script>|<!--.*?-->', '')
    $balanced = $true; $first = ''
    foreach ($m in [regex]::Matches($body, '<(/?)([a-zA-Z][a-zA-Z0-9]*)[^>]*?(/?)>')) {
        $tag = $m.Groups[2].Value.ToLower()
        if ($void -contains $tag -or $tag -eq '!doctype') { continue }
        if ($m.Groups[1].Value -eq '/') {
            if ($stack.Count -eq 0 -or $stack.Peek() -ne $tag) { if ($balanced) { $first = "unexpected </$tag>" }; $balanced = $false; continue }
            [void]$stack.Pop()
        } else { $stack.Push($tag) }
    }
    Check ($balanced -and $stack.Count -eq 0) "$n tags balanced $first"

    # links
    $dir = Split-Path $path
    $bad = @()
    foreach ($m in [regex]::Matches($html, '(?:href|src)="([^"]*)"')) {
        $u = $m.Groups[1].Value
        if ($u -match '^(https?:|mailto:|#|data:)') { continue }
        $local = ($u -split '[#?]')[0]
        if ($local -eq '') { continue }
        $target = [IO.Path]::GetFullPath((Join-Path $dir ($local -replace '/', '\')))
        if (Test-Path -LiteralPath $target -PathType Container) { $target = Join-Path $target 'index.html' }
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { $bad += $u }
    }
    Check ($bad.Count -eq 0) "$n relative links resolve ($($bad -join ', '))"
    # images
    foreach ($m in [regex]::Matches($html, '<img [^>]*>')) { Check ($m.Value -match 'width="\d+"' -and $m.Value -match 'height="\d+"') "$n img has width and height" }
}
Check (($altSets | Select-Object -Unique).Count -eq 1) 'hreflang alternates identical on the three pages'

# Social image
$sp = Join-Path $site 'assets\social-card-1200x630.png'
$img = [System.Drawing.Image]::FromFile($sp)
Check ($img.Width -eq 1200 -and $img.Height -eq 630) "social card is $($img.Width) x $($img.Height)"
$img.Dispose()
$icon = Get-Item (Join-Path $site 'assets\icon-512.png')
Check ($icon.Length -lt 102400) "icon file $([math]::Round($icon.Length/1KB,1)) KB (< 100 KB)"

# CSS
$css = [regex]::Replace([IO.File]::ReadAllText((Join-Path $site 'assets\landing.css')), '(?s)/\*.*?\*/', '')
Check ($css -notmatch '(?i)max-width|margin:\s*0\s+auto|min\(\d+px') 'landing.css has no max-width, centred margin or min(px)'
Check (-not $css.Contains('...')) 'landing.css no three dots'
Check (-not ($css.Contains([string][char]0x2013) -or $css.Contains([string][char]0x2014))) 'landing.css no long dash'

# Kit byte identity
$prov = [IO.File]::ReadAllText((Join-Path $site 'assets\PROVENANCE.txt'))
$want = [regex]::Match($prov, 'sza-kit\.css sha256 ([0-9a-f]{64})').Groups[1].Value
$have = (Get-FileHash (Join-Path $site 'assets\sza-kit.css') -Algorithm SHA256).Hash.ToLower()
Check ($want -eq $have) "kit sha256 $have equals PROVENANCE"

# Sitemap
$sm = [xml][IO.File]::ReadAllText((Join-Path $site 'sitemap.xml'))
$ns = New-Object Xml.XmlNamespaceManager($sm.NameTable); $ns.AddNamespace('s', 'http://www.sitemaps.org/schemas/sitemap/0.9'); $ns.AddNamespace('x', 'http://www.w3.org/1999/xhtml')
$locs = @($sm.SelectNodes('//s:url/s:loc', $ns) | ForEach-Object { $_.InnerText })
foreach ($p in $pages) { Check ($locs -contains $p.Url) "sitemap lists $($p.Url)" }
foreach ($u in $sm.SelectNodes('//s:url', $ns)) {
    $loc = $u.SelectSingleNode('s:loc', $ns).InnerText
    $rel = $loc.Substring($base.Length)
    if ($rel -eq '') { $rel = 'index.html' } elseif ($rel.EndsWith('/')) { $rel += 'index.html' }
    Check (Test-Path -LiteralPath (Join-Path $site ($rel -replace '/', '\'))) "sitemap row $loc maps to a file"
}
$stamp = Get-Content (Join-Path $root '.sza-canon.json') -Raw | ConvertFrom-Json
foreach ($p in $pages) { Check ($stamp.site.pages -contains ($p.Rel -replace '\\', '/')) "stamp site.pages names $($p.Rel -replace '\\','/')" }
foreach ($pg in $stamp.site.pages) { Check (Test-Path -LiteralPath (Join-Path $site ($pg -replace '/', '\'))) "stamp page $pg exists" }

Write-Host ("failures: {0}" -f $fail)
exit $(if ($fail) { 1 } else { 0 })
