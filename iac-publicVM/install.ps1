<#
.SYNOPSIS
  Infrastructure as Code Component
.DESCRIPTION
  Install a Public Virtual Machine
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
  [string] $DevopsGroup = "devops",
  [string] $Location = $env:AZURE_LOCATION,
  [boolean] $DomainJoin = $false,
  [string] $Image = $false,
  [string] $ImageName = ""
)

if (Test-Path ..\scripts\functions.ps1) { . ..\scripts\functions.ps1 }
if (Test-Path .\scripts\functions.ps1) { . .\scripts\functions.ps1 }
if (!$Subscription) { throw "Subscription Required" }
if (!$ResourceGroupName) { throw "ResourceGroupName Required" }
if (!$Location) { throw "Location Required" }

if (( $DevopsGroup ) -and ( $ImageName ) -and ( $Image -eq $true )) { 
  $UseImage = "Yes"
} else {
  $UseImage = "No"
}

###############################
## Azure Intialize           ##
###############################
$BASE_DIR = Get-ScriptDirectory
$DEPLOYMENT = Split-Path $BASE_DIR -Leaf
LoginAzure
CreateResourceGroup $ResourceGroupName $Location

Write-Color -Text "Registering Provider..." -Color Yellow
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute

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
$AdminUserName = (Get-AzureKeyVaultSecret -VaultName $VaultName -Name 'adminUserName').SecretValueText
$AdminPassword = (Get-AzureKeyVaultSecret -VaultName $VaultName -Name 'adminPassword').SecretValue

if (!$AdminUserName) {
  Write-Color -Text "`r`n---------------------------------------------------- "-Color Blue
  Write-Color -Text "Collecting Server Admin Credentials... " -Color Red
  Write-Color -Text "---------------------------------------------------- "-Color Blue
  $credential = Get-Credential -Message "Enter Server Admin Credentials"
  Set-AzureKeyVaultSecret -VaultName $VaultName -Name "adminUserName" -SecretValue (ConvertTo-SecureString $credential.UserName -AsPlainText -Force)
  Set-AzureKeyVaultSecret -VaultName $VaultName -Name "adminPassword" -SecretValue $credential.Password

  $AdminUserName = (Get-AzureKeyVaultSecret -VaultName $VaultName -Name 'adminUserName').SecretValueText
  $AdminPassword = (Get-AzureKeyVaultSecret -VaultName $VaultName -Name 'adminPassword').SecretValue
}
Write-Color -Text "$AdminUserName\*************" -Color White

Write-Color -Text "Retrieving Virtual Network Parameters..." -Color Green
$VirtualNetworkName = "${CommonResourceGroup}-vnet"
Write-Color -Text "$CommonResourceGroup  $VirtualNetworkName" -Color White

if ($UseImage -eq "Yes" ) {
  Write-Color -Text "Retrieving Image Parameters..." -Color Green
  $ManagedImage = Get-AzureRmImage -ResourceGroupName $DevopsGroup -ImageName $ImageName
} else {
  $ManagedImage = @{}
  $ManagedImage.Id = "/NoImage"
}

Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
Write-Color -Text "Deploying ", "$DEPLOYMENT ", "template..." -Color Green, Red, Green
Write-Color -Text "---------------------------------------------------- "-Color Yellow
New-AzureRmResourceGroupDeployment -Name $DEPLOYMENT `
  -TemplateFile $BASE_DIR\azuredeploy.json `
  -TemplateParameterFile $BASE_DIR\azuredeploy.parameters.json `
  -prefix $ResourceGroupName `
  -managedImageId $ManagedImage.Id -useImage $UseImage `
  -diagnosticsStorageName $StorageAccountName -diagnosticsStorageKey $SecureStorageKey `
  -adminUserName $AdminUserName -adminPassword $AdminPassword `
  -vnetGroup $CommonResourceGroup -vnet $VirtualNetworkName `
  -ResourceGroupName $ResourceGroupName

# Domain Join is not in a template to give the option to comment out.
if ( $DomainJoin -eq $True ) {
  & $BASE_DIR\..\ext-domainJoin\install.ps1 -ResourceGroupName $ResourceGroupName -VmName "$ResourceGroupName-jump".ToLower()
}
