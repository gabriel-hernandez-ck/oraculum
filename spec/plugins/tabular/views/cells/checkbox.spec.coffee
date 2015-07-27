define [
  'oraculum'
  'oraculum/plugins/tabular/views/cells/checkbox'
], (Oraculum) ->
  'use strict'

  describe 'Checkbox.Cell', ->
    definition = Oraculum.definitions['Checkbox.Cell']
    ctor = definition.constructor

    view = null
    model = null
    column = null

    beforeEach ->
      model = Oraculum.get 'Model',
        attribute1: true
        attribute2: null
      column = Oraculum.get 'Model', {attribute: 'attribute1'}
      view = Oraculum.get 'Checkbox.Cell', {model, column}

    afterEach ->
      view.mixinOptions.disposable.disposeAll = true
      view.dispose()

    it 'should use Cell.ViewMixin', -> expect(view).toUseMixin 'Cell.ViewMixin'
    it 'should use Listener.Mixin', -> expect(view).toUseMixin 'Listener.Mixin'
    it 'should use Disposable.Mixin', -> expect(view).toUseMixin 'Disposable.Mixin'
    it 'should use EventedMethod.Mixin', -> expect(view).toUseMixin 'EventedMethod.Mixin'
    it 'should use HTMLTemplating.ViewMixin', -> expect(view).toUseMixin 'HTMLTemplating.ViewMixin'

    it 'should render a checkbox element', ->
      view.render()
      expect(view.$el).toContainElement 'input[type="checkbox"]'

    it 'should set the checkboxes checked state based on the models target attribute', ->
      view.render()
      expect(view.$el).toContainElement 'input:checked'
      model.set 'attribute1', false
      expect(view.$el).not.toContainElement 'input:checked'

    it 'should set the models target attribute based on the checkboxes checked state', ->
      view.render()
      expect(model.get 'attribute1').toBeTrue()
      view.$('input[type="checkbox"]').prop('checked', false).change()
      expect(model.get 'attribute1').toBeFalse()
      view.$('input[type="checkbox"]').prop('checked', true).change()
      expect(model.get 'attribute1').toBeTrue()

    it 'should continue to function if the columns attribute changes', ->
      view.render()
      expect(view.$el).toContainElement 'input:checked'
      column.set 'attribute', 'attribute2'
      expect(view.$el).not.toContainElement 'input:checked'
      model.set 'attribute2', true
      expect(view.$el).toContainElement 'input:checked'
      view.$('input[type="checkbox"]').prop('checked', false).change()
      expect(model.get 'attribute2').toBeFalse()

