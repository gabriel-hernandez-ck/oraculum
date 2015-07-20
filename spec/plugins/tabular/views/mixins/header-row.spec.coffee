define [
  'oraculum'
  'oraculum/mixins/disposable'
  'oraculum/models/mixins/disposable'
  'oraculum/plugins/tabular/views/mixins/row'
], (Oraculum) ->
  'use strict'

  describe 'HeaderRow.ViewMixin', ->

    testCollection = 'Disposable.HeaderRow.ViewMixin.Test.Collection'
    Oraculum.extend 'Collection', testCollection, {
    }, mixins: ['Disposable.CollectionMixin']

    testModel = 'Disposable.HeaderRow.ViewMixin.Test.Model'
    Oraculum.extend 'Model', testModel, {
    }, mixins: ['Disposable.Mixin']

    testView = 'HeaderRow.ViewMixin.Test.View'
    Oraculum.extend 'View', testView, {
      mixinOptions:
        list:
          modelView: null
        disposable:
          disposeAll: true
    }, mixins: [
      'Disposable.Mixin'
      'HeaderRow.ViewMixin'
    ]

    view = null
    model = null
    collection = null

    createView = null
    insertView = null

    beforeEach ->
      model = Oraculum.get testModel, {'attribute'}
      collection = Oraculum.get testCollection
      view = Oraculum.get testView, {model, collection}
      createView = sinon.stub(view, 'createView').returns render: ->
      insertView = sinon.stub(view, 'insertView')
      view.render()

    afterEach ->
      view.dispose()

    it 'should allow headerView to be set on the column', ->
      collection.add { 'attribute', headerView: 'Test.View' }
      expect(createView).toHaveBeenCalledOnce()
      expect(createView.firstCall.args[0]).toImplement view: 'Test.View'

    it 'should allow headerViewOptions to be set on the column', ->
      collection.add { 'attribute', headerView: 'Test.View', headerViewOptions: {'test'} }
      expect(createView).toHaveBeenCalledOnce()
      expect(createView.firstCall.args[0].viewOptions).toImplement {'test'}

    it 'should allow the configured viewOptions to be a function', ->
      view.mixinOptions.list.viewOptions = -> {'test'}
      collection.add { 'attribute', headerView: 'Test.View'}
      expect(createView).toHaveBeenCalledOnce()
      expect(createView.firstCall.args[0].viewOptions).toImplement {'test'}

    it 'should always pass the column in the viewOptions', ->
      collection.add { 'attribute', headerView: 'Test.View', viewOptions: {'test'} }
      expect(createView).toHaveBeenCalledOnce()
      expect(createView.firstCall.args[0].viewOptions).toImplement
        column: collection.models[0]

    it 'should pass the column as model if no model is present', ->
      delete view.model
      collection.add { 'attribute', headerView: 'Test.View', viewOptions: {'test'} }
      expect(createView.firstCall.args[0].viewOptions).toImplement
        model: collection.models[0]

    it 'should throw if no headerView is configured', ->
      epicFail = -> collection.add {'attribute'}
      expect(epicFail).toThrow()
