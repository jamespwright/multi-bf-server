$ErrorActionPreference = "Stop"

# ==========================
# Config
# ==========================
$installRoot = "C:\GameServer"
$zipPath     = "$installRoot\server.zip"
$markerFile  = "$installRoot\.installed"

$oneDriveZipUrl = "https://api.onedrive.com/v1.0/shares/u!BASE64VALUE/root/content"

# ==========================
# Idempotency Guard
# ==========================
if (Test-Path $markerFile) {
    Write-Host "Game server already installed. Exiting."
    exit 0
}

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
  -Uri $oneDriveZipUrl `
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
# Firewall
# ==========================
New-NetFirewallRule `
  -DisplayName "BFBC2 Server" `
  -Direction Inbound `
  -Protocol UDP `
  -LocalPort 19567 `
  -Action Allow `
  -ErrorAction SilentlyContinue

# ==========================
# Create startup script
# ==========================
$startScript = "$installRoot\start-server.ps1"

@"
Start-Process "$installRoot\BFBC2-EMU\mase_bc2.exe"
Start-Process "$installRoot\Frost\Frost.Game.Main_Win32_Final.exe" `
  -ArgumentList '-serverInstancePath "Instance/" -mapPack2Enabled 1 -port 19567 -timeStampLogNames -heartBeatInterval'
"@ | Out-File $startScript -Encoding UTF8

# ==========================
# Register Scheduled Task (auto-start)
# ==========================
$action = New-ScheduledTaskAction `
  -Execute "powershell.exe" `
  -Argument "-ExecutionPolicy Bypass -File `"$startScript`""

$trigger = New-ScheduledTaskTrigger -AtStartup

Register-ScheduledTask `
  -TaskName "BFBC2Server" `
  -Action $action `
  -Trigger $trigger `
  -RunLevel Highest `
  -Force

# ==========================
# Start immediately
# ==========================
powershell -ExecutionPolicy Bypass -File $startScript

# ==========================
# Mark installed
# ==========================
New-Item -ItemType File -Path $markerFile

Write-Host "Game server installation complete."
