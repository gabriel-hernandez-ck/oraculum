define [
  'oraculum'
  'underscore'
], (Oraculum, _) ->
  'use strict'

  Oraculum.define 'composeConfig', (->

    composeConfig = (defaultConfig, overrideConfig, args...) ->
      if _.isFunction defaultConfig
        defaultConfig = defaultConfig.apply this, args
      if _.isFunction overrideConfig
        overrideConfig = overrideConfig.apply this, args
      return if _.isArray(defaultConfig) and _.isArray(overrideConfig)
      then [].concat defaultConfig, overrideConfig
      else _.extend {}, defaultConfig, overrideConfig

    return (defaultConfig, overrideConfigs...) ->
      return _.reduce overrideConfigs, ((defaultConfig, overrideConfig) ->
        return if _.isFunction(defaultConfig) or _.isFunction(overrideConfig)
        then -> composeConfig.call this, defaultConfig, overrideConfig, arguments...
        else composeConfig defaultConfig, overrideConfig
      ), defaultConfig

  ), singleton: true
