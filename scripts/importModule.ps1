<# Copyright (c) 2017
.Synopsis
   Imports a module into an automation account
   Adapted from blog posts by: KARIM VAES
.DESCRIPTION
   This script will import a module via powershell into a provided automation account.
.EXAMPLE
    ./importModule.ps1 -ModuleName xWebAdministration -ModuleVersion 1.18.0 -ResourceGroup iac-automation -AutomationAccount automate
#>
#Requires -Version 6.1.0
#Requires -Module @{ModuleName='Az.Resources'; ModuleVersion='0.3.0'}

Param(
  [Parameter(Mandatory = $true)]
  [string] $ModuleName,

  [Parameter(Mandatory = $true)]
  [string] $ModuleVersion,

  [Parameter(Mandatory = $true)]
  [string] $ResourceGroup,

  [string] $AutomationAccount = $ResourceGroup.Replace("-", "").ToLower() + "-automate"
)

function Import-DscModule ($name, $version, $account, $group) {

  $module = Get-AzAutomationModule `
    -Name $name  `
    -AutomationAccountName $account `
    -ResourceGroupName $group `
    -ErrorAction SilentlyContinue

  if (!$module) {
    Set-StrictMode -off
    Write-Output "Importing $name module with version $version into the Automation Account $account"


    $url = "https://www.powershellgallery.com/api/v2/package/$name/$version"


    New-AzAutomationModule `
      -Name $name `
      -AutomationAccountName $account `
      -ResourceGroupName $group `
      -ContentLink $url

    $done = ""
    while (!$done) {
      $done = Get-AzAutomationModule `
        -Name $name `
        -AutomationAccountName $account `
        -ResourceGroupName $group `
        -ErrorAction SilentlyContinue| Where-Object {$_.ProvisioningState -eq 'Succeeded'}
      Start-Sleep -Seconds 3
      Write-Output "Importing ..."
    }
    Write-Output "Import Complete!"
  }
}

Import-DscModule  $ModuleName $ModuleVersion $AutomationAccount $ResourceGroup
