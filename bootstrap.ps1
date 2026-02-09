$OneDriveZipUrl = "https://1drv.ms/u/c/5ec0f8fbd7b1a668/IQC1rdQgon0pSK9kTXb_8Nl3Ac6lhu3jmuHVBgYdaqLRVyM?e=BDQbMO"
$OneDriveURLConverter = "https://github.com/Kobi-Blade/OneDriveLink/releases/download/v1.1.0/OneDriveLink.zip"

$ErrorActionPreference = "Stop"
Write-Host "Bootstrap script started with ExecutionId: $ExecutionId"

# ==========================
# Prepare directories
# ==========================
$installRoot = "C:\GameServer"
Start-Transcript -Path "$installRoot\bootstrap.log" -Append
New-Item -ItemType Directory -Force -Path $installRoot
Set-Location $installRoot

# ==========================
# Download OneDriveURLConverter
# ==========================
Write-Host "Downloading OneDriveURLConverter..."
Invoke-WebRequest `
  -Uri $OneDriveURLConverter `
  -OutFile "OneDriveLink.zip" `
  -UseBasicParsing

# ==========================
# Extract OneDriveURLConverter
# ==========================
Write-Host "Extracting OneDriveURLConverter..."
Expand-Archive `
  -Path "OneDriveLink.zip" `
  -DestinationPath $installRoot `
  -Force

# ==========================
# Get OneDriveURL
# ==========================
$OneDriveDownloadUrl = .\OneDriveLink.exe $OneDriveZipUrl

# ==========================
# Download game server files
# ==========================
Write-Host "Downloading game server from OneDrive..."
Invoke-WebRequest `
  -Uri $OneDriveDownloadUrl `
  -OutFile "server.zip" `
  -UseBasicParsing

# ==========================
# Extract game server files
# ==========================
Write-Host "Extracting game server files..."
Expand-Archive `
  -Path "server.zip" `
  -DestinationPath $installRoot `
  -Force

# ==========================
# Cleanup
# ==========================
Remove-Item -Path "server.zip" -Force
Write-Host "Bootstrap complete. Game server files are located at $installRoot"
Stop-Transcript