<# Copyright (c) 2017
.Synopsis
   Creates a Container in a storage account
.DESCRIPTION
   This script will create a storage container if it doesn't exist.
.EXAMPLE
#>

#Requires -Version 3.0
#Requires -Module AzureRM.Resources

Param(
  [Parameter(Mandatory = $true)]
  [string] $ResourceGroupName,

  [Parameter(Mandatory = $true)]
  [string] $ContainerName
)

function Create-Container ($ResourceGroupName, $ContainerName) {

  # Get Storage Account
  $StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName
  if (!$StorageAccount) {
    Write-Error -Message "Storage Account in $ResourceGroupName not found. Please fix and continue"
    return
  }

  $Keys = Get-AzureRmStorageAccountKey -Name $StorageAccount.StorageAccountName -ResourceGroupName $ResourceGroupName
  $StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey $Keys[0].Value

  $Container = Get-AzureStorageContainer -Name $ContainerName -Context $StorageContext -ErrorAction SilentlyContinue
  if (!$Container) {
    Write-Warning -Message "Storage Container $ContainerName not found. Creating the Container $ContainerName"
    New-AzureStorageContainer -Name $ContainerName -Context $StorageContext -Permission Off
  }

  # Set Global VSTS Task Variable $env:StorageAccount
  $value = $StorageAccount.StorageAccountName
  Write-Host ("##vso[task.setvariable variable=StorageAccount;]$value")
}

Create-Container $ResourceGroupName $ContainerName
