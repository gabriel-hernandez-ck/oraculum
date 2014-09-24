define [
  'oraculum'
  'oraculum/views/mixins/static-classes'
  'oraculum/plugins/tabular/views/mixins/row'
], (Oraculum) ->
  'use strict'

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
      viewOptions = @mixinOptions.list.viewOptions
      viewOptions = if _.isFunction viewOptions
      then viewOptions.call this, { model, column }
      else _.extend { model, column }, viewOptions
      return _.extend {}, viewOptions, column.get 'headerViewOptions'

  }, mixins: [
    'Row.ViewMixin'
    'StaticClasses.ViewMixin'
  ]
