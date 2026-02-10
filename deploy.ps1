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
$OneDriveURLConverter = "https://github.com/Kobi-Blade/OneDriveLink/releases/download/v1.0.4/OneDriveLink.zip"

if (-not $env:ONEDRIVE_ZIP_URL) {
    $env:ONEDRIVE_ZIP_URL = Read-Host "Enter the OneDrive ZIP URL"
}


# ==========================
# Login to Azure
# ==========================

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

# ==========================
# Open required ports
# ==========================

Write-Host "Opening required ports on VM $vmName..."
$basePriority = 1100
$ports = @(42128, 42129, 42127, 80, 443, 25100, 25300)
for ($i = 0; $i -lt $ports.Count; $i++) {
  $port = $ports[$i]
  $priority = $basePriority + $i
  az vm open-port --resource-group $resourceGroup --name $vmName --port $port --priority $priority
}

# ==========================
# Disable Windows Defender Firewall
# ==========================

Write-Host "Disabling Windows Defender Firewall on VM $vmName..."
az vm run-command invoke `
  --resource-group $resourceGroup `
  --name $vmName `
  --command-id RunPowerShellScript `
  --scripts "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False"

# ==========================
# Install Game Server
# ==========================

Write-Host "Installing Game Server on VM $vmName..."

az vm run-command invoke `
  --resource-group $resourceGroup `
  --name $vmName `
  --command-id RunPowerShellScript `
  --scripts "Invoke-WebRequest $bootstrapScriptUrl -OutFile C:\bootstrap.ps1; powershell -ExecutionPolicy Bypass -File C:\bootstrap.ps1 -OneDriveZipUrl '$env:ONEDRIVE_ZIP_URL' -OneDriveURLConverter '$OneDriveURLConverter'"