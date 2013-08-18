'use strict'

describe 'Service: ApiGet', () ->

  # load the service's module
  beforeEach module 'appApp'

  # instantiate service
  ApiGet = {}
  beforeEach inject (_ApiGet_) ->
    ApiGet = _ApiGet_

  it 'should do something', () ->
    expect(!!ApiGet).toBe true;

  it 'should have a method for fetching congress data', () ->
  	expect(!!ApiGet.congress).toBe true;