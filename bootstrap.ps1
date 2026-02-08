$OneDriveZipUrl = "https://my.microsoftpersonalcontent.com/personal/5ec0f8fbd7b1a668/_layouts/15/download.aspx?UniqueId=d7b1a668-f8fb-20c0-805e-c71b00000000&Translate=false&tempauth=v1e.eyJzaXRlaWQiOiJjNmZkNmZkZi1iZGU5LTRlYmEtYjhkZS05NzE3ZTliMmIzZDgiLCJhdWQiOiIwMDAwMDAwMy0wMDAwLTBmZjEtY2UwMC0wMDAwMDAwMDAwMDAvbXkubWljcm9zb2Z0cGVyc29uYWxjb250ZW50LmNvbUA5MTg4MDQwZC02YzY3LTRjNWItYjExMi0zNmEzMDRiNjZkYWQiLCJleHAiOiIxNzcwNTQ5OTQwIn0.kRxfDF9tZ14gsy-_LeEbC5vJW3vcYtd2Gl-8yLhC3vckzDt3FYfXctrcyrv31QADRpuyoZT-QwbvBWwXHY7do_fVgUjwzqAICDPsoKFst-ywuKkm-yufDy01jkM43sOviueKR0BXcNz7wm098_BA31fCLd5YUYVbj5hFxWyLQDTaTWkOUeMRGixcrLAbkGo1nbnmfqXqOX9OmeB0ItiInKC1VZq1B8ZIoLhL7E0KD6-PcPA9JkwK5uWS85kFprOEND2kKoa5Ymokjpl3JUoSQcoLG8bLTVIGX0sn946ELQWBKbWDjSXYrUTgD7LiXbxgylcJZkkD5QMzdJ5_Y99h2hUPC2QN4dcIdmW-Kg4ssO8jCT28jq12HzoNO1FDo1U2h5m0_Xxxo9PZRh7YOsakleLQAs8om21G7mqIZRHF8Su5J7K0Cud_luff5S4scljt4b0fn9N_Qvxsph--zths0a9CmZw61wkAOnUQ4ML61Pmhtt02kTYGU5-qCWnvgyDxEqp4Y_CS2oz4RVwGiMm8yQ.cOCN-cs1rW5XOhd0CCu6jz5Z_fGG56xPGEzoz3sZlAY&ApiVersion=2.0"
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

Start-Transcript -Path "$installRoot\bootstrap.log" -Append
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