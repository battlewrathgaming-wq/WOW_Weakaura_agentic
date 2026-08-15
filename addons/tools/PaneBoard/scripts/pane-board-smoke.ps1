$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$tmpRoot = Join-Path $projectRoot ".tmp"
$cacheRoot = Join-Path $tmpRoot "cache"
$smokeRoot = Join-Path $tmpRoot "pane-board-smoke"
$resultPath = Join-Path $smokeRoot "pane-board-smoke-result.json"

New-Item -ItemType Directory -Force -Path $tmpRoot, $cacheRoot, $smokeRoot | Out-Null

if (Test-Path -LiteralPath $resultPath) {
  Remove-Item -LiteralPath $resultPath -Force
}

$env:WA_PANE_BOARD_SMOKE = "1"
$env:npm_config_cache = Join-Path $cacheRoot "npm"

Set-Location -LiteralPath $projectRoot
npm.cmd start

$startExitCode = $LASTEXITCODE
if ($startExitCode -ne 0) {
  exit $startExitCode
}

if (-not (Test-Path -LiteralPath $resultPath)) {
  throw "Pane Board smoke did not write $resultPath"
}

$result = Get-Content -LiteralPath $resultPath -Raw | ConvertFrom-Json
if ($result.status -ne "passed") {
  throw "Pane Board smoke failed: $($result.message)"
}

Write-Host "Pane Board smoke passed."
