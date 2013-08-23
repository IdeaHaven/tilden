'use strict'

angular.module('appApp.controllers')
  .controller('MainCtrl', ['$scope', 'ApiGet', ($scope, ApiGet) ->
    $scope.awesomeThings = ['HTML5 Boilerplate', 'AngularJS', 'Karma']
    $scope.htmlTooltip1 = "Find your Representatives";    
    $scope.htmlTooltip2 = "Compare your Representatives";    
    $scope.htmlTooltip3 = "Find your Representatives";    
    $scope.htmlTooltip4 = "See who Funds your Representatives";    
    $scope.htmlTooltip5 = "Search for Bills your Representatives Voted On";    
    $scope.htmlTooltip6 = "Find your Representatives";    
    $scope.htmlTooltip7 = "Geolocation";    
    $scope.htmlTooltip8 = "Annotate the Bills!";    
    $scope.htmlTooltip9 = "Deleted Tweets";    
    $scope.htmlTooltip10 = "Find your Representatives";    
    $scope.htmlTooltip11 = "Find your Representatives";    
    $scope.htmlTooltip12 = "Find your Representatives";    
  ])
