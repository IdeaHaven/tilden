'use strict'

describe 'Controller: CompareCtrl', () ->

  # load the controller's module
  beforeEach module 'appApp.controllers'

  CompareCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    CompareCtrl = $controller 'CompareCtrl', {
      $scope: scope
    }

  xit 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3;
