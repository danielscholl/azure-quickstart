#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    init.sh <resourcegroup> <commongroup> <templatecontainer>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: init.sh <resourcegroup> <commongroup> <templatecontainer>" 1>&2; exit 1; }

if [ -f ~/.azure/.env ]; then source ~/.azure/.env; fi
if [ -f ../.env ]; then source ../.env; fi
if [ -f ./.env ]; then source ./.env; fi
if [ -f ../scripts/functions.sh ]; then source ../scripts/functions.sh; fi
if [ -f ./scripts/functions.sh ]; then source ./scripts/functions.sh; fi

if [ ! -z $1 ]; then RESOURCE_GROUP=$1; fi
if [ -z $RESOURCE_GROUP ]; then
  tput setaf 1; echo 'ERROR: RESOURCE_GROUP not provided' ; tput sgr0
  usage;
fi

if [ ! -z $2 ]; then COMMON_GROUP=$2; fi
if [ -z $COMMON_GROUP ]; then
  tput setaf 1; echo 'ERROR: COMMON_GROUP not provided' ; tput sgr0
  usage;
fi

if [ ! -z $3 ]; then TEMPLATE_CONTAINER=$3; fi
if [ -z $TEMPLATE_CONTAINER ]; then
  tput setaf 1; echo 'ERROR: TEMPLATE_CONTAINER not provided' ; tput sgr0
  usage;
fi


###############################
## Azure Intialize           ##
###############################
tput setaf 2; echo 'Logging in and setting subscription...' ; tput sgr0
az account set --subscription ${AZURE_SUBSCRIPTION}

##############################
## Deploy Template          ##
##############################

#######################################
## Retrieving Parameter Information  ##
#######################################
tput setaf 2; echo "Gathering information for Diagnostics Storage Account..." ; tput sgr0
STORAGE_ACCOUNT=$(GetStorageAccount $COMMON_GROUP)
echo $STORAGE_ACCOUNT

tput setaf 2; echo "Retrieving Connection for Storage Account ${STORAGE_ACCOUNT}..." ; tput sgr0
CONNECTION=$(GetStorageConnection ${COMMON_GROUP} ${STORAGE_ACCOUNT})
echo $CONNECTION

tput setaf 2; echo 'Generating a SAS Token for Container...' ; tput sgr0
TOKEN=$(CreateSASToken ${TEMPLATE_CONTAINER} ${CONNECTION})
echo $TOKEN

tput setaf 2; echo "Gathering information for Key Vault..." ; tput sgr0
KEY_VAULT=$(GetKeyVault $COMMON_GROUP)
echo $KEY_VAULT

tput setaf 2; echo "Gathering information for Network..." ; tput sgr0
NETWORK=$(GetNetwork $COMMON_GROUP)
echo $NETWORK


if [ -d ./scripts ]; then BASE_DIR=$PWD; else BASE_DIR=$(dirname $PWD); fi

az group deployment create \
  --template-file $BASE_DIR/iaas/database/azuredeploy.json \
  --parameters $BASE_DIR/iaas/database/azuredeploy.parameters.json \
  --parameters diagStorage=$STORAGE_ACCOUNT  \
  --parameters keyVaultGroup=$COMMON_GROUP keyVault=$KEY_VAULT \
  --parameters vnetGroup=$COMMON_GROUP vnet=$NETWORK \
  --parameters templateStorage=$STORAGE_ACCOUNT sasToken=?$TOKEN \
  --resource-group $RESOURCE_GROUP
