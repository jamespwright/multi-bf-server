# ==========================
# Config
# ==========================
$resourceGroup = "rg-bf-multi-server"
$location      = "australiaeast"
$vmName        = "bf-multi-server"
$vmSize        = "Standard_D4s_v5"
$adminUser     = "azureuser"
$adminPassword = Read-Host -Prompt "Enter admin password" -AsSecureString
$adminPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($adminPassword))
$bootstrapScriptUrl = "https://raw.githubusercontent.com/jamespwright/multi-bf-server/main/bootstrap.ps1"
$oneDriveZipUrl = Read-Host -Prompt "Enter OneDrive direct download URL for game server zip file"

az login

# ==========================
# Create Resource Group
# ==========================
az group create `
  --name $resourceGroup `
  --location $location

# ==========================
# Create VM
# ==========================
az vm create `
  --resource-group $resourceGroup `
  --name $vmName `
  --image Win2022Datacenter `
  --size $vmSize `
  --admin-username $adminUser `
  --admin-password $adminPasswordPlain `
  --public-ip-sku Standard

# ==========================
# Apply Custom Script Extension
# ==========================
$commandToExecute = "powershell -ExecutionPolicy Bypass -Command \`"iwr $bootstrapScriptUrl -OutFile C:\bootstrap.ps1; powershell -ExecutionPolicy Bypass -File C:\bootstrap.ps1 -OneDriveZipUrl '$oneDriveZipUrl'\`""
$settingsJson = @{commandToExecute = $commandToExecute} | ConvertTo-Json -Compress

# Save JSON to temp file to avoid PowerShell escaping issues
$tempSettingsFile = Join-Path $env:TEMP "vm-extension-settings.json"
$settingsJson | Out-File -FilePath $tempSettingsFile -Encoding utf8 -NoNewline

az vm extension set `
  --resource-group $resourceGroup `
  --vm-name $vmName `
  --name CustomScriptExtension `
  --publisher Microsoft.Compute `
  --settings "@$tempSettingsFile"

# Clean up temp file
Remove-Item $tempSettingsFile -ErrorAction SilentlyContinue
