(function() {
  define(['oraculum', 'oraculum/views/mixins/static-classes', 'oraculum/plugins/tabular/views/mixins/row'], function(Oraculum) {
    'use strict';

    /*
    Row.ViewMixin
    =============
     */
    return Oraculum.defineMixin('HeaderRow.ViewMixin', {
      mixinOptions: {
        staticClasses: ['header-row-mixin']
      },
      resolveModelView: function(column) {
        var headerView, modelView, viewOptions, _ref;
        _ref = this.mixinOptions.list, headerView = _ref.headerView, modelView = _ref.modelView, viewOptions = _ref.viewOptions;
        headerView = column.get('headerView') || headerView;
        headerView || (headerView = column.get('modelView') || modelView);
        return headerView;
      }
    }, {
      mixins: ['Row.ViewMixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
