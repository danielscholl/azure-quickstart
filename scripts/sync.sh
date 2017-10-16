#!/usr/bin/env bash
#
#  Purpose: Sync the Runbooks and DSC folders to containers in a storage account
#  Usage:
#    sync.sh <resourcegroup> <folder>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: sync.sh <resourcegroup> <folder>" 1>&2; exit 1; }

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

if [ ! -z $2 ]; then CONTAINER=$2; fi
if [ -z $CONTAINER ]; then
  tput setaf 1; echo 'ERROR: FOLDER not provided' ; tput sgr0
  usage;
fi

###############################
## Azure Intialize           ##
###############################
tput setaf 2; echo 'Logging in and setting subscription...' ; tput sgr0
az account set --subscription ${AZURE_SUBSCRIPTION}


##############################
## Folder Sync              ##
##############################
tput setaf 2; echo "Creating the $CONTAINER blob container..." ; tput sgr0
STORAGE_ACCOUNT=$(GetStorageAccount $RESOURCE_GROUP)
CONNECTION=$(GetStorageConnection $RESOURCE_GROUP $STORAGE_ACCOUNT)
CreateBlobContainer $CONTAINER $CONNECTION

if [ -d ./scripts ]; then BASE_DIR=$PWD; else BASE_DIR=$(dirname $PWD); fi
FILES=$BASE_DIR/automation/$CONTAINER/*

for f in $FILES
do
  if [ -f "${f}" ]; then UploadFile $f $CONTAINER $CONNECTION; fi
done
