(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/mixins/evented-method'], function(Oraculum) {
    'use strict';
    var _;
    _ = Oraculum.get('underscore');

    /*
    DisposeRemoved.CollectionMixin
    ==============================
    Automatically `dispose` a `Model` that has been removed from a `Collection`.
    This mixin is intended to be used at the `Collection` layer so that it can
    ensure that it's not disposing of `Model`s that may have been removed from
    a separate `Collection`.
     */
    return Oraculum.defineMixin('DisposeRemoved.CollectionMixin', {

      /*
      Mixin Options
      -------------
      Allow the `disposeRemoved` flag to be set on the definition.
       */
      mixinOptions: {
        disposeRemoved: true,
        eventedMethods: {
          reset: {},
          remove: {}
        }
      },

      /*
      Mixconfig
      ---------
      Allow the `disposeRemoved` flag to be set in the constructor options.
      
      @param {Boolean} disposeRemoved Whether or not to `dispose` removed `Model`s.
       */
      mixconfig: function(mixinOptions, models, arg) {
        var disposeRemoved;
        disposeRemoved = (arg != null ? arg : {}).disposeRemoved;
        if (disposeRemoved != null) {
          return mixinOptions.disposeRemoved = disposeRemoved;
        }
      },

      /*
      Mixinitialize
      -------------
      Set up an event listener to respond to `remove:after` events by invoking
      `dispose` on the removed `Model`s.
      Additionally, add an event listener to respond to `reset:after` events by
      invoking `dispose` on `Model`s that were removed during the `reset`.
      By design, this will throw if the target model does not impement the
      `dispose` method.
       */
      mixinitialize: function() {
        if (this.mixinOptions.disposeRemoved) {
          return this.enableDisposeRemoved();
        } else {
          return this.disableDisposeRemoved();
        }
      },
      enableDisposeRemoved: function() {
        this.on('reset', this.disposeRemovedReset, this);
        return this.on('remove:after', this.disposeRemoved, this);
      },
      disableDisposeRemoved: function() {
        this.off('reset', this.disposeRemovedReset, this);
        return this.off('remove:after', this.disposeRemoved, this);
      },
      disposeRemovedReset: function(target, arg) {
        var previousModels;
        previousModels = arg.previousModels;
        return this.once('reset:after', (function(_this) {
          return function() {
            return _this.disposeRemoved(previousModels);
          };
        })(this));
      },
      disposeRemoved: function(models) {
        var i, len, model, results;
        if (!_.isArray(models)) {
          models = [models];
        }
        results = [];
        for (i = 0, len = models.length; i < len; i++) {
          model = models[i];
          results.push(model.dispose());
        }
        return results;
      }
    }, {
      mixins: ['EventedMethod.Mixin']
    });
  });

}).call(this);
