<#
.SYNOPSIS
  Root Disk Expansion
.DESCRIPTION
  Expand the Root Disk of a Virtual Machine
.PARAMETER NewOSDiskSize
    New Size of OS Disk
.EXAMPLE
  .\expand.ps1
  Version History
  v1.0   - Initial Release
#>
#Requires -Version 6.1.0
#Requires -Module @{ModuleName='Az.Resources'; ModuleVersion='0.3.0'}

Param(
  [string] $ResourceGroupName = $env:AZURE_IAAS_GROUP,

  [Parameter(Mandatory = $true)]
  [String]$VMName,

  [Parameter(Mandatory = $true)]
  [ValidateRange(30, 2048)]
  [int]$Size
)

if (!(Get-AzContext).Account) {
  Write-Error "Not Logged in!"
  return
}

Write-Verbose "Getting VM reference..."
# Get the VM in context
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName

if ($vm) {
  if ($vm.StorageProfile.OSDisk.DiskSizeGB -ge $Size) {
    $ExistingDiskSize = $vm.StorageProfile.OSDisk.DiskSizeGB
    Write-Error "Existing Size is $ExistingDiskSize and can't be reduced to $Size."
    return
  }

  Write-Verbose $vm.StorageProfile.OsDisk.ManagedDisk

  if ($vm.StorageProfile.OsDisk.ManagedDisk) {

    Write-Verbose "Getting VM Status..."
    $vmstatus = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -Status

    Write-Verbose "Getting VM State..."
    If ($vmstatus.Statuses.Code -contains "PowerState/running") {
      Write-Verbose "Stopping the VM as it is in a Running State..."
      $stopped = Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -Force
    }

    Write-Verbose "Changing OS Disk Size..."
    $vmDisk = Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $vm.StorageProfile.OSDisk.Name
    $vmDisk.DiskSizeGB = $Size
    $resizeOps = Update-AzDisk -ResourceGroupName $ResourceGroupName -Disk $vmDisk -DiskName $vmDisk.Name

    If ($stopped) {
      Write-Verbose "Restart the VM as it was stopped from a Running State..."
      Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -AsJob > $null
    }

    Write-Verbose "OS Disk size change successful."

  }
  else {
    Write-Error "Cannot find VM'"
    return
  }
}

