<# Copyright (c) 2017
.Synopsis
   Imports a DSC Node into an automation account
   Adapted from blog posts by: KARIM VAES
.DESCRIPTION
   This script will import a dsc configuration via powershell into a provided automation account.
.EXAMPLE

#>
#Requires -Version 6.1.0
#Requires -Module @{ModuleName='Az.Resources'; ModuleVersion='0.3.0'}

Param(
  [string] $filter,
  [string] $group,
  [string] $dscAccount,
  [string] $dscGroup,
  [string] $dscConfig
)

function Add-NodesViaFilter ($filter, $group, $dscAccount, $dscGroup, $dscConfig) {
  Write-Information -MessageData "Register VM with name like $filter found in $group and apply config $dscConfig"

  Get-AzVM -ResourceGroupName $group | Where-Object { $_.Name -like $filter } | `
    ForEach-Object {
    $vmName = $_.Name
    $vmLocation = $_.Location
    $vmGroup = $_.ResourceGroupName

    $dscNode = Get-AzAutomationDscNode `
      -Name $vmName `
      -ResourceGroupName $dscGroup `
      -AutomationAccountName $dscAccount `
      -ErrorAction SilentlyContinue

    if ( !$dscNode ) {
      Write-Information -MessageData "Registering $vmName"
      Register-AzAutomationDscNode `
        -AzureVMName $vmName `
        -AzureVMResourceGroup $vmGroup `
        -AzureVMLocation $vmLocation `
        -AutomationAccountName $dscAccount `
        -ResourceGroupName $dscGroup `
        -NodeConfigurationName $dscConfig `
        -RebootNodeIfNeeded $true
    }
    else {
      Write-Information -MessageData  "Skipping $vmName, as it is already registered"
    }
  }
}

Add-NodesViaFilter $filter $group $dscAccount $dscGroup $dscConfig
