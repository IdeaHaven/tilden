'use strict'

angular.module('appApp', ['appApp.services', 'appApp.controllers'])
  .config ['$routeProvider', ($routeProvider) ->
    $routeProvider.when('/', {templateUrl: 'views/main.html', controller: 'MainCtrl'})
    $routeProvider.when('/individual', {templateUrl: 'views/individual.html', controller: 'IndividualCtrl'})
    $routeProvider.otherwise({redirectTo: '/'})
  ]

# set default headers to cors for api access
angular.module('appApp')
  .config ['$httpProvider', ($httpProvider) ->
    $httpProvider.defaults.useXDomain = true
    delete $httpProvider.defaults.headers.common['X-Requested-With']
  ]