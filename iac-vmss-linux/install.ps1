<#
.SYNOPSIS
  Infrastructure as Code Component
.DESCRIPTION
  Install a Scale Set
.EXAMPLE
  .\install.ps1
  Version History
  v1.0   - Initial Release
#>
#Requires -Version 6.1.0
#Requires -Module @{ModuleName='Az.Resources'; ModuleVersion='0.3.0'}

Param(
  [string]$Subscription = $env:AZURE_SUBSCRIPTION,
  [string] $ResourceGroupName = $env:AZURE_IAAS_GROUP,
  [string] $CommonResourceGroup = $env:AZURE_COMMON_GROUP,
  [string]$Location = $env:AZURE_LOCATION
)

if (Test-Path ..\scripts\functions.ps1) { . ..\scripts\functions.ps1 }
if (Test-Path .\scripts\functions.ps1) { . .\scripts\functions.ps1 }
if ( !$Subscription) { throw "Subscription Required" }
if ( !$ResourceGroupName) { throw "ResourceGroupName Required" }
if ( !$Location) { throw "Location Required" }


###############################
## Azure Intialize           ##
###############################
$BASE_DIR = Get-ScriptDirectory
$DEPLOYMENT = Split-Path $BASE_DIR -Leaf
LoginAzure
CreateResourceGroup $ResourceGroupName $Location

Write-Color -Text "Registering Provider..." -Color Yellow
Register-AzResourceProvider -ProviderNamespace Microsoft.Network


##############################
## Deploy Template          ##
##############################
Write-Color -Text "Gathering information for Key Vault..." -Color Green
$VaultName = GetKeyVault $CommonResourceGroup

Write-Color -Text "Retrieving Diagnostic Storage Account Parameters..." -Color Green
$StorageAccountName = GetStorageAccount $CommonResourceGroup
$StorageAccountKey = GetStorageAccountKey $CommonResourceGroup $StorageAccountName
$SecureStorageKey = $StorageAccountKey | ConvertTo-SecureString -AsPlainText -Force
Write-Color -Text "$StorageAccountName  $StorageAccountKey" -Color White

Write-Color -Text "Retrieving Credential Parameters..." -Color Green
$AdminUserName = (Get-AzKeyVaultSecret -VaultName $VaultName -Name 'adminUserName').SecretValueText
$SSHKey = (Get-AzKeyVaultSecret -VaultName $VaultName -Name 'sshKey').SecretValueText

Write-Color -Text "$AdminUserName" -Color White
Write-Color -Text "$SSHKey" -Color White

Write-Color -Text "Retrieving Virtual Network Parameters..." -Color Green
$VirtualNetworkName = "${CommonResourceGroup}-vnet"
Write-Color -Text "$CommonResourceGroup  $VirtualNetworkName" -Color White

Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
Write-Color -Text "Deploying ", "$DEPLOYMENT ", "template..." -Color Green, Red, Green
Write-Color -Text "---------------------------------------------------- "-Color Yellow

New-AzResourceGroupDeployment -Name $DEPLOYMENT `
  -TemplateFile $BASE_DIR\azuredeploy.json `
  -TemplateParameterFile $BASE_DIR\azuredeploy.parameters.json `
  -prefix $ResourceGroupName `
  -vnetGroup $CommonResourceGroup -vnet $VirtualNetworkName `
  -adminUserName $AdminUserName -sshKey $SSHKey `
  -ResourceGroupName $ResourceGroupName
