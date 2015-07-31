(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/mixins/evented-method'], function(Oraculum) {
    'use strict';
    var _;
    _ = Oraculum.get('underscore');

    /*
    Freezable.Mixin
    ===============
    Allow an object to be frozen immediately after construction and provide
    a freezable interface.
     */
    return Oraculum.defineMixin('Freezable.Mixin', {

      /*
      Mixin Options
      -------------
      Allow the object to be configured to be frozen immediately after
      construction. Default to false.
       */
      mixinOptions: {
        freeze: false
      },

      /*
      Minitialize
      -----------
      Configure the instance and perform the freeze operation.
       */
      mixinitialize: function() {
        if (this.mixinOptions.freeze !== true) {
          return;
        }
        return _.defer((function(_this) {
          return function() {
            return _this.freeze();
          };
        })(this));
      },

      /*
      Freeze
      ------
      The freeze interface.
      Invoke the freezse method on this instance if it's available.
       */
      freeze: function() {
        return typeof Object.freeze === "function" ? Object.freeze(this) : void 0;
      },

      /*
      Is Frozen
      ---------
      Check to see if this instance is frozen.
      
      @return {Boolean} Whether this instance is frozen.
       */
      isFrozen: function() {
        return typeof Object.isFrozen === "function" ? Object.isFrozen(this) : void 0;
      }
    });
  });

}).call(this);
