<#
.SYNOPSIS
  Infrastructure as Code Component
.DESCRIPTION
  Install a StorageAccount
.EXAMPLE
  .\install.ps1
  Version History
  v1.0   - Initial Release
#>
#Requires -Version 5.1
#Requires -Module @{ModuleName='AzureRM.Resources'; ModuleVersion='5.0'}

Param(
  [string]$Subscription = $env:AZURE_SUBSCRIPTION,
  [string]$ResourceGroupName = "lab",
  [string]$CommonResourceGroup = "common",
  [string]$DevopsGroup = "devops",
  [string]$Location = $env:AZURE_LOCATION,
  [string]$GithubToken = $env:GITHUB_TOKEN,
  [Parameter(Mandatory=$true, Position=0, HelpMessage="Password?")]
  [SecureString]$password
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
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Storage



##############################
## Deploy Template          ##
##############################

Write-Color -Text "Retrieving Virtual Network Parameters..." -Color Green
$VirtualNetworkName = "${CommonResourceGroup}-vnet"
Write-Color -Text "$CommonResourceGroup  $VirtualNetworkName" -Color White



Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
Write-Color -Text "Deploying ", "$DEPLOYMENT ", "template..." -Color Green, Red, Green
Write-Color -Text "---------------------------------------------------- "-Color Yellow
New-AzureRmResourceGroupDeployment -Name $DEPLOYMENT `
  -TemplateFile $BASE_DIR\azuredeploy.json `
  -TemplateParameterFile $BASE_DIR\azuredeploy.parameters.json `
  -prefix $ResourceGroupName `
  -vnetGroup $CommonResourceGroup -vnet $VirtualNetworkName `
  -artifactRepoSecurityToken $GithubToken `
  -ResourceGroupName $ResourceGroupName

# $pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
# $LabName = $(az resource list -g devtest --query "[?type=='Microsoft.DevTestLab/labs'].name" -otsv)
#   az lab secret set --lab-name $LabName `
#   --resource-group $ResourceGroupName `
#   --name password `
#   --value $pw