'use strict'

describe 'Filter: percent', () ->

  # load the filter's module
  beforeEach module 'appApp.filters'

  # initialize a new instance of the filter before each test
  percent = {}
  beforeEach inject ($filter) ->
    percent = $filter 'percent'

  it 'should return the input prefixed with "percent filter:"', () ->
    text = 'angularjs'
    expect(percent text).toBe ('percent filter: ' + text);
