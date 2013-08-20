'use strict';

angular.module('appApp.directives', [])
  .directive('subView', [()->
    restrict: 'E'
    # TODO: Refactor the route below after updating to angular 1.1.4 or higher.
    templateUrl: "views/header/individual.html"
  ])
 