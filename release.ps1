# ============================================================================
#  Dong goi phat hanh MCP Revit 2021-2026.
#    .\release.ps1
#  Ket qua:
#    Release\MCP-Revit_Setup_<version>.exe   BO CAI CHINH: 1 file, chon phien ban Revit, cai/go (khong can Admin)
#    Release\MCP-Revit_<version>\            du phong: Install.bat, Uninstall.bat, HUONG-DAN.txt, 2021\..2026\
#    Release\MCP-Revit_<version>.zip         zip cua thu muc du phong
#  Can cai du Revit 2021-2026 tren may build (ban nao thieu se bi bo qua + canh bao).
# ============================================================================
param([int[]]$Versions = @(2021, 2022, 2023, 2024, 2025, 2026))

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

# 1. Build tat ca ban
& (Join-Path $root "build.ps1") -Versions $Versions

# 2. Phien ban lay tu csproj
[xml]$proj = Get-Content (Join-Path $root "DtvMcpRevit\DtvMcpRevit.csproj")
$version = ($proj.Project.PropertyGroup | Where-Object { $_.Version } | Select-Object -First 1).Version
if (-not $version) { $version = "1.0.0" }

$name = "MCP-Revit_$version"
$releaseRoot = Join-Path $root "Release"
$stage = Join-Path $releaseRoot $name
$zip = Join-Path $releaseRoot "$name.zip"
if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
if (Test-Path $zip) { Remove-Item -Force $zip }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

# 3. Goi add-in tung ban
$packed = @()
foreach ($v in $Versions) {
    $deploy = Join-Path $root "DtvMcpRevit\bin\$v\Release\Deploy"
    if (-not (Test-Path (Join-Path $deploy "DTV_MCP.addin"))) {
        Write-Host "  Thieu goi Revit $v (chua build duoc) - bo qua" -ForegroundColor Yellow
        continue
    }
    Copy-Item -Path $deploy -Destination (Join-Path $stage $v) -Recurse -Force
    # pdb khong can khi phat hanh
    Get-ChildItem -Path (Join-Path $stage $v) -Recurse -Filter *.pdb | Remove-Item -Force
    $packed += $v
}

# 4. Bo cai Setup.exe: nhung cac thu muc 2021..2026 (payload.zip, duong dan zip dung '/') vao 1 file exe
Add-Type -AssemblyName System.IO.Compression.FileSystem
$payload = Join-Path $releaseRoot "payload.zip"
if (Test-Path $payload) { Remove-Item -Force $payload }
[System.IO.Compression.ZipFile]::CreateFromDirectory($stage, $payload, [System.IO.Compression.CompressionLevel]::Optimal, $false)
$setupProj = Join-Path $root "DtvMcpSetup\DtvMcpSetup.csproj"
dotnet build $setupProj -c Release -nologo -v q "-p:PayloadZip=$payload" "-p:Version=$version"
if ($LASTEXITCODE -ne 0) { throw "Build bo cai Setup that bai" }
$setupExe = Join-Path $releaseRoot "MCP-Revit_Setup_$version.exe"
Copy-Item -Path (Join-Path $root "DtvMcpSetup\bin\Release\DtvMcpSetup.exe") -Destination $setupExe -Force
Remove-Item -Force $payload

# 5. Bo cai du phong (.bat/.ps1): .ps1 luu UTF-8 co BOM (PowerShell 5.1 doc dung tieng Viet), .bat/.txt dung CRLF
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
foreach ($f in Get-ChildItem (Join-Path $root "Installer") -File) {
    $text = [System.IO.File]::ReadAllText($f.FullName) -replace "`r?`n", "`r`n"
    $dest = Join-Path $stage $f.Name
    if ($f.Extension -eq ".ps1") { [System.IO.File]::WriteAllText($dest, $text, $utf8Bom) }
    else { [System.IO.File]::WriteAllText($dest, $text, (New-Object System.Text.UTF8Encoding($false))) }
}

# 6. Nen zip (ban du phong)
Compress-Archive -Path (Join-Path $stage "*") -DestinationPath $zip -CompressionLevel Optimal

$size = [math]::Round((Get-Item $zip).Length / 1MB, 1)
Write-Host ""
Write-Host "Phat hanh $name : Revit $($packed -join ', ')" -ForegroundColor Green
Write-Host "  Thu muc : $stage"
Write-Host "  Zip     : $zip ($size MB)"
$setupSize = [math]::Round((Get-Item $setupExe).Length / 1MB, 1)
Write-Host "  Setup   : $setupExe ($setupSize MB)  <- gui file nay cho nguoi dung" -ForegroundColor Green
