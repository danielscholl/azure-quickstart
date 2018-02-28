# Introduction
Infrastructure as Code - Network

# Getting Started

1. __Create Common Resource Goup__

```powershell
Login-AzureRMAccount

$ResourceGroupName = 'my-common'
$Location = 'southcentralus'
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
```

2. __Deploy Network to host ARM Templates__

```powershell
New-AzureRmResourceGroupDeployment -Name iac-network `
  -TemplateFile azuredeploy.json `
  -TemplateParameterFile azuredeploy.parameters.json `
  -ResourceGroupName $ResourceGroupName 
```


# Build and Test

1. To manually run the javascript test suite

```bash
npm install
npm test
```

2. To manually provision the resource

```bash
npm run provision
```
