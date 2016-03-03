define [
  'oraculum'
  'oraculum/models/mixins/polling'
], (oraculum) ->

  describe 'Polling.ModelMixin', ->
    Backbone = oraculum.get 'Backbone'
    oraculum.extend 'Model', 'Polling.Test.Model', {
      url: '/dev/null'
    }, mixins: ['Polling.ModelMixin']

    model = null

    afterEach ->
      model.__dispose()

    it 'should allow the polling options to be set via constructor args', ->
      model = oraculum.get 'Polling.Test.Model', {}, {
        pollingInterval: 50000
      }

      expect(model.mixinOptions.polling.interval).toBe 50000

    describe 'global polling events', ->
      it 'should pause polling events if started', ->
        model = oraculum.get 'Polling.Test.Model', {}, {
          pollingInterval: 50000
        }

        model.startPolling()
        Backbone.trigger 'polling:pause'
        expect(model._polling).toBe false

      it 'should resume polling if it was paused', ->
        model = oraculum.get 'Polling.Test.Model', {}, {
          pollingInterval: 50000
        }

        model.startPolling()
        Backbone.trigger 'polling:pause'
        Backbone.trigger 'polling:resume'
        expect(model._polling).toBe true

      it 'should not resume polling if it was not paused', ->
        model = oraculum.get 'Polling.Test.Model', {}, {
          pollingInterval: 50000
        }

        Backbone.trigger 'polling:pause'
        Backbone.trigger 'polling:resume'
        expect(model._polling).toBe undefined
