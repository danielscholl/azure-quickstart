const test = require('tap').test;
const uuid = require('uuid');
const {
  exec
} = require('child_process');

const before = test;
const after = test;

const location = 'southcentralus';
const prefix = uuid.v4().substr(0, 5);
const resourceGroupName = `${prefix}-spec-region`;


before('az group create', assert => {
  const command = `az group create \
                    --name ${resourceGroupName} \
                    --location ${location} \
                    --query name -otsv`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
    }

    assert.ok(true, stdout);
    assert.end();
  });
});

test('az group deployment validate iac-storage', assert => {
  const command = `az group deployment validate \
                    --template-file ./iac-storage/azuredeploy.json \
                    --parameters ./iac-storage/azuredeploy.json \
                    --resource-group ${resourceGroupName} \
                    --mode Complete`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
    }

    assert.ok(stdout, 'validation: exit 0');
    assert.end();
  });
});

test('az group deployment validate iac-keyvault', assert => {
  const command = `az group deployment validate \
                    --template-file ./iac-keyvault/azuredeploy.json \
                    --parameters ./iac-keyvault/azuredeploy.json \
                    --resource-group ${resourceGroupName} \
                    --mode Complete`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
    }

    assert.ok(stdout, 'validation: exit 0');
    assert.end();
  });
});

test('az group deployment validate iac-functions', assert => {
  const command = `az group deployment validate \
                    --template-file ./iac-functions/azuredeploy.json \
                    --parameters ./iac-functions/azuredeploy.json \
                    --resource-group ${resourceGroupName} \
                    --mode Complete`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
    }

    assert.ok(stdout, 'validation: exit 0');
    assert.end();
  });
});

test('az group deployment validate iac-network', assert => {
  const command = `az group deployment validate \
                    --template-file ./iac-network/azuredeploy.json \
                    --parameters ./iac-network/azuredeploy.json \
                    --resource-group ${resourceGroupName} \
                    --mode Complete`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
    }

    assert.ok(stdout, 'validation: exit 0');
    assert.end();
  });
});

test('az group deployment validate iac-automation', assert => {
  const command = `az group deployment validate \
                    --template-file ./iac-automation/azuredeploy.json \
                    --parameters ./iac-automation/azuredeploy.json \
                    --resource-group ${resourceGroupName} \
                    --mode Complete`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
    }

    assert.ok(stdout, 'validation: exit 0');
    assert.end();
  });
});

test('az group deployment validate iac-publicVM', assert => {
  const command = `az group deployment validate \
                    --template-file ./iac-publicVM/azuredeploy.json \
                    --parameters ./iac-publicVM/azuredeploy.json \
                    --resource-group ${resourceGroupName} \
                    --mode Complete`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
    }

    assert.ok(stdout, 'validation: exit 0');
    assert.end();
  });
});

test('az group deployment validate iac-devtestlab', assert => {
  const command = `az group deployment validate \
                    --template-file ./iac-devtestlab/azuredeploy.json \
                    --parameters ./iac-devtestlab/azuredeploy.json \
                    --resource-group ${resourceGroupName} \
                    --mode Complete`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
    }

    assert.ok(stdout, 'validation: exit 0');
    assert.end();
  });
});

after('az group delete', assert => {
  const command = `az group delete \
                    --name ${resourceGroupName} \
                    --yes --no-wait`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
    }

    assert.ok(true, `${resourceGroupName} deleted.`);
    assert.end();
  });
});
