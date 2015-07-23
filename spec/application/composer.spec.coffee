# Unit tests ported from Chaplin
define ['oraculum'], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  describe 'Composer', ->

    composer = null
    listener = null

    Oraculum.extend('View', 'Composer.Test1.View', {})
    Oraculum.extend('View', 'Composer.Test2.View', {})
    TestView1 = Oraculum.getConstructor 'Composer.Test1.View'
    TestView2 = Oraculum.getConstructor 'Composer.Test2.View'

    beforeEach ->
      composer = Oraculum.get 'Composer'
      listener = Oraculum.get 'Listener.SpecHelper'

    afterEach ->
      listener.publishEvent 'dispatcher:dispatch'
      listener.dispose()
      composer.dispose()

    it 'should use PubSub.Mixin', -> expect(composer).toUseMixin 'PubSub.Mixin'
    it 'should use Listener.Mixin', -> expect(composer).toUseMixin 'Listener.Mixin'
    it 'should use Disposable.Mixin', -> expect(composer).toUseMixin 'Disposable.Mixin'
    it 'should use CallbackProvider.Mixin', -> expect(composer).toUseMixin 'CallbackProvider.Mixin'

    it 'should initialize an instance when it is composed for the first time', ->
      listener.executeCallback 'composer:compose', 'test1', TestView1
      instance = listener.executeCallback 'composer:retrieve', 'test1'
      expect(instance).toBeInstanceOf TestView1

    it 'should not initialize an instance if it is already composed', ->
      instance1 = listener.executeCallback 'composer:compose', 'test1', TestView1
      instance2 = listener.executeCallback 'composer:compose', 'test1', TestView1
      instance3 = listener.executeCallback 'composer:compose', 'test2', TestView2
      expect(instance1).toBe instance2
      expect(instance2).not.toBe instance3
      expect(instance1).toBeInstanceOf TestView1
      expect(instance3).toBeInstanceOf TestView2

    it 'should dispose a composed view if it is not re-composed', ->
      listener.executeCallback 'composer:compose', 'test1', TestView1
      listener.executeCallback 'composer:compose', 'test2', TestView2

      # Trigger a cleanup
      listener.publishEvent 'dispatcher:dispatch'

      # Try to get the instances
      instance1 = listener.executeCallback 'composer:retrieve', 'test1'
      instance2 = listener.executeCallback 'composer:retrieve', 'test2'

      # Expect to have failed
      expect(instance1).not.toBeDefined()
      expect(instance2).not.toBeDefined()

    it 'should allow a function to be composed with options', ->
      options = {}
      compose = sinon.stub()
      listener.executeCallback 'composer:compose', 'spy', compose, options
      listener.publishEvent 'dispatcher:dispatch'
      expect(compose).toHaveBeenCalledOnce()
      expect(compose).toHaveBeenCalledWith options

    it 'should allow a function to be composed with the object interface', ->
      options = {}
      compose = sinon.stub()
      listener.executeCallback 'composer:compose', 'spy', {compose, options}
      listener.publishEvent 'dispatcher:dispatch'
      expect(compose).toHaveBeenCalledOnce()
      expect(compose).toHaveBeenCalledWith options

    it 'should invoke compose when an instance should be composed', ->
      composition = listener.executeCallback 'composer:compose', 'weird',
        check: -> false
        compose: -> @view = new TestView1()
      expect(composition.view).toBeInstanceOf TestView1

      composition = listener.executeCallback 'composer:compose', 'weird',
        compose: -> @view = new TestView2()
      expect(composition.view).toBeInstanceOf TestView2

    it 'should dispose the entire composition when necessary', ->
      composition = listener.executeCallback 'composer:compose', 'weird',
        check: -> false
        compose: ->
          @view1 = new TestView1()
          @view2 = new TestView1()
      expect(composition.view1).toBeInstanceOf TestView1
      expect(composition.view2).toBeInstanceOf TestView1
      expect(composition.view1).not.toBe composition.view2

    it 'should allow a composition to be composed', ->
      options = {}
      compose = sinon.stub()
      CustomComposition = Oraculum.extend('Composition', 'CustomComposition', {
        compose
      }, { inheritMixins: true }).getConstructor 'CustomComposition'
      listener.executeCallback 'composer:compose', 'spy', CustomComposition, options
      expect(compose).toHaveBeenCalledOnce()
      expect(compose).toHaveBeenCalledWith options

    it 'should throw for invalid invocations', ->
      expect(-> listener.executeCallback 'composer:compose', 'spy', null).toThrow()
      expect(-> listener.executeCallback 'composer:compose', compose: /a/, check: '').toThrow()
