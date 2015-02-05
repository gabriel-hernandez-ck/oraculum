define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented-method'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  Oraculum.defineMixin 'Subview.ViewMixin', {

    # Example subviews configuration
    # ------------------------------
    # ```coffeescript
    # mixinOptions:
    #   subviews:
    #     nameOfChildView:
    #       view: 'View'
    #       viewOptions: {}
    #     nameOfAnotherChildView: ->
    #       view: @view
    #       viewOptions: @getViewOptions()
    # ```

    mixinOptions:
      eventedMethods:
        render: {}

    mixconfig: (mixinOptions, {subviews} = {}) ->
      mixinOptions.subviews = _.extend {}, mixinOptions.subviews, subviews

    mixinitialize: ->
      @_subviews = []
      @_subviewsByName = {}
      @on 'render:after', => @createSubviews()
      @on 'dispose', => _.each @_subviews, (view) -> view.dispose?()

    createSubviews: ->
      # Create a mutable local clone of the subviews
      mutableSubviews = _.clone @mixinOptions.subviews
      @_createDOMSubviews mutableSubviews
      @_createDOMContainerSubviews mutableSubviews
      _.each mutableSubviews, (spec, name) =>
        @createSubview name, spec

    _createDOMSubviews: (mutableSubviews) ->
      subviewElements = @$('[data-subview]')
      _.each subviewElements, (el) =>
        name = el.getAttribute 'data-subview'
        spec = mutableSubviews[name]
        viewOptions = _.extend {}, spec.viewOptions, { el }
        @createSubview name, _.extend {}, spec, { viewOptions }
        delete mutableSubviews[name]

    _createDOMContainerSubviews: (mutableSubviews) ->
      subviewElements = @$('[data-subview-container]')
      _.each subviewElements, (container) =>
        name = container.getAttribute 'data-subview-container'
        spec = mutableSubviews[name]
        viewOptions = _.extend {}, spec.viewOptions, { container }
        @createSubview name, _.extend {}, spec, { viewOptions }
        delete mutableSubviews[name]

    createSubview: (name, spec) ->
      return @subview name, @createView spec

    createView: (spec) ->
      spec = spec.call this if _.isFunction spec
      viewOptions = _.extend {}, spec.viewOptions
      return if _.isString spec.view
      then @__factory().get spec.view, viewOptions
      else new spec.view viewOptions

    subview: (name, view) ->
      return @_resolveSubview(name).view unless view
      @removeSubview name
      @_subviews.push view
      @_subviewsByName[name] = view
      @trigger 'subviewCreated', view, this
      return view

    removeSubview: (nameOrView, dispose = true) ->
      {name, view} = @_resolveSubview nameOrView
      return unless name and view
      view.remove()
      @disposeSubview nameOrView if dispose

    disposeSubview: (nameOrView) ->
      {name, view} = @_resolveSubview nameOrView
      return unless name and view
      view.dispose?()
      index = @_subviews.indexOf view
      @_subviews.splice index, 1 unless index is -1
      return delete @_subviewsByName[name]

    _resolveSubview: (name) ->
      view = if _.isString name then @_subviewsByName[name] else name
      return {name, view} if _.isString name
      for name, otherView of @_subviewsByName
        return {name, view} if view is otherView

  }, mixins: [
    'EventedMethod.Mixin'
  ]
