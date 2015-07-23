define [
  'oraculum'
  'oraculum/mixins/disposable'
  'oraculum/views/mixins/html-templating'
  'oraculum/views/mixins/dom-property-binding'
], (Oraculum) ->
  'use strict'

  describe 'DOMPropertyBinding.ViewMixin', ->

    Oraculum.extend 'View', 'DOMPropertyBinding.Test.View', {
      mixinOptions: domPropertyBinding: {'placeholder'}
    }, mixins: [
      'Disposable.Mixin'
      'HTMLTemplating.ViewMixin'
      'DOMPropertyBinding.ViewMixin'
    ]

    view = null
    afterEach -> view?.dispose()

    describe 'mixin configuration', ->

      beforeEach -> view = Oraculum.get 'DOMPropertyBinding.Test.View'

      it 'should use Evented.Mixin', ->
        expect(view).toUseMixin 'Evented.Mixin'

      it 'should use EventedMethod.Mixin', ->
        expect(view).toUseMixin 'EventedMethod.Mixin'

    describe 'mixin initialization', ->

      it 'should read placeholder at construction', ->
        view = Oraculum.get 'DOMPropertyBinding.Test.View', placeholder: 'somethingElse'
        expect(view.mixinOptions.domPropertyBinding.placeholder).toBe 'somethingElse'

    describe 'Model binding', ->

      model = null
      beforeEach -> model = Oraculum.get 'Model', {'attribute'}
      afterEach -> model.__dispose()

      it 'should bind model attributes to an element', ->
        template = '<div class="test" data-prop="model" data-prop-attr="attribute"/>'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {model, template}
        expect(view.$ '.test').not.toContainText 'attribute'
        view.render()
        expect(view.$ '.test').toContainText 'attribute'
        model.set 'attribute', 'somethingElse'
        expect(view.$ '.test').toContainText 'somethingElse'

      it 'should allow alternate dom manipulation methods', ->
        template = '<input type="text" class="test" data-prop="model" data-prop-attr="attribute" data-prop-method="val">'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {model, template}
        expect(view.$ '.test').not.toHaveValue 'attribute'
        view.render()
        expect(view.$ '.test').toHaveValue 'attribute'
        model.set 'attribute', 'somethingElse'
        expect(view.$ '.test').toHaveValue 'somethingElse'

      it 'should respect custom event listeners', ->
        template = '<div class="test" data-prop="model" data-prop-attr="attribute" data-prop-events="customEvent1 customEvent2"/>'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {model, template}
        expect(view.$ '.test').not.toContainText 'attribute'

        view.render()
        expect(view.$ '.test').toContainText 'attribute'

        model.set 'attribute', 'somethingElse'
        expect(view.$ '.test').toContainText 'attribute'

        model.trigger 'customEvent1'
        expect(view.$ '.test').toContainText 'somethingElse'

        model.set 'attribute', 'somethingNew'
        expect(view.$ '.test').toContainText 'somethingElse'

        model.trigger 'customEvent2'
        expect(view.$ '.test').toContainText 'somethingNew'

      it 'should allow empty (no) event listeners', ->
        template = '<div class="test" data-prop="model" data-prop-attr="attribute" data-prop-events=""/>'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {model, template}
        expect(view.$ '.test').not.toContainText 'attribute'
        view.render()
        expect(view.$ '.test').toContainText 'attribute'
        model.set 'attribute', 'somethingElse'
        expect(view.$ '.test').toContainText 'attribute'
        model.set 'attribute', 'somethingNew'
        expect(view.$ '.test').toContainText 'attribute'

    describe 'Collection binding', ->

      collection = null
      beforeEach ->
        collection = Oraculum.get 'Collection', [
          {id: 'one'}
          {id: 'two'}
          {id: 'three'}
        ]

      afterEach ->
        collection.__dispose()

      it 'should bind collection attributes to an element', ->
        template = '<div class="test" data-prop="collection" data-prop-attr="length"/>'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {collection, template}
        expect(view.$ '.test').not.toContainText '3'
        view.render()
        expect(view.$ '.test').toContainText '3'
        collection.reset()
        expect(view.$ '.test').toContainText '0'

      it 'should bind collection model attributes to an element', ->
        template = '<div class="test" data-prop="collection" data-prop-attr="models.0.id"/>'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {collection, template}
        expect(view.$ '.test').not.toContainText 'one'
        view.render()
        expect(view.$ '.test').toContainText 'one'
        collection.reset [{id:'four'}]
        expect(view.$ '.test').toContainText 'four'

    describe 'Object binding', ->

      it 'should be able to resolve a property on an object', ->
        template = '<div class="test" data-prop="someObject" data-prop-attr="some.property"/>'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {template}
        view.someObject = someObject = some: {'property'}
        expect(view.$ '.test').not.toContainText 'property'

        view.render()
        expect(view.$ '.test').toContainText 'property'

        someObject.some.property = 'otherProperty'
        expect(view.$ '.test').toContainText 'property'

        view.render()
        expect(view.$ '.test').toContainText 'otherProperty'

      it 'should be able to resolve a function on an object', ->
        template = '<div class="test" data-prop="someObject" data-prop-attr="some.function"/>'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {template}
        view.someObject = someObject = some: function: -> 'result'
        expect(view.$ '.test').not.toContainText 'result'

        view.render()
        expect(view.$ '.test').toContainText 'result'

        someObject.some.function = -> 'otherResult'
        expect(view.$ '.test').toContainText 'result'

        view.render()
        expect(view.$ '.test').toContainText 'otherResult'

      it 'should be able to resolve a property on an array', ->
        template = '<div class="test" data-prop="someArray" data-prop-attr="1.2"/>'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {template}
        view.someArray = someArray = [null,[null,null,'value',null],null]
        expect(view.$ '.test').not.toContainText 'value'

        view.render()
        expect(view.$ '.test').toContainText 'value'

        someArray[1][2] = 'otherValue'
        expect(view.$ '.test').toContainText 'value'

        view.render()
        expect(view.$ '.test').toContainText 'otherValue'

    describe 'error conditions', ->

      it 'should throw an error if a bound property does not exist', ->
        template = '<div class="test" data-prop="nonexistant" data-prop-attr="nonexistant"/>'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {template}
        expect(-> view.render()).toThrow()

      it 'should render a placeholder when a property\'s attribute is nullish', ->
        template = '<div class="test" data-prop="someObject" data-prop-attr="nonexistant"/>'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {template}
        view.someObject = someObject = {}
        expect(view.$ '.test').not.toContainText 'placeholder'

        view.render()
        expect(view.$ '.test').toContainText 'placeholder'

        view.mixinOptions.domPropertyBinding.placeholder = 'otherPlaceholder'
        expect(view.$ '.test').toContainText 'placeholder'

        view.render()
        expect(view.$ '.test').toContainText 'otherPlaceholder'

      it 'should not throw if rendered after the initial render', ->
        template = '<div data-prop="model" data-prop-attr="attribute"/>'
        view = Oraculum.get 'DOMPropertyBinding.Test.View', {model: {'attribute'}, template}
        expect(-> view.render()).not.toThrow()
        expect(-> view.render()).not.toThrow()
        expect(-> view.render()).not.toThrow()
        expect(-> view.render()).not.toThrow()
