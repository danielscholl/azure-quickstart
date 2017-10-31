#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    init.sh <resourcegroup>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: init.sh <resourcegroup> <commongroup>" 1>&2; exit 1; }

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


###############################
## Azure Intialize           ##
###############################
tput setaf 2; echo 'Logging in and setting subscription...' ; tput sgr0
az account set --subscription ${AZURE_SUBSCRIPTION}

##############################
## Deploy Template          ##
##############################
tput setaf 2; echo "Gathering information for Diagnostics Storage Account..." ; tput sgr0
STORAGE_ACCOUNT=$(GetStorageAccount $COMMON_GROUP)
STORAGE_ACCOUNT_KEY=$(GetStorageAccountKey $COMMON_GROUP $STORAGE_ACCOUNT)

PARAMS="diagnosticsStorageName=$STORAGE_ACCOUNT diagnosticsStorageKey=$STORAGE_ACCOUNT_KEY"
echo $PARAMS

if [ -d ./scripts ]; then BASE_DIR=$PWD; else BASE_DIR=$(dirname $PWD); fi

az group deployment create \
  --template-file $BASE_DIR/iac-databaseVM/azuredeploy.json \
  --parameters $BASE_DIR/iac-databaseVM/azuredeploy.parameters.json \
  --parameters $PARAMS\
  --resource-group $RESOURCE_GROUP
