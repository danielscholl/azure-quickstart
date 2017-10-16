require('tap').mochaGlobals();
const should = require('should');

const template = require('../iac-devtestlab/azuredeploy.json');
const parameters = require('../iac-devtestlab/azuredeploy.parameters.json');

describe('iac-devtestlab', () => {
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

      it('should have 5 parameters', () => actual.length.should.be.exactly(5));
      it('should have a prefix', () => actual.should.containEql('prefix'));
      it('should have a vmName', () => actual.should.containEql('vmName'));
      it('should have a vmSize', () => actual.should.containEql('vmSize'));
      it('should have a userName', () => actual.should.containEql('userName'));
      it('should have a password', () => actual.should.containEql('password'));
    });

    context('creates the expected resources', () => {
      const actual = template.resources.map(resource => resource.type);

      it('should create Microsoft.DevTestLab/labs', () => actual.should.containEql('Microsoft.DevTestLab/labs'));
      it('should create Microsoft.DevTestLab/labs/virtualmachines', () => actual.should.containEql('Microsoft.DevTestLab/labs/virtualmachines'));
    });

    context('configures a virtual network for the lab', () => {
      const lab = template.resources.find(resource => resource.type === 'Microsoft.DevTestLab/labs');
      const actual = lab.resources.map(resource => resource.type);

      it('should create virtualNetworks for the lab', () => actual.should.containEql('virtualNetworks'));
    });

    context('has expected output', () => {
      it('should define lab', () => template.outputs.lab);
      it('should define lab id', () => template.outputs.lab.value.id);
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