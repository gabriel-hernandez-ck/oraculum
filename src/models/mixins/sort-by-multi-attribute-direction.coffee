define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/models/mixins/sort-by-multi-attribute-direction-interface'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  normalizeValue = (value) ->
    # Always prefer numbers
    return value if _.isNumber value
    # Parse to a number if the value is numeric (eg, "1")
    return parseInt value, 10 if _.isString(value) and /^\d+$/.test value
    # If it's not a number, use a string
    return value if _.isString value # Already a string
    return if value?.toString? then value.toString() else value

  multiDirectionSort = (a, b, attributes, directions, index = 0) ->
    return 0 if (direction = directions[index]) is 0

    attribute = attributes[index]
    return 0 unless (valueA = normalizeValue a.get attribute)?
    return 0 unless (valueB = normalizeValue b.get attribute)?

    if valueA is valueB
      return if (attributes.length - 1) is index then 0
      else multiDirectionSort a, b, attributes, directions, ++index

    return direction if valueA < valueB
    return direction * -1

  Oraculum.defineMixin 'SortByMultiAttributeDirection.CollectionMixin', {

    mixinitialize: ->
      @listenTo @sortState, 'add remove reset change', _.debounce (=>
        @sort arguments...
      ), 10

    comparator: (a, b) ->
      attributes = @sortState.pluck 'attribute'
      directions = @sortState.pluck 'direction'
      return (a.cid > b.cid) and 1 or -1 unless attributes.length
      return multiDirectionSort a, b, attributes, directions

  }, mixins: [
    'Evented.Mixin'
    'SortByMultiAttributeDirectionInterface.CollectionMixin'
  ]
