(function() {
  define(['oraculum'], function(Oraculum) {
    'use strict';

    /*
    Hideable.CellMixin
    ==================
    This mixin enhances the behavior of Cell.ViewMixin to provide hideable
    behavior on a cell based on its columns hidden state.
     */
    return Oraculum.defineMixin('Hideable.CellMixin', {
      mixinitialize: function() {
        this.column = this.mixinOptions.cell.column;
        this.listenTo(this.column, 'change:hidden', this._updateHiddenState);
        return this._updateHiddenState();
      },
      _updateHiddenState: function() {
        var display, hidden;
        if ((hidden = this.column.get('hidden')) == null) {
          return;
        }
        display = Boolean(hidden) ? 'none' : '';
        return this.$el.css({
          display: display
        });
      }
    });
  });

}).call(this);
