define ['oraculum'], (oraculum) ->
  'use strict'

  oraculum.defineMixin 'CacheResponseHeaders.ModelMixin',

    mixinOptions:
      cacheResponseHeaders: []

    mixinitialize: ->
      @responseHeaders = @__factory().get 'Model'
      @on 'dispose', => @responseHeaders.dispose?()
      @on 'sync', (model, response, {xhr}) =>
        @responseHeaders.set _.chain(@mixinOptions.cacheResponseHeaders).map(
          (headerName) -> [headerName, xhr.getResponseHeader(headerName)]
        ).object().value()
