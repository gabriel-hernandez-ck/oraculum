(function() {
  var slice = [].slice;

  define(['oraculum', 'underscore'], function(Oraculum, _) {
    'use strict';
    return Oraculum.define('composeConfig', (function() {
      var composeConfig;
      composeConfig = function() {
        var args, defaultConfig, overrideConfig;
        defaultConfig = arguments[0], overrideConfig = arguments[1], args = 3 <= arguments.length ? slice.call(arguments, 2) : [];
        if (_.isFunction(defaultConfig)) {
          defaultConfig = defaultConfig.apply(this, args);
        }
        if (_.isFunction(overrideConfig)) {
          overrideConfig = overrideConfig.apply(this, args);
        }
        if (_.isArray(defaultConfig) && _.isArray(overrideConfig)) {
          return [].concat(defaultConfig, overrideConfig);
        } else {
          return _.extend({}, defaultConfig, overrideConfig);
        }
      };
      return function() {
        var defaultConfig, overrideConfigs;
        defaultConfig = arguments[0], overrideConfigs = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        return _.reduce(overrideConfigs, (function(defaultConfig, overrideConfig) {
          if (_.isFunction(defaultConfig) || _.isFunction(overrideConfig)) {
            return function() {
              return composeConfig.call.apply(composeConfig, [this, defaultConfig, overrideConfig].concat(slice.call(arguments)));
            };
          } else {
            return composeConfig(defaultConfig, overrideConfig);
          }
        }), defaultConfig);
      };
    }), {
      singleton: true
    });
  });

}).call(this);
