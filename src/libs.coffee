define [
  'oraculum'
  'oraculum/extensions/compose-config'
  'oraculum/extensions/resolve-view-target'
  'oraculum/extensions/make-evented-method'
  'oraculum/extensions/make-middleware-method'
], (Oraculum) ->
  'use strict'

  # Libs
  # ====
  # All of our vendor libs are already included as definitions on
  # BackboneFactory via FactoryJS 1.1.9.
  # This file is used as a requirejs shim to load our extensions.
