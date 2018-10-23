# Infrastructure as Code - Scale Set

## Script Orchestrator Deployment

To further automate things but keep a good reusable generic template layer scripts can be used instead.

1. __Deploy Template using Bash Scripts__

```bash
./install.sh
```

## Resize Root Disk Process


```powershell
az disk list `
    --resource-group $env:AZURE_IAAS_GROUP `
    --query '[*].{Name:name,Gb:diskSizeGb,Tier:accountType}' `
    --output table

$Disk_Name=$(az disk list --resource-group $env:AZURE_IAAS_GROUP --query [].name -otsv)

# Step 1 Deallocate the Machine
az vm deallocate --resource-group $env:AZURE_IAAS_GROUP --name $env:AZURE_IAAS_GROUP-jump

# Step 2 Update the Disk
az disk update --name $Disk_Name --resource-group $env:AZURE_IAAS_GROUP --size-gb 128

# Step 3 Start the Machine
az vm start --resource-group $env:AZURE_IAAS_GROUP --name $env:AZURE_IAAS_GROUP-jump
```
