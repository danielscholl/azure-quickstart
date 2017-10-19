<# Copyright (c) 2017
.Synopsis
   Adds a Secret to the Key Vault
.DESCRIPTION
   This script will add a secret to a key vault.
.EXAMPLE
#>

#Requires -Version 3.0
#Requires -Module AzureRM.Resources

Param(
  [Parameter(Mandatory = $true)]
  [string] $ResourceGroupName
)

function Add-Secret ($ResourceGroupName, $SecretName, $SecretValue) {

  # Get Storage Account
  $KeyVault = Get-AzureRmKeyVault -ResourceGroupName $ResourceGroupName
  if (!$KeyVault) {
    Write-Error -Message "Key Vault in $ResourceGroupName not found. Please fix and continue"
    return
  }

  Write-Output "Saving Secret $SecretName..."
  Set-AzureKeyVaultSecret -VaultName $KeyVault.VaultName -Name $SecretName -SecretValue $SecretValue
}


function Get-Storage($ResourceGroupName) {

  $StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName
  if (!$StorageAccount) {
    Write-Error -Message "Storage Account in $ResourceGroupName not found. Please fix and continue"
    return
  }

  Write-Output "Getting Keys for Storage $StorageAccount.StorageAccountName ..."
  $StorageKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName  -AccountName $StorageAccount.StorageAccountName

  $PrimaryKey = ConvertTo-SecureString $StorageKeys[0].Value -AsPlainText -Force
  $SecondaryKey = ConvertTo-SecureString $StorageKeys[1].Value -AsPlainText -Force

  Add-Secret $ResourceGroupName diagPrimaryKey $PrimaryKey
  Add-Secret $ResourceGroupName diagSecondaryKey $SecondaryKey
}

Get-Storage $ResourceGroupName
