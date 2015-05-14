(function() {
  define(['oraculum', 'oraculum/views/mixins/static-classes', 'oraculum/plugins/tabular/views/mixins/row'], function(Oraculum) {
    'use strict';

    /*
    HeaderRow.ViewMixin
    ===================
     */
    return Oraculum.defineMixin('HeaderRow.ViewMixin', {
      mixinOptions: {
        staticClasses: ['header-row-mixin']
      },
      resolveModelView: function(column) {
        var headerView, modelView, ref, viewOptions;
        ref = this.mixinOptions.list, headerView = ref.headerView, modelView = ref.modelView, viewOptions = ref.viewOptions;
        headerView = column.get('headerView') || headerView;
        headerView || (headerView = column.get('modelView') || modelView);
        return headerView;
      },
      resolveViewOptions: function(column) {
        var model, viewOptions;
        model = this.model || column;
        viewOptions = this.mixinOptions.list.viewOptions;
        viewOptions = _.isFunction(viewOptions) ? viewOptions.call(this, {
          model: model,
          column: column
        }) : _.extend({
          model: model,
          column: column
        }, viewOptions);
        return _.extend({}, viewOptions, column.get('headerViewOptions'));
      }
    }, {
      mixins: ['Row.ViewMixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
