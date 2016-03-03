define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
], (oraculum) ->
  'use strict'

  _ = oraculum.get 'underscore'

  oraculum.defineMixin 'URLAppend.ModelMixin',
    mixinitialize: ->
      url = @url
      @url = =>
        parentUrl = _.result @parent, 'url'
        thisUrl = if _.isFunction url then url.apply this, arguments else url
        return "#{parentUrl}#{thisUrl}"

  oraculum.defineMixin 'Submodel.ModelMixin', {

    # Example submodels configuration
    # -------------------------------
    # TODO: Support flags for auto-creating submodels
    # TODO: Support constructor options for submodels
    # ```coffeescript
    # mixinOptions:
    #   submodels:
    #     someModel:
    #       model: 'Some.Model'
    #       ctorArgs: []
    #       setOptions:
    #         parse: true
    #         validate: false
    #     someCollection:
    #       keep: true
    #       model: 'Some.Collection'
    #       default: true
    #       ctorArgs: -> []
    # ```

    mixconfig: (mixinOptions, attrs, {submodels} = {}) ->
      mixinOptions.submodels = _.extend {}, mixinOptions.submodels, submodels

    mixinitialize: ->
      attributes = _.clone @attributes

      _.each @attributes, (submodel, attr) =>
        return unless @mixinOptions.submodels[attr]
        return unless _.isFunction submodel?.on
        @configureSubmodelAttribute submodel, attr

      _.each @mixinOptions.submodels, (submodel, attr) =>
        return unless submodel.default
        submodel = @createSubmodelFor attr
        @set attr, submodel, silent: true

      set = @set
      @set = (attrs, val, options) =>
        return unless attrs?
        options = val if _.isObject attrs
        attrs = _.object [attrs], [val] unless _.isObject attrs
        attrs = @parseSubmodelAttributes attrs, options unless options?.unset
        set.call this, attrs, options

      # Dispose of all our submodels, unless we want to keep them
      @on 'dispose', (model) =>
        return unless model is this
        _.each @attributes, (value, attr) =>
          spec = @mixinOptions.submodels[attr]
          return if spec and spec.keep
          value?.dispose?()

      @set attributes, silent: true

    createSubmodelFor: (attr) ->
      Model = @mixinOptions.submodels[attr].model
      ctorArgs = @mixinOptions.submodels[attr].ctorArgs
      ctorArgs = ctorArgs.call this if _.isFunction ctorArgs
      ctorArgs or= []
      submodel = if _.isString Model
      then @__factory().get Model, ctorArgs...
      else new Model(ctorArgs...)
      return @configureSubmodelAttribute submodel, attr

    configureSubmodelAttribute: (submodel, attr) ->
      submodel.parent = this
      @stopListening submodel

      # Bubble up events from the submodel
      @listenTo submodel, 'all', (eventName, args...) =>
        @trigger "#{attr}:#{eventName}", args...

      # Clean up references to this model from the submodel if it gets disposed
      @listenTo submodel, 'dispose', (target) =>
        return unless target is submodel
        @stopListening submodel

      @listenTo this, "change:#{attr}", (model, value, options) =>
        return if Boolean value
        return unless Boolean options?.unset
        return if @mixinOptions.submodels[attr].keep
        submodel.dispose?() unless options.keep

      return submodel

    parseSubmodelAttributes: (attrs, options) ->
      attrs = _.clone attrs
      _.each attrs, (value, attr) =>
        return unless spec = @mixinOptions.submodels[attr]

        tags = value?.__tags?()
        isModel = tags? and 'Model' in tags
        isCollection = tags? and 'Collection' in tags
        isModelOrCollection = isModel or isCollection
        return @configureSubmodelAttribute value, attr if isModelOrCollection

        submodel = @get attr
        if _.isFunction submodel?.set
          submodel.set value, _.extend {}, spec.setOptions, options
          delete attrs[attr]
        else
          submodel = @createSubmodelFor attr
          submodel.set value, _.extend {}, spec.setOptions, options
          attrs[attr] = submodel

      return attrs

  }, mixins: [
    'Evented.Mixin'
  ]
