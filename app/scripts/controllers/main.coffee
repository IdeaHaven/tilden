'use strict'

angular.module('appApp.controllers', ['appApp.services', 'appApp.directives', 'ui.bootstrap'])
  .controller('MainCtrl', ['$scope', 'ApiGet', ($scope, ApiGet) ->
    $scope.awesomeThings = ['HTML5 Boilerplate', 'AngularJS', 'Karma']    
  ])
  .controller('BillCtrl', ['$scope', '$http', ($scope, $http) ->
    $scope.bill = {}
    $scope.bills = []
    $scope.bills.text = []
    $scope.$watch "bill", ->
      getBillText $scope.bill.last_version.urls.html

    jsonToArray = (data) ->
      results = []
      i = 0
      while i < data.length
        results.push data[i].text
        i++
      results

    getBillList = ->
      $http(
        method: "GET"
        url: "http://congress.api.sunlightfoundation.com/bills?apikey=3cdfa27b289e4d4090fd1b176c45e6cf&per_page=20&page=1"
      ).success((data, status) ->
        $scope.bills = data.results
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    getBillText = (url) ->
      $http(
        method: "GET"
        url: "http://query.yahooapis.com/v1/public/yql"
        params:
          q: "select * from html where url=\'#{url}\'"
          format: "json"
      ).success((data, status) ->
        $scope.bill.text = data.query.results.body.pre.replace(/[\n\r]/g, ' ').replace(/[_]/g, '').replace(/<all>/g, '')
        console.log $scope.bills
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    getBillList()
  ])