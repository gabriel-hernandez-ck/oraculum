define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  ###
  VariableWidth.CellMixin
  =======================
  This mixin enhances Cell.ViewMixin to provide variable width
  behavior on a cell based on its column's width attribute.
  ###

  Oraculum.defineMixin 'VariableWidth.CellMixin',

    mixinitialize: ->
      @listenTo @column, 'change:width', @_updateWidth
      @_updateWidth()

    _updateWidth: ->
      return unless (width = @column.get 'width')?
      @$el.css {width}
