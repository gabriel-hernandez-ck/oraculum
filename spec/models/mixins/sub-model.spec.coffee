define [
  'oraculum'
  'oraculum/libs'
  'oraculum/models/mixins/sub-model'
  'oraculum/mixins/disposable'
  'oraculum/models/mixins/disposable'
], (oraculum) ->
  'use strict'

  _ = oraculum.get 'underscore'

  describe 'Submodel.ModelMixin', ->

    oraculum.extend 'Model', 'Vanilla.Submodel.Test.Model', {
    }, mixins: ['Disposable.Mixin']

    oraculum.extend 'Collection', 'Vanilla.Submodel.Test.Collection', {
    }, mixins: ['Disposable.CollectionMixin']

    oraculum.extend 'Model', 'Submodel.Test.Model', {
      mixinOptions:
        submodels:
          setModel:
            model: 'Vanilla.Submodel.Test.Model'
          defaultModel:
            model: 'Vanilla.Submodel.Test.Model'
            default: true
          silentModel:
            model: 'Vanilla.Submodel.Test.Model'
            setOptions:
              silent: true
          fetchCollection:
            model: 'Collection'

    }, mixins: [
      'Disposable.Mixin'
      'Submodel.ModelMixin'
    ]

    model = null
    VanillaModel = oraculum.getConstructor 'Vanilla.Submodel.Test.Model'
    VanillaCollection = oraculum.getConstructor 'Vanilla.Submodel.Test.Collection'

    beforeEach ->
      model = oraculum.get 'Submodel.Test.Model', null,
        submodels:
          ctorModel:
            model: 'Vanilla.Submodel.Test.Model'

    afterEach ->
      model.dispose()

    it 'should allow submodels to be configured via the constructor', ->
      model.set 'ctorModel', {'name'}
      expect(model.get('ctorModel') instanceof VanillaModel).toBe true
      expect(model.get('ctorModel').get 'name').toBe 'name'

    it 'should contain any default submodels', ->
      expect(model.has 'setModel').toBe false
      expect(model.has 'silentModel').toBe false
      expect(model.get('defaultModel') instanceof VanillaModel).toBe true
      expect(model.has 'fetchCollection').toBe false

    it 'should allow setting a submodels attributes via the set interface', ->
      model.set 'setModel', {'name'}
      setModel = model.get 'setModel'
      expect(setModel instanceof VanillaModel).toBe true
      expect(setModel.get 'name').toBe 'name'

      model.set 'setModel', {'type'}
      expect(setModel.get 'type').toBe 'type'
      expect(model.get 'setModel').toBe setModel

      model.set 'noModel', {'name'}
      expect(model.get 'noModel').toEqual {'name'}

    it 'should use the configured setOptions when setting a model', ->
      silentStub = sinon.stub()
      model.on 'silentModel:change:name', silentStub
      model.set 'silentModel', {'name'}
      expect(silentStub).not.toHaveBeenCalled()

    it 'should override setOptions with local options', ->
      silentStub = sinon.stub()
      model.on 'silentModel:change:name', silentStub
      model.set 'silentModel', {'name'}, silent: false
      expect(silentStub).toHaveBeenCalled()

    it 'should allow submodels to be unset', ->
      model.unset 'defaultModel'
      expect(model.has 'defaultModel').toBe false

    it 'should dispose unset submodels', ->
      defaultModel = model.get 'defaultModel'
      model.unset 'defaultModel'
      expect(defaultModel.disposed).toBe true

    it 'should not dispose unset submodels if options.keep is true', ->
      defaultModel = model.get 'defaultModel'
      model.unset 'defaultModel', keep: true
      expect(defaultModel.disposed).toBeUndefined()
