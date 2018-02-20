# Introduction

Infrastructure as Code - Network VPN Gateway

## Manual ARM Template Deployment

1. __Create Company Resource Goup__

```powershell
Login-AzureRMAccount

$ResourceGroupName = 'common'
$Location = 'southcentralus'
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
```

1. __Modify Template Parameters as desired__

1. __Deploy Template to Resource Group__

```powershell
New-AzureRmResourceGroupDeployment -Name iac-gateway `
  -TemplateFile azuredeploy.json `
  -TemplateParameterFile azuredeploy.parameters.json `
  -ResourceGroupName $ResourceGroupName
```

## Script Orchestrator Deployment

To further automate things but keep a good reusable generic template layer scripts can be used instead.

1. __Deploy Template using PowerShell Scripts__

```powershell
./install.ps1
```
