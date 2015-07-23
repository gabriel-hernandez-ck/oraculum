define ['oraculum'], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'
  _ = Oraculum.get 'underscore'

  describe 'Dispatcher', ->

    # Test controllers
    test1ControllerShow = sinon.stub()
    test1ControllerDispose = sinon.stub()
    Test1Controller = Oraculum.extend 'Controller', 'Dispatcher.Test1.Controller', {
      show: test1ControllerShow
      constructed: -> @dispose = test1ControllerDispose
      redirectToURL: -> @redirectTo '/test/123'
    }, inheritMixins: true
    Test1Controller = Oraculum.getConstructor 'Dispatcher.Test1.Controller'

    test2ControllerShow = sinon.stub()
    test2ControllerDispose = sinon.stub()
    Oraculum.extend 'Controller', 'Dispatcher.Test2.Controller', {
      show: test2ControllerShow
      constructed: -> @dispose = test2ControllerDispose
    }, inheritMixins: true

    # Always reset our env
    params = path = options = stdOptions = null
    route1 = route2 = redirectToURLRoute = redirectToControllerRoute = null
    beforeEach ->
      params = id: _.uniqueId('paramsId')
      path = "test/#{params.id}"
      options = {}
      stdOptions = {forceStartup: false, query: {}}
      route1 = {
        path
        action: 'show'
        controller: 'Dispatcher.Test1.Controller'
      }
      route2 = {
        path
        action: 'show'
        controller: 'Dispatcher.Test2.Controller'
      }
      redirectToURLRoute = {
        path
        action: 'redirectToURL'
        controller: 'Dispatcher.Test1.Controller'
      }
      redirectToControllerRoute = {
        path
        action: 'redirectToController'
        controller: 'Dispatcher.Test1.Controller'
      }

    # Create the instances we will be testing with
    listener = null
    dispatcher = null
    beforeEach ->
      listener = Oraculum.get 'Listener.SpecHelper'
      dispatcher = Oraculum.get 'Dispatcher'
      test1ControllerShow.reset()
      test2ControllerShow.reset()
      test1ControllerDispose.reset()
      test2ControllerDispose.reset()

    afterEach ->
      listener.dispose()
      dispatcher.dispose()

    it 'should use PubSub.Mixin', -> expect(dispatcher).toUseMixin 'PubSub.Mixin'
    it 'should use Evented.Mixin', -> expect(dispatcher).toUseMixin 'Evented.Mixin'
    it 'should use Listener.Mixin', -> expect(dispatcher).toUseMixin 'Listener.Mixin'
    it 'should use Disposable.Mixin', -> expect(dispatcher).toUseMixin 'Disposable.Mixin'

    it 'should dispatch routes to controller actions', ->
      listener.publishEvent 'router:match', route1, params, options
      controller = dispatcher.currentController
      expect(test1ControllerShow).toHaveBeenCalledOnce()
      expect(test1ControllerShow).toHaveBeenCalledOn controller
      expect(test1ControllerShow).toHaveBeenCalledWith params, route1, stdOptions

    it 'should not initialize the same controller if params/query are equal', ->
      listener.publishEvent 'router:match', route1, params, options
      listener.publishEvent 'router:match', route1, params, options
      expect(test1ControllerShow).toHaveBeenCalledOnce()

    it 'should initialize the same controller if params differ', ->
      listener.publishEvent 'router:match', route1, params, options
      expect(test1ControllerShow).toHaveBeenCalledOnce()
      listener.publishEvent 'router:match', route1, {'id'}, options
      expect(test1ControllerShow).toHaveBeenCalledTwice()

    it 'should initialize the same controller if queries differ', ->
      listener.publishEvent 'router:match', route1, params, options
      expect(test1ControllerShow).toHaveBeenCalledOnce()
      listener.publishEvent 'router:match', route1, params, query: {'qs'}
      expect(test1ControllerShow).toHaveBeenCalledTwice()

    it 'should initialize the same controller if forced', ->
      listener.publishEvent 'router:match', route1, params, options
      expect(test1ControllerShow).toHaveBeenCalledOnce()
      listener.publishEvent 'router:match', route1, params, forceStartup: true
      expect(test1ControllerShow).toHaveBeenCalledTwice()

    it 'should cache the controller, action, params, query, and path', ->
      listener.publishEvent 'router:match', route1, params, options
      expect(dispatcher.currentRoute).toEqual route1
      expect(dispatcher.currentQuery).toEqual stdOptions.query
      expect(dispatcher.currentParams).toEqual params
      expect(dispatcher.currentController).toBeInstanceOf Test1Controller

    it 'should cache the previous route', ->
      listener.publishEvent 'router:match', route1, params, options
      listener.publishEvent 'router:match', route2, params, options
      expect(dispatcher.previousRoute).toEqual route1

    it 'should add the previous route to the current route', ->
      listener.publishEvent 'router:match', route1, params, options
      firstRoute = _.extend {params}, dispatcher.currentRoute
      listener.publishEvent 'router:match', route2, params, options
      expect(dispatcher.currentRoute.previous).toEqual firstRoute

    it 'should dispose inactive controllers', ->
      listener.publishEvent 'router:match', route1, params, options
      listener.publishEvent 'router:match', route2, params, options
      expect(test1ControllerDispose).toHaveBeenCalledOnce()
      [callParams, callRoute, callOptions] = test1ControllerDispose.firstCall.args
      expect(callRoute).toImplement route2
      expect(callParams).toEqual params
      expect(callOptions).toEqual stdOptions

    it 'should fire beforeControllerDispose events', ->
      listener.publishEvent 'router:match', route1, params, options
      controller = dispatcher.currentController
      dispatchStub = sinon.stub()
      listener.subscribeEvent 'beforeControllerDispose', dispatchStub
      listener.publishEvent 'router:match', route2, params, options
      expect(dispatchStub).toHaveBeenCalledOnce()
      expect(dispatchStub).toHaveBeenCalledWith controller

    it 'should publish dispatch events', ->
      dispatchStub = sinon.spy()
      listener.subscribeEvent 'dispatcher:dispatch', dispatchStub

      listener.publishEvent 'router:match', route1, params, options
      controller1 = dispatcher.currentController
      expect(dispatchStub).toHaveBeenCalledOnce()
      [c, callParams, callRoute, callOptions] = dispatchStub.firstCall.args
      expect(c).toBe controller1
      expect(callRoute).toImplement route1
      expect(callParams).toEqual params
      expect(callOptions).toEqual stdOptions

      listener.publishEvent 'router:match', route2, params, options
      controller2 = dispatcher.currentController
      expect(dispatchStub).toHaveBeenCalledTwice()
      [c, callParams, callRoute, callOptions] = dispatchStub.secondCall.args
      expect(c).toBe controller2
      expect(callRoute).toImplement route2
      expect(callParams).toEqual params
      expect(callOptions).toEqual stdOptions

    it 'should support redirection in an action', ->
      listener.publishEvent 'router:match', route1, params, options
      listener.subscribeEvent 'dispatcher:dispatch', dispatchStub = sinon.stub()
      listener.provideCallback 'router:route', routeStub = sinon.stub()
      redirectToURL = sinon.spy Test1Controller::, 'redirectToURL'
      listener.publishEvent 'router:match', redirectToURLRoute, params, options
      expect(redirectToURL).toHaveBeenCalledOnce()
      [callParams, callRoute, callOptions] = redirectToURL.firstCall.args
      expect(callParams).toEqual params
      expect(callRoute.previous).toEqual _.extend {params}, route1
      expect(callOptions).toEqual stdOptions
      expect(dispatcher.previousRoute).toEqual route1
      previous = _.extend {params}, route1
      currentRoute = _.extend {previous}, redirectToURLRoute
      expect(dispatcher.currentRoute).toEqual currentRoute
      expect(dispatcher.currentController).toBeInstanceOf Test1Controller
      expect(routeStub).toHaveBeenCalledOnce()
      expect(dispatchStub).not.toHaveBeenCalled()
      expect(test1ControllerDispose).toHaveBeenCalledOnce()

    describe 'beforeAction', ->

      test3ControllerShow = sinon.stub()
      Oraculum.extend 'Controller', 'Dispatcher.Test3.Controller', {
        show: test3ControllerShow
        beforeAction: null
      }, inheritMixins: true

      route3 = null
      beforeEach ->
        test3ControllerShow.reset()
        route3 = {
          path
          action: 'show'
          controller: 'Dispatcher.Test3.Controller'
        }

      test4ControllerShow = sinon.stub()
      test4ControllerBeforeAction = sinon.stub()
      Oraculum.extend 'Controller', 'Dispatcher.Test4.Controller', {
        show: test4ControllerShow
        beforeAction: test4ControllerBeforeAction
      }, inheritMixins: true

      route4 = null
      beforeEach ->
        test4ControllerShow.reset()
        test4ControllerBeforeAction.reset()
        route4 = {
          path
          action: 'show'
          controller: 'Dispatcher.Test4.Controller'
        }

      it 'should execute the target action if there is no beforeAction method', ->
        listener.publishEvent 'router:match', route3, params, options
        expect(test3ControllerShow).toHaveBeenCalledOnce()

      it 'should execute the target action after beforeAction is there is a beforeAction method', ->
        listener.publishEvent 'router:match', route4, params, options
        controller = dispatcher.currentController
        expect(test4ControllerBeforeAction).toHaveBeenCalledOnce()
        expect(test4ControllerBeforeAction).toHaveBeenCalledOn controller
        expect(test4ControllerBeforeAction).toHaveBeenCalledBefore test4ControllerShow
        expect(test4ControllerShow).toHaveBeenCalledOnce()

      it 'should throw an error if a before action method isn’t a function', ->
        Oraculum.extend 'Controller', 'BrokenController', {
          'beforeAction', show: ->
        }, inheritMixins: true
        BrokenController = Oraculum.getConstructor 'BrokenController'
        brokenRoute = {controller: 'BrokenController', action: 'show', path}
        brokenRouteAttempt = -> listener.publishEvent 'router:match', brokenRoute, params, options
        expect(brokenRouteAttempt).toThrow()

      it 'should execute the target action with the same arguments as beforeAction', ->
        listener.publishEvent 'router:match', route4, params, options
        expect(test4ControllerBeforeAction).toHaveBeenCalledOnce()
        expect(test4ControllerShow).toHaveBeenCalledOnce()
        expect(test4ControllerShow.firstCall.args).toEqual test4ControllerBeforeAction.firstCall.args

      describe 'when returning a promise', ->

        test5ControllerPromise = null
        test5ControllerShow = sinon.stub()
        test5ControllerBeforeAction = sinon.stub()
        Oraculum.extend 'Controller', 'Dispatcher.Test5.Controller', {
          show: test5ControllerShow
          beforeAction: test5ControllerBeforeAction
        }, inheritMixins: true

        route5 = null
        beforeEach ->
          test5ControllerShow.reset()
          test5ControllerBeforeAction.reset()
          test5ControllerPromise = $.Deferred()
          test5ControllerBeforeAction.returns test5ControllerPromise
          route5 = {
            path
            action: 'show'
            controller: 'Dispatcher.Test5.Controller'
          }

        test6ControllerPromise = null
        test6ControllerShow = sinon.stub()
        Oraculum.extend 'Controller', 'Dispatcher.Test6.Controller', {
          show: test6ControllerShow
          beforeAction: -> @reuse 'composition', -> test6ControllerPromise
        }, inheritMixins: true

        route6 = null
        beforeEach ->
          test6ControllerShow.reset()
          test6ControllerPromise = $.Deferred()
          route6 = {
            path
            action: 'show'
            controller: 'Dispatcher.Test6.Controller'
          }

        composer = null
        beforeEach -> composer = Oraculum.get 'Composer'
        afterEach -> composer.dispose()

        it 'should wait until the returned promise is resolved before executing the target action', ->
          listener.publishEvent 'router:match', route5, params, options
          expect(test5ControllerBeforeAction).toHaveBeenCalledOnce()
          expect(test5ControllerShow).not.toHaveBeenCalled()
          test5ControllerPromise.resolve()
          expect(test5ControllerShow).toHaveBeenCalledOnce()
          expect(test5ControllerShow.firstCall.args).toEqual test5ControllerBeforeAction.firstCall.args

        it 'should support multiple asynchronous controllers', ->
          test5ControllerPromise.resolve()
          (test = (count) ->
            lastTest = count >= 3
            listener.publishEvent 'router:match', route5, params, options
            expect(test5ControllerBeforeAction).toHaveBeenCalledOnce()
            expect(test5ControllerShow).toHaveBeenCalledOnce()
            test5ControllerBeforeAction.reset()
            test5ControllerShow.reset()
            test(count + 1) if lastTest
          )(0)

        it 'should support promises created in compositions', ->
          listener.publishEvent 'router:match', route6, params, options
          expect(test6ControllerShow).not.toHaveBeenCalled()
          test6ControllerPromise.resolve()
          expect(test6ControllerShow).toHaveBeenCalledOnce()

        it 'should stop dispatching when another controller is started', ->
          # Fire up a controller whose beforeAction returns a promise.
          listener.publishEvent 'router:match', route5, params, options
          expect(test5ControllerBeforeAction).toHaveBeenCalledOnce()
          expect(test5ControllerShow).not.toHaveBeenCalled()

          # Before resolving the promise, fire up another, simple controller.
          listener.publishEvent 'router:match', route1, params, options
          expect(test5ControllerShow).not.toHaveBeenCalled()
          expect(test1ControllerShow).toHaveBeenCalledOnce()
