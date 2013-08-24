'use strict'

angular.module('appApp.controllers')
  .controller 'CompareCtrl', ['$scope','ApiGet', ($scope, ApiGet) ->
    #### Setup Vars #####
    #
    # $scope.selected
    # $scope.reps
    # 
    # are intialized in the AppCtrl
    #

    $scope.selected.rep1 = $scope.selected.rep1 or {}
    $scope.selected.rep2 = $scope.selected.rep2 or {}
    $scope.selected.rep1.bioguide_id = "K000381"
    $scope.selected.rep2.bioguide_id = "P000197"

    $scope.comparison =
      votes: null
      chamber: null

    # $scope.rep1 = $scope.reps[$scope.selected.rep1]
    # $scope.rep2 = $scope.reps[$scope.selected.rep2]

    $scope.get = $scope.cb = {nyt: {}}

    ##### API CALLS #####
    $scope.get.nyt.overview = (bioguide_id)->
      $scope.reps[bioguide_id] = $scope.reps[bioguide_id] or {}
      unless $scope.reps[bioguide_id].nyt_overview
        ApiGet.nyt "members/#{bioguide_id}", $scope.cb.nyt.overview, this, bioguide_id

    $scope.cb.nyt.overview = (error, data, bioguide_id) ->
      console.log arguments 
      unless error
        $scope.reps[bioguide_id].nyt_overview = data
      else console.log 'error', error

    $scope.get.nyt.votes = (bioguide_id1, bioguide_id2, congress, chamber)->
      unless $scope.comparison.votes
        ApiGet.nyt "members/#{bioguide_id1}/votes/#{bioguide_id2}/#{congress}/#{chamber}", $scope.cb.nyt.votes, this

    $scope.cb.nyt.votes = (error, data)->
      unless error
        $scope.comparison.votes = data
      else console.log 'Error pull nyt votes comparison: ', error

    ##### Non-API Methods

    # $scope.compare_chambers = ->
    #   if $scope.rep1.nyt_overview

    ##### init  
    $scope.get.nyt.overview($scope.selected.rep1.bioguide_id)        
    # $scope.get.nyt.overview($scope.selected.rep2.bioguide_id)
    # $scope.get.nyt.votes($scope.selected.rep1.bioguide_id, $scope.selected.rep2.bioguide_id, 113, $scope.comparison.chamber)
  ]