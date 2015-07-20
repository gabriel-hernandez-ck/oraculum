define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
], (Oraculum) ->

  _ = Oraculum.get 'underscore'
  Backbone = Oraculum.get 'Backbone'

  ###
  Listener.Mixin
  ==============
  Allow objects to automnatically setup event listeners via configuration.
  This uses a syntax similar to `Backbone.View`'s `events` configuration.
  ###

  Oraculum.defineMixin 'Listener.Mixin', {

    ###
    Mixin Options
    -------------
    Allow the event configuration to be defined using a mapping of event specs
    and methods as described in the examples below.

    @param {Object} listen Object containing an event map.
    @param {Function} listen Function that returns an object containing an event map.
    ###

    #### Example configuration ###
    # ```coffeescript
    # mixinOptions:
    #   listen: # -> # Can also be a function
    #     # Bind `@update` to `render:after` events on `this`.
    #     'render:after this': 'update'
    #     'render:after self': 'update'
    #
    #     # Bind `@render` to `change` events on `@model`.
    #     'change model': 'render'
    #
    #     # Bind an anonymous function to `add`, `remove`, and
    #     # `reset` events on `@collection`
    #     'add remove reset collection': -> doSomething()
    #
    #     # Bind `@someMethod` to `!someEvent` events on the
    #     # mediator. (Backbone)
    #     '!someEvent pubsub': 'someMethod'
    #     '!someEvent mediator': 'someMethod'
    # ```

    ###
    Minitialize
    -----------
    Invoke `@delegateListeners`.

    @see @delegateListeners
    ###

    mixinitialize: ->
      @delegateListeners()

    ###
    Make Evented Methods
    --------------------
    Iterate over an event map, passing an event spec and its mapped callback
    through to `@delegateListener`.

    @see @delegateListener

    @param {Object} eventMap? An event map. Defaults to the configured event map.
    @param {Function} eventMap? A function that returns an event map. Defaults to the configured event map.
    ###

    delegateListeners: (eventMap) ->
      return unless eventMap ?= @mixinOptions.listen
      eventMap = eventMap.call this if _.isFunction eventMap
      _.each eventMap, (callback, spec) =>
        @delegateListener spec, callback

    ###
    Delegate Listener
    -----------------
    Delegates events for a single event spec which can describe multiple
    listeners.

    @param {String} spec The event spec to delegate events for.
    @param {String} method A method on the current instance to bind.
    @param {Function} method A function to bind.
    ###

    delegateListener: (spec, method) ->
      target = spec.split(' ').slice(-1)[0]
      events = spec.split(' ').slice(0, -1).join(' ')

      callback = if _.isFunction method then method else @[method]
      throw new TypeError """
        Listener.Mixin #{method} is not a function.
      """ unless _.isFunction callback

      emitter = if target in ['this', 'self'] then this
      else if target in ['pubsub', 'mediator'] then Backbone
      else @[target]

      throw new TypeError """
        Listener.Mixin #{target} is not an emitter.
      """ unless _.isFunction emitter?.on

      @listenTo emitter, events, callback

  }, mixins: ['Evented.Mixin']
