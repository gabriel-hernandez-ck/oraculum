(function() {
  define(['oraculum', 'oraculum/libs'], function(Oraculum) {
    'use strict';
    var _, composeConfig;
    _ = Oraculum.get('underscore');
    composeConfig = Oraculum.get('composeConfig');

    /*
    AutoFetch.ModelMixin
    ====================
    Automatically fetch a model as soon as it's created.
     */
    return Oraculum.defineMixin('AutoFetch.ModelMixin', {

      /*
      Mixin Options
      -------------
      Allow the autoFetch behavior to be configured on a definition.
       */
      mixinOptions: {
        autoFetch: {
          fetch: true,
          fetchOptions: null
        }
      },

      /*
      Mixconfig
      ---------
      Allow autoFetch options to passed in the contructor options.
      
      @param {Boolean} autoFetch Set the `fetch` flag.
      @param {Object} fetchOptions Extend the default fetchOptions.
       */
      mixconfig: function(arg, attrs, arg1) {
        var autoFetch, fetch, fetchOptions, ref;
        autoFetch = arg.autoFetch;
        ref = arg1 != null ? arg1 : {}, fetch = ref.autoFetch, fetchOptions = ref.fetchOptions;
        if (fetch != null) {
          autoFetch.fetch = fetch;
        }
        return autoFetch.fetchOptions = composeConfig(autoFetch.fetchOptions, fetchOptions);
      },

      /*
      Mixinitialize
      -------------
      Automatically fetch the model if we're still confugred to do so.
       */
      mixinitialize: function() {
        var fetch, fetchOptions, ref;
        ref = this.mixinOptions.autoFetch, fetch = ref.fetch, fetchOptions = ref.fetchOptions;
        if (_.isFunction(fetchOptions)) {
          fetchOptions = fetchOptions.call(this);
        }
        if (fetch) {
          return this.fetch(fetchOptions);
        }
      }
    });
  });

}).call(this);
