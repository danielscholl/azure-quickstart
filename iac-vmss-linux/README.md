# Infrastructure as Code - Scale Set

## Script Orchestrator Deployment

To further automate things but keep a good reusable generic template layer scripts can be used instead.

1. __Deploy Template using Bash Scripts__

```bash
./install.sh
```

## Resize Root Disk Process

```powershell
Get-AzVmss -ResourceGroupName $env:AZURE_IAAS_GROUP  -VMScaleSetName $env:AZURE_IAAS_GROUP-vmss -InstanceView
Get-AzVmssVm -ResourceGroupName $env:AZURE_IAAS_GROUP -VMScaleSetName $env:AZURE_IAAS_GROUP-vmss  -InstanceId instanceId -InstanceView


az vmss get-instance-view --resource-group $env:AZURE_IAAS_GROUP --name $env:AZURE_IAAS_GROUP-vmss
az vmss get-instance-view --resource-group $env:AZURE_IAAS_GROUP --name $env:AZURE_IAAS_GROUP-vmss --instance-id 0


# Step 1 Update the Scale Set Model
az vmss update --resource-group $env:AZURE_IAAS_GROUP --name $env:AZURE_IAAS_GROUP-vmss --set virtualMachineProfile.storageProfile.osDisk.diskSizeGB=64

# Step 2 Deallocate the Instance
az vmss deallocate --resource-group $env:AZURE_IAAS_GROUP --name $env:AZURE_IAAS_GROUP-vmss --instance-ids 0

# Step 3 Update the Instance to the lastest Model
az vmss update-instances --resource-group $env:AZURE_IAAS_GROUP --name $env:AZURE_IAAS_GROUP-vmss --instance-ids 0

# Step 4 Start the Instance
az vmss start --resource-group $env:AZURE_IAAS_GROUP --name $env:AZURE_IAAS_GROUP-vmss --instance-ids 0

```
