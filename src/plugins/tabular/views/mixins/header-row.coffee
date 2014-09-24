define [
  'oraculum'
  'oraculum/views/mixins/static-classes'
  'oraculum/plugins/tabular/views/mixins/row'
], (Oraculum) ->
  'use strict'

  ###
  Row.ViewMixin
  =============
  ###

  Oraculum.defineMixin 'HeaderRow.ViewMixin', {

    mixinOptions:
      staticClasses: ['header-row-mixin']

    resolveModelView: (column) ->
      {headerView, modelView, viewOptions} = @mixinOptions.list
      headerView = column.get('headerView') or headerView
      headerView or= column.get('modelView') or modelView
      return headerView

  }, mixins: [
    'Row.ViewMixin'
    'StaticClasses.ViewMixin'
  ]
