# Introduction
Infrastructure as Code - Automation

## Setup

Add an alias to generate UUID

```bash
alias uuid="python -c 'import sys,uuid; sys.stdout.write(uuid.uuid4().hex)' | pbcopy && pbpaste && echo"
```

# Getting Started

1. __Create a Resource Group__

```bash
az group create --location southcentralus --name my-automation
```

2. __Modify Template Parameters as desired__

3. __Deploy Template to Resource Group__

```bash
az group deployment create --template-file azuredeploy.json --parameters azuredeploy.parameters.json --resource-group my-automation
```

# Build and Test

1. To manually run the javascript test suite

```bash
npm install
npm test
```
