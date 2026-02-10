$OneDriveZipUrl = $env:ONEDRIVE_ZIP_URL
$OneDriveURLConverter = $env:ONEDRIVE_URL_CONVERTER

# ==========================
# Prepare directories
# ==========================
$installRoot = "C:\GameServer"
New-Item -ItemType Directory -Force -Path $installRoot | Out-Null
Start-Transcript -Path "$installRoot\bootstrap.log" -Append
Set-Location $installRoot

Write-Host "Bootstrap script started..."

# ==========================
# Install Chocolatey and prerequisites
# ==========================
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Write-Host "Installing prerequisites via Chocolatey..."

choco install `
    vcredist2012 `
    vcredist140 `
    dotnet-8.0-runtime `
    dotnet3.5 `
    -y --no-progress

    # ==========================
# Download OneDriveLink
# ==========================
Write-Host "Downloading OneDriveLink..."
Invoke-WebRequest `
  -Uri $OneDriveURLConverter `
  -OutFile "OneDriveLink.zip"

# ==========================
# Extract OneDriveLink
# ==========================
Write-Host "Extracting OneDriveLink..."
Expand-Archive `
  -Path "OneDriveLink.zip" `
  -DestinationPath $installRoot `
  -Force

# ==========================
# Generate direct OneDrive download URL
# ==========================
Write-Host "Generating OneDrive direct download URL..."
$OneDriveDownloadUrl = .\OneDriveLink.exe $OneDriveZipUrl

if (-not $OneDriveDownloadUrl) {
    throw "Failed to generate OneDrive download URL"
}

# ==========================
# Download game server files
# ==========================
Write-Host "Downloading game server files..."
Invoke-WebRequest `
  -Uri $OneDriveDownloadUrl `
  -OutFile "server.zip"

# ==========================
# Extract game server files
# ==========================
Write-Host "Extracting game server files..."
Expand-Archive `
  -Path "server.zip" `
  -DestinationPath $installRoot `
  -Force

# ==========================
# Install game server
# ==========================
Set-Location '.\Portable BF-2021-08-13'
$setupProcess = Start-Process -FilePath '.\Setup.exe' -ArgumentList '/SILENT' -Wait -PassThru
if ($setupProcess.ExitCode -ne 0) {
  throw "Game server installation failed with exit code $($setupProcess.ExitCode)"
}

# ==========================
# Start game server
# ==========================

# Start Apache
Start-Process "C:\BF-Portable\Xampp\apache\bin\httpd.exe"
Start-Sleep -Seconds 10

# Start MySQL
Start-Process "C:\BF-Portable\Xampp\mysql\bin\mysqld.exe" -ArgumentList "--defaults-file=C:\BF-Portable\Xampp\mysql\bin\my.ini --standalone --console"
Start-Sleep -Seconds 10

# Start Redirector
Start-Process "C:\BF-Portable\Redirector\gosredirector.ea.com.exe" -ArgumentList "/console"
Start-Sleep -Seconds 10

# Start BlazeServer
Start-Process "C:\BF-Portable\EMU\BlazeServer.exe"
Start-Sleep -Seconds 10

# Start Battlefield 3 Server
Start-Process "C:\BF-Portable\Battlefield_3_Server\_StartServer.bat" -WorkingDirectory "C:\BF-Portable\Battlefield_3_Server"
Start-Sleep -Seconds 10

# Start Battlefield 4 Server
Start-Process "C:\BF-Portable\Battlefield_4_Server\!StartServer.bat" -WorkingDirectory "C:\BF-Portable\Battlefield_4_Server"
Start-Sleep -Seconds 10

Stop-Transcript