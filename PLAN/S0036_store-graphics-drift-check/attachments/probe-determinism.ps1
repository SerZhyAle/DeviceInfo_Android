#requires -Version 7.0
# Scratch probe for S0036: is the System.Drawing PNG output byte-stable on this machine,
# and do the committed render targets equal a fresh render? Writes only under temp/S0036.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$repo = 'P:\ANDROID\deviceinfo_mob'
$scratch = Join-Path $repo 'temp\S0036'
$gen = Join-Path $repo 'tools\store\render-store-assets.ps1'
$files = @(
    'docs\play\icon-512.png',
    'docs\play\feature-graphic-1024x500.png',
    'site\assets\social-card-1200x630.png',
    'site\assets\icon-512.png'
)

foreach ($run in 'run1', 'run2') {
    $root = Join-Path $scratch $run
    if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force }
    New-Item -ItemType Directory -Force $root | Out-Null
    & $gen -Root $root | Out-Null
}

function Get-Sha256 {
    param([byte[]] $Bytes)
    [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::HashData($Bytes)).Replace('-', '').ToLowerInvariant()
}

function Get-PixelHash {
    param([string] $Path)
    $bmp = [System.Drawing.Bitmap]::new($Path)
    try {
        $rect = [System.Drawing.Rectangle]::new(0, 0, $bmp.Width, $bmp.Height)
        $data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $n = [Math]::Abs($data.Stride) * $bmp.Height
            $buf = New-Object byte[] $n
            [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $buf, 0, $n)
            return "{0}x{1} {2}" -f $bmp.Width, $bmp.Height, (Get-Sha256 $buf)
        }
        finally { $bmp.UnlockBits($data) }
    }
    finally { $bmp.Dispose() }
}

function Get-PngChunks {
    param([byte[]] $Bytes)
    $out = New-Object System.Collections.Generic.List[string]
    $pos = 8
    while ($pos -lt $Bytes.Length) {
        $len = ([int]$Bytes[$pos] -shl 24) -bor ([int]$Bytes[$pos + 1] -shl 16) -bor ([int]$Bytes[$pos + 2] -shl 8) -bor [int]$Bytes[$pos + 3]
        $type = [System.Text.Encoding]::ASCII.GetString($Bytes, $pos + 4, 4)
        $out.Add("$type($len)")
        $pos += 12 + $len
    }
    $out -join ' '
}

foreach ($f in $files) {
    $committed = Join-Path $repo $f
    $r1 = Join-Path $scratch "run1\$f"
    $r2 = Join-Path $scratch "run2\$f"
    $cb = [System.IO.File]::ReadAllBytes($committed)
    $b1 = [System.IO.File]::ReadAllBytes($r1)
    $b2 = [System.IO.File]::ReadAllBytes($r2)
    Write-Host "== $f"
    Write-Host ("  file sha256  committed={0} run1={1} run2={2}" -f (Get-Sha256 $cb), (Get-Sha256 $b1), (Get-Sha256 $b2))
    Write-Host ("  bytes        committed={0} run1={1} run2={2}" -f $cb.Length, $b1.Length, $b2.Length)
    Write-Host ("  pixels       committed={0}" -f (Get-PixelHash $committed))
    Write-Host ("  pixels       run1     ={0}" -f (Get-PixelHash $r1))
    Write-Host ("  pixels       run2     ={0}" -f (Get-PixelHash $r2))
    Write-Host ("  chunks       committed: {0}" -f (Get-PngChunks $cb))
    Write-Host ("  chunks       run1     : {0}" -f (Get-PngChunks $b1))
}
