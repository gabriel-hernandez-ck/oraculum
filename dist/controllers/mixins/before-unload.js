(function() {
  var slice = [].slice;

  define(['oraculum', 'oraculum/mixins/pub-sub'], function(oraculum) {
    'use strict';
    return oraculum.defineMixin('BeforeUnload.ControllerMixin', {
      mixinOptions: {
        beforeUnload: {
          message: 'Are you sure you want to do that?',
          deferredCallback: function(message) {
            return alert(message);
          }
        }
      },
      mixinitialize: function() {
        return this.on('dispose', this.removeBeforeUnload, this);
      },
      addBeforeUnload: function() {
        this.subscribeEvent('router:route:middleware:before', this._routeStarted);
        this.subscribeEvent('router:route:middleware:defer', this._routeDeferred);
        return window.onbeforeunload = (function(_this) {
          return function() {
            return _this.mixinOptions.beforeUnload.message;
          };
        })(this);
      },
      removeBeforeUnload: function() {
        this.unsubscribeEvent('router:route:middleware:before', this._routeStarted);
        this.unsubscribeEvent('router:route:middleware:defer', this._routeDeferred);
        return window.onbeforeunload = function() {};
      },
      _routeStarted: function() {
        var proxy;
        proxy = this._findProxy.apply(this, arguments);
        return proxy.wait = true;
      },
      _routeDeferred: function() {
        var message, proxy;
        proxy = this._findProxy.apply(this, arguments);
        message = this.mixinOptions.beforeUnload.message;
        return this.mixinOptions.beforeUnload.deferredCallback(message);
      },
      _findProxy: function() {
        var args;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        return _.find(args, function(arg) {
          return arg.type === 'middleware_proxy';
        });
      }
    }, {
      mixins: ['PubSub.Mixin']
    });
  });

}).call(this);
