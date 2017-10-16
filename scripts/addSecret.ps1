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
  [string] $ResourceGroupName,

  [Parameter(Mandatory = $true)]
  [string] $SecretName,

  [Parameter(Mandatory = $true)]
  [SecureString ] $SecretValue
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

Add-Secret $ResourceGroupName $SecretName $SecretValue
