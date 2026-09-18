## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $projectRoot "art\characters\human_default"
$manifestPath = Join-Path $sourceRoot "human_zero_parts_bundle_4x.json"
$outputPath = Join-Path $sourceRoot "human_zero_parts_bundle_4x.png"
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$magick = Get-Command magick.exe -ErrorAction Stop
$canvasWidth = [int]$manifest.canvas[0]
$canvasHeight = [int]$manifest.canvas[1]
$temporaryBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$temporaryRoot = Join-Path $temporaryBase ("go-breeding-human-zero-" + [guid]::NewGuid().ToString("N"))

New-Item -ItemType Directory -Path $temporaryRoot | Out-Null
try {
    $canvasPath = Join-Path $temporaryRoot "canvas-000.png"
    # Force a true-colour alpha canvas. ImageMagick otherwise optimizes an
    # empty canvas to grayscale-alpha and can quantize coloured SVG layers
    # down to gray while compositing them.
    & $magick.Source -size "${canvasWidth}x${canvasHeight}" "xc:rgba(0,0,0,0)" -colorspace sRGB -type TrueColorAlpha -define png:color-type=6 $canvasPath
    if ($LASTEXITCODE -ne 0) {
        throw "ImageMagick could not create the transparent atlas canvas."
    }

    $entryIndex = 0
    foreach ($entry in $manifest.entries) {
        $entryIndex += 1
        $sourcePath = Join-Path $sourceRoot ([string]$entry.source)
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
            throw "Missing Human Zero SVG source: $sourcePath"
        }
        $x = [int]$entry.rect[0]
        $y = [int]$entry.rect[1]
        $width = [int]$entry.rect[2]
        $height = [int]$entry.rect[3]
        $piecePath = Join-Path $temporaryRoot ("piece-{0:d3}.png" -f $entryIndex)
        $nextCanvasPath = Join-Path $temporaryRoot ("canvas-{0:d3}.png" -f $entryIndex)

        & $magick.Source -background none $sourcePath -resize "${width}x${height}!" $piecePath
        if ($LASTEXITCODE -ne 0) {
            throw "ImageMagick could not rasterize $sourcePath"
        }
        & $magick.Source $canvasPath $piecePath -geometry "+${x}+${y}" -composite $nextCanvasPath
        if ($LASTEXITCODE -ne 0) {
            throw "ImageMagick could not place $($entry.id) in the atlas."
        }
        $canvasPath = $nextCanvasPath
    }

    # Strip timestamps and ancillary chunks so identical SVG inputs produce
    # byte-identical committed output.
    & $magick.Source $canvasPath -colorspace sRGB -type TrueColorAlpha -strip -define png:exclude-chunks=date,time -define png:color-type=6 $outputPath
    if ($LASTEXITCODE -ne 0) {
        throw "ImageMagick could not finalize the deterministic PNG atlas."
    }
    Write-Host "HUMAN_ZERO_PNG_BUNDLE: $outputPath"
}
finally {
    $resolvedTemporaryRoot = [System.IO.Path]::GetFullPath($temporaryRoot)
    if ($resolvedTemporaryRoot.StartsWith($temporaryBase, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedTemporaryRoot)) {
        Remove-Item -LiteralPath $resolvedTemporaryRoot -Recurse -Force
    }
}
