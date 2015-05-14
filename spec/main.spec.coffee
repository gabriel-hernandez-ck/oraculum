define [
  'oraculum'
  'Factory'
  'BackboneFactory'
], (Oraculum, Factory, BackboneFactory) ->
  'use strict'

  describe 'Oraculum', ->

    it 'should be a factory', ->
      expect(Oraculum instanceof Factory).toBe true
