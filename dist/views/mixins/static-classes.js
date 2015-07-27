(function() {
  define(['oraculum', 'oraculum/libs'], function(Oraculum) {
    'use strict';
    var _;
    _ = require('underscore');
    return Oraculum.defineMixin('StaticClasses.ViewMixin', {
      mixinOptions: {
        staticClasses: []
      },
      mixinitialize: function() {
        return this._setStaticClasses();
      },
      _setStaticClasses: function() {
        var staticClasses;
        staticClasses = this.mixinOptions.staticClasses;
        if (_.isString(staticClasses)) {
          staticClasses = staticClasses.split(' ');
        }
        staticClasses = [].concat(staticClasses, this._getTagClasses());
        return this.$el.addClass(_.chain(staticClasses).compact().uniq().value().join(' '));
      },
      _getTagClasses: function() {
        var staticTags;
        staticTags = [].concat(this.__tags(), this.__mixins());
        return _.map(staticTags, function(tag) {
          var regions;
          regions = tag.split(/[^\w]/);
          return _.map(regions, function(region) {
            var words;
            words = region.match(/[A-Z]?[a-z]*/g);
            return _.chain(words).compact().map(function(value) {
              return value.toLowerCase();
            }).value().join('-');
          }).join('_');
        });
      }
    });
  });

}).call(this);
