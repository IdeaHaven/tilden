'use strict';

angular.module('appApp.filter')
  .filter 'percent', [() ->
    (input) ->
      'percent filter: ' + input
  ]
