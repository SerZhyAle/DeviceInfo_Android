#requires -Version 7.0
<#
Shared helpers of the help tooling (S0024): the generator `render-help.ps1` and the gate `check-help-map.ps1` both
dot-source this file, so they read the one help map, the same page sources and the same string resources.
Not run on its own.
#>
Set-StrictMode -Version Latest

# The capture records, the input hash and the marker arithmetic (S0032); their functions call back into this file.
. (Join-Path $PSScriptRoot '_capture.ps1')

$script:HelpLocales = @('en', 'ru', 'uk')
$script:LocaleDirName = @{ en = 'values'; ru = 'values-ru'; uk = 'values-uk' }
# Where the generated pages land: the app's assets and the site. Both receive the same bytes (CONTEXT-HELP rule 12).
$script:HelpOutputRoots = @('phone/src/main/assets/help', 'site/help')
$script:HelpMapRelative = 'phone/src/main/assets/help/help-map.json'
$script:StringCache = @{}

function Read-HelpJson {
    param([Parameter(Mandatory)][string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) { throw "Missing file: $Path" }
    Get-Content -LiteralPath $Path -Raw -Encoding utf8 | ConvertFrom-Json -AsHashtable
}

function Convert-AndroidText {
    param([string] $Text)
    $trimmed = $Text.Trim()
    if (-not $trimmed.Contains('\')) { return $trimmed }   # the evaluator below is slow in PowerShell; most strings need none
    [regex]::Replace($trimmed, '\\(.)', {
            param($m)
            if ($m.Groups[1].Value -eq 'n') { ' ' } else { $m.Groups[1].Value }
        })
}

# The strings of one module and locale: every <string> of every xml file of that values directory.
function Get-ModuleStrings {
    param([string] $Root, [string] $Module, [string] $Locale)
    $cacheKey = "$Root|$Module|$Locale"
    if ($script:StringCache.ContainsKey($cacheKey)) { return $script:StringCache[$cacheKey] }
    $strings = @{}
    $nonTranslatable = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $dir = Join-Path $Root "$Module/src/main/res/$($script:LocaleDirName[$Locale])"
    if (Test-Path -LiteralPath $dir) {
        foreach ($file in (Get-ChildItem -LiteralPath $dir -Filter '*.xml' -File)) {
            $doc = [System.Xml.XmlDocument]::new()
            $doc.Load($file.FullName)
            foreach ($node in $doc.SelectNodes('/resources/string')) {
                $name = $node.GetAttribute('name')
                $strings[$name] = Convert-AndroidText $node.InnerText
                if ($node.GetAttribute('translatable') -eq 'false') { [void]$nonTranslatable.Add($name) }
            }
        }
    }
    $entry = @{ Strings = $strings; NonTranslatable = $nonTranslatable }
    $script:StringCache[$cacheKey] = $entry
    $entry
}

# One UI string for a locale. A key the base locale marks translatable="false" (app_name) is read from the base.
function Resolve-StringRef {
    param([string] $Root, [string] $Module, [string] $Locale, [string] $Key)
    $local = Get-ModuleStrings -Root $Root -Module $Module -Locale $Locale
    if ($local.Strings.ContainsKey($Key)) { return $local.Strings[$Key] }
    if ($Locale -ne 'en') {
        $base = Get-ModuleStrings -Root $Root -Module $Module -Locale 'en'
        if ($base.NonTranslatable.Contains($Key)) { return $base.Strings[$Key] }
    }
    throw "String '$Key' is missing from the $Module resources of locale '$Locale'"
}

function Get-HelpMap {
    param([string] $Root)
    Read-HelpJson (Join-Path $Root $script:HelpMapRelative)
}

# The pages the map declares, in map order: help id -> parsed source.
function Get-HelpPageSources {
    param([string] $Root, [hashtable] $Map)
    $dir = Join-Path $Root 'tools/help/source'
    $pages = [ordered]@{}
    foreach ($row in $Map.surfaces) {
        if ($row.form -notin 'page', 'both', 'layer') { continue }
        $help = [string]$row.help
        if ($pages.Contains($help)) { continue }
        $pages[$help] = Read-HelpJson (Join-Path $dir "$help.json")
    }
    $pages
}

function Get-SiteBase {
    param([hashtable] $Map)
    $root = [string]$Map.siteRoot
    if (-not $root.EndsWith('help/')) { throw "siteRoot must end with 'help/': $root" }
    $root.Substring(0, $root.Length - 'help/'.Length)
}

function Test-ForbiddenText {
    param([string] $Where, [string] $Text, [System.Collections.Generic.List[string]] $Problems)
    if ($Text.Contains('...')) { $Problems.Add("$Where holds the character sequence of three dots (house style: two)") }
    if ($Text.Contains([string][char]0x2014) -or $Text.Contains([string][char]0x2013)) {
        $Problems.Add("$Where holds a typographic long dash (house style: a plain hyphen)")
    }
}

# Refusals of the sources (everything that would make the pages unequal or the contract's anatomy incomplete).
function Test-HelpSources {
    param([string] $Root, [hashtable] $Map, [System.Collections.IDictionary] $Pages, [hashtable] $Common)
    $problems = [System.Collections.Generic.List[string]]::new()
    $tokenRegex = [regex]'\{([a-z][a-z0-9-]*)\}'
    $sourceDir = Join-Path $Root 'tools/help/source'
    $known = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($key in $Pages.Keys) { [void]$known.Add($key) }
    foreach ($file in (Get-ChildItem -LiteralPath $sourceDir -Filter '*.json' -File)) {
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        if ($stem -ne 'common' -and -not $known.Contains($stem)) {
            $problems.Add("source $($file.Name) belongs to no surface of the help map")
        }
    }
    foreach ($loc in $script:HelpLocales) {
        if (-not $Common.text.ContainsKey($loc)) { $problems.Add("common.json has no text for $loc"); continue }
        foreach ($key in $Common.text['en'].Keys) {
            if (-not $Common.text[$loc].ContainsKey($key)) { $problems.Add("common.json: key '$key' is missing for $loc") }
        }
        foreach ($key in $Common.text[$loc].Keys) {
            if (-not $Common.text['en'].ContainsKey($key)) { $problems.Add("common.json: key '$key' of $loc has no English source") }
            else { Test-ForbiddenText "common.json $loc.$key" ([string]$Common.text[$loc][$key]) $problems }
        }
    }
    foreach ($pageId in $Pages.Keys) {
        $page = $Pages[$pageId]
        $tag = "source $pageId"
        foreach ($field in 'id', 'surface', 'module', 'revised', 'titleRef', 'elements', 'text') {
            if (-not $page.ContainsKey($field)) { $problems.Add("$tag has no '$field'") }
        }
        if ($problems.Count -gt 0 -and -not $page.ContainsKey('elements')) { continue }
        if ($page.id -ne $pageId) { $problems.Add("$tag declares id '$($page.id)'") }
        if ($page.revised -notmatch '^\d{4}-\d{2}-\d{2}$') { $problems.Add("$tag revised '$($page.revised)' is not a date") }
        if ($page.module -notin 'phone', 'wear') { $problems.Add("$tag module '$($page.module)' is not phone or wear") }
        $ids = @($page.elements | ForEach-Object { $_.id })
        if ($ids.Count -eq 0) { $problems.Add("$tag has no elements") }
        if (@($ids | Select-Object -Unique).Count -ne $ids.Count) { $problems.Add("$tag has a duplicate element id") }
        foreach ($id in $ids) { if ($id -notmatch '^[a-z][a-z0-9-]*$') { $problems.Add("$tag element id '$id' is not kebab-case") } }
        foreach ($loc in $script:HelpLocales) {
            if (-not $page.text.ContainsKey($loc)) { $problems.Add("$tag has no text for $loc"); continue }
            $text = $page.text[$loc]
            foreach ($field in 'summary', 'lead', 'order', 'elements', 'related') {
                if (-not $text.ContainsKey($field)) { $problems.Add("$tag/$loc has no '$field'") }
            }
            if (-not ($text.ContainsKey('order') -and $text.ContainsKey('elements'))) { continue }
            $steps = @($text.order)
            if ($steps.Count -lt 1 -or $steps.Count -gt 7) { $problems.Add("$tag/$loc has $($steps.Count) order steps (1 to 7 allowed, CONTEXT-HELP rule 8 item 4)") }
            if ($steps.Count -ne @($page.text['en'].order).Count) { $problems.Add("$tag/$loc has a different number of order steps than en") }
            foreach ($step in $steps) {
                Test-ForbiddenText "$tag/$loc order" ([string]$step) $problems
                foreach ($m in $tokenRegex.Matches([string]$step)) {
                    if ($m.Groups[1].Value -notin $ids) { $problems.Add("$tag/$loc order names unknown element '$($m.Groups[1].Value)'") }
                }
            }
            foreach ($field in 'summary', 'lead') { Test-ForbiddenText "$tag/$loc $field" ([string]$text[$field]) $problems }
            foreach ($key in $text.elements.Keys) {
                if ($key -notin $ids) { $problems.Add("$tag/$loc has text for unknown element '$key'") }
            }
            foreach ($element in $page.elements) {
                $id = $element.id
                if (-not $text.elements.ContainsKey($id)) { $problems.Add("$tag/$loc has no text for element '$id'"); continue }
                $entry = $text.elements[$id]
                foreach ($field in 'one', 'full', 'why', 'next', 'undo') {
                    if (-not $entry.ContainsKey($field) -or [string]::IsNullOrWhiteSpace((@($entry[$field]) -join ''))) {
                        $problems.Add("$tag/$loc element '$id' has no '$field' (CONTEXT-HELP rule 9)")
                    }
                }
                $hasRef = $element.ContainsKey('nameRef') -or $element.ContainsKey('nameRefs')
                if (-not $hasRef -and -not $entry.ContainsKey('name')) { $problems.Add("$tag/$loc element '$id' has neither a UI string reference nor a name") }
                foreach ($field in $entry.Keys) { Test-ForbiddenText "$tag/$loc element '$id' $field" ((@($entry[$field]) -join ' ')) $problems }
                $refs = @()
                if ($element.ContainsKey('nameRef')) { $refs += [string]$element.nameRef }
                if ($element.ContainsKey('nameRefs')) { $refs += @($element.nameRefs) }
                foreach ($key in $refs) {
                    try { [void](Resolve-StringRef -Root $Root -Module $page.module -Locale $loc -Key $key) }
                    catch { $problems.Add("$tag/$loc element '$id': $($_.Exception.Message)") }
                }
                foreach ($m in $tokenRegex.Matches((@($entry.full) -join ' '))) {
                    if ($m.Groups[1].Value -notin $ids) { $problems.Add("$tag/$loc element '$id' names unknown element '$($m.Groups[1].Value)'") }
                }
            }
            try { [void](Resolve-StringRef -Root $Root -Module $page.module -Locale $loc -Key $page.titleRef) }
            catch { $problems.Add("$tag/$loc title: $($_.Exception.Message)") }
            foreach ($rel in $page.related) {
                if ($rel.ContainsKey('page')) {
                    if (-not $Pages.Contains([string]$rel.page)) { $problems.Add("$tag related page '$($rel.page)' is not in the help map") }
                    elseif (-not $text.related.ContainsKey([string]$rel.page)) { $problems.Add("$tag/$loc has no related note for page '$($rel.page)'") }
                }
            }
            foreach ($key in $text.related.Keys) { Test-ForbiddenText "$tag/$loc related $key" ([string]$text.related[$key]) $problems }
        }
    }
    , $problems
}

# ---------------------------------------------------------------------------------------------- HTML

function ConvertTo-HtmlText {
    param([string] $Text)
    $Text.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
}

# Escaped text with **bold** and {element} reference tokens expanded.
function ConvertTo-HelpInline {
    param([string] $Text, [hashtable] $Markers)
    $escaped = ConvertTo-HtmlText $Text
    $escaped = [regex]::Replace($escaped, '\*\*(.+?)\*\*', '<b>$1</b>')
    [regex]::Replace($escaped, '\{([a-z][a-z0-9-]*)\}', {
            param($m)
            $id = $m.Groups[1].Value
            "<a class=`"ref`" href=`"#$id`">$($Markers[$id])</a>"
        })
}

function ConvertTo-ShortcutHtml {
    param([string] $Shortcut)
    (($Shortcut -split '\+') | ForEach-Object { '<kbd>' + (ConvertTo-HtmlText $_.Trim()) + '</kbd>' }) -join ' + '
}

$script:ThemeScript = @'
<script>
(function () {
  try {
    var q = new URLSearchParams(location.search).get('theme');
    var t = (q === 'light' || q === 'dark') ? q : (matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark');
    document.documentElement.setAttribute('data-theme', t);
  } catch (e) { /* no script: help.css follows the system */ }
})();
</script>
'@

$script:HashScript = @'
<script>
/* Progressive enhancement only: the page is complete without it. */
(function () {
  function openHash() {
    var id = location.hash.slice(1);
    var el = id && document.getElementById(id);
    if (el && el.tagName === 'DETAILS') { el.open = true; }
  }
  addEventListener('hashchange', openHash);
  openHash();
})();
</script>
'@

function Get-HelpHead {
    param([string] $Locale, [string] $Title)
    $lines = @(
        '<!doctype html>'
        "<html lang=`"$Locale`" dir=`"ltr`">"
        '<head>'
        '<meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width, initial-scale=1">'
        '<meta name="referrer" content="no-referrer">'
        '<meta name="robots" content="noindex">'
        "<title>$(ConvertTo-HtmlText $Title)</title>"
        $script:ThemeScript
        '<link rel="stylesheet" href="../sza-kit.css">'
        '<link rel="stylesheet" href="../help.css">'
        '</head>'
        '<body class="help">'
        '<main class="container">'
    )
    $lines -join "`n"
}

function Get-HelpFooter {
    param([string] $Locale, [hashtable] $Common, [string] $Revised, [bool] $WithIndex, [hashtable] $Record = $null)
    $t = $Common.text[$Locale]
    $parts = @('<footer class="help-foot">')
    $parts += "  <span>$(ConvertTo-HtmlText ($t.footerRevised.Replace('{date}', $Revised)))</span>"
    if ($null -ne $Record) {
        $parts += "  <span>$(ConvertTo-HtmlText ($t.footerCaptured.Replace('{version}', [string]$Record.version).Replace('{date}', [string]$Record.date)))</span>"
    }
    if ($WithIndex) { $parts += "  <a href=`"index.html`">$(ConvertTo-HtmlText $t.footerIndex)</a>" }
    $parts += "  <a href=`"$(ConvertTo-HtmlText $Common.supportUrl)`" rel=`"noopener`">$(ConvertTo-HtmlText $t.footerSupport)</a>"
    $parts += '</footer>'
    $parts -join "`n"
}

function Get-ModulePill {
    param([hashtable] $Text, [string] $Module)
    if ($Module -eq "wear") { $Text.pillWatch } else { $Text.pillPhone }
}

function Get-RelatedItem {
    param([string] $Href, [string] $Name, [string] $Pill, [bool] $Gold, [string] $Note)
    $pillClass = if ($Gold) { 'pill gold' } else { 'pill' }
    "  <li><a href=`"$(ConvertTo-HtmlText $Href)`"><b>$(ConvertTo-HtmlText $Name)</b><span class=`"$pillClass`">$(ConvertTo-HtmlText $Pill)</span><small>$(ConvertTo-HtmlText $Note)</small></a></li>"
}

# The name of an element as the page shows it: the UI strings of its module when it has references, else its own text.
function Get-HelpElementName {
    param([string] $Root, [hashtable] $Page, [hashtable] $Element, [hashtable] $Entry, [string] $Locale)
    $refs = @()
    if ($Element.ContainsKey('nameRef')) { $refs += [string]$Element.nameRef }
    if ($Element.ContainsKey('nameRefs')) { $refs += @($Element.nameRefs) }
    if ($refs.Count -gt 0) {
        return (($refs | ForEach-Object { Resolve-StringRef -Root $Root -Module $Page.module -Locale $Locale -Key $_ }) -join ' / ')
    }
    [string]$Entry.name
}

# The hover link between a pin and its entry (the reference template's script); the page reads completely without it.
$script:PinScript = @'
<script>
/* Progressive enhancement only: the page is complete without it. */
(function () {
  document.querySelectorAll('details.el').forEach(function (d) {
    var pin = document.querySelector('.pin[href="#' + d.id + '"]');
    if (!pin) { return; }
    function on() { pin.classList.add('on'); d.classList.add('on'); }
    function off() { pin.classList.remove('on'); d.classList.remove('on'); }
    d.addEventListener('mouseenter', on); d.addEventListener('mouseleave', off);
    d.addEventListener('focusin', on); d.addEventListener('focusout', off);
    pin.addEventListener('mouseenter', on); pin.addEventListener('mouseleave', off);
    pin.addEventListener('focus', on); pin.addEventListener('blur', off);
  });
})();
</script>
'@

# The screenshot with its numbered pins (CONTEXT-HELP rule 8 item 3). The pins' percentages are of the frame, which is the
# image and nothing else; the frame never grows past the image's own width. A page with two themes carries two images and
# help.css shows the one that matches; a page with one theme carries one plain image. A part the record lists as absent has
# its entry and its number in the text and no pin.
function Get-HelpFigureHtml {
    param([string] $Root, [hashtable] $Common, [hashtable] $Page, [hashtable] $Record, [string] $Locale, [hashtable] $Markers)
    $t = $Common.text[$Locale]
    $text = $Page.text[$Locale]
    $title = Resolve-StringRef -Root $Root -Module $Page.module -Locale $Locale -Key $Page.titleRef
    $watch = $Page.module -eq 'wear'
    $names = @{}
    foreach ($element in $Page.elements) { $names[[string]$element.id] = Get-HelpElementName -Root $Root -Page $Page -Element $element -Entry $text.elements[[string]$element.id] -Locale $Locale }
    $labels = [System.Collections.Generic.List[string]]::new()
    foreach ($element in $Page.elements) {
        $id = [string]$element.id
        if (@($Record.pins | Where-Object { $_.id -eq $id }).Count -gt 0) { $labels.Add("$($Markers[$id]) $($names[$id])") }
    }
    $altTemplate = if ($watch) { $t.shotAltWatch } else { $t.shotAlt }
    $alt = $altTemplate.Replace('{title}', $title).Replace('{names}', ($labels -join ', '))
    $caption = if ($watch) { $t.shotCaptionWatch } else { $t.shotCaption }
    $width = [int]$Record.image.width
    $height = [int]$Record.image.height
    $themes = @($Record.themes)
    $out = [System.Collections.Generic.List[string]]::new()
    $out.Add('  <figure class="shot">')
    $out.Add("    <div class=`"frame`" style=`"max-width:$($width)px;margin-inline:auto`">")
    if ($themes.Count -eq 1) {
        $out.Add("      <img src=`"$($Page.id)-$($themes[0]).png`" width=`"$width`" height=`"$height`" alt=`"$(ConvertTo-HtmlText $alt)`">")
    } else {
        $out.Add("      <img class=`"on-dark`" src=`"$($Page.id)-dark.png`" width=`"$width`" height=`"$height`" alt=`"$(ConvertTo-HtmlText $alt)`">")
        $out.Add("      <img class=`"on-light`" src=`"$($Page.id)-light.png`" width=`"$width`" height=`"$height`" alt=`"`">")
    }
    $invariant = [System.Globalization.CultureInfo]::InvariantCulture
    foreach ($element in $Page.elements) {
        $id = [string]$element.id
        $pin = @($Record.pins | Where-Object { $_.id -eq $id })
        if ($pin.Count -eq 0) { continue }
        $x = ([double]$pin[0].x).ToString('0.##', $invariant)
        $y = ([double]$pin[0].y).ToString('0.##', $invariant)
        $label = ConvertTo-HtmlText "$($Markers[$id]), $($names[$id])"
        $out.Add("      <a class=`"pin`" style=`"--x:$x%;--y:$y%`" href=`"#$id`" aria-label=`"$label`">$($Markers[$id])</a>")
    }
    $out.Add('    </div>')
    $out.Add("    <figcaption>$(ConvertTo-HtmlText $caption)</figcaption>")
    $out.Add('  </figure>')
    $out -join "`n"
}

function New-HelpPageHtml {
    param([string] $Root, [hashtable] $Map, [System.Collections.IDictionary] $Pages, [hashtable] $Common, [hashtable] $Page, [string] $Locale, [hashtable] $Record = $null)
    $t = $Common.text[$Locale]
    $text = $Page.text[$Locale]
    $siteBase = Get-SiteBase $Map
    $title = Resolve-StringRef -Root $Root -Module $Page.module -Locale $Locale -Key $Page.titleRef
    $markers = @{}
    $number = 0
    foreach ($element in $Page.elements) { $number++; $markers[$element.id] = $number }

    $out = [System.Collections.Generic.List[string]]::new()
    $out.Add((Get-HelpHead -Locale $Locale -Title ($t.titlePrefix + $title + " - " + (Get-ModulePill $t $Page.module))))
    $out.Add('')
    $out.Add('  <nav class="help-crumbs" aria-label="Breadcrumb">')
    $out.Add("    <a href=`"index.html`">$(ConvertTo-HtmlText $t.crumbIndex)</a><span class=`"sep`" aria-hidden=`"true`">/</span><span>$(ConvertTo-HtmlText $title)</span>")
    $out.Add('  </nav>')
    $out.Add('  <header class="hero">')
    $out.Add("    <p class=`"kicker`">$(ConvertTo-HtmlText $(if ($Page.module -eq "wear") { $t.kickerWatch } else { $t.kicker }))</p>")
    $out.Add("    <h1>$(ConvertTo-HtmlText $title)</h1>")
    $out.Add("    <p class=`"lead`">$(ConvertTo-HtmlText $text.lead)</p>")
    $out.Add('  </header>')
    $out.Add('')
    if ($null -ne $Record) {
        $out.Add((Get-HelpFigureHtml -Root $Root -Common $Common -Page $Page -Record $Record -Locale $Locale -Markers $markers))
        $out.Add('')
    }
    $out.Add("  <h2>$(ConvertTo-HtmlText $t.stepsHeading)</h2>")
    $out.Add('  <ol class="order">')
    foreach ($step in $text.order) { $out.Add("    <li>$(ConvertTo-HelpInline ([string]$step) $markers)</li>") }
    $out.Add('  </ol>')
    $out.Add('')
    $out.Add("  <h2>$(ConvertTo-HtmlText $t.elementsHeading)</h2>")
    $out.Add('  <div class="elements">')
    foreach ($element in $Page.elements) {
        $id = $element.id
        $entry = $text.elements[$id]
        $name = Get-HelpElementName -Root $Root -Page $Page -Element $element -Entry $entry -Locale $Locale
        $out.Add('')
        $out.Add("    <details class=`"el`" id=`"$id`">")
        $out.Add("      <summary><span class=`"mk`">$($markers[$id])</span><span><span class=`"name`">$(ConvertTo-HtmlText $name)</span><span class=`"one`">$(ConvertTo-HelpInline ([string]$entry.one) $markers)</span></span></summary>")
        $out.Add('      <div class="full">')
        foreach ($paragraph in @($entry.full)) { $out.Add("        <p>$(ConvertTo-HelpInline ([string]$paragraph) $markers)</p>") }
        $out.Add('        <dl class="facts">')
        $out.Add("          <dt>$(ConvertTo-HtmlText $t.factWhy)</dt><dd>$(ConvertTo-HelpInline ([string]$entry.why) $markers)</dd>")
        $out.Add("          <dt>$(ConvertTo-HtmlText $t.factNext)</dt><dd>$(ConvertTo-HelpInline ([string]$entry.next) $markers)</dd>")
        $out.Add("          <dt>$(ConvertTo-HtmlText $t.factUndo)</dt><dd>$(ConvertTo-HelpInline ([string]$entry.undo) $markers)</dd>")
        if ($element.ContainsKey('shortcut')) {
            $out.Add("          <dt>$(ConvertTo-HtmlText $t.factShortcut)</dt><dd>$(ConvertTo-ShortcutHtml ([string]$element.shortcut))</dd>")
        }
        $out.Add('        </dl>')
        $out.Add('      </div>')
        $out.Add('    </details>')
    }
    $out.Add('  </div>')
    $out.Add('')
    $out.Add("  <h2>$(ConvertTo-HtmlText $t.relatedHeading)</h2>")
    $out.Add('  <ul class="related">')
    foreach ($rel in $Page.related) {
        if ($rel.ContainsKey('page')) {
            $target = $Pages[[string]$rel.page]
            $targetTitle = Resolve-StringRef -Root $Root -Module $target.module -Locale $Locale -Key $target.titleRef
            $out.Add((Get-RelatedItem -Href "$($rel.page).html" -Name $targetTitle -Pill (Get-ModulePill $t $target.module) -Gold $false -Note ([string]$text.related[[string]$rel.page])))
        } elseif ($rel.site -eq 'landing') {
            $out.Add((Get-RelatedItem -Href ($siteBase + $Common.landingPath[$Locale]) -Name $t.siteName -Pill $t.pillSite -Gold $true -Note $t.siteNote))
        } elseif ($rel.site -eq 'privacy') {
            $out.Add((Get-RelatedItem -Href ($siteBase + $Common.privacyPath[$Locale]) -Name $t.privacyName -Pill $t.pillSite -Gold $true -Note $t.privacyNote))
        } else {
            throw "Unknown related entry in source $($Page.id)"
        }
    }
    $out.Add('  </ul>')
    $out.Add('')
    $out.Add((Get-HelpFooter -Locale $Locale -Common $Common -Revised $Page.revised -WithIndex $true -Record $Record))
    $out.Add('')
    $out.Add('</main>')
    $out.Add($script:HashScript)
    if ($null -ne $Record) { $out.Add($script:PinScript) }
    $out.Add('</body>')
    $out.Add('</html>')
    ($out -join "`n") + "`n"
}

function New-HelpIndexHtml {
    param([string] $Root, [hashtable] $Map, [System.Collections.IDictionary] $Pages, [hashtable] $Common, [string] $Locale)
    $t = $Common.text[$Locale]
    $revised = ($Pages.Values | ForEach-Object { $_.revised } | Sort-Object | Select-Object -Last 1)
    $out = [System.Collections.Generic.List[string]]::new()
    $out.Add((Get-HelpHead -Locale $Locale -Title $t.indexTitle))
    $out.Add('')
    $out.Add('  <header class="hero">')
    $out.Add("    <p class=`"kicker`">$(ConvertTo-HtmlText $t.indexKicker)</p>")
    $out.Add("    <h1>$(ConvertTo-HtmlText $t.indexTitle)</h1>")
    $out.Add("    <p class=`"lead`">$(ConvertTo-HtmlText $t.indexLead)</p>")
    $out.Add('  </header>')
    $out.Add('')
    $out.Add("  <h2>$(ConvertTo-HtmlText $t.indexPagesHeading)</h2>")
    $out.Add('  <ul class="related">')
    foreach ($pageId in $Pages.Keys) {
        $page = $Pages[$pageId]
        $title = Resolve-StringRef -Root $Root -Module $page.module -Locale $Locale -Key $page.titleRef
        $out.Add((Get-RelatedItem -Href "$pageId.html" -Name $title -Pill (Get-ModulePill $t $page.module) -Gold $false -Note ([string]$page.text[$Locale].summary)))
    }
    $out.Add('  </ul>')
    $out.Add('')
    $out.Add((Get-HelpFooter -Locale $Locale -Common $Common -Revised $revised -WithIndex $false))
    $out.Add('')
    $out.Add('</main>')
    $out.Add('</body>')
    $out.Add('</html>')
    ($out -join "`n") + "`n"
}

# Every file the generator owns, for every output root: relative path (forward slashes, from the repository root) -> bytes.
function Get-HelpExpectedFiles {
    param([string] $Root)
    $map = Get-HelpMap -Root $Root
    $pages = Get-HelpPageSources -Root $Root -Map $map
    $common = Read-HelpJson (Join-Path $Root 'tools/help/source/common.json')
    $problems = Test-HelpSources -Root $Root -Map $map -Pages $pages -Common $common
    $records = Read-CaptureRecords -Root $Root
    if ($problems.Count -eq 0 -and $null -ne $records) {
        foreach ($problem in (Test-CaptureRecords -Root $Root -Pages $pages -Records $records)) { $problems.Add($problem) }
    }
    if ($problems.Count -gt 0) { return @{ Problems = $problems; Files = $null } }
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    $files = [ordered]@{}
    $kit = [System.IO.File]::ReadAllBytes((Join-Path $Root 'site/assets/sza-kit.css'))
    $help = [System.IO.File]::ReadAllBytes((Join-Path $Root 'tools/help/vendor/help.css'))
    # The app and the site get the same bytes (rule 12), so each page is built once and placed in every output root.
    $built = [ordered]@{}
    foreach ($loc in $script:HelpLocales) {
        $built["$loc/index.html"] = $utf8.GetBytes((New-HelpIndexHtml -Root $Root -Map $map -Pages $pages -Common $common -Locale $loc))
        foreach ($pageId in $pages.Keys) {
            $record = $null
            if ($null -ne $records -and $records.records.ContainsKey($pageId) -and $records.records[$pageId].ContainsKey($loc)) { $record = $records.records[$pageId][$loc] }
            $built["$loc/$pageId.html"] = $utf8.GetBytes((New-HelpPageHtml -Root $Root -Map $map -Pages $pages -Common $common -Page $pages[$pageId] -Locale $loc -Record $record))
            if ($null -ne $record) {
                foreach ($theme in @($record.themes)) {
                    $built["$loc/$pageId-$theme.png"] = [System.IO.File]::ReadAllBytes((Join-Path $Root (Get-CaptureImageRelative -HelpId $pageId -Locale $loc -Theme $theme)))
                }
            }
        }
    }
    foreach ($outRoot in $script:HelpOutputRoots) {
        $files["$outRoot/sza-kit.css"] = $kit
        $files["$outRoot/help.css"] = $help
        foreach ($key in $built.Keys) { $files["$outRoot/$key"] = $built[$key] }
    }
    @{ Problems = $problems; Files = $files }
}
