'use strict'

angular.module('appApp.controllers')
  .controller('WordsCtrl', ['$scope', '$http', '$location', '$timeout', ($scope, $http, $location, $timeout) ->
    $scope.rep = {}
    $scope.reps = []
    $scope.state = "CA"
    $scope.states = ["AK","AL","AR","AS","AZ","CA","CO","CT","DC","DE","FL","GA","GU","HI","IA","ID","IL","IN","KS","KY","LA","MA","MD","ME","MH","MI","MN","MO","MS","MT","NC","ND","NE","NH","NJ","NM","NV","NY","OH","OK","OR","PA","PR","PW","RI","SC","SD","TN","TX","UT","VA","VI","VT","WA","WI","WV","WY"]
    $scope.words = []
    $scope.wordQuery = ""
    $scope.wordFrequency = ""

    $scope.$watch "rep", ->
      $scope.words = []
      $scope.getRepWords()
    $scope.$watch "wordQuery", ->
      $timeout.cancel
      if $scope.wordQuery == ""
        $scope.wordFrequency = "?"
      else
        $scope.wordFrequency = "..."
        $timeout($scope.getWordFrequency, 2000)
    $scope.$watch "state", ->
      $scope.getRepList()
    

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
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    $scope.getRepList = ->
      $http(
        method: "GET"
        url: "http://congress.api.sunlightfoundation.com/legislators?state=#{$scope.state}&per_page=all&apikey=3cdfa27b289e4d4090fd1b176c45e6cf"
      ).success((data, status) ->
        $scope.reps = $scope.makeRepFullName(data.results)
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    $scope.getWordFrequency = ->
      url = "http://capitolwords.org/api/1/dates.json?phrase=#{$scope.wordQuery.replace(/\s/g, '+')}&apikey=3cdfa27b289e4d4090fd1b176c45e6cf"
      $http(
        method: "GET"
        url: "http://query.yahooapis.com/v1/public/yql"
        params:
          q: "select * from json where url=\'#{url}\'"
          format: "json"
      ).success((data, status) ->
        $scope.wordFrequency = 0
        $scope.wordFrequency = $scope.countFrequency(data.query.results.json.results)
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    $scope.stringToIntForWordCount = (array) ->
      i = 0

      while i < array.length
        array[i].count = Number(array[i].count)
        i++
      return array

    $scope.countFrequency = (array) ->
      i = 0
      count = 0

      while i < array.length
        count += Number(array[i].count)
        i++
      return count

    $scope.makeRepFullName = (array) ->
      i = 0
      
      while i < array.length
        array[i].full_name = "#{array[i].title}. #{array[i].first_name} #{array[i].last_name}"
        i++
      return array

  ])
