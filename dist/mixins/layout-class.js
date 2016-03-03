(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/mixins/pub-sub', 'oraculum/mixins/evented-method'], function(oraculum) {
    'use strict';
    var _;
    _ = oraculum.get('underscore');
    oraculum.defineMixin('ResetLayoutClass.ControllerMixin', {
      mixinOptions: {
        eventedMethods: {
          beforeAction: {}
        }
      },
      mixinitialize: function() {
        return this.on('beforeAction:before', (function(_this) {
          return function() {
            return _this.publishEvent('!resetLayoutClass');
          };
        })(this));
      }
    }, {
      mixins: ['PubSub.Mixin', 'EventedMethod.Mixin']
    });
    oraculum.defineMixin('RouteLayoutClass.ControllerMixin', {
      mixinOptions: {
        eventedMethods: {
          beforeAction: {}
        }
      },
      mixinitialize: function() {
        var remove, replace;
        replace = /[^\w]+/g;
        remove = /\.?controller/ig;
        return this.on('beforeAction:after', (function(_this) {
          return function(p, arg) {
            var action, controller, prevAction, prevController, previous;
            controller = arg.controller, action = arg.action, previous = arg.previous;
            prevAction = prevController = 'unknown';
            if ((previous != null ? previous.action : void 0) != null) {
              prevAction = previous.action;
            }
            if ((previous != null ? previous.controller : void 0) != null) {
              prevController = previous.controller;
            }
            action = action.toLowerCase();
            prevAction = prevAction.toLowerCase();
            controller = controller.replace(remove, '').toLowerCase();
            prevController = prevController.replace(remove, '').toLowerCase();
            return _this.publishEvent('!addLayoutClass', [(action.replace(replace, '-')) + "-action", (controller.replace(replace, '-')) + "-controller", (prevAction.replace(replace, '-')) + "-prev-action", (prevController.replace(replace, '-')) + "-prev-controller"].join(' '));
          };
        })(this));
      }
    }, {
      mixins: ['PubSub.Mixin', 'EventedMethod.Mixin']
    });
    return oraculum.defineMixin('LayoutClass.LayoutMixin', {
      mixinitialize: function() {
        this.subscribeEvent('!addLayoutClass', this.addClass);
        this.subscribeEvent('!resetLayoutClass', this.resetClass);
        this.subscribeEvent('!removeLayoutClass', this.removeClass);
        return this.subscribeEvent('!toggleLayoutClass', this.toggleClass);
      },
      resetClass: function() {
        return this.$el.attr('class', _.result(this, 'className') || '');
      },
      addClass: function() {
        var ref;
        return (ref = this.$el).addClass.apply(ref, arguments);
      },
      removeClass: function() {
        var ref;
        return (ref = this.$el).removeClass.apply(ref, arguments);
      },
      toggleClass: function() {
        var ref;
        return (ref = this.$el).toggleClass.apply(ref, arguments);
      }
    }, {
      mixins: ['PubSub.Mixin']
    });
  });

}).call(this);
