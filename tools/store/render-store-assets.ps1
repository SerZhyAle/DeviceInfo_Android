#requires -Version 7.0
<#
.SYNOPSIS
    Renders the Google Play listing graphics of DeviceInfo from the launcher glyph's geometry, or checks that the
    committed files are that render (-Check).

.DESCRIPTION
    docs/play/icon-512.png            512 x 512 listing icon (Play applies its own mask, so the square is full bleed)
    docs/play/feature-graphic-1024x500.png   1024 x 500 feature graphic
    site/assets/icon-512.png          the same icon, the link-preview image of the hosted privacy pages
    site/assets/social-card-1200x630.png   1200 x 630 link-preview card (og:image) of the landing pages (S0012)

    The geometry is the one of phone/src/main/res/drawable/ic_launcher_foreground.xml (and the watch copy): a ring
    of radius 26 and stroke 6, a dot of radius 4 at (54, 41) and a stem 7 wide from y 49 to y 70, on the canvas
    of 108 units centred at (54, 54), over the background colour #0D47A1. The listing icon shows the whole canvas
    instead of the 72-unit visible circle of a launcher, so the glyph is drawn 1.5 times larger.
    Needs Windows (System.Drawing). Re-run it after changing the glyph; the PNGs are render targets, never edited.

    -Check (S0036, DOC-INTERNAL-QUALITY rule 4) renders the four files into a scratch folder of the operating system
    and compares the decoded pixels of each render with the committed file. The pixels are compared, not the PNG
    bytes: System.Drawing saves through GDI+, a component of the Windows build, so an unchanged picture can come out
    with other bytes on another build. Both sides are decoded by the same decoder in the same run. The scratch folder
    is removed; the repository is only read.

.PARAMETER Root
    Repository root. Defaults to two levels above this script.

.PARAMETER Check
    Compares the committed files with a fresh render instead of writing them. Exit codes: 0 every file equals its
    render (PASS); 1 a file is missing, cannot be decoded or differs (FAIL); 2 the render could not run (COULD NOT
    VERIFY). The last line on stdout is the verdict: `store-graphics-check: PASS|FAIL|COULD NOT VERIFY (..)`.
#>
[CmdletBinding()]
param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [switch]$Check
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

# The four render targets, relative to the repository root. The site icon is a copy of the listing icon.
$targets = @(
    'docs\play\icon-512.png',
    'docs\play\feature-graphic-1024x500.png',
    'site\assets\social-card-1200x630.png',
    'site\assets\icon-512.png'
)

$background = [System.Drawing.ColorTranslator]::FromHtml('#0D47A1')

# Draws the glyph with its centre at ($cx, $cy); $unit is the size in pixels of one geometry unit.
function Draw-Glyph {
    param([System.Drawing.Graphics]$G, [single]$cx, [single]$cy, [single]$unit)
    $white = [System.Drawing.Brushes]::White
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, (6 * $unit))
    try {
        $r = 26 * $unit
        $G.DrawEllipse($pen, $cx - $r, $cy - $r, 2 * $r, 2 * $r)
    }
    finally { $pen.Dispose() }
    $dot = 4 * $unit
    $G.FillEllipse($white, $cx - $dot, $cy + (41 - 54) * $unit - $dot, 2 * $dot, 2 * $dot)
    $G.FillRectangle($white, $cx - 3.5 * $unit, $cy + (49 - 54) * $unit, 7 * $unit, 21 * $unit)
}

function New-Canvas {
    param([int]$Width, [int]$Height)
    $bmp = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear($background)
    [pscustomobject]@{ Bitmap = $bmp; Graphics = $g }
}

