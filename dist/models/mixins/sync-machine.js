(function() {
  define(['oraculum'], function(Oraculum) {
    'use strict';
    var STATE_CHANGE, SYNCED, SYNCING, SyncMachine, UNSYNCED, event, fn, i, len, ref;
    SYNCED = 'synced';
    SYNCING = 'syncing';
    UNSYNCED = 'unsynced';
    STATE_CHANGE = 'syncStateChange';
    SyncMachine = {
      mixinitialize: function() {
        this._syncState = UNSYNCED;
        this._previousSyncState = null;
        this.on('request', this.beginSync, this);
        this.on('error', this.abortSync, this);
        return this.on('sync', this.finishSync, this);
      },
      syncState: function() {
        return this._syncState;
      },
      isSynced: function() {
        return this._syncState === SYNCED;
      },
      isSyncing: function() {
        return this._syncState === SYNCING;
      },
      isUnsynced: function() {
        return this._syncState === UNSYNCED;
      },
      unsync: function() {
        var ref;
        if ((ref = this._syncState) !== SYNCING && ref !== SYNCED) {
          return;
        }
        this._previousSync = this._syncState;
        this._syncState = UNSYNCED;
        this.trigger(this._syncState, this, this._syncState);
        return this.trigger(STATE_CHANGE, this, this._syncState);
      },
      beginSync: function() {
        var ref;
        if ((ref = this._syncState) !== UNSYNCED && ref !== SYNCED) {
          return;
        }
        this._previousSync = this._syncState;
        this._syncState = SYNCING;
        this.trigger(this._syncState, this, this._syncState);
        return this.trigger(STATE_CHANGE, this, this._syncState);
      },
      finishSync: function() {
        if (this._syncState !== SYNCING) {
          return;
        }
        this._previousSync = this._syncState;
        this._syncState = SYNCED;
        this.trigger(this._syncState, this, this._syncState);
        return this.trigger(STATE_CHANGE, this, this._syncState);
      },
      abortSync: function() {
        if (this._syncState !== SYNCING) {
          return;
        }
        this._syncState = this._previousSync;
        this._previousSync = this._syncState;
        this.trigger(this._syncState, this, this._syncState);
        return this.trigger(STATE_CHANGE, this, this._syncState);
      }
    };
    ref = [UNSYNCED, SYNCING, SYNCED, STATE_CHANGE];
    fn = function(event) {
      return SyncMachine[event] = function(callback, context) {
        if (context == null) {
          context = this;
        }
        this.on(event, callback, context);
        if (this._syncState === event) {
          return callback.call(context);
        }
      };
    };
    for (i = 0, len = ref.length; i < len; i++) {
      event = ref[i];
      fn(event);
    }
    return Oraculum.defineMixin('SyncMachine.ModelMixin', SyncMachine);
  });

}).call(this);
