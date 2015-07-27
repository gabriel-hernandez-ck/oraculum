define [
  'oraculum'
  'oraculum/libs'
], (Oraculum) ->
  'use strict'

  _ = require 'underscore'

  Oraculum.defineMixin 'StaticClasses.ViewMixin',

    # Example staticClasses configuration
    # -----------------------------------
    # ```coffeescript
    # mixinOptions:
    #   staticClasses: 'something somethingelse'
    #   staticClasses: ['something', 'somethingelse']
    # ```

    mixinOptions:
      staticClasses: []

    mixinitialize: ->
      @_setStaticClasses()

    _setStaticClasses: ->
      staticClasses = @mixinOptions.staticClasses
      staticClasses = staticClasses.split ' ' if _.isString staticClasses
      staticClasses = [].concat staticClasses, @_getTagClasses()
      @$el.addClass _.chain(staticClasses).compact().uniq().value().join ' '

    _getTagClasses: ->
      staticTags = [].concat @__tags(), @__mixins()
      return _.map staticTags, (tag) ->
        regions = tag.split /[^\w]/
        return _.map(regions, (region) ->
          words = region.match /[A-Z]?[a-z]*/g
          return _.chain(words).compact().map((value) ->
            return value.toLowerCase()
          ).value().join '-'
        ).join '_'
