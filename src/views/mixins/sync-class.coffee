define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/mixins/evented-method'
], (oraculum) ->
  'use strict'

  _ = oraculum.get 'underscore'

  getOptions = ->
    options = @mixinOptions.syncClass
    options = options.call(this) if _.isFunction options
    return options

  oraculum.defineMixin 'SyncClass.ViewMixin', {

    mixinOptions:
      syncClass:
        emitter: null
        selector: null
      eventedMethods:
        render: {}

    mixconfig: ({syncClass}, {syncEmitter, syncSelector} = {}) ->
      syncClass.emitter = syncEmitter if syncEmitter?
      syncClass.selector = syncSelector if syncSelector?

    mixinitialize: ->
      @on 'render:after', @updateSyncClass, this
      @setSyncEmitter()

    setSyncEmitter: (emitter) ->
      return unless emitter ?= getOptions.call(this).emitter
      if @_syncClassEmitter
        @stopListening @_syncClassEmitter, 'syncStateChange', @updateSyncClass
      @_syncClassEmitter = emitter
      @listenTo emitter, 'syncStateChange', @updateSyncClass
      @updateSyncClass()

    updateSyncClass: ->
      return unless @_syncClassEmitter
      selector = getOptions.call(this).selector
      $target = if selector? then @$ selector else @$el
      $target.toggleClass 'synced', @_syncClassEmitter.isSynced()
      $target.toggleClass 'syncing', @_syncClassEmitter.isSyncing()
      $target.toggleClass 'unsynced', @_syncClassEmitter.isUnsynced()

  }, mixins: [
    'Evented.Mixin'
    'EventedMethod.Mixin'
  ]
