[CmdletBinding()]
param(
    [string]$GodotPath = ""
)

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$artifactRoot = Join-Path $projectRoot "artifacts\build-checks"
$exportRoot = Join-Path $projectRoot "export"
$qaExecutable = Join-Path $exportRoot "Go.Breeding-v0.2.4-win64-build-check.exe"
$qaPack = [System.IO.Path]::ChangeExtension($qaExecutable, ".pck")
$crashDummyCatalogPath = Join-Path $projectRoot "data\crash_dummy_part_catalog.json"

New-Item -ItemType Directory -Force -Path $artifactRoot | Out-Null
New-Item -ItemType Directory -Force -Path $exportRoot | Out-Null

if (-not $GodotPath) {
    $dedicatedGodot = "C:\Games\Dev\Godot\Godot.exe"
    if (Test-Path -LiteralPath $dedicatedGodot -PathType Leaf) {
        $GodotPath = $dedicatedGodot
    }
}

if (-not $GodotPath) {
    $godotCommand = Get-Command "Godot.exe" -ErrorAction SilentlyContinue
    if (-not $godotCommand) {
        $godotCommand = Get-Command "Godot_v4.7.2-stable_win64.exe" -ErrorAction SilentlyContinue
    }
    if (-not $godotCommand) {
        $godotCommand = Get-Command "godot" -ErrorAction SilentlyContinue
    }
    if (-not $godotCommand) {
        throw "Godot 4.7.2 was not found at C:\Games\Dev\Godot\Godot.exe or on PATH. Supply -GodotPath with the editor executable path."
    }
    $GodotPath = $godotCommand.Source
}

if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw "Godot executable not found at: $GodotPath"
}

function Invoke-CheckedProcess {
    param(
        [Parameter(Mandatory)] [string]$FilePath,
        [Parameter(Mandatory)] [string[]]$ArgumentList,
        [Parameter(Mandatory)] [string]$LogName
    )

    $stdoutPath = Join-Path $artifactRoot "$LogName-stdout.log"
    $stderrPath = Join-Path $artifactRoot "$LogName-stderr.log"
    $process = Start-Process `
        -FilePath $FilePath `
        -ArgumentList $ArgumentList `
        -WindowStyle Hidden `
        -PassThru `
        -RedirectStandardOutput $stdoutPath `
        -RedirectStandardError $stderrPath

    if (-not $process.WaitForExit(60000)) {
        $process.Kill($true)
        $process.WaitForExit()
        throw "$LogName exceeded the 60-second build-check timeout."
    }
    $process.WaitForExit()

    if ($process.ExitCode -ne 0) {
        $stderrText = Get-Content -LiteralPath $stderrPath -Raw -ErrorAction SilentlyContinue
        throw "$LogName failed with exit code $($process.ExitCode).`n$stderrText"
    }

    return [pscustomobject]@{
        StdoutPath = $stdoutPath
        StderrPath = $stderrPath
    }
}

Write-Host "[1/6] Verifying Godot version"
$crashDummyCatalog = Get-Content -LiteralPath $crashDummyCatalogPath -Raw | ConvertFrom-Json
$crashDummyDefinitionCount = @($crashDummyCatalog.part_definitions.PSObject.Properties).Count
if ($crashDummyDefinitionCount -lt 90) {
    throw "Crash-dummy catalog unexpectedly contains only $crashDummyDefinitionCount definitions."
}
$versionResult = Invoke-CheckedProcess -FilePath $GodotPath -ArgumentList @("--headless", "--version") -LogName "version"
$version = (Get-Content -LiteralPath $versionResult.StdoutPath -Raw).Trim()
if ($version -notmatch "^4\.7\.2\.") {
    throw "Expected Godot 4.7.2, found: $version"
}

Write-Host "[2/6] Importing resources and loading editor plugin"
$importResult = Invoke-CheckedProcess `
    -FilePath $GodotPath `
    -ArgumentList @("--headless", "--editor", "--path", $projectRoot, "--import") `
    -LogName "import"
$importErrors = Get-Content -LiteralPath $importResult.StderrPath -Raw
if ($importErrors -match "SCRIPT ERROR|Failed to load script|Invalid call") {
    throw "Editor plugin failed to compile or initialize.`n$importErrors"
}

