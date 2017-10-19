require('tap').mochaGlobals();
const should = require('should');

const template = require('../iac-automation/azuredeploy.json');
const parameters = require('../iac-automation/azuredeploy.parameters.json');


describe('iac-automation', () => {
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

      it('should have 14 parameters', () => actual.length.should.be.exactly(14));
      it('should have a prefix', () => actual.should.containEql('prefix'));
      it('should have a storageAccountName', () => actual.should.containEql('storageAccountName'));
      it('should have a runbookSasToken', () => actual.should.containEql('runbookSasToken'));
      it('should have a dscSasToken', () => actual.should.containEql('dscSasToken'));
      it('should have a omsWorkspaceRegion', () => actual.should.containEql('omsWorkspaceRegion'));
      it('should have a automationRegion', () => actual.should.containEql('automationRegion'));
      it('should have a subscriptionAdmin', () => actual.should.containEql('subscriptionAdmin'));
      it('should have a subscriptionPassword', () => actual.should.containEql('subscriptionPassword'));
      it('should have a domainName', () => actual.should.containEql('domainName'));
      it('should have a domainAdmin', () => actual.should.containEql('domainAdmin'));
      it('should have a domainPassword', () => actual.should.containEql('domainPassword'));
      it('should have a jobGuid1', () => actual.should.containEql('jobGuid1'));
      it('should have a jobGuid2', () => actual.should.containEql('jobGuid2'));
      it('should have a jobGuid3', () => actual.should.containEql('jobGuid3'));
    });

    context('creates the expected resources', () => {
      const actual = template.resources.map(resource => resource.type);

      it('should have 3 resources', () => actual.length.should.be.exactly(3));
      it('should create Microsoft.OperationalInsights/workspaces', () => actual.should.containEql('Microsoft.OperationalInsights/workspaces'));
      it('should create Microsoft.OperationsManagement/solutions', () => actual.should.containEql('Microsoft.OperationsManagement/solutions'));
      it('should create Microsoft.Automation/automationAccounts', () => actual.should.containEql('Microsoft.Automation/automationAccounts'));
    });

    context('has expected output', () => {
      it('should define omsWorkspace', () => template.outputs.omsWorkspace);
      it('should define omsWorkspace id', () => template.outputs.omsWorkspace.value.id);
      it('should define omsWorkspace name', () => template.outputs.omsWorkspace.value.name);
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
