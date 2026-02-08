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
# URL encode for safety
$urlEncodedOneDriveZipUrl = [System.Web.HttpUtility]::UrlEncode($oneDriveZipUrl)
# Escape single quotes for PowerShell command
$escapedOneDriveZipUrl = $urlEncodedOneDriveZipUrl -replace "'", "''"
<#
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
Write-Host "Creating VM $vmName in resource group $resourceGroup..."
az vm create `
  --resource-group $resourceGroup `
  --name $vmName `
  --image Win2022Datacenter `
  --size $vmSize `
  --admin-username $adminUser `
  --admin-password $adminPasswordPlain `
  --public-ip-sku Standard
#>
# ==========================
# Apply Custom Script Extension
# ==========================
Write-Host "Applying Custom Script Extension to VM $vmName..."
$ExecutionId = [Guid]::NewGuid().ToString()
$commandToExecute = "powershell -ExecutionPolicy Bypass -Command Invoke-WebRequest $bootstrapScriptUrl -OutFile C:\bootstrap.ps1; powershell -ExecutionPolicy Bypass -Command C:\bootstrap.ps1 -OneDriveZipUrl '$escapedOneDriveZipUrl' -ExecutionId '$ExecutionId'"

# Compress JSON and escape quotes for Azure CLI compatibility
$settingsJson = @{commandToExecute = $commandToExecute} | ConvertTo-Json -Compress
$settingsJson = $settingsJson.Replace('"', '\"')

az vm extension set `
  --resource-group $resourceGroup `
  --vm-name $vmName `
  --name CustomScriptExtension `
  --publisher Microsoft.Compute `
  --settings "$settingsJson"