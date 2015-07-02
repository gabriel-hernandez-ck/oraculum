beforeEach ->
  jasmine.addMatchers

    toBeType: (util, customEqualityTesters) ->
      compare: (actual, expected) ->
        return pass: actual.__type() is expected

    toHaveTag: (util, customEqualityTesters) ->
      compare: (actual, expected) ->
        return pass: expected in actual.__tags()

    toUseMixin: (util, customEqualityTesters) ->
      compare: (actual, expected) ->
        return pass: expected in actual.__mixins()

    toBeInstanceOf: (util, customEqualityTesters) ->
      compare: (actual, expected) ->
        return pass: actual instanceof expected
