define [
  'oraculum'
  'oraculum/libs'
], (Oraculum) ->
  'use strict'

  describe 'resolveViewTarget', ->
    view = null
    divTarget = null
    resolveViewTarget = null

    beforeEach ->
      view = Oraculum.get 'View'
      view.$el.html '<div class="target"/>'
      divTarget = view.$ '.target'
      resolveViewTarget = Oraculum.get 'resolveViewTarget'

    afterEach ->
      view.__mixin 'Disposable.Mixin'
      view.dispose()

    it 'should resolve a nullish to view.$el', ->
      expect(resolveViewTarget view).toBeMatchedBy view.$el
      expect(resolveViewTarget view, null).toBeMatchedBy view.$el

    it 'should resolve a selector to an element', ->
      expect(resolveViewTarget view, '.target').toBeMatchedBy divTarget

    it 'should resolve a jQuery element to an element', ->
      expect(resolveViewTarget view, divTarget).toBeMatchedBy divTarget

    it 'should resolve an element to an element', ->
      expect(resolveViewTarget view, divTarget[0]).toBeMatchedBy divTarget

    it 'should resolve a function to an element', ->
      expect(resolveViewTarget view, -> null).toBeMatchedBy view.$el
      expect(resolveViewTarget view, -> '.target').toBeMatchedBy divTarget
      expect(resolveViewTarget view, -> divTarget).toBeMatchedBy divTarget
      expect(resolveViewTarget view, -> divTarget[0]).toBeMatchedBy divTarget
