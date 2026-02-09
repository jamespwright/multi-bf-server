$OneDriveZipUrl = "https://1drv.ms/u/c/5ec0f8fbd7b1a668/IQBx2wO2Q10iTbPAFZsun2FXAVcOY5JRWXM7e9-xwj6yOB0?e=C3L5Iw"
$OneDriveURLConverter = "https://github.com/Kobi-Blade/OneDriveLink/releases/download/v1.0.4/OneDriveLink.zip"

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
.\Setup.exe /SILENT

# ==========================
# Start game server
# ==========================

# Start Apache
Start-Process "C:\BF-Portable\Xampp\apache\bin\httpd.exe"

# Start MySQL
Start-Process "C:\BF-Portable\Xampp\mysql\bin\mysqld.exe" -ArgumentList "--defaults-file=C:\BF-Portable\Xampp\mysql\bin\my.ini --standalone --console"

# Start Redirector
Start-Process "C:\BF-Portable\Redirector\gosredirector.ea.com.exe" -ArgumentList "/console"

# Start BlazeServer
Start-Process "C:\BF-Portable\EMU\BlazeServer.exe"

# Start Battlefield 3 Server
Start-Process "C:\BF-Portable\Battlefield_3_Server\_StartServer.bat" -WorkingDirectory "C:\BF-Portable\Battlefield_3_Server"

# Start Battlefield 4 Server
Start-Process "C:\BF-Portable\Battlefield_4_Server\!StartServer.bat" -WorkingDirectory "C:\BF-Portable\Battlefield_4_Server"

Stop-Transcript