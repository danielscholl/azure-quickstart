<# Copyright (c) 2017
.Synopsis
   Imports a DSC Configuration into an automation account
   Adapted from blog posts by: KARIM VAES
.DESCRIPTION
   This script will import a dsc configuration via powershell into a provided automation account.
.EXAMPLE

#>
#Requires -Version 6.1.0
#Requires -Module @{ModuleName='Az.Resources'; ModuleVersion='0.3.0'}


Param(

  [Parameter(Mandatory = $true)]
  [string] $dscRole,

  [Parameter(Mandatory = $true)]
  [string] $ResourceGroup,

  [string] $DscPath = "./iac-automation/dsc/",
  [string] $dscDataConfig = $dscRole + "-config.ps1",
  [bool] $Force = $false
)

function Import-DscConfiguration ($script, $config, $ResourceGroup) {

  $AutomationAccount = (Get-AzAutomationAccount -ResourceGroupName $ResourceGroup).AutomationAccountName

  $dscConfig = Join-Path $DscPath ($script + ".ps1")
  $dscDataConfig = Join-Path $DscPath $config

  $dscConfigFile = (Get-Item $dscConfig).FullName
  $dscConfigFileName = [io.path]::GetFileNameWithoutExtension($dscConfigFile)

  $dscDataConfigFile = (Get-Item $dscDataConfig).FullName
  $dscDataConfigFileName = [io.path]::GetFileNameWithoutExtension($dscDataConfigFile)

  $dsc = Get-AzAutomationDscConfiguration `
    -Name $dscConfigFileName `
    -ResourceGroupName $ResourceGroup `
    -AutomationAccountName $AutomationAccount `
    -erroraction 'silentlycontinue'

  if ($dsc -and !$Force) {
    Write-Output  "Configuration $dscConfig Already Exists"
  }
  else {
    Write-Output "Importing & compiling DSC configuration $dscConfigFileName"

    Import-AzAutomationDscConfiguration `
      -AutomationAccountName $AutomationAccount `
      -ResourceGroupName $ResourceGroup `
      -Published `
      -SourcePath $dscConfigFile `
      -Force

    $configContent = (Get-Content $dscDataConfigFile | Out-String)
    Invoke-Expression $configContent

    $compiledJob = Start-AzAutomationDscCompilationJob `
      -ResourceGroupName $ResourceGroup `
      -AutomationAccountName $AutomationAccount `
      -ConfigurationName $dscConfigFileName `
      -ConfigurationData $ConfigData

    while ($null -eq $compiledJob.EndTime -and $null -eq $compiledJob.Exception) {
      $compiledJob = $compiledJob | Get-AzAutomationDscCompilationJob
      Start-Sleep -Seconds 3
      Write-Output "Compiling Configuration ..."
    }

    Write-Output "Compilation Complete!"
    $compiledJob | Get-AzAutomationDscCompilationJobOutput
  }

}


Import-DscConfiguration $dscRole $dscDataConfig $ResourceGroup
