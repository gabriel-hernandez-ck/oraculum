(function() {
  define(['oraculum', 'oraculum/libs'], function(oraculum) {
    'use strict';
    var _;
    _ = oraculum.get('underscore');
    return oraculum.defineMixin('ViewComposer.ControllerMixin', {

      /* Example configuration
      mixinOptions:
        viewComposer:
          someView:
            view: 'View'
            eventName: 'beforeAction:after'
            waitsForPromise: true
            viewOptions: {}
       */
      mixinOptions: {
        viewComposer: {}
      },
      mixinitialize: function() {
        return _.each(this.mixinOptions.viewComposer, (function(_this) {
          return function(spec, name) {
            var composeView, eventName, view, viewOptions, waitsForPromise;
            if (_.isFunction(spec)) {
              spec = spec.call(_this);
            }
            eventName = spec.eventName, view = spec.view, viewOptions = spec.viewOptions, waitsForPromise = spec.waitsForPromise;
            composeView = function() {
              return _this.reuse(name, view, viewOptions);
            };
            return _this.on(eventName, function() {
              var eventedProxy, ref;
              eventedProxy = _.findWhere(arguments, {
                type: 'evented_proxy'
              });
              if (((eventedProxy != null ? (ref = eventedProxy.result) != null ? ref.then : void 0 : void 0) != null) && waitsForPromise !== false) {
                return eventedProxy.result.then(composeView);
              } else {
                return composeView();
              }
            });
          };
        })(this));
      }
    });
  });

}).call(this);
