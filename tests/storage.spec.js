require('tap').mochaGlobals();
const should = require('should');

const template = require('../iac-storage/azuredeploy.json');
const parameters = require('../iac-storage/azuredeploy.parameters.json');


describe('iac-storage', () => {
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

      it('should have 2 parameters', () => actual.length.should.be.exactly(2));
      it('should have a prefix', () => actual.should.containEql('prefix'));
      it('should have a storageAccountType', () => actual.should.containEql('storageAccountType'));
    });

    context('creates the expected resources', () => {
      const actual = template.resources.map(resource => resource.type);

      it('should create Microsoft.Storage/storageAccounts', () => actual.should.containEql('Microsoft.Storage/storageAccounts'));
    });

    context('ensures storage encryption', () => {
      const storage = template.resources.find(resource => resource.type === 'Microsoft.Storage/storageAccounts');

      it('should define encryption', () => should.exist(storage.properties.encryption));
      it('should enable encryption', () => storage.properties.encryption.services.blob.enabled.should.eql(true));
    });

    context('has expected output', () => {
      it('should define storageAccount', () => template.outputs.storageAccount);
      it('should define storageAccount id', () => template.outputs.storageAccount.value.id);
      it('should define storageAccount name', () => template.outputs.storageAccount.value.name);
      it('should define storageAccount key', () => template.outputs.storageAccount.value.key);
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
