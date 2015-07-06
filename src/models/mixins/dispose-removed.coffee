define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented-method'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  ###
  DisposeRemoved.CollectionMixin
  ==============================
  Automatically `dispose` a `Model` that has been removed from a `Collection`.
  This mixin is intended to be used at the `Collection` layer so that it can
  ensure that it's not disposing of `Model`s that may have been removed from
  a separate `Collection`.
  ###

  Oraculum.defineMixin 'DisposeRemoved.CollectionMixin', {

    ###
    Mixin Options
    -------------
    Allow the `disposeRemoved` flag to be set on the definition.
    ###

    mixinOptions:
      disposeRemoved: true # Whether or not to `dispose` removed `Model`s.
      eventedMethods:
        reset: {}
        remove: {}

    ###
    Mixconfig
    ---------
    Allow the `disposeRemoved` flag to be set in the constructor options.

    @param {Boolean} disposeRemoved Whether or not to `dispose` removed `Model`s.
    ###

    mixconfig: (mixinOptions, models, {disposeRemoved} = {}) ->
      mixinOptions.disposeRemoved = disposeRemoved if disposeRemoved?

    ###
    Mixinitialize
    -------------
    Set up an event listener to respond to `remove:after` events by invoking
    `dispose` on the removed `Model`s.
    Additionally, add an event listener to respond to `reset:after` events by
    invoking `dispose` on `Model`s that were removed during the `reset`.
    By design, this will throw if the target model does not impement the
    `dispose` method.
    ###

    mixinitialize: ->
      if @mixinOptions.disposeRemoved
      then @enableDisposeRemoved()
      else @disableDisposeRemoved()

    enableDisposeRemoved: ->
      @on 'reset', @disposeRemovedReset, this
      @on 'remove:after', @disposeRemoved, this

    disableDisposeRemoved: ->
      @off 'reset', @disposeRemovedReset, this
      @off 'remove:after', @disposeRemoved, this

    disposeRemovedReset: (target, {previousModels}) ->
      @once 'reset:after', => @disposeRemoved previousModels

    disposeRemoved: (models) ->
      models = [models] unless _.isArray models
      model?.dispose() for model in models

  }, mixins: ['EventedMethod.Mixin']
