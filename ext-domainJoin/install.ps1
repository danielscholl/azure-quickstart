<#
.SYNOPSIS
  Extension Component
.DESCRIPTION
  Add Domain to a Virtual machine
.EXAMPLE
  .\install.ps1
  Version History
  v1.0   - Initial Release
#>
#Requires -Version 5.1
#Requires -Module @{ModuleName='AzureRM.Resources'; ModuleVersion='5.0'}

Param(
  [string] $Subscription = $env:AZURE_SUBSCRIPTION,
  [string] $ResourceGroupName,
  [string] $CommonResourceGroup = "common",
  [Parameter(Mandatory = $true)]
  [string] $VmName
)

if (Test-Path ..\scripts\functions.ps1) { . ..\scripts\functions.ps1 }
if (Test-Path .\scripts\functions.ps1) { . .\scripts\functions.ps1 }
if ( !$Subscription) { throw "Subscription Required" }
if ( !$ResourceGroupName) { throw "ResourceGroupName Required" }

###############################
## Azure Intialize           ##
###############################
$BASE_DIR = Get-ScriptDirectory
$DEPLOYMENT = Split-Path $BASE_DIR -Leaf
LoginAzure

Write-Color -Text "Gathering information for Key Vault..." -Color Green
$VaultName = GetKeyVault $CommonResourceGroup

Write-Color -Text "Retrieving Credential Parameters..." -Color Green
$DomainUserName = (Get-AzureKeyVaultSecret -VaultName $VaultName -Name 'domainJoinName').SecretValueText
$DomainPassword = (Get-AzureKeyVaultSecret -VaultName $VaultName -Name 'domainJoinPassword').SecretValue

if (!$DomainUserName) {
  Write-Color -Text "`r`n---------------------------------------------------- "-Color Blue
  Write-Color -Text "Collecting Azure Active Directory Domain Credentials... " -Color Red
  Write-Color -Text "---------------------------------------------------- "-Color Blue
  $credential = Get-Credential -Message "Enger Azure Active Directory Domain Credentials"
  Set-AzureKeyVaultSecret -VaultName $VaultName -Name "domainJoinName" -SecretValue (ConvertTo-SecureString $credential.UserName -AsPlainText -Force)
  Set-AzureKeyVaultSecret -VaultName $VaultName -Name "domainJoinPassword" -SecretValue $credential.Password

  $DomainUserName = (Get-AzureKeyVaultSecret -VaultName $VaultName -Name 'domainJoinName').SecretValueText
  $DomainPassword = (Get-AzureKeyVaultSecret -VaultName $VaultName -Name 'domainJoinPassword').SecretValue
}

Write-Color -Text "$DomainUserName/***********" -Color White

##############################
## Deploy Template          ##
##############################
Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
Write-Color -Text "Deploying ", "$DEPLOYMENT ", "extension to ", "$VmName ", "template..." -Color Green, Red, Green, Red, Green
Write-Color -Text "---------------------------------------------------- "-Color Yellow
New-AzureRmResourceGroupDeployment -Name "$DEPLOYMENT-$vmName" `
  -TemplateFile $BASE_DIR\azuredeploy.json `
  -TemplateParameterFile $BASE_DIR\azuredeployparameters.json `
  -vmList $vmName `
  -domainAdmin $DomainUserName -domainPassword $DomainPassword `
  -ResourceGroupName $ResourceGroupName
