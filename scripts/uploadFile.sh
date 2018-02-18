#!/usr/bin/env bash
#
#  Purpose: Sync the Runbooks and DSC folders to containers in a storage account
#  Usage:
#    uploadFile.sh <resourcegroup> <container> <file> <name>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: uploadFile.sh <resourcegroup> <container> <file> <name>" 1>&2; exit 1; }

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

if [ ! -z $2 ]; then CONTAINER_NAME=$2; fi
if [ -z $CONTAINER_NAME ]; then
  tput setaf 1; echo 'ERROR: CONTAINER_NAME not provided' ; tput sgr0
  usage;
fi

if [ ! -z $3 ]; then FILE_NAME=$3; fi
if [ -z FILE_NAME ]; then
  tput setaf 1; echo 'ERROR: FILE_NAME not provided' ; tput sgr0
  usage;
fi

if [ ! -z $4 ]; then BLOB_NAME=$4; fi
if [ -z BLOB_NAME ]; then
  tput setaf 1; echo 'ERROR: BLOB_NAME not provided' ; tput sgr0
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
if [ -d ./scripts ]; then BASE_DIR=$PWD; else BASE_DIR=$(dirname $PWD); fi

tput setaf 2; echo "Creating the $CONTAINER blob container..." ; tput sgr0
STORAGE_ACCOUNT=$(GetStorageAccount $RESOURCE_GROUP)
STORAGE_KEY=$(GetStorageAccountKey $RESOURCE_GROUP $STORAGE_ACCOUNT)
CreateBlobContainer $STORAGE_ACCOUNT $STORAGE_KEY $CONTAINER_NAME
CONNECTION=$(GetStorageConnection $RESOURCE_GROUP $STORAGE_ACCOUNT)
UploadFile $BASE_DIR/$FILE_NAME $CONTAINER_NAME $CONNECTION $BLOB_NAME
