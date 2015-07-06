(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/mixins/evented', 'oraculum/models/mixins/sort-by-multi-attribute-direction-interface'], function(Oraculum) {
    'use strict';
    var _, multiDirectionSort, normalizeValue;
    _ = Oraculum.get('underscore');
    normalizeValue = function(value) {
      if (_.isNumber(value)) {
        return value;
      }
      if (_.isString(value) && /^\d+$/.test(value)) {
        return parseInt(value, 10);
      }
      if (_.isString(value)) {
        return value;
      }
      if ((value != null ? value.toString : void 0) != null) {
        return value.toString();
      } else {
        return value;
      }
    };
    multiDirectionSort = function(a, b, attributes, directions, index) {
      var attribute, direction, valueA, valueB;
      if (index == null) {
        index = 0;
      }
      if ((direction = directions[index]) === 0) {
        return 0;
      }
      attribute = attributes[index];
      if ((valueA = normalizeValue(a.get(attribute))) == null) {
        return 0;
      }
      if ((valueB = normalizeValue(b.get(attribute))) == null) {
        return 0;
      }
      if (valueA === valueB) {
        if ((attributes.length - 1) === index) {
          return 0;
        } else {
          return multiDirectionSort(a, b, attributes, directions, ++index);
        }
      }
      if (valueA < valueB) {
        return direction;
      }
      return direction * -1;
    };
    return Oraculum.defineMixin('SortByMultiAttributeDirection.CollectionMixin', {
      mixinitialize: function() {
        return this.listenTo(this.sortState, 'add remove reset change', _.debounce(((function(_this) {
          return function() {
            return _this.sort.apply(_this, arguments);
          };
        })(this)), 10));
      },
      comparator: function(a, b) {
        var attributes, directions;
        attributes = this.sortState.pluck('attribute');
        directions = this.sortState.pluck('direction');
        if (!attributes.length) {
          return (a.cid > b.cid) && 1 || -1;
        }
        return multiDirectionSort(a, b, attributes, directions);
      }
    }, {
      mixins: ['Evented.Mixin', 'SortByMultiAttributeDirectionInterface.CollectionMixin']
    });
  });

}).call(this);
