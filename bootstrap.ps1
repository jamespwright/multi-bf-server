param(
  [Parameter(Mandatory=$true)]
  [string]$OneDriveZipUrl
)

$ErrorActionPreference = "Stop"

# ==========================
# Config
# ==========================
$installRoot = "D:\GameServer"
$zipPath     = "$installRoot\server.zip"

# ==========================
# Prepare directories
# ==========================
New-Item -ItemType Directory -Force -Path $installRoot
Set-Location $installRoot

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
Expand-Archive `
  -Path $zipPath `
  -DestinationPath $installRoot `
  -Force

# ==========================
# Cleanup
# ==========================
Remove-Item -Path $zipPath -Force