(function() {
  define(['oraculum'], function(oraculum) {
    'use strict';
    return oraculum.defineMixin('CacheResponseHeaders.ModelMixin', {
      mixinOptions: {
        cacheResponseHeaders: []
      },
      mixinitialize: function() {
        this.responseHeaders = this.__factory().get('Model');
        this.on('dispose', (function(_this) {
          return function() {
            var base;
            return typeof (base = _this.responseHeaders).dispose === "function" ? base.dispose() : void 0;
          };
        })(this));
        return this.on('sync', (function(_this) {
          return function(model, response, arg) {
            var xhr;
            xhr = arg.xhr;
            return _this.responseHeaders.set(_.chain(_this.mixinOptions.cacheResponseHeaders).map(function(headerName) {
              return [headerName, xhr.getResponseHeader(headerName)];
            }).object().value());
          };
        })(this));
      }
    });
  });

}).call(this);
