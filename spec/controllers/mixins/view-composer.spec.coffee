define [
  'oraculum'

  'oraculum/application/controller'

  'oraculum/controllers/mixins/view-composer'
], (oraculum) ->
  'use strict'

  describe 'ViewComposer.ControllerMixin', ->

    testController = 'ViewComposer.ControllerMixin.Test.Controller'
    oraculum.extend 'Controller', testController, {
      mixinOptions:
        viewComposer:
          objectTest:
            view: 'View'
            eventName: 'someEvent'
            viewOptions: {'option1'}
          functionTest: ->
            view: 'View'
            eventName: 'someOtherEvent'
            viewOptions: {'option2'}
    }, {
      inheritMixins: true
      mixins: ['ViewComposer.ControllerMixin']
    }

    reuse = null
    controller = null

    beforeEach ->
      controller = oraculum.get testController
      reuse = sinon.stub controller, 'reuse'

    afterEach ->
      reuse.restore()
      controller.dispose()

    it 'should compose views based on an object spec', ->
      expect(reuse).not.toHaveBeenCalled()
      controller.trigger 'someEvent'
      expect(reuse).toHaveBeenCalledOnce()
      expect(reuse.firstCall.args[0]).toBe 'objectTest'
      expect(reuse.firstCall.args[1]).toBe 'View'
      expect(reuse.firstCall.args[2]).toEqual {'option1'}

    it 'should compose views based on an function spec', ->
      expect(reuse).not.toHaveBeenCalled()
      controller.trigger 'someOtherEvent'
      expect(reuse).toHaveBeenCalledOnce()
      expect(reuse.firstCall.args[0]).toBe 'functionTest'
      expect(reuse.firstCall.args[1]).toBe 'View'
      expect(reuse.firstCall.args[2]).toEqual {'option2'}

    it 'should wait for a promise proxy result to resolve', ->
      expect(reuse).not.toHaveBeenCalled()
      dfd = $.Deferred()
      controller.trigger 'someEvent',
        type: 'evented_proxy'
        result: dfd.promise()
      expect(reuse).not.toHaveBeenCalled()
      dfd.resolve()
      expect(reuse).toHaveBeenCalledOnce()
