define ['oraculum'], (Oraculum) ->
  'use strict'

  describe 'RemoveDisposed.ViewMixin', ->

    Oraculum.extend 'View', 'RemoveDisposed.Test.View', {
      mixinOptions: disposable: keepElement: 'truthyValue'
      remove: remove = sinon.stub()
    }, mixins: [
      'Disposable.Mixin'
      'RemoveDisposed.ViewMixin'
    ]

    view = null
    beforeEach ->
      view = Oraculum.get 'RemoveDisposed.Test.View'
      remove.reset()

    afterEach ->
      view.dispose()

    it 'should use Evented.Mixin', ->
      expect(view).toUseMixin 'Evented.Mixin'

    it 'should remove the element on `dispose` when keepElement is `false`', ->
      view = Oraculum.get 'RemoveDisposed.Test.View', keepElement: false
      expect(view.mixinOptions.disposable.keepElement).toBe false
      view.dispose()
      expect(remove).toHaveBeenCalledOnce()

    it 'should not remove the element on `dispose` when keepElement is not `false`', ->
      view = Oraculum.get 'RemoveDisposed.Test.View'
      expect(view.mixinOptions.disposable.keepElement).toBe 'truthyValue'
      view.dispose()
      expect(remove).toHaveBeenCalledOnce()

    it 'should not remove the element on `dispose` when keepElement is `true`', ->
      view = Oraculum.get 'RemoveDisposed.Test.View', keepElement: true
      expect(view.mixinOptions.disposable.keepElement).toBe true
      view.dispose()
      expect(remove).not.toHaveBeenCalled()

