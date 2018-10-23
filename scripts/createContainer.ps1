<# Copyright (c) 2017
.Synopsis
   Creates a Container in a storage account
.DESCRIPTION
   This script will create a storage container if it doesn't exist.
.EXAMPLE
#>

#Requires -Version 6.1.0
#Requires -Module @{ModuleName='Az.Resources'; ModuleVersion='0.3.0'}

Param(
  [Parameter(Mandatory = $true)]
  [string] $ResourceGroupName,

  [Parameter(Mandatory = $true)]
  [string] $ContainerName
)

function Create-Container ($ResourceGroupName, $ContainerName) {

  # Get Storage Account
  $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName
  if (!$StorageAccount) {
    Write-Error -Message "Storage Account in $ResourceGroupName not found. Please fix and continue"
    return
  }

  $Keys = Get-AzStorageAccountKey -Name $StorageAccount.StorageAccountName -ResourceGroupName $ResourceGroupName
  $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey $Keys[0].Value

  $Container = Get-AzStorageContainer -Name $ContainerName -Context $StorageContext -ErrorAction SilentlyContinue
  if (!$Container) {
    Write-Warning -Message "Storage Container $ContainerName not found. Creating the Container $ContainerName"
    New-AzStorageContainer -Name $ContainerName -Context $StorageContext -Permission Off
  }

  # Set Global VSTS Task Variable $env:StorageAccount
  $value = $StorageAccount.StorageAccountName
  Write-Host ("##vso[task.setvariable variable=StorageAccount;]$value")
}

Create-Container $ResourceGroupName $ContainerName
