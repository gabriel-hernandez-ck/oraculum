define [
  'oraculum'
  'oraculum/libs'
], (oraculum) ->
  'use strict'

  _ = oraculum.get 'underscore'

  oraculum.defineMixin 'ViewComposer.ControllerMixin',

    ### Example configuration
    mixinOptions:
      viewComposer:
        someView:
          view: 'View'
          eventName: 'beforeAction:after'
          waitsForPromise: true
          viewOptions: {}
    ###

    mixinOptions:
      viewComposer: {}

    mixinitialize: ->
      _.each @mixinOptions.viewComposer, (spec, name) =>
        spec = spec.call this if _.isFunction spec
        {eventName, view, viewOptions, waitsForPromise} = spec
        composeView = => @reuse name, view, viewOptions
        @on eventName, ->
          eventedProxy = _.findWhere arguments, type: 'evented_proxy'
          if eventedProxy?.result?.then? and waitsForPromise isnt false
          then eventedProxy.result.then composeView
          else composeView()
