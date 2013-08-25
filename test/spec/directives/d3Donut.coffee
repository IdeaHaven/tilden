'use strict'

describe 'Directive: d3Donut', () ->

  # load the directive's module
  beforeEach module 'appApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<d3-donut></d3-donut>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the d3Donut directive'
