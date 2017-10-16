<# Copyright (c) 2017
.Synopsis
   Imports a credential into an automation account
   Adapted from blog posts by: KARIM VAES
.DESCRIPTION
   This script will import a credential via powershell into a provided automation account.
.EXAMPLE

#>

#Requires -Version 3.0
#Requires -Module AzureRM.Resources

Param(
  [Parameter(Mandatory = $true)]
  [string] $CredentialName,

  [Parameter(Mandatory = $true)]
  [string] $UserName,

  [Parameter(Mandatory = $true)]
  [securestring] $UserPassword,

  [Parameter(Mandatory = $true)]
  [string] $ResourceGroup,

  [string] $AutomationAccount = $ResourceGroup.Replace("-", "").ToLower() + "-automate"

)

function Import-Credential ($CredentialName, $UserName, $UserPassword, $AutomationAccount, $ResourceGroup) {

  $cred = Get-AzureRmAutomationCredential `
    -Name $CredentialName `
    -ResourceGroupName $ResourceGroup `
    -AutomationAccountName $AutomationAccount `
    -ErrorAction SilentlyContinue

  if (!$cred) {
    Set-StrictMode -off
    Write-Output "Importing $CredentialName credential for user $UserName into the Automation Account $account"

    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $UserPassword

    New-AzureRmAutomationCredential `
      -Name $CredentialName `
      -ResourceGroupName $ResourceGroup `
      -AutomationAccountName $AutomationAccount `
      -Value $cred

  }

}


Import-Credential $CredentialName $UserName $UserPassword $AutomationAccount $ResourceGroup
