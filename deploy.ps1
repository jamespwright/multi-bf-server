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

# ==========================
# Function to set environment variable on remote VM
# ==========================
function Set-RemoteEnvironmentVariable {
  param(
      [Parameter(Mandatory=$true)]
      [string]$ResourceGroup,
      
      [Parameter(Mandatory=$true)]
      [string]$VMName,
      
      [Parameter(Mandatory=$true)]
      [string]$Name,
      
      [Parameter(Mandatory=$true)]
      [string]$Value
  )
$script = @"
[System.Environment]::SetEnvironmentVariable('$Name', '$Value', [System.EnvironmentVariableTarget]::Machine)
"@

  Write-Host "Setting $Name on VM $VMName..."

  az vm run-command invoke `
      --resource-group $ResourceGroup `
      --name $VMName `
      --command-id RunPowerShellScript `
      --scripts $script
}
# ==========================
# Main Script
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
# Set environment variables for game server configuration
# ==========================
Set-RemoteEnvironmentVariable -ResourceGroup $resourceGroup -VMName $vmName -Name "ONEDRIVE_ZIP_URL" -Value $env:ONEDRIVE_ZIP_URL
Set-RemoteEnvironmentVariable -ResourceGroup $resourceGroup -VMName $vmName -Name "ONEDRIVE_URL_CONVERTER" -Value "https://github.com/Kobi-Blade/OneDriveLink/releases/download/v1.0.4/OneDriveLink.zip"

# ==========================
# Install Game Server Extension
# ==========================
Write-Host "Installing Game Server Extension on VM $vmName..."
$commandToExecute = "powershell -ExecutionPolicy Bypass -Command Invoke-WebRequest $bootstrapScriptUrl -OutFile C:\bootstrap.ps1; powershell -ExecutionPolicy Bypass -File C:\bootstrap.ps1"
$settingsJson = @{commandToExecute = $commandToExecute} | ConvertTo-Json -Compress

az vm extension set `
  --resource-group $resourceGroup `
  --vm-name $vmName `
  --name CustomScriptExtension `
  --publisher Microsoft.Compute `
  --settings $settingsJson