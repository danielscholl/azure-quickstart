#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    init.sh <resourcegroup>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: install.sh <resourcegroup> <vmname>" 1>&2; exit 1; }

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

if [ ! -z $2 ]; then VM_NAME=$2; fi
if [ -z $VM_NAME ]; then
  tput setaf 1; echo 'ERROR: VM_NAME not provided' ; tput sgr0
  usage;
fi

if [ ! -z $3 ]; then SCRIPT=$3; fi
if [ -z $SCRIPT ]; then
  tput setaf 1; echo 'ERROR: SCRIPT not provided' ; tput sgr0
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
tput setaf 2; echo "Deploying Custom Script Extension..." ; tput sgr0
az vm extension set --resource-group ${RESOURCE_GROUP} \
  --vm-name ${VM_NAME} \
  --name CustomScriptExtension \
  --publisher Microsoft.Compute \
  --settings ./${SCRIPT}.json --version 1.9


