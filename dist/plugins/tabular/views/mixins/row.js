(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/views/mixins/list', 'oraculum/views/mixins/static-classes'], function(Oraculum) {
    'use strict';
    var composeConfig;
    composeConfig = Oraculum.get('composeConfig');

    /*
    Row.ViewMixin
    =============
     */
    return Oraculum.defineMixin('Row.ViewMixin', {
      mixinOptions: {
        staticClasses: ['row-mixin']
      },
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
        viewOptions = composeConfig({
          model: model,
          column: column
        }, viewOptions, columnOptions);
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
      mixins: ['List.ViewMixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
