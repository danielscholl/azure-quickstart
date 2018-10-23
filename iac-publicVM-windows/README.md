# Introduction
Infrastructure as Code - VirtualMachine

# Getting Started
This Quick Start Deploys a PublicVM onto a network.

1. __Create a Resource Group__
Ensure that a resource group exists to deploy into.

```bash
az group create --location southcentralus --name my-iaas
```

2. __Modify Template Parameters as desired__


3. __Deploy Template to Resource Group__
Run the install script.

```bash
./iac-publicVM/init.sh my-iaas my-commons
```
