(function() {
  define(['oraculum', 'jquery', 'backbone', 'underscore', 'oraculum/extensions/compose-config', 'oraculum/extensions/resolve-view-target', 'oraculum/extensions/make-evented-method', 'oraculum/extensions/make-middleware-method'], function(Oraculum, jQuery, Backbone, _) {
    'use strict';
    Oraculum.define('jQuery', (function() {
      return jQuery;
    }), {
      singleton: true
    });
    Oraculum.define('Backbone', (function() {
      return Backbone;
    }), {
      singleton: true
    });
    return Oraculum.define('underscore', (function() {
      return _;
    }), {
      singleton: true
    });
  });

}).call(this);
