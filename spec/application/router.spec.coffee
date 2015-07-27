define ['oraculum'], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  describe 'Route', ->

  describe 'Router', ->

    router = null
    listener = null
    routerMatch = null
    beforeEach ->
      router = Oraculum.get 'Router', {'randomOption', pushState: false}
      listener = Oraculum.get 'Listener.SpecHelper'
      listener.subscribeEvent 'router:match', routerMatch = sinon.stub()

    afterEach ->
      router.dispose()
      listener.dispose()

    it 'should use PubSub.Mixin', -> expect(router).toUseMixin 'PubSub.Mixin'
    it 'should use Listener.Mixin', -> expect(router).toUseMixin 'Listener.Mixin'
    it 'should use Disposable.Mixin', -> expect(router).toUseMixin 'Disposable.Mixin'
    it 'should use CallbackProvider.Mixin', -> expect(router).toUseMixin 'CallbackProvider.Mixin'

    describe 'interaction with Backbone.History', ->

      it 'should create a Backbone.History instance', ->
        expect(Backbone.history instanceof Backbone.History).toBe true

      it 'should not start Backbone.History immediately', ->
        expect(Backbone.History.started).toBeFalse()

      it 'should set the pushState option on the history object', ->
        router.startHistory()
        expect(Backbone.history.options.pushState).toBe router.options.pushState

      it 'should set the root option on the history object', ->
        router.startHistory()
        expect(Backbone.history.options.root).toBe router.options.root

      it 'should pass the options to the Backbone.History instance', ->
        router.startHistory()
        expect(Backbone.history.options.randomOption).toBe 'randomOption'

      it 'should provide an interface to start Backbone.History', ->
        expect(Backbone.History.started).toBeFalse()
        historyStart = sinon.spy Backbone.history, 'start'
        router.startHistory()
        expect(historyStart).toHaveBeenCalledOnce()
        expect(Backbone.History.started).toBeTrue()

      it 'should provide an interface to stop Backbone.History', ->
        expect(Backbone.History.started).toBeFalse()
        router.startHistory()
        expect(Backbone.History.started).toBeTrue()
        historyStop = sinon.spy Backbone.history, 'stop'
        router.stopHistory()
        expect(historyStop).toHaveBeenCalledOnce()
        expect(Backbone.History.started).toBeFalse()

    describe 'Creating Routes', ->
      Route = Oraculum.getConstructor 'Route'

      it 'should have a match method which returns a route', ->
        route = router.match '', 'null#null'
        expect(route).toBeInstanceOf Route

      it 'should reject reserved controller method names', ->
        for prop in ['constructor', 'initialize', 'redirectTo']
          expect(-> router.match '', "null##{prop}").toThrow()

      it 'should allow specifying controller and action in options', ->
        # Signature: url, 'controller#action', options
        route = router.match 'url', 'controller#action', {}
        expect(route.action).toBe 'action'
        expect(route.controller).toBe 'controller'

        # Signature: url, { controller, action }
        route = router.match 'url', {'controller', 'action'}
        expect(route.action).toBe 'action'
        expect(route.controller).toBe 'controller'

      it 'should throw an exception if invoked with invalid arguments', ->
        expect(-> router.match 'url', {}).toThrow()
        expect(-> router.match 'url', 'null#null', {'controller', 'action'}).toThrow()

      it 'should pass trailing option from Router by default', ->
        route = router.match 'url', 'controller#action'
        expect(route.options.trailing).toBe router.options.trailing

        router.options.trailing = true
        route = router.match 'url', 'controller#action'
        expect(route.options.trailing).toBeTrue()

        route = router.match 'url', 'controller#action', trailing: null
        expect(route.options.trailing).toBe null

    describe 'routing', ->

      it 'should fire a router:match event when a route matches', ->
        router.match '', 'null#null'
        expect(routerMatch).not.toHaveBeenCalled()
        router.route url: '/'
        expect(routerMatch).toHaveBeenCalledOnce()

      it 'should match route names, both default and custom', ->
        router.match 'correct-match1', 'controller#action'
        router.match 'correct-match2', 'null#null', name: 'routeName'
        expect(routerMatch).not.toHaveBeenCalled()
        router.route 'controller#action'
        expect(routerMatch).toHaveBeenCalledOnce()
        router.route 'routeName'
        expect(routerMatch).toHaveBeenCalledTwice()

      it 'should match URLs correctly', ->
        router.match 'correct-match1', 'null#null'
        router.match 'correct-match2', 'null#null'
        expect(routerMatch).not.toHaveBeenCalled()
        router.route url: '/correct-match1'
        expect(routerMatch).toHaveBeenCalledOnce()

      it 'should match configuration objects', ->
        router.match 'correct-match', 'null#null'
        router.match 'correct-match-with-name', 'null#null', name: 'null'
        router.match 'correct-match-with/:named_param', 'null#null', name: 'with-param'
        routed1 = router.route controller: 'null', action: 'null'
        routed2 = router.route name: 'null'
        expect(routerMatch).toHaveBeenCalledTwice()

      describe 'when using a non-root root', ->

        root = '/subdir/'
        subdirRooter = null
        beforeEach ->
          subdirRooter = Oraculum.get 'Router', {'randomOption', root, pushState: false}

        afterEach ->
          subdirRooter.dispose()

        it 'should match correctly when using the root option', ->
          subdirRooter.match 'correct-match1', 'null#null'
          subdirRooter.match 'correct-match2', 'null#null'
          subdirRooter.route url: '/subdir/correct-match1'
          expect(routerMatch).toHaveBeenCalledOnce()

      it 'should match routes in the order they were added', ->
        router.match 'params/:one', 'null#null'
        router.match 'params/:two', 'null#null'
        router.route url: '/params/1'
        expect(routerMatch).toHaveBeenCalledOnce()
        expect(routerMatch.firstCall.args[1]).toEqual one: '1'

      it 'should match in order specified when called by Backbone.History', ->
        router.match 'params/:one', 'null#null'
        router.match 'params/:two', 'null#null'
        router.startHistory()
        Backbone.history.loadUrl '/params/1'
        expect(routerMatch).toHaveBeenCalledOnce()
        expect(routerMatch.firstCall.args[1]).toEqual one: '1'

      it 'should identically match URLs that differ only by trailing slash', ->
        router.match 'url', 'null#null'
        router.route url: 'url/'
        expect(routerMatch).toHaveBeenCalledOnce()
        router.route url: 'url/?'
        expect(routerMatch).toHaveBeenCalledTwice()
        router.route url: 'url/?key=val'
        expect(routerMatch).toHaveBeenCalledThrice()

      it 'should leave trailing slash according to current options', ->
        router.match 'url', 'null#null', trailing: null
        router.route url: 'url/'
        expect(routerMatch.firstCall.args[0]).toEqual
          name: 'null#null'
          path: 'url/'
          query: ''
          action: 'null'
          controller: 'null'

      it 'should remove trailing slash according to current options', ->
        router.match 'url', 'null#null', trailing: false
        router.route url: 'url/'
        expect(routerMatch.firstCall.args[0]).toEqual
          name: 'null#null'
          path: 'url'
          query: ''
          action: 'null'
          controller: 'null'

      it 'should add trailing slash according to current options', ->
        router.match 'url', 'null#null', trailing: true
        router.route url: 'url'
        expect(routerMatch.firstCall.args[0]).toEqual
          name: 'null#null'
          path: 'url/'
          query: ''
          action: 'null'
          controller: 'null'

      it 'should pass the route to the router:match handler', ->
        router.match 'passing-the-route', 'controller#action'
        router.route 'controller#action'
        expect(routerMatch.firstCall.args[0]).toEqual
          name: 'controller#action'
          path: 'passing-the-route'
          query: ''
          action: 'action'
          controller: 'controller'

      it 'should handle optional parameters', ->
        router.match 'items(/missing/:missing)(/present/:present)', 'controller#action'
        router.route url: '/items/present/1'
        expect(routerMatch.firstCall.args[0]).toEqual
          name: 'controller#action'
          path: 'items/present/1'
          query: ''
          action: 'action'
          controller: 'controller'

      it 'should extract named parameters from URL', ->
        router.match 'params/:one/:p_two_123/three', 'null#null'
        router.route url: '/params/123-foo/456-bar/three'
        expect(routerMatch.firstCall.args[1]).toEqual
          one: '123-foo'
          p_two_123: '456-bar'

      it 'should extract named parameters from object', ->
        router.match 'params/:one/:p_two_123/three', 'controller#action'
        router.route 'controller#action', one: '123-foo', p_two_123: '456-bar'
        expect(routerMatch.firstCall.args[1]).toEqual
          one: '123-foo'
          p_two_123: '456-bar'

      it 'should extract non-ascii named parameters', ->
        router.match 'params/:one/:two/:three/:four', 'null#null'
        router.route url: "/params/o_O/*.*/ü~ö~ä/#{encodeURIComponent('éêè')}"
        expect(routerMatch.firstCall.args[1]).toEqual
          one: 'o_O'
          two: '*.*'
          three: 'ü~ö~ä'
          four: encodeURIComponent('éêè')

      it 'should match splat parameters', ->
        router.match 'params/:one/*two', 'null#null'
        router.route url: '/params/123-foo/456-bar/789-qux'
        expect(routerMatch.firstCall.args[1]).toEqual
          one: '123-foo'
          two: '456-bar/789-qux'

      it 'should match splat parameters at the beginning', ->
        router.match 'params/*one/:two', 'null#null'
        router.route url: '/params/123-foo/456-bar/789-qux'
        expect(routerMatch.firstCall.args[1]).toEqual
          one: '123-foo/456-bar'
          two: '789-qux'

      it 'should match splat parameters before a named parameter', ->
        router.match 'params/*one:two', 'null#null'
        router.route url: '/params/123-foo/456-bar/789-qux'
        expect(routerMatch.firstCall.args[1]).toEqual
          one: '123-foo/456-bar/'
          two: '789-qux'

      it 'should match optional named parameters', ->
        router.match 'items/:type(/page/:page)(/min/:min/max/:max)', 'null#null'

        router.route url: '/items/clothing'
        expect(routerMatch.firstCall.args[1]).toEqual
          type: 'clothing'
          page: undefined
          min: undefined
          max: undefined

        router.route url: '/items/clothing/page/5'
        expect(routerMatch.secondCall.args[1]).toEqual
          type: 'clothing'
          page: '5'
          min: undefined
          max: undefined

        router.route url: '/items/clothing/min/10/max/20'
        expect(routerMatch.thirdCall.args[1]).toEqual
          type: 'clothing'
          page: undefined
          min: '10'
          max: '20'

      it 'should match optional splat parameters', ->
        router.match 'items(/*slug)', 'null#null'
        router.route url: '/items'
        expect(routerMatch).toHaveBeenCalledOnce()
        expect(routerMatch.firstCall.args[1]).toEqual slug: undefined
        routed = router.route url: '/items/5-boots'
        expect(routerMatch).toHaveBeenCalledTwice()
        expect(routerMatch.secondCall.args[1]).toEqual slug: '5-boots'

      it 'should pass fixed parameters', ->
        router.match 'fixed-params/:id', 'null#null', params: foo: 'bar'
        router.route url: '/fixed-params/123'
        expect(routerMatch.firstCall.args[1]).toEqual
          id: '123'
          foo: 'bar'

      it 'should not overwrite fixed parameters', ->
        router.match 'conflicting-params/:foo', 'null#null', params: foo: 'bar'
        router.route url: '/conflicting-params/123'
        expect(routerMatch.firstCall.args[1]).toEqual foo: 'bar'

    #   it 'should impose parameter constraints', ->
    #     spy = sinon.spy()
    #     Backbone.on 'router:match', spy
    #     router.match 'constraints/:id', 'controller#action',
    #       constraints:
    #         id: /^\d+$/

    #     expect(-> router.route url: '/constraints/123-foo').toThrow()
    #     expect(-> router.route 'controller#action', id: '123-foo').toThrow()

    #     router.route url: '/constraints/123'
    #     router.route 'controller#action', id: 123
    #     expect(spy).toHaveBeenCalledTwice()

    #     Backbone.off 'router:match', spy

    #   it 'should deny regular expression as pattern', ->
    #     expect(-> router.match /url/, 'null#null').toThrow()

    # describe 'Route Matching', ->

    #   it 'should not initialize when route name has "#"', ->
    #     expect(->
    #       new Route 'params', 'null', 'null', name: 'null#null'
    #     ).toThrow()
    #   it 'should not initialize when using existing controller attr', ->
    #     expect(->
    #       new Route 'params', 'null', 'beforeAction'
    #     ).toThrow()

    #   it 'should compare route value', ->
    #     route = new Route 'params', 'hello', 'world'
    #     expect(route.matches 'hello#world').toBeTrue()
    #     expect(route.matches controller: 'hello', action: 'world').toBeTrue()
    #     expect(route.matches name: 'hello#world').toBeTrue()

    #     expect(route.matches 'hello#worldz').toBeFalse()
    #     expect(route.matches controller: 'hello', action: 'worldz').toBeFalse()
    #     expect(route.matches name: 'hello#worldz').toBeFalse()

    # describe 'Route Reversal', ->

    #   it 'should allow for reversing a route instance to get its url', ->
    #     route = new Route 'params', 'null', 'null'
    #     url = route.reverse()
    #     expect(url).toBe 'params'

    #   it 'should allow for reversing a route instance with object to get its url', ->
    #     route = new Route 'params/:two', 'null', 'null'
    #     url = route.reverse two: 1151
    #     expect(url).toBe 'params/1151'

    #     route = new Route 'params/:two/:one/*other/:another', 'null', 'null'
    #     url = route.reverse
    #       two: 32
    #       one: 156
    #       other: 'someone/out/there'
    #       another: 'meh'
    #     expect(url).toBe 'params/32/156/someone/out/there/meh'

    #   it 'should allow for reversing a route instance with array to get its url', ->
    #     route = new Route 'params/:two', 'null', 'null'
    #     url = route.reverse [1151]
    #     expect(url).toBe 'params/1151'

    #     route = new Route 'params/:two/:one/*other/:another', 'null', 'null'
    #     url = route.reverse [32, 156, 'someone/out/there', 'meh']
    #     expect(url).toBe 'params/32/156/someone/out/there/meh'

    #   it 'should allow for reversing optional route params', ->
    #     route = new Route 'items/:id(/page/:page)(/sort/:sort)', 'null', 'null'
    #     url = route.reverse id: 5, page: 2, sort: 'price'
    #     expect(url).toBe 'items/5/page/2/sort/price'

    #     route = new Route 'items/:id(/page/:page/sort/:sort)', 'null', 'null'
    #     url = route.reverse id: 5, page: 2, sort: 'price'
    #     expect(url).toBe 'items/5/page/2/sort/price'

    #   it 'should allow for reversing a route instance with optional splats', ->
    #     route = new Route 'items/:id(-*slug)', 'null', 'null'
    #     url = route.reverse id: 5, slug: "shirt"
    #     expect(url).toBe 'items/5-shirt'

    #   it 'should handle partial fulfillment of optional portions', ->
    #     route = new Route 'items/:id(/page/:page)(/sort/:sort)', 'null', 'null'
    #     url = route.reverse id: 5, page: 2
    #     expect(url).toBe 'items/5/page/2'

    #     route = new Route 'items/:id(/page/:page/sort/:sort)', 'null', 'null'
    #     url = route.reverse id: 5, page: 2
    #     expect(url).toBe 'items/5'

    #   it 'should handle partial fulfillment of optional splats', ->
    #     route = new Route 'items/:id(-*slug)(/:section)', 'null', 'null'
    #     url = route.reverse id: 5, section: 'comments'
    #     expect(url).toBe 'items/5/comments'
    #     url = route.reverse id: 5, slug: 'boots'
    #     expect(url).toBe 'items/5-boots'
    #     url = route.reverse id: 5, slug: 'boots', section: 'comments'
    #     expect(url).toBe 'items/5-boots/comments'

    #     route = new Route 'items/:id(-*slug/:desc)', 'null', 'null'
    #     url = route.reverse id: 5, slug: 'shirt'
    #     expect(url).toBe 'items/5'
    #     url = route.reverse id: 5, slug: 'shirt', desc: 'brand new'
    #     expect(url).toBe 'items/5-shirt/brand new'

    #   it 'should reject reversals when there are not enough params', ->
    #     route = new Route 'params/:one/:two', 'null', 'null'
    #     expect(route.reverse [1]).toEqual false
    #     expect(route.reverse one: 1).toEqual false
    #     expect(route.reverse two: 2).toEqual false
    #     expect(route.reverse()).toEqual false

    #   it 'should add trailing slash accordingly to current options', ->
    #     route = new Route 'params', 'null', 'null', trailing: true
    #     url = route.reverse()
    #     expect(url).toBe 'params/'

    # describe 'Router reversing', ->
    #   register = ->
    #     router.match 'index', 'null#1', name: 'home'
    #     router.match 'phone/:one', 'null#2', name: 'phonebook'
    #     router.match 'params/:two', 'null#2', name: 'about'
    #     router.match 'fake/:three', 'fake#2', name: 'about'
    #     router.match 'phone/:four', 'null#a'

    #   it 'should allow for registering routes with a name', ->
    #     register()
    #     names = for handler in Backbone.history.handlers
    #       handler.route.name
    #     expect(names).toEqual ['home', 'phonebook', 'about', 'about', 'null#a']

    #   it 'should allow for reversing a route by its default name', ->
    #     register()
    #     url = router.reverse 'null#a', {four: 41}
    #     expect(url).toBe '/phone/41'

    #   it 'should allow for reversing a route by its custom name', ->
    #     register()
    #     url = router.reverse 'phonebook', one: 145
    #     expect(url).toBe '/phone/145'

    #     expect(-> router.reverse 'missing', one: 145).toThrow()

    #   it 'should report the given criteria if reversal fails', ->
    #     register()
    #     expect(-> router.reverse 'missing').toThrow()

    #   it 'should allow for reversing a route by its controller', ->
    #     register()
    #     url = router.reverse controller: 'null'
    #     expect(url).toBe '/index'

    #   it 'should allow for reversing a route by its controller and action', ->
    #     register()
    #     url = router.reverse {controller: 'null', action: '2'}, {two: 41}
    #     expect(url).toBe '/params/41'

    #   it 'should allow for reversing a route by its controller and name', ->
    #     register()
    #     url = router.reverse {name: 'about', controller: 'fake'}, {three: 41}
    #     expect(url).toBe '/fake/41'

    #   it 'should allow for reversing a route by its name via event', ->
    #     register()
    #     params = one: 145
    #     spy = sinon.spy()
    #     expect(executeCallback 'router:reverse', 'phonebook', params).toBe '/phone/145'

    #     expect(->
    #       executeCallback 'router:reverse', 'missing', params
    #     ).toThrow()

    #   it 'should prepend mount point', ->
    #     router.dispose()
    #     Backbone.off 'router:match', routerMatch

    #     removeCallbacks()
    #     router = new Router randomOption: 'foo', pushState: false, root: '/subdir/'
    #     Backbone.on 'router:match', routerMatch
    #     register()

    #     params = one: 145
    #     res = executeCallback 'router:reverse', 'phonebook', params
    #     expect(res).toBe '/subdir/phone/145'

    # describe 'Query string extraction', ->

    #   it 'should extract query string parameters from an url', ->
    #     router.match 'query-string', 'null#null'

    #     input =
    #       foo: '123 456'
    #       'b a r': 'the _quick &brown föx= jumps over the lazy dáwg'
    #       'q&uu=x': 'the _quick &brown föx= jumps over the lazy dáwg'
    #     query = routeConstructor.stringifyQueryParams input

    #     router.route url: 'query-string?' + query
    #     expect(passedOptions.query).toEqual input

    #   it 'should extract query string parameters from an object', ->
    #     router.match 'query-string', 'controller#action'

    #     input =
    #       foo: '123 456'
    #       'b a r': 'the _quick &brown föx= jumps over the lazy dáwg'
    #       'q&uu=x': 'the _quick &brown föx= jumps over the lazy dáwg'

    #     router.route 'controller#action', null, {query: input}
    #     expect(passedOptions.query).toEqual input

    # describe 'Passing the Routing Options', ->

    #   it 'should pass routing options', ->
    #     router.match ':id', 'controller#action'
    #     query = x: 32, y: 21
    #     options = foo: 123, bar: 456
    #     router.route 'controller#action', ['foo'], create {query}, options
    #     # It should be a different object
    #     expect(passedOptions).not.toBe options
    #     expect(passedRoute.path).toBe 'foo'
    #     expect(passedRoute.query).toBe 'x=32&y=21'
    #     expect(passedOptions).toEqual(
    #       create(options, changeURL: true, query: query)
    #     )

    # describe 'Setting the router:route handler', ->

    #   it 'should route when receiving a path', ->
    #     path = 'router-route-event'
    #     options = replace: true

    #     routeSpy = sinon.spy router, 'route'
    #     router.match path, 'router#route'

    #     executeCallback 'router:route', url: path, options
    #     expect(passedRoute).toBeObject()
    #     expect(passedRoute.controller).toBe 'router'
    #     expect(passedRoute.action).toBe 'route'
    #     expect(passedRoute.path).toBe path
    #     expect(passedOptions).toEqual(
    #       create(options, {changeURL: true})
    #     )

    #     expect(->
    #       executeCallback 'router:route', 'different-path', options
    #     ).toThrow()

    #     routeSpy.restore()

    #   it 'should route when receiving a name', ->

    #     router.match '', 'home#index', name: 'home'
    #     executeCallback 'router:route', name: 'home'

    #     expect(passedRoute.controller).toBe 'home'
    #     expect(passedRoute.action).toBe 'index'
    #     expect(passedRoute.path).toBe ''
    #     expect(passedParams).toBeObject()

    #   it 'should route when receiving both name and params', ->
    #     router.match 'phone/:id', 'phonebook#dial', name: 'phonebook'

    #     params = id: '123'
    #     executeCallback 'router:route', 'phonebook', params
    #     expect(passedRoute.controller).toBe 'phonebook'
    #     expect(passedRoute.action).toBe 'dial'
    #     expect(passedRoute.path).toBe "phone/#{params.id}"
    #     expect(passedParams).not.toBe params
    #     expect(passedParams).toBeObject()
    #     expect(passedParams.id).toBe params.id

    #   it 'should route when receiving controller and action name', ->
    #     router.match '', 'home#index'
    #     executeCallback 'router:route', controller: 'home', action: 'index'

    #     expect(passedRoute.controller).toBe 'home'
    #     expect(passedRoute.action).toBe 'index'
    #     expect(passedRoute.path).toBe ''
    #     expect(passedParams).toBeObject()

    #   it 'should route when receiving controller and action name and params', ->
    #     router.match 'phone/:id', 'phonebook#dial'

    #     params = id: '123'
    #     executeCallback 'router:route', controller: 'phonebook', action: 'dial', params
    #     expect(passedRoute.controller).toBe 'phonebook'
    #     expect(passedRoute.action).toBe 'dial'
    #     expect(passedRoute.path).toBe "phone/#{params.id}"
    #     expect(passedParams).not.toBe params
    #     expect(passedParams).toBeObject()
    #     expect(passedParams.id).toBe params.id

    #   it 'should pass options and call the callback', ->
    #     router.match 'index', 'null#null', name: 'home'
    #     router.match 'phone/:id', 'phonebook#dial', name: 'phonebook'

    #     params = id: '123'
    #     options = replace: true
    #     executeCallback 'router:route', 'phonebook', params, options

    #     expect(passedRoute.controller).toBe 'phonebook'
    #     expect(passedRoute.action).toBe 'dial'
    #     expect(passedRoute.path).toBe "phone/#{params.id}"
    #     expect(passedParams).not.toBe params
    #     expect(passedParams).toBeObject()
    #     expect(passedParams.id).toBe params.id
    #     expect(passedOptions).not.toBe options
    #     expect(passedOptions).toEqual(
    #       create(options, options,
    #         changeURL: true
    #       )
    #     )

    #   it 'should throw an error when no match was found', ->
    #     expect(->
    #       executeCallback 'router:route', 'phonebook'
    #     ).toThrow()

    # describe 'Changing the URL', ->

    #   it 'should forward changeURL routing options to Backbone', ->
    #     path = 'router-changeurl-options'
    #     changeURL = sinon.spy router, 'changeURL'
    #     navigate = sinon.spy Backbone.history, 'navigate'
    #     options = some: 'stuff', changeURL: true

    #     router.changeURL null, null, {path}, options
    #     expect(navigate).toHaveBeenCalledWith path,
    #       replace: false, trigger: false

    #     forwarding = replace: true, trigger: true
    #     router.changeURL null, null, {path}, create(options, forwarding)
    #     expect(navigate).toHaveBeenCalledWith path, forwarding

    #     changeURL.restore()
    #     navigate.restore()

    #   it 'should not adjust the URL if not desired', ->
    #     path = 'router-changeurl-false'
    #     changeURL = sinon.spy router, 'changeURL'
    #     navigate = sinon.spy Backbone.history, 'navigate'

    #     router.changeURL null, null, {path}, changeURL: false
    #     expect(navigate).not.toHaveBeenCalled()

    #     changeURL.restore()
    #     navigate.restore()

    #   it 'should add the query string when adjusting the URL', ->
    #     path = 'my-little-path'
    #     query = 'foo=bar'
    #     changeURL = sinon.spy router, 'changeURL'
    #     navigate = sinon.spy Backbone.history, 'navigate'

    #     router.changeURL null, null, {path, query}, changeURL: true
    #     expect(navigate).toHaveBeenCalledWith "#{path}?#{query}"

    #     changeURL.restore()
    #     navigate.restore()
