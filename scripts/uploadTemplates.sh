./scripts/uploadFile.sh my-common templates ./iac-storage/azuredeploy.json deployStorage.json
./scripts/uploadFile.sh my-common templates ./iac-keyvault/azuredeploy.json deployKeyVault.json
./scripts/uploadFile.sh my-common templates ./iac-network/azuredeploy.json deployNetwork.json
./scripts/uploadFile.sh my-common templates ./iac-functions/azuredeploy.json deployFunctions.json
./scripts/uploadFile.sh my-common templates ./iac-automation/azuredeploy.json deployAutomation.json
./scripts/uploadFile.sh my-common templates ./iac-singleVM/azuredeploy.json deploySingleVM.json
./scripts/uploadFile.sh my-common templates ./iac-databaseVM/azuredeploy.json deployDatabaseVM.json
./scripts/uploadFile.sh my-common templates ./iac-publicVM/azuredeploy.json deployPublicVM.json
./scripts/uploadFile.sh my-common templates ./ext-omsMonitor/azuredeploy.json deployOMSExtension.json
./scripts/uploadFile.sh my-common templates ./ext-dscNode/azuredeploy.json deployDSCExtension.json
./scripts/uploadFile.sh my-common templates ./ext-domainJoin/azuredeploy.json deployDomainJoinExtension.json