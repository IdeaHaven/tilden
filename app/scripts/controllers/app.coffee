'use strict'

angular.module('appApp.controllers')
  .controller 'AppCtrl', ['$scope', 'ApiGet', '$location', ($scope, ApiGet, $location) ->
######################
# Variable Setup
######################

    # these are defined here and children $scopes will delegate to them
    # values placed here will be the defaults if no values is set as a url param
    $scope.reps = {}
    $scope.reps_list = []
    $scope.selected =
      rep1: {bioguide_id: "P000197", name: "Rep. John Boehner"}
      rep2: {bioguide_id: "P000197", name: "Rep. Nancy Pelosi"}
      zip: null
      bill: null
      commiitee: null
      district: null
      state: null
      position: null

######################
# Define API Methods
######################

    $scope.get_all_reps_in_office = ()->
      ApiGet.congress "legislators?per_page=all&", $scope.callback_all_reps_in_office, this

    $scope.callback_all_reps_in_office = (error, data) ->
      unless error
        for rep in data
          rep.fullname = "#{rep.title}. #{rep.first_name} #{rep.last_name}"
          $scope.reps_list.push({name: rep.fullname, bioguide_id: rep.bioguide_id})
          rep.chamber = rep.chamber.charAt(0).toUpperCase() + rep.chamber.slice(1)  # cap first letter
          rep.party_name = if rep.party is "D" then "Democrat" else if rep.party is "R" then "Republican" else rep.party
          $scope.reps[rep.bioguide_id] = $scope.reps[rep.bioguide_id] or {}
          $scope.reps[rep.bioguide_id].overview = rep
      else
        console.warn "Error setting reps_list and overview data: ", error

#####################
# Define Non-API Methods
#####################

    # active class navbar
    $scope.isActive = (viewLocation)->
      viewLocation is $location.path().match(/^(\/\w*)\/?/)[1]

    # this is used to update a selected rep based on the input boxes
    $scope.onSelect = ($item, $model, $label, rep)->
      $scope.selected[rep] = $item

######################
# Initial Method Calls
######################

    $scope.get_all_reps_in_office()

  ]
