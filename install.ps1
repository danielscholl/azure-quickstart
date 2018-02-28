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
#Requires -Version 5.1
#Requires -Module @{ModuleName='AzureRM.Resources'; ModuleVersion='5.0'}

Param(
  [boolean] $Base = $false,
  [boolean] $Gateway = $false,
  [boolean] $DevOps = $false,
  [boolean] $Server = $false
)
. ./.env.ps1
Get-ChildItem Env:AZURE*

if ($Base -eq $true) {
  Write-Host "Install Base Resources here we go...." -foregroundcolor "cyan"
  & ./iac-storage/install.ps1 -ResourceGroupName common
  & ./iac-keyvault/install.ps1 -ResourceGroupName common
  & ./iac-network/install.ps1 -ResourceGroupName common

  & .\scripts\createContainer.ps1 -ResourceGroupName common -ContainerName templates

  & .\scripts\uploadFile.ps1 -ResourceGroupName common -QuickStart iac-storage -BlobName deployStorage.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName common -QuickStart iac-keyvault -BlobName deployKeyVault.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName common -QuickStart iac-network -BlobName deployNetwork.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName common -QuickStart iac-functions -BlobName deployFunctions.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName common -QuickStart iac-automation -BlobName deployAutomation.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName common -QuickStart iac-singleVM -BlobName deploySingleVM.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName common -QuickStart iac-databaseVM -BlobName deployDatabaseVM.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName common -QuickStart iac-publicVM -BlobName deployPublicVM.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName common -QuickStart ext-omsMonitor -BlobName deployOMSExtension.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName common -QuickStart ext-dscNode -BlobName deployDSCExtension.json
  & .\scripts\uploadFile.ps1 -ResourceGroupName common -QuickStart ext-domainJoin -BlobName deployDomainJoinExtension.json

  & .\scripts\loadKeyVault.ps1 -ResourceGroupName common

  Write-Host "---------------------------------------------" -ForegroundColor "blue"
  Write-Host "Base Components have been installed!!!!!" -foregroundcolor "red"
  Write-Host "---------------------------------------------" -ForegroundColor "blue"
}

if ($DevOps -eq $true) {
  Write-Host "Install DevOps Resources here we go...." -foregroundcolor "cyan"

  & ./iac-storage/install.ps1 -ResourceGroupName devops
  & ./iac-automation/install.ps1 -ResourceGroupName devops

  Write-Host "---------------------------------------------" -ForegroundColor "blue"
  Write-Host "Devops Components have been installed!!!!!" -foregroundcolor "red"
  Write-Host "---------------------------------------------" -ForegroundColor "blue"
}


