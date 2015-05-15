define [
  'oraculum'
  'oraculum/libs'
  'oraculum/views/mixins/list'
  'oraculum/views/mixins/static-classes'
], (Oraculum) ->
  'use strict'

  composeConfig = Oraculum.get 'composeConfig'

  Oraculum.defineMixin 'Table.ViewMixin', {

    mixinOptions:
      staticClasses: ['table-mixin']
      table: columns: null

    mixconfig: ({table, list}, {columns} = {}) ->
      table.columns = columns if columns?
      list.viewOptions = composeConfig {
        collection: table.columns
      }, list.viewOptions

    mixinitialize: ->
      @columns = @mixinOptions.table.columns
      @columns = @__factory().get @columns if _.isString @columns
      @columns = @__factory().get 'Collection', @columns if _.isArray @columns

  }, mixins: [
    'List.ViewMixin'
    'StaticClasses.ViewMixin'
  ]
