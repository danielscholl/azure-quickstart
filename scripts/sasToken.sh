#!/usr/bin/env bash
#
#  Purpose: Generate a Storage Account Security Token for a container in a storage account
#  Usage:
#    sasToken.sh <resourcegroup> <container>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: sasToken.sh <resourcegroup> <container>" 1>&2; exit 1; }

if [ -f ~/.azure/.env ]; then source ~/.azure/.env; fi
if [ -f ./.env ]; then source ./.env; fi
if [ -f ./functions.sh ]; then source ./functions.sh; fi
if [ -f ./scripts/functions.sh ]; then source ./scripts/functions.sh; fi


if [ ! -z $1 ]; then RESOURCE_GROUP=$1; fi
if [ -z $RESOURCE_GROUP ]; then
  tput setaf 1; echo 'ERROR: RESOURCE_GROUP not provided' ; tput sgr0
  usage;
fi

if [ ! -z $2 ]; then CONTAINER=$2; fi
if [ -z $CONTAINER ]; then
  tput setaf 1; echo 'ERROR: CONTAINER not provided' ; tput sgr0
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
tput setaf 2; echo 'Generating a SAS Token for ${CONTAINER}...' ; tput sgr0
STORAGE_ACCOUNT=$(GetStorageAccount $RESOURCE_GROUP)
CONNECTION=$(GetStorageConnection $RESOURCE_GROUP $STORAGE_ACCOUNT)
TOKEN=$(CreateSASToken ${CONTAINER} ${CONNECTION})
echo $TOKEN
