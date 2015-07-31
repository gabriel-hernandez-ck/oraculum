(function() {
  define(['oraculum', 'jquery'], function(Oraculum, $) {
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
    Oraculum.resolveViewTarget = function(view, target) {
      if (typeof target === 'function') {
        target = target.call(view);
      }
      if (target instanceof $) {
        return target;
      }
      if (_.isElement(target)) {
        return $(target);
      }
      if (target != null) {
        return view.$(target);
      } else {
        return view.$el;
      }
    };
    return Oraculum.define('resolveViewTarget', (function() {
      if (typeof console !== "undefined" && console !== null) {
        if (typeof console.warn === "function") {
          console.warn('Oraculum resolveViewTarget definition has been superceded by the\nOraculum.resolveViewTarget instance method.\nThis factory definition will be removed in 2.x');
        }
      }
      return Oraculum.resolveViewTarget;
    }), {
      singleton: true
    });
  });

}).call(this);
