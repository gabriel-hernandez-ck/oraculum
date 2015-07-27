define ['oraculum'], (Oraculum) ->
  'use strict'

  describe 'RegionAttach.ViewMixin', ->

    Oraculum.extend 'View', 'RegionAttach.Test.View', {
      mixinOptions: attach: region: 'region1'
    }, mixins: [
      'Disposable.Mixin'
      'RegionAttach.ViewMixin'
    ]

    listener = null
    beforeEach -> listener = Oraculum.get 'Listener.SpecHelper'
    afterEach -> listener.dispose()

    describe 'mixin configuration', ->
      view = null
      beforeEach -> view = Oraculum.get 'RegionAttach.Test.View'
      afterEach -> view.dispose()

      it 'should use Attach.ViewMixin', -> expect(view).toUseMixin 'Attach.ViewMixin'
      it 'should use EventedMethod.Mixin', -> expect(view).toUseMixin 'EventedMethod.Mixin'
      it 'should use CallbackDelegate.Mixin', -> expect(view).toUseMixin 'CallbackDelegate.Mixin'

    describe 'initialization', ->

      it 'should read region at construction', ->
        view = Oraculum.get 'RegionAttach.Test.View', region: 'region2'
        expect(view.mixinOptions.attach.region).toBe 'region2'
        view.dispose()

    describe 'on attach', ->

      it 'should execute the region:show callback with the target region/instance', ->
        view = Oraculum.get 'RegionAttach.Test.View'
        listener.provideCallback 'region:show', (region, instance) ->
          expect(region).toBe 'region1'
          expect(instance).toBe view
        view.attach()
        view.dispose()
