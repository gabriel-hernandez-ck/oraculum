(function() {
  define(['oraculum', 'oraculum/mixins/pub-sub', 'oraculum/mixins/evented-method'], function(Oraculum) {
    'use strict';
    var $;
    $ = Oraculum.get('jQuery');
    return Oraculum.defineMixin('Attach.ViewMixin', {
      mixinOptions: {
        attach: {
          auto: true,
          container: null,
          containerMethod: 'append'
        },
        eventedMethods: {
          render: {},
          attach: {}
        }
      },
      mixconfig: function(arg, arg1) {
        var attach, autoAttach, container, containerMethod, ref;
        attach = arg.attach;
        ref = arg1 != null ? arg1 : {}, autoAttach = ref.autoAttach, container = ref.container, containerMethod = ref.containerMethod;
        if (autoAttach != null) {
          attach.auto = autoAttach;
        }
        if (container != null) {
          attach.container = container;
        }
        if (containerMethod != null) {
          return attach.containerMethod = containerMethod;
        }
      },
      mixinitialize: function() {
        return this.on('render:after', (function(_this) {
          return function() {
            if (_this.mixinOptions.attach.auto) {
              return _this.attach();
            }
          };
        })(this));
      },
      attach: function() {
        var container, containerMethod, ref;
        ref = this.mixinOptions.attach, container = ref.container, containerMethod = ref.containerMethod;
        if (!(container && containerMethod)) {
          return;
        }
        if (document.body.contains(this.el)) {
          return;
        }
        $(container)[containerMethod](this.el);
        return this.trigger('addedToParent');
      }
    }, {
      mixins: ['EventedMethod.Mixin']
    });
  });

}).call(this);
