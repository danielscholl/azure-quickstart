require('tap').mochaGlobals();
const should = require('should');

const template = require('../iac-keyvault/azuredeploy.json');
const parameters = require('../iac-keyvault/azuredeploy.parameters.json');


describe('iac-keyvault', () => {
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

      it('should have 4 parameters', () => actual.length.should.be.exactly(4));
      it('should have a prefix', () => actual.should.containEql('prefix'));
      it('should have a servicePrincipalAppId', () => actual.should.containEql('servicePrincipalAppId'));
      it('should have a adminUserName', () => actual.should.containEql('adminUserName'));
      it('should have a adminPassword', () => actual.should.containEql('adminPassword'));
    });

    context('creates the expected resources', () => {
      const actual = template.resources.map(resource => resource.type);

      it('should create Microsoft.KeyVault/vaults', () => actual.should.containEql('Microsoft.KeyVault/vaults'));
    });

    context('ensures volume encryption', () => {
      const keyVault = template.resources.find(resource => resource.type === 'Microsoft.KeyVault/vaults');

      it('should define encryption', () => should.exist(keyVault.properties.enabledForVolumeEncryption));
      it('should enable encryption', () => keyVault.properties.enabledForVolumeEncryption.should.eql(true));
    });

    context('loads default secrets', () => {
      const keyVault = template.resources.find(resource => resource.type === 'Microsoft.KeyVault/vaults');

      it('shoud have 2 secrets', () => keyVault.resources.length.should.be.exactly(2));
      it('should define adminUserName Secret', () => should.exist(keyVault.resources.find(item => item.name === 'adminUserName')));
      it('should define adminPassword Secret', () => should.exist(keyVault.resources.find(item => item.name === 'adminPassword')));
    });

    context('has expected output', () => {
      it('should define keyVault', () => should.exist(template.outputs.keyVault));
      it('should define keyVault id', () => should.exist(template.outputs.keyVault.value.id));
    });
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
