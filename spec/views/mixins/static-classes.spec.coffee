require [
  'oraculum'
  'oraculum/mixins/disposable'
  'oraculum/views/mixins/static-classes'
], (Oraculum) ->
  'use strict'

  describe 'StaticClasses.ViewMixin', ->

    emptyTestView = 'StaticClasses.ViewMixin.Empty.Test.View'
    Oraculum.extend 'View', emptyTestView, {
    }, mixins: ['Disposable.Mixin', 'StaticClasses.ViewMixin']

    arrayTestView = 'StaticClasses.ViewMixin.Array.Test.View'
    Oraculum.extend 'View', arrayTestView, {
      mixinOptions:
        staticClasses: ['array-class1', 'array-class2']
    }, mixins: ['Disposable.Mixin', 'StaticClasses.ViewMixin']

    stringTestView = 'StaticClasses.ViewMixin.String.Test.View'
    Oraculum.extend 'View', stringTestView, {
      mixinOptions:
        staticClasses: 'string-class1 string-class2'
    }, mixins: ['Disposable.Mixin', 'StaticClasses.ViewMixin']

    view = null

    afterEach ->
      view?.dispose()

    describe 'default type className', ->

      beforeEach ->
        view = Oraculum.get emptyTestView

      it 'should automatically add a css class representing the views definition name', ->
        expect(view.$el).toHaveClass 'static-classes_view-mixin_empty_test_view'

    describe 'mixin array configuration', ->

      beforeEach ->
        view = Oraculum.get arrayTestView

      it 'should automatically add any classes specified in mixinOptions.staticClasses', ->
        expect(view.$el).toHaveClass 'array-class1'
        expect(view.$el).toHaveClass 'array-class2'

    describe 'mixin string configuration', ->

      beforeEach ->
        view = Oraculum.get stringTestView

      it 'should automatically add any classes specified in mixinOptions.staticClasses', ->
        expect(view.$el).toHaveClass 'string-class1'
        expect(view.$el).toHaveClass 'string-class2'
