define ['oraculum'], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'

  describe 'Attach.ViewMixin', ->
    view = null

    Oraculum.extend 'View', 'Attach.Test1.View', {
      id: 'attach_test1_view'
    }, mixins: [
      'Disposable.Mixin'
      'Attach.ViewMixin'
    ]

    testbed = $testbed = null
    beforeEach -> $testbed = $(testbed = createTestbed())
    afterEach -> removeTestbed()

    it 'should use EventedMethod.Mixin', ->
      expect(Oraculum.get 'Attach.Test1.View').toUseMixin 'EventedMethod.Mixin'

    it 'should read autoAttach, container, containerMethod at construction', ->
      view = Oraculum.get 'Attach.Test1.View',
        autoAttach: false
        container: 'container2'
        containerMethod: 'prepend'
      expect(view.mixinOptions.attach.auto).toBe false
      expect(view.mixinOptions.attach.container).toBe 'container2'
      expect(view.mixinOptions.attach.containerMethod).toBe 'prepend'

    it 'should not attach itself if autoAttach is false', ->
      view = Oraculum.get 'Attach.Test1.View',
        container: testbed
        autoAttach: false
      expect(testbed).not.toContainElement view.el
      view.render()
      expect(testbed).not.toContainElement view.el

    it 'should attach itself to an element automatically on render', ->
      view = Oraculum.get 'Attach.Test1.View', container: testbed
      expect(testbed).not.toContainElement view.el
      view.render()
      expect(testbed).toContainElement view.el

    it 'should attach itself to a selector automatically on render', ->
      view = Oraculum.get('Attach.Test1.View', container: '#testbed').render()
      expect(testbed).toContainElement view.el

    it 'should attach itself to a jQuery object automatically on render', ->
      view = Oraculum.get('Attach.Test1.View', container: $('#testbed')).render()
      expect(testbed).toContainElement view.el

    it 'should use the provided container method', ->
      $testbed.html '<div id="last_element"/>'
      view = Oraculum.get('Attach.Test1.View', {
        container: testbed
        containerMethod: 'prepend'
      }).render()
      expect(testbed).toContainElement view.el
      expect(view.$el.index()).toBe 0

    it 'should not attach itself more than once', ->
      spy = sinon.spy testbed, 'appendChild'
      view = Oraculum.get 'Attach.Test1.View', container: testbed
      view.render()
      view.render()
      expect(spy).toHaveBeenCalledOnce()
      spy.restore()
