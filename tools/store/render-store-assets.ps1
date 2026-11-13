<#
.SYNOPSIS
    Renders the Google Play listing graphics of DeviceInfo from the launcher glyph's geometry.

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

.PARAMETER Root
    Repository root. Defaults to two levels above this script.
#>
[CmdletBinding()]
param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$background = [System.Drawing.ColorTranslator]::FromHtml('#0D47A1')
$outDir = Join-Path $Root 'docs\play'
New-Item -ItemType Directory -Force $outDir | Out-Null

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

# Listing icon.
$icon = New-Canvas -Width 512 -Height 512
Draw-Glyph -G $icon.Graphics -cx 256 -cy 256 -unit ((512 / 108) * 1.5)
$icon.Graphics.Dispose()
$iconPath = Join-Path $outDir 'icon-512.png'
$icon.Bitmap.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)
$icon.Bitmap.Dispose()
# The hosted pages use the same icon as their link-preview image (og:image).
$siteAssets = Join-Path $Root 'site\assets'
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

foreach ($path in $iconPath, $featurePath, $socialPath) {
    $img = [System.Drawing.Image]::FromFile($path)
    Write-Host ("{0}: {1} x {2}, {3} bytes" -f (Split-Path $path -Leaf), $img.Width, $img.Height, (Get-Item $path).Length)
    $img.Dispose()
}
