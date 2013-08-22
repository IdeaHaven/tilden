'use strict'

describe 'Controller: CarouselCtrl', () ->

  # load the controller's module
  beforeEach module 'appApp'

  CarouselCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    CarouselCtrl = $controller 'CarouselCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3;
