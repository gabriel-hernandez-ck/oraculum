(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/views/mixins/list', 'oraculum/views/mixins/static-classes'], function(Oraculum) {
    'use strict';
    var composeConfig;
    composeConfig = Oraculum.get('composeConfig');
    return Oraculum.defineMixin('Table.ViewMixin', {
      mixinOptions: {
        staticClasses: ['table-mixin'],
        table: {
          columns: null
        }
      },
      mixconfig: function(arg, arg1) {
        var columns, list, table;
        table = arg.table, list = arg.list;
        columns = (arg1 != null ? arg1 : {}).columns;
        if (columns != null) {
          table.columns = columns;
        }
        return list.viewOptions = composeConfig({
          collection: table.columns
        }, list.viewOptions);
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
