(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/mixins/evented', 'oraculum/mixins/evented-method'], function(oraculum) {
    'use strict';
    var _, getOptions;
    _ = oraculum.get('underscore');
    getOptions = function() {
      var options;
      options = this.mixinOptions.syncClass;
      if (_.isFunction(options)) {
        options = options.call(this);
      }
      return options;
    };
    return oraculum.defineMixin('SyncClass.ViewMixin', {
      mixinOptions: {
        syncClass: {
          emitter: null,
          selector: null
        },
        eventedMethods: {
          render: {}
        }
      },
      mixconfig: function(arg, arg1) {
        var ref, syncClass, syncEmitter, syncSelector;
        syncClass = arg.syncClass;
        ref = arg1 != null ? arg1 : {}, syncEmitter = ref.syncEmitter, syncSelector = ref.syncSelector;
        if (syncEmitter != null) {
          syncClass.emitter = syncEmitter;
        }
        if (syncSelector != null) {
          return syncClass.selector = syncSelector;
        }
      },
      mixinitialize: function() {
        this.on('render:after', this.updateSyncClass, this);
        return this.setSyncEmitter();
      },
      setSyncEmitter: function(emitter) {
        if (!(emitter != null ? emitter : emitter = getOptions.call(this).emitter)) {
          return;
        }
        if (this._syncClassEmitter) {
          this.stopListening(this._syncClassEmitter, 'syncStateChange', this.updateSyncClass);
        }
        this._syncClassEmitter = emitter;
        this.listenTo(emitter, 'syncStateChange', this.updateSyncClass);
        return this.updateSyncClass();
      },
      updateSyncClass: function() {
        var $target, selector;
        if (!this._syncClassEmitter) {
          return;
        }
        selector = getOptions.call(this).selector;
        $target = selector != null ? this.$(selector) : this.$el;
        $target.toggleClass('synced', this._syncClassEmitter.isSynced());
        $target.toggleClass('syncing', this._syncClassEmitter.isSyncing());
        return $target.toggleClass('unsynced', this._syncClassEmitter.isUnsynced());
      }
    }, {
      mixins: ['Evented.Mixin', 'EventedMethod.Mixin']
    });
  });

}).call(this);
