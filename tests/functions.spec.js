require('tap').mochaGlobals();
const should = require('should');

const template = require('../iac-functions/azuredeploy.json');
const parameters = require('../iac-functions/azuredeploy.parameters.json');


describe('iac-functions', () => {
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
      it('should have a storageAccountType', () => actual.should.containEql('storageAccountType'));
      it('should have a repoURL', () => actual.should.containEql('repoURL'));
      it('should have a branch', () => actual.should.containEql('branch'));
    });

    context('creates the expected resources', () => {
      const actual = template.resources.map(resource => resource.type);

      it('should have 3 resources', () => actual.length.should.be.exactly(3));
      it('should create Microsoft.Storage/storageAccounts', () => actual.should.containEql('Microsoft.Storage/storageAccounts'));
      it('should create Microsoft.Web/serverfarms', () => actual.should.containEql('Microsoft.Web/serverfarms'));
      it('should create Microsoft.Web/sites', () => actual.should.containEql('Microsoft.Web/sites'));
    });

    context('ensures storage encryption', () => {
      const storage = template.resources.find(resource => resource.type === 'Microsoft.Storage/storageAccounts');

      it('should define encryption', () => should.exist(storage.properties.encryption));
      it('should enable encryption', () => storage.properties.encryption.services.blob.enabled.should.eql(true));
    });

    context('configures a app service plane', () => {
      const appPlan = template.resources.find(resource => resource.type === 'Microsoft.Web/serverfarms');

      it('should use a free plan', () => appPlan.sku.tier.should.eql('Dynamic'));
    });

    context('syncs from source control', () => {
      const actual = template.resources.find(resource => resource.type === 'Microsoft.Web/sites');
      const siteResource = actual.resources.find(resource => resource.type === 'sourcecontrols');

      it('should define a sourcecontrols resource', () => siteResource.type.should.eql('sourcecontrols'));

    });

    context('has expected output', () => {
      it('should define storageAccount', () => template.outputs.storageAccount);
      it('should define storageAccount id', () => template.outputs.storageAccount.value.id);
      it('should define storageAccount name', () => template.outputs.storageAccount.value.name);
      it('should define storageAccount key', () => template.outputs.storageAccount.value.key);
      it('should define functionApp', () => should.exist(template.outputs.functionApp));
      it('should define functionApp url', () => should.exist(template.outputs.functionApp.value.url));
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
