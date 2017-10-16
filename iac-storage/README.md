# Introduction
Infrastructure as Code - Storage

# Getting Started

1. __Create a Resource Group__

```bash
az group create --location southcentralus --name my-common
```

2. __Modify Template Parameters as desired__

3. __Deploy Template to Resource Group__

```bash
az group deployment create --template-file azuredeploy.json --parameters azuredeploy.parameters.json --resource-group my-common
```

4. __Deploy Storage Keys to KeyVault__

```powershell
.\scripts\loadKeyVault.ps1 my-common
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

3. Continuous Integration is currently turned on for this project via VSTS and the build and release jobs.

> Note: Deploys to my-common-cd
