define ['oraculum'], (Oraculum) ->
  'use strict'

  describe 'Coding conventions', ->

    describe 'mixins', ->
      _.each Oraculum.mixins, ({definition, options}, name) ->
        describe name, ->
          if definition.mixinOptions?
            # The correct way to add event handlers in mixins is to add them
            # programatically in mixinitialize or similar.
            it 'should not use Listener.Mixin in mixinOptions', ->
              expect(definition.mixinOptions.listen).not.toBeDefined()
