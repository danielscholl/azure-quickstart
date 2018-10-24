<#
.SYNOPSIS
  Install the Full Infrastructure As Code Solution
.DESCRIPTION
  This Script will install the full Infrastructure.

  1. Resource Group
  2. Storage Container
  3. Key Vault
  4. Virtual Network

.EXAMPLE
  .\install.ps1
  Version History
  v1.0   - Initial Release
#>
#Requires -Version 6.1.0
#Requires -Module @{ModuleName='Az.Resources'; ModuleVersion='0.3.0'}

Param(
  [boolean] $Base = $false,
  [boolean] $Gateway = $false,
  [boolean] $DevOps = $false,
  [boolean] $Bastion = $false,
  [boolean] $Server = $false
)
. ./.env.ps1
Get-ChildItem Env:AZURE*

if ($Base -eq $true) {
  Write-Host "Install Base Resources here we go...." -foregroundcolor "cyan"
  & ./iac-storage/install.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP
  & ./iac-keyvault/install.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP
  & ./iac-network/install.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP

  & .\scripts\createContainer.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -ContainerName templates

  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart iac-storage -BlobName deployStorage.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart iac-keyvault -BlobName deployKeyVault.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart iac-network -BlobName deployNetwork.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart iac-functions -BlobName deployFunctions.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart iac-automation -BlobName deployAutomation.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart iac-singleVM -BlobName deploySingleVM.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart iac-databaseVM -BlobName deployDatabaseVM.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart iac-publicVM-windows -BlobName deployPublicVM-Windows.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart iac-publicVM-linux -BlobName deployPublicVM-Linux.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart iac-vmss-linux -BlobName deployVmss-Linux.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart ext-omsMonitor -BlobName deployOMSExtension.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart ext-dscNode -BlobName deployDSCExtension.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP -QuickStart ext-domainJoin -BlobName deployDomainJoinExtension.json

  & .\scripts\loadKeyVault.ps1 -ResourceGroupName $Env:AZURE_COMMON_GROUP

  Write-Host "---------------------------------------------" -ForegroundColor "blue"
  Write-Host "Base Components have been installed!!!!!" -foregroundcolor "red"
  Write-Host "---------------------------------------------" -ForegroundColor "blue"
}

if ($DevOps -eq $true) {
  Write-Host "Install DevOps Resources here we go...." -foregroundcolor "cyan"

  & ./iac-storage/install.ps1 -ResourceGroupName $Env:AZURE_DEVOPS_GROUP
  & ./iac-automation/install.ps1 -ResourceGroupName $Env:AZURE_DEVOPS_GROUP

  Write-Host "---------------------------------------------" -ForegroundColor "blue"
  Write-Host "Devops Components have been installed!!!!!" -foregroundcolor "red"
  Write-Host "---------------------------------------------" -ForegroundColor "blue"
}

if($Bastion -eq $true) {
  Write-Host "Install Bastion Resources here we go...." -foregroundcolor "cyan"

  & ./iac-publicVM-linux/install.ps1 -ResourceGroupName $Env:AZURE_BASTION_GROUP
  & ./iac-publicVM-windows/install.ps1 -ResourceGroupName $Env:AZURE_BASTION_GROUP -DomainJoin $false

  Write-Host "---------------------------------------------" -ForegroundColor "blue"
  Write-Host "Bastion Components have been installed!!!!!" -foregroundcolor "red"
  Write-Host "---------------------------------------------" -ForegroundColor "blue"
}

if($Server -eq $true) {
  Write-Host "Install Server Resources here we go...." -foregroundcolor "cyan"

  & ./iac-vmss-linux/install.ps1 -ResourceGroupName $Env:AZURE_SERVER_GROUP

  Write-Host "---------------------------------------------" -ForegroundColor "blue"
  Write-Host "Server Components have been installed!!!!!" -foregroundcolor "red"
  Write-Host "---------------------------------------------" -ForegroundColor "blue"
}
