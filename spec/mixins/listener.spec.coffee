define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/listener'
], (Oraculum) ->
  'use strict'

  Backbone = Oraculum.get 'Backbone'

  describe 'Listener.Mixin', ->
    view = null

    Oraculum.extend 'View', 'ListenerParent.View',

      initialize: ->
        @model = @__factory().get 'Model'
        @thing1 = @__factory().get 'Model'
        @thing2 = @__factory().get 'Model'
        @collection = @__factory().get 'Collection'

      mixinOptions:
        listen:
          # self
          'ns:a this': 'a1Handler'
          'ns:b self': -> @b1Handler arguments...

          # model
          'change:a model': 'a1Handler'
          'change:b model': 'b1Handler'

          # collection
          'reset collection': 'a1Handler'
          'custom collection': 'b1Handler'

          # mediator
          'ns:a mediator': 'a1Handler'
          'ns:b pubsub': 'b1Handler'

          # properties
          'ns:a thing1': 'a1Handler'
          'ns:b thing2': 'b1Handler'

    Oraculum.extend 'ListenerParent.View', 'ListenerChild.View', {
      mixinOptions:
        listen:
          # self
          'ns:a this': 'a2Handler'
          'ns:b self': -> @b2Handler arguments...

          # model
          'change:a model': 'a2Handler'
          'change:b model': 'b2Handler'

          # collection
          'reset collection': 'a2Handler'
          'custom collection': 'b2Handler'

          # mediator
          'ns:a mediator': 'a2Handler'
          'ns:b pubsub': 'b2Handler'

          # properties
          'ns:a thing1': 'a2Handler'
          'ns:b thing2': 'b2Handler'

      initialize: ->
        @model = @__factory().get 'Model'
        @thing1 = @__factory().get 'Model'
        @thing2 = @__factory().get 'Model'
        @collection = @__factory().get 'Collection'
        @a1Handler = sinon.spy()
        @b1Handler = sinon.spy()
        @a2Handler = sinon.spy()
        @b2Handler = sinon.spy()

    }, mixins: ['Listener.Mixin']

    afterEach ->
      view.__dispose() if Oraculum.verifyTags view

    it 'should bind to own events declaratively', ->
      view = Oraculum.get 'ListenerChild.View'

      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).not.toHaveBeenCalled()
      expect(view.b2Handler).not.toHaveBeenCalled()

      view.trigger 'ns:a'
      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).toHaveBeenCalledOnce()
      expect(view.b2Handler).not.toHaveBeenCalled()

      view.trigger 'ns:b'
      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).toHaveBeenCalledOnce()
      expect(view.b2Handler).toHaveBeenCalledOnce()

    it 'should bind to model events declaratively', ->
      view = Oraculum.get 'ListenerChild.View'

      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.b2Handler).not.toHaveBeenCalled()

      view.model.set 'a', 1
      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).toHaveBeenCalledOnce()
      expect(view.b2Handler).not.toHaveBeenCalled()

      view.model.set 'b', 2
      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).toHaveBeenCalledOnce()
      expect(view.b2Handler).toHaveBeenCalledOnce()

    it 'should bind to collection events declaratively', ->
      view = Oraculum.get 'ListenerChild.View'

      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.b2Handler).not.toHaveBeenCalled()

      view.collection.reset [{a: 1}]
      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).toHaveBeenCalledOnce()
      expect(view.b2Handler).not.toHaveBeenCalled()

      view.collection.trigger 'custom'
      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).toHaveBeenCalledOnce()
      expect(view.b2Handler).toHaveBeenCalledOnce()

    it 'should bind to Backbone events declaratively', ->
      view = Oraculum.get 'ListenerChild.View'

      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).not.toHaveBeenCalled()
      expect(view.b2Handler).not.toHaveBeenCalled()

      Backbone.trigger 'ns:a'
      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).toHaveBeenCalledOnce()
      expect(view.b2Handler).not.toHaveBeenCalled()

      Backbone.trigger 'ns:b'
      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).toHaveBeenCalledOnce()
      expect(view.b2Handler).toHaveBeenCalledOnce()

    it 'should bind to abritrary property\'s events declaratively', ->
      view = Oraculum.get 'ListenerChild.View'

      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).not.toHaveBeenCalled()
      expect(view.b2Handler).not.toHaveBeenCalled()

      view.thing1.trigger 'ns:a'
      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).toHaveBeenCalledOnce()
      expect(view.b2Handler).not.toHaveBeenCalled()

      view.thing2.trigger 'ns:b'
      expect(view.a1Handler).not.toHaveBeenCalled()
      expect(view.b1Handler).not.toHaveBeenCalled()
      expect(view.a2Handler).toHaveBeenCalledOnce()
      expect(view.b2Handler).toHaveBeenCalledOnce()

    it 'should throw an error when corresponding method doesn’t exist', ->
      Oraculum.extend 'View', 'ListenerError1.View', { mixinOptions: listen: {'fail'} }, mixins: ['Listener.Mixin']
      expect(-> view = Oraculum.get 'ListenerError1.View').toThrow()
