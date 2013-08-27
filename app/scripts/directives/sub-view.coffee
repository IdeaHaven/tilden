'use strict';

angular.module('appApp.directives')
  .directive 'subView', [()->
    restrict: 'E'
    templateUrl: (element, attrs) ->
      "views/#{attrs.template}.html"
  ]
