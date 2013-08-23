'use strict'

angular.module('appApp.controllers')
  .controller('WordsCtrl', ['$scope', '$http', '$location', ($scope, $http, $location) ->
    $scope.rep = {}
    $scope.reps = []
    $scope.words = []
    $scope.$watch "rep", ->
      $scope.getRepWords()

    $scope.getRepWords = ->
      url = "http://capitolwords.org/api/1/phrases.json?entity_type=legislator&entity_value=#{$scope.rep.bioguide_id}&apikey=3cdfa27b289e4d4090fd1b176c45e6cf"
      $http(
        method: "GET"
        url: "http://query.yahooapis.com/v1/public/yql"
        params:
          q: "select * from json where url=\'#{url}\'"
          format: "json"
      ).success((data, status) ->
        $scope.words = $scope.stringToIntForWordCount(data.query.results.json.json)
        console.log $scope.words
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    $scope.getBillList = ->
      $http(
        method: "GET"
        url: "http://congress.api.sunlightfoundation.com/legislators?apikey=3cdfa27b289e4d4090fd1b176c45e6cf&chamber=senate&per_page=50&page=2"
      ).success((data, status) ->
        console.log data
        $scope.reps = data.results
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    $scope.stringToIntForWordCount = (array) ->
      i = 0

      while i < array.length
        array[i].count = Number(array[i].count)
        i++
      return array

    $scope.getBillList()
  ])