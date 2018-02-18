#!/usr/bin/env bash
#
#  Purpose: Generate a Container in a Storage Account
#  Usage:
#    createContainer.sh <resourcegroup> <containername>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: createContainer.sh <resourcegroup> <containername>" 1>&2; exit 1; }

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

if [ ! -z $2 ]; then CONTAINER_NAME=$2; fi
if [ -z $CONTAINER_NAME ]; then
  tput setaf 1; echo 'ERROR: CONTAINER_NAME not provided' ; tput sgr0
  usage;
fi


###############################
## Azure Intialize           ##
###############################
tput setaf 2; echo 'Logging in and setting subscription...' ; tput sgr0
az account set --subscription ${AZURE_SUBSCRIPTION}


####################################
## Storage Account Container      ##
####################################
tput setaf 2; echo 'Creating Container for Storage Account in ResourceGroup ${RESOURCE_GROUP}...' ; tput sgr0

STORAGE_ACCOUNT=$(GetStorageAccount $RESOURCE_GROUP)
STORAGE_KEY=$(GetStorageAccountKey $RESOURCE_GROUP $STORAGE_ACCOUNT)
CreateBlobContainer $STORAGE_ACCOUNT $STORAGE_KEY $CONTAINER_NAME
