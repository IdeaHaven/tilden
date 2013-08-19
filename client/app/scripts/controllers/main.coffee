'use strict'

angular.module('appApp.controllers', ['appApp.services'])
  .controller('MainCtrl', ['$scope', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ]
  ])
