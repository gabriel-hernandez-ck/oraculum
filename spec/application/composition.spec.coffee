define [
  'oraculum'
  'oraculum/application/composition'
], (Oraculum) ->
  'use strict'

  describe 'Composition', ->

    composition = null
    beforeEach -> composition = Oraculum.get 'Composition'
    afterEach -> composition.dispose()

    it 'should use Evented.Mixin', -> expect(composition).toUseMixin 'Evented.Mixin'
    it 'should use Disposable.Mixin', -> expect(composition).toUseMixin 'Disposable.Mixin'

    it 'should initialize', ->
      expect(composition.stale()).toBeFalse()
      expect(composition.item).toBe composition
