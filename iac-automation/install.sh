#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    init.sh <resourcegroup>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: init.sh <resourcegroup> <scriptgroup>" 1>&2; exit 1; }

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
if [ ! -z $2 ]; then SCRIPT_GROUP=$2; fi
if [ -z $SCRIPT_GROUP ]; then
  tput setaf 1; echo 'ERROR: SCRIPT_GROUP not provided' ; tput sgr0
  usage;
fi

###############################
## Azure Intialize           ##
###############################
tput setaf 2; echo 'Logging in and setting subscription...' ; tput sgr0
az account set --subscription ${AZURE_SUBSCRIPTION}

##############################
## SAS Token                ##
##############################
tput setaf 2; echo "Generating a SAS Token for ${CONTAINER}..." ; tput sgr0
STORAGE_ACCOUNT=$(GetStorageAccount $SCRIPT_GROUP)
CONNECTION=$(GetStorageConnection $SCRIPT_GROUP $STORAGE_ACCOUNT)
RUNBOOK_TOKEN=$(CreateSASToken runbooks ${CONNECTION})
DSC_TOKEN=$(CreateSASToken dsc ${CONNECTION})


PARAMS="storageAccountName=$STORAGE_ACCOUNT runbookSasToken=?$RUNBOOK_TOKEN dscSasToken=?$DSC_TOKEN jobGuid1=$(GetUUID) jobGuid2=$(GetUUID) jobGuid3=$(GetUUID)"
echo $PARAMS

if [ -d ./scripts ]; then BASE_DIR=$PWD; else BASE_DIR=$(dirname $PWD); fi

az group deployment create \
  --template-file $BASE_DIR/iac-automation/azuredeploy.json \
  --parameters $BASE_DIR/iac-automation/azuredeploy.parameters.json \
  --parameters $PARAMS\
  --resource-group $RESOURCE_GROUP
