(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/views/mixins/list'], function(Oraculum) {
    'use strict';

    /*
    Row.ViewMixin
    =============
     */
    return Oraculum.defineMixin('Row.ViewMixin', {
      resolveModelView: function(column) {
        var modelView, ref, viewOptions;
        ref = this.mixinOptions.list, modelView = ref.modelView, viewOptions = ref.viewOptions;
        return column.get('modelView') || modelView;
      },
      resolveViewOptions: function(column) {
        var columnOptions, model, viewOptions;
        model = this.model || column;
        columnOptions = column.get('viewOptions');
        viewOptions = this.mixinOptions.list.viewOptions;
        viewOptions = Oraculum.composeConfig({
          model: model,
          column: column
        }, viewOptions, columnOptions);
        if (_.isFunction(viewOptions)) {
          viewOptions = viewOptions.call(this, {
            model: model,
            column: column
          });
        }
        return viewOptions;
      }
    }, {
      mixins: ['List.ViewMixin']
    });
  });

}).call(this);
