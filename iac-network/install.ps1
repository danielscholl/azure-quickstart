<#
.SYNOPSIS
  Infrastructure as Code Component
.DESCRIPTION
  Install a Network
.EXAMPLE
  .\install.ps1
  Version History
  v1.0   - Initial Release
#>
#Requires -Version 6.1.0
#Requires -Module @{ModuleName='Az.Resources'; ModuleVersion='0.3.0'}

Param(
  [string]$Subscription = $env:AZURE_SUBSCRIPTION,
  [string]$ResourceGroupName = $env:AZURE_COMMON_GROUP,
  [string]$Location = $env:AZURE_LOCATION,
  [string]$NetworkSegment = "10.0.0"
)

if (Test-Path ..\scripts\functions.ps1) { . ..\scripts\functions.ps1 }
if (Test-Path .\scripts\functions.ps1) { . .\scripts\functions.ps1 }
if ( !$Subscription) { throw "Subscription Required" }
if ( !$ResourceGroupName) { throw "ResourceGroupName Required" }
if ( !$Location) { throw "Location Required" }
if ( !$NetworkSegment) { throw "Network Segment Required" }

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
Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
Write-Color -Text "Deploying ", "$DEPLOYMENT ", "template..." -Color Green, Red, Green
Write-Color -Text "---------------------------------------------------- "-Color Yellow

New-AzResourceGroupDeployment -Name $DEPLOYMENT `
  -TemplateFile $BASE_DIR\azuredeploy.json `
  -TemplateParameterFile $BASE_DIR\azuredeploy.parameters.json `
  -prefix $ResourceGroupName `
  -vnetPrefix    "$NetworkSegment.0/24" `
  -subnet1Prefix "$NetworkSegment.0/25" `
  -subnet2Prefix "$NetworkSegment.128/26" `
  -subnet3Prefix "$NetworkSegment.192/27" `
  -subnet4Prefix "$NetworkSegment.224/28" `
  -ResourceGroupName $ResourceGroupName
