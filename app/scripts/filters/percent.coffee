'use strict';

angular.module('appApp.filters')
  .filter 'percent', [() ->
    (input) ->
      'percent filter: ' + input
  ]
