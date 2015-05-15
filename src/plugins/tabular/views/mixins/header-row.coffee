define [
  'oraculum'
  'oraculum/libs'
  'oraculum/views/mixins/static-classes'
  'oraculum/plugins/tabular/views/mixins/row'
], (Oraculum) ->
  'use strict'

  composeConfig = Oraculum.get 'composeConfig'

  ###
  HeaderRow.ViewMixin
  ===================
  ###

  Oraculum.defineMixin 'HeaderRow.ViewMixin', {

    mixinOptions:
      staticClasses: ['header-row-mixin']

    resolveModelView: (column) ->
      {headerView, modelView, viewOptions} = @mixinOptions.list
      headerView = column.get('headerView') or headerView
      headerView or= column.get('modelView') or modelView
      return headerView

    resolveViewOptions: (column) ->
      model = @model or column
      headerOptions = column.get 'headerViewOptions'
      viewOptions = @mixinOptions.list.viewOptions
      viewOptions = composeConfig {model, column}, viewOptions, headerOptions
      return if _.isFunction viewOptions
      then viewOptions.call this, {model, column}
      else viewOptions

  }, mixins: [
    'Row.ViewMixin'
    'StaticClasses.ViewMixin'
  ]
