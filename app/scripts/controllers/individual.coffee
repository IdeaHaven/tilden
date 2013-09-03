'use strict'

angular.module('appApp.controllers')
  .controller('IndividualCtrl', ['$scope', '$location', '$routeParams', 'ApiGet', ($scope, $location, $routeParams, ApiGet) ->


######################
# Variable Setup
######################

    # these were defined in AppCtrl and $scope will delegate to $rootScope
      # $scope.reps
      # $scope.selected
      # $scope.reps_list

    # init local variables

######################
# Define API Methods
######################
    $scope.$watch "selected.rep1", (newVal, oldVal)->
      $scope.selected_watcher_functions('rep1', newVal.bioguide_id)

    $scope.selected_watcher_functions = (rep, bioguide_id)->
      $scope.get_transparencydata_id($scope.selected.rep1.bioguide_id)
      ApiGet.littleSis "entities/bioguide_id/#{$scope.selected.rep1.bioguide_id}.json?", $scope.callback_littleSis_id, this, $scope.selected.rep1.bioguide_id
      $scope.get_committees($scope.selected.rep1.bioguide_id)

    $scope.get_transparencydata_id = (bioguide_id)->
      $scope.reps[bioguide_id] = $scope.reps[bioguide_id] or {}
      if not $scope.reps[bioguide_id].influence
        ApiGet.influence "entities/id_lookup.json?bioguide_id=#{bioguide_id}&", $scope.callback_transparencydata_id, this, bioguide_id
        $scope.rep = $scope.reps[$scope.selected.rep1.bioguide_id]

    $scope.callback_transparencydata_id = (error, data, bioguide_id)->
      if not error
        $scope.reps[bioguide_id].influence = $scope.reps[bioguide_id].influence or {}
        $scope.reps[bioguide_id].influence.id = data.id
        ## Call dependents of influence id
        $scope.get_bio(data.id, bioguide_id)
      else console.log "Error: ", error

    $scope.get_bio = (transparencydata_id, bioguide_id)->
      if not $scope.reps[bioguide_id].influence.bio
        ApiGet.influence "entities/#{transparencydata_id}.json?", $scope.callback_bio, this, bioguide_id

    $scope.callback_bio = (error, data, bioguide_id)->
      if not error
        $scope.reps[bioguide_id].influence.bio = data
      else console.log "Error: ", error

    $scope.get_committees = (bioguide_id)->
      ApiGet.congress "committees?member_ids=#{bioguide_id}", $scope.callback_committees, this, bioguide_id

    $scope.callback_committees = (error, data, bioguide_id)->
      if not error
        $scope.reps[bioguide_id].committees = data
      else console.log "Error: ", error

    $scope.callback_littleSis_id = (error, data, bioguide_id)->
      if not error
        $scope.reps[bioguide_id].littleSis = $scope.reps[bioguide_id].littleSis or {}
        $scope.reps[bioguide_id].littleSis.id = data.Response.Data.Entities.Entity.id
        $scope.reps[bioguide_id].littleSis.overview = data.Response.Data.Entities.Entity
        #Call dependent on id
        ApiGet.littleSis "entity/#{$scope.reps[bioguide_id].littleSis.id}/related.json?cat_ids=5&", $scope.callback_littleSisDonors, this, bioguide_id
      else console.log "Error: ", $error

    $scope.callback_littleSisDonors = (error, data, bioguide_id)->
      match = []

      if not error
        _.each data.Response.Data.RelatedEntities.Entity, (val) ->
          if val.Relationships.Relationship.amount
            if val.Relationships.Relationship.amount >= 15000
              match.push
                name: val.name
                summary: val.summary
                amount: val.Relationships.Relationship.amount

          else if val.Relationships.Relationship[0]
            _.each val.Relationships.Relationship, (subVal) ->
              if subVal.amount >= 15000
                match.push
                  name: val.name
                  summary: val.summary
                  amount: subVal.amount

        sorted =  _.sortBy(match, (val)-> val.amount*-1).splice(0,10)
        $scope.reps[bioguide_id].littleSis.donors = sorted
      else console.log "Error: ", error

    $scope.setRepToRouteParams = () ->
      if $routeParams.bioguide_id.length > 0
        if $scope.reps[$routeParams.bioguide_id]
          $scope.selected.rep1 =
            bioguide_id: $routeParams.bioguide_id
            name: $scope.reps[$routeParams.bioguide_id].overview.fullname
        else
          console.log "Error, Senator/Rep not found."
          # set default focus

    $scope.onSelect = ($item, $model, $label, rep)->
      if rep is 'rep2'
        $scope.selected[rep] = $item
        $location.path("/compare")
      else $scope.selected[rep] = $item

##############
## Initial Calls
##############

    $scope.setRepToRouteParams()

    $scope.rep = $scope.reps[$scope.selected.rep1.bioguide_id]
    $scope.get_transparencydata_id($scope.selected.rep1.bioguide_id)
    ApiGet.littleSis "entities/bioguide_id/#{$scope.selected.rep1.bioguide_id}.json?", $scope.callback_littleSis_id, this, $scope.selected.rep1.bioguide_id
    $scope.get_committees($scope.selected.rep1.bioguide_id)

  ])
