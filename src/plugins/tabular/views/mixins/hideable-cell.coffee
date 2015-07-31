define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  ###
  Hideable.CellMixin
  ==================
  This mixin enhances the behavior of Cell.ViewMixin to provide hideable
  behavior on a cell based on its columns hidden state.
  ###

  Oraculum.defineMixin 'Hideable.CellMixin',

    mixinitialize: ->
      @column = @mixinOptions.cell.column
      @listenTo @column, 'change:hidden', @_updateHiddenState
      @_updateHiddenState()

    _updateHiddenState: ->
      return unless (hidden = @column.get 'hidden')?
      display = if Boolean hidden then 'none' else ''
      @$el.css {display}
