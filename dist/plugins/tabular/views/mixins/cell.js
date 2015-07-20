(function() {
  define(['oraculum', 'oraculum/mixins/evented', 'oraculum/views/mixins/static-classes', 'oraculum/plugins/tabular/views/mixins/sortable-cell', 'oraculum/plugins/tabular/views/mixins/hideable-cell'], function(Oraculum) {
    'use strict';

    /*
    Cell.ViewMixin
    ==============
    A "cell" is the intersection of a "column" and a "row".
    In a common tabular view, a "row" may represent a data model,
    and a "column" may represent a rendering specification for the data.
    E.g. what attribute of the data model the cell should render.
    This mixin aims to cover the most common use cases for tabular view cells.
     */
    return Oraculum.defineMixin('Cell.ViewMixin', {
      mixinOptions: {
        staticClasses: ['cell', 'cell-mixin'],
        cell: {
          column: null
        }
      },
      mixconfig: function(arg, arg1) {
        var cell, column, model, ref;
        cell = arg.cell;
        ref = arg1 != null ? arg1 : {}, model = ref.model, column = ref.column;
        if (column != null) {
          cell.column = column;
        }
        if (model != null) {
          if (cell.column == null) {
            cell.column = model;
          }
        }
        if (!cell.column) {
          throw new Error('Cell.ViewMixin#mixconfig: requires a column');
        }
      },
      mixinitialize: function() {
        this.column = this.mixinOptions.cell.column;
        this.listenTo(this.column, 'change:attribute', this._updateCellAttributes);
        return this._updateCellAttributes();
      },
      _updateCellAttributes: function() {
        var current, previous;
        current = this.column.get('attribute');
        previous = this.column.previous('attribute');
        this.$el.addClass((current + "-cell").replace(/[\.\s]/, '-'));
        this.$el.removeClass((previous + "-cell").replace(/[\.\s]/, '-'));
        return this.$el.attr('data-column-attr', current);
      }
    }, {
      mixins: ['Evented.Mixin', 'Hideable.CellMixin', 'Sortable.CellMixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
