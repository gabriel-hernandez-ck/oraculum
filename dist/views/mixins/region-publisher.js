(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/mixins/callback-provider'], function(Oraculum) {
    'use strict';
    var _;
    _ = Oraculum.get('underscore');
    return Oraculum.defineMixin('RegionPublisher.ViewMixin', {
      mixconfig: function(mixinOptions, arg) {
        var regions;
        regions = (arg != null ? arg : {}).regions;
        return mixinOptions.regions = Oraculum.composeConfig(mixinOptions.regions, regions);
      },
      mixinitialize: function() {
        var regions;
        regions = this.mixinOptions.regions;
        if (_.isFunction(regions)) {
          regions = regions.call(this);
        }
        if (regions != null) {
          this.executeCallback('region:register', this);
        }
        return this.on('dispose', (function(_this) {
          return function() {
            return _this.unregisterAllRegions.apply(_this, arguments);
          };
        })(this));
      },
      registerRegion: function(name, selector) {
        return this.executeCallback('region:register', this, name, selector);
      },
      unregisterRegion: function(name) {
        return this.executeCallback('region:unregister', this, name);
      },
      unregisterAllRegions: function() {
        return this.executeCallback('region:unregister', this);
      }
    }, {
      mixins: ['CallbackDelegate.Mixin']
    });
  });

}).call(this);
