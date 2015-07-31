define ['oraculum'], (Oraculum) ->
  'use strict'

  Oraculum.define 'composeConfig', (->
    console?.warn? '''
      Oraculum composeConfig definition has been superceded by the
      Oraculum.composeConfig class/instance method provided by FactoryJS.
      This factory definition will be removed in 2.x
    '''
    return Oraculum.composeConfig
  ), singleton: true
