(function() {
  define(['oraculum', 'oraculum/views/mixins/list', 'oraculum/views/mixins/static-classes'], function(Oraculum) {
    'use strict';

    /*
    Row.ViewMixin
    =============
     */
    return Oraculum.defineMixin('Row.ViewMixin', {
      mixinOptions: {
        staticClasses: ['row-mixin']
      },
      resolveModelView: function(column) {
        var modelView, viewOptions, _ref;
        _ref = this.mixinOptions.list, modelView = _ref.modelView, viewOptions = _ref.viewOptions;
        return column.get('modelView') || modelView;
      },
      initModelView: function(column) {
        var model, modelView, viewOptions;
        modelView = this.resolveModelView(column);
        if (!modelView) {
          throw new TypeError('Row.ViewMixin modelView option must be defined.');
        }
        model = this.model || column;
        viewOptions = this.mixinOptions.list.viewOptions;
        viewOptions = _.isFunction(viewOptions) ? viewOptions.call(this, {
          model: model,
          column: column
        }) : _.extend({
          model: model,
          column: column
        }, viewOptions);
        viewOptions = _.extend({}, viewOptions, column.get('viewOptions'));
        return this.createView({
          view: modelView,
          viewOptions: viewOptions
        });
      }
    }, {
      mixins: ['List.ViewMixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