Write-Host "[3/6] Testing Rig Studio interaction contract"
$studioResult = Invoke-CheckedProcess `
    -FilePath $GodotPath `
    -ArgumentList @("--headless", "--path", $projectRoot, "--script", "res://tools/rig_studio_smoke.gd") `
    -LogName "rig-studio"
$studioOutput = Get-Content -LiteralPath $studioResult.StdoutPath -Raw
if ($studioOutput -notmatch "RIG_STUDIO_SMOKE: editor UI, anchor drag, shared keyframe, undo and mode separation passed") {
    throw "Rig Studio test exited successfully but did not report its success marker."
}
if ($studioOutput -notmatch "MULTI_RIG_SMOKE: independent cast sizes, arbitrary rig count, keyed actor poses and stage motion passed") {
    throw "Multi-rig authoring test did not report its success marker."
}
if ($studioOutput -notmatch "RIG_STUDIO_V020: builder creation, variable keys, multi-select, onion skins, propagation and verb composition passed") {
    throw "Rig Studio v0.2.0 interaction contract did not report its success marker."
}

Write-Host "[4/6] Running source-project smoke test"
$sourceResult = Invoke-CheckedProcess `
    -FilePath $GodotPath `
    -ArgumentList @("--headless", "--path", $projectRoot, "--", "--smoke-test") `
    -LogName "source-smoke"
$sourceOutput = Get-Content -LiteralPath $sourceResult.StdoutPath -Raw
if ($sourceOutput -notmatch "SMOKE_TEST: all framework screens constructed successfully") {
    throw "Source smoke test exited successfully but did not report its success marker."
}

Write-Host "[5/6] Exporting private Windows QA build"
# Never overwrite an older embedded-PCK executable in place. Godot can leave
# the stale appended payload behind when a preset changes to a sidecar PCK,
# causing the runtime to prefer corrupt embedded data over the new pack.
Remove-Item -LiteralPath $qaExecutable -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $qaPack -Force -ErrorAction SilentlyContinue
$exportResult = Invoke-CheckedProcess `
    -FilePath $GodotPath `
    -ArgumentList @("--headless", "--verbose", "--path", $projectRoot, "--export-release", '"Windows Desktop"', $qaExecutable) `
    -LogName "export"
if (-not (Test-Path -LiteralPath $qaExecutable -PathType Leaf)) {
    throw "Godot reported success but did not create: $qaExecutable"
}
$exportErrors = Get-Content -LiteralPath $exportResult.StderrPath -Raw
if ($exportErrors -match "Couldn't save project\.binary|Can't open file from path .*tmpproject\.binary|SCRIPT ERROR|Failed to load script") {
    throw "Godot returned success but logged a fatal export error.`n$exportErrors"
}
$exportOutput = Get-Content -LiteralPath $exportResult.StdoutPath -Raw
$packedFiles = ($exportOutput -split "`r?`n") | Where-Object { $_ -match "Storing File:" }
$packedFileAudit = $packedFiles -join "`n"
if ($packedFileAudit -match "style_exploration" -or $packedFileAudit -match "art/offline" -or $packedFileAudit -match "API\.png") {
    throw "Export audit failed: private research media or API.png was packed into the QA build."
}
if ($packedFileAudit -match "addons/rig_studio" -or $packedFileAudit -match "res://tools/") {
    throw "Export audit failed: editor-only Rig Studio code was packed into the playable build."
}
if ($packedFileAudit -notmatch "unknown_character\.png" -or $packedFileAudit -match "unknown_character\.svg") {
    throw "Export audit failed: the runtime emergency PNG must be packed, but its editable SVG source must not be."
}
if ($packedFileAudit -notmatch "animation_verbs\.json" -or $packedFileAudit -notmatch "pairing_storyboard_grammar\.json") {
    throw "Export audit failed: the verb vocabulary and storyboard grammar were not packed."
}

Write-Host "[6/6] Running exported-build smoke test"
$runtimeResult = Invoke-CheckedProcess `
    -FilePath $qaExecutable `
    -ArgumentList @("--headless", "--", "--smoke-test") `
    -LogName "runtime-smoke"
$runtimeOutput = Get-Content -LiteralPath $runtimeResult.StdoutPath -Raw
if ($runtimeOutput -notmatch "SMOKE_TEST: all framework screens constructed successfully") {
    throw "Exported-build smoke test exited successfully but did not report its success marker."
}

$qaFile = Get-Item -LiteralPath $qaExecutable
Write-Host "BUILD_CHECK: PASS"
Write-Host "Godot: $version"
Write-Host "QA executable: $($qaFile.FullName)"
Write-Host "QA size: $($qaFile.Length) bytes"
