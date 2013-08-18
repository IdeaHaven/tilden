'use strict'

angular.module('appApp')
  .controller('MainCtrl', ['$scope', ($scope) ->
    $scope.awesomeThings = ['HTML5 Boilerplate', 'AngularJS', 'Karma']
  ])
  .controller 'BillCtrl', ['$scope', '$http', ($scope, $http) ->
  $scope.bill = {last_version: urls: {xml: 'http://www.gpo.gov/fdsys/pkg/BILLS-113hres334ih/xml/BILLS-113hres334ih.xml'}}
  $scope.bills = []

  getBillList = ->
    $http(
      method: "JSON"
      url: "http://congress.api.sunlightfoundation.com/bills?apikey=3cdfa27b289e4d4090fd1b176c45e6cf&per_page=10&page=1"
    ).success((data, status) ->
      $scope.bills = data.results
    ).error (data, status) ->
      console.log "Error " + status + ": " + data

  getBillText = (url) ->
    $http(
      method: "XML"
      url: url
    ).success((data, status) ->
      $scope.bill.text = data
    ).error (data, status) ->
      console.log "Error " + status + ": " + data

  $scope.$watch "bill", ->
    getBillText $scope.bill.last_version.urls.xml
