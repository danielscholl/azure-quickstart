<# Copyright (c) 2017
.Synopsis
   Creates a Container in a storage account to hold ARM Templates
.DESCRIPTION
   This script will create a storage container for hosting ARM Templates.
.EXAMPLE
#>
#Requires -Version 6.1.0
#Requires -Module @{ModuleName='Az.Resources'; ModuleVersion='0.3.0'}

Param(
  [Parameter(Mandatory = $true)]
  [string] $ResourceGroupName,

  [Parameter(Mandatory = $false)]
  [string] $ContainerName = "templates",

  [Parameter(Mandatory = $true)]
  [string] $QuickStart,

  [Parameter(Mandatory = $true)]
  [string] $BlobName
)

function Upload-Template ($ResourceGroupName, $ContainerName, $QuickStart, $BlobName) {

  # Get Storage Account
  $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName
  if (!$StorageAccount) {
    Write-Error -Message "Storage Account in $ResourceGroupName not found. Please fix and continue"
    return
  }

  $Keys = Get-AzStorageAccountKey -Name $StorageAccount.StorageAccountName `
    -ResourceGroupName $ResourceGroupName

  $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccount.StorageAccountName `
    -StorageAccountKey $Keys[0].Value

  ### Upload a file to the Microsoft Azure Storage Blob Container
  Write-Output "Uploading $BlobName..."
  $UploadFile = @{
    Context   = $StorageContext;
    Container = $ContainerName;
    File      = "$QuickStart\azuredeploy.json";
    Blob      = $BlobName;
  }

  Set-AzStorageBlobContent @UploadFile -Force;
}

Upload-Template $ResourceGroupName $ContainerName $QuickStart $BlobName
