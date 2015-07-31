(function() {
  define(['oraculum'], function(Oraculum) {
    'use strict';

    /*
    VariableWidth.CellMixin
    =======================
    This mixin enhances Cell.ViewMixin to provide variable width
    behavior on a cell based on its column's width attribute.
     */
    return Oraculum.defineMixin('VariableWidth.CellMixin', {
      mixinitialize: function() {
        this.listenTo(this.column, 'change:width', this._updateWidth);
        return this._updateWidth();
      },
      _updateWidth: function() {
        var width;
        if ((width = this.column.get('width')) == null) {
          return;
        }
        return this.$el.css({
          width: width
        });
      }
    });
  });

}).call(this);
