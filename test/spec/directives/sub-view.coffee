'use strict'

describe 'Directive: subView', () ->
  beforeEach module 'appApp.directives'

  element = {}

  # it 'should make hidden element visible', inject ($rootScope, $compile) ->
  #   element = angular.element '<sub-view></sub-view>'
  #   element = $compile(element) $rootScope
  #   expect(element.text()).toBe 'this is the subView directive'
