(function() {
  define(['oraculum'], function(Oraculum) {
    'use strict';

    /*
    Resolve View Target
    ===================
    This function is a helper for arbitrary `View`s that makes the issue of
    resolving a target element in a view simpler when dealing with mixed types.
    Many mixins use this behavior to resolve '.class', `Element` or
    `jQueryElement` references to a `jQueryElement` in a particular `View`s scope.
    Additionally, a `null`, `false`, `undefined`, etc target will return the
    `View`s root element ($el).
    
    @param {View} view The object that contains the targeted method.
    @param {null|false|undefined|String|Element|jQueryElement|Function} target Something that resembles an element or selector.
     */
    return Oraculum.define('resolveViewTarget', (function() {
      return function(view, target) {
        if (typeof target === 'function') {
          target = target.call(view);
        }
        if (target != null) {
          return view.$(target);
        } else {
          return view.$el;
        }
      };
    }), {
      singleton: true
    });
  });

}).call(this);
