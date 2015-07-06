define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  describe 'SortByMultiAttributeDirectionInterface.CollectionMixin', ->

    testModel = 'SortByMultiAttributeDirectionInterface.CollectionMixin.Model'
    Oraculum.extend 'Model', testModel, {}, mixins: ['Disposable.Mixin']

    testCollection = 'SortByMultiAttributeDirectionInterface.CollectionMixin.Collection'
    Oraculum.extend 'Collection', testCollection, {
      model: testModel
      mixinOptions:
        sortByMultiAttributeDirection:
          defaults: [{'attribute', direction: 0}]
        disposable:
          disposeModels: true
    }, mixins: [
      'Disposable.CollectionMixin'
      'SortByMultiAttributeDirectionInterface.CollectionMixin'
    ]

    collection = null
    afterEach -> collection?.dispose()

    describe 'mixins', ->
      beforeEach -> collection = Oraculum.get testCollection
      it 'should use Evented.Mixin', -> expect(collection).toUseMixin 'Evented.Mixin'

    describe 'constructor configuration', ->
      it 'should allow the defaults configuration to be extended', ->
        collection = Oraculum.get testCollection, null, sortDefaults: [
          { attribute: 'attribute-1', direction: -1 }
          { attribute: 'attribute1',  direction: 1 }
        ]
        expect(collection.sortState.length).toBe 3
        expect(collection.sortState.get('attribute').get 'direction').toBe 0
        expect(collection.sortState.get('attribute1').get 'direction').toBe 1
        expect(collection.sortState.get('attribute-1').get 'direction').toBe -1

    describe 'reactionary behavior', ->

      sortStateDispose = null
      beforeEach ->
        collection = Oraculum.get testCollection, [{'id'}]
        sortStateDispose = sinon.spy collection.sortState, 'dispose'

      it 'should dispose of the sortState model on dispose', ->
        expect(sortStateDispose).not.toHaveBeenCalled()

        collection.get('id').dispose()
        expect(sortStateDispose).not.toHaveBeenCalled()

        collection.dispose()
        expect(sortStateDispose).toHaveBeenCalledOnce()
        expect(collection.sortState).not.toBeDefined()

    describe 'interface', ->

      collection = null
      beforeEach ->
        collection = Oraculum.get testCollection

      describe '[add|get|remove]AttributeDirection', ->

        it 'should return the direction for the provided attribute', ->
          expect(collection.getAttributeDirection 'attribute').toBe 0
          expect(collection.getAttributeDirection 'nonexistant').toBe 0

        it 'should add/update the direction for the provided attribute', ->
          collection.addAttributeDirection 'attribute', 1
          expect(collection.getAttributeDirection 'attribute').toBe 1
          collection.addAttributeDirection 'attribute1', 1
          expect(collection.getAttributeDirection 'attribute1').toBe 1
          collection.addAttributeDirection 'attribute-1', -1
          expect(collection.getAttributeDirection 'attribute-1').toBe -1

        it 'should remove the direction for the provided attribute', ->
          collection.addAttributeDirection 'attribute', 1
          expect(collection.getAttributeDirection 'attribute').toBe 1
          collection.addAttributeDirection 'attribute'
          expect(collection.getAttributeDirection 'attribute').toBe 0
          collection.addAttributeDirection 'attribute', 1
          expect(collection.getAttributeDirection 'attribute').toBe 1
          collection.removeAttributeDirection 'attribute'
          expect(collection.getAttributeDirection 'attribute').toBe 0

      describe 'unsort', ->
        it 'should remove all sorting', ->
          expect(collection.getAttributeDirection 'attribute').toBe 0
          collection.addAttributeDirection 'attribute', 1
          expect(collection.getAttributeDirection 'attribute').toBe 1
          collection.unsort()
          expect(collection.getAttributeDirection 'attribute').toBe 0
