define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  ###
  SortableColumn.ModelMixin
  =========================
  A mixin to provide a sorting interface on a "column".

  It expects `sortCollection` to support the following interface:
    * Method: `getAttributeDirection`
    * Method: `addAttributeDirection`
    * Method: `removeAttributeDirection`
    * Method: `unsort`

  These can be custom methods on the `sortCollection`, or the `sortCollection`
  can mixin one of the provided sorting mixins:

  @see models/mixins/sort-by-attribute-direction.coffee
  @see models/mixins/sort-by-multi-attribute-direction.coffee
  @see models/mixins/sort-by-attribute-direction-interface.coffee
  @see models/mixins/sort-by-multi-attribute-direction-interface.coffee
  ###

  ###
  This definition is part of Oraculum's tabular interface.
  For more information see:

  @see views/cell/text.coffee
  @see views/cell/header.coffee
  @see views/cell/checkbox.coffee
  @see views/mixins/cell.coffee
  @see views/mixins/column-list.coffee
  @see models/mixins/sortable-column.coffee
  ###

  Oraculum.defineMixin 'SortableColumn.ModelMixin',
    mixinOptions:
      sortableColumn:
        # These defaults are compatible with oraculum sorting mixins
        collection: null
        directions: [1, 0, -1]

    # Allows passing in the `sortCollection` option as a constructor argument.
    mixconfig: ({sortableColumn}, attrs, options = {}) ->
      {sortCollection, sortDirections} = options
      sortableColumn.collection = sortCollection if sortCollection?
      sortableColumn.directions = sortDirections if sortDirections?
      throw new Error '''
        SortableColumn.ModelMixin requires a sortCollection
      ''' unless sortableColumn.collection

    mixinitialize: ->
      sortCollection = @mixinOptions.sortableColumn.collection
      @_sortableCollection = if _.isString sortCollection
      then @__factory().get sortCollection
      else sortCollection
      @listenTo @_sortableCollection, 'sort', @_collectionSorted
      @_collectionSorted()

    # Expose an interface for incrementing the current direction
    nextDirection: ->
      attribute = @get 'attribute'
      nextDirection = @getNextDirection()
      @_sortableCollection.addAttributeDirection attribute, nextDirection
      @_collectionSorted()

    # Expose the machanism for determining the next direction
    getNextDirection: ->
      attribute = @get 'attribute'
      directions = @mixinOptions.sortableColumn.directions
      currentDirection = @_sortableCollection.getAttributeDirection attribute
      index = directions.indexOf currentDirection
      nextDirection = directions[++index]
      nextDirection ?= directions[0]
      return nextDirection

    # Provide a convenience method for determining if a column is sorted
    isSorted: -> @has 'sortDirection'

    # React to changed in the `@_sortableCollection`s state
    _collectionSorted: ->
      attribute = @get 'attribute'
      currentDirection = @_sortableCollection.getAttributeDirection attribute
      return @unset 'sortDirection' unless currentDirection
      @set 'sortDirection', currentDirection
