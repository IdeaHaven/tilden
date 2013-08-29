'use strict'

angular.module('appApp.controllers')
  .controller('IndividualCtrl', ['$scope', 'ApiGet', 'Member_data', ($scope, ApiGet, Member_data) ->


######################
# Variable Setup
######################

    # these were defined in AppCtrl and $scope will delegate to $rootScope
      # $rootScope.reps
      # $rootScope.selected
      # $rootScope.reps_list

    # init local variables

######################
# Define API Methods
######################
    #loading checks
    $scope.loaded_trandparencydata_id = false
    $scope.loaded_bio = false

    $scope.get_transparencydata_id = ()->
      if not $scope.loaded_trandparencydata_id
        ApiGet.influence "entities/id_lookup.json?bioguide_id=#{$scope.selected.rep1.bioguide_id}&", $scope.callback_transparencydata_id, this

    $scope.callback_transparencydata_id = (error, data)->
      if not error
        $scope.selected.rep1.transparencydata_id = data.id
        $scope.loaded_trandparencydata_id = true
        # $scope.get.transparencydata()
        # $scope.set_watchers_for_transparencydata_id()
        $scope.get_bio()
      else console.log "Error: ", error

    $scope.get_bio = ()->
      if not $scope.loaded_bio
        ApiGet.influence "entities/#{$scope.selected.rep1.transparencydata_id}.json?", $scope.callback_bio, this

    $scope.callback_bio = (error, data)->
      if not error
        $scope.selected.rep1.bio = data
        $scope.loaded_bio = true
      else console.log "Error: ", error

    $scope.callback_nyt = (error, data)->
      if not error
        $scope.selected.rep1.nyt_data = data
        $scope.reps[$scope.selected.rep1.bioguide_id].nyt_data = data
      else console.log "Error: ", error

    $scope.callback_littleSis_id = (error, data)->
      if not error
        $scope.selected.rep1.littleSis_id = data.Entities.Entity.id
        Member_data.get_littleSisDonors($scope.selected.rep1.littleSis_id, $scope.callback_littleSisDonors)
      else console.log "Error: ", $error

    $scope.callback_littleSisDonors = (error, data)->
      if not error
        $scope.selected.rep1.littleSis_data = data
        $scope.reps[$scope.selected.rep1.bioguide_id].littleSis_data = data
        $scope.get_donors($scope.selected.rep1.littleSis_data)
      else console.log "Error: ", error

    $scope.match = []

    $scope.get_donors = (data) ->
      _.each data, (val) ->
        if val.Relationships.Relationship.amount
          if val.Relationships.Relationship.amount >= 15000
            $scope.match.push
              name: val.name
              summary: val.summary
              amount: val.Relationships.Relationship.amount

        else if val.Relationships.Relationship[0]
          _.each val.Relationships.Relationship, (subVal) ->
            if subVal.amount >= 15000
              $scope.match.push
                name: val.name
                summary: val.summary
                amount: subVal.amount

    $scope.get_transparencydata_id()
    Member_data.get_littleSis_id($scope.selected.rep1.bioguide_id, $scope.callback_littleSis_id)
    Member_data.get_nyt($scope.selected.rep1.bioguide_id, $scope.callback_nyt)

  ])
