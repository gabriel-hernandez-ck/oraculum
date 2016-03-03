define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/pub-sub'
  'oraculum/mixins/evented-method'
], (oraculum) ->
  'use strict'

  _ = oraculum.get 'underscore'

  oraculum.defineMixin 'ResetLayoutClass.ControllerMixin', {
    mixinOptions:
      eventedMethods:
        beforeAction: {}

    mixinitialize: ->
      @on 'beforeAction:before', =>
        @publishEvent '!resetLayoutClass'

  }, mixins: [
    'PubSub.Mixin'
    'EventedMethod.Mixin'
  ]

  oraculum.defineMixin 'RouteLayoutClass.ControllerMixin', {
    mixinOptions:
      eventedMethods:
        beforeAction: {}

    mixinitialize: ->
      replace = /[^\w]+/g
      remove = /\.?controller/ig
      @on 'beforeAction:after', (p, {controller, action, previous}) =>
        prevAction = prevController = 'unknown'
        prevAction = previous.action if previous?.action?
        prevController = previous.controller if previous?.controller?
        action = action.toLowerCase()
        prevAction = prevAction.toLowerCase()
        controller = controller.replace(remove, '').toLowerCase()
        prevController = prevController.replace(remove, '').toLowerCase()
        @publishEvent '!addLayoutClass', [
          "#{action.replace replace, '-'}-action"
          "#{controller.replace replace, '-'}-controller"
          "#{prevAction.replace replace, '-'}-prev-action"
          "#{prevController.replace replace, '-'}-prev-controller"
        ].join ' '

  }, mixins: [
    'PubSub.Mixin'
    'EventedMethod.Mixin'
  ]

  oraculum.defineMixin 'LayoutClass.LayoutMixin', {

    mixinitialize: ->
      @subscribeEvent '!addLayoutClass', @addClass
      @subscribeEvent '!resetLayoutClass', @resetClass
      @subscribeEvent '!removeLayoutClass', @removeClass
      @subscribeEvent '!toggleLayoutClass', @toggleClass

    resetClass: -> @$el.attr 'class', _.result(this, 'className') or ''

    addClass: -> @$el.addClass arguments...
    removeClass: -> @$el.removeClass arguments...
    toggleClass: -> @$el.toggleClass arguments...

  }, mixins: [
    'PubSub.Mixin'
  ]


