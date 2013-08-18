'use strict'

describe 'Service: ToPretty', () ->

  # load the service's module
  beforeEach module 'appApp'

  # instantiate service
  ToPretty = {}
  beforeEach inject (_ToPretty_) ->
    ToPretty = _ToPretty_

  it 'should do something', () ->
    expect(!!ToPretty).toBe true;

  it 'should be able to format numbers into dollar formatted strings', () ->
  	expect(ToPretty.num_to_dollars(123456789)).toBe('$123,456,789')
