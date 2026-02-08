# ==========================
# Config
# ==========================
$resourceGroup = "bfbc2-rg"
$location      = "australiaeast"
$vmName        = "bfbc2-vm"
$vmSize        = "Standard_D4s_v5"
$adminUser     = "azureuser"
$adminPassword = "REPLACE_WITH_STRONG_PASSWORD"

$bootstrapScriptUrl = "https://raw.githubusercontent.com/YOURORG/YOURREPO/main/bootstrap.ps1"

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
  --admin-password $adminPassword `
  --public-ip-sku Standard

# ==========================
# Open Game Port (UDP 19567)
# ==========================
az vm open-port `
  --resource-group $resourceGroup `
  --name $vmName `
  --port 19567 `
  --protocol UDP

# ==========================
# Apply Custom Script Extension
# ==========================
az vm extension set `
  --resource-group $resourceGroup `
  --vm-name $vmName `
  --name CustomScriptExtension `
  --publisher Microsoft.Compute `
  --settings @"
{
  "commandToExecute": "powershell -ExecutionPolicy Bypass -Command `"iwr $bootstrapScriptUrl -OutFile C:\\bootstrap.ps1; powershell -ExecutionPolicy Bypass -File C:\\bootstrap.ps1`""
}
"@
