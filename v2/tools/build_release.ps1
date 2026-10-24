# Builds a release APK and copies it to releases/one_touch_v2-<version>-release.apk
# Usage (from v2/): powershell -ExecutionPolicy Bypass -File tools\build_release.ps1
# Rules: see v2/AGENTS.md "Build rules". Keep this file ASCII-only (Windows PowerShell 5.1).

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot          # v2/
$app = Join-Path $root 'app'
$pubspec = Join-Path $app 'pubspec.yaml'

$match = Select-String -Path $pubspec -Pattern '^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)' | Select-Object -First 1
if (-not $match) { throw "Could not read 'version: x.y.z+n' from $pubspec" }
$versionName = $match.Matches[0].Groups[1].Value
$versionCode = $match.Matches[0].Groups[2].Value

$outDir = Join-Path $root 'releases'
$target = Join-Path $outDir "one_touch_v2-$versionName-release.apk"
if (Test-Path $target) {
    throw "$target already exists. Bump the version in app/pubspec.yaml and build again."
}

Write-Host "Building one_touch_v2 $versionName (build $versionCode) ..."
Push-Location $app
try {
    flutter build apk --release
    if ($LASTEXITCODE -ne 0) { throw "flutter build apk --release failed (exit $LASTEXITCODE)" }
} finally {
    Pop-Location
}

$built = Join-Path $app 'build\app\outputs\flutter-apk\app-release.apk'
if (-not (Test-Path $built)) { throw "Build output not found: $built" }

New-Item -ItemType Directory -Force -Path $outDir | Out-Null
Copy-Item $built $target
$sizeMb = [math]::Round((Get-Item $target).Length / 1MB, 1)
Write-Host "Done: $target ($sizeMb MB)"
