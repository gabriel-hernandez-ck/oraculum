(function() {
  define(['oraculum'], function(Oraculum) {
    'use strict';
    return Oraculum.define('composeConfig', (function() {
      if (typeof console !== "undefined" && console !== null) {
        if (typeof console.warn === "function") {
          console.warn('Oraculum composeConfig definition has been superceded by the\nOraculum.composeConfig class/instance method provided by FactoryJS.\nThis factory definition will be removed in 2.x');
        }
      }
      return Oraculum.composeConfig;
    }), {
      singleton: true
    });
  });

}).call(this);
