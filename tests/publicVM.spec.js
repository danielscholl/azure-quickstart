require('tap').mochaGlobals();
const should = require('should');

const template = require('../iac-publicVM/azuredeploy.json');
const parameters = require('../iac-publicVM/azuredeploy.parameters.json');


describe('iac-publicVM', () => {
  context('template file', () => {
    it('should exist', () => should.exist(template));

    context('has expected properties', () => {
      it('should have property $schema', () => should.exist(template.$schema));
      it('should have property contentVersion', () => should.exist(template.contentVersion));
      it('should have property parameters', () => should.exist(template.parameters));
      it('should have property variables', () => should.exist(template.variables));
      it('should have property resources', () => should.exist(template.resources));
      it('should have property outputs', () => should.exist(template.outputs));
    });

    context('defines the expected parameters', () => {
      const actual = Object.keys(template.parameters);

      it('should have 12 parameters', () => actual.length.should.be.exactly(12));
      it('should have a vmName', () => actual.should.containEql('vmName'));
      it('should have a vmSize', () => actual.should.containEql('vmSize'));
      it('should have a vnet', () => actual.should.containEql('vnet'));
      it('should have a vnetGroup', () => actual.should.containEql('vnetGroup'));
      it('should have a subnet', () => actual.should.containEql('subnet'));
      it('should have a adminUserName', () => actual.should.containEql('adminUserName'));
      it('should have a adminPassword', () => actual.should.containEql('adminPassword'));
      it('should have a WindowsOSVersion', () => actual.should.containEql('WindowsOSVersion'));
      it('should have a storageAccountName', () => actual.should.containEql('storageAccountName'));
      it('should have a remoteAccessACL', () => actual.should.containEql('remoteAccessACL'));
    });

    context('creates the expected resources', () => {
      const actual = template.resources.map(resource => resource.type);

      it('should have 4 resources', () => actual.length.should.be.exactly(4));
      it('should create Microsoft.Network/networkSecurityGroups', () => actual.should.containEql('Microsoft.Network/networkSecurityGroups'));
      it('should create Microsoft.Network/publicIPAddresses', () => actual.should.containEql('Microsoft.Network/publicIPAddresses'));
      it('should create Microsoft.Network/networkInterfaces', () => actual.should.containEql('Microsoft.Network/networkInterfaces'));
      it('should create Microsoft.Compute/virtualMachines', () => actual.should.containEql('Microsoft.Compute/virtualMachines'));
    });

    // context('has expected output', () => {
    //   it('should define storageAccount', () => template.outputs.storageAccount);
    //   it('should define storageAccount id', () => template.outputs.storageAccount.value.id);
    //   it('should define storageAccount name', () => template.outputs.storageAccount.value.name);
    //   it('should define storageAccount key', () => template.outputs.storageAccount.value.key);
    // });
  });

  context('parameters file', (done) => {
    it('should exist', () => should.exist(parameters));

    context('has expected properties', () => {
      it('should define $schema', () => should.exist(parameters.$schema));
      it('should define contentVersion', () => should.exist(parameters.contentVersion));
      it('should define parameters', () => should.exist(parameters.parameters));
    });
  });
});
