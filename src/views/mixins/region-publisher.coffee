define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/callback-provider'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'
  composeConfig = Oraculum.get 'composeConfig'

  Oraculum.defineMixin 'RegionPublisher.ViewMixin', {

    # Example regions configuration
    # -----------------------------
    # ```coffeescript
    # mixinOptions:
    #   regions:
    #     body: 'body'
    #     content: '#content'
    # ```

    mixconfig: (mixinOptions, {regions} = {}) ->
      mixinOptions.regions = composeConfig mixinOptions.regions, regions

    mixinitialize: ->
      regions = @mixinOptions.regions
      regions = regions.call this if _.isFunction regions
      @executeCallback 'region:register', this if regions?
      @on 'dispose', => @unregisterAllRegions arguments...

    # Functionally register a single region.
    registerRegion: (name, selector) ->
      @executeCallback 'region:register', this, name, selector

    # Functionally unregister a single region by name.
    unregisterRegion: (name) ->
      @executeCallback 'region:unregister', this, name

    # Unregister all regions; called upon view disposal.
    unregisterAllRegions: ->
      @executeCallback 'region:unregister', this

  }, mixins: [
    'CallbackDelegate.Mixin'
  ]
