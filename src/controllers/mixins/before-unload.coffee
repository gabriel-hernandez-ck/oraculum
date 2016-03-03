define [
  'oraculum'
  'oraculum/mixins/pub-sub'
], (oraculum) ->
  'use strict'

  # This relies on `MiddlewareMethod.Mixin` wrapping `route` on the application
  # router and using the global event bus (Backbone) as its emitter.
  # See: src/router/index.coffee

  oraculum.defineMixin 'BeforeUnload.ControllerMixin', {
    mixinOptions:
      beforeUnload:
        # TODO: i18n
        message: 'Are you sure you want to do that?'
        deferredCallback: (message) -> alert message

    mixinitialize: ->
      @on 'dispose', @removeBeforeUnload, this

    addBeforeUnload: ->
      @subscribeEvent 'router:route:middleware:before', @_routeStarted
      @subscribeEvent 'router:route:middleware:defer', @_routeDeferred
      window.onbeforeunload = => @mixinOptions.beforeUnload.message

    removeBeforeUnload: ->
      @unsubscribeEvent 'router:route:middleware:before', @_routeStarted
      @unsubscribeEvent 'router:route:middleware:defer', @_routeDeferred
      window.onbeforeunload = -> #0x90

    _routeStarted: ->
      proxy = @_findProxy arguments...
      proxy.wait = true

    _routeDeferred: ->
      proxy = @_findProxy arguments...
      message = @mixinOptions.beforeUnload.message
      @mixinOptions.beforeUnload.deferredCallback message

    _findProxy: (args...) ->
      return _.find args, (arg) -> arg.type is 'middleware_proxy'

  }, mixins: ['PubSub.Mixin']
