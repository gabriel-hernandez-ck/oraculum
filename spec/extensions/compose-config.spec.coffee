define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  describe 'composeConfig', ->
    composeConfig = null

    beforeEach ->
      composeConfig = Oraculum.get 'composeConfig'

    describe 'with objects', ->

      it 'should compose n objects', ->
        result = composeConfig {'defaultConfig'}, {'overrideConfig'}
        expect(result).toEqual {'defaultConfig', 'overrideConfig'}

      it 'should compose n functions', ->
        result = composeConfig (->{'defaultConfig'}), (->{'overrideConfig'})
        expect(result()).toEqual {'defaultConfig', 'overrideConfig'}

      it 'should compose n mixed objects/functions', ->
        defaultConfig = {'defaultConfig', functionConfig: 'defaultConfig'}
        functionConfig = -> {'functionConfig', defaultConfig: 'functionConfig'}
        overrideConfig = {'overrideConfig', functionConfig: 'overrideConfig'}
        result = composeConfig defaultConfig, functionConfig, overrideConfig
        expect(result()).toEqual {
          defaultConfig: 'functionConfig'
          functionConfig: 'overrideConfig'
          overrideConfig: 'overrideConfig'
        }

    describe 'with arrays', ->

      it 'should compose n arrays', ->
        result = composeConfig ['defaultConfig'], ['overrideConfig']
        expect(result).toEqual ['defaultConfig', 'overrideConfig']

      it 'should compose n functions', ->
        result = composeConfig (->['defaultConfig']), (->['overrideConfig'])
        expect(result()).toEqual ['defaultConfig', 'overrideConfig']

      it 'should compose n mixed arrays/functions', ->
        defaultConfig = ['defaultConfig']
        functionConfig = -> ['functionConfig']
        overrideConfig = ['overrideConfig']
        result = composeConfig defaultConfig, functionConfig, overrideConfig
        expect(result()).toEqual ['defaultConfig', 'functionConfig', 'overrideConfig']
