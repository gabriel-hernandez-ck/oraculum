define [
  'oraculum'
  'oraculum/mixins/disposable'
  'oraculum/models/mixins/sort-by-attribute-direction'
  'oraculum/plugins/tabular/models/mixins/sortable-column'
], (Oraculum) ->
  'use strict'

  describe 'SortableColumn.ModelMixin', ->

    Oraculum.extend 'Model', 'Disposable.SortableColumn.Test.Model', {
    }, mixins: ['Disposable.Mixin']

    Oraculum.extend 'Collection', 'SortableCollection.SortableColumn.Test.Collection', {
      model: 'Disposable.SortableColumn.Test.Model'
    }, mixins: [
      'Disposable.CollectionMixin'
      'SortByAttributeDirection.CollectionMixin'
    ]

    Oraculum.extend 'Model', 'SortableColumn.Test.Model', {}, mixins: [
      'Disposable.Mixin'
      'SortableColumn.ModelMixin'
    ]

    testModel = null
    sortCollection = null

    beforeEach ->
      sortCollection = Oraculum.get 'SortableCollection.SortableColumn.Test.Collection', [
        {attribute: 'a'}
        {attribute: 'b'}
        {attribute: 'c'}
        {attribute: 'd'}
      ]
      testModel = Oraculum.get 'SortableColumn.Test.Model',
        {'attribute'}, {sortCollection}

    afterEach ->
      testModel.dispose()

    it 'should throw if no sortCollection is present', ->
      epicFail = -> testModel = Oraculum.get 'SortableColumn.Test.Model'
      expect(epicFail).toThrow()

    it 'should allow sortCollection to be passed via the constructor', ->
      mixinOptions = testModel.mixinOptions.sortableColumn
      expect(mixinOptions.collection).toBe sortCollection

    it 'should allow sortDirections to be passed via the constructor', ->
      testModel.dispose()
      sortDirections = [1,-1]
      testModel = Oraculum.get 'SortableColumn.Test.Model', {'attribute'},
        {sortCollection, sortDirections}
      mixinOptions = testModel.mixinOptions.sortableColumn
      expect(mixinOptions.directions).toEqual sortDirections

    it 'should resolve sortCollection to an instance from a string', ->
      ctor = Oraculum.getConstructor 'SortableCollection.SortableColumn.Test.Collection'
      testModel = Oraculum.get 'SortableColumn.Test.Model', {'attribute'},
        sortCollection: 'SortableCollection.SortableColumn.Test.Collection'
      expect(testModel._sortableCollection instanceof ctor).toBe true

    it 'should resolve sortCollection to an instance from a function', ->
      instance = Oraculum.get 'SortableCollection.SortableColumn.Test.Collection'
      testModel = Oraculum.get 'SortableColumn.Test.Model', {'attribute'},
        sortCollection: -> instance
      expect(testModel._sortableCollection).toBe instance

    describe 'reactionary behavior', ->

      it 'should track the sortDirection of the current column', (done) ->
        sortCollection = Oraculum.get 'SortableCollection.SortableColumn.Test.Collection'
        testModel = Oraculum.get 'SortableColumn.Test.Model',
          {'attribute'}, {sortCollection}
        sortCollection.addAttributeDirection 'attribute', -1
        setTimeout (->
          expect(testModel.get 'sortDirection').toBe -1
          sortCollection.unsort()
          setTimeout (->
            expect(testModel.has 'sortDirection').toBeFalse()
            done()
          ), 10
        ), 10

    describe 'getNextDirection method', ->

      it 'should return the next available sortDirection in the list', (done) ->
        expect(testModel.getNextDirection()).toBe -1
        sortCollection.addAttributeDirection 'attribute', -1
        setTimeout (->
          expect(testModel.getNextDirection()).toBe 1
          sortCollection.addAttributeDirection 'attribute', 1
          setTimeout (->
            expect(testModel.getNextDirection()).toBe 0
            done()
          ), 10
        ), 10

    describe 'nextDirection method', ->

      it 'should cycle through available sortDirection', ->
        expect(testModel.has 'sortDirection').toBeFalse()
        testModel.nextDirection()
        expect(testModel.get 'sortDirection').toBe -1
        testModel.nextDirection()
        expect(testModel.get 'sortDirection').toBe 1

    describe 'isSorted method', ->

      it 'should return true if the model has a sortDirection attribute', ->
        expect(testModel.isSorted()).toBeFalse()
        testModel.nextDirection()
        expect(testModel.isSorted()).toBeTrue()