# Writes the four render targets under $RenderRoot.
function Save-StoreGraphics {
    param([string]$RenderRoot)

    $outDir = Join-Path $RenderRoot 'docs\play'
    New-Item -ItemType Directory -Force $outDir | Out-Null

    # Listing icon.
    $icon = New-Canvas -Width 512 -Height 512
    Draw-Glyph -G $icon.Graphics -cx 256 -cy 256 -unit ((512 / 108) * 1.5)
    $icon.Graphics.Dispose()
    $iconPath = Join-Path $outDir 'icon-512.png'
    $icon.Bitmap.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $icon.Bitmap.Dispose()
    # The hosted pages use the same icon as their link-preview image (og:image).
    $siteAssets = Join-Path $RenderRoot 'site\assets'
    New-Item -ItemType Directory -Force $siteAssets | Out-Null
    Copy-Item -LiteralPath $iconPath -Destination (Join-Path $siteAssets 'icon-512.png') -Force

    # Feature graphic: the glyph on the left, the name on the right.
    $feature = New-Canvas -Width 1024 -Height 500
    Draw-Glyph -G $feature.Graphics -cx 250 -cy 250 -unit 5.2
    $font = New-Object System.Drawing.Font('Segoe UI Semibold', 88, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    try {
        $format = New-Object System.Drawing.StringFormat
        $format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $feature.Graphics.DrawString('DeviceInfo', $font, [System.Drawing.Brushes]::White, (New-Object System.Drawing.RectangleF(470, 0, 540, 500)), $format)
    }
    finally { $font.Dispose() }
    $feature.Graphics.Dispose()
    $featurePath = Join-Path $outDir 'feature-graphic-1024x500.png'
    $feature.Bitmap.Save($featurePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $feature.Bitmap.Dispose()

    # Social card of the landing (S0012): the same layout at the 1200 x 630 of an Open Graph preview, locale-neutral.
    $social = New-Canvas -Width 1200 -Height 630
    Draw-Glyph -G $social.Graphics -cx 300 -cy 315 -unit 6.4
    $socialFont = New-Object System.Drawing.Font('Segoe UI Semibold', 104, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    try {
        $socialFormat = New-Object System.Drawing.StringFormat
        $socialFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
        $social.Graphics.DrawString('DeviceInfo', $socialFont, [System.Drawing.Brushes]::White, (New-Object System.Drawing.RectangleF(560, 0, 620, 630)), $socialFormat)
    }
    finally { $socialFont.Dispose() }
    $social.Graphics.Dispose()
    $socialPath = Join-Path $siteAssets 'social-card-1200x630.png'
    $social.Bitmap.Save($socialPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $social.Bitmap.Dispose()
}

# The decoded pixels of a PNG as 32-bit ARGB rows: the size and the SHA-256 of the rows. Both sides of a comparison
# are decoded by this same function in the same run, so only the pixels decide the result.
function Get-PixelDigest {
    param([string]$Path)
    $bmp = [System.Drawing.Bitmap]::new($Path)
    try {
        $rect = [System.Drawing.Rectangle]::new(0, 0, $bmp.Width, $bmp.Height)
        $data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $length = [Math]::Abs($data.Stride) * $bmp.Height
            $pixels = [byte[]]::new($length)
            [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $pixels, 0, $length)
            $sha = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::HashData($pixels)).Replace('-', '').ToLowerInvariant()
            [pscustomobject]@{ Width = $bmp.Width; Height = $bmp.Height; Sha256 = $sha }
        }
        finally { $bmp.UnlockBits($data) }
    }
    finally { $bmp.Dispose() }
}

# Compares each committed target with its render. Returns the findings; an empty list means every target is equal.
function Compare-StoreGraphics {
    param([string]$CommittedRoot, [string]$RenderRoot)
    $findings = [System.Collections.Generic.List[string]]::new()
    foreach ($target in $targets) {
        $committed = Join-Path $CommittedRoot $target
        if (-not (Test-Path -LiteralPath $committed -PathType Leaf)) { $findings.Add("$target is missing"); continue }
        try { $have = Get-PixelDigest $committed }
        catch { $findings.Add("$target cannot be decoded: $($_.Exception.Message)"); continue }
        $want = Get-PixelDigest (Join-Path $RenderRoot $target)
        if ($have.Width -ne $want.Width -or $have.Height -ne $want.Height -or $have.Sha256 -ne $want.Sha256) {
            $findings.Add("$target differs from its render: committed $($have.Width) x $($have.Height) pixels $($have.Sha256.Substring(0, 12)), render $($want.Width) x $($want.Height) pixels $($want.Sha256.Substring(0, 12))")
            continue
        }
        Write-Host "PASS ${target}: $($have.Width) x $($have.Height), pixels equal"
    }
    return , $findings
}

if (-not $Check) {
    Save-StoreGraphics -RenderRoot $Root
    foreach ($target in $targets) {
        $path = Join-Path $Root $target
        $img = [System.Drawing.Image]::FromFile($path)
        Write-Host ("{0}: {1} x {2}, {3} bytes" -f $target, $img.Width, $img.Height, (Get-Item $path).Length)
        $img.Dispose()
    }
    return
}

# Check: the render goes to a scratch folder of the operating system; the repository is only read.
$scratch = Join-Path ([System.IO.Path]::GetTempPath()) ('deviceinfo-store-check-' + [guid]::NewGuid().ToString('N'))
$code = 0
try {
    Save-StoreGraphics -RenderRoot $scratch
    $findings = Compare-StoreGraphics -CommittedRoot $Root -RenderRoot $scratch
    if ($findings.Count -eq 0) {
        Write-Host "store-graphics-check: PASS ($($targets.Count) targets, pixels equal to the render)"
    }
    else {
        foreach ($finding in $findings) { Write-Host "FAIL $finding" }
        Write-Host "store-graphics-check: FAIL ($($findings.Count) of $($targets.Count) target(s) differ or are missing; re-run tools/store/render-store-assets.ps1 on the owner's machine, never edit a PNG)"
        $code = 1
    }
}
catch {
    Write-Host "store-graphics-check: COULD NOT VERIFY (the render or the comparison could not run: $($_.Exception.Message))"
    $code = 2
}
finally {
    if (Test-Path -LiteralPath $scratch) { Remove-Item -LiteralPath $scratch -Recurse -Force }
}
exit $code
