define [
  'oraculum'
  'oraculum/libs'
  'oraculum/views/mixins/list'
  'oraculum/views/mixins/static-classes'
], (Oraculum) ->
  'use strict'

  composeConfig = Oraculum.get 'composeConfig'

  ###
  Row.ViewMixin
  =============
  ###

  Oraculum.defineMixin 'Row.ViewMixin', {

    mixinOptions:
      staticClasses: ['row-mixin']

    resolveModelView: (column) ->
      {modelView, viewOptions} = @mixinOptions.list
      return column.get('modelView') or modelView

    resolveViewOptions: (column) ->
      model = @model or column
      columnOptions = column.get 'viewOptions'
      viewOptions = @mixinOptions.list.viewOptions
      viewOptions = composeConfig {model, column}, viewOptions, columnOptions
      return if _.isFunction viewOptions
      then viewOptions.call this, {model, column}
      else viewOptions

  }, mixins: [
    'List.ViewMixin'
    'StaticClasses.ViewMixin'
  ]
