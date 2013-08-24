'use strict'

angular.module('appApp.controllers')
  .controller 'CompareCtrl', ['$scope','ApiGet', '$timeout', ($scope, ApiGet, $timeout) ->
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
      chamber: "house"

    $scope.rep1 = $scope.reps[$scope.selected.rep1.bioguide_id]
    $scope.rep2 = $scope.reps[$scope.selected.rep2.bioguide_id]
    $scope.get =
      nyt: {}
      influence: {}
    $scope.cb =
      nyt: {}
      influence: {}

    ##### API CALLS #####
    $scope.get.nyt.overview = (bioguide_id)->
      $scope.reps[bioguide_id] = $scope.reps[bioguide_id] or {}
      unless $scope.reps[bioguide_id].nyt_overview
        ApiGet.nyt "members/#{bioguide_id}", $scope.cb.nyt.overview, this, bioguide_id

    $scope.cb.nyt.overview = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].nyt_overview = data.results
      else console.log 'error', error

    $scope.get.nyt.votes = (bioguide_id1, bioguide_id2, congress, chamber)->
      unless $scope.comparison.votes
        ApiGet.nyt "members/#{bioguide_id1}/votes/#{bioguide_id2}/#{congress}/#{chamber}", $scope.cb.nyt.votes, this

    $scope.cb.nyt.votes = (error, data)->
      unless error
        $scope.comparison.votes = data.results
      else console.log 'Error pull nyt votes comparison: ', error

    $scope.get.influence.id = (bioguide_id)->
      $scope.reps[bioguide_id] = $scope.reps[bioguide_id] or {}
      unless $scope.reps[bioguide_id].influence
        ApiGet.influence "entities/id_lookup.json?bioguide_id=#{bioguide_id}&", $scope.cb.influence.id, this, bioguide_id

    $scope.cb.influence.id = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].influence = $scope.reps[bioguide_id].influence or {}
        $scope.reps[bioguide_id].influence.id = data.id

        # call depedents here
        $scope.get.influence.contributors(data.id, bioguide_id)
        $scope.get.influence.local(data.id, bioguide_id)
        $scope.get.influence.type(data.id, bioguide_id)
        $scope.get.influence.industries(data.id, bioguide_id)
      else console.log 'Error getting influence id: ', error

    $scope.get.influence.contributors = (transparency_id, bioguide_id)->
      # this is being called in the $scope.cb.influence.id callback so there is no need to check if the item was ever called before
      ApiGet.influence "aggregates/pol/#{transparency_id}/contributors.json?cycle=2012&limit=3&", $scope.cb.influence.contributors, this, bioguide_id

    $scope.cb.influence.contributors = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].influence.contributors = data.json
      else console.log 'error', error

    $scope.get.influence.local = (transparency_id, bioguide_id)->
      # this is being called in the $scope.cb.influence.id callback so there is no need to check if the item was ever called before
      ApiGet.influence "aggregates/pol/#{transparency_id}/contributors/local_breakdown.json?cycle=2012&", $scope.cb.influence.local, this, bioguide_id

    $scope.cb.influence.local = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].influence.local = data
      else console.log 'error', error

    $scope.get.influence.type = (transparency_id, bioguide_id)->
      # this is being called in the $scope.cb.influence.id callback so there is no need to check if the item was ever called before
      ApiGet.influence "aggregates/pol/#{transparency_id}/contributors/type_breakdown.json?cycle=2012&", $scope.cb.influence.type, this, bioguide_id

    $scope.cb.influence.type = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].influence.type = data
      else console.log 'error', error

    $scope.get.influence.industries = (transparency_id, bioguide_id)->
      # this is being called in the $scope.cb.influence.id callback so there is no need to check if the item was ever called before
      ApiGet.influence "aggregates/pol/#{transparency_id}/contributors/industries.json?cycle=2012&limit=3&", $scope.cb.influence.industries, this, bioguide_id

    $scope.cb.influence.industries = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].influence.industries = data.json
      else console.log 'error', error


    ##### Non-API Methods

    # $scope.compare_chambers = ->
    #   if $scope.rep1.nyt_overview

    ##### init
    $scope.get.nyt.overview($scope.selected.rep1.bioguide_id)
    $scope.get.nyt.overview($scope.selected.rep2.bioguide_id)
    $timeout(()=>
      $scope.get.nyt.votes($scope.selected.rep1.bioguide_id, $scope.selected.rep2.bioguide_id, 113, $scope.comparison.chamber)
    , 1000)
    $scope.get.influence.id($scope.selected.rep1.bioguide_id)
    $scope.get.influence.id($scope.selected.rep2.bioguide_id)
  ]