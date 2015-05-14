(function() {
  define(['oraculum', 'oraculum/views/mixins/list', 'oraculum/views/mixins/static-classes'], function(Oraculum) {
    'use strict';
    return Oraculum.defineMixin('Table.ViewMixin', {
      mixinOptions: {
        staticClasses: ['table-mixin'],
        table: {
          columns: null
        }
      },
      mixconfig: function(arg, arg1) {
        var columns, list, table, viewOptions;
        table = arg.table, list = arg.list;
        columns = (arg1 != null ? arg1 : {}).columns;
        if (columns != null) {
          table.columns = columns;
        }
        viewOptions = list.viewOptions;
        return list.viewOptions = !_.isFunction(viewOptions) ? _.extend({
          collection: table.columns
        }, viewOptions) : function() {
          return _.extend({
            collection: table.columns
          }, viewOptions.apply(this, arguments));
        };
      },
      mixinitialize: function() {
        this.columns = this.mixinOptions.table.columns;
        if (_.isString(this.columns)) {
          this.columns = this.__factory().get(this.columns);
        }
        if (_.isArray(this.columns)) {
          return this.columns = this.__factory().get('Collection', this.columns);
        }
      }
    }, {
      mixins: ['List.ViewMixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
