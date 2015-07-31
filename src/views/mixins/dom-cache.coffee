define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/mixins/evented-method'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  Oraculum.defineMixin 'DOMCache.ViewMixin', {

    # Example subviews configuration
    # ------------------------------
    # ```coffeescript
    # mixinOptions:
    #   domcache:
    #     name: 'selector'
    # ```

    mixinOptions:
      eventedMethods:
        render: {}

    mixconfig: (mixinOptions, {domcache} = {}) ->
      mixinOptions.domcache = Oraculum.composeConfig mixinOptions.domcache, domcache

    mixinitialize: ->
      @on 'render:after', @cacheDOM, this

    cacheDOM: ->
      @domcache = {}
      configOptions = @mixinOptions.domcache
      configOptions = configOptions.call this if _.isFunction configOptions
      _.each @$('[data-cache]'), @cacheElement, this
      _.each configOptions, @cacheElement, this
      @trigger 'domcache', this

    cacheElement: (element, name) ->
      $element = @$ element
      name = $element.attr 'data-cache' if _.isElement element
      @domcache[name] = $element if name and $element.length

  }, mixins: [
    'Evented.Mixin'
    'EventedMethod.Mixin'
  ]
