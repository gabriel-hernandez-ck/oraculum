define ['oraculum'], (Oraculum) ->
  'use strict'

  Oraculum.define 'Listener.SpecHelper', (class Listener
    constructor: -> # nop
  ), mixins:[
    'PubSub.Mixin'
    'Listener.Mixin'
    'Disposable.Mixin'
    'CallbackProvider.Mixin'
    'CallbackDelegate.Mixin'
  ]
