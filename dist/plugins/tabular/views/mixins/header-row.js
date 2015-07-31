(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/plugins/tabular/views/mixins/row'], function(Oraculum) {
    'use strict';
    var _;
    _ = Oraculum.get('underscore');

    /*
    HeaderRow.ViewMixin
    ===================
     */
    return Oraculum.defineMixin('HeaderRow.ViewMixin', {
      resolveModelView: function(column) {
        var headerView, modelView, ref, viewOptions;
        ref = this.mixinOptions.list, headerView = ref.headerView, modelView = ref.modelView, viewOptions = ref.viewOptions;
        headerView = column.get('headerView') || headerView;
        headerView || (headerView = column.get('modelView') || modelView);
        return headerView;
      },
      resolveViewOptions: function(column) {
        var headerOptions, model, viewOptions;
        model = this.model || column;
        headerOptions = column.get('headerViewOptions');
        viewOptions = this.mixinOptions.list.viewOptions;
        viewOptions = Oraculum.composeConfig({
          model: model,
          column: column
        }, viewOptions, headerOptions);
        if (_.isFunction(viewOptions)) {
          viewOptions = viewOptions.call(this, {
            model: model,
            column: column
          });
        }
        return viewOptions;
      }
    }, {
      mixins: ['Row.ViewMixin']
    });
  });

}).call(this);
