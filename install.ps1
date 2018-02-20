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
  [boolean] $Server = $false
)
. ./.env.ps1
Get-ChildItem Env:AZURE*

if ($Base -eq $true) {
  Write-Host "Install Base Resources here we go...." -foregroundcolor "cyan"
  & ./iac-storage/install.ps1 -ResourceGroupName common
  & ./iac-keyvault/install.ps1 -ResourceGroupName common
  & ./iac-network/install.ps1 -ResourceGroupName common

  Write-Host "---------------------------------------------" -ForegroundColor "blue"
  Write-Host "Base Components have been installed!!!!!" -foregroundcolor "red"
  Write-Host "---------------------------------------------" -ForegroundColor "blue"
}


