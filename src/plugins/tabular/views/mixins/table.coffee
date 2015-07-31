define [
  'oraculum'
  'oraculum/libs'
  'oraculum/views/mixins/list'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'Table.ViewMixin', {

    mixinOptions:
      table: columns: null

    mixconfig: ({table, list}, {columns} = {}) ->
      table.columns = columns if columns?
      list.viewOptions = Oraculum.composeConfig {
        collection: table.columns
      }, list.viewOptions

    mixinitialize: ->
      @columns = @mixinOptions.table.columns
      @columns = @__factory().get @columns if _.isString @columns
      @columns = @__factory().get 'Collection', @columns if _.isArray @columns

  }, mixins: ['List.ViewMixin']
