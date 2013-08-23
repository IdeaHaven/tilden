'use strict'

angular.module('appApp', ['appApp.services', 'appApp.controllers', 'appApp.directives'])
  .config ['$routeProvider', ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/bills/:billid',
        templateUrl: 'views/billtext.html'
        controller: 'BillCtrl'
      .when '/words',
        templateUrl: 'views/words.html'
        controller: 'WordsCtrl'
      .when '/individual',
        templateUrl: 'views/individual.html'
        controller: 'IndividualCtrl'
      .otherwise
        redirectTo: '/'
  ]

# set default headers to cors for api access
angular.module('appApp')
  .config ['$httpProvider', ($httpProvider) ->
    $httpProvider.defaults.useXDomain = true
    delete $httpProvider.defaults.headers.common['X-Requested-With']
  ]