define [
  'oraculum'
  'oraculum/libs'
], (Oraculum) ->
  'use strict'

  _ = require 'underscore'

  Oraculum.defineMixin 'StaticClasses.ViewMixin',

    mixinOptions:
      staticClasses: []

    mixinitialize: ->
      @_addTagClass @__type() if _.isFunction @__type
      @$el.addClass if _.isArray @mixinOptions.staticClasses
      then @mixinOptions.staticClasses.join ' '
      else @mixinOptions.staticClasses

    _addTagClass: (tag) ->
      @$el.addClass _.map(tag.split(/[^\w]/), (region) ->
        return _.map(region.match(/[A-Z]?[a-z]+/g), (value) ->
          return value.toLowerCase()
        ).join '-'
      ).join '_'
