

Param(
  [string] $filter,
  [string] $group,
  [string] $dscAccount,
  [string] $dscGroup,
  [string] $dscConfig
)

function Add-NodesViaFilter ($filter, $group, $dscAccount, $dscGroup, $dscConfig) {
  Write-Information -MessageData "Register VM with name like $filter found in $group and apply config $dscConfig"

  Get-AzureRMVM -ResourceGroupName $group | Where-Object { $_.Name -like $filter } | `
    ForEach-Object {
    $vmName = $_.Name
    $vmLocation = $_.Location
    $vmGroup = $_.ResourceGroupName

    $dscNode = Get-AzureRmAutomationDscNode `
      -Name $vmName `
      -ResourceGroupName $dscGroup `
      -AutomationAccountName $dscAccount `
      -ErrorAction SilentlyContinue

    if ( !$dscNode ) {
      Write-Information -MessageData "Registering $vmName"
      Register-AzureRmAutomationDscNode `
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
