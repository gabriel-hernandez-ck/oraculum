define [
  'oraculum'
  'oraculum/libs'
  'oraculum/views/mixins/list'
], (Oraculum) ->
  'use strict'

  ###
  Row.ViewMixin
  =============
  ###

  Oraculum.defineMixin 'Row.ViewMixin', {

    resolveModelView: (column) ->
      {modelView, viewOptions} = @mixinOptions.list
      return column.get('modelView') or modelView

    resolveViewOptions: (column) ->
      model = @model or column
      columnOptions = column.get 'viewOptions'
      viewOptions = @mixinOptions.list.viewOptions
      viewOptions = Oraculum.composeConfig {model, column}, viewOptions, columnOptions
      viewOptions = viewOptions.call this, {model, column} if _.isFunction viewOptions
      return viewOptions

  }, mixins: ['List.ViewMixin']
