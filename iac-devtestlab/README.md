# Introduction
Infrastructure as Code - Developer Lab

# Getting Started

1. __Create a Resource Group__

```bash
az group create --location southcentralus --name my-lab
```

2. __Modify Template Parameters as desired__

3. __Deploy Template to Resource Group__

```bash
az group deployment create --template-file azuredeploy.json --parameters azuredeploy.parameters.json --resource-group my-lab
az group deployment create --template-file virtualmachine.json --parameters azuredeploy.parameters.json --resource-group my-lab
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
