define ['oraculum'], (Oraculum) ->
  'use strict'

  testData = [
    {id: 1, number: 1, numeric: '333', string: 'a'}
    {id: 2, number: 1, numeric: '33',  string: 'b'}
    {id: 3, number: 1, numeric: '3',   string: 'c'}
    {id: 4, number: 2, numeric: '222', string: 'b'}
    {id: 5, number: 2, numeric: '22',  string: 'a'}
    {id: 6, number: 2, numeric: '2',   string: 'b'}
    {id: 7, number: 3, numeric: '111', string: 'c'}
    {id: 8, number: 3, numeric: '11',  string: 'b'}
    {id: 9, number: 3, numeric: '1',   string: 'a'}
  ]

  describe 'SortByMultiAttributeDirection.CollectionMixin', ->

    testModel = 'SortByMultiAttributeDirection.CollectionMixin.Model'
    Oraculum.extend 'Model', testModel, {}, mixins: ['Disposable.Mixin']

    testCollection = 'SortByMultiAttributeDirection.CollectionMixin.Collection'
    Oraculum.extend 'Collection', testCollection, {
      model: testModel
      mixinOptions: disposable: disposeModels: true
    }, mixins: [
      'Disposable.CollectionMixin'
      'SortByMultiAttributeDirection.CollectionMixin'
    ]

    collection = null
    beforeEach -> collection = Oraculum.get testCollection, testData
    afterEach -> collection.dispose()

    describe 'mixins', ->
      it 'should use Evented.Mixin', ->
        expect(collection).toUseMixin 'Evented.Mixin'
      it 'should use SortByMultiAttributeDirectionInterface.CollectionMixin', ->
        expect(collection).toUseMixin 'SortByMultiAttributeDirectionInterface.CollectionMixin'

    describe 'reactionary behavior', ->

      sort = null
      beforeEach ->
        sort = sinon.spy collection, 'sort'

      it 'should debounce invoke sort on add, remove, reset, change @sortState', (done) ->
        expect(sort).not.toHaveBeenCalled()
        collection.addAttributeDirection 'number', 1
        setTimeout (->
          expect(sort).toHaveBeenCalledOnce()
          collection.unsort()
          setTimeout (->
            expect(sort).toHaveBeenCalledTwice()
            done()
          ), 20
        ), 20

    describe 'sorting', ->

      # Ascending
      it 'should allow ascending sorting on a single number value', (done) ->
        collection.addAttributeDirection 'number', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [1..9]), 20

      it 'should allow ascending sorting on a single numeric value', (done) ->
        collection.addAttributeDirection 'numeric', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [9,6,3,8,5,2,7,4,1]), 20

      it 'should allow ascending sorting on a single string value', (done) ->
        collection.addAttributeDirection 'string', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [1,5,9,2,4,6,8,3,7]), 20

      # Descending
      it 'should allow descending sorting on a single number value', (done) ->
        collection.addAttributeDirection 'number', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [7,8,9,4,5,6,1,2,3]), 20

      it 'should allow descending sorting on a single numeric value', (done) ->
        collection.addAttributeDirection 'numeric', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [1,4,7,2,5,8,3,6,9]), 20

      it 'should allow descending sorting on a single string value', (done) ->
        collection.addAttributeDirection 'string', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [3,7,2,4,6,8,1,5,9]), 20

      # Ascending/ascending
      it 'should allow ascending/ascending sorting on number/numeric', (done) ->
        collection.addAttributeDirection 'number', -1
        collection.addAttributeDirection 'numeric', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [3,2,1,6,5,4,9,8,7]), 20

      it 'should allow ascending/ascending sorting on number/string', (done) ->
        collection.addAttributeDirection 'number', -1
        collection.addAttributeDirection 'string', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [1,2,3,5,4,6,9,8,7]), 20

      it 'should allow ascending/ascending sorting on numeric/number', (done) ->
        collection.addAttributeDirection 'numeric', -1
        collection.addAttributeDirection 'number', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [9,6,3,8,5,2,7,4,1]), 20

      it 'should allow ascending/ascending sorting on numeric/string', (done) ->
        collection.addAttributeDirection 'numeric', -1
        collection.addAttributeDirection 'string', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [9,6,3,8,5,2,7,4,1]), 20

      it 'should allow ascending/ascending sorting on string/number', (done) ->
        collection.addAttributeDirection 'string', -1
        collection.addAttributeDirection 'number', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [1,5,9,2,4,6,8,3,7]), 20

      it 'should allow ascending/ascending sorting on string/numeric', (done) ->
        collection.addAttributeDirection 'string', -1
        collection.addAttributeDirection 'numeric', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [9,5,1,6,8,2,4,3,7]), 20

      # Descending/descending
      it 'should allow descending/descending sorting on number/numeric', (done) ->
        collection.addAttributeDirection 'number', 1
        collection.addAttributeDirection 'numeric', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [7,8,9,4,5,6,1,2,3]), 20

      it 'should allow descending/descending sorting on number/string', (done) ->
        collection.addAttributeDirection 'number', 1
        collection.addAttributeDirection 'string', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [7,8,9,4,6,5,3,2,1]), 20

      it 'should allow descending/descending sorting on numeric/number', (done) ->
        collection.addAttributeDirection 'numeric', 1
        collection.addAttributeDirection 'number', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [1,4,7,2,5,8,3,6,9]), 20

      it 'should allow descending/descending sorting on numeric/string', (done) ->
        collection.addAttributeDirection 'numeric', 1
        collection.addAttributeDirection 'string', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [1,4,7,2,5,8,3,6,9]), 20

      it 'should allow descending/descending sorting on string/number', (done) ->
        collection.addAttributeDirection 'string', 1
        collection.addAttributeDirection 'number', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [7,3,8,4,6,2,9,5,1]), 20

      it 'should allow descending/descending sorting on string/numeric', (done) ->
        collection.addAttributeDirection 'string', 1
        collection.addAttributeDirection 'numeric', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [7,3,4,2,8,6,1,5,9]), 20

      # Ascending/descending
      it 'should allow ascending/descending sorting on number/numeric', (done) ->
        collection.addAttributeDirection 'number', -1
        collection.addAttributeDirection 'numeric', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [1..9]), 20

      it 'should allow ascending/descending sorting on number/string', (done) ->
        collection.addAttributeDirection 'number', -1
        collection.addAttributeDirection 'string', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [3,2,1,4,6,5,7,8,9]), 20

      it 'should allow ascending/descending sorting on numeric/number', (done) ->
        collection.addAttributeDirection 'numeric', -1
        collection.addAttributeDirection 'number', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [9,6,3,8,5,2,7,4,1]), 20

      it 'should allow ascending/descending sorting on numeric/string', (done) ->
        collection.addAttributeDirection 'numeric', -1
        collection.addAttributeDirection 'string', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [9,6,3,8,5,2,7,4,1]), 20

      it 'should allow ascending/descending sorting on string/number', (done) ->
        collection.addAttributeDirection 'string', -1
        collection.addAttributeDirection 'number', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [9,5,1,8,4,6,2,7,3]), 20

      it 'should allow ascending/descending sorting on string/numeric', (done) ->
        collection.addAttributeDirection 'string', -1
        collection.addAttributeDirection 'numeric', 1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [1,5,9,4,2,8,6,7,3]), 20

      # Descending/ascending
      it 'should allow descending/ascending sorting on number/numeric', (done) ->
        collection.addAttributeDirection 'number', 1
        collection.addAttributeDirection 'numeric', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [9,8,7,6,5,4,3,2,1]), 20

      it 'should allow descending/ascending sorting on number/string', (done) ->
        collection.addAttributeDirection 'number', 1
        collection.addAttributeDirection 'string', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [9,8,7,5,4,6,1,2,3]), 20

      it 'should allow descending/ascending sorting on numeric/number', (done) ->
        collection.addAttributeDirection 'numeric', 1
        collection.addAttributeDirection 'number', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [1,4,7,2,5,8,3,6,9]), 20

      it 'should allow descending/ascending sorting on numeric/string', (done) ->
        collection.addAttributeDirection 'numeric', 1
        collection.addAttributeDirection 'string', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [1,4,7,2,5,8,3,6,9]), 20

      it 'should allow descending/ascending sorting on string/number', (done) ->
        collection.addAttributeDirection 'string', 1
        collection.addAttributeDirection 'number', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [3,7,2,4,6,8,1,5,9]), 20

      it 'should allow descending/ascending sorting on string/numeric', (done) ->
        collection.addAttributeDirection 'string', 1
        collection.addAttributeDirection 'numeric', -1
        setTimeout (-> done expect(collection.pluck 'id').toEqual [3,7,6,8,2,4,9,5,1]), 20

      # We could totally keep going... Literally forever... but this should be "enough"
