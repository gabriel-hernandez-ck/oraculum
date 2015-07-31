define [
  'oraculum'
  'oraculum/libs'
  'oraculum/plugins/tabular/views/mixins/row'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  ###
  HeaderRow.ViewMixin
  ===================
  ###

  Oraculum.defineMixin 'HeaderRow.ViewMixin', {

    resolveModelView: (column) ->
      {headerView, modelView, viewOptions} = @mixinOptions.list
      headerView = column.get('headerView') or headerView
      headerView or= column.get('modelView') or modelView
      return headerView

    resolveViewOptions: (column) ->
      model = @model or column
      headerOptions = column.get 'headerViewOptions'
      viewOptions = @mixinOptions.list.viewOptions
      viewOptions = Oraculum.composeConfig {model, column}, viewOptions, headerOptions
      viewOptions = viewOptions.call this, {model, column} if _.isFunction viewOptions
      return viewOptions

  }, mixins: ['Row.ViewMixin']
