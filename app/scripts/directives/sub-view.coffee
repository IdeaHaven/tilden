'use strict';

angular.module('appApp.directives')
  .directive('subView', [()->
    restrict: 'E'
    # NOTE: the templateUrl function requires angular 1.1.4 or higher
    templateUrl: (element, attrs) ->
      "views/#{attrs.template}.html"
  ])
