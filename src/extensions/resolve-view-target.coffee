define [
  'oraculum'
  'jquery'
], (Oraculum, $) ->
  'use strict'

  ###
  Resolve View Target
  ===================
  This function is a helper for arbitrary `View`s that makes the issue of
  resolving a target element in a view simpler when dealing with mixed types.
  Many mixins use this behavior to resolve '.class', `Element` or
  `jQueryElement` references to a `jQueryElement` in a particular `View`s scope.
  Additionally, a `null`, `false`, `undefined`, etc target will return the
  `View`s root element ($el).

  @param {View} view The object that contains the targeted method.
  @param {null|false|undefined|String|Element|jQueryElement|Function} target Something that resembles an element or selector.
  ###

  Oraculum.resolveViewTarget = (view, target) ->
    target = target.call view if typeof target is 'function'
    return target if target instanceof $
    return $(target) if _.isElement target
    return if target? then view.$(target) else view.$el

  Oraculum.define 'resolveViewTarget', (->
    console?.warn? '''
      Oraculum resolveViewTarget definition has been superceded by the
      Oraculum.resolveViewTarget instance method.
      This factory definition will be removed in 2.x
    '''
    return Oraculum.resolveViewTarget
  ), singleton: true
