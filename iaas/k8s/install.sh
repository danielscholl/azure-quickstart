#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    init.sh <resourcegroup> <commongroup>


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

#######################################
## Retrieving Parameter Information  ##
#######################################
tput setaf 2; echo "Gathering information for Diagnostics Storage Account..." ; tput sgr0
STORAGE_ACCOUNT=$(GetStorageAccount $COMMON_GROUP)
echo $STORAGE_ACCOUNT

tput setaf 2; echo "Gathering information for Key Vault..." ; tput sgr0
KEY_VAULT=$(GetKeyVault $COMMON_GROUP)
echo $KEY_VAULT

tput setaf 2; echo "Gathering information for Network..." ; tput sgr0
NETWORK=$(GetNetwork $COMMON_GROUP)
echo $NETWORK


if [ -d ./scripts ]; then BASE_DIR=$PWD; else BASE_DIR=$(dirname $PWD); fi

az acs create --name=myk8sCluster \
  --orchestrator-type=kubernetes \
  --windows --generate-ssh-keys \
  --admin-username azureuser --admin-password Password1! \
  --resource-group $RESOURCE_GROUP
