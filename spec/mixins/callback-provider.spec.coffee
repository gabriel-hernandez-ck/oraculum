define ['oraculum'], (Oraculum) ->
  'use strict'

  describe 'CallbackProvider.Mixin, CallbackDelegate.Mixin', ->
    view = null
    listener = null
    callback1 = sinon.stub()
    callback2 = sinon.stub()

    Oraculum.extend 'View', 'CallbackProvider.Test.View', {
      callback1: callback1
      mixinOptions: provideCallbacks: {'callback1', callback2}
    }, mixins: [
      'Disposable.Mixin'
      'CallbackProvider.Mixin'
    ]

    beforeEach ->
      listener = Oraculum.get 'Listener.SpecHelper'
      view = Oraculum.get 'CallbackProvider.Test.View'
      callback1.reset()
      callback2.reset()

    afterEach ->
      view.dispose()
      listener.dispose()

    it 'should provide callbacks as configured', ->
      listener.executeCallback 'callback1'
      listener.executeCallback 'callback2'
      expect(callback1).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledOn view

    it 'should provide a single callback', ->
      stub = sinon.stub()
      view.provideCallback 'stub', stub, sinon
      listener.executeCallback 'stub'
      expect(stub).toHaveBeenCalledOnce()
      expect(stub).toHaveBeenCalledOn sinon

    it 'should throw an error for an invalid callback', ->
      Oraculum.extend 'View', 'InvalidCallbackProvider.Test.View', {
      mixinOptions: provideCallbacks: callback: 'noSuchFunction'
      }, mixins: ['Disposable.Mixin','CallbackProvider.Mixin']
      expect(-> view.provideCallback()).toThrow()
      expect(-> view.provideCallback null).toThrow()
      expect(-> view.provideCallback 'string', null).toThrow()
      expect(-> view.provideCallback 'string', 'string').toThrow()
      view.dispose()
      expect(-> Oraculum.get 'InvalidCallbackProvider.Test.View').toThrow()

    it 'should remove callbacks by name', ->
      listener.executeCallback 'callback1'
      listener.executeCallback 'callback2'
      expect(callback1).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledOnce()
      view.removeCallbacks ['callback1']
      expect(-> listener.executeCallback 'callback1').toThrow()
      expect(-> listener.executeCallback 'callback2').not.toThrow()
      expect(callback1).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledTwice()

    it 'should remove callbacks by instance', ->
      callback3 = sinon.stub()
      listener.provideCallback 'callback3', callback3, sinon
      listener.executeCallback 'callback1'
      listener.executeCallback 'callback2'
      listener.executeCallback 'callback3'
      expect(callback1).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledOnce()
      expect(callback3).toHaveBeenCalledOnce()
      view.removeCallbacks view
      expect(-> listener.executeCallback 'callback1').toThrow()
      expect(-> listener.executeCallback 'callback2').toThrow()
      expect(-> listener.executeCallback 'callback3').not.toThrow()
      expect(callback1).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledOnce()
      expect(callback3).toHaveBeenCalledTwice()

    it 'should not throw an error for an invalid callback if silent', ->
      expect(-> listener.executeCallback 'name').toThrow()
      expect(-> listener.executeCallback {'name', silent: false}).toThrow()
      expect(-> listener.executeCallback {'name', silent: true}).not.toThrow()

    it 'should pass arguments to the callback', ->
      listener.provideCallback 'arguments', args = sinon.stub()
      listener.executeCallback 'arguments', 1, 2, 3, 4, 5
      expect(args).toHaveBeenCalledWith 1, 2, 3, 4, 5

    it 'should return the result of the callback', ->
      listener.provideCallback 'result', -> 'result'
      expect(listener.executeCallback 'result').toBe 'result'
