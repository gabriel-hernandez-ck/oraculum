(function() {
  define(['oraculum', 'oraculum/mixins/pub-sub'], function(oraculum) {
    'use strict';
    return oraculum.defineMixin('Polling.ModelMixin', {
      mixinOptions: {
        polling: {
          interval: 2000
        }
      },
      mixconfig: function(arg, attrs, arg1) {
        var polling, pollingInterval;
        polling = arg.polling;
        pollingInterval = (arg1 != null ? arg1 : {}).pollingInterval;
        if (pollingInterval != null) {
          return polling.interval = pollingInterval;
        }
      },
      mixinitialize: function() {
        var pollingPaused;
        pollingPaused = false;
        this.subscribeEvent('polling:pause', (function(_this) {
          return function() {
            pollingPaused = _this._polling;
            return _this.stopPolling();
          };
        })(this));
        this.subscribeEvent('polling:resume', (function(_this) {
          return function() {
            if (pollingPaused) {
              return _this.startPolling();
            }
          };
        })(this));
        return this.on('dispose', this.stopPolling, this);
      },
      startPolling: function() {
        var fetch;
        if (this._polling) {
          return;
        }
        this._polling = true;
        fetch = _.debounce(((function(_this) {
          return function() {
            if (!_this._polling) {
              return;
            }
            _this._pollingXHR = _this.fetch();
            return _this._pollingXHR.always(fetch);
          };
        })(this)), this.mixinOptions.polling.interval);
        fetch();
        this.trigger('startPolling', this);
        return this;
      },
      stopPolling: function() {
        var ref;
        if (!this._polling) {
          return;
        }
        this._polling = false;
        if ((ref = this._pollingXHR) != null) {
          ref.abort();
        }
        this.trigger('stopPolling', this);
        return this;
      }
    }, {
      mixins: ['PubSub.Mixin']
    });
  });

}).call(this);
