#!/usr/bin/env bash
#
#  Purpose: Generate a Storage Account Security Token for a container in a storage account
#  Usage:
#    loadKeyVault.sh <resourcegroup>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: loadKeyVault.sh <resourcegroup>" 1>&2; exit 1; }

if [ -f ~/.azure/.env ]; then source ~/.azure/.env; fi
if [ -f ./.env ]; then source ./.env; fi
if [ -f ../.env ]; then source ../.env; fi
if [ -f ./functions.sh ]; then source ./functions.sh; fi
if [ -f ./scripts/functions.sh ]; then source ./scripts/functions.sh; fi


if [ ! -z $1 ]; then RESOURCE_GROUP=$1; fi
if [ -z $RESOURCE_GROUP ]; then
  tput setaf 1; echo 'ERROR: RESOURCE_GROUP not provided' ; tput sgr0
  usage;
fi


###############################
## Azure Intialize           ##
###############################
tput setaf 2; echo 'Logging in and setting subscription...' ; tput sgr0
az account set --subscription ${AZURE_SUBSCRIPTION}


####################################
## Storage Account Keys to Vault  ##
####################################
tput setaf 2; echo 'Locating Storage Account in ResourceGroup ${RESOURCE_GROUP}...' ; tput sgr0

STORAGE_ACCOUNT=$(GetStorageAccount $RESOURCE_GROUP)
STORAGE_ACCOUNT_KEY=$(GetStorageAccountKey $RESOURCE_GROUP $STORAGE_ACCOUNT)
echo $STORAGE_ACCOUNT_KEY

KEY_VAULT=$(GetKeyVault $RESOURCE_GROUP)
SECRET=$(AddKeyToVault $KEY_VAULT diagPrimaryKey $STORAGE_ACCOUNT_KEY)
