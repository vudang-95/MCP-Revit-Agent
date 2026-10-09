# Build DTV MCP cho nhieu phien ban Revit.
#   .\build.ps1                         -> 2021..2026, Release
#   .\build.ps1 -Versions 2024,2025     -> chi cac ban chon
#   .\build.ps1 -Deploy                 -> build xong copy vao %AppData%\Autodesk\Revit\Addins\<ver>
# Goi cai tung ban: DtvMcpRevit\bin\<ver>\Release\Deploy\ (DTV_MCP.addin + thu muc DTV_MCP)
param(
    [int[]]$Versions = @(2021, 2022, 2023, 2024, 2025, 2026),
    [string]$Configuration = "Release",
    [switch]$Deploy
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$bridge = Join-Path $root "DtvMcpBridge\DtvMcpBridge.csproj"
$addin = Join-Path $root "DtvMcpRevit\DtvMcpRevit.csproj"

Write-Host "== Bridge (net48)" -ForegroundColor Cyan
dotnet build $bridge -c Release -nologo -v q
if ($LASTEXITCODE -ne 0) { throw "Build bridge loi" }

$failed = @()
foreach ($v in $Versions) {
    if (-not (Test-Path "C:\Program Files\Autodesk\Revit $v\RevitAPI.dll")) {
        Write-Host "== Revit $v : bo qua (chua cai Revit $v)" -ForegroundColor Yellow
        continue
    }
    Write-Host "== Revit $v" -ForegroundColor Cyan
    $buildArgs = @($addin, "-c", $Configuration, "-p:RevitVersion=$v", "-p:SkipBridge=true", "-nologo", "-v", "q")
    if ($Deploy) { $buildArgs += "-p:DeployToRevit=true" }
    dotnet build @buildArgs
    if ($LASTEXITCODE -ne 0) { $failed += $v }
}

if ($failed.Count -gt 0) { throw "Build loi: $($failed -join ', ')" }
Write-Host "Xong. Goi cai: DtvMcpRevit\bin\<ver>\$Configuration\Deploy\" -ForegroundColor Green
