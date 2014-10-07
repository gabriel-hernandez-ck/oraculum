require [
  'oraculum'
  'oraculum/mixins/disposable'
  'oraculum/views/mixins/attach'
  'oraculum/views/mixins/subview'
  'oraculum/views/mixins/auto-render'
], (Oraculum) ->
  'use strict'

  describe 'Subview.ViewMixin', ->

    testSubview = 'Subview.ViewMixin.Test.Subview'
    Oraculum.extend 'View', testSubview, {
      initialize: (@viewOptions) -> #nop
    }, mixins: [
      'Disposable.Mixin'
      'Attach.ViewMixin'
      'AutoRender.ViewMixin'
    ]

    testConfig1 = testSubview1:
      view: testSubview
      viewOptions: {'test1'}

    testConfig2 = testSubview2:
      view: testSubview
      viewOptions: {'test2'}

    testView = 'Subview.ViewMixin.Test.View'
    Oraculum.extend 'View', testView, {

      mixinOptions:
        subviews: testConfig1

    }, mixins: [
      'Disposable.Mixin'
      'Subview.ViewMixin'
    ]

    view = null

    beforeEach ->
      view = Oraculum.get testView

    afterEach ->
      view.dispose()

    describe 'mixconfig', ->

      beforeEach ->
        view.dispose()

      it 'should allow the subviews configuraiton to be extended', ->
        view = Oraculum.get testView,
          subviews: testConfig2
        expect(view.mixinOptions.subviews).toEqual _.extend {
        }, testConfig1, testConfig2

    describe 'default state (initialization)', ->

      it 'should create an array of subviews', ->
        expect(view._subviews).toBeArray()
        expect(view._subviews.length).toBe 0

      it 'should create a hash of subviews by name', ->
        expect(view._subviewsByName).toBeObject()
        expect(view._subviewsByName).toEqual {}

    describe 'reactionary behavior', ->

      createSubviews = null

      beforeEach ->
        createSubviews = sinon.stub view, 'createSubviews'

      afterEach ->
        createSubviews.restore()

      it 'should invoke createSubviews after render', ->
        expect(createSubviews).not.toHaveBeenCalled()
        view.render()
        expect(createSubviews).toHaveBeenCalledOnce()

      it 'should dispose all subviews on dispose', ->
        mockView = dispose: sinon.stub()
        view._subviews.push mockView
        expect(mockView.dispose).not.toHaveBeenCalled()
        view.trigger 'dispose'
        expect(mockView.dispose).toHaveBeenCalledOnce()

    describe '"public" interface', ->

      describe 'createSubviews method', ->

        it 'should create all subviews configured in mixinOptions', ->
          view.createSubviews()
          expect(view._subviewsByName.testSubview1).toBeDefined()

        it 'should allow subview dom targets to be configured with data attributes', ->
          $element = $ '<div data-subview="testSubview1"/>'
          view.$el.html $element
          view.createSubviews()
          subview = view.subview 'testSubview1'
          expect(subview.$el).toBe $element

        it 'should allow subview container targets to be configured with data attributes', ->
          $element = $ '<div data-subview-container="testSubview1"/>'
          view.$el.html $element
          view.createSubviews()
          subview = view.subview 'testSubview1'
          expect($element).toContain subview.el

      describe 'createView method', ->

        it 'should create a view from a viewspec config', ->
          spec = testConfig2.testSubview2
          createdView = view.createView spec
          expect(createdView.__type()).toBe testSubview
          expect(createdView.viewOptions).toEqual spec.viewOptions
          createdView.dispose()

        it 'should create a view from a function that returns a viewspec config', ->
          spec = testConfig2.testSubview2
          specFunction = -> spec
          createdView = view.createView spec
          expect(createdView.__type()).toBe testSubview
          expect(createdView.viewOptions).toEqual spec.viewOptions
          createdView.dispose()

      describe 'subview method', ->

        beforeEach ->
          view.render()

        it 'should return an existing view by name if no view is provided', ->
          subview = view.subview 'testSubview1'
          expect(subview).toBe view._subviewsByName.testSubview1

        it 'should push the view into the subview hashes', ->
          mockView = {}
          subview = view.subview 'mockView', mockView
          expect(subview).toBe mockView
          expect(view._subviews[1]).toBe mockView
          expect(view._subviewsByName.mockView).toBe mockView

      describe 'createSubview method', ->

        it 'should create a view and subview it', ->
          spec = testConfig2.testSubview2
          subview = view.createSubview 'testSubview2', spec
          expect(view.subview 'testSubview2').toBe subview
          expect(subview.viewOptions).toEqual spec.viewOptions

      describe 'removeSubview method', ->

        beforeEach ->
          view.createSubviews()

        it 'should remove and dispose of a subview by name', ->
          subview = view.subview 'testSubview1'
          view.removeSubview 'testSubview1'
          expect(subview.disposed).toBe true

        it 'should remove and dispose of a subview by view', ->
          subview = view.subview 'testSubview1'
          view.removeSubview subview
          expect(subview.disposed).toBe true
