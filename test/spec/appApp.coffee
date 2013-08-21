'use strict'

describe('Module: appApp', () ->

  it("should be registered", () ->
    expect(angular.module('appApp')).not.toBeNull()
  )

  it("should have the submodule .services registered", () ->
    expect(angular.module('appApp.services')).not.toBeNull()
  )

  it("should have the submodule .controllers registered", () ->
    expect(angular.module('appApp.controllers')).not.toBeNull()
  )

)

describe('Module appApp:', () ->

  beforeEach(()->
    @module = angular.module('appApp')
    @dependencies = @module.requires
  )

  it('should have appApp.services as a dependency', () ->
    expect(@dependencies[0]).toEqual('appApp.services')
  )

  it('should have appApp.controllers as a dependency', () ->
    expect(@dependencies[1]).toEqual('appApp.controllers')
  )

)