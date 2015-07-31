(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/mixins/evented', 'oraculum/mixins/evented-method'], function(Oraculum) {
    'use strict';
    var _;
    _ = Oraculum.get('underscore');
    return Oraculum.defineMixin('DOMCache.ViewMixin', {
      mixinOptions: {
        eventedMethods: {
          render: {}
        }
      },
      mixconfig: function(mixinOptions, arg) {
        var domcache;
        domcache = (arg != null ? arg : {}).domcache;
        return mixinOptions.domcache = Oraculum.composeConfig(mixinOptions.domcache, domcache);
      },
      mixinitialize: function() {
        return this.on('render:after', this.cacheDOM, this);
      },
      cacheDOM: function() {
        var configOptions;
        this.domcache = {};
        configOptions = this.mixinOptions.domcache;
        if (_.isFunction(configOptions)) {
          configOptions = configOptions.call(this);
        }
        _.each(this.$('[data-cache]'), this.cacheElement, this);
        _.each(configOptions, this.cacheElement, this);
        return this.trigger('domcache', this);
      },
      cacheElement: function(element, name) {
        var $element;
        $element = this.$(element);
        if (_.isElement(element)) {
          name = $element.attr('data-cache');
        }
        if (name && $element.length) {
          return this.domcache[name] = $element;
        }
      }
    }, {
      mixins: ['Evented.Mixin', 'EventedMethod.Mixin']
    });
  });

}).call(this);
