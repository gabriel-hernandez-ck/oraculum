define ['oraculum'], (Oraculum) ->
  'use strict'

  Backbone = Oraculum.get 'Backbone'

  describe 'Controller', ->
    controller = null
    beforeEach -> controller = Oraculum.get 'Controller'
    afterEach -> controller.dispose()

    it 'should use PubSub.Mixin', -> expect(controller).toUseMixin 'PubSub.Mixin'
    it 'should use Evented.Mixin', -> expect(controller).toUseMixin 'Evented.Mixin'
    it 'should use Disposable.Mixin', -> expect(controller).toUseMixin 'Disposable.Mixin'
    it 'should use CallbackDelegate.Mixin', -> expect(controller).toUseMixin 'CallbackDelegate.Mixin'

    it 'should implement Backbone.Events', ->
      expect(controller).toImplement Backbone.Events

    describe 'redirectTo interface', ->
      options = {}
      pathSpec = 'redirect-target/123'
      listener = null
      routeCallback = null

      beforeEach ->
        listener = Oraculum.get 'Listener.SpecHelper'
        listener.provideCallback 'router:route', routeCallback = sinon.stub()
        controller.redirectTo pathSpec, options

      afterEach ->
        listener.dispose()

      it 'should mark the controller as redirected', ->
        expect(controller.redirected).toBeTrue()

      it 'should notify the router of a route request', ->
        expect(routeCallback).toHaveBeenCalledOnce()
        expect(routeCallback).toHaveBeenCalledWith pathSpec, options

    describe 'adjustTitle interface', ->
      listener = null
      titleCallback = null

      beforeEach ->
        listener = Oraculum.get 'Listener.SpecHelper'
        listener.subscribeEvent '!adjustTitle', titleCallback = sinon.stub()
        controller.adjustTitle 'newTitle'

      afterEach ->
        listener.dispose()

      it 'should publish an `!adjustTitle` event', ->
        expect(titleCallback).toHaveBeenCalledOnce()
        expect(titleCallback).toHaveBeenCalledWith 'newTitle'

    describe 'reuse interface', ->
      listener = null
      composeCallback = null
      retrieveCallback = null

      beforeEach ->
        listener = Oraculum.get 'Listener.SpecHelper'
        listener.provideCallback 'composer:compose', composeCallback = sinon.stub()
        listener.provideCallback 'composer:retrieve', retrieveCallback = sinon.stub()

      afterEach ->
        listener.dispose()

      it 'should notify the composer of a retrieval request if called with only one argument', ->
        controller.reuse 'testInstance'
        expect(retrieveCallback).toHaveBeenCalledOnce()
        expect(retrieveCallback).toHaveBeenCalledWith 'testInstance'

      it 'should notify the composer of a composition request if called with more than one argument', ->
        controller.reuse 'testInstance', 'SomeDefinition', options = {}
        expect(composeCallback).toHaveBeenCalledOnce()
        expect(composeCallback).toHaveBeenCalledWith 'testInstance', 'SomeDefinition', options
