define [
  'oraculum'
  'oraculum/mixins/evented'
  'oraculum/views/mixins/static-classes'
], (Oraculum) ->
  'use strict'

  ###
  Cell.ViewMixin
  ==============
  A "cell" is the intersection of a "column" and a "row".
  In a common tabular view, a "row" may represent a data model,
  and a "column" may represent a rendering specification for the data.
  E.g. what attribute of the data model the cell should render.
  This mixin aims to cover the most common use cases for tabular view cells.
  ###

  Oraculum.defineMixin 'Cell.ViewMixin', {

    mixinOptions:
      staticClasses: ['cell']
      cell: column: null

    mixconfig: ({cell}, {model, column} = {}) ->
      cell.column = column if column?
      cell.column ?= model if model?
      throw new Error '''
        Cell.ViewMixin#mixconfig: requires a column
      ''' unless cell.column

    mixinitialize: ->
      @column = @mixinOptions.cell.column
      @listenTo @column, 'change:sortable', @_updateSortableClass
      @listenTo @column, 'change:attribute', @_updateAttributeClass
      @listenTo @column, 'change:sortDirection', @_updateDirectionClass
      @listenTo @column, 'change:hidden', @_updateHiddenState
      @_updateSortableClass()
      @_updateAttributeClass()
      @_updateDirectionClass()
      @_updateHiddenState()

    _updateAttributeClass: ->
      previous = @column.previous 'attribute'
      @$el.removeClass "#{previous}-cell"
      current = @column.get 'attribute'
      @$el.addClass "#{current}-cell"

    _updateSortableClass: ->
      sortable = Boolean @column.get 'sortable'
      @$el.toggleClass 'sortable', sortable

    _updateDirectionClass: ->
      direction = @column.get 'sortDirection'
      @$el.toggleClass 'sorted', Boolean direction
      @$el.toggleClass 'ascending', direction is -1
      @$el.toggleClass 'descending', direction is 1

    _updateHiddenState: ->
      hidden = @column.get 'hidden'
      return unless hidden?
      @$el.toggle(not hidden)

  }, mixins: [
    'Evented.Mixin'
    'StaticClasses.ViewMixin'
  ]
