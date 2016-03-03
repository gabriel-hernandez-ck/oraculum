define [
  'oraculum'
  'oraculum/mixins/pub-sub'
], (oraculum) ->
  'use strict'

  oraculum.defineMixin 'Polling.ModelMixin',
    mixinOptions:
      polling:
        interval: 2000

    mixconfig: ({polling}, attrs, {pollingInterval} = {}) ->
      polling.interval = pollingInterval if pollingInterval?

    mixinitialize: ->
      pollingPaused = false
      @subscribeEvent 'polling:pause', =>
        pollingPaused = @_polling
        @stopPolling()
      @subscribeEvent 'polling:resume', =>
        @startPolling() if pollingPaused
      @on 'dispose', @stopPolling, this

    startPolling: ->
      return if @_polling
      @_polling = true
      fetch = _.debounce (=>
        return unless @_polling
        @_pollingXHR = @fetch()
        @_pollingXHR.always fetch
      ), @mixinOptions.polling.interval
      fetch()
      @trigger 'startPolling', this
      return this

    stopPolling: ->
      return unless @_polling
      @_polling = false
      @_pollingXHR?.abort()
      @trigger 'stopPolling', this
      return this
  , mixins: ['PubSub.Mixin']
