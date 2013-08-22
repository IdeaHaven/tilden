'use strict'

angular.module('appApp')
  .controller('IndividualCtrl', ['$scope', 'ApiGet', ($scope, ApiGet) ->
    $scope.reps = {}
    $scope.selected = {rep1: null, rep2: null, zip: null}
    $scope.reps_names_list = []

    $scope.get_all_reps_in_office = ()->
      ApiGet.congress "legislators?per_page_all", $scope.callback_all_reps_in_office, this

    $scope.callback_all_reps_in_office = (error, data) ->
      if not error
        for rep in data
          rep.fullname = "#{rep.title}. #{rep.first_name} #{rep.last_name}"
          $scope.reps_names_list.push({name: rep.fullname})
          rep.chamber = rep.chamber.charAt(0).toUpperCase() + rep.chamber.slice(1)  # cap first letter
          rep.party_name = if rep.party is "D" then "Democrat" else if rep.party is "R" then "Republican" else rep.party
          $scope.reps[rep.bioguide_id] = {}
          $scope.reps[rep.bioguide_id].overview = rep
      else
        console.log "Error: ", error
   
    $scope.get_all_reps_in_office()
  ])
