(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/views/mixins/static-classes', 'oraculum/plugins/tabular/views/mixins/row'], function(Oraculum) {
    'use strict';
    var composeConfig;
    composeConfig = Oraculum.get('composeConfig');

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
        var headerOptions, model, viewOptions;
        model = this.model || column;
        headerOptions = column.get('headerViewOptions');
        viewOptions = this.mixinOptions.list.viewOptions;
        viewOptions = composeConfig({
          model: model,
          column: column
        }, viewOptions, headerOptions);
        if (_.isFunction(viewOptions)) {
          return viewOptions.call(this, {
            model: model,
            column: column
          });
        } else {
          return viewOptions;
        }
      }
    }, {
      mixins: ['Row.ViewMixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
