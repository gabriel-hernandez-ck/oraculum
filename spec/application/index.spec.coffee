define ['oraculum'], (Oraculum) ->
  'use strict'

  describe 'Application', ->

    Oraculum.extend 'Application', 'Application.Test.Application', {
    }, inheritMixins: true

    Oraculum.extend 'Router', 'Application.Test.Router', {
      initialize: (@options) -> # noop
    }, inheritMixins: true

    Oraculum.extend 'Dispatcher', 'Application.Test.Dispatcher', {
      initialize: (@options) -> # noop
    }, inheritMixins: true

    Oraculum.extend 'View', 'Application.Test.Layout', {
      initialize: (@options) -> # noop
    }, mixins: ['Disposable.Mixin']

    Oraculum.extend 'Composer', 'Application.Test.Composer', {
      initialize: (@options) -> # noop
    }, inheritMixins: true

    options = null
    application = null
    beforeEach ->
      application = Oraculum.get 'Application.Test.Application', options = {
        router: 'Application.Test.Router'
        dispatcher: 'Application.Test.Dispatcher'
        layout: 'Application.Test.Layout'
        composer: 'Application.Test.Composer'
      }

    afterEach -> application.dispose()

    describe 'mixin configuration', ->
      it 'should use PubSub.Mixin', -> expect(application).toUseMixin 'PubSub.Mixin'
      it 'should use Freezable.Mixin', -> expect(application).toUseMixin 'Freezable.Mixin'
      it 'should use Disposable.Mixin', -> expect(application).toUseMixin 'Disposable.Mixin'

      it 'should set the disposeAll bit to true on the disposable mixin by default', ->
        expect(application.mixinOptions.disposable.disposeAll).toBeTrue()

      it 'should set the freeze bit to true on the freezable mixin by default', ->
        expect(application.mixinOptions.freeze).toBe true
        expect(Object.isFrozen application).toBe true

    describe 'initialization', ->

      it 'should export an instance of the requested Router', ->
        expect(application.router.__type()).toBe 'Application.Test.Router'
        expect(application.router.options).toEqual _.extend {
          root: '/'
          trailing: false
          pushState: window.location.protocol in ['http:', 'https:']
        }, options

      it 'should export an instance of the requested Dispatcher', ->
        expect(application.dispatcher.__type()).toBe 'Application.Test.Dispatcher'
        expect(application.dispatcher.options).toBe options

      it 'should export an instance of the requested Layout', ->
        expect(application.layout.__type()).toBe 'Application.Test.Layout'
        expect(application.layout.options).toBe options

      it 'should export an instance of the requested Composer', ->
        expect(application.composer.__type()).toBe 'Application.Test.Composer'
        expect(application.composer.options).toBe options

      it 'should start the router', ->
        expect(application.started).toBe true
        expect(Backbone.History.started).toBe true
