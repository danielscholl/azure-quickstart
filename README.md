# Quick Start Setup

## Setup
Prefix can be modified by changing the value in package.json

## Create Required Resource Groups

- my-common
- my-automation
- my-iaas

```bash
npm run group
```

## Provision Common Storage 
Common Storage is used for diagnostics collection as well as template storage

```bash
npm run provision:storage
```

Upload the templates into the storage container to allow for nested templates.

```powershell
.\scripts\createContainer.ps1 -ResourceGroupName my-common -ContainerName templates

.\scripts\uploadFile.ps1 -ResourceGroupName my-common -QuickStart iac-storage -BlobName deployStorage.json
.\scripts\uploadFile.ps1 -ResourceGroupName my-common -QuickStart iac-keyvault -BlobName deployKeyVault.json
.\scripts\uploadFile.ps1 -ResourceGroupName my-common -QuickStart iac-network -BlobName deployNetwork.json
.\scripts\uploadFile.ps1 -ResourceGroupName my-common -QuickStart iac-functions -BlobName deployFunctions.json
.\scripts\uploadFile.ps1 -ResourceGroupName my-common -QuickStart iac-automation -BlobName deployAutomation.json
.\scripts\uploadFile.ps1 -ResourceGroupName my-common -QuickStart iac-singleVM -BlobName deploySingleVM.json
.\scripts\uploadFile.ps1 -ResourceGroupName my-common -QuickStart iac-publicVM -BlobName deployPublicVM.json
.\scripts\uploadFile.ps1 -ResourceGroupName my-common -QuickStart ext-omsMonitor -BlobName deployOMSExtension.json
.\scripts\uploadFile.ps1 -ResourceGroupName my-common -QuickStart ext-dscNode -BlobName deployDSCExtension.json
```

## Provision Common KeyVault
Common KeyVault is used to store sensitive information that can be further used in Templates

Required Attribute is a servicePrincipalId used to access keyvault. 

```bash
az ad user show --upn user@email.com --query objectId -otsv
npm run provision:keyvault
```

Load the Common Storage Keys into the Keyvault.  _(powershell script)_

```powershell
.\scripts\loadKeyVault.ps1 -ResourceGroupName my-common
```

## Provision Common Network
Common Network is a 4 Subnet Network

```bash
npm run provision:network
```

## Provision Azure AD Domain Services
Azure Active Directory Domain Services is used for Domain Authentication of Servers.  This is a manual step as ADDS for ARM
is a relatively new feature and is still in Preview.

In my-common resource group add Azure AD Domain Services.  (Requires Admin Access to Azure Active Directory)

Once ADDS is provisioned (about 35 minutes) then you must configure DNS server settings for your virtual network. In your ADDS instance
click the configure DNS Servers button and add the two DNS server IP's as Custom DNS Servers in the VNET.


## Provision Function App
Automation Functions provides a Nested Template for GUID Creations

```bash
npm run provision:functions
```

## Provision Automation Account and OMS
Automation Accounts use Runbooks and DSC scripts from a storage container.  Scripts must be loaded into the storage container prior to installing automation.

```bash
npm run sync
```

Required Attributes are an azure subscription login and password used to create the AzureRunAsAccount. 
Required Attribute is the default login and password for local machine login to be stored in the KeyVault.

```bash
npm run provision:automation
```

To upload additional DSC Configurations execut the importDscConfig.ps1 script and supply the required attributes.

```powershell
.\scripts\importDscConfig.ps1 -ResourceGroup my-automation -dscRole DomainController
```

Upload the Local Configuration Management file to configure a server to use the Automation Account as its DSC Pull Server.

```
.\scripts\uploadFile.ps1 -ResourceGroupName my-common -FileName iac-storage -BlobName UpdateLCMforAAPull.zip
```

Other templates use the OMS Id and the OMS Key.  There is not other way to get this information other then manual.


To get the OMS Workspace Id and Key Use the Portal.

1. Go to the Microsoft Operations Management Suite
  - Connected Sources
  - Windows Servers

2. Go to the KeyStore in the Common Resource Group and manually create the Secrets
  - omsId
  - omsKey

## Provision Public Facing Jump Server
JumpServer is deployed with 3 extensions.

1. BGInfo
2. Diagnostics
3. OMS Agent


To get the OMS Workspace Id and Key the portal must be used.

1. Go to the Microsoft Operations Management Suite
  - Connected Sources
  - Windows Servers
