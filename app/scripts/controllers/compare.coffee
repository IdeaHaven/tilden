'use strict'

angular.module('appApp.controllers')
  .controller 'CompareCtrl', ['$scope','ApiGet', '$timeout', ($scope, ApiGet, $timeout) ->
######################
# Variable Setup
######################

    # these were defined in AppCtrl and $scope will delegate to $rootScope
      # $rootScope.reps
      # $rootScope.selected
      # $rootScope.reps_list

    # init local variables
    $scope.comparison =
      votes: null
      chamber: "house"
      congress: 113

    $scope.get =
      nyt: {}
      influence: {}
    $scope.cb =
      nyt: {}
      influence: {}

######################
# Define API Methods
######################
    $scope.get.nyt.overview = (bioguide_id)->
      $scope.reps[bioguide_id] = $scope.reps[bioguide_id] or {}
      # only run if data is not already available
      unless $scope.reps[bioguide_id].nyt_overview
        ApiGet.nyt "members/#{bioguide_id}", $scope.cb.nyt.overview, this, bioguide_id

    $scope.cb.nyt.overview = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].nyt_overview = data.results
      else console.log 'error', error

    $scope.get.nyt.votes = (bioguide_id1, bioguide_id2, congress, chamber)->
      ApiGet.nyt "members/#{bioguide_id1}/votes/#{bioguide_id2}/#{congress}/#{chamber}", $scope.cb.nyt.votes, this

    $scope.cb.nyt.votes = (error, data)->
      unless error
        $scope.comparison.votes = data.results
      else console.log 'Error pull nyt votes comparison: ', error

    $scope.get.influence.id = (bioguide_id)->
      $scope.reps[bioguide_id] = $scope.reps[bioguide_id] or {}
      # only run if data is not already available
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
        $scope.analysis.industries($scope.selected.rep1.bioguide_id, $scope.selected.rep2.bioguide_id)
      else console.log 'error', error


    $scope.get.nyt.bills = (bioguide_id1, bioguide_id2, congress, chamber)->
      ApiGet.nyt "members/#{bioguide_id1}/bills/#{bioguide_id2}/#{congress}/#{chamber}", $scope.cb.nyt.bills, this

    $scope.cb.nyt.bills = (error, data)->
      unless error
        $scope.comparison.bills = data.results
      else console.log 'Error pull nyt bills comparison: ', error

#####################
# Define Non-API Methods
#####################

    # this is used to update a selected rep based on the input boxes
    $scope.onSelect = ($item, $model, $label, rep)->
      $scope.selected[rep] = $item

    $scope.analysis = {}

#####################
# Data Analysis for Industries
#####################

    $scope.analysis.industries = (bioguide_id1, bioguide_id2 )->
      both = []
      _.each($scope.reps[bioguide_id1].influence.industries, (val)->
        _.each($scope.reps[bioguide_id2].influence.industries, (val1)->
          if val.id is val1.id
            obj1 = {}
            obj2 = {}
            obj1[val.name] = val.amount
            obj2[val1.name] = val1.amount
            both.push(obj1,obj2)
        )
      )
      $scope.compareIndustries = both


#####################
# Define D3 Data
#####################
    $scope.tempScale = 100000
    $scope.dummyData =
      "name": "Apple"
      "total_amount" : "30000"
    $scope.d3DonutClick = (item)->
      console.log 'D3 clicked', item
    $scope.d3_data = {amounts: [200,200,200,200,200]}

#####################
# Define Watchers
#####################

    # Watchers
    $scope.$watch 'selected.rep1', (newVal, oldVal)->
      console.log "Rep1 changed from #{oldVal.name} to #{newVal.name}"
      $scope.selected_watcher_functions('rep1', newVal.bioguide_id)
    $scope.$watch 'selected.rep2', (newVal, oldVal)->
      console.log "Rep2 changed from #{oldVal.name} to #{newVal.name}"
      $scope.selected_watcher_functions('rep2', newVal.bioguide_id)

    # Watcher Callbacks
    $scope.selected_watcher_functions = (rep, bioguide_id)->
      $scope.get.nyt.overview(bioguide_id)
      # nyt have a rate limit of 2 calls per secon
      $timeout(()->
        $scope.get.nyt.bills($scope.selected.rep1.bioguide_id, $scope.selected.rep2.bioguide_id, $scope.comparison.congress, $scope.comparison.chamber)
        $scope.get.nyt.votes($scope.selected.rep1.bioguide_id, $scope.selected.rep2.bioguide_id, $scope.comparison.congress, $scope.comparison.chamber)
      , 1000)
      $scope.get.influence.id($scope.selected[rep].bioguide_id)

#####################
# Set Reps by Route Params and Init
#####################

    # set selected reps to show in input boxes
    $scope.rep1 = $scope.selected.rep1.name
    $scope.rep2 = $scope.selected.rep2.name

  ]