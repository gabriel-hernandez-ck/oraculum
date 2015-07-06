define [
  'oraculum'
  'jquery'
  'backbone'
  'underscore'
  'oraculum/extensions/compose-config'
  'oraculum/extensions/resolve-view-target'
  'oraculum/extensions/make-evented-method'
  'oraculum/extensions/make-middleware-method'
], (Oraculum, jQuery, Backbone, _) ->
  'use strict'

  # Libs
  # ====
  # By packing all of our libs into the Oraculum container, we can skirt around
  # the nuisance of requiring each of them explicitly in our define[] blocks
  # and simply request a reference to the library from Oraculum.
  # It lends itself well to more readable code.

  Oraculum.define 'jQuery', (-> jQuery),
    singleton: true
    tags: ['vendor']

  Oraculum.define 'Backbone', (-> Backbone),
    singleton: true
    tags: ['vendor']

  Oraculum.define 'underscore', (-> _),
    singleton: true
    tags: ['vendor']
