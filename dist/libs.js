(function() {
  define(['oraculum', 'jquery', 'backbone', 'underscore', 'oraculum/extensions/compose-config', 'oraculum/extensions/resolve-view-target', 'oraculum/extensions/make-evented-method', 'oraculum/extensions/make-middleware-method'], function(Oraculum, jQuery, Backbone, _) {
    'use strict';
    Oraculum.define('jQuery', (function() {
      return jQuery;
    }), {
      singleton: true,
      tags: ['vendor']
    });
    Oraculum.define('Backbone', (function() {
      return Backbone;
    }), {
      singleton: true,
      tags: ['vendor']
    });
    return Oraculum.define('underscore', (function() {
      return _;
    }), {
      singleton: true,
      tags: ['vendor']
    });
  });

}).call(this);
