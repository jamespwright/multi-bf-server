param(
  [Parameter(Mandatory=$true)]
  [string]$OneDriveZipUrl,
  [Parameter(Mandatory=$true)]
  [string]$ExecutionId
)

$ErrorActionPreference = "Stop"
Write-Host "Bootstrap script started with ExecutionId: $ExecutionId"
 # ==========================
 # Config
 # ==========================
$installRoot = "C:\GameServer"
$zipPath     = "$installRoot\server.zip"

# ==========================
# Prepare directories
# ==========================
New-Item -ItemType Directory -Force -Path $installRoot
Set-Location $installRoot

Start-Transcript -Path "$installRoot\bootstrap.log" -NoClobber
# ==========================
# Download game server files
# ==========================
Write-Host "Downloading game server from OneDrive..."
Invoke-WebRequest `
  -Uri $OneDriveZipUrl `
  -OutFile $zipPath `
  -UseBasicParsing

# ==========================
# Extract
# ==========================
Write-Host "Extracting game server files..."
Expand-Archive `
  -Path $zipPath `
  -DestinationPath $installRoot `
  -Force

# ==========================
# Cleanup
# ==========================
Remove-Item -Path $zipPath -Force

Write-Host "Bootstrap complete. Game server files are located at $installRoot"
Stop-Transcript