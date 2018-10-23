<# Copyright (c) 2017
.Synopsis
   Imports a variable into an automation account
   Adapted from blog posts by: KARIM VAES
.DESCRIPTION
   This script will import a variable via powershell into a provided automation account.
.EXAMPLE
#>
#Requires -Version 6.1.0
#Requires -Module @{ModuleName='Az.Resources'; ModuleVersion='0.3.0'}


Param(
  [Parameter(Mandatory = $true)]
  [string] $VariableName,

  [Parameter(Mandatory = $true)]
  [string] $VariableValue,

  [Parameter(Mandatory = $true)]
  [string] $ResourceGroup,

  [string] $AutomationAccount = $ResourceGroup.Replace("-", "").ToLower() + "-automate"

)

function Import-Variable ($name, $value, $ResourceGroup, $AutomationAccount) {


  $variable = Get-AzAutomationVariable `
    -Name $name `
    -ResourceGroupName $ResourceGroup `
    -AutomationAccountName $AutomationAccount `
    -ErrorAction SilentlyContinue

  if (!$variable) {
    Set-StrictMode -off
    Write-Output "Importing $VariableName credential into the Automation Account $account"

    New-AzAutomationVariable `
      -Name $name `
      -Value $value `
      -Encrypted $false `
      -ResourceGroupName $ResourceGroup `
      -AutomationAccountName $AutomationAccount
  }

}


Import-Variable $VariableName $VariableValue $ResourceGroup $AutomationAccount
