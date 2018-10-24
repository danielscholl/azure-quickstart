#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    init.sh <resourcegroup>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: init.sh <resourcegroup>" 1>&2; exit 1; }

if [ -f ~/.azure/.env ]; then source ~/.azure/.env; fi
if [ -f ../.env ]; then source ../.env; fi
if [ -f ./.env ]; then source ./.env; fi
if [ -f ../scripts/functions.sh ]; then source ../scripts/functions.sh; fi
if [ -f ./scripts/functions.sh ]; then source ./scripts/functions.sh; fi

if [ ! -z $1 ]; then RESOURCE_GROUP=$1; fi
if [ -z $RESOURCE_GROUP ]; then
  RESOURCE_GROUP="iac-vmss"
  #tput setaf 1; echo 'ERROR: RESOURCE_GROUP not provided' ; tput sgr0
  #usage;
fi

###############################
## Azure Intialize           ##
###############################
tput setaf 2; echo 'Logging in and setting subscription...' ; tput sgr0
az account set --subscription ${AZURE_SUBSCRIPTION}

tput setaf 2; echo 'Creating Resource Group...' ; tput sgr0
CreateResourceGroup $RESOURCE_GROUP $AZURE_LOCATION

tput setaf 2; echo 'Accepting Marketplace Terms and Conditions...' ; tput sgr0
PUBLISHER="Canonical"
OFFER="UbuntuServer"
SKU="16.04-LTS"
URN=$(az vm image list --all --publisher $PUBLISHER --offer $OFFER --sku $SKU --query '[0].urn' -otsv)
az vm image accept-terms --urn $URN


##############################
## Deploy Template          ##
##############################
if [ -d ./scripts ]; then BASE_DIR=$PWD; else BASE_DIR=$(dirname $PWD); fi

az group deployment create \
  --template-file $BASE_DIR/iac-vmss/azuredeploy.json \
  --parameters $BASE_DIR/iac-vmss/azuredeploy.parameters.json \
  --resource-group $RESOURCE_GROUP
