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
Common Storage is used for diagnostics collection

```bash
npm run provision:storage
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