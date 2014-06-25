(function() {
  define(['oraculum'], function(Oraculum) {
    'use strict';
    Oraculum.define('jQuery', (function() {
      return require('jquery');
    }), {
      singleton: true
    });
    Oraculum.define('Backbone', (function() {
      return require('backbone');
    }), {
      singleton: true
    });
    return Oraculum.define('underscore', (function() {
      return require('underscore');
    }), {
      singleton: true
    });
  });

}).call(this);
