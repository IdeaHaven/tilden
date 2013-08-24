'use strict'

angular.module('appApp.controllers')
  .controller('IndividualCtrl', ['$scope', 'ApiGet', 'Member_data', ($scope, ApiGet, Member_data) ->
    $scope.selected = {rep1: null, rep2: null, zip: null}
    $scope.selected_rep = {bioguide_id: "K000381"} #grab from URL

    #loading checks
    $scope.loaded_trandparencydata_id = false
    $scope.loaded_bio = false

    $scope.get_transparencydata_id = ()->
      if not $scope.loaded_trandparencydata_id
        ApiGet.influence "entities/id_lookup.json?bioguide_id=#{$scope.selected_rep.bioguide_id}&", $scope.callback_transparencydata_id, this

    $scope.callback_transparencydata_id = (error, data)->
      if not error
        $scope.selected_rep.transparencydata_id = data.id
        $scope.loaded_trandparencydata_id = true
        # $scope.get.transparencydata()
        # $scope.set_watchers_for_transparencydata_id()
        $scope.get_bio()
      else console.log "Error: ", error

    $scope.get_bio = ()->
      if not $scope.loaded_bio
        ApiGet.influence "entities/#{$scope.selected_rep.transparencydata_id}.json?", $scope.callback_bio, this

    $scope.callback_bio = (error, data)->
      if not error
        $scope.selected_rep.bio = data
        $scope.loaded_bio = true
      else console.log "Error: ", error

    $scope.callback_nyt = (error, data)->
      if not error
        $scope.selected_rep.nyt_data = data
        $scope.reps[$scope.selected_rep.bioguide_id].overview.nyt_data = data
      else console.log "Error: ", error

    $scope.callback_littleSis = (error, data)->
      if not error
        $scope.selected_rep.littleSis_data = data.query
        $scope.reps[$scope.selected_rep.bioguide_id].overview.littleSis_data = data.query
      else console.log "Error: ", error  

    $scope.get_transparencydata_id()
    Member_data.get_nyt($scope.selected_rep.bioguide_id, $scope.callback_nyt)

  ])
