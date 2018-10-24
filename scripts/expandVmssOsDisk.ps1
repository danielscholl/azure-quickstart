<#
.SYNOPSIS
  Root Disk Expansion
.DESCRIPTION
  Expand the Root Disk of a Scale Set
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
  [Parameter(Mandatory = $true)]
  [string] $ResourceGroupName,

  [Parameter(Mandatory = $true)]
  [String]$Name,

  [Parameter(Mandatory = $true)]
  [ValidateRange(30, 2048)]
  [int]$Size
)

if (!(Get-AzContext).Account) {
  Write-Error "Not Logged in!"
  return
}

Write-Verbose "Getting Scale Set reference..."
# Get the VM in context
$vmss = Get-AzVmss -ResourceGroupName $ResourceGroupName -Name $Name

if ($vmss) {
  if ($vmss.VirtualMachineProfile.StorageProfile.OSDisk.DiskSizeGB -ge $Size) {
    $ExistingDiskSize = $vmss.VirtualMachineProfile.StorageProfile.OSDisk.DiskSizeGB
    Write-Error "Existing Size is $ExistingDiskSize and can't be reduced to $Size."
    return
  }

  if ($vmss.VirtualMachineProfile.StorageProfile.OsDisk.ManagedDisk) {

    Write-Host "Changing OS Disk Size on the Scale Set Model"
    $vmss.VirtualMachineProfile.StorageProfile.OSDisk.DiskSizeGB = $Size
    Update-AzVmss -ResourceGroupName $ResourceGroupName -Name $Name -VirtualMachineScaleSet $vmss

    $instances = Get-AzVmss -ResourceGroupName $ResourceGroupName -Name $Name -InstanceView

    For ($i=0; $i -le $instances.VirtualMachine.StatusesSummary[0].Count - 1; $i++) {
      Write-Host "Recycling and Updating Scale Set Instance $i."

      Stop-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $Name -InstanceId $i -Force
      Update-AzVmssInstance -ResourceGroupName $ResourceGroupName -VMScaleSetName $Name -InstanceId $i
      Start-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $Name -InstanceId $i
    }

    Write-Host "OS Disk size change successful."

  }
  else {
    Write-Error "Cannot find VM'"
    return
  }
}

