# Infrastructure as Code - Storage

## Getting Started

1. __Create a Resource Group__

```bash
az group create --location southcentralus --name common
```

```powershell
Connect-AzureRMAccount

$ResourceGroupName = 'common'
$Location = 'southcentralus'
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
```

1. __Modify Template Parameters as desired__

1. __Deploy Template to Resource Group__

```bash
az group deployment create --name iac-storage /
 --template-file azuredeploy.json /
 --parameters azuredeploy.parameters.json /
 --resource-group common
```

```powershell
New-AzureRmResourceGroupDeployment -Name iac-storage `
  -TemplateFile azuredeploy.json `
  -TemplateParameterFile azuredeploy.parameters.json `
  -ResourceGroupName $ResourceGroupName 
```

1. __Deploy Storage Keys to KeyVault__

```powershell
.\scripts\loadKeyVault.ps1 common
```

## Script Orchestrator Deployment

To further automate things but keep a good reusable generic template layer scripts can be used instead.

1. __Deploy Template using PowerShell Scripts__

```powershell
./install.ps1
```

1. __Deploy Template using NPM as a Task Orchestrator

>Note: Do this from the root directory where package.json lives.

```bash
npm run group:common
npm run provision:storage
```